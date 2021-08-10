//Everything needed for the mirage ability

/mob/living/carbon/xenomorph/illusion
	density = FALSE
	status_flags = GODMODE
	wall_smash = FALSE
	tier = XENO_TIER_ZERO
	caste_base_type = /mob/living/carbon/xenomorph/illusion
	upgrade = XENO_UPGRADE_ZERO
	status_flags = GODMODE | INCORPOREAL
	///The parent xenomorph the illusion is a copy of
	var/mob/living/carbon/xenomorph/original_xeno

/mob/living/carbon/xenomorph/illusion/Initialize(mapload, mob/living/carbon/xenomorph/original_xeno, life_time)
	src.original_xeno = original_xeno
	. = ..()
	setXenoCasteSpeed(original_xeno.xeno_caste.speed * 1.3) //30% increase in speed so they can follow up
	appearance = original_xeno.appearance
	desc = original_xeno.desc
	name = original_xeno.name
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/carbon/xeno/illusion, original_xeno)
	RegisterSignal(original_xeno, list(COMSIG_PARENT_QDELETING, COMSIG_MOB_DEATH), .proc/destroy_illusion)
	QDEL_IN(src, life_time)

/mob/living/carbon/xenomorph/illusion/Destroy()
	original_xeno = null
	return ..()

///Delete this illusion when the original xeno is dead
/mob/living/carbon/xenomorph/illusion/proc/destroy_illusion()
	SIGNAL_HANDLER
	qdel(src)

/mob/living/carbon/xenomorph/illusion/update_icons()
	appearance = original_xeno.appearance

/mob/living/carbon/xenomorph/illusion/update_progression()
	return

/datum/xeno_caste/illusion
	caste_type_path = /mob/living/carbon/xenomorph/illusion

/datum/ai_behavior/carbon/xeno/illusion
	real_xeno = FALSE
	target_distance = 3 //We attack only near
	base_behavior = ESCORTING_ATOM
