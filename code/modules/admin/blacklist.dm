#define BLACKLISTFILE "[global.config.directory]/roguetown/bans/blacklist.txt"

GLOBAL_LIST_EMPTY(blacklist)
GLOBAL_PROTECT(blacklist)

/proc/load_blacklist()
	if(GLOB.blacklist.len)
		return
	GLOB.blacklist = list()
	for(var/line in world.file2list(BLACKLISTFILE))
		if(!line)
			continue
		if(findtextEx(line,"#",1,2))
			continue
		GLOB.blacklist += ckey(line)

	if(!GLOB.blacklist.len)
		GLOB.blacklist = null

/proc/check_blacklist(ckey)
	if(!GLOB.blacklist)
		return FALSE
	if(!GLOB.blacklist.len)
		load_blacklist()
	. = (ckey in GLOB.blacklist)

#undef BLACKLISTFILE

#define NAMEBANFILE "[global.config.directory]/roguetown/nameban.txt"

GLOBAL_LIST(nameban)
GLOBAL_PROTECT(nameban)

/proc/load_nameban()
	GLOB.nameban = list()
	for(var/line in world.file2list(NAMEBANFILE))
		if(!line)
			continue
		if(findtextEx(line,"#",1,2))
			continue
		GLOB.nameban += ckey(line)

	if(!GLOB.nameban.len)
		GLOB.nameban = null

/proc/check_nameban(ckey)
	if(!GLOB.nameban)
		return FALSE
	. = (ckey in GLOB.nameban)

#undef NAMEBANFILE


#define PSYCHOFILE "[global.config.directory]/roguetown/psychokiller.txt"

GLOBAL_LIST(psychokiller)
GLOBAL_PROTECT(psychokiller)

/proc/load_psychokiller()
	GLOB.psychokiller = list()
	for(var/line in world.file2list(PSYCHOFILE))
		if(!line)
			continue
		if(findtextEx(line,"#",1,2))
			continue
		GLOB.psychokiller += ckey(line)

	if(!GLOB.psychokiller.len)
		GLOB.psychokiller = null

/proc/check_psychokiller(ckey)
	if(!GLOB.psychokiller)
		return FALSE
	. = (ckey in GLOB.psychokiller)

#undef PSYCHOFILE


#define BYPASSAGEFILE "[global.config.directory]/roguetown/bypassage.txt"

GLOBAL_LIST(bypassage)
GLOBAL_PROTECT(bypassage)

/proc/load_bypassage()
	GLOB.bypassage = list()
	for(var/line in world.file2list(BYPASSAGEFILE))
		if(!line)
			continue
		if(findtextEx(line,"#",1,2))
			continue
		GLOB.bypassage += ckey(line)

	if(!GLOB.bypassage.len)
		GLOB.bypassage = null

/proc/check_bypassage(ckey)
	if(!GLOB.bypassage)
		return FALSE
	. = (ckey in GLOB.bypassage)

#undef BYPASSAGEFILE