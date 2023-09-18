// ***************************************
// *********** Scatterspit
// ***************************************

/datum/action/xeno_action/activable/scatter_spit/praetorian
	name = "Scatter Spit"
	action_icon_state = "scatter_spit"
	desc = "Spits a spread of acid projectiles that splatter on the ground."
	ability_name = "scatter spit"
	plasma_cost = 280
	cooldown_timer = 1 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_SCATTER_SPIT,
	)

/datum/action/xeno_action/activable/scatter_spit/on_cooldown_finish()
	to_chat(owner, span_xenodanger("Our auxiliary sacks fill to bursting; we can use scatter spit again."))
	owner.playsound_local(owner, 'sound/voice/alien_drool1.ogg', 25, 0, 1)
	return ..()
