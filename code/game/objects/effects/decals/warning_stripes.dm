/obj/effect/decal/warning_stripes
	icon = 'icons/effects/warning_stripes.dmi'
	layer = TURF_LAYER

/obj/effect/decal/warning_stripes/Initialize()
	. = ..()

	loc.overlays += src
	return INITIALIZE_HINT_QDEL
