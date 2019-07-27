/mob/living/carbon/xenomorph/defender/ai
	ai_datum = new/datum/ai_behavior/xeno/defender

/mob/living/carbon/xenomorph/defender/ai/Initialize()
	..()
	ai_datum.parentmob = src
	ai_datum.Init()

/datum/ai_behavior/xeno/defender
	var/datum/action/xeno_action/activable/forward_charge/charge = new
	var/datum/action/xeno_action/activable/tail_sweep/sweep = new

/datum/ai_behavior/xeno/defender/Init()
	..()
	var/mob/living/carbon/xenomorph/defender/parentmob2 = parentmob
	charge.owner = parentmob
	sweep.owner = parentmob
	parentmob2.set_crest_defense(TRUE)

/datum/ai_behavior/xeno/defender/HandleAbility()
	. = ..()
	if(!.)
		return FALSE

	if(istype(action_state, /datum/action_state/hunt_and_destroy))
		var/datum/action_state/hunt_and_destroy/action_state2 = action_state

		if(get_dist(parentmob, action_state2.atomtowalkto) <= 1)
			if(sweep.can_use_ability(action_state2.atomtowalkto, FALSE, XACT_IGNORE_SELECTED_ABILITY))
				sweep.use_ability()
