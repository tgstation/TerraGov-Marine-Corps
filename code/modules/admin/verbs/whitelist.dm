#define WHITELISTFILE "[global.config.directory]/whitelist.txt"

GLOBAL_LIST(whitelist)
GLOBAL_PROTECT(whitelist)

/proc/load_whitelist()
	GLOB.whitelist = list()
	for(var/line in file2list(WHITELISTFILE))
		if(!line)
			continue
		if(findtextEx_char(line,"#",1,2))
			continue
		GLOB.whitelist += ckey(line)

	if(!GLOB.whitelist.len)
		GLOB.whitelist = null

/proc/check_whitelist(ckey)
	if(!GLOB.whitelist)
		return FALSE
	. = (ckey in GLOB.whitelist)

#undef WHITELISTFILE
