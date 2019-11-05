/datum/keybinding/human
	category = CATEGORY_HUMAN
	weight = WEIGHT_MOB

/datum/keybinding/human/New()
	. = ..()
	if(!keybind_signal)
		CRASH("Keybind [src] called unredefined down() without a keybind_signal.")

/datum/keybinding/human/down(client/user)
	return CHECK_BITFIELD(SEND_SIGNAL(user.mob, keybind_signal), COMSIG_KB_ACTIVATED)


/datum/keybinding/human/quick_equip
	key = "E"
	name = "quick_equip"
	full_name = "Quick equip"
	description = ""
	keybind_signal = COMSIG_KB_QUICKEQUIP


/datum/keybinding/human/holster
	key = "H"
	name = "holster"
	full_name = "Holster"
	description = ""
	keybind_signal = COMSIG_KB_HOLSTER


/datum/keybinding/human/unique_action
	key = "Space"
	name = "unique_action"
	full_name = "Perform unique action"
	description = ""
	keybind_signal = COMSIG_KB_UNIQUEACTION


/datum/keybinding/human/hold_run_move_intent
	key = "Alt"
	name = "hold_run_move_intent"
	full_name = "Hold to Run"
	description = "Held down to run, release to return to walking mode."
	keybind_signal = COMSIG_KB_HOLD_RUN_MOVE_INTENT_DOWN

/datum/keybinding/human/hold_run_move_intent/down(client/user)
	. = ..()
	if(.)
		return
	user.mob.toggle_move_intent(MOVE_INTENT_RUN)
	return TRUE

/datum/keybinding/human/hold_run_move_intent/up(client/user)
	if(SEND_SIGNAL(user.mob, COMSIG_KB_HOLD_RUN_MOVE_INTENT_UP) & COMSIG_KB_ACTIVATED)
		return TRUE
	user.mob.toggle_move_intent(MOVE_INTENT_WALK)
	return TRUE
