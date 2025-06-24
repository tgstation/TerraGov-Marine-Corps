/**
 * tgui state: access_state
 *
 * Humans need to have access and be adjacent to use it.
 * Silicons and other lifeforms get their default ui_state pass.
 * Xenomorphs need to be intelligent & hive lead
 */

GLOBAL_DATUM_INIT(alamo_state, /datum/ui_state/alamo_state, new)

/datum/ui_state/alamo_state/can_use_topic(src_object, mob/user)
	return user.alamo_can_use_topic(src_object)

/mob/proc/alamo_can_use_topic(src_object)
	return default_can_use_topic(src_object)

/mob/living/alamo_can_use_topic(src_object)
	. = human_adjacent_can_use_topic(src_object)

	var/obj/O = src_object
	if(!O?.allowed(src)) //No access? No ui!
		to_chat(src, span_warning("Access Denied!"))
		return UI_CLOSE
	. = min(., UI_INTERACTIVE)

/mob/living/silicon/alamo_can_use_topic(src_object)
	return default_can_use_topic(src_object)

/mob/living/carbon/xenomorph/alamo_can_use_topic(src_object)
	var/datum/game_mode/infestation/infestation_mode = SSticker.mode
	if(infestation_mode.round_stage == INFESTATION_MARINE_CRASHING) //Minor QOL, any xeno can check the console after the hive lead hijacks
		return GLOB.xeno_state.can_use_topic(src_object, src)
	if(!(xeno_caste.caste_flags & CASTE_IS_INTELLIGENT))
		return default_can_use_topic(src_object)
	if(hive.living_xeno_ruler != src)
		return default_can_use_topic(src_object)
	return GLOB.xeno_state.can_use_topic(src_object, src)
