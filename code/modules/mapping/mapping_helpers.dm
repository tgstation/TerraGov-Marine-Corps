//Landmarks and other helpers which speed up the mapping process and reduce the number of unique instances/subtypes of items/turf/ect


/obj/effect/baseturf_helper //Set the baseturfs of every turf in the /area/ it is placed.
	name = "baseturf editor"
	icon = 'icons/effects/mapping_helpers.dmi'
	icon_state = ""
	plane = POINT_PLANE
	var/list/baseturf_to_replace
	var/baseturf


/obj/effect/baseturf_helper/Initialize(mapload)
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
		if(!length(baseturf_cache))
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

/obj/effect/mapping_helpers/Initialize(mapload)
	. = ..()
	return late ? INITIALIZE_HINT_LATELOAD : INITIALIZE_HINT_QDEL


//airlock helpers
/obj/effect/mapping_helpers/airlock
	layer = DOOR_HELPER_LAYER

/obj/effect/mapping_helpers/airlock/locked
	name = "airlock lock helper"
	icon_state = "airlock_locked_helper"

/obj/effect/mapping_helpers/airlock/locked/Initialize(mapload)
	. = ..()
	if(!mapload)
		log_world("### MAP WARNING, [src] spawned outside of mapload!")
		return
	var/obj/machinery/door/airlock/airlock = locate(/obj/machinery/door/airlock) in loc
	if(!airlock)
		CRASH("### MAP WARNING, [src] failed to find an airlock at [AREACOORD(src)]")
	if(airlock.locked)
		stack_trace("### MAP WARNING, [src] at [AREACOORD(src)] tried to bolt [airlock] but it's already locked!")
	airlock.locked = TRUE
	var/turf/current_turf = get_turf(airlock)
	current_turf.atom_flags |= AI_BLOCKED

/obj/effect/mapping_helpers/airlock/free_access
	name = "airlock free access helper"
	icon_state = "airlock_free_access"

/obj/effect/mapping_helpers/airlock/free_access/Initialize(mapload)
	. = ..()
	if(!mapload)
		log_world("### MAP WARNING, [src] spawned outside of mapload!")
		return
	var/obj/machinery/door/airlock/airlock = locate(/obj/machinery/door/airlock) in loc
	if(!airlock)
		CRASH("### MAP WARNING, [src] failed to find an airlock at [AREACOORD(src)]")
	airlock.req_access = null
	airlock.req_one_access = null

/obj/effect/mapping_helpers/airlock/abandoned
	name = "airlock abandoned helper"
	icon_state = "airlock_abandoned_helper"

/obj/effect/mapping_helpers/airlock/abandoned/Initialize(mapload)
	. = ..()
	if(!mapload)
		log_world("### MAP WARNING, [src] spawned outside of mapload!")
		return
	var/obj/machinery/door/airlock/airlock = locate(/obj/machinery/door/airlock) in loc
	if(!airlock)
		CRASH("### MAP WARNING, [src] failed to find an airlock at [AREACOORD(src)]")
	if(airlock.abandoned)
		stack_trace("### MAP WARNING, [src] at [AREACOORD(src)] tried to make [airlock] abandoned but it's already abandoned!")
	airlock.abandoned = TRUE
	var/turf/current_turf = get_turf(airlock)
	current_turf.atom_flags |= AI_BLOCKED

/obj/effect/mapping_helpers/airlock/welded
	name = "airlock welded helper"
	icon_state = "airlock_welded_helper"

/obj/effect/mapping_helpers/airlock/welded/Initialize(mapload)
	. = ..()
	if(!mapload)
		log_world("### MAP WARNING, [src] spawned outside of mapload!")
		return
	var/obj/machinery/door/airlock/airlock = locate(/obj/machinery/door/airlock) in loc
	if(!airlock)
		CRASH("### MAP WARNING, [src] failed to find an airlock at [AREACOORD(src)]")
	if(airlock.welded)
		stack_trace("### MAP WARNING, [src] at [AREACOORD(src)] tried to bolt [airlock] but it's already welded!")
	airlock.welded = TRUE
	var/turf/current_turf = get_turf(airlock)
	current_turf.atom_flags |= AI_BLOCKED

