//Season defines, universal for all seasons
#define LAST_UPDATE "last_update" //last time the season changed
#define CURRENT_SEASON "current_season" //current season of the section

//Season names
#define SEASONAL_GUNS "seasonal_guns"

SUBSYSTEM_DEF(persistence)
	name = "Persistence"
	init_order = INIT_ORDER_PERSISTENCE
	flags = SS_NO_FIRE

	///Stores how long each season should last
	var/list/seasons_durations = list(
		SEASONAL_GUNS = 0.001 DAYS,
	)
	///Stores the current season for each season group
	var/list/season_progress = list()
	///Items that have been selected for the current round for each season
	var/list/season_items = list()
	///Available gun seasons
	var/list/seasons_buckets = list(
		SEASONAL_GUNS = list(
		/datum/season_datum/weapons/guns/sadar_event,
		/datum/season_datum/weapons/guns/wp_event
		),
		)

///Loads data at the start of the round
/datum/controller/subsystem/persistence/Initialize()
	LoadSeasonalItems()
	return ..()

///Stores data at the end of the round
/datum/controller/subsystem/persistence/proc/CollectData()
	return

///Loads seasons data, advances seasons and saves the data
/datum/controller/subsystem/persistence/proc/LoadSeasonalItems()
	var/json_file = file("data/seasonal_items.json")
	if(!fexists(json_file))
		initialize_seasonal_items_file()
	var/list/seasons_file_info = json_decode(file2text(json_file))

	for(var/season_class in seasons_durations)
		seasons_file_info = update_season_data(season_class, seasons_file_info)

	fdel(json_file)
	WRITE_FILE(json_file, json_encode(seasons_file_info))

/datum/controller/subsystem/persistence/proc/update_season_data(season_class, list/seasons_file_info)
	if(!LAZYACCESS(seasons_file_info, season_class)) //handles adding missing entries
		var/list/template_season_entry = list(
			"[season_class]" = list(LAST_UPDATE = 0, CURRENT_SEASON = 0) //values will be set afterwards
		)
		seasons_file_info += template_season_entry

	var/last_season_update_time = text2num(seasons_file_info[season_class][LAST_UPDATE])
	var/time_since_last_update = world.realtime - last_season_update_time
	if(time_since_last_update < seasons_durations[season_class])
		return seasons_file_info

	seasons_file_info[season_class][LAST_UPDATE] = world.realtime
	seasons_file_info[season_class][CURRENT_SEASON]++
	season_progress[season_class] = seasons_file_info[season_class][CURRENT_SEASON]

	var/seasons_buckets_list_index = season_progress[season_class] % length(seasons_buckets[season_class]) + 1

	var/season_typepath = seasons_buckets[season_class][seasons_buckets_list_index]
	var/datum/season_datum/season_instance = new season_typepath
	season_items[season_class] = season_instance.item_list
	return seasons_file_info

///Initializes the seasonal items file if it is missing
/datum/controller/subsystem/persistence/proc/initialize_seasonal_items_file()
	var/json_file = file("data/seasonal_items.json")
	var/list/seasons_file_info = list()
	WRITE_FILE(json_file, json_encode(seasons_file_info))

///Used to make item buckets for the seasonal items system
/datum/season_datum
	///Name of the  season
	var/name = "base season"
	///Descrpition of the season
	var/description = "The first season."
	///Items that the season contains
	var/list/item_list = list()

/datum/season_datum/weapons/guns/sadar_event
	name = "SADAR bucket"
	description = "Adds some SADARS to round-start marine gear to balance the winrates"
	item_list = list(
		/obj/item/weapon/gun/launcher/rocket/sadar = 10,
		)

/datum/season_datum/weapons/guns/wp_event
	name = "WP bucket"
	description = "Adds some WP grenades to round-start marine gear to balance the winrates"
	item_list = list(
		/obj/item/explosive/grenade/phosphorus = 10,
		)
