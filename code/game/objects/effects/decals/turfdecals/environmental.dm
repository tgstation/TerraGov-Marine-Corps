/obj/effect/turf_decal/grassdecal
	icon = 'icons/turf/ground_map.dmi'
	icon_state = "grassdecal_edge"

/obj/effect/turf_decal/grassdecal/corner
	icon_state = "grassdecal_corner"

/obj/effect/turf_decal/grassdecal/corner2
	icon_state = "grassdecal_corner2"

/obj/effect/turf_decal/grassdecal/center
	icon_state = "grassdecal_center"

/obj/effect/turf_decal/lvsanddecal
	icon = 'icons/turf/ground_map.dmi'
	icon_state = "lvsanddecal_edge"

/obj/effect/turf_decal/lvsanddecal/corner
	icon_state = "lvsanddecal_corner"

/obj/effect/turf_decal/lvsanddecal/full
	icon_state = "lvsanddecal_full"

/obj/effect/turf_decal/tracks/human1
	icon = 'icons/effects/fluidtracks.dmi'
	icon_state = "human1"
	color = "#9bf500"

/obj/effect/turf_decal/tracks/human1/bloody
	color = "#860707"

/obj/effect/turf_decal/tracks/human1/wet
	color = "#626464"
	alpha = 140

/obj/effect/turf_decal/sandedge
	name = "dirt"
	desc = "A dirty pile, it looks thinner in certain areas."
	icon = 'icons/turf/bigred.dmi'
	icon_state = "sandedge"

/obj/effect/turf_decal/sandedge/corner
	icon_state = "sandcorner"

/obj/effect/turf_decal/sandedge/corner2
	icon_state = "sandcorner2"

/obj/effect/turf_decal/sandytile
	name = "sand"
	icon = 'icons/turf/ground_map.dmi'
	icon_state = "sandyfloor"

/obj/effect/turf_decal/sandytile/sandyplating
	icon_state = "sandyplating"

/obj/effect/turf_decal/riverdecal
	name = "river"
	layer = XENO_WEEDS_LAYER
	icon = 'icons/turf/ground_map.dmi'
	icon_state = "riverdecal"
	smoothing_groups = list(
		SMOOTH_GROUP_RIVER,
		SMOOTH_GROUP_SURVIVAL_TITANIUM_WALLS,
		SMOOTH_GROUP_LATTICE,
		SMOOTH_GROUP_GRILLE,
	)


/obj/effect/turf_decal/riverdecal/edge
	icon_state = "riverdecal_edge"
