#!/bin/bash
set -euo pipefail

#nb: must be bash to support shopt globstar
shopt -s globstar extglob

#ANSI Escape Codes for colors to increase contrast of errors
RED="\033[0;31m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
NC="\033[0m" # No Color

st=0

# check for ripgrep
if command -v rg >/dev/null 2>&1; then
	grep=rg
	pcre2_support=1
	if [ ! rg -P '' >/dev/null 2>&1 ] ; then
		pcre2_support=0
	fi
	code_files="code/**/**.dm"
	map_files="maps/**/**.dmm"
	code_x_515="code/**/!(_byond_version_compat).dm"
else
	pcre2_support=0
	grep=grep
	code_files="-r --include=code/**/**.dm"
	map_files="-r --include=maps/**/**.dmm"
	code_x_515="-r --include=code/**/!(_byond_version_compat).dm"
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

section "map issues"

part "TGM"
if grep -El '^\".+\" = \(.+\)' $map_files;	then
	echo
	echo -e "${RED}ERROR: Non-TGM formatted map detected. Please convert it using Map Merger!${NC}"
	st=1
fi;

part "iconstate tags"
if grep -P '^\ttag = \"icon' $map_files;	then
	echo
	echo -e "${RED}ERROR: tag vars from icon state generation detected in maps, please remove them.${NC}"
	st=1
fi;

part "step variables"
if grep -P 'step_[xy]' $map_files;	then
	echo
	echo -e "${RED}ERROR: step_x/step_y variables detected in maps, please remove them.${NC}"
	st=1
fi;

part "pixel offsets"
if grep -P 'pixel_[^xy]' $map_files;	then
	echo
	echo -e "${RED}ERROR: incorrect pixel offset variables detected in maps, please remove them.${NC}"
	st=1
fi;

#part "varedited cables"
#if grep -P '/obj/structure/cable(/\w+)+\{' $map_files;	then
#	echo
#	echo -e "${RED}ERROR: Variable editted cables detected, please remove them.${NC}"
#	st=1
#fi;

part "wrongly offset APCs"
if grep -Pzo '/obj/structure/machinery/power/apc[/\w]*?\{\n[^}]*?pixel_[xy] = -?[013-9]\d*?[^\d]*?\s*?\},?\n' $map_files ||
	grep -Pzo '/obj/structure/machinery/power/apc[/\w]*?\{\n[^}]*?pixel_[xy] = -?\d+?[0-46-9][^\d]*?\s*?\},?\n' $map_files ||
	grep -Pzo '/obj/structure/machinery/power/apc[/\w]*?\{\n[^}]*?pixel_[xy] = -?\d{3,1000}[^\d]*?\s*?\},?\n' $map_files ;	then
	echo -e "${RED}ERROR: found an APC with a manually set pixel_x or pixel_y that is not +-25.${NC}"
	st=1
fi;

part "vareditted areas"
if grep -P '^/area/.+[\{]' $map_files;	then
	echo -e "${RED}ERROR: Vareditted /area path use detected in maps, please replace with proper paths.${NC}"
	st=1
fi;

part "base /turf usage"
if grep -P '\W\/turf\s*[,\){]' $map_files; then
	echo
	echo -e "${RED}ERROR: base /turf path use detected in maps, please replace with proper paths.${NC}"
	st=1
fi;

part "/obj/structure misuse"
if grep -P '^\/obj\/structure\{$' $map_files;	then
	echo
	echo -e "${RED}ERROR: individually defined /obj/structure objects detected in map files, please replace them with pre-defined objects.${NC}"
	st=1
fi;

section "whitespace issues"

part "space indentation"
if grep -P '(^ {2})|(^ [^ * ])|(^    +)' $code_files; then
	echo
	echo -e "${RED}ERROR: space indentation detected.${NC}"
	st=1
fi;

part "mixed tab/space indentation"
if grep -P '^\t+ [^ *]' $code_files; then
	echo
	echo -e "${RED}ERROR: mixed <tab><space> indentation detected.${NC}"
	st=1
fi;

part "missing trailing newlines"
nl='
'
nl=$'\n'
while read f; do
	t=$(tail -c2 "$f"; printf x); r1="${nl}$"; r2="${nl}${r1}"
	if [[ ! ${t%x} =~ $r1 ]]; then
		echo
		echo -e "${RED}ERROR: file $f is missing a trailing newline.${NC}"
		st=1
	fi;
done < <(find . -type f -name '*.dm')

section "common mistakes"

part "var in proc args"
if grep -P '^/[\w/]\S+\(.*(var/|, ?var/.*).*\)' $code_files; then
	echo
	echo -e "${RED}ERROR: changed files contains proc argument starting with 'var'.${NC}"
	st=1
