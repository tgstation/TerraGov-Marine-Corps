

/mob/living/carbon/proc/handle_grabbed()
	if(pulledby.grab_level >= GRAB_AGGRESSIVE)
		drop_held_items()

	/*if(pulledby.grab_level >= GRAB_NECK)
		Stun(5)
		adjustOxyLoss(1)*/

	if(pulledby.grab_level >= GRAB_KILL)
		KnockDown(5)
		losebreath = min(losebreath + 2, 3)
