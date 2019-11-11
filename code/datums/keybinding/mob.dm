/datum/keybinding/mob
	category = CATEGORY_MOB
	weight = WEIGHT_MOB


/datum/keybinding/mob/face_north
	key = "Ctrl-W"
	classic_key = "Ctrl-North"
	name = "face_north"
	full_name = "Face North"
	description = ""
	keybind_signal = COMSIG_KB_MOB_FACENORTH_DOWN

/datum/keybinding/mob/face_north/down(client/user)
	. = ..()
	if(!.)
		return
	var/mob/M = user.mob
	M.northface()
	return TRUE


/datum/keybinding/mob/face_east
	key = "Ctrl-D"
	classic_key = "Ctrl-East"
	name = "face_east"
	full_name = "Face East"
	description = ""
	keybind_signal = COMSIG_KB_MOB_FACEEAST_DOWN

/datum/keybinding/mob/face_east/down(client/user)
	. = ..()
	if(!.)
		return
	var/mob/M = user.mob
	M.eastface()
	return TRUE


/datum/keybinding/mob/face_south
	key = "Ctrl-S"
	classic_key = "Ctrl-South"
	name = "face_south"
	full_name = "Face South"
	description = ""
	keybind_signal = COMSIG_KB_MOB_FACESOUTH_DOWN

/datum/keybinding/mob/face_south/down(client/user)
	. = ..()
	if(!.)
		return
	var/mob/M = user.mob
	M.southface()
	return TRUE

/datum/keybinding/mob/face_west
	key = "Ctrl-A"
	classic_key = "Ctrl-West"
	name = "face_west"
	full_name = "Face West"
	description = ""
	keybind_signal = COMSIG_KB_MOB_FACEWEST_DOWN

/datum/keybinding/mob/face_west/down(client/user)
	. = ..()
	if(!.)
		return
	var/mob/M = user.mob
	M.westface()
	return TRUE

/datum/keybinding/mob/stop_pulling
	key = "Delete"
	name = "stop_pulling"
	full_name = "Stop pulling"
	description = ""
	keybind_signal = COMSIG_KB_MOB_STOPPULLING_DOWN

/datum/keybinding/mob/stop_pulling/down(client/user)
	. = ..()
	if(!.)
		return
	var/mob/M = user.mob
	if(M.pulling)
		M.stop_pulling()
	return TRUE

/datum/keybinding/mob/cycle_intent_right
	key = "Home"
	name = "cycle_intent_right"
	full_name = "cycle_intent_right"
	description = ""
	keybind_signal = COMSIG_KB_MOB_CYCLEINTENTRIGHT_DOWN

/datum/keybinding/mob/cycle_intent_right/down(client/user)
	. = ..()
	if(!.)
		return
	var/mob/M = user.mob
	M.a_intent_change(INTENT_HOTKEY_RIGHT)
	return TRUE

/datum/keybinding/mob/cycle_intent_left
	key = "Insert"
	name = "cycle_intent_left"
	full_name = "cycle_intent_left"
	description = ""
	keybind_signal = COMSIG_KB_MOB_CYCLEINTENTLEFT_DOWN

/datum/keybinding/mob/cycle_intent_left/down(client/user)
	. = ..()
	if(!.)
		return
	var/mob/M = user.mob
	M.a_intent_change(INTENT_HOTKEY_LEFT)
	return TRUE

/datum/keybinding/mob/swap_hands
	key = "X"
	name = "swap_hands"
	full_name = "Swap hands"
	description = ""
	keybind_signal = COMSIG_KB_MOB_SWAPHANDS_DOWN

/datum/keybinding/mob/swap_hands/down(client/user)
	. = ..()
	if(!.)
		return
	user.swap_hand()
	return TRUE

/datum/keybinding/mob/say
	key = "Unbound"
	name = "say"
	full_name = "Say (Currently disabled)"
	description = ""
	keybind_signal = COMSIG_KB_MOB_SAY_DOWN

/datum/keybinding/mob/say/down(client/user)
	. = ..()
	if(!.)
		return
	var/mob/M = user.mob
	M.say_wrapper()
	return TRUE

/datum/keybinding/mob/me
	key = "Unbound"
	name = "me"
	full_name = "Me (Currently disabled)"
	description = ""
	keybind_signal = COMSIG_KB_MOB_ME_DOWN

/datum/keybinding/mob/me/down(client/user)
	. = ..()
	if(!.)
		return
	var/mob/M = user.mob
	M.me_wrapper()
	return TRUE

