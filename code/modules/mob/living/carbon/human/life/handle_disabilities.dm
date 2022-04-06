//Refer to life.dm for caller

/mob/living/carbon/human/handle_disabilities()
	. = ..()

	switch(rand(0, 200))
		if(0 to 3)
			if(getBrainLoss() >= 5)
				custom_pain("Your head feels numb and painful.")
		if(4 to 6)
			if(eye_blurry <= 0 && getBrainLoss() >= 15 )
				to_chat(src, span_danger("It becomes hard to see for some reason."))
				blur_eyes(10)
		if(7 to 9)
			if((hand && get_held_item()) && getBrainLoss())
				to_chat(src, span_danger("Your hand won't respond properly, you drop what you're holding."))
				drop_held_item()
		if(10 to 12)
			if(!lying_angle && getBrainLoss())
				to_chat(src, span_danger("Your legs won't respond properly, you fall down."))
				set_resting(TRUE)
		else
			return


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
