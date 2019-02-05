SUBSYSTEM_DEF(mapping)
	name = "Mapping"
	init_order = INIT_ORDER_MAPPING
	flags = SS_NO_FIRE

	var/list/nuke_tiles = list()
	var/list/nuke_threats = list()

	var/datum/map_config/config
	var/datum/map_config/next_map_config

	var/list/map_templates = list()

	var/list/shuttle_templates = list()
	var/list/shelter_templates = list()

	var/list/areas_in_z = list()

	var/loading_ruins = FALSE
	var/list/turf/unused_turfs = list()				//Not actually unused turfs they're unused but reserved for use for whatever requests them. "[zlevel_of_turf]" = list(turfs)
	var/list/datum/turf_reservations		//list of turf reservations
	var/list/used_turfs = list()				//list of turf = datum/turf_reservation

	var/clearing_reserved_turfs = FALSE

	// Z-manager stuff
	var/ground_start  // should only be used for maploading-related tasks
	var/space_levels_so_far = 0
	var/list/z_list
	var/datum/space_level/transit
	var/datum/space_level/empty_space
	var/num_of_res_levels = 1

//dlete dis once #39770 is resolved
/datum/controller/subsystem/mapping/proc/HACK_LoadMapConfig()
	if(!config)
#ifdef FORCE_MAP
		config = load_map_config(FORCE_MAP)
#else
		config = load_map_config(error_if_missing = FALSE)
#endif

/datum/controller/subsystem/mapping/Initialize(timeofday)
	HACK_LoadMapConfig()
	if(initialized)
		return
	if(config.defaulted)
		var/old_config = config
		config = global.config.defaultmap
		if(!config || config.defaulted)
			to_chat(world, "<span class='boldannounce'>Unable to load next or default map config, defaulting to LV624</span>")
			config = old_config
	loadWorld()
	//repopulate_sorted_areas() // we dont have glob.sortedareas yet
	//process_teleport_locs()			//Sets up the wizard teleport locations
	preloadTemplates()
#ifndef LOWMEMORYMODE
	// Create space ruin levels
	while (space_levels_so_far < config.space_ruin_levels)
		++space_levels_so_far
		add_new_zlevel("Empty Area [space_levels_so_far]", ZTRAITS_SPACE)
	// and one level with no ruins
	for (var/i in 1 to config.space_empty_levels)
		++space_levels_so_far
		empty_space = add_new_zlevel("Empty Area [space_levels_so_far]", list(ZTRAIT_LINKAGE = CROSSLINKED))
	// and the transit level
	transit = add_new_zlevel("Transit/Reserved", list(ZTRAIT_RESERVED = TRUE))

	// Pick a random away mission.
	//if(CONFIG_GET(flag/roundstart_away))
	//	createRandomZlevel()


	// Generate mining ruins
	//loading_ruins = TRUE
	//var/list/lava_ruins = levels_by_trait(ZTRAIT_LAVA_RUINS)
	//if (lava_ruins.len)
	//	seedRuins(lava_ruins, CONFIG_GET(number/lavaland_budget), /area/lavaland/surface/outdoors/unexplored, lava_ruins_templates)
	//	for (var/lava_z in lava_ruins)
	//		spawn_rivers(lava_z)

	// Generate deep space ruins
	//var/list/space_ruins = levels_by_trait(ZTRAIT_SPACE_RUINS)
	//if (space_ruins.len)
	//	seedRuins(space_ruins, CONFIG_GET(number/space_budget), /area/space, space_ruins_templates)
	//loading_ruins = FALSE
#endif
	//repopulate_sorted_areas()
	// Set up Z-level transitions.
	//setup_map_transitions()
	generate_station_area_list()
	//initialize_reserved_level()
	return ..()

/datum/controller/subsystem/mapping/Recover()
	flags |= SS_NO_INIT
	initialized = SSmapping.initialized
	map_templates = SSmapping.map_templates
	shuttle_templates = SSmapping.shuttle_templates
	shelter_templates = SSmapping.shelter_templates
	unused_turfs = SSmapping.unused_turfs
	turf_reservations = SSmapping.turf_reservations
	used_turfs = SSmapping.used_turfs

	config = SSmapping.config
	next_map_config = SSmapping.next_map_config

	clearing_reserved_turfs = SSmapping.clearing_reserved_turfs

	z_list = SSmapping.z_list

#define INIT_ANNOUNCE(X) to_chat(world, "<span class='boldannounce'>[X]</span>"); log_world(X)
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
	else if (total_z != traits.len)  // mismatch
		INIT_ANNOUNCE("WARNING: [traits.len] trait sets specified for [total_z] z-levels in [path]!")
		if (total_z < traits.len)  // ignore extra traits
			traits.Cut(total_z + 1)
		while (total_z > traits.len)  // fall back to defaults on extra levels
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
	INIT_ANNOUNCE("Loading [config.map_name]...")
	LoadGroup(FailedZs, "Ground", config.map_path, config.map_file, config.traits, ZTRAITS_GROUND)

	var/datum/map_config/theseus = new
	theseus.LoadConfig("_maps/theseus.json")

	INIT_ANNOUNCE("Loading [MAIN_SHIP_NAME]...")
	LoadGroup(FailedZs, MAIN_SHIP_NAME, theseus.map_path, theseus.map_file, theseus.traits, ZTRAITS_MAIN_SHIP)

	var/datum/map_config/low_orbit = new
	low_orbit.LoadConfig("_maps/low_orbit.json")

	INIT_ANNOUNCE("Loading Low Orbit...")
	LoadGroup(FailedZs, "Low Orbit", low_orbit.map_path, low_orbit.map_file, low_orbit.traits, ZTRAITS_LOW_ORBIT)


