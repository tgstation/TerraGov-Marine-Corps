// ***************************************
// *********** Bull charge types
// ***************************************

/datum/action/ability/activable/xeno/bull_charge
	name = "Plow Charge"
	action_icon_state = "bull_charge"
	desc = "When you hit a host, knock them out of your way while continuing your charge undeterred. The force of your charge also disarms them."
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_BULLCHARGE,
	)
	var/new_charge_type = CHARGE_BULL


/datum/action/ability/activable/xeno/bull_charge/on_selection()
	SEND_SIGNAL(owner, COMSIG_XENOACTION_TOGGLECHARGETYPE, new_charge_type)


/datum/action/ability/activable/xeno/bull_charge/headbutt
	name = "Headbutt Charge"
	action_icon_state = "bull_headbutt"
	desc = "When you hit a host, stops your charge while headbutting them, flinging them in the air and stunning them for some time."
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_BULLHEADBUTT,
	)
	new_charge_type = CHARGE_BULL_HEADBUTT

/datum/action/ability/activable/xeno/bull_charge/gore
	name = "Gore Charge"
	action_icon_state = "bull_gore"
	desc = "When you hit a host, stops your charge while piercing them for a large amount of damage where you are targeting, in addition to injecting the Ozelomelyn toxin."
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_BULLGORE,
	)
	new_charge_type = CHARGE_BULL_GORE
