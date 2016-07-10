#define WHITELISTFILE "data/whitelist.txt"

var/list/whitelist = list()

/hook/startup/proc/loadWhitelist()
	if(config.usewhitelist)
		load_whitelist()
	return 1

/proc/load_whitelist()
	whitelist = file2list(WHITELISTFILE)
	if(!whitelist.len)	whitelist = null

/proc/check_whitelist(mob/M /*, var/rank*/)
	if(!whitelist)
		return 0
	return ("[M.ckey]" in whitelist)

/var/list/alien_whitelist = list()

/hook/startup/proc/loadAlienWhitelist()
	if(config.usealienwhitelist)
		load_alienwhitelist()
	return 1

/proc/load_alienwhitelist()
	var/text = file2text("config/alienwhitelist.txt")
	if (!text)
		log_misc("Failed to load config/alienwhitelist.txt")
	else
		alien_whitelist = text2list(text, "\n")

//todo: admin aliens
/proc/is_alien_whitelisted(mob/M, var/species)
	if(!config.usealienwhitelist) //If there's not config to use the whitelist.
		return 1
	if(species == "human" || species == "Human")
		return 1
//	if(check_rights(R_ADMIN, 0)) //Admins are not automatically considered to be whitelisted anymore. ~N
//		return 1				//This actually screwed up a bunch of procs, but I only noticed it with the wrong spawn point.
	if(!alien_whitelist)
		return 0
	if(M && species)
		for (var/s in alien_whitelist)
			if(findtext(lowertext(s),"[lowertext(M.key)] - [species]"))
				return 1
			//if(findtext(lowertext(s),"[lowertext(M.key)] - [species] Elder")) //Unnecessary.
			//	return 1
			if(findtext(lowertext(s),"[lowertext(M.key)] - All"))
				return 1
	return 0

#undef WHITELISTFILE
