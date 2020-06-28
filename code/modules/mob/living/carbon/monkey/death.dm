

/mob/living/carbon/monkey/gib_animation()
	new /obj/effect/overlay/temp/gib_animation(loc, src, "gibbed-m")

/mob/living/carbon/monkey/dust_animation()
	new /obj/effect/overlay/temp/dust_animation(loc, src, "dust-m")


/mob/living/carbon/monkey/death(gibbing, deathmessage = "lets out a faint chimper as it collapses and stops moving...", silent)
	if(stat == DEAD)
		return ..()
	return ..() //Just a different standard deathmessage
