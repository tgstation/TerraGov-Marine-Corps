/datum/keybinding/mob
	category = CATEGORY_HUMAN
	weight = WEIGHT_MOB


/datum/keybinding/mob/face_north
	hotkey_keys = list("CtrlW", "CtrlNorth")
	classic_keys = list("CtrlNorth")
	name = "face_north"
	full_name = "Face North"
	description = ""

/datum/keybinding/mob/face_north/down(client/user)
	var/mob/M = user.mob
	M.northface()
	return TRUE


/datum/keybinding/mob/face_east
	hotkey_keys = list("CtrlD", "CtrlEast")
	classic_keys = list("CtrlEast")
	name = "face_east"
	full_name = "Face East"
	description = ""

/datum/keybinding/mob/face_east/down(client/user)
	var/mob/M = user.mob
	M.eastface()
	return TRUE


/datum/keybinding/mob/face_south
	hotkey_keys = list("CtrlS", "CtrlSouth")
	classic_keys = list("CtrlSouth")
	name = "face_south"
	full_name = "Face South"
	description = ""

/datum/keybinding/mob/face_south/down(client/user)
	var/mob/M = user.mob
	M.southface()
	return TRUE

/datum/keybinding/mob/face_west
	hotkey_keys = list("CtrlA", "CtrlWest")
	classic_keys = list("CtrlWest")
	name = "face_west"
	full_name = "Face West"
	description = ""

/datum/keybinding/mob/face_west/down(client/user)
	var/mob/M = user.mob
	M.westface()
	return TRUE
/*
/datum/keybinding/mob/stop_pulling
	hotkey_keys = list("Z")
	classic_keys = list("Z")
	name = "stop_pulling"
	full_name = "Stop pulling"
	description = ""

/datum/keybinding/mob/stop_pulling/down(client/user)
	var/mob/M = user.mob
	if(!M.pulling)
		to_chat(user, "<span class='notice'>I are not pulling anything.</span>")
	else
		M.stop_pulling()
	return TRUE
*/
/*
/datum/keybinding/mob/toggle_move_intent
	hotkey_keys = list("Alt")
	name = "toggle_move_intent"
	full_name = "Hold to toggle move intent"
	description = "Held down to cycle to the other move intent, release to cycle back"

/datum/keybinding/mob/toggle_move_intent/down(client/user)
	var/mob/M = user.mob
	M.toggle_move_intent()
	return TRUE

/datum/keybinding/mob/toggle_move_intent/up(client/user)
	var/mob/M = user.mob
	M.toggle_move_intent()
	return TRUE

/datum/keybinding/mob/toggle_move_intent_alternative
	hotkey_keys = list("Unbound")
	name = "toggle_move_intent_alt"
	full_name = "press to cycle move intent"
	description = "Pressing this cycle to the opposite move intent, does not cycle back"

/datum/keybinding/mob/toggle_move_intent_alternative/down(client/user)
	var/mob/M = user.mob
	M.toggle_move_intent()
	return TRUE

/datum/keybinding/mob/target_head_cycle
	hotkey_keys = list("Numpad8")
	name = "target_head_cycle"
	full_name = "Target: Cycle head"
	description = ""

/datum/keybinding/mob/target_head_cycle/down(client/user)
	user.body_toggle_head()
	return TRUE

/datum/keybinding/mob/target_r_arm
	hotkey_keys = list("Numpad4")
	name = "target_r_arm"
	full_name = "Target: right arm"
	description = ""

/datum/keybinding/mob/target_r_arm/down(client/user)
	user.body_r_arm()
	return TRUE

/datum/keybinding/mob/target_body_chest
	hotkey_keys = list("Numpad5")
	name = "target_body_chest"
	full_name = "Target: Body"
	description = ""

/datum/keybinding/mob/target_body_chest/down(client/user)
	user.body_chest()
	return TRUE

/datum/keybinding/mob/target_left_arm
	hotkey_keys = list("Numpad6")
	name = "target_left_arm"
	full_name = "Target: left arm"
	description = ""

/datum/keybinding/mob/target_left_arm/down(client/user)
	user.body_l_arm()
	return TRUE

/datum/keybinding/mob/target_right_leg
	hotkey_keys = list("Numpad1")
	name = "target_right_leg"
	full_name = "Target: Right leg"
	description = ""

/datum/keybinding/mob/target_right_leg/down(client/user)
	user.body_r_leg()
	return TRUE

/datum/keybinding/mob/target_body_groin
	hotkey_keys = list("Numpad2")
	name = "target_body_groin"
	full_name = "Target: Groin"
	description = ""

/datum/keybinding/mob/target_body_groin/down(client/user)
	user.body_groin()
	return TRUE

/datum/keybinding/mob/target_left_leg
	hotkey_keys = list("Numpad3")
	name = "target_left_leg"
	full_name = "Target: left leg"
	description = ""

/datum/keybinding/mob/target_left_leg/down(client/user)
	user.body_l_leg()
	return TRUE
*/