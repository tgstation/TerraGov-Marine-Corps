//Landmarks and other helpers which speed up the mapping process and reduce the number of unique instances/subtypes of items/turf/ect



/obj/effect/baseturf_helper //Set the baseturfs of every turf in the /area/ it is placed.
	name = "baseturf editor"
	icon = 'icons/effects/mapping_helpers.dmi'
	icon_state = ""

	var/list/baseturf_to_replace
	var/baseturf

	layer = POINT_LAYER

/obj/effect/baseturf_helper/Initialize()
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/effect/baseturf_helper/LateInitialize()
	if(!baseturf_to_replace)
		baseturf_to_replace = typecacheof(/turf/open/space)
	else if(!length(baseturf_to_replace))
		baseturf_to_replace = list(baseturf_to_replace = TRUE)
	else if(baseturf_to_replace[baseturf_to_replace[1]] != TRUE) // It's not associative
		var/list/formatted = list()
		for(var/i in baseturf_to_replace)
			formatted[i] = TRUE
		baseturf_to_replace = formatted

	var/area/our_area = get_area(src)
	for(var/i in get_area_turfs(our_area, z))
		replace_baseturf(i)

	qdel(src)

/obj/effect/baseturf_helper/proc/replace_baseturf(turf/thing)
	var/list/baseturf_cache = thing.baseturfs
	if(length(baseturf_cache))
		for(var/i in baseturf_cache)
			if(baseturf_to_replace[i])
				baseturf_cache -= i
		if(!baseturf_cache.len)
			thing.assemble_baseturfs(baseturf)
		else
			thing.PlaceOnBottom(null, baseturf)
	else if(baseturf_to_replace[thing.baseturfs])
		thing.assemble_baseturfs(baseturf)
	else
		thing.PlaceOnBottom(null, baseturf)



/obj/effect/baseturf_helper/space
	name = "space baseturf editor"
	baseturf = /turf/open/space
/*
/obj/effect/baseturf_helper/asteroid
	name = "asteroid baseturf editor"
	baseturf = /turf/open/floor/plating/asteroid

/obj/effect/baseturf_helper/asteroid/airless
	name = "asteroid airless baseturf editor"
	baseturf = /turf/open/floor/plating/asteroid/airless

/obj/effect/baseturf_helper/asteroid/basalt
	name = "asteroid basalt baseturf editor"
	baseturf = /turf/open/floor/plating/asteroid/basalt

/obj/effect/baseturf_helper/asteroid/snow
	name = "asteroid snow baseturf editor"
	baseturf = /turf/open/floor/plating/asteroid/snow

/obj/effect/baseturf_helper/beach/sand
	name = "beach sand baseturf editor"
	baseturf = /turf/open/floor/plating/beach/sand

/obj/effect/baseturf_helper/beach/water
	name = "water baseturf editor"
	baseturf = /turf/open/floor/plating/beach/water

/obj/effect/baseturf_helper/lava
	name = "lava baseturf editor"
	baseturf = /turf/open/lava/smooth

/obj/effect/baseturf_helper/lava_land/surface
	name = "lavaland baseturf editor"
	baseturf = /turf/open/lava/smooth/lava_land_surface
*/

/obj/effect/mapping_helpers
	icon = 'icons/effects/mapping_helpers.dmi'
	icon_state = ""
	var/late = FALSE

/obj/effect/mapping_helpers/Initialize()
	. = ..()
	return late ? INITIALIZE_HINT_LATELOAD : INITIALIZE_HINT_QDEL


//airlock helpers
/obj/effect/mapping_helpers/airlock
	layer = DOOR_HELPER_LAYER

/obj/effect/mapping_helpers/airlock/cyclelink_helper
	name = "airlock cyclelink helper"
	icon_state = "airlock_cyclelink_helper"

/obj/effect/mapping_helpers/airlock/cyclelink_helper/Initialize(mapload)
	. = ..()
	if(!mapload)
		log_world("### MAP WARNING, [src] spawned outside of mapload!")
		return
	//var/obj/machinery/door/airlock/airlock = locate(/obj/machinery/door/airlock) in loc
	//if(airlock)
	//	if(airlock.cyclelinkeddir)
	//		log_world("### MAP WARNING, [src] at [AREACOORD(src)] tried to set [airlock] cyclelinkeddir, but it's already set!")
	//	else
	//		airlock.cyclelinkeddir = dir
	//else
		//log_world("### MAP WARNING, [src] failed to find an airlock at [AREACOORD(src)]")


/obj/effect/mapping_helpers/airlock/locked
	name = "airlock lock helper"
	icon_state = "airlock_locked_helper"

/obj/effect/mapping_helpers/airlock/locked/Initialize(mapload)
	. = ..()
	if(!mapload)
		log_world("### MAP WARNING, [src] spawned outside of mapload!")
		return
	var/obj/machinery/door/airlock/airlock = locate(/obj/machinery/door/airlock) in loc
	if(airlock)
		if(airlock.locked)
			log_world("### MAP WARNING, [src] at [AREACOORD(src)] tried to bolt [airlock] but it's already locked!")
		else
			airlock.locked = TRUE
			var/turf/current_turf = get_turf(airlock)
			current_turf.flags_atom |= AI_BLOCKED
	else
		log_world("### MAP WARNING, [src] failed to find an airlock at [AREACOORD(src)]")

/obj/effect/mapping_helpers/airlock/unres
	name = "airlock unresctricted side helper"
	icon_state = "airlock_unres_helper"

/obj/effect/mapping_helpers/airlock/unres/Initialize(mapload)
	. = ..()
	if(!mapload)
		log_world("### MAP WARNING, [src] spawned outside of mapload!")
		return

