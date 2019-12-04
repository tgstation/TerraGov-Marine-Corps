/mob/living/carbon/proc/handle_grabbed()
	if(pulledby.grab_level >= GRAB_AGGRESSIVE)
		drop_all_held_items()

	if(pulledby.grab_level >= GRAB_KILL)
		Knockdown(10 SECONDS)
		Losebreath(3)
