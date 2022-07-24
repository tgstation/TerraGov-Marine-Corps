
// Used for spray that you spray at walls, tables, hydrovats etc
/atom/movable/effect/decal/spraystill
	density = FALSE
	anchored = TRUE
	layer = FLY_LAYER

//Used by spraybottles.
/atom/movable/effect/decal/chempuff
	name = "chemicals"
	icon = 'icons/effects/effects.dmi'
	icon_state = "chempuff"
	flags_pass = PASSTABLE|PASSGRILLE

/atom/movable/effect/decal/tile
	icon = 'icons/turf/floors.dmi'
	icon_state = "whitedecal"
	layer = ABOVE_TURF_LAYER
	mouse_opacity = 0

/atom/movable/effect/decal/tile/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			qdel(src)
		if(EXPLODE_HEAVY)
			if(prob(50))
				qdel(src)
		if(EXPLODE_LIGHT)
			if(prob(25))
				qdel(src)

/atom/movable/effect/decal/tile/full
	icon_state = "floor_large"

/atom/movable/effect/decal/tile/full/graylarge
	icon_state = "grayfloorlarge"

/atom/movable/effect/decal/tile/full/black
	color = "#6b6b6b"

/atom/movable/effect/decal/tile/full/darkgray
	color = "#818181"

/atom/movable/effect/decal/tile/full/white
	color = "#f7eeee"

/atom/movable/effect/decal/tile/full/brown
	color = "#443529"

/atom/movable/effect/decal/tile/gray
	icon_state = "graydecal"

/atom/movable/effect/decal/tile/green
	icon_state = "greendecal"

/atom/movable/effect/decal/tile/yellow
	icon_state = "yellowdecal"

/atom/movable/effect/decal/tile/red
	icon_state = "redecal"

/atom/movable/effect/decal/tile/black
	icon_state = "blackdecal"

/atom/movable/effect/decal/tile/brown
	icon_state = "browndecal"

/atom/movable/effect/decal/tile/pink
	icon_state = "pinkdecal"

/atom/movable/effect/decal/tile/blue
	icon_state = "bluedecal"

/atom/movable/effect/decal/tile/grid
	icon_state = "grid"

/atom/movable/effect/decal/tile/corsatstraight
	icon_state = "corsattile"

/atom/movable/effect/decal/tile/corsatstraight/red
	color = "#722729"

/atom/movable/effect/decal/tile/corsatstraight/blue
	color = "#2a5d7a"

/atom/movable/effect/decal/tile/corsatstraight/cyan
	color = "#217e7e"

/atom/movable/effect/decal/tile/corsatstraight/green
	color = "#155e19"

/atom/movable/effect/decal/tile/corsatstraight/yellow
	color = "#83810c"

/atom/movable/effect/decal/tile/corsatstraight/brown
	color = "#96561a"

/atom/movable/effect/decal/tile/corsatstraight/purple
	color = "#8d498d"

/atom/movable/effect/decal/tile/corsatstraight/lightpurple
	color = "#a33b94"

/atom/movable/effect/decal/tile/corsatstraight/darkgreen
	color = "#238623"

/atom/movable/effect/decal/tile/corsatstraight/white
	color = "#d3d3d3"

/atom/movable/effect/decal/tile/corsatcorner
	icon_state = "corsatlinecorner"

/atom/movable/effect/decal/tile/corsatcorner/red
	color = "#722729"

/atom/movable/effect/decal/tile/corsatcorner/blue
	color = "#2a5d7a"

/atom/movable/effect/decal/tile/corsatcorner/cyan
	color = "#217e7e"

/atom/movable/effect/decal/tile/corsatcorner/green
	color = "#155e19"

/atom/movable/effect/decal/tile/corsatcorner/yellow
	color = "#83810c"

/atom/movable/effect/decal/tile/corsatcorner/brown
	color = "#96561a"

/atom/movable/effect/decal/tile/corsatcorner/purple
	color = "#8d498d"

/atom/movable/effect/decal/tile/corsatcorner/lighpurple
	color = "#a33b94"

/atom/movable/effect/decal/tile/corsatcorner/darkgreen
	color = "#238623"

/atom/movable/effect/decal/tile/corsatcorner/white
	color = "#d3d3d3"

/atom/movable/effect/decal/tile/corsatsemi
	icon_state = "corsatlinesemi"

/atom/movable/effect/decal/tile/corsatsemi/red
	color = "#722729"

/atom/movable/effect/decal/tile/corsatsemi/blue
	color = "#2a5d7a"

/atom/movable/effect/decal/tile/corsatsemi/cyan
	color = "#217e7e"

/atom/movable/effect/decal/tile/corsatsemi/green
	color = "#155e19"

/atom/movable/effect/decal/tile/corsatsemi/yellow
	color = "#83810c"

/atom/movable/effect/decal/tile/corsatsemi/brown
	color = "#96561a"

/atom/movable/effect/decal/tile/corsatsemi/purple
	color = "#8d498d"

/atom/movable/effect/decal/tile/corsatsemi/lightpurple
	color = "#a33b94"

/atom/movable/effect/decal/tile/corsatsemi/darkgreen
	color = "#238623"

/atom/movable/effect/decal/tile/corsatsemi/white
	color = "#d3d3d3"

/atom/movable/effect/decal/woodsiding
	icon = 'icons/turf/floors.dmi'
	icon_state = "wood_siding"