/obj/effect/mapping_helpers/broken_apc
	name = "broken apc helper"
	icon_state = "airlock_brokenapc_helper"
	///chance that we actually break the APC
	var/breakchance = 100

/obj/effect/mapping_helpers/broken_apc/Initialize(mapload)
	. = ..()
	if(!mapload)
		log_world("### MAP WARNING, [src] spawned outside of mapload!")
		return
	if(!prob(breakchance))
		return
	var/obj/machinery/power/apc/apc = locate(/obj/machinery/power/apc) in loc
	if(!apc)
		CRASH("### MAP WARNING, [src] failed to find an apc at [AREACOORD(src)]")
	if(apc.machine_stat && (BROKEN)) //there's a small chance of APCs being broken on round start, just return if it's already happened
		return
	apc.do_break()

/obj/effect/mapping_helpers/apc_unlocked
	name = "apc unlocked interface helper"
	icon_state = "apc_unlocked_interface_helper"

/obj/effect/mapping_helpers/apc_unlocked/Initialize(mapload)
	. = ..()
	var/obj/machinery/power/apc/apc = locate(/obj/machinery/power/apc) in loc
	if(!apc)
		CRASH("### MAP WARNING, [src] failed to find an apc at [AREACOORD(src)]")
	if(!apc.coverlocked || !apc.locked)
		var/area/apc_area = get_area(apc)
		log_mapping("[src] at [AREACOORD(src)] [(apc_area.type)] tried to unlock the [apc] but it's already unlocked!")
	apc.coverlocked = FALSE
	apc.locked = FALSE

/obj/effect/mapping_helpers/broken_apc/lowchance
	breakchance = 25

/obj/effect/mapping_helpers/broken_apc/highchance
	breakchance = 75

/obj/effect/mapping_helpers/airlock_autoname
	name = "airlock autoname helper"
	icon_state = "airlock_autoname_helper"

/obj/effect/mapping_helpers/airlock/hackProof
	name = "airlock block ai control helper"
	icon_state = "hackproof"

/obj/effect/mapping_helpers/airlock/hackProof/Initialize(mapload)
	. = ..()
	var/obj/machinery/door/airlock/airlock = locate(/obj/machinery/door/airlock) in loc
	if(!airlock)
		CRASH("### MAP WARNING, [src] failed to find an airlock at [AREACOORD(src)]")
	if(airlock.aiControlDisabled)
		log_mapping("[src] at [AREACOORD(src)] tried to make [airlock] hackproof but it's already hackproof!")
	else
		airlock.hackProof = TRUE

/obj/effect/mapping_helpers/airlock_autoname/Initialize(mapload)
	. = ..()
	if(!mapload)
		log_world("### MAP WARNING, [src] spawned outside of mapload!")
		return
	var/obj/machinery/door/door = locate(/obj/machinery/door) in loc
	if(!door)
		CRASH("### MAP WARNING, [src] failed to find a nameable door at [AREACOORD(src)]")
	door.name = get_area_name(door)

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
	area.area_flags |= flag_type

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

/obj/effect/mapping_helpers/area_flag_injector/no_construction
	flag_type = NO_CONSTRUCTION

/obj/effect/mapping_helpers/simple_pipes
	name = "Simple Pipes"
	late = TRUE
	icon_state = "pipe-3"
	var/piping_layer = 3
	var/pipe_color = ""
	var/connection_num = 0
	var/hide = FALSE
	/// Tracking variable to prevent duplicate runtime messages
	var/crashed = FALSE

