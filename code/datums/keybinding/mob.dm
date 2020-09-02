/datum/keybinding/mob
	category = CATEGORY_MOB
	weight = WEIGHT_MOB


/datum/keybinding/mob/face_north
	hotkey_keys = list("CtrlW", "CtrlNorth")
	classic_keys = list("CtrlNorth")
	name = "face_north"
	full_name = "Face North"
	description = ""
	keybind_signal = COMSIG_KB_MOB_FACENORTH_DOWN

/datum/keybinding/mob/face_north/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/M = user.mob
	M.northface()
	return TRUE


/datum/keybinding/mob/face_east
	hotkey_keys = list("CtrlD", "CtrlEast")
	classic_keys = list("CtrlEast")
	name = "face_east"
	full_name = "Face East"
	description = ""
	keybind_signal = COMSIG_KB_MOB_FACEEAST_DOWN

/datum/keybinding/mob/face_east/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/M = user.mob
	M.eastface()
	return TRUE


/datum/keybinding/mob/face_south
	hotkey_keys = list("CtrlS", "CtrlSouth")
	classic_keys = list("CtrlSouth")
	name = "face_south"
	full_name = "Face South"
	description = ""
	keybind_signal = COMSIG_KB_MOB_FACESOUTH_DOWN

/datum/keybinding/mob/face_south/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/M = user.mob
	M.southface()
	return TRUE

/datum/keybinding/mob/face_west
	hotkey_keys = list("CtrlA", "CtrlWest")
	classic_keys = list("CtrlWest")
	name = "face_west"
	full_name = "Face West"
	description = ""
	keybind_signal = COMSIG_KB_MOB_FACEWEST_DOWN

/datum/keybinding/mob/face_west/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/M = user.mob
	M.westface()
	return TRUE

/datum/keybinding/mob/stop_pulling
	hotkey_keys = list("Delete")
	name = "stop_pulling"
	full_name = "Stop pulling"
	description = ""
	keybind_signal = COMSIG_KB_MOB_STOPPULLING_DOWN

/datum/keybinding/mob/stop_pulling/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/M = user.mob
	if(M.pulling)
		M.stop_pulling()
	return TRUE

/datum/keybinding/mob/cycle_intent_right
	hotkey_keys = list("Northwest") // HOME
	name = "cycle_intent_right"
	full_name = "cycle_intent_right"
	description = ""
	keybind_signal = COMSIG_KB_MOB_CYCLEINTENTRIGHT_DOWN

/datum/keybinding/mob/cycle_intent_right/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/M = user.mob
	M.a_intent_change(INTENT_HOTKEY_RIGHT)
	return TRUE

/datum/keybinding/mob/cycle_intent_left
	hotkey_keys = list("Insert")
	name = "cycle_intent_left"
	full_name = "cycle_intent_left"
	description = ""
	keybind_signal = COMSIG_KB_MOB_CYCLEINTENTLEFT_DOWN

/datum/keybinding/mob/cycle_intent_left/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/M = user.mob
	M.a_intent_change(INTENT_HOTKEY_LEFT)
	return TRUE

/datum/keybinding/mob/swap_hands
	hotkey_keys = list("X")
	classic_keys = list("Northeast") // PAGEUP
	name = "swap_hands"
	full_name = "Swap hands"
	description = ""
	keybind_signal = COMSIG_KB_MOB_SWAPHANDS_DOWN

/datum/keybinding/mob/swap_hands/down(client/user)
	. = ..()
	if(.)
		return
	user.swap_hand()
	return TRUE

/datum/keybinding/mob/say
	name = "say"
	full_name = "Say"
	hotkey_keys = list("T")
	classic_keys = list("T")
	description = ""
	keybind_signal = COMSIG_KB_MOB_SAY_DOWN

/datum/keybinding/mob/say/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/M = user.mob
	M.say_wrapper()
	return TRUE

/datum/keybinding/mob/me
	name = "me"
	full_name = "Me"
	hotkey_keys = list("M")
	classic_keys = list("M")
	description = ""
	keybind_signal = COMSIG_KB_MOB_ME_DOWN

/datum/keybinding/mob/me/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/M = user.mob
	M.me_wrapper()
	return TRUE

/datum/keybinding/mob/activate_inhand
	hotkey_keys = list("Z")
	classic_keys = list("Southeast") // PAGEDOWN
	name = "activate_inhand"
	full_name = "Activate in-hand"
	description = "Uses whatever item you have inhand"
	keybind_signal = COMSIG_KB_MOB_ACTIVATEINHAND_DOWN

/datum/keybinding/mob/activate_inhand/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/M = user.mob
	M.mode()
	return TRUE

/datum/keybinding/mob/drop_item
	hotkey_keys = list("Q")
	name = "drop_item"
	full_name = "Drop Item"
	description = ""
	keybind_signal = COMSIG_KB_MOB_DROPITEM_DOWN

