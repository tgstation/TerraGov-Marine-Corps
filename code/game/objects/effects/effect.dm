/obj/effect

/obj/effect/New()
	..()
	effect_list += src

/obj/effect/Dispose()
	. = ..()
	effect_list -= src


