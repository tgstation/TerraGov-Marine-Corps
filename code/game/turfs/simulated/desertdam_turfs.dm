
//TURF

	//desert floor

	//asphalt road

	//CAVE
		//_______________________________________
		//desert floor to outer cave floor transition
		//outer cave floor
		//ouer to inner cave floor transition
		//inner cave floor



	//WATER
		//CLEAN
			//_______________________________________
			//shallow water
			//shallow water transition to deep
			//deep water
			//shallow water coast
			//desert floor waterway
			//cave floor waterway

		//TOXIC
			//_______________________________________
			//shallow water
			//shallow water transition to deep
			//deep water
			//shallow water coast
			//desert floor waterway
			//cave floor waterway

	//Wall

//OBJ

	//loose sand overlay

	//GRASS
		//_______________________________________
		//lightgrass
		//heavygrass
	//CACTUS
		//_______________________________________
		//cactus
		//cacti
	//road decal
		//_______________________________________
		//road edge
		//road stop

//TURF Parent
/turf/unsimulated/floor/desertdam //Basic groundmap turf parent

    name = "desert dirt"

    icon = 'icons/turf/desertdam_map.dmi'

    icon_state = "desert1"

//  floor_tile = null

    heat_capacity = 500000 //Shouldn't be possible, but you never know...

    is_groundmap_turf = TRUE

    ex_act(severity) //Should make it indestructable

        return

    fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)

        return

    attackby() //This should fix everything else. No cables, etc

        return
//desert floor
/turf/unsimulated/floor/desertdam/desert
	name = "desert"
	icon_state = "desert1"


//asphalt road
/turf/unsimulated/floor/desertdam/asphault
	name = "asphault"
	icon_state = "sunbleached_asphalt1"



//CAVE
/turf/unsimulated/floor/desertdam/cave
	icon_state = "outer_cave_floor1"

//desert floor to outer cave floor transition
/turf/unsimulated/floor/desertdam/cave/desert_into_outer_cave_floor
	name = "cave"
	icon_state = "outer_cave_transition1"

//outer cave floor
/turf/unsimulated/floor/desertdam/cave/outer_cave_floor
	name = "cave"
	icon_state = "outer_cave_floor1"

//outer to inner cave floor transition
/turf/unsimulated/floor/desertdam/cave/outer_cave_to_inner_cave
	name = "cave"
	icon_state = "outer_cave_to_inner1"

//inner cave floor
/turf/unsimulated/floor/desertdam/cave/inner_cave_floor
	name = "cave"
	icon_state = "inner_cave_1"

//River
/turf/unsimulated/floor/desertdam/river
	icon_state = "shallow_water_clean"


//shallow water
/turf/unsimulated/floor/desertdam/river/clean/shallow
	name = "river"
	icon_state = "shallow_water_clean"
//shallow water transition to deep
/turf/unsimulated/floor/desertdam/river/clean/shallow_edge
	name = "river"
	icon_state = "shallow_to_deep_clean_water1"
//deep water
/turf/unsimulated/floor/desertdam/river/clean/deep_water_clean
	name = "river"
	icon_state = "deep_water_clean"
//shallow water coast
/turf/unsimulated/floor/desertdam/river/clean/shallow_water_desert_coast
	name = "river"
	icon_state = "shallow_water_desert_coast1"
//desert floor waterway
/turf/unsimulated/floor/desertdam/river/clean/shallow_water_desert_waterway
	name = "river"
	icon_state = "desert_waterway1"
//shallow water cave coast
/turf/unsimulated/floor/desertdam/river/clean/shallow_water_cave_coast
	name = "river"
	icon_state = "shallow_water_cave_coast1"
//cave floor waterway
/turf/unsimulated/floor/desertdam/river/clean/shallow_water_cave_waterway
	name = "river"
	icon_state = "shallow_water_cave_waterway1"

//TOXIC
/turf/unsimulated/floor/desertdam/river/toxic
	icon_state = "shallow_water_toxic"

//shallow water
/turf/unsimulated/floor/desertdam/river/toxic/shallow_water_toxic
	name = "river"
	icon_state = "shallow_water_toxic"
//shallow water transition to deep
/turf/unsimulated/floor/desertdam/river/toxic/shallow_edge_toxic
	name = "river"
	icon_state = "shallow_to_deep_toxic_water1"
//deep water
/turf/unsimulated/floor/desertdam/river/toxic/deep_water_toxic
	name = "river"
	icon_state = "deep_water_toxic"
//shallow water coast
/turf/unsimulated/floor/desertdam/river/toxic/shallow_water_desert_coast_toxic
	name = "river"
	icon_state = "shallow_water_desert_coast_toxic1"
//desert floor waterway
/turf/unsimulated/floor/desertdam/river/toxic/shallow_water_desert_waterway_toxic
	name = "river"
	icon_state = "desert_waterway_toxic1"
//shallow water cave coast
/turf/unsimulated/floor/desertdam/river/toxic/shallow_water_cave_coast_toxic
	name = "river"
	icon_state = "shallow_water_cave_coast_toxic1"
//cave floor waterway
/turf/unsimulated/floor/desertdam/river/toxic/shallow_water_cave_waterway_toxic
	name = "river"
	icon_state = "shallow_water_cave_waterway_toxic1"

//Wall
//rock walls
/turf/unsimulated/wall/desertdam/desertdamrockwall
    name = "rockwall"
    icon = 'icons/turf/desertdam_map.dmi'
    icon_state = "cavewall1"


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

//GRASS
/obj/structure/desertdam/decals/grass
	icon_state = "heavygrass_1"
/obj/structure/desertdam/decals/grass/lightgrass
	name = "grass"
	icon_state = "lightgrass_1"
/obj/structure/desertdam/decals/grass/heavygrass
	name = "grass"
	icon_state = "heavygrass_1"

//CACTUS
/obj/structure/desertdam/decals/cactus
	icon_state = "cactus_1"
/obj/structure/desertdam/decals/cactus/cactus
	name = "cactus"
	icon_state = "cactus_1"
/obj/structure/desertdam/decals/cactus/cacti
	name = "cacti"
	icon_state = "cacti_1"
//road decal
/obj/structure/desertdam/decals/road_edge
	name = "road"
	icon_state = "road_edge_decal1"
/obj/structure/desertdam/decals/road_stop
	name = "road"
	icon_state = "stop_decal1"
<<<<<<< HEAD

//TODO:
//Relocate me somewhere that makes more sense!
/obj/structure/chigusa_sign
	name = "Chigusa Sign"
	desc = "A large sign reading 'lazarus landing por-' the rest of it is smeared in blood."
	icon = 'icons/obj/landing_signs.dmi'
	icon_state = "laz_sign"
	bound_width = 64
	bound_height = 64
	density = 1
=======
>>>>>>> 7917b9f6115020ea0ebb1ceab85fdc7740187561
