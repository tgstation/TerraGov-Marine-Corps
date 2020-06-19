/obj/effect/decal/warning_stripes
	icon = 'icons/effects/warning_stripes.dmi'
	layer = TURF_LAYER

/obj/effect/decal/warning_stripes/nscenter
	icon_state = "NS-center"

/obj/effect/decal/warning_stripes/Initialize()
	. = ..()

	loc.overlays += image(icon, icon_state, dir = src.dir)
	return INITIALIZE_HINT_QDEL

/obj/effect/decal/warning_stripes/thin
	icon_state = "thin"

/obj/effect/decal/warning_stripes/thick
	icon_state = "thick"