fi;

part "unmanaged global vars"
if grep -P '^/*var/' $code_files; then
	echo
	echo -e "${RED}ERROR: Unmanaged global var use detected in code, please use the helpers.${NC}"
	st=1
fi;


part "map json naming"
if ls maps/*.json | grep -P "[A-Z]"; then
	echo
	echo -e "${RED}ERROR: Uppercase in a map json detected, these must be all lowercase.${NC}"
	st=1
fi;

part "map json sanity"
for json in maps/*.json
do
	map_path=$(jq -r '.map_path' $json)
	override_map=$(jq -r '.override_map' $json)
	while read map_file; do
		filename="maps/$map_path/$map_file"
		if [ ! -f $filename ] && [ -z "$override_map" ]
		then
			echo
			echo -e "${RED}ERROR: found invalid file reference to $filename in _maps/$json.${NC}"
			st=1
		fi
	done < <(jq -r '[.map_file] | flatten | .[]' $json)
done

part "balloon_alert sanity"
if $grep 'balloon_alert\(".*"\)' $code_files; then
	echo
	echo -e "${RED}ERROR: Found a balloon alert with improper arguments.${NC}"
	st=1
fi;

if $grep 'balloon_alert(.*span_)' $code_files; then
	echo
	echo -e "${RED}ERROR: Balloon alerts should never contain spans.${NC}"
	st=1
fi;

part "balloon_alert idiomatic usage"
if $grep 'balloon_alert\(.*?, ?"[A-Z]' $code_files; then
	echo
	echo -e "${RED}ERROR: Balloon alerts should not start with capital letters. This includes text like 'AI'. If this is a false positive, wrap the text in UNLINT().${NC}"
	st=1
fi;

part "to_chat without user"
if $grep 'to_chat\(("|SPAN)' $code_files; then
	echo
	echo -e "${RED}ERROR: to_chat() requires a target as its first argument.${NC}"
	st=1
fi;

section "515 Proc Syntax"
part "proc ref syntax"
if $grep '\.proc/' $code_x_515 ; then
    echo
    echo -e "${RED}ERROR: Outdated proc reference use detected in code, please use proc reference helpers.${NC}"
    st=1
fi;

if [ "$pcre2_support" -eq 1 ]; then
	section "regexes requiring PCRE2"
	part "long list formatting"
	if $grep -PU '^(\t)[\w_]+ = list\(\n\1\t{2,}' code/**/*.dm; then
		echo -e "${RED}ERROR: Long list overindented, should be two tabs.${NC}"
		st=1
	fi;
	if $grep -PU '^(\t)[\w_]+ = list\(\n\1\S' code/**/*.dm; then
		echo -e "${RED}ERROR: Long list underindented, should be two tabs.${NC}"
		st=1
	fi;
	if $grep -PU '^(\t)[\w_]+ = list\([^\s)]+( ?= ?[\w\d]+)?,\n' code/**/*.dm; then
		echo -e "${RED}ERROR: First item in a long list should be on the next line.${NC}"
		st=1
	fi;
	if $grep -PU '^(\t)[\w_]+ = list\(\n(\1\t\S+( ?= ?[\w\d]+)?,\n)*\1\t[^\s,)]+( ?= ?[\w\d]+)?\n' code/**/*.dm; then
		echo -e "${RED}ERROR: Last item in a long list should still have a comma.${NC}"
		st=1
	fi;
	if $grep -PU '^(\t)[\w_]+ = list\(\n(\1\t[^\s)]+( ?= ?[\w\d]+)?,\n)*\1\t[^\s)]+( ?= ?[\w\d]+)?\)' code/**/*.dm; then
		echo -e "${RED}ERROR: The ) in a long list should be on a new line.${NC}"
		st=1
	fi;
	if $grep -PU '^(\t)[\w_]+ = list\(\n(\1\t[^\s)]+( ?= ?[\w\d]+)?,\n)+\1\t\)' code/**/*.dm; then
		echo -e "${RED}ERROR: The ) in a long list should match identation of the opening list line.${NC}"
		st=1
	fi;
else
	echo -e "${RED}pcre2 not supported, skipping checks requiring pcre2"
	echo -e "if you want to run these checks install ripgrep with pcre2 support.${NC}"
fi

if [ $st = 0 ]; then
	echo
	echo -e "${GREEN}No errors found using grep!${NC}"
fi;

if [ $st = 1 ]; then
	echo
	echo -e "${RED}Errors found, please fix them and try again.${NC}"
fi;

exit $st
