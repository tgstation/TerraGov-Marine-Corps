/**********************Planet**************************/

/turf/open/floor/plating/ground //Basic groundmap turf parent
	name = "ground dirt"
	icon = 'icons/turf/ground_map.dmi'
	icon_state = "desert"

/turf/open/floor/plating/ground/AfterChange()
	. = ..()
	baseturfs = type

/turf/open/floor/plating/ground/fire_act(exposed_temperature, exposed_volume)
	return

/turf/open/floor/plating/ground/is_plating() //Temporary hack until we re-implement baseturfs, /tg/ plating and change_turf.dm.
	return FALSE


/turf/open/floor/plating/ground/dirt
	name = "dirt"
	icon_state = "desert"
	shoefootstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	mediumxenofootstep = FOOTSTEP_SAND

/turf/open/floor/plating/ground/dirt/Initialize()
	. = ..()
	if(rand(0,15) == 0)
		icon_state = "desert[pick("0","1","2","3")]"


/turf/open/floor/plating/ground/dirt2
	name = "dirt"
	icon_state = "dirt"

/turf/open/floor/plating/ground/dirtgrassborder
	name = "grass"
	icon_state = "grassdirt_edge"
	shoefootstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	mediumxenofootstep = FOOTSTEP_SAND

/turf/open/floor/plating/ground/dirtgrassborder/corner
	icon_state = "grassdirt_corner"

/turf/open/floor/plating/ground/dirtgrassborder2
	name = "grass"
	icon_state = "grassdirt2_edge"
	shoefootstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	mediumxenofootstep = FOOTSTEP_SAND

/turf/open/floor/plating/ground/dirtgrassborder2/corner
	icon_state = "grassdirt_corner2"

/turf/open/ground/grass
	name = "grass"
	icon_state = "grass1"
	shoefootstep = FOOTSTEP_GRASS
	barefootstep = FOOTSTEP_GRASS
	mediumxenofootstep = FOOTSTEP_GRASS

/turf/open/ground/grass/grass2
	icon_state = "grass2"


// Big Red

/turf/open/floor/plating/ground/mars
	icon = 'icons/turf/bigred.dmi'

/turf/open/floor/plating/ground/mars/random/Initialize()
	. = ..()
	dir = pick(GLOB.alldirs)

/turf/open/floor/plating/ground/mars/random/cave
	name = "cave"
	icon_state = "mars_cave"

/turf/open/floor/plating/ground/mars/random/cave/rock
	name = "cave"
	icon_state = "mars_cave_rock"

/turf/open/floor/plating/ground/mars/random/tile
	name = "dirt"
	icon_state = "mars_tile"

/turf/open/floor/plating/ground/mars/random/dust
	name = "dusty dirt"
	icon_state = "mars_dirt"
	var/dirt_color = "#b1503d"



turf/open/floor/plating/ground/mars/random/dust/Entered(atom/A, atom/OL)
	. = ..()
	if(iscarbon(A))
		var/mob/living/carbon/C = A
		if(!C.lying_angle && !(C.buckled && istype(C.buckled,/obj/structure/bed/chair)))
			if(ishuman(C))
				var/mob/living/carbon/human/H = C
				src.AddTracks(/obj/effect/decal/cleanable/blood/tracks/dustprints,null,H.dir,0,dirt_color) // Coming
				var/turf/from = get_step(H,reverse_direction(H.dir))
				if(istype(from) && from)
					from.AddTracks(/obj/effect/decal/cleanable/blood/tracks/dustprints,null,0,H.dir,dirt_color) // Going


/turf/open/floor/plating/ground/mars/random/dust/sand
	name = "dusty sand"
	icon_state = "mars_sand"
	shoefootstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	mediumxenofootstep = FOOTSTEP_SAND

/turf/open/floor/plating/ground/mars/random/dust/dirt
	name = "dusty dirt"
	icon_state = "mars_dirt"

/turf/open/floor/plating/ground/mars/dirttosand
	name = "sand"
	icon_state = "mars_dirt_to_sand"
/turf/open/floor/plating/ground/mars/cavetodirt
	name = "cave"
	icon_state = "mars_cave_to_dirt"


//Ice Colony grounds

//Ice Floor
/turf/open/floor/plating/ground/ice
	name = "ice floor"
	icon = 'icons/turf/ice.dmi'
	icon_state = "ice_floor"

//Randomize ice floor sprite
/turf/open/floor/plating/ground/ice/Initialize()
	. = ..()
	setDir(pick(NORTH,SOUTH,EAST,WEST,NORTHEAST,NORTHWEST,SOUTHEAST,SOUTHWEST))

// Colony tiles
/turf/open/floor/plating/ground/asphalt
	name = "asphalt"
	icon = 'icons/turf/asphalt.dmi'
	icon_state = "asphalt"


//Desert Map

/turf/open/floor/plating/ground/desertdam //Basic groundmap turf parent
	name = "desert dirt"
	icon = 'icons/turf/desertdam_map.dmi'
	icon_state = "desert1"

//desert floor
/turf/open/floor/plating/ground/desertdam/desert
	name = "desert"
	icon_state = "desert1"

//asphalt road
/turf/open/floor/plating/ground/desertdam/asphault
	name = "asphault"
	icon_state = "sunbleached_asphalt1"

//CAVE
/turf/open/floor/plating/ground/desertdam/cave
	icon_state = "outer_cave_floor1"

//desert floor to outer cave floor transition
/turf/open/floor/plating/ground/desertdam/cave/desert_into_outer_cave_floor
	name = "cave"
	icon_state = "outer_cave_transition1"

//outer cave floor
/turf/open/floor/plating/ground/desertdam/cave/outer_cave_floor
	name = "cave"
	icon_state = "outer_cave_floor1"

//outer to inner cave floor transition
/turf/open/floor/plating/ground/desertdam/cave/outer_cave_to_inner_cave
	name = "cave"
	icon_state = "outer_cave_to_inner1"

//inner cave floor
/turf/open/floor/plating/ground/desertdam/cave/inner_cave_floor
	name = "cave"
	icon_state = "inner_cave_1"
