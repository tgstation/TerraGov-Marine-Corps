SUBSYSTEM_DEF(mapping)
	name = "Mapping"
	init_order = INIT_ORDER_MAPPING
	flags = SS_NO_FIRE

	var/list/datum/map_config/configs
	var/list/datum/map_config/next_map_configs

	var/list/map_templates = list()

	var/list/shuttle_templates = list()
	var/list/minidropship_templates = list()

	///list of all modular mapping templates
	var/list/modular_templates = list()

	var/list/areas_in_z = list()

	var/list/turf/unused_turfs = list()				//Not actually unused turfs they're unused but reserved for use for whatever requests them. "[zlevel_of_turf]" = list(turfs)
	var/list/datum/turf_reservations		//list of turf reservations
	var/list/used_turfs = list()				//list of turf = datum/turf_reservation

	var/list/reservation_ready = list()
	var/clearing_reserved_turfs = FALSE

	// Z-manager stuff
	var/ground_start  // should only be used for maploading-related tasks
	var/list/z_list
	var/datum/space_level/transit
	var/num_of_res_levels = 1

	///If true, non-admin players will not be able to initiate a vote to change groundmap
	var/groundmap_voted = FALSE
	///If true, non-admin players will not be able to initiate a vote to change shipmap
	var/shipmap_voted = FALSE
	///The number of connected clients for the previous round
	var/last_round_player_count

	///shows the gravity value for each z level
	var/list/gravity_by_z_level = list()

//dlete dis once #39770 is resolved
/datum/controller/subsystem/mapping/proc/HACK_LoadMapConfig()
	if(!configs)
		configs = load_map_configs(ALL_MAPTYPES, error_if_missing = FALSE)
		for(var/i in GLOB.clients)
			var/client/C = i
			winset(C, null, "mainwindow.title='[CONFIG_GET(string/title)] - [SSmapping.configs[SHIP_MAP].map_name]'")

/datum/controller/subsystem/mapping/Initialize()
	HACK_LoadMapConfig()
	if(initialized)
		return SS_INIT_SUCCESS

	for(var/i in ALL_MAPTYPES)
		var/datum/map_config/MC = configs[i]
		if(MC.defaulted)
			var/old_config = configs[i]
			configs[i] = global.config.defaultmaps[i]
			if(!configs || configs[i].defaulted)
				to_chat(world, span_boldannounce("Unable to load next or default map config, defaulting."))
				configs[i] = old_config

	if(configs[GROUND_MAP])
		for(var/datum/game_mode/M AS in config.votable_modes)
			if(!(M.config_tag in configs[GROUND_MAP].gamemodes))
				config.votable_modes -= M // remove invalid modes

	loadWorld()
	repopulate_sorted_areas()
	load_last_round_playercount()
	preloadTemplates()
	// Add the transit level
	transit = add_new_zlevel("Transit/Reserved", list(ZTRAIT_RESERVED = TRUE))
	repopulate_sorted_areas()
	initialize_reserved_level(transit.z_value)
	calculate_default_z_level_gravities()
	return SS_INIT_SUCCESS

//Loads the number of players we had last round, for use in modular mapping
/datum/controller/subsystem/mapping/proc/load_last_round_playercount()
	var/json_file = file("data/last_round_player_count.json")
	if(!fexists(json_file))
		return
	last_round_player_count = json_decode(file2text(json_file))

/datum/controller/subsystem/mapping/proc/wipe_reservations(wipe_safety_delay = 100)
	if(clearing_reserved_turfs || !initialized)			//in either case this is just not needed.
		return
	clearing_reserved_turfs = TRUE
	SSshuttle.transit_requesters.Cut()
	message_admins("Clearing dynamic reservation space.")
	var/list/obj/docking_port/mobile/in_transit = list()
	for(var/i in SSshuttle.transit)
		var/obj/docking_port/stationary/transit/T = i
		if(!istype(T))
			continue
		in_transit[T] = T.get_docked()
	var/go_ahead = world.time + wipe_safety_delay
	if(length(in_transit))
		message_admins("Shuttles in transit detected. Attempting to fast travel. Timeout is [wipe_safety_delay/10] seconds.")
	var/list/cleared = list()
	for(var/i in in_transit)
		INVOKE_ASYNC(src, PROC_REF(safety_clear_transit_dock), i, in_transit[i], cleared)
	UNTIL((go_ahead < world.time) || (length(cleared) == length(in_transit)))
	do_wipe_turf_reservations()
	clearing_reserved_turfs = FALSE

