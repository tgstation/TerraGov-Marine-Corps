/mob/living/carbon/xenomorph/warrior/start_pulling(atom/movable/AM, force = move_force, suppress_message = TRUE, lunge = FALSE)
	. = ..()
	if(agility)
		balloon_alert(src, "Cannot in agility mode")
