/datum/action/xeno_action/activable/corrosive_acid/drone
	name = "Corrosive Acid"
	plasma_cost = 75
	acid_type = /obj/effect/xenomorph/acid/weak

/datum/action/xeno_action/activable/salvage_plasma
	name = "Salvage Plasma"
	action_icon_state = "salvage_plasma"
	ability_name = "salvage plasma"
	var/plasma_salvage_amount = PLASMA_SALVAGE_AMOUNT
	var/salvage_delay = 5 SECONDS
	var/max_range = 1
	keybind_signal = COMSIG_XENOABILITY_SALVAGE_PLASMA

/datum/action/xeno_action/activable/salvage_plasma/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/X = owner
	if(owner.action_busy)
		return
	X.xeno_salvage_plasma(A, plasma_salvage_amount, salvage_delay, max_range)
