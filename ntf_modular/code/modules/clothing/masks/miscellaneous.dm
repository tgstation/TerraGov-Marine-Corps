/obj/item/clothing/mask/muzzle/equipped(mob/M, slot)
	. = ..()
	if (slot == SLOT_WEAR_MASK)
		RegisterSignal(M, COMSIG_MOB_SAY, PROC_REF(handle_speech))
	else
		UnregisterSignal(M, COMSIG_MOB_SAY)

/obj/item/clothing/mask/muzzle/dropped(mob/M)
	. = ..()
	UnregisterSignal(M, COMSIG_MOB_SAY)

/obj/item/clothing/mask/muzzle/proc/handle_speech(mob/living/carbon/user, list/speech_args)
	SIGNAL_HANDLER
	if(user.wear_mask != src)
		UnregisterSignal(user, COMSIG_MOB_SAY)
		CRASH("Muzzle speech handling signal not unregistered on removal.")
	speech_args[SPEECH_MESSAGE] = pick("Mmmph...", "Hmmphh", "Mmmfhg", "Gmmmh...", "Mhgm...", "Hmmmp!...", "GMmmhp!")