/datum/controller/subsystem/mapping/proc/safety_clear_transit_dock(obj/docking_port/stationary/transit/T, obj/docking_port/mobile/M, list/returning)
	M.setTimer(0)
	var/error = M.initiate_docking(M.destination, M.preferred_direction)
	if(!error)
		returning += M
		qdel(T, TRUE)

/datum/controller/subsystem/mapping/Recover()
	flags |= SS_NO_INIT
	initialized = SSmapping.initialized
	map_templates = SSmapping.map_templates
	minidropship_templates = SSmapping.minidropship_templates
	shuttle_templates = SSmapping.shuttle_templates
	modular_templates = SSmapping.modular_templates
	unused_turfs = SSmapping.unused_turfs
	turf_reservations = SSmapping.turf_reservations
	used_turfs = SSmapping.used_turfs
	transit = SSmapping.transit
	areas_in_z = SSmapping.areas_in_z

	configs = SSmapping.configs
	next_map_configs = SSmapping.next_map_configs

	clearing_reserved_turfs = SSmapping.clearing_reserved_turfs

	z_list = SSmapping.z_list

#define INIT_ANNOUNCE(X) to_chat(world, span_notice("[X]")); log_world(X)
/datum/controller/subsystem/mapping/proc/LoadGroup(list/errorList, name, path, files, list/traits, list/default_traits, silent = FALSE)
	. = list()
	var/start_time = REALTIMEOFDAY

	if (!islist(files))  // handle single-level maps
		files = list(files)
	// check that the total z count of all maps matches the list of traits
	var/total_z = 0
	var/list/parsed_maps = list()
	for (var/file in files)
		var/full_path = "_maps/[path]/[file]"
		var/datum/parsed_map/pm = new(file(full_path))
		var/bounds = pm?.bounds
		if (!bounds)
			errorList |= full_path
			continue
		parsed_maps[pm] = total_z  // save the start Z of this file
		total_z += bounds[MAP_MAXZ] - bounds[MAP_MINZ] + 1
	if (!length(traits))  // null or empty - default
		for (var/i in 1 to total_z)
			traits += list(default_traits)
	else if (total_z != length(traits))  // mismatch
		INIT_ANNOUNCE("WARNING: [length(traits)] trait sets specified for [total_z] z-levels in [path]!")
		if (total_z < length(traits))  // ignore extra traits
			traits.Cut(total_z + 1)
		while (total_z > length(traits))  // fall back to defaults on extra levels
			traits += list(default_traits)
	// preload the relevant space_level datums
	var/start_z = world.maxz + 1
	var/i = 0
	for (var/level in traits)
		add_new_zlevel("[name][i ? " [i + 1]" : ""]", level)
		++i

	// load the maps
	for (var/P in parsed_maps)
		var/datum/parsed_map/pm = P
		if (!pm.load(1, 1, start_z + parsed_maps[P], no_changeturf = TRUE))
			errorList |= pm.original_path
	if(!silent)
		INIT_ANNOUNCE("Loaded [name] in [(REALTIMEOFDAY - start_time)/10]s!")
	return parsed_maps

