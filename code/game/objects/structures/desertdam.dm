
//OBJ
/obj/structure/desertdam/decals
	icon = 'icons/turf/desertdam_map.dmi'
	density = FALSE
	anchored = TRUE
	resistance_flags = UNACIDABLE
	layer = ABOVE_MOB_LAYER

//loose sand overlay
/obj/structure/desertdam/decals/loose_sand_overlay
	name = "loose sand"
	icon_state = "loosesand0"

/obj/structure/desertdam/decals/loose_sand_overlay/alt
	icon_state = "loosesand1"

//road decal
/obj/structure/desertdam/decals/road
	name = "road"
	icon_state = "road"
	layer = LOW_OBJ_LAYER

/obj/structure/desertdam/decals/road/edge
	icon_state = "edge"

/obj/structure/desertdam/decals/road/edge/long
	icon_state = "road_edge_long"

/obj/structure/desertdam/decals/road/stop
	icon_state = "stop_decal"

/obj/structure/desertdam/decals/road/line
	icon_state = "line"

//TODO:
//Relocate me somewhere that makes more sense
/obj/structure/chigusa_sign
	name = "Chigusa Sign"
	desc = "A large sign reading 'lazarus landing pop. 73', there's blood smeared on it."
	icon = 'icons/obj/landing_signs.dmi'
	icon_state = "laz_sign"
	bound_width = 64
	bound_height = 64
	density = TRUE
	coverage = 15