/obj/effect/mapping_helpers/area_flag_injector
	name = "Area flag Injector"
	icon_state = "area_flag_injector"
	/// flags to inject to the area this is placed in
	var/flag_type = NONE

/obj/effect/mapping_helpers/area_flag_injector/Initialize(mapload)
	. = ..()
	var/area/area = get_area(src)
	area.flags_area |= flag_type

/obj/effect/mapping_helpers/area_flag_injector/marine_base
	flag_type = MARINE_BASE

/obj/effect/mapping_helpers/area_flag_injector/no_weeding
	flag_type = DISALLOW_WEEDING

/obj/effect/mapping_helpers/area_flag_injector/ob_immune
	flag_type = OB_CAS_IMMUNE

/obj/effect/mapping_helpers/area_flag_injector/droppod_immune
	flag_type = NO_DROPPOD

/obj/effect/mapping_helpers/area_flag_injector/near_fob
	flag_type = NEAR_FOB


/obj/effect/mapping_helpers/simple_pipes
	name = "Simple Pipes"
	late = TRUE
	icon_state = "pipe-3"
	var/piping_layer = 3
	var/pipe_color = ""
	var/connection_num = 0
	var/hide = FALSE

/obj/effect/mapping_helpers/simple_pipes/LateInitialize()
	var/list/connections = list( dir2text(NORTH)  = FALSE, dir2text(SOUTH) = FALSE , dir2text(EAST) = FALSE , dir2text(WEST) = FALSE)
	var/list/valid_connectors = typecacheof(/obj/machinery/atmospherics)
	for(var/direction in connections)
		var/turf/T = get_step(src,  text2dir(direction))
		for(var/machine_type in T.contents)
			if(istype(machine_type,type))
				var/obj/effect/mapping_helpers/simple_pipes/found = machine_type
				if(found.piping_layer != piping_layer)
					continue
				connections[direction] = TRUE
				connection_num++
				break
			if(!is_type_in_typecache(machine_type,valid_connectors))
				continue
			var/obj/machinery/atmospherics/machine = machine_type

			if(machine.piping_layer != piping_layer)
				continue

			if(angle2dir(dir2angle(text2dir(direction))+180) & machine.initialize_directions)
				connections[direction] = TRUE
				connection_num++
				break

	switch(connection_num)
		if(1)
			for(var/direction in connections)
				if(connections[direction] != TRUE)
					continue
				spawn_pipe(direction,/obj/machinery/atmospherics/pipe/simple)
		if(2)
			for(var/direction in connections)
				if(connections[direction] != TRUE)
					continue
				//Detects straight pipes connected from east to west , north to south etc.
				if(connections[dir2text(angle2dir(dir2angle(text2dir(direction))+180))] == TRUE)
					spawn_pipe(direction,/obj/machinery/atmospherics/pipe/simple)
					break

				for(var/direction2 in connections - direction)
					if(connections[direction2] != TRUE)
						continue
					spawn_pipe(dir2text(text2dir(direction)+text2dir(direction2)),/obj/machinery/atmospherics/pipe/simple)
		if(3)
			for(var/direction in connections)
				if(connections[direction] == FALSE)
					spawn_pipe(direction,/obj/machinery/atmospherics/pipe/manifold)
		if(4)
			spawn_pipe(dir2text(NORTH),/obj/machinery/atmospherics/pipe/manifold4w)

	qdel(src)

//spawn pipe
/obj/effect/mapping_helpers/simple_pipes/proc/spawn_pipe(direction,type )
	var/obj/machinery/atmospherics/pipe/pipe = new type(get_turf(src),TRUE,text2dir(direction))
	pipe.level = level
	pipe.piping_layer = piping_layer
	pipe.update_layer()
	pipe.paint(pipe_color)

//	var/obj/machinery/door/airlock/airlock = locate(/obj/machinery/door/airlock) in loc
//	if(airlock)
//		airlock.unres_sides ^= dir
//	else
//		log_world("### MAP WARNING, [src] failed to find an airlock at [AREACOORD(src)]")


//needs to do its thing before spawn_rivers() is called
/*
INITIALIZE_IMMEDIATE(/obj/effect/mapping_helpers/no_lava)

/obj/effect/mapping_helpers/no_lava
	icon_state = "no_lava"

/obj/effect/mapping_helpers/no_lava/Initialize()
	. = ..()
	var/turf/T = get_turf(src)
	T.flags_1 |= NO_LAVA_GEN_1
*/

/*
//This helper applies components to things on the map directly.
/obj/effect/mapping_helpers/component_injector
	name = "Component Injector"
	late = TRUE
	var/target_type
	var/target_name
	var/component_type

//Late init so everything is likely ready and loaded (no warranty)
/obj/effect/mapping_helpers/component_injector/LateInitialize()
	if(!ispath(component_type,/datum/component))
		CRASH("Wrong component type in [type] - [component_type] is not a component")
	var/turf/T = get_turf(src)
	for(var/atom/A in T.GetAllContents())
		if(A == src)
			continue
		if(target_name && A.name != target_name)
			continue
		if(target_type && !istype(A,target_type))
			continue
		var/cargs = build_args()
		A.AddComponent(arglist(cargs))
		qdel(src)
		return

/obj/effect/mapping_helpers/component_injector/proc/build_args()
	return list(component_type)

/obj/effect/mapping_helpers/component_injector/infective
	name = "Infective Injector"
	icon_state = "component_infective"
	component_type = /datum/component/infective
	var/disease_type

/obj/effect/mapping_helpers/component_injector/infective/build_args()
	if(!ispath(disease_type,/datum/disease))
		CRASH("Wrong disease type passed in.")
	var/datum/disease/D = new disease_type()
	return list(component_type,D)
	*/