/obj/effect/mapping_helpers/simple_pipes/LateInitialize()
	var/list/connections = list( dir2text(NORTH) = FALSE, dir2text(SOUTH) = FALSE , dir2text(EAST) = FALSE , dir2text(WEST) = FALSE)
	var/list/valid_connectors = typecacheof(/obj/machinery/atmospherics)

	// Check for duplicate helpers on a single turf
	var/turf/self_turf = get_turf(src)
	for(var/obj/effect/mapping_helpers/simple_pipes/helper in self_turf.contents)
		if(helper == src)
			continue
		if(helper.piping_layer != src.piping_layer)
			continue
		if(helper.crashed)
			return
		helper.crashed = TRUE
		crashed = TRUE
		CRASH("Duplicate simple_pipes mapping helper at [AREACOORD(src)]")

	for(var/direction in connections)
		var/turf/T = get_step(src, text2dir(direction))
		for(var/machine_type in T.contents)
			if(istype(machine_type, type))
				var/obj/effect/mapping_helpers/simple_pipes/found = machine_type
				if(found.piping_layer != piping_layer)
					continue
				connections[direction] = TRUE
				connection_num++
				break
			if(!is_type_in_typecache(machine_type, valid_connectors))
				continue
			var/obj/machinery/atmospherics/machine = machine_type

			if(machine.piping_layer != piping_layer)
				continue

			if(angle2dir(dir2angle(text2dir(direction)) + 180) & machine.initialize_directions)
				connections[direction] = TRUE
				connection_num++
				break

	switch(connection_num)
		if(1)
			for(var/direction in connections)
				if(connections[direction] != TRUE)
					continue
				spawn_pipe(direction, /obj/machinery/atmospherics/pipe/simple)
				break
		if(2)
			for(var/direction in connections)
				if(connections[direction] != TRUE)
					continue

				//Detects straight pipes connected from east to west , north to south etc.
				if(connections[dir2text(angle2dir(dir2angle(text2dir(direction)) + 180))] == TRUE)
					spawn_pipe(direction, /obj/machinery/atmospherics/pipe/simple)
					break

				//Detects curved pipes, finds the second connection and spawns a pipe, then removes the direction from the list to prevent duplciates
				for(var/direction2 in connections - direction)
					if(connections[direction2] != TRUE)
						continue
					spawn_pipe(dir2text(text2dir(direction) + text2dir(direction2)), /obj/machinery/atmospherics/pipe/simple)
					connections -= direction2
					break
		if(3)
			for(var/direction in connections)
				if(connections[direction] == FALSE)
					spawn_pipe(direction, /obj/machinery/atmospherics/pipe/manifold)
					break
		if(4)
			spawn_pipe(dir2text(NORTH), /obj/machinery/atmospherics/pipe/manifold4w)

	qdel(src)

/obj/effect/mapping_helpers/light
	name = "generic placeholder for light map helpers, do not place in game"
	layer = DOOR_HELPER_LAYER

/obj/effect/mapping_helpers/light/broken
	name = "light broken map helper"
	icon_state = "light_flicker_broken"

/obj/effect/mapping_helpers/light/broken/Initialize(mapload)
	. = ..()
	var/obj/machinery/light/light = locate(/obj/machinery/light) in loc
	if(!light)
		CRASH("### MAP WARNING, [src] failed to find an light at [AREACOORD(src)]")
	if(light.status == LIGHT_BROKEN) //already broken, go home
		return
	if(light.status == LIGHT_EMPTY)
		log_mapping("[src] at [AREACOORD(src)] tried to make [light] broken, but it couldn't be done!")
		return

	light.broken()

/obj/effect/mapping_helpers/light/turnedoff
	name = "light area turnoff helper"
	icon_state = "light_flicker_area_off"

/obj/effect/mapping_helpers/light/turnedoff/Initialize(mapload)
	. = ..()
	var/area/area = get_area(src)

	area.lightswitch = area.lightswitch ? FALSE : TRUE
	area.update_icon()

/obj/effect/mapping_helpers/light/flickering
	name = "light flickering helper"
	icon_state = "light_flicker"

/obj/effect/mapping_helpers/light/flickering/Initialize(mapload)
	. = ..()
	var/obj/machinery/light/light = locate(/obj/machinery/light) in loc
	if(!light)
		CRASH("### MAP WARNING, [src] failed to find an light at [AREACOORD(src)]")
	if(light.flickering || light.status != LIGHT_OK)
		log_mapping("[src] at [AREACOORD(src)] tried to make [light] flicker, but it couldn't be done!")
	else
		light.lightambient = new(null, FALSE)
		light.flicker(TRUE)

///enable random flickering on lights, to make this effect happen the light has be flickering in the first place
/obj/effect/mapping_helpers/light/flickering/enable_random_flickering
	name = "light enable random flicker timing helper"
	icon_state = "light_flicker_random"

