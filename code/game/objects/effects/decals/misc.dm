
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

/obj/effect/decal/tile
	icon = 'icons/turf/floors.dmi'
	icon_state = "whitedecal"
	layer = ABOVE_TURF_LAYER
	mouse_opacity = 0

/obj/effect/decal/tile/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			qdel(src)
		if(EXPLODE_HEAVY)
			if(prob(50))
				qdel(src)
		if(EXPLODE_LIGHT)
			if(prob(25))
				qdel(src)

/obj/effect/decal/tile/gray
	icon_state = "graydecal"

/obj/effect/decal/tile/green
	icon_state = "greendecal"

/obj/effect/decal/tile/yellow
	icon_state = "yellowdecal"

/obj/effect/decal/tile/red
	icon_state = "redecal"

/obj/effect/decal/tile/black
	icon_state = "blackdecal"

/obj/effect/decal/tile/brown
	icon_state = "browndecal"

/obj/effect/decal/tile/pink
	icon_state = "pinkdecal"

/obj/effect/decal/tile/blue
	icon_state = "bluedecal"

/obj/effect/decal/tile/grid
	icon_state = "grid"

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

/obj/effect/decal/sandytile
	name = "sand"
	gender = PLURAL
	density = FALSE
	anchored = TRUE
	layer = TURF_LAYER
	icon = 'icons/turf/ground_map.dmi'
	icon_state = "sandyfloor"
	mouse_opacity = 0

/obj/effect/decal/sandytile/sandyplating
	icon_state = "sandyplating"

/obj/effect/decal/riverdecal
	name = "river"
	gender = PLURAL
	density = FALSE
	anchored = TRUE
	layer = XENO_WEEDS_LAYER
	icon = 'icons/turf/ground_map.dmi'
	icon_state = "riverdecal"
	mouse_opacity = 0

/obj/effect/decal/riverdecal/edge
	icon_state = "riverdecaledge"