/atom/movable/effect/decal/woodsiding/alt
	icon_state = "wood_sidingalt"

/atom/movable/effect/decal/woodsiding/Initialize()
	. = ..()
	loc.overlays += image(icon, icon_state, dir = src.dir)
	return INITIALIZE_HINT_QDEL

/atom/movable/effect/decal/siding
	icon = 'icons/turf/floors.dmi'
	icon_state = "siding"

/atom/movable/effect/decal/siding/alt
	icon_state = "sidingalt"

/atom/movable/effect/decal/siding/Initialize()
	. = ..()
	loc.overlays += image(icon, icon_state, dir = src.dir)
	return INITIALIZE_HINT_QDEL

/atom/movable/effect/decal/sandedge
	name = "dirt"
	desc = "A dirty pile, it looks thinner in certain areas."
	gender = PLURAL
	density = FALSE
	anchored = TRUE
	layer = TURF_LAYER
	icon = 'icons/turf/bigred.dmi'
	icon_state = "sandedge"
	mouse_opacity = 0

/atom/movable/effect/decal/sandedge/corner
	icon_state = "sandcorner"

/atom/movable/effect/decal/sandedge/corner2
	icon_state = "sandcorner2"

/atom/movable/effect/decal/sandytile
	name = "sand"
	gender = PLURAL
	density = FALSE
	anchored = TRUE
	layer = TURF_LAYER
	icon = 'icons/turf/ground_map.dmi'
	icon_state = "sandyfloor"
	mouse_opacity = 0

/atom/movable/effect/decal/sandytile/sandyplating
	icon_state = "sandyplating"

/atom/movable/effect/decal/riverdecal
	name = "river"
	gender = PLURAL
	density = FALSE
	anchored = TRUE
	layer = XENO_WEEDS_LAYER
	icon = 'icons/turf/ground_map.dmi'
	icon_state = "riverdecal"
	mouse_opacity = 0

/atom/movable/effect/decal/riverdecal/edge
	icon_state = "riverdecal_edge"

/atom/movable/effect/decal/corsat/symbol
	icon = 'icons/effects/warning_stripes.dmi'
	color = "#9c7f42"

/atom/movable/effect/decal/corsat/symbol/omega
	icon_state = "omega"
	color = "#534563"

/atom/movable/effect/decal/corsat/symbol/theta
	icon_state = "theta"
	color = "#549c42"

/atom/movable/effect/decal/corsat/symbol/gamma
	icon_state = "gamma"
	color = "#5d6384"

/atom/movable/effect/decal/corsat/symbol/sigma
	icon_state = "sigma"


/atom/movable/effect/decal/grassdecal
	icon = 'icons/turf/ground_map.dmi'
	icon_state = "grassdecal_edge"


/atom/movable/effect/decal/grassdecal/corner
	icon_state = "grassdecal_corner"

/atom/movable/effect/decal/grassdecal/corner2
	icon_state = "grassdecal_corner2"

/atom/movable/effect/decal/grassdecal/center
	icon_state = "grassdecal_center"

/atom/movable/effect/decal/lvsanddecal
	icon = 'icons/turf/ground_map.dmi'
	icon_state = "lvsanddecal_edge"


/atom/movable/effect/decal/lvsanddecal/corner
	icon_state = "lvsanddecal_corner"

/atom/movable/effect/decal/lvsanddecal/full
	icon_state = "lvsanddecal_full"

/atom/movable/effect/decal/tracks/human1
	icon = 'icons/effects/fluidtracks.dmi'
	icon_state = "human1"
	color = "#9bf500"

/atom/movable/effect/decal/tracks/human1/bloody
	color = "#860707"

/atom/movable/effect/decal/tracks/human1/wet
	color = "#626464"
	alpha = 140

/atom/movable/effect/decal/tracks/human2
	icon = 'icons/effects/fluidtracks.dmi'
	icon_state = "human2"
	color = "#9bf500"

/atom/movable/effect/decal/tracks/human2/bloody
	color = "#860707"

/atom/movable/effect/decal/tracks/paw1
	icon = 'icons/effects/fluidtracks.dmi'
	icon_state = "paw1"
	color = "#9bf500"

/atom/movable/effect/decal/tracks/paw1/bloody
	color = "#860707"

/atom/movable/effect/decal/tracks/paw2
	icon = 'icons/effects/fluidtracks.dmi'
	icon_state = "paw2"
	color = "#9bf500"

/atom/movable/effect/decal/tracks/paw2/bloody
	color = "#860707"

/atom/movable/effect/decal/tracks/claw1
	icon = 'icons/effects/fluidtracks.dmi'
	icon_state = "claw1"
	color = "#9bf500"

/atom/movable/effect/decal/tracks/claw1/bloody
	color = "#860707"

/atom/movable/effect/decal/tracks/claw2
	icon = 'icons/effects/fluidtracks.dmi'
	icon_state = "claw2"
	color = "#9bf500"

/atom/movable/effect/decal/tracks/claw2/bloody
	color = "#860707"

/atom/movable/effect/decal/tracks/wheels
	icon = 'icons/effects/fluidtracks.dmi'
	icon_state = "wheels"
	color = "#9bf500"

/atom/movable/effect/decal/tracks/wheels/bloody
	color = "#860707"
