/proc/get_mob_faction_alignment(mob/M)
	if(!M)
		return
	var/faction = M.faction
	. = GLOB.faction_to_alignement[faction]
	if(isnull(.))
		WARNING("cant find mob faction hostility, ensure its added to faction_to_alignement list")
