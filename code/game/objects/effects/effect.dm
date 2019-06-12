/obj/effect
	icon = 'icons/effects/effects.dmi'
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF


/obj/effect/Initialize()
	. = ..()
	GLOB.effect_list += src


/obj/effect/Destroy()
	. = ..()
	GLOB.effect_list -= src