/obj/effect/mapping_helpers/light/flickering/enable_random_flickering/Initialize(mapload)
	. = ..()
	var/obj/machinery/light/light = locate(/obj/machinery/light) in loc
	if(!light)
		CRASH("### MAP WARNING, [src] failed to find an light at [AREACOORD(src)]")
	if(light.random_flicker || light.status != LIGHT_OK)
		log_mapping("[src] at [AREACOORD(src)] tried to make [light] randomly flicker, but it couldn't be done!")
	else
		light.random_flicker = TRUE

/obj/effect/mapping_helpers/light/flickering/flicker_random_settings
	name = "light random flicker settings helper"
	icon_state = "light_flicker_random_settings"
	var/flicker_time_upper_max = 10 SECONDS
	var/flicker_time_lower_min = 0.2 SECONDS

/obj/effect/mapping_helpers/light/flickering/flicker_random_settings/Initialize(mapload)
	. = ..()
	var/obj/machinery/light/light = locate(/obj/machinery/light) in loc
	if(!light)
		CRASH("### MAP WARNING, [src] failed to find an light at [AREACOORD(src)]")
	if(flicker_time_lower_min > flicker_time_upper_max)
		CRASH("Invalid random flicker setting for light at [AREACOORD(src)]")
	light.flicker_time_upper_max = flicker_time_upper_max
	light.flicker_time_lower_min = flicker_time_lower_min

/obj/effect/mapping_helpers/light/flickering/flicker_random_settings/lowset
	flicker_time_upper_max = 3 SECONDS
	flicker_time_lower_min = 0.4 SECONDS

/obj/effect/mapping_helpers/light/flickering/flicker_random_settings/highset
	flicker_time_upper_max = 6 SECONDS
	flicker_time_lower_min = 3 SECONDS

/obj/effect/mapping_helpers/light/power
	name = "light power helper"
	icon_state = "light_flicker_power"
	var/lighting_power = 1

/obj/effect/mapping_helpers/light/power/Initialize(mapload)
	. = ..()
	var/obj/machinery/light/light = locate(/obj/machinery/light) in loc
	if(!light)
		CRASH("### MAP WARNING, [src] failed to find an light at [AREACOORD(src)]")
	light.bulb_power = lighting_power
	light.update()

/obj/effect/mapping_helpers/light/power/dim
	lighting_power = 0.5

/obj/effect/mapping_helpers/light/power/bright
	lighting_power = 2.0

/obj/effect/mapping_helpers/light/color
	name = "light color mapping helper"
	icon_state = "light_flicker_color"
	var/lighting_color = LIGHT_COLOR_WHITE

/obj/effect/mapping_helpers/light/color/Initialize(mapload)
	. = ..()
	var/obj/machinery/light/light = locate(/obj/machinery/light) in loc
	if(!light)
		CRASH("### MAP WARNING, [src] failed to find an light at [AREACOORD(src)]")
	light.light_color = lighting_color
	light.update()

/obj/effect/mapping_helpers/light/color/red
	light_color = LIGHT_COLOR_RED

/obj/effect/mapping_helpers/light/color/blue
	light_color = LIGHT_COLOR_ORANGE

/obj/effect/mapping_helpers/light/bulb_colour
	name = "light bulb color helper"
	icon_state = "light_flicker_color_bulb"
	var/bulb_colour = LIGHT_COLOR_WHITE

/obj/effect/mapping_helpers/light/bulb_colour/Initialize(mapload)
	. = ..()
	var/obj/machinery/light/light = locate(/obj/machinery/light) in loc
	if(!light)
		CRASH("### MAP WARNING, [src] failed to find an light at [AREACOORD(src)]")
	light.bulb_colour = bulb_colour
	light.update()

/obj/effect/mapping_helpers/light/bulb_colour/red
	bulb_colour = LIGHT_COLOR_RED

/obj/effect/mapping_helpers/light/bulb_colour/blue
	bulb_colour = LIGHT_COLOR_BLUE

/obj/effect/mapping_helpers/light/brightness
	name = "light brightness mapping helper"
	icon_state = "light_flicker_brightness"
	var/brightness_intensity = 4

/obj/effect/mapping_helpers/light/brightness/Initialize(mapload)
	. = ..()
	var/obj/machinery/light/light = locate(/obj/machinery/light) in loc
	if(!light)
		CRASH("### MAP WARNING, [src] failed to find an light at [AREACOORD(src)]")
	light.brightness = brightness_intensity
	light.update()

