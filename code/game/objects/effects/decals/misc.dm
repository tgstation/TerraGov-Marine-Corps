
// Used for spray that you spray at walls, tables, hydrovats etc
/obj/effect/decal/spraystill
	density = FALSE
	anchored = TRUE
	layer = FLY_LAYER

//Used by spraybottles.
/obj/effect/decal/chempuff
	name = "chemicals"
	icon = 'icons/effects/effects.dmi'
	icon_state = "chempuff"
	flags_pass = PASSTABLE|PASSGRILLE

/obj/effect/decal/woodsiding
	icon = 'icons/turf/floors.dmi'
	icon_state = "wood_siding"

/obj/effect/decal/woodsiding/alt
	icon_state = "wood_sidingalt"

/obj/effect/decal/woodsiding/Initialize()
	. = ..()
	loc.overlays += image(icon, icon_state, dir = src.dir)
	return INITIALIZE_HINT_QDEL

/obj/effect/decal/siding
	icon = 'icons/turf/floors.dmi'
	icon_state = "siding"

/obj/effect/decal/siding/alt
	icon_state = "sidingalt"

/obj/effect/decal/siding/Initialize()
	. = ..()
	loc.overlays += image(icon, icon_state, dir = src.dir)
	return INITIALIZE_HINT_QDEL

/obj/effect/decal/sandedge
	name = "dirt"
	desc = "A dirty pile, it looks thinner in certain areas."
	gender = PLURAL
	density = FALSE
	anchored = TRUE
	layer = TURF_LAYER
	icon = 'icons/turf/bigred.dmi'
	icon_state = "sandedge"
	mouse_opacity = 0

/obj/effect/decal/sandedge/corner
	icon_state = "sandcorner"

/obj/effect/decal/sandedge/corner2
	icon_state = "sandcorner2"
