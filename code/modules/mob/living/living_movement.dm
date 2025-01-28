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

/mob/living/set_submerge_level(turf/new_loc, turf/old_loc, submerge_icon = 'icons/turf/alpha_64.dmi', submerge_icon_state = "liquid_alpha", duration = cached_multiplicative_slowdown + next_move_slowdown)
	return ..()

/mob/living/keybind_face_direction(direction)
	if(stat > CONSCIOUS)
		return
	facedir(direction)