/datum/keybinding/mob/drop_item/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/M = user.mob
	var/obj/item/I = M.get_active_held_item()
	if(!I)
		to_chat(user, "<span class='warning'>You have nothing to drop in your hand!</span>")
	else
		user.mob.dropItemToGround(I)
	return TRUE


/datum/keybinding/mob/examine
	hotkey_keys = list("Shift")
	name = "examine_kb"
	full_name = "Examine"
	description = "Hold this hotkey_keys and click to examine things."
	keybind_signal = COMSIG_KB_MOB_EXAMINE_DOWN


/datum/keybinding/mob/examine/down(client/user)
	. = ..()
	if(.)
		return
	RegisterSignal(user.mob, list(COMSIG_MOB_CLICKON, COMSIG_OBSERVER_CLICKON), .proc/examinate)
	RegisterSignal(user.mob, list(COMSIG_MOB_MOUSEDOWN, COMSIG_MOB_MOUSEUP), .keybinding/proc/intercept_mouse_special)
	return TRUE


/datum/keybinding/mob/examine/up(client/user)
	UnregisterSignal(user.mob, list(COMSIG_MOB_MOUSEDOWN, COMSIG_MOB_MOUSEUP, COMSIG_MOB_CLICKON, COMSIG_OBSERVER_CLICKON))
	return TRUE


/datum/keybinding/mob/examine/proc/examinate(datum/source, atom/A, params)
	var/mob/user = source
	if(!user.client || !(user.client.eye == user || user.client.eye == user.loc))
		UnregisterSignal(user, list(COMSIG_MOB_CLICKON, COMSIG_OBSERVER_CLICKON))
		return
	user.examinate(A)
	return COMSIG_MOB_CLICK_HANDLED

/datum/keybinding/mob/toggle_move_intent
	hotkey_keys = list("5")
	name = "toggle_move_intent"
	full_name = "Toggle move intent"
	description = "Cycle to the other move intent."
	keybind_signal = COMSIG_KB_MOB_TOGGLEMOVEINTENT_DOWN

/datum/keybinding/mob/toggle_move_intent/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/M = user.mob
	M.toggle_move_intent()
	return TRUE

/datum/keybinding/mob/target_head_cycle
	hotkey_keys = list("Numpad8")
	name = "target_head_cycle"
	full_name = "Target: Cycle head"
	description = ""
	keybind_signal = COMSIG_KB_MOB_TARGETCYCLEHEAD_DOWN

/datum/keybinding/mob/target_head_cycle/down(client/user)
	. = ..()
	if(.)
		return
	user.body_toggle_head()
	return TRUE

/datum/keybinding/mob/target_r_arm
	hotkey_keys = list("Numpad4")
	name = "target_r_arm"
	full_name = "Target: right arm"
	description = ""
	keybind_signal = COMSIG_KB_MOB_TARGETRIGHTARM_DOWN

/datum/keybinding/mob/target_r_arm/down(client/user)
	. = ..()
	if(.)
		return
	user.body_r_arm()
	return TRUE

/datum/keybinding/mob/target_body_chest
	hotkey_keys = list("Numpad5")
	name = "target_body_chest"
	full_name = "Target: Body"
	description = ""
	keybind_signal = COMSIG_KB_MOB_TARGETBODYCHEST_DOWN

/datum/keybinding/mob/target_body_chest/down(client/user)
	. = ..()
	if(.)
		return
	user.body_chest()
	return TRUE

/datum/keybinding/mob/target_left_arm
	hotkey_keys = list("Numpad6")
	name = "target_left_arm"
	full_name = "Target: left arm"
	description = ""
	keybind_signal = COMSIG_KB_MOB_TARGETLEFTARM_DOWN

/datum/keybinding/mob/target_left_arm/down(client/user)
	. = ..()
	if(.)
		return
	user.body_l_arm()
	return TRUE

/datum/keybinding/mob/target_right_leg
	hotkey_keys = list("Numpad1")
	name = "target_right_leg"
	full_name = "Target: Right leg"
	description = ""
	keybind_signal = COMSIG_KB_MOB_TARGETRIGHTLEG_DOWN

/datum/keybinding/mob/target_right_leg/down(client/user)
	. = ..()
	if(.)
		return
	user.body_r_leg()
	return TRUE

/datum/keybinding/mob/target_body_groin
	hotkey_keys = list("Numpad2")
	name = "target_body_groin"
	full_name = "Target: Groin"
	description = ""
	keybind_signal = COMSIG_KB_MOB_TARGETBODYGROIN_DOWN

/datum/keybinding/mob/target_body_groin/down(client/user)
	. = ..()
	if(.)
		return
	user.body_groin()
	return TRUE

/datum/keybinding/mob/target_left_leg
	hotkey_keys = list("Numpad3")
	name = "target_left_leg"
	full_name = "Target: left leg"
	description = ""
	keybind_signal = COMSIG_KB_MOB_TARGETLEFTLEG_DOWN

/datum/keybinding/mob/target_left_leg/down(client/user)
	. = ..()
	if(.)
		return
	user.body_l_leg()
	return TRUE
