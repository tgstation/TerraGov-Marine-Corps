#!/bin/bash
set -euo pipefail

#nb: must be bash to support shopt globstar
shopt -s globstar extglob

#ANSI Escape Codes for colors to increase contrast of errors
RED="\033[0;31m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
NC="\033[0m" # No Color


# check for ripgrep
if command -v rg >/dev/null 2>&1; then
	grep=rg
	pcre2_support=1
	if [ ! rg -P '' >/dev/null 2>&1 ] ; then
		pcre2_support=0
	fi
	code_files="code/**/**.dm"
	map_files="_maps/**/**.dmm"
	code_x_515="code/**/!(__byond_version_compat).dm"
else
	pcre2_support=0
	grep=grep
	code_files="-r --include=code/**/**.dm"
	map_files="-r --include=_maps/**/**.dmm"
	code_x_515="-r --include=code/**/!(__byond_version_compat).dm"
fi

echo -e "${BLUE}Using grep provider at $(which $grep)${NC}"

part=0
section() {
	echo -e "${BLUE}Checking for $1${NC}..."
	part=0
}

part() {
	part=$((part+1))
	padded=$(printf "%02d" $part)
	echo -e "${GREEN} $padded- $1${NC}"
}

st=0

echo "Checking for TGM formatting"
if grep -El '^\".+\" = \(.+\)'  $map_files;	then
    echo "Non-TGM formatted map detected. Please convert it using Map Merger!"
    st=1
fi;
echo "Checking for mapping tags"
if grep -nP '^\ttag = \"icon'  $map_files;	then
    echo "tag vars from icon state generation detected in maps, please remove them."
    st=1
fi;


echo "Checking for unmanaged globals"
if grep -nP '^/*var/' $code_files; then
    echo "Unmanaged global var use detected in code, please use the helpers."
    st=1
fi;
echo "Checking for src changing"
if grep -nP '^\t+src = ' $code_files; then
    echo "Illegal src change detected, please amend"
    st=1
fi;
echo "Checking for 0 length timers"
if grep -nP 'addtimer\(.+?, ?0\)($| |/)' $code_files; then
	echo "Default timer type with no length detected. Please add the correct flags or use the async macro call"
	st=1
fi;
echo "Checking for default return value returns"
if grep -nP '^\s*return \.\s*\n' $code_files; then
    echo "Default return value return detected"
    st=1
fi;
echo "Checking for space indentation"
if grep -nP '(^ {2})|(^ [^ * ])|(^    +)' $code_files; then
    echo "space indentation detected"
    st=1
fi;
echo "Checking for mixed indentation"
if grep -nP '^\t+ [^ *]' $code_files; then
    echo "mixed <tab><space> indentation detected"
    st=1
fi;
echo "Checking long list formatting"
if grep -nPzo '^(\t)[\w_]+ = list\(\n\1\t{2,}' $code_files; then
    echo "long list overidented, should be two tabs"
    st=1
fi;
if grep -nPzo '^(\t)[\w_]+ = list\(\n\1\S' $code_files; then
    echo "long list underindented, should be two tabs"
    st=1
fi;
if grep -nPzo '^(\t)[\w_]+ = list\([^\s)]+( ?= ?[\w\d]+)?,\n' $code_files; then
    echo "first item in a long list should be on the next line"
    st=1
fi;
if grep -nPzo '^(\t)[\w_]+ = list\(\n(\1\t\S+( ?= ?[\w\d]+)?,\n)*\1\t[^\s,)]+( ?= ?[\w\d]+)?\n' $code_files; then
    echo "last item in a long list should still have a comma"
    st=1
fi;
if grep -nPzo '^(\t)[\w_]+ = list\(\n(\1\t[^\s)]+( ?= ?[\w\d]+)?,\n)*\1\t[^\s)]+( ?= ?[\w\d]+)?\)' $code_files; then
    echo ") in a long list should be on a new line"
    st=1
fi;
if grep -nPzo '^(\t)[\w_]+ = list\(\n(\1\t[^\s)]+( ?= ?[\w\d]+)?,\n)+\1\t\)' $code_files; then
    echo "the ) in a long list should match identation of the opening list line"
    st=1
fi;

if $grep -PU '[^\n]$(?!\n)' $code_files; then
	echo
	echo -e "${RED}ERROR: File(s) with no trailing newline detected, please add one.${NC}"
	st=1
fi
if grep -nP '^/[\w/]\S+\(.*(var/|, ?var/.*).*\)' $code_files; then
    echo "changed files contains proc argument starting with 'var'"
    st=1
fi;
if grep -ni 'centcomm' $code_files; then
    echo "Misspelling(s) of CENTCOM detected in code, please remove the extra M(s)."
    st=1
fi;
if grep -ni 'centcomm' $map_files; then
    echo "Misspelling(s) of CENTCOM detected in maps, please remove the extra M(s)."
    st=1
fi;
if grep -ni 'nanotransen' $code_files; then
    echo "Misspelling(s) of nanotrasen detected in code, please remove the extra N(s)."
    st=1
fi;
if grep -ni 'nanotransen' $map_files; then
    echo "Misspelling(s) of nanotrasen detected in maps, please remove the extra N(s)."
    st=1
fi;
if ls _maps/*.json | grep -nP "[A-Z]"; then
    echo "Uppercase in a map json detected, these must be all lowercase."
	st=1
fi;
for json in _maps/*.json
do
    filename="_maps/$(jq -r '.map_path' $json)/$(jq -r '.map_file' $json)"
    if [ ! -f $filename ]
    then
        echo "found invalid file reference to $filename in _maps/$json"
        st=1
    fi
done

# Check for non-515 compatable .proc/ syntax
if grep -P --exclude='__byond_version_compat.dm' '\.proc/' $code_x_515; then
    echo "ERROR: Outdated proc reference use detected in code, please use proc reference helpers."
    st=1
fi;

exit $st
