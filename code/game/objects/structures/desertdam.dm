
//OBJ
/obj/structure/desertdam/decals
	name = "desert foliage"
	icon = 'icons/turf/desertdam_map.dmi'
	density = 0
	anchored = 1
	unacidable = 1 // can toggle it off anyway
	layer = ABOVE_MOB_LAYER
//loose sand overlay
/obj/structure/desertdam/decals/loose_sand_overlay
	name = "loose sand"
	icon_state = "loosesand_overlay_for_asphalt_1"

//road decal
/obj/structure/desertdam/decals/road_edge
	name = "road"
	icon_state = "road_edge_decal1"
/obj/structure/desertdam/decals/road_stop
	name = "road"
	icon_state = "stop_decal1"

//TODO:
//Relocate me somewhere that makes more sense
/obj/structure/chigusa_sign
	name = "Chigusa Sign"
	desc = "A large sign reading 'lazarus landing pop. 73', there's blood smeared on it."
	icon = 'icons/obj/landing_signs.dmi'
	icon_state = "laz_sign"
	bound_width = 64
	bound_height = 64
	density = 1
