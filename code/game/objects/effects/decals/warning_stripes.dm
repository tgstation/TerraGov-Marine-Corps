/obj/effect/decal/warning_stripes
	name = "warning stripes"
	icon = 'icons/effects/warning_stripes.dmi'
	layer = TURF_LAYER
	mouse_opacity = 0
/obj/effect/decal/warning_stripes/New()
	. = ..()

	loc.overlays += src
	cdel(src)

/obj/effect/decal/warning_stripes/asteroid
	icon_state = "warning"


/obj/effect/decal/warning_stripes/sand
	mouse_opacity = 0
	unacidable = 1
	icon = 'icons/turf/overlays.dmi'
	icon_state = "sand"
	layer = TURF_LAYER+0.5 //So it appears over other decals

/obj/effect/decal/warning_stripes/sand/rock
	icon_state = "rock"

/obj/effect/decal/warning_stripes/halftile
	name = "half tile"
	icon_state = "halftile"

/obj/effect/decal/warning_stripes/halftile/warning
	name = "warning stripes half tile"
	icon_state = "halftile_w"