/datum/keybinding/mob/activate_inhand
	key = "Z"
	classic_key = "PAGEDOWN"
	name = "activate_inhand"
	full_name = "Activate in-hand"
	description = "Uses whatever item you have inhand"
	keybind_signal = COMSIG_KB_MOB_ACTIVATEINHAND_DOWN

/datum/keybinding/mob/activate_inhand/down(client/user)
	. = ..()
	if(!.)
		return
	var/mob/M = user.mob
	M.mode()
	return TRUE

/datum/keybinding/mob/drop_item
	key = "Q"
	name = "drop_item"
	full_name = "Drop Item"
	description = ""
	keybind_signal = COMSIG_KB_MOB_DROPITEM_DOWN

/datum/keybinding/mob/drop_item/down(client/user)
	. = ..()
	if(!.)
		return
	var/mob/M = user.mob
	var/obj/item/I = M.get_active_held_item()
	if(!I)
		to_chat(user, "<span class='warning'>You have nothing to drop in your hand!</span>")
	else
		user.mob.dropItemToGround(I)
	return TRUE


/datum/keybinding/mob/examine
	key = "Shift"
	name = "examine_kb"
	full_name = "Examine"
	description = "Hold this key and click to examine things."
	keybind_signal = COMSIG_KB_MOB_EXAMINE_DOWN


/datum/keybinding/mob/examine/down(client/user)
	. = ..()
	if(!.)
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
	key = "5"
	name = "toggle_move_intent"
	full_name = "Toggle move intent"
	description = "Cycle to the other move intent."
	keybind_signal = COMSIG_KB_MOB_TOGGLEMOVEINTENT_DOWN

/datum/keybinding/mob/toggle_move_intent/down(client/user)
	. = ..()
	if(!.)
		return
	var/mob/M = user.mob
	M.toggle_move_intent()
	return TRUE

/datum/keybinding/mob/target_head_cycle
	key = "Numpad8"
	name = "target_head_cycle"
	full_name = "Target: Cycle head"
	description = ""
	keybind_signal = COMSIG_KB_MOB_TARGETCYCLEHEAD_DOWN

/datum/keybinding/mob/target_head_cycle/down(client/user)
	. = ..()
	if(!.)
		return
	user.body_toggle_head()
	return TRUE

/datum/keybinding/mob/target_r_arm
	key = "Numpad4"
	name = "target_r_arm"
	full_name = "Target: right arm"
	description = ""
	keybind_signal = COMSIG_KB_MOB_TARGETRIGHTARM_DOWN

/datum/keybinding/mob/target_r_arm/down(client/user)
	. = ..()
	if(!.)
		return
	user.body_r_arm()
	return TRUE

/datum/keybinding/mob/target_body_chest
	key = "Numpad5"
	name = "target_body_chest"
	full_name = "Target: Body"
	description = ""
	keybind_signal = COMSIG_KB_MOB_TARGETBODYCHEST_DOWN

/datum/keybinding/mob/target_body_chest/down(client/user)
	. = ..()
	if(!.)
		return
	user.body_chest()
	return TRUE

/datum/keybinding/mob/target_left_arm
	key = "Numpad6"
	name = "target_left_arm"
	full_name = "Target: left arm"
	description = ""
	keybind_signal = COMSIG_KB_MOB_TARGETLEFTARM_DOWN

/datum/keybinding/mob/target_left_arm/down(client/user)
	. = ..()
	if(!.)
		return
	user.body_l_arm()
	return TRUE

/datum/keybinding/mob/target_right_leg
	key = "Numpad1"
	name = "target_right_leg"
	full_name = "Target: Right leg"
	description = ""
	keybind_signal = COMSIG_KB_MOB_TARGETRIGHTLEG_DOWN

/datum/keybinding/mob/target_right_leg/down(client/user)
	. = ..()
	if(!.)
		return
	user.body_r_leg()
	return TRUE

/datum/keybinding/mob/target_body_groin
	key = "Numpad2"
	name = "target_body_groin"
	full_name = "Target: Groin"
	description = ""
	keybind_signal = COMSIG_KB_MOB_TARGETBODYGROIN_DOWN

/datum/keybinding/mob/target_body_groin/down(client/user)
	. = ..()
	if(!.)
		return
	user.body_groin()
	return TRUE

/datum/keybinding/mob/target_left_leg
	key = "Numpad3"
	name = "target_left_leg"
	full_name = "Target: left leg"
	description = ""
	keybind_signal = COMSIG_KB_MOB_TARGETLEFTLEG_DOWN

/datum/keybinding/mob/target_left_leg/down(client/user)
	. = ..()
	if(!.)
		return
	user.body_l_leg()
	return TRUE
