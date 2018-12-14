/obj/effect

/obj/effect/New()
	..()
	effect_list += src

/obj/effect/Destroy()
	. = ..()
	effect_list -= src


