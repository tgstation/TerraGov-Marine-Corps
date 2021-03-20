/**
 * tgui state: dropship_state
 *
 * Checks that the user is next to the src object
 */

GLOBAL_DATUM_INIT(dropship_state, /datum/ui_state/dropship_state, new)

/datum/ui_state/dropship_state/can_use_topic(src_object, mob/user)
	return user.dropship_can_use_topic(src_object)

/mob/living/dropship_can_use_topic(src_object)
	. = shared_ui_interaction(src_object)
	if(. > UI_CLOSE && loc) //must not be in nullspace.
		. = min(., shared_living_ui_distance(src_object))

/mob/proc/dropship_can_use_topic(src_object)
	return UI_CLOSE