/datum/controller/subsystem/mapping/proc/loadWorld()
	//if any of these fail, something has gone horribly, HORRIBLY, wrong
	var/list/FailedZs = list()

	// ensure we have space_level datums for compiled-in maps
	InitializeDefaultZLevels()

	// load the ground level
	ground_start = world.maxz + 1

	var/datum/map_config/ground_map = configs[GROUND_MAP]
	INIT_ANNOUNCE("Loading [ground_map.map_name]...")
	LoadGroup(FailedZs, ground_map.map_name, ground_map.map_path, ground_map.map_file, ground_map.traits, ZTRAITS_GROUND)

	var/datum/map_config/ship_map = configs[SHIP_MAP]
	INIT_ANNOUNCE("Loading [ship_map.map_name]...")
	LoadGroup(FailedZs, ship_map.map_name, ship_map.map_path, ship_map.map_file, ship_map.traits, ZTRAITS_MAIN_SHIP)

	if(SSdbcore.Connect())
		var/datum/db_query/query_round_map_name = SSdbcore.NewQuery({"
			UPDATE [format_table_name("round")] SET map_name = :map_name WHERE id = :round_id
		"}, list("map_name" = ground_map.map_name, "round_id" = GLOB.round_id))
		query_round_map_name.Execute()
		qdel(query_round_map_name)

	// Also saving this as a feedback var as we don't have ship_name in the round table.
	SSblackbox.record_feedback("text", "ground_map", 1, ground_map.map_name)
	SSblackbox.record_feedback("text", "ship_map", 1, ship_map.map_name)

	if(LAZYLEN(FailedZs))	//but seriously, unless the server's filesystem is messed up this will never happen
		var/msg = "RED ALERT! The following map files failed to load: [FailedZs[1]]"
		if(length(FailedZs) > 1)
			for(var/I in 2 to length(FailedZs))
				msg += ", [FailedZs[I]]"
		msg += ". Yell at your server host!"
		INIT_ANNOUNCE(msg)
#undef INIT_ANNOUNCE

/datum/controller/subsystem/mapping/proc/changemap(datum/map_config/VM, maptype = GROUND_MAP)
	LAZYINITLIST(next_map_configs)
	if(maptype == GROUND_MAP)
		if(!VM.MakeNextMap(maptype))
			next_map_configs[GROUND_MAP] = load_map_configs(list(maptype), default = TRUE)
			message_admins("Failed to set new map with next_map.json for [VM.map_name]! Using default as backup!")
			return

		next_map_configs[GROUND_MAP] = VM
		return TRUE

	else if(maptype == SHIP_MAP)
		if(!VM.MakeNextMap(maptype))
			next_map_configs[SHIP_MAP] = load_map_configs(list(maptype), default = TRUE)
			message_admins("Failed to set new map with next_map.json for [VM.map_name]! Using default as backup!")
			return

		next_map_configs[SHIP_MAP] = VM
		return TRUE

/datum/controller/subsystem/mapping/proc/preloadTemplates(path = "_maps/templates/") //see master controller setup
	var/list/filelist = flist(path)
	for(var/map in filelist)
		var/datum/map_template/T = new(path = "[path][map]", rename = "[map]")
		map_templates[T.name] = T

	preloadShuttleTemplates()
	preloadModularTemplates()

/proc/generateMapList(filename)
	. = list()
	var/list/Lines = file2list(filename)

	if(!length(Lines))
		return
	for (var/t in Lines)
		if (!t)
			continue

		t = trim(t)
		if (length(t) == 0)
			continue
		else if (t[1] == "#")
			continue

		var/pos = findtext(t, " ")
		var/name = null

		if (pos)
			name = lowertext(copytext(t, 1, pos))

		else
			name = lowertext(t)

		if (!name)
			continue

		. += t

/datum/controller/subsystem/mapping/proc/preloadShuttleTemplates()
	var/list/unbuyable = generateMapList("[global.config.directory]/unbuyableshuttles.txt")

	for(var/item in subtypesof(/datum/map_template/shuttle))
		var/datum/map_template/shuttle/shuttle_type = item

		var/datum/map_template/shuttle/S = new shuttle_type()
		if(unbuyable.Find(S.mappath))
			S.can_be_bought = FALSE

		shuttle_templates[S.shuttle_id] = S
		map_templates[S.shuttle_id] = S

	for(var/drop_path in typesof(/datum/map_template/shuttle/minidropship))
		var/datum/map_template/shuttle/drop = new drop_path()
		minidropship_templates += drop

/datum/controller/subsystem/mapping/proc/preloadModularTemplates()
	for(var/item in subtypesof(/datum/map_template/modular))
		var/datum/map_template/modular/modular_type = item

		var/datum/map_template/modular/M = new modular_type()

		LAZYINITLIST(modular_templates[M.modular_id])
		if(M.min_player_num == null || M.max_player_num == null) //maps without an assigned max or min player count are always added to the modular map list
			modular_templates[M.modular_id] += M
		else if (last_round_player_count >= M.min_player_num && last_round_player_count <= M.max_player_num) //if we exceed the minimum or maximum players numbers for a modular map don't add it to our list of valid modules that can be loaded
			modular_templates[M.modular_id] += M
		map_templates[M.type] = M

/datum/controller/subsystem/mapping/proc/RequestBlockReservation(width, height, z, type = /datum/turf_reservation, turf_type_override)
	UNTIL(initialized && !clearing_reserved_turfs)
	var/datum/turf_reservation/reserve = new type
	if(turf_type_override)
		reserve.turf_type = turf_type_override
	if(!z)
		for(var/i in levels_by_trait(ZTRAIT_RESERVED))
			if(reserve.Reserve(width, height, i))
				return reserve
		//If we didn't return at this point, theres a good chance we ran out of room on the exisiting reserved z levels, so lets try a new one
		num_of_res_levels += 1
		var/datum/space_level/newReserved = add_new_zlevel("Transit/Reserved [num_of_res_levels]", list(ZTRAIT_RESERVED = TRUE))
		initialize_reserved_level(newReserved.z_value)
		for(var/i in levels_by_trait(ZTRAIT_RESERVED))
			if(reserve.Reserve(width, height, i))
				return reserve
		CRASH("Despite adding a fresh reserved zlevel still failed to get a reservation")
	else
		if(!level_trait(z, ZTRAIT_RESERVED))
			qdel(reserve)
			return
		else
			if(reserve.Reserve(width, height, z))
				return reserve
	QDEL_NULL(reserve)

//This is not for wiping reserved levels, use wipe_reservations() for that.
/datum/controller/subsystem/mapping/proc/initialize_reserved_level(z)
	UNTIL(!clearing_reserved_turfs)				//regardless, lets add a check just in case.
	clearing_reserved_turfs = TRUE			//This operation will likely clear any existing reservations, so lets make sure nothing tries to make one while we're doing it.
	if(!level_trait(z,ZTRAIT_RESERVED))
		clearing_reserved_turfs = FALSE
		CRASH("Invalid z level prepared for reservations.")
	var/turf/A = get_turf(locate(SHUTTLE_TRANSIT_BORDER,SHUTTLE_TRANSIT_BORDER,z))
	var/turf/B = get_turf(locate(world.maxx - SHUTTLE_TRANSIT_BORDER,world.maxy - SHUTTLE_TRANSIT_BORDER,z))
	var/block = block(A, B)
	for(var/t in block)
		// No need to empty() these, because it's world init and they're
		// already /turf/open/space/basic.
		var/turf/T = t
		T.flags_atom |= UNUSED_RESERVATION_TURF_1
	unused_turfs["[z]"] = block
	reservation_ready["[z]"] = TRUE
	clearing_reserved_turfs = FALSE

/datum/controller/subsystem/mapping/proc/reserve_turfs(list/turfs)
	for(var/i in turfs)
		var/turf/T = i
		T.empty(RESERVED_TURF_TYPE, RESERVED_TURF_TYPE, null, TRUE)
		LAZYINITLIST(unused_turfs["[T.z]"])
		unused_turfs["[T.z]"] |= T
		T.flags_atom |= UNUSED_RESERVATION_TURF_1
		GLOB.areas_by_type[world.area].contents += T
		CHECK_TICK

//DO NOT CALL THIS PROC DIRECTLY, CALL wipe_reservations().
/datum/controller/subsystem/mapping/proc/do_wipe_turf_reservations()
	UNTIL(initialized)							//This proc is for AFTER init, before init turf reservations won't even exist and using this will likely break things.
	for(var/i in turf_reservations)
		var/datum/turf_reservation/TR = i
		if(!QDELETED(TR))
			qdel(TR, TRUE)
	UNSETEMPTY(turf_reservations)
	var/list/clearing = list()
	for(var/l in unused_turfs)			//unused_turfs is a assoc list by z = list(turfs)
		if(islist(unused_turfs[l]))
			clearing |= unused_turfs[l]
	clearing |= used_turfs		//used turfs is an associative list, BUT, reserve_turfs() can still handle it. If the code above works properly, this won't even be needed as the turfs would be freed already.
	unused_turfs.Cut()
	used_turfs.Cut()
	reserve_turfs(clearing)

/datum/controller/subsystem/mapping/proc/reg_in_areas_in_z(list/areas)
	for(var/area/new_area AS in areas)
		new_area.reg_in_areas_in_z()

///Generates baseline gravity levels for all z-levels based off traits
/datum/controller/subsystem/mapping/proc/calculate_default_z_level_gravities()
	for(var/z_level in 1 to length(z_list))
		calculate_z_level_gravity(z_level)

///Calculates the gravity for a z-level
/datum/controller/subsystem/mapping/proc/calculate_z_level_gravity(z_level_number)
	if(!isnum(z_level_number) || z_level_number < 1)
		return FALSE

	var/max_gravity = 1 //we default to standard grav

	max_gravity = level_trait(z_level_number, ZTRAIT_GRAVITY) ? level_trait(z_level_number, ZTRAIT_GRAVITY) : 1

	gravity_by_z_level["[z_level_number]"] = max_gravity
	return max_gravity
