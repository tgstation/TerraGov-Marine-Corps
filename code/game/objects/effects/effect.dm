/obj/effect

/obj/effect/Initialize()
	. = ..()
	GLOB.effect_list += src

/obj/effect/Destroy()
	. = ..()
	GLOB.effect_list -= src


