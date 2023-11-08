// ***************************************
// *********** Set Hugger Reserve
// ***************************************
// Set hugger reserve
/datum/action/xeno_action/set_hugger_reserve
	name = "Set Hugger Reserve"
	action_icon_state = "hugger_set"
	desc = "Set the number of huggers you want to preserve from the observers' possession."
	use_state_flags = XACT_USE_LYING

/datum/action/xeno_action/set_hugger_reserve/give_action(mob/living/L)
	. = ..()
	var/mob/living/carbon/xenomorph/carrier/caster = owner
	caster.huggers_reserved = caster.xeno_caste.huggers_max

/datum/action/xeno_action/set_hugger_reserve/action_activate()
	var/mob/living/carbon/xenomorph/carrier/caster = owner
	var/number = tgui_input_number(usr, "How many facehuggers would you like to keep safe from Observers wanting to join as facehuggers?", "How many to reserve?", caster.huggers_reserved, caster.xeno_caste.huggers_max)
	if(!isnull(number))
		caster.huggers_reserved = number
	to_chat(caster, span_notice("You reserved [caster.huggers_reserved] facehuggers for yourself."))
	caster.balloon_alert(caster, "Reserved [caster.huggers_reserved] facehuggers")

	return succeed_activate()

/datum/action/xeno_action/place_trap
	desc = "Place a hole on weeds that can be filled with a hugger, liquid acid, acid or neurotoxin gas. Activates when a marine steps on it."
	action_icon_state = "small_trap"
	plasma_cost = 200

/datum/action/xeno_action/spawn_hugger
	plasma_cost = 100
