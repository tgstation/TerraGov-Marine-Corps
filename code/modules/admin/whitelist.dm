#ifdef TESTSERVER
	#define WHITELISTFILE	"[global.config.directory]/roguetown/wl_test.txt"
#else
	#define WHITELISTFILE	"[global.config.directory]/roguetown/wl_mat.txt"
#endif

GLOBAL_LIST_EMPTY(whitelist)
GLOBAL_PROTECT(whitelist)

/proc/load_whitelist()
	GLOB.whitelist = list()
	for(var/line in world.file2list(WHITELISTFILE))
		if(!line)
			continue
		if(findtextEx(line,"#",1,2))
			continue
		GLOB.whitelist += ckey(line)

/proc/check_whitelist(ckey)
	if(!GLOB.whitelist || !GLOB.whitelist.len)
		load_whitelist()
#ifdef TESTSERVER
	var/plevel = check_patreon_lvl(ckey)
	if(plevel >= 3)
		return TRUE
#endif
	return (ckey in GLOB.whitelist)
#undef WHITELISTFILE
