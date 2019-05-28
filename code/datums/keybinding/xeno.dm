/datum/keybinding/xeno
	category = CATEGORY_XENO
	weight = WEIGHT_MOB
	var/ability_signal

/datum/keybinding/xeno/down(client/user)
	if(SEND_SIGNAL(user.mob, ability_signal) & COMSIG_XENOABILITY_HAS_ABILITY)
		return TRUE

	if(!isxeno(user.mob))
		return

	to_chat(user, "<span class='notice'>You don't have this ability.</span>") // TODO Is this spammy?
	return TRUE

/datum/keybinding/xeno/regurgitate
	//key = "V"
	name = "regurgitate"
	full_name = "Regurgitate"
	description = "Vomit whatever you have devoured."
	ability_signal = COMSIG_XENOABILITY_REGURGITATE

/datum/keybinding/xeno/drop_weeds
	key = "V"
	name = "drop_weeds"
	full_name = "Drop Weed"
	description = "Drop weeds to help grow your hive."
	ability_signal = COMSIG_XENOABILITY_DROP_WEEDS

/datum/keybinding/xeno/choose_resin
	//key = "V"
	name = "choose_resin"
	full_name = "Choose Resin Structure"
	description = "Selects which structure you will build with the (secrete resin) ability."
	ability_signal = COMSIG_XENOABILITY_CHOOSE_RESIN

/datum/keybinding/xeno/secrete_resin
	//key = "V"
	name = "secrete_resin"
	full_name = "Secrete Resin"
	description = "Builds whatever you’ve selected with (choose resin structure) on your tile."
	ability_signal = COMSIG_XENOABILITY_SECRETE_RESIN

/datum/keybinding/xeno/emit_recovery
	//key = "V"
	name = "emit_recovery"
	full_name = "Emit Recovery Pheromones"
	description = "Increases healing for yourself and nearby teammates."
	ability_signal = COMSIG_XENOABILITY_EMIT_RECOVERY

/datum/keybinding/xeno/emit_warding
	//key = "V"
	name = "emit_warding"
	full_name = "Emit Warding Pheromones"
	description = "Increases armor for yourself and nearby teammates."
	ability_signal = COMSIG_XENOABILITY_EMIT_WARDING

/datum/keybinding/xeno/emit_frenzy
	//key = "V"
	name = "emit_frenzy"
	full_name = "Emit Frenzy Pheromones"
	description = "Increases damage for yourself and nearby teammates."
	ability_signal = COMSIG_XENOABILITY_EMIT_FRENZY

/datum/keybinding/xeno/transfer_plasma
	//key = "V"
	name = "transfer_plasma"
	full_name = "Transfer Plasma"
	description = "Give some of your plasma to a teammate."
	ability_signal = COMSIG_XENOABILITY_TRANSFER_PLASMA


/datum/keybinding/xeno/tail_sweep
	//key = "V"
	name = "tail_sweep"
	full_name = "Tail Sweep"
	description = "Hit all adjacent units around you, knocking them away and down."
	ability_signal = COMSIG_XENOABILITY_TAIL_SWEEP




