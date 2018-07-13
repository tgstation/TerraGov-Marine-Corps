/obj/effect/decal/warning_stripes
	icon = 'icons/effects/warning_stripes.dmi'
	layer = TURF_LAYER

/obj/effect/decal/warning_stripes/New()
	. = ..()

	loc.overlays += src
	cdel(src)

/obj/effect/decal/warning_stripes/asteroid
	icon_state = "warning"


/obj/effect/decal/sand
	mouse_opacity = 0
	unacidable = 1
	icon = 'icons/turf/overlays.dmi'
	icon_state = "sand"
	layer = TURF_LAYER+0.5 //So it appears over other decals

/obj/effect/decal/sand/rock
	icon_state = "rock"