//	if(SSdbcore.Connect())
//		var/datum/DBQuery/query_round_map_name = SSdbcore.NewQuery("UPDATE [format_table_name("round")] SET map_name = '[config.map_name]' WHERE id = [GLOB.round_id]")
//		query_round_map_name.Execute()
//		qdel(query_round_map_name)

#ifndef LOWMEMORYMODE
	// TODO: remove this when the DB is prepared for the z-levels getting reordered
	//while (world.maxz < (5 - 1) && space_levels_so_far < config.space_ruin_levels)
	//	++space_levels_so_far
	//	add_new_zlevel("Empty Area [space_levels_so_far]", ZTRAITS_SPACE)

	// load mining
//	if(config.minetype == "lavaland")
//		LoadGroup(FailedZs, "Lavaland", "map_files/Mining", "Lavaland.dmm", default_traits = ZTRAITS_LAVALAND)
//	else if (!isnull(config.minetype))
//		INIT_ANNOUNCE("WARNING: An unknown minetype '[config.minetype]' was set! This is being ignored! Update the maploader code!")
#endif

	if(LAZYLEN(FailedZs))	//but seriously, unless the server's filesystem is messed up this will never happen
		var/msg = "RED ALERT! The following map files failed to load: [FailedZs[1]]"
		if(FailedZs.len > 1)
			for(var/I in 2 to FailedZs.len)
				msg += ", [FailedZs[I]]"
		msg += ". Yell at your server host!"
		INIT_ANNOUNCE(msg)
#undef INIT_ANNOUNCE

GLOBAL_LIST_EMPTY(the_station_areas)

/datum/controller/subsystem/mapping/proc/generate_station_area_list()
	var/list/station_areas_blacklist = typecacheof(list(/area/space, /area/mine))
	for(var/area/A in world)
		var/turf/picked = safepick(get_area_turfs(A.type))
		if(picked && is_station_level(picked.z))
			if(!(A.type in GLOB.the_station_areas) && !is_type_in_typecache(A, station_areas_blacklist))
				GLOB.the_station_areas.Add(A.type)

	if(!GLOB.the_station_areas.len)
		log_world("ERROR: Station areas list failed to generate!")

/datum/controller/subsystem/mapping/proc/maprotate()
/*	var/players = clients.len
	var/list/mapvotes = list()
	//count votes
	var/amv = TRUE
	var/amv = CONFIG_GET(flag/allow_map_voting)
	if(amv)
		for (var/client/c in clients)
			var/vote = c.prefs.preferred_map
			if (!vote)
				if (global.config.defaultmap)
					mapvotes[global.config.defaultmap.map_name] += 1
				continue
			mapvotes[vote] += 1
	else
		for(var/M in global.config.maplist)
			mapvotes[M] = 1

	//filter votes
	for (var/map in mapvotes)
		if (!map)
			mapvotes.Remove(map)
		if (!(map in global.config.maplist))
			mapvotes.Remove(map)
			continue
		var/datum/map_config/VM = global.config.maplist[map]
		if (!VM)
			mapvotes.Remove(map)
			continue
		if (VM.voteweight <= 0)
			mapvotes.Remove(map)
			continue
		if (VM.config_min_users > 0 && players < VM.config_min_users)
			mapvotes.Remove(map)
			continue
		if (VM.config_max_users > 0 && players > VM.config_max_users)
			mapvotes.Remove(map)
			continue

		if(amv)
			mapvotes[map] = mapvotes[map]*VM.voteweight

	var/pickedmap = pickweight(mapvotes)
	if (!pickedmap)
		return
	var/datum/map_config/VM = global.config.maplist[pickedmap]
	message_admins("Randomly rotating map to [VM.map_name]")
	. = changemap(VM)
	if (. && VM.map_name != config.map_name)
		to_chat(world, "<span class='boldannounce'>Map rotation has chosen [VM.map_name] for next round!</span>")
*/
/datum/controller/subsystem/mapping/proc/changemap(var/datum/map_config/VM)
	if(!VM.MakeNextMap())
		next_map_config = load_map_config(default_to_box = TRUE)
		message_admins("Failed to set new map with next_map.json for [VM.map_name]! Using default as backup!")
		return

	next_map_config = VM
	return TRUE

/datum/controller/subsystem/mapping/proc/preloadTemplates(path = "_maps/templates/") //see master controller setup
	var/list/filelist = flist(path)
	for(var/map in filelist)
		var/datum/map_template/T = new(path = "[path][map]", rename = "[map]")
		map_templates[T.name] = T

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
		var/newReserved = add_new_zlevel("Transit/Reserved [num_of_res_levels]", list(ZTRAIT_RESERVED = TRUE))
		if(reserve.Reserve(width, height, newReserved))
			return reserve
	else
		if(!level_trait(z, ZTRAIT_RESERVED))
			qdel(reserve)
			return
		else
			if(reserve.Reserve(width, height, z))
				return reserve
	QDEL_NULL(reserve)
