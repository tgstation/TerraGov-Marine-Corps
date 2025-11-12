/datum/keybinding/mob
	category = CATEGORY_MOB
	weight = WEIGHT_MOB

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

/*/datum/keybinding/mob/say
	name = "say"
	full_name = "Say"
	hotkey_keys = list("T")
	description = ""
	keybind_signal = COMSIG_KB_MOB_SAY_DOWN

/datum/keybinding/mob/say/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/M = user.mob
	M.say_wrapper()
	return TRUE*/

/datum/keybinding/mob/activate_inhand
	hotkey_keys = list("Z")
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
		to_chat(user, span_warning("You have nothing to drop in your hand!"))
	else
		user.mob.dropItemToGround(I)
	return TRUE

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
	if(isxeno(M) && !(user.prefs?.toggles_gameplay & TOGGLE_XENO_MOVE_INTENT_KEYBIND))
		return
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

/datum/keybinding/mob/toggle_minimap
	name = "toggle_minimap"
	full_name = "Toggle minimap"
	description = "Toggle your character's inherent or headset-based minimap screen"
	keybind_signal = COMSIG_KB_TOGGLE_MINIMAP

/datum/keybinding/mob/toggle_external_minimap
	name = "toggle_external_minimap"
	full_name = "Toggle external minimap"
	description = "Toggle external minimap screens received from e.g. consoles or similar objects"
	keybind_signal = COMSIG_KB_TOGGLE_EXTERNAL_MINIMAP

/datum/keybinding/mob/toggle_self_harm
	name = "toggle_self_harm"
	full_name = "Toggle self harm"
	description = "Toggle being able to hit yourself"
	keybind_signal = COMSIG_KB_SELFHARM
	hotkey_keys = list("0")

/datum/keybinding/mob/toggle_self_harm/down(client/user)
	. = ..()
	if (.)
		return
	user.mob.do_self_harm = !user.mob.do_self_harm
	user.mob.balloon_alert(user.mob, "self-harm [user.mob.do_self_harm ? "active" : "inactive"]")

/datum/keybinding/mob/interactive_emote
	name = "interactive_emote"
	full_name = "Do interactive emote"
	description = "Perform an interactive emote with another player."
	keybind_signal = COMSIG_KB_INTERACTIVE_EMOTE

/datum/keybinding/mob/interactive_emote/down(client/user)
	. = ..()
	if(. || !isliving(user.mob) || CHECK_BITFIELD(user.mob.status_flags, INCORPOREAL) || !user.mob.can_interact(user.mob))
		return

	var/list/adjacent_mobs = cheap_get_living_near(user.mob, 1)
	adjacent_mobs.Remove(user.mob)	//Get rid of self
	for(var/mob/M AS in adjacent_mobs)
		if(!M.client)
			adjacent_mobs.Remove(M)	//Get rid of non-players

	if(!length(adjacent_mobs))
		return

	if(length(adjacent_mobs) == 1)
		user.mob.interaction_emote(adjacent_mobs[1])
		return

	var/mob/target = tgui_input_list(user, "Who do you want to interact with?", "Select a target", adjacent_mobs)
	if(!target || !user.mob.Adjacent(target))	//In case the target moved away while selecting them
		return
	user.mob.interaction_emote(target)

/datum/keybinding/mob/prevent_movement
	hotkey_keys = list("")
	name = "block_movement"
	full_name = "Block movement"
	description = "Prevents you from moving"
	keybind_signal = COMSIG_KB_MOB_BLOCKMOVEMENT_DOWN

/datum/keybinding/mob/prevent_movement/down(client/user)
	. = ..()
	if(.)
		return
	user.movement_locked = TRUE

/datum/keybinding/mob/prevent_movement/up(client/user)
	. = ..()
	if(.)
		return
	user.movement_locked = FALSE

/datum/keybinding/mob/toggle_clickdrag
	hotkey_keys = list("")
	name = "toggle_clickdrag"
	full_name = "Toggle Click-Drag"
	description = "Toggles click-dragging on and off."
	keybind_signal = COMSIG_KB_MOB_TOGGLE_CLICKDRAG

/datum/keybinding/mob/toggle_clickdrag/down(client/user)
	. = ..()
	if(.)
		return
	user.prefs.toggles_gameplay ^= TOGGLE_CLICKDRAG
	user.mob.balloon_alert(user.mob, "click-drag [user.prefs.toggles_gameplay & TOGGLE_CLICKDRAG ? "inactive" : "active"]")
