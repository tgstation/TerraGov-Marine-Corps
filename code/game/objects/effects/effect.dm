/obj/effect

/obj/effect/New()
	..()
	GLOB.effect_list += src

/obj/effect/Destroy()
	. = ..()
	GLOB.effect_list -= src


