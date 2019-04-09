/obj/effect
	resistance_flags = UNACIDABLE


/obj/effect/Initialize()
	. = ..()
	GLOB.effect_list += src


/obj/effect/Destroy()
	. = ..()
	GLOB.effect_list -= src