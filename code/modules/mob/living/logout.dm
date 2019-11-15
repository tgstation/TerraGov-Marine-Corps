/mob/living/Logout()
	..()
	if (mind)
		if(!key)	//key and mind have become seperated.
			mind.active = 0	//This is to stop say, a mind.transfer_to call on a corpse causing a ghost to re-enter its body.
		if(!immune_to_ssd && mind.active)
			Sleeping(40)	//This causes instant sleep, but does not prolong it. See life.dm for furthering SSD.
