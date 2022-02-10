/**
 * tgui state: access_state
 *
 * Humans need to have access and be adjacent to use it.
 * Silicons and other lifeforms get their default ui_state pass.
 */

GLOBAL_DATUM_INIT(access_state, /datum/ui_state/access_state, new)

/datum/ui_state/access_state/can_use_topic(src_object, mob/user)
	return user.access_can_use_topic(src_object)

/mob/proc/access_can_use_topic(src_object)
	return default_can_use_topic(src_object)

/mob/living/access_can_use_topic(src_object)
	. = human_adjacent_can_use_topic(src_object)

	var/obj/O = src_object
	if(!O?.allowed(src)) //No access? No ui!
		to_chat(src, span_warning("Access Denied!"))
		return UI_CLOSE
	. = min(., UI_INTERACTIVE)

/mob/living/silicon/access_can_use_topic(src_object)
	return default_can_use_topic(src_object)
