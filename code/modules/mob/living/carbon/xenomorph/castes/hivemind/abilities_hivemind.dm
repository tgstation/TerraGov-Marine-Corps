/datum/action/xeno_action/return_to_core
	name = "Return to Core"
	action_icon_state = "lay_hivemind"
	mechanics_text = "Teleport back to your core."

/datum/action/xeno_action/return_to_core/action_activate()
	SEND_SIGNAL(owner, COMSIG_XENOMORPH_CORE_RETURN)

/datum/action/xeno_action/activable/mirage
	name = "Mirage"
	action_icon_state = ""
	mechanics_text = "Create mirror images of the targeted xeno."

/datum/action/xeno_action/activable/mirage/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(!isxeno(A) || !owner.issamexenohive(A))
		return FALSE
	return TRUE

/datum/action/xeno_action/activable/mirage/use_ability(atom/A)
	new /mob/living/carbon/xenomorph/illusion(A.loc, A)

/mob/living/carbon/xenomorph/illusion
	density = FALSE
	status_flags = GODMODE
	wall_smash = FALSE
	tier = XENO_TIER_ZERO
	caste_base_type = /mob/living/carbon/xenomorph/illusion
	upgrade = XENO_UPGRADE_ZERO
	///The parent xenomorph the illusion is a copy of
	var/mob/living/carbon/xenomorph/original_xeno

/mob/living/carbon/xenomorph/illusion/Initialize(mapload, mob/living/carbon/xenomorph/original_xeno)
	. = ..()
	src.original_xeno = original_xeno
	appearance = original_xeno.appearance
	desc = original_xeno.desc
	name = original_xeno.name
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/carbon/xeno/illusion)
	a_intent = INTENT_HARM

/datum/xeno_caste/illusion
	caste_type_path = /mob/living/carbon/xenomorph/illusion
