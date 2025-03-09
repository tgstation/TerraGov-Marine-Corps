// make subtypes of these for turf under/overlays
/obj/effect/turf_overlay
	name = "abstract type"

/obj/effect/turf_overlay/Initialize(mapload)
	. = ..()
	var/turf/T = get_turf(src)
	T.overlays += image(icon, T, icon_state, TURF_DECAL_LAYER)
	return INITIALIZE_HINT_QDEL

/obj/effect/turf_overlay/shuttle
	icon = 'icons/turf/shuttle.dmi'

/obj/effect/turf_overlay/shuttle/platform
	icon_state = "platform"

/obj/effect/turf_overlay/shuttle/heater
	icon_state = "heater"

/obj/effect/turf_overlay/icerock
	icon = 'icons/turf/rockwall.dmi'
	icon_state = "corner_overlay"


/obj/effect/turf_underlay
	name = "abstract type"

/obj/effect/turf_underlay/Initialize(mapload)
	. = ..()
	var/turf/T = get_turf(src)
	T.underlays += image(icon, T, icon_state, LOW_FLOOR_LAYER)
	return INITIALIZE_HINT_QDEL

/obj/effect/turf_underlay/tiles
	icon = 'icons/turf/floors.dmi'

/obj/effect/turf_underlay/tiles/dark2
	icon_state = "dark2"

/obj/effect/turf_underlay/tiles/plating
	icon_state = "plating"

/obj/effect/turf_underlay/shuttle
	icon = 'icons/turf/shuttle.dmi'

/obj/effect/turf_underlay/shuttle/floor6
	icon_state = "floor6"
