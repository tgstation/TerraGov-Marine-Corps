//Refer to life.dm for caller

/mob/living/carbon/human/handle_impaired_vision()
	. = ..()

	if(!(disabilities & BLIND) && tinttotal >= TINT_5) // Covered eyes, heal faster
		adjust_blindness(-1)
		adjust_blurriness(-2)

	if(!(disabilities & NEARSIGHTED))
		clear_fullscreen("nearsighted")
		return

	if(!glasses)
		overlay_fullscreen("nearsighted", /obj/screen/fullscreen/impaired, 1)
		return

	var/obj/item/clothing/glasses/G = glasses
	if(!G.prescription)
		overlay_fullscreen("nearsighted", /obj/screen/fullscreen/impaired, 1)
	else
		clear_fullscreen("nearsighted")



/mob/living/carbon/human/handle_impaired_hearing()
	. = ..()

	if(disabilities & DEAF)
		return

	if(!istype(wear_ear, /obj/item/clothing/ears/earmuffs))	//Resting your ears with earmuffs heals ear damage faster
		return

	adjust_ear_damage(-0.15, 1)
