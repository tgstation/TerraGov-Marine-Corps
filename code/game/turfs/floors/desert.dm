//Desert Map

/turf/open/desert //Basic groundmap turf parent
	name = "desert dirt"
	icon = 'icons/turf/floors/desert.dmi'
	icon_state = "desert1"
	is_groundmap_turf = TRUE

/turf/open/desert/ex_act(severity) //Should make it indestructable
	return

/turf/open/desert/fire_act(exposed_temperature, exposed_volume)
	return

/turf/open/desert/attackby() //This should fix everything else. No cables, etc
	return

//desert floor
/turf/open/desert/desert
	name = "desert"
	icon_state = "desert1"

//Desert shore
/turf/open/desert/desert_shore
	name = "shore"
	icon = 'icons/turf/desert_water_toxic.dmi'
	icon_state = "shore"

/turf/open/desert/desert_shore/shore_edge
	icon_state = "shore"
/turf/open/desert/desert_shore/shore_corner
	icon_state = "shore_c"

//Desert Waterway
/turf/open/desert/waterway
	icon = 'icons/turf/desert_water.dmi'
	icon_state = "dock"
/turf/open/desert/waterway/desert_waterway
	icon = 'icons/turf/desert_water.dmi'
	icon_state = "dock"
/turf/open/desert/waterway/desert_waterway_c
	icon = 'icons/turf/desert_water.dmi'
	icon_state = "dock_c"
/turf/open/desert/waterway/desert_waterway_cave
	icon = 'icons/turf/desert_water.dmi'
	icon_state = "dock_caves"
/turf/open/desert/waterway/desert_waterway_cave_c
	icon = 'icons/turf/desert_water.dmi'
	icon_state = "dock_caves_c"


//Desert Cave
/turf/open/desert/cave
	icon_state = "outer_cave_floor1"
//desert floor to outer cave floor transition
/turf/open/desert/cave/desert_into_outer_cave_floor
	name = "cave"
	icon_state = "outer_cave_transition1"
//outer cave floor
/turf/open/desert/cave/outer_cave_floor
	name = "cave"
	icon_state = "outer_cave_floor1"
//outer to inner cave floor transition
/turf/open/desert/cave/outer_cave_to_inner_cave
	name = "cave"
	icon_state = "outer_cave_to_inner1"
//inner cave floor
/turf/open/desert/cave/inner_cave_floor
	name = "cave"
	icon_state = "inner_cave_1"
//inner cave shore
/turf/open/desert/cave/cave_shore
	name = "cave shore"
	icon = 'icons/turf/desert_water_toxic.dmi'
	icon_state = "shore_caves"

//Desert River Toxic
/turf/open/desert/river
	name = "toxic river"
	icon = 'icons/turf/desert_water_toxic.dmi'
	icon_state = "shallow"
	var/toxic = 1

/turf/open/desert/river/update_icon()
	..()
	if(toxic)
		icon = 'icons/turf/desert_water_toxic.dmi'
	else
		icon = 'icons/turf/desert_water.dmi'

//shallow water
/turf/open/desert/river/shallow
	icon_state = "shallow"
//shallow water transition to deep
/turf/open/desert/river/shallow_edge
	icon_state = "shallow_edge"
//shallow water transition to deep corner
/turf/open/desert/river/shallow_corner
	icon_state = "shallow_c"
//deep water
/turf/open/desert/river/deep
	name = "river"
	icon_state = "deep"
//shallow water channel plain
/turf/open/desert/river/channel
	name = "river"
	icon_state = "channel"
//shallow water channel edge
/turf/open/desert/river/channel_edge
	name = "river"
	icon_state = "channel_edge"
//shallow water channel corner
/turf/open/desert/river/channel_three
	name = "river"
	icon_state = "channel_three"


