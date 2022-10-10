// ***************************************
// *********** Bull charge types
// ***************************************

/datum/action/xeno_action/activable/bull_charge
	name = "Plow Charge"
	action_icon_state = "bull_charge"
	mechanics_text = "The plow charge is similar to the crusher charge, as it deals damage and throws anyone hit out of your way. Hitting a host does not stop or slow you down."
	ability_name = "plow charge"
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_BULLCHARGE,
	)
	var/new_charge_type = CHARGE_BULL


/datum/action/xeno_action/activable/bull_charge/on_activation()
	SEND_SIGNAL(owner, COMSIG_XENOACTION_TOGGLECHARGETYPE, new_charge_type)


/datum/action/xeno_action/activable/bull_charge/headbutt
	name = "Headbutt Charge"
	action_icon_state = "bull_headbutt"
	mechanics_text = "The headbutt charge, when it hits a host, stops your charge while knocking them down stunned for some time."
	ability_name = "headbutt charge"
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_BULLHEADBUTT,
	)
	new_charge_type = CHARGE_BULL_HEADBUTT

/datum/action/xeno_action/activable/bull_charge/gore
	name = "Gore Charge"
	action_icon_state = "bull_gore"
	mechanics_text = "The gore charge, when it hits a host, stops your charge while dealing a large amount of damage where you are targeting dependant on your charge speed."
	ability_name = "gore charge"
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_BULLGORE,
	)
	new_charge_type = CHARGE_BULL_GORE
