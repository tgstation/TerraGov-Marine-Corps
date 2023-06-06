// ***************************************
// *********** Toggle Rolling
// ***************************************
/datum/action/xeno_action/toggle_rolling
	name = "Toggle Rolling"
	action_icon_state = "agility_on"
	desc = ""
	ability_name = "toggle rolling"
	cooldown_timer = 1 SECONDS
	use_state_flags = XACT_USE_ROLLING
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_TOGGLE_ROLLING,
	)

/datum/action/xeno_action/toggle_rolling/action_activate()
	var/mob/living/carbon/xenomorph/X = owner

	X.rolling = !X.rolling

	if(X.rolling)
		to_chat(X, span_xenowarning("We roll ourselves into a tight ball, ready to roll out"))
		X.add_movespeed_modifier(MOVESPEED_ID_BANELING_ROLLING , TRUE, 0, NONE, TRUE, X.xeno_caste.agility_speed_increase)
		owner.toggle_move_intent(MOVE_INTENT_RUN) //By default we swap to running when activating agility
	else
		to_chat(X, span_xenowarning("We raise ourselves to stand on two feet, hard scales setting back into place."))
		X.remove_movespeed_modifier(MOVESPEED_ID_BANELING_ROLLING)

	X.update_icons()
	add_cooldown()
	return succeed_activate()

// ***************************************
// *********** Baneling Explode
// ***************************************
/datum/action/xeno_action/baneling_explode
	name = "Baneling Explode"
	action_icon_state = "baneling_explode"
	desc = ""
	ability_name = "baneling explode"
	use_state_flags = XACT_USE_ROLLING
	keybinding_signals = list(
	KEYBINDING_NORMAL = COMSIG_XENOABILITY_BANELING_EXPLODE,
	)
