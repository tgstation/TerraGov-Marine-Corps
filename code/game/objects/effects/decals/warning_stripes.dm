/obj/effect/decal/warning_stripes
	icon = 'icons/effects/warning_stripes.dmi'
	layer = TURF_LAYER

/obj/effect/decal/warning_stripes/New()
	. = ..()

	loc.overlays += src
	cdel(src)