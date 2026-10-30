/obj/item/megaphone
	name = "megaphone"
	desc = "A device used to project your voice. Loudly."
	icon = 'icons/obj/device.dmi'
	icon_state = "megaphone"
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/equipment/tools_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/equipment/tools_right.dmi',
	)
	worn_icon_state = "radio"
	w_class = WEIGHT_CLASS_SMALL
	atom_flags = CONDUCT
	var/spamcheck = 0
	var/list/voicespan = list(SPAN_COMMAND)

/obj/item/megaphone/equipped(mob/M, slot)
	. = ..()
	if ((slot == SLOT_L_HAND) || (slot == SLOT_R_HAND))
		RegisterSignal(M, COMSIG_MOB_SAY, PROC_REF(handle_speech))
	else
		UnregisterSignal(M, COMSIG_MOB_SAY)

/obj/item/megaphone/dropped(mob/M)
	. = ..()
	UnregisterSignal(M, COMSIG_MOB_SAY)

/obj/item/megaphone/proc/handle_speech(mob/living/carbon/user, list/speech_args)
	SIGNAL_HANDLER
	if (user.get_active_held_item() != src)
		return
	if(spamcheck > world.time)
		balloon_alert(user, "wait a while!")
		return
	playsound(loc, 'sound/items/megaphone.ogg', 100, FALSE, TRUE)
	spamcheck = world.time + 20
	speech_args[SPEECH_SPANS] |= voicespan
