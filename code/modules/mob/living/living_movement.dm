/mob/living/proc/update_pull_movespeed()
	if(!pulling?.drag_delay)
		remove_movespeed_modifier(MOVESPEED_ID_BULKY_DRAGGING)
		return
	. = pulling.drag_delay
	if(ismob(pulling))
		var/mob/pulled_mob = pulling
		if(pulled_mob.buckled) //if the pulled mob is buckled to an object, we use that object's drag_delay.
			. = pulled_mob.buckled.drag_delay
	. += pull_speed
	if(. <= 0)
		remove_movespeed_modifier(MOVESPEED_ID_BULKY_DRAGGING)
		return
	add_movespeed_modifier(MOVESPEED_ID_BULKY_DRAGGING, TRUE, 0, NONE, TRUE, .)
