//used for holding information about unique properties of maps
//feed it json files that match the datum layout
//defaults to box
//  -Cyberboss

/datum/map_config
	// Metadata
	var/config_filename = "_maps/vapor_processing.json"
	var/defaulted = TRUE  // set to FALSE by LoadConfig() succeeding
	// Config from maps.txt
	var/config_max_users = 0
	var/config_min_users = 0
	var/voteweight = 1

	// Config actually from the JSON - default values
	var/map_name = "Vapor Processing"
	var/map_path = "map_files/Vapor_Processing"
	var/map_file = "Vapor_Processing.dmm"

	var/traits = null
	var/space_empty_levels = 1
	var/list/environment_traits = list()
	///Which disk sets this map has, key-value = name - weight for choosing.
	var/list/disk_sets = list()
	var/armor_style = "default"
	var/quickbuilds = 1000
	var/list/gamemodes = list()

	var/allow_custom_shuttles = TRUE
	var/shuttles = list()

	var/announce_text = ""

	var/squads_max_num = 4


/proc/load_map_config(filename, default, delete_after, error_if_missing = TRUE)
	var/datum/map_config/config = new
	if(default)
		return config
	if(!config.LoadConfig(filename, error_if_missing))
		qdel(config)
		config = new /datum/map_config
	if(delete_after)
		fdel(filename)
	return config


/proc/load_map_configs(list/maptypes, default, delete_after, error_if_missing = TRUE)
	var/list/configs = list()

	for(var/i in maptypes)
		var/filename = MAP_TO_FILENAME[i]
		var/datum/map_config/config = new
		if(default)
			configs[i] = config
			continue
		if(!config.LoadConfig(filename, error_if_missing, i, TRUE))
			qdel(config)
			config = new /datum/map_config
		if(delete_after)
			fdel(filename)
		configs[i] = config
	return configs

#define CHECK_EXISTS(X) if(!istext(json[X])) { log_world("[##X] missing from json!"); return; }
/datum/map_config/proc/LoadConfig(filename, error_if_missing, maptype, load_default)
	if(!fexists(filename))
		if(error_if_missing)
			log_world("map_config not found: [filename]")
		if(!load_default)
			return
		switch(maptype)
			if(GROUND_MAP)
				return LoadConfig("_maps/vapor_processing.json", error_if_missing, maptype)
			if(SHIP_MAP)
				return LoadConfig("_maps/debugdalus.json", error_if_missing, maptype)

	var/json = file(filename)
	if(!json)
		log_world("Could not open map_config: [filename]")
		return

	json = file2text(json)
	if(!json)
		log_world("map_config is not text: [filename]")
		return

	json = json_decode(json)
	if(!json)
		log_world("map_config is not json: [filename]")
		return

	config_filename = filename

	CHECK_EXISTS("map_name")
	map_name = json["map_name"]
	CHECK_EXISTS("map_path")
	map_path = json["map_path"]
	announce_text = json["announce_text"]

	map_file = json["map_file"]
	// "map_file": "BoxStation.dmm"
	if (istext(map_file))
		if (!fexists("_maps/[map_path]/[map_file]"))
			log_world("Map file ([map_file]) does not exist!")
			return
	// "map_file": ["Lower.dmm", "Upper.dmm"]
	else if (islist(map_file))
		for (var/file in map_file)
			if (!fexists("_maps/[map_path]/[file]"))
				log_world("Map file ([file]) does not exist!")
				return
	else
		log_world("map_file missing from json!")
		return

	if (islist(json["shuttles"]))
		var/list/L = json["shuttles"]
		for(var/key in L)
			var/value = L[key]
			shuttles[key] = value
	else if ("shuttles" in json)
		log_world("map_config shuttles is not a list!")
		return

	traits = json["traits"]
	if (islist(traits))
		// "Ground" is set by default, but it's assumed if you're setting
		// traits you want to customize which level is cross-linked
		// we only set ground if not mainship
		for (var/level in traits)
			if (!(ZTRAIT_GROUND in level) && !(ZTRAIT_MARINE_MAIN_SHIP in level))
				level[ZTRAIT_GROUND] = TRUE
	// "traits": null or absent -> default
	else if (!isnull(traits))
		log_world("map_config traits is not a list!")
		return

	var/temp = json["space_empty_levels"]
	if (isnum(temp))
		space_empty_levels = temp
	else if (!isnull(temp))
		log_world("map_config space_empty_levels is not a number!")
		return

	temp = json["squads"]
	if(isnum(temp))
		squads_max_num = temp
	else if(!isnull(temp))
		log_world("map_config squads_max_num is not a number!")
		return

	allow_custom_shuttles = json["allow_custom_shuttles"] != FALSE

	if(json["armor"])
		armor_style = json["armor"]

	if(json["quickbuilds"])
		quickbuilds = json["quickbuilds"]

	if(islist(json["disk_sets"]))
		disk_sets = json["disk_sets"]
	else if(!isnull(json["disk_sets"]))
		log_world("map_config disk sets are not a list!")
		return

	if(islist(json["environment_traits"]))
		environment_traits = json["environment_traits"]
	else if(!isnull(json["environment_traits"]))
		log_world("map_config environment_traits is not a list!")
		return

	var/list/gamemode_names = list()
	for(var/t in subtypesof(/datum/game_mode))
		var/datum/game_mode/G = t
		if(initial(G.config_tag))
			gamemode_names += initial(G.config_tag)

	if(islist(json["gamemodes"]))
		for(var/g in json["gamemodes"])
			if(!(g in gamemode_names))
				log_world("map_config has an invalid gamemode name!")
				return
			gamemodes += g
	else if(!isnull(json["gamemodes"]))
		log_world("map_config gamemodes is not a list!")
		return
	else
		for(var/a in subtypesof(/datum/game_mode))
			var/datum/game_mode/G = a
			if(initial(G.config_tag))
				gamemodes += initial(G.config_tag)

	defaulted = FALSE
	return TRUE
#undef CHECK_EXISTS

/datum/map_config/proc/GetFullMapPaths()
	if (istext(map_file))
		return list("_maps/[map_path]/[map_file]")
	. = list()
	for (var/file in map_file)
		. += "_maps/[map_path]/[file]"


/datum/map_config/proc/MakeNextMap(maptype = GROUND_MAP)
	if(maptype == GROUND_MAP)
		return config_filename == "data/next_map.json" || fcopy(config_filename, "data/next_map.json")
	else if(maptype == SHIP_MAP)
		return config_filename == "data/next_ship.json" || fcopy(config_filename, "data/next_ship.json")
