/mob/living/Logout()
	..()
	if (mind)
		if(!key)	//key and mind have become seperated.
			mind.active = 0	//This is to stop say, a mind.transfer_to call on a corpse causing a ghost to re-enter its body.
		if(!immune_to_ssd && mind.active)
			Sleeping(40)	//This causes instant sleep, but does not prolong it. See life.dm for furthering SSD.
	var/datum/action/toggle_rightclick/rclick = actions_by_path[/datum/action/toggle_rightclick]
	rclick.remove_action(src)
	if(!key)
		set_afk_status(MOB_DISCONNECTED)
	else if(!isclientedaghost(src))
		set_afk_status(MOB_RECENTLY_DISCONNECTED, AFK_TIMER)
	if(!QDELETED(src))
		LAZYDISTINCTADD(GLOB.ssd_living_mobs, src)
