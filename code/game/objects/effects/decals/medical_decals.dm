/obj/effect/decal/medical_decals
	icon = 'icons/effects/medical_decals.dmi'
	layer = TURF_LAYER

/obj/effect/decal/medical_decals/New()
	. = ..()

	loc.overlays += src
	qdel(src)
