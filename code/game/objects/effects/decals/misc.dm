
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

/obj/effect/decal/tile/full
	icon_state = "floor_large"

/obj/effect/decal/tile/full/graylarge
	icon_state = "grayfloorlarge"

/obj/effect/decal/tile/full/black
	color = "#6b6b6b"

/obj/effect/decal/tile/full/darkgray
	color = "#818181"

/obj/effect/decal/tile/full/white
	color = "#f7eeee"

/obj/effect/decal/tile/full/brown
	color = "#443529"

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

/obj/effect/decal/tile/corsatstraight
	icon_state = "corsattile"

/obj/effect/decal/tile/corsatstraight/red
	color = "#722729"

/obj/effect/decal/tile/corsatstraight/blue
	color = "#2a5d7a"

/obj/effect/decal/tile/corsatstraight/cyan
	color = "#217e7e"

/obj/effect/decal/tile/corsatstraight/green
	color = "#155e19"

/obj/effect/decal/tile/corsatstraight/yellow
	color = "#83810c"

/obj/effect/decal/tile/corsatstraight/brown
	color = "#96561a"

/obj/effect/decal/tile/corsatstraight/purple
	color = "#8d498d"

/obj/effect/decal/tile/corsatstraight/lightpurple
	color = "#a33b94" 

/obj/effect/decal/tile/corsatstraight/darkgreen
	color = "#238623"

/obj/effect/decal/tile/corsatstraight/white
	color = "#d3d3d3"

/obj/effect/decal/tile/corsatcorner
	icon_state = "corsatlinecorner"

/obj/effect/decal/tile/corsatcorner/red
	color = "#722729"

/obj/effect/decal/tile/corsatcorner/blue
	color = "#2a5d7a"

/obj/effect/decal/tile/corsatcorner/cyan
	color = "#217e7e"

/obj/effect/decal/tile/corsatcorner/green
	color = "#155e19"

/obj/effect/decal/tile/corsatcorner/yellow
	color = "#83810c"

/obj/effect/decal/tile/corsatcorner/brown
	color = "#96561a"

/obj/effect/decal/tile/corsatcorner/purple
	color = "#8d498d"

/obj/effect/decal/tile/corsatcorner/lighpurple
	color = "#a33b94"

/obj/effect/decal/tile/corsatcorner/darkgreen
	color = "#238623"

/obj/effect/decal/tile/corsatcorner/white
	color = "#d3d3d3"

/obj/effect/decal/tile/corsatsemi
	icon_state = "corsatlinesemi"

/obj/effect/decal/tile/corsatsemi/red
	color = "#722729"

/obj/effect/decal/tile/corsatsemi/blue
	color = "#2a5d7a"

/obj/effect/decal/tile/corsatsemi/cyan
	color = "#217e7e"

/obj/effect/decal/tile/corsatsemi/green
	color = "#155e19"

/obj/effect/decal/tile/corsatsemi/yellow
	color = "#83810c"

/obj/effect/decal/tile/corsatsemi/brown
	color = "#96561a"

/obj/effect/decal/tile/corsatsemi/purple
	color = "#8d498d"

/obj/effect/decal/tile/corsatsemi/lightpurple
	color = "#a33b94"

/obj/effect/decal/tile/corsatsemi/darkgreen
	color = "#238623"

/obj/effect/decal/tile/corsatsemi/white
	color = "#d3d3d3"

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
	icon_state = "riverdecal_edge"

/obj/effect/decal/corsat/symbol
	icon = 'icons/effects/warning_stripes.dmi'
	color = "#9c7f42"

/obj/effect/decal/corsat/symbol/omega
	icon_state = "omega"
	color = "#534563"

/obj/effect/decal/corsat/symbol/theta
	icon_state = "theta"
	color = "#549c42"

/obj/effect/decal/corsat/symbol/gamma
	icon_state = "gamma"
	color = "#5d6384"

/obj/effect/decal/corsat/symbol/sigma
	icon_state = "sigma"


/obj/effect/decal/grassdecal
	icon = 'icons/turf/ground_map.dmi'
	icon_state = "grassdecal_edge"


/obj/effect/decal/grassdecal/corner
	icon_state = "grassdecal_corner"

/obj/effect/decal/grassdecal/corner2
	icon_state = "grassdecal_corner2"

/obj/effect/decal/grassdecal/center
	icon_state = "grassdecal_center"

/obj/effect/decal/lvsanddecal
	icon = 'icons/turf/ground_map.dmi'
	icon_state = "lvsanddecal_edge"


/obj/effect/decal/lvsanddecal/corner
	icon_state = "lvsanddecal_corner"

/obj/effect/decal/lvsanddecal/full
	icon_state = "lvsanddecal_full"

/obj/effect/decal/tracks/human1
	icon = 'icons/effects/fluidtracks.dmi'
	icon_state = "human1"
	color = "#9bf500"

/obj/effect/decal/tracks/human1/bloody
	color = "#860707"

/obj/effect/decal/tracks/human1/wet
	color = "#626464"
	alpha = 140
	
/obj/effect/decal/tracks/human2
	icon = 'icons/effects/fluidtracks.dmi'
	icon_state = "human2"
	color = "#9bf500"

/obj/effect/decal/tracks/human2/bloody
	color = "#860707"

/obj/effect/decal/tracks/paw1
	icon = 'icons/effects/fluidtracks.dmi'
	icon_state = "paw1"
	color = "#9bf500"

/obj/effect/decal/tracks/paw1/bloody
	color = "#860707"

/obj/effect/decal/tracks/paw2
	icon = 'icons/effects/fluidtracks.dmi'
	icon_state = "paw2"
	color = "#9bf500"

/obj/effect/decal/tracks/paw2/bloody
	color = "#860707"

/obj/effect/decal/tracks/claw1
	icon = 'icons/effects/fluidtracks.dmi'
	icon_state = "claw1"
	color = "#9bf500"

/obj/effect/decal/tracks/claw1/bloody
	color = "#860707"

/obj/effect/decal/tracks/claw2
	icon = 'icons/effects/fluidtracks.dmi'
	icon_state = "claw2"
	color = "#9bf500"

/obj/effect/decal/tracks/claw2/bloody
	color = "#860707"

/obj/effect/decal/tracks/wheels
	icon = 'icons/effects/fluidtracks.dmi'
	icon_state = "wheels"
	color = "#9bf500"

/obj/effect/decal/tracks/wheels/bloody
	color = "#860707"
