/datum/action/xeno_action/return_to_core
	name = "Return to Core"
	action_icon_state = "lay_hivemind"
	mechanics_text = "Teleport back to your core."

/datum/action/xeno_action/return_to_core/action_activate()
	SEND_SIGNAL(owner, COMSIG_XENOMORPH_CORE_RETURN)

/datum/action/xeno_action/activable/secrete_resin/ranged/slow
	base_wait = 1 SECONDS
	max_range = 4

/datum/action/xeno_action/change_form
	name = "Change form"
	action_icon_state = "manifest"
	mechanics_text = "Change from your incorporal form to your physical on and vice-versa."

/datum/action/xeno_action/change_form/action_activate()
	var/mob/living/carbon/xenomorph/xenomorph_owner = owner
	xenomorph_owner.change_form()
