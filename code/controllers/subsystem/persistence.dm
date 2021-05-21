#define FILE_RECENT_MAPS "data/RecentMaps.json"

#define KEEP_ROUNDS_MAP 3

#define LAST_UPDATE "last_update" //last time the season changed
#define CURRENT_SEASON "current_season" //current season of the section

#define SEASONAL_GUNS "seasonal_guns"

SUBSYSTEM_DEF(persistence)
	name = "Persistence"
	init_order = INIT_ORDER_PERSISTENCE
	flags = SS_NO_FIRE

	var/list/saved_modes = list(1,2,3)
	var/list/saved_maps = list()

	///Stores how long each season should last
	var/list/item_seasons_durations = list(
		SEASONAL_GUNS = 1 DAYS,
	)
	///Stores the current season for each season item group
	var/list/item_season_progress = list()

	///Available guns seasons
	var/list/gun_buckets = list(
		/datum/seasonal_items/weapons/guns/sadar_bucket,
		/datum/seasonal_items/weapons/guns/wp_bucket,
		)

/datum/controller/subsystem/persistence/Initialize()
	LoadPoly()
	LoadRecentModes()
	LoadSeasonalItems()
	return ..()

/datum/controller/subsystem/persistence/proc/LoadPoly()
	for(var/mob/living/simple_animal/parrot/Poly/P in GLOB.mob_list)
		twitterize(P.speech_buffer, "polytalk")
		break //Who's been duping the bird?!

/datum/controller/subsystem/persistence/proc/LoadRecentModes()
	var/json_file = file("data/recent_modes.json")
	if(!fexists(json_file))
		return
	var/list/json = json_decode(file2text(json_file))
	if(!json)
		return
	saved_modes = json["data"]

/datum/controller/subsystem/persistence/proc/CollectData()
	CollectRoundtype()

/datum/controller/subsystem/persistence/proc/CollectRoundtype()
	saved_modes[3] = saved_modes[2]
	saved_modes[2] = saved_modes[1]
	saved_modes[1] = SSticker.mode.config_tag
	var/json_file = file("data/recent_modes.json")
	var/list/file_data = list()
	file_data["data"] = saved_modes
	fdel(json_file)
	WRITE_FILE(json_file, json_encode(file_data))

///Loads seasons data, advances seasons and saves the data
/datum/controller/subsystem/persistence/proc/LoadSeasonalItems()
	var/json_file = file("data/seasonal_items.json")
	if(!fexists(json_file))
		initialize_seasonal_items_file()
	var/list/json = json_decode(file2text(json_file))

	for(var/season_section in item_seasons_durations)
		if(!json[season_section][LAST_UPDATE])
			json[season_section][LAST_UPDATE] = world.realtime
			json[season_section][CURRENT_SEASON] = 1
			continue

		var/time_since_last_update = world.realtime - text2num(json[season_section][LAST_UPDATE])
		if(time_since_last_update < item_seasons_durations[season_section])
			continue

		json[season_section][LAST_UPDATE] = world.realtime
		json[season_section][CURRENT_SEASON]++

		item_season_progress[season_section] = json[season_section][CURRENT_SEASON]

	fdel(json_file)
	WRITE_FILE(json_file, json_encode(json))

///Initializes the seasonal items file if it is missing
/datum/controller/subsystem/persistence/proc/initialize_seasonal_items_file()
	var/json_file = file("data/seasonal_items.json")
	var/list/json_default_list = list(
		LAST_UPDATE = world.realtime,
		CURRENT_SEASON = 1,
	)
	var/list/json = list()
	for(var/season_section in item_seasons_durations)
		json[season_section] = json_default_list

	WRITE_FILE(json_file, json_encode(json))

///Returns the currently active gun bucket
/datum/controller/subsystem/persistence/proc/current_guns()
	var/bucket_index = item_season_progress[SEASONAL_GUNS] % gun_buckets.len + 1
	var/typepath = gun_buckets[bucket_index]
	var/datum/seasonal_items/current_bucket = new typepath
	return current_bucket.item_list

///Used to make item buckets for the seasonal items system
/datum/seasonal_items
	///Name of the corresponding bucket
	var/name = "base bucket"
	///Descrpition of the corresponding bucket
	var/description = "The first bucket."
	///Items that the corresponding item bucket contains
	var/list/item_list = list()

/datum/seasonal_items/weapons/guns/sadar_bucket
	name = "SADAR bucket"
	description = "Adds some SADARS to round-start marine gear to balance the winrates"
	item_list = list(
		/obj/item/weapon/gun/launcher/rocket/sadar = 10,
		)

/datum/seasonal_items/weapons/guns/wp_bucket
	name = "WP bucket"
	description = "Adds some WP grenades to round-start marine gear to balance the winrates"
	item_list = list(
		/obj/item/explosive/grenade/phosphorus = 10,
		)
