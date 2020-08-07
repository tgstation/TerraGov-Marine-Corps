/mob/living/carbon/xenomorph/Logout()
	. = ..()
	if(!key)
		set_afk_status(MOB_DISCONNECTED)
	else if(!isclientedaghost(src))
		set_afk_status(MOB_RECENTLY_DISCONNECTED, XENO_AFK_TIMER)
	if(hive) //This can happen after the mob is destroyed.
		hive.on_xeno_logout(src)
	if(!isnum(nicknumber) && (stat != DEAD))//Reroll the number if a xeno ghosts
		var/tempnumber = rand(1, 999)
		var/list/xenolist = hive.get_all_xenos(FALSE)
		while(tempnumber in xenolist)
			tempnumber = rand(1, 999)
		nicknumber = tempnumber
		generate_name()