/obj/effect/mapping_helpers/light/brightness/dim
	brightness_intensity = 3

/obj/effect/mapping_helpers/light/brightness/bright
	brightness_intensity = 6

/// spawn the pipe
/obj/effect/mapping_helpers/simple_pipes/proc/spawn_pipe(direction, type)
	var/obj/machinery/atmospherics/pipe/pipe = new type(get_turf(src), TRUE, text2dir(direction))
	pipe.level = level
	pipe.piping_layer = piping_layer
	pipe.update_layer()
	pipe.paint(pipe_color)

/obj/effect/mapping_helpers/airlock/unres
	name = "airlock unrestricted side helper"
	icon_state = "airlock_unres_helper"

/obj/effect/mapping_helpers/airlock/unres/Initialize(mapload)
	. = ..()
	var/obj/machinery/door/airlock/airlock = locate(/obj/machinery/door/airlock) in loc
	if(!airlock)
		CRASH("### MAP WARNING, [src] failed to find an airlock at [AREACOORD(src)]")
	airlock.unres_sides ^= dir

/obj/effect/mapping_helpers/airlock/cyclelink_helper
	name = "airlock cyclelink helper"
	icon_state = "airlock_cyclelink_helper"

/obj/effect/mapping_helpers/airlock/cyclelink_helper/Initialize(mapload)
	. = ..()
	var/obj/machinery/door/airlock/airlock = locate(/obj/machinery/door/airlock) in loc
	if(!airlock)
		log_world("### MAP WARNING, [src] failed to find an airlock at [AREACOORD(src)]")
	if(airlock.cyclelinkeddir)
		log_world("### MAP WARNING, [src] at [AREACOORD(src)] tried to set [airlock] cyclelinkeddir, but it's already set!")
	else
		airlock.cyclelinkeddir = dir

/obj/effect/mapping_helpers/barricade
	name = "base barricade helper"

/obj/effect/mapping_helpers/barricade/wired
	name = "wired barricade helper"
	icon_state = "barricade_wired"

/obj/effect/mapping_helpers/barricade/wired/Initialize(mapload)
	. = ..()
	if(!mapload)
		log_world("### MAP WARNING, [src] spawned outside of mapload!")
		return
	var/obj/structure/barricade/foundbarricade = locate(/obj/structure/barricade) in loc
	if(!foundbarricade)
		CRASH("### MAP WARNING, [src] failed to find a barricade at [AREACOORD(src)]")
	if(foundbarricade.is_wired || !foundbarricade.can_wire)
		stack_trace("### MAP WARNING, [src] at [AREACOORD(src)] tried to make [foundbarricade] wired but it's already wired!")
	foundbarricade.wire()

/obj/effect/mapping_helpers/barricade/bomb
	name = "bomb armor barricade helper"
	icon_state = "barricade_bomb"

/obj/effect/mapping_helpers/barricade/bomb/Initialize(mapload)
	. = ..()
	if(!mapload)
		log_world("### MAP WARNING, [src] spawned outside of mapload!")
		return
	var/obj/structure/barricade/solid/foundbarricade = locate(/obj/structure/barricade/solid) in loc
	if(!foundbarricade)
		CRASH("### MAP WARNING, [src] failed to find a barricade at [AREACOORD(src)]")
	if(foundbarricade.barricade_upgrade_type)
		stack_trace("### MAP WARNING, [src] at [AREACOORD(src)] tried to upgrade [foundbarricade] but it already has armor!")
	foundbarricade.soft_armor = soft_armor.modifyRating(bomb = 50)
	foundbarricade.barricade_upgrade_type = CADE_TYPE_BOMB
	foundbarricade.update_icon()

/obj/effect/mapping_helpers/barricade/acid
	name = "acid armor barricade helper"
	icon_state = "barricade_acid"

