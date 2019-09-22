// ***************************************
// *********** Bull charge types
// ***************************************

/datum/action/xeno_action/activable/bull_charge
	name = "Plow Charge"
	action_icon_state = "bull_charge"
	ability_name = "plow charge"
	keybind_signal = COMSIG_XENOABILITY_BULLCHARGE
	var/new_charge_type = CHARGE_BULL


/datum/action/xeno_action/activable/action_activate()
	var/mob/living/carbon/xenomorph/X = owner
	if(X.selected_ability == src)
		return
	if(X.selected_ability)
		X.selected_ability.deselect()
	select()


/datum/action/xeno_action/activable/bull_charge/on_activation()
	SEND_SIGNAL(owner, COMSIG_XENOACTION_TOGGLECHARGETYPE, new_charge_type)


/datum/action/xeno_action/activable/bull_charge/headbutt
	name = "Headbutt Charge"
	action_icon_state = "bull_headbutt"
	ability_name = "headbutt charge"
	keybind_signal = COMSIG_XENOABILITY_BULLHEADBUTT
	new_charge_type = CHARGE_BULL_HEADBUTT


/datum/action/xeno_action/activable/bull_charge/gore
	name = "Gore Charge"
	action_icon_state = "bull_gore"
	ability_name = "gore charge"
	keybind_signal = COMSIG_XENOABILITY_BULLGORE
	new_charge_type = CHARGE_BULL_GORE
