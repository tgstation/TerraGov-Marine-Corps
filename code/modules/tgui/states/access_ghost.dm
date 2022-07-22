/**
 * tgui state: access_ghost_state
 *
 * Humans need to have access and be adjacent to use it.
 * Silicons and other lifeforms get their default ui_state pass.
 * Observers can also interact with the UI (MAKE SURE YOU SANATIZE OBSERVER INPUT IN UI_ACT)
 */

GLOBAL_DATUM_INIT(access_ghost_state, /datum/ui_state/access_ghost_state, new)

/datum/ui_state/access_ghost_state/can_use_topic(src_object, mob/user)
	return user.access_ghost_can_use_topic(src_object)

/mob/proc/access_ghost_can_use_topic(src_object)
	return default_can_use_topic(src_object)

/mob/living/access_ghost_can_use_topic(src_object)
	. = human_adjacent_can_use_topic(src_object)

	var/obj/O = src_object
	if(!O?.allowed(src)) //No access? No ui!
		to_chat(src, span_warning("Access Denied!"))
		return UI_CLOSE
	. = min(., UI_INTERACTIVE)

/mob/living/silicon/access_ghost_can_use_topic(src_object)
	return default_can_use_topic(src_object)

/mob/dead/observer/access_ghost_can_use_topic(src_object)
	return UI_INTERACTIVE