/obj/effect/mapping_helpers/barricade/acid/Initialize(mapload)
	. = ..()
	if(!mapload)
		log_world("### MAP WARNING, [src] spawned outside of mapload!")
		return
	var/obj/structure/barricade/solid/foundbarricade = locate(/obj/structure/barricade/solid) in loc
	if(!foundbarricade)
		CRASH("### MAP WARNING, [src] failed to find a barricade at [AREACOORD(src)]")
	if(foundbarricade.barricade_upgrade_type)
		stack_trace("### MAP WARNING, [src] at [AREACOORD(src)] tried to upgrade [foundbarricade] but it already has armor!")
	foundbarricade.barricade_upgrade_type = CADE_TYPE_ACID
	foundbarricade.soft_armor = soft_armor.modifyRating(acid = 20)
	foundbarricade.resistance_flags |= UNACIDABLE
	foundbarricade.update_icon()

/obj/effect/mapping_helpers/barricade/melee
	name = "melee armor barricade helper"
	icon_state = "barricade_melee"

/obj/effect/mapping_helpers/barricade/melee/Initialize(mapload)
	. = ..()
	if(!mapload)
		log_world("### MAP WARNING, [src] spawned outside of mapload!")
		return
	var/obj/structure/barricade/solid/foundbarricade = locate(/obj/structure/barricade/solid) in loc
	if(!foundbarricade)
		CRASH("### MAP WARNING, [src] failed to find a barricade at [AREACOORD(src)]")
	if(foundbarricade.barricade_upgrade_type)
		stack_trace("### MAP WARNING, [src] at [AREACOORD(src)] tried to upgrade [foundbarricade] but it already has armor!")
	foundbarricade.barricade_upgrade_type = CADE_TYPE_MELEE
	foundbarricade.soft_armor = soft_armor.modifyRating(melee = 30, bullet = 30, laser = 30, energy = 30)
	foundbarricade.update_icon()

/obj/effect/mapping_helpers/barricade/closed
	name = "closed plasteel barricade helper"
	icon_state = "barricade_closed"

/obj/effect/mapping_helpers/barricade/closed/Initialize(mapload)
	. = ..()
	if(!mapload)
		log_world("### MAP WARNING, [src] spawned outside of mapload!")
		return
	var/obj/structure/barricade/folding/foundbarricade = locate(/obj/structure/barricade/folding) in loc
	if(!foundbarricade)
		CRASH("### MAP WARNING, [src] failed to find a plasteel barricade at [AREACOORD(src)]")
	if(!foundbarricade.closed)
		stack_trace("### MAP WARNING, [src] at [AREACOORD(src)] tried to open [foundbarricade] but it's already open!")
	foundbarricade.toggle_open()

/obj/effect/mapping_helpers/weld_vents
	name = "vents welded helper"
	icon_state = "airlock_welded_helper"
	///probability we weld the vent
	var/weld_chance = 100

/obj/effect/mapping_helpers/weld_vents/Initialize(mapload)
	. = ..()
	if(!mapload)
		log_world("### MAP WARNING, [src] spawned outside of mapload!")
		return
	var/obj/machinery/atmospherics/components/unary/vent_pump/foundvent = locate(/obj/machinery/atmospherics/components/unary/vent_pump) in loc
	var/obj/machinery/atmospherics/components/unary/vent_scrubber/foundscrubber = locate(/obj/machinery/atmospherics/components/unary/vent_scrubber) in loc
	if(!foundvent && !foundscrubber)
		CRASH("### MAP WARNING, [src] failed to find a plasteel barricade at [AREACOORD(src)]")
	if(foundvent && foundvent.welded)
		stack_trace("### MAP WARNING, [src] at [AREACOORD(src)] tried to weld [foundvent] but it's already welded!")
	else if(foundvent && prob(weld_chance))
		foundvent.welded = TRUE
	if(foundscrubber && foundscrubber.welded)
		stack_trace("### MAP WARNING, [src] at [AREACOORD(src)] tried to weld [foundscrubber] but it's already welded!")
	else if(foundscrubber && prob(weld_chance))
		foundscrubber.welded = TRUE

/obj/effect/mapping_helpers/weld_vents/fiftyfifty
	weld_chance = 50

/obj/effect/mapping_helpers/weld_vents/lowchance
	weld_chance = 15

//needs to do its thing before spawn_rivers() is called
/*
INITIALIZE_IMMEDIATE(/obj/effect/mapping_helpers/no_lava)

/obj/effect/mapping_helpers/no_lava
	icon_state = "no_lava"

/obj/effect/mapping_helpers/no_lava/Initialize(mapload)
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
