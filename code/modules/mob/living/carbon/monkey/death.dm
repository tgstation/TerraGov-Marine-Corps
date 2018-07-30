

/mob/living/carbon/monkey/gib_animation()
	new /obj/effect/overlay/temp/gib_animation(loc, src, "gibbed-m")

/mob/living/carbon/monkey/dust_animation()
	new /obj/effect/overlay/temp/dust_animation(loc, src, "dust-m")


/mob/living/carbon/monkey/death(gibbed)
	..(gibbed,"lets out a faint chimper as it collapses and stops moving...")