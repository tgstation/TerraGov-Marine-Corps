#define CROWNFILE "[global.config.directory]/crownwearers.txt"

GLOBAL_LIST(crownwearers)
GLOBAL_PROTECT(crownwearers)

/proc/load_crownlist()
	GLOB.crownwearers = list()
	for(var/line in world.file2list(CROWNFILE))
		if(!line)
			continue
		if(findtextEx(line,"#",1,2))
			continue
		GLOB.crownwearers += ckey(line)

	if(!GLOB.crownwearers.len)
		GLOB.crownwearers = null

/proc/check_crownlist(ckey)
	if(!GLOB.crownwearers)
		return FALSE
	. = (ckey in GLOB.crownwearers)

#undef CROWNFILE
