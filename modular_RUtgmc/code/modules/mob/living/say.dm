/mob/living/can_speak_vocal(message) //Check AFTER handling of xeno channels
	if(istype(wear_mask, /obj/item/clothing/mask/facehugger))
		return FALSE
	return ..()
