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
		SEASONAL_GUNS = 4 DAYS,
	)
	///Stores the current season for each season group
	var/list/season_progress = list()
	///Items that have been selected for the current round for each season
	var/list/season_items = list()
	///Available gun seasons
	var/list/seasons_buckets = list(
		SEASONAL_GUNS = list(
		/datum/season_datum/weapons/guns/pistol_seasonal_one,
		/datum/season_datum/weapons/guns/rifle_seasonal_one,
		/datum/season_datum/weapons/guns/pistol_seasonal_two,
		/datum/season_datum/weapons/guns/rifle_seasonal_two,
		/datum/season_datum/weapons/guns/pistol_seasonal_three,
		)
	)
	///The saved list of custom outfits names
	var/list/custom_loadouts = list()

///Loads data at the start of the round
/datum/controller/subsystem/persistence/Initialize()
	LoadSeasonalItems()
	load_custom_loadouts_list()
	return ..()

///Stores data at the end of the round
/datum/controller/subsystem/persistence/proc/CollectData()
	save_custom_loadouts_list()
	return

///Loads the list of custom outfits names
/datum/controller/subsystem/persistence/proc/load_custom_loadouts_list()
	var/json_file = file("data/custom_loadouts.json")
	if(!fexists(json_file))
		initialize_custom_loadouts_file()
	custom_loadouts = json_decode(file2text(json_file))

///Load a loadout from the persistence loadouts savefile
/datum/controller/subsystem/persistence/proc/load_loadout(loadout_name)
	var/savefile/S = new /savefile("data/persistence.sav")
	if(!S)
		return FALSE
	S.cd = "/loadouts"
	var/loadout_json = ""
	READ_FILE(S[loadout_name], loadout_json)
	if(!loadout_json)
		return FALSE
	var/datum/loadout/loadout = jatum_deserialize(loadout_json)
	return loadout

///Saves the list of custom outfits names
/datum/controller/subsystem/persistence/proc/save_custom_loadouts_list()
	var/json_file = file("data/custom_loadouts.json")
	fdel(json_file)
	WRITE_FILE(json_file, json_encode(custom_loadouts))

///Save a loadout into the persistence savefile
/datum/controller/subsystem/persistence/proc/save_loadout(datum/loadout/loadout)
	var/savefile/S = new /savefile("data/persistence.sav")
	if(!S)
		return FALSE
	S.cd = "/loadouts"
	loadout.loadout_vendor = null
	var/loadout_json = jatum_serialize(loadout)
	WRITE_FILE(S["[loadout.name]"], loadout_json)
	custom_loadouts += loadout.name
	return TRUE

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

///Handles checking whether a season should advance and advancing it, along with setting up the seasons' values or procs for the round
/datum/controller/subsystem/persistence/proc/update_season_data(season_class, list/seasons_file_info)
	//loads a new entry for a season if one is missing
	if(!LAZYACCESS(seasons_file_info, season_class)) //handles adding missing entries
		var/list/template_season_entry = list(
			"[season_class]" = list(LAST_UPDATE = 0, CURRENT_SEASON = 0) //values will be set afterwards
		)
		seasons_file_info += template_season_entry

	//checks whether the season should be advanced
	var/last_season_update_time = text2num(seasons_file_info[season_class][LAST_UPDATE])
	var/time_since_last_update = world.realtime - last_season_update_time
	if(time_since_last_update >= seasons_durations[season_class])
		seasons_file_info[season_class][LAST_UPDATE] = world.realtime
		seasons_file_info[season_class][CURRENT_SEASON]++

	//Initializes the season datum that is chosen based on the current season
	season_progress[season_class] = seasons_file_info[season_class][CURRENT_SEASON]
	var/seasons_buckets_list_index = season_progress[season_class] % length(seasons_buckets[season_class]) + 1
	var/season_typepath = seasons_buckets[season_class][seasons_buckets_list_index]
	var/datum/season_datum/season_instance = new season_typepath

	//Does stuff with the initialized season datum
	season_items[season_class] = season_instance.item_list

	//returns the updated season file data to write over the stored season file information
	return seasons_file_info

///Initializes the seasonal items file if it is missing
/datum/controller/subsystem/persistence/proc/initialize_seasonal_items_file()
	var/json_file = file("data/seasonal_items.json")
	var/list/seasons_file_info = list()
	WRITE_FILE(json_file, json_encode(seasons_file_info))

///Initializes the custom loadouts file if it is missing
/datum/controller/subsystem/persistence/proc/initialize_custom_loadouts_file()
	var/json_file = file("data/custom_loadouts.json")
	var/list/custom_loadouts_info = list()
	WRITE_FILE(json_file, json_encode(custom_loadouts_info))

///Used to make item buckets for the seasonal items system
/datum/season_datum
	///Name of the  season
	var/name = "base season"
	///Descrpition of the season
	var/description = "The first season."
	///Items that the season contains
	var/list/item_list = list()

/datum/season_datum/weapons/guns/rifle_seasonal_one
	name = "rifles bucket 1"
	description = "Rifle guns, previously at import"
	item_list = list(
		/obj/item/weapon/gun/rifle/ak47 = -1,
		/obj/item/ammo_magazine/rifle/ak47 = -1,
		/obj/item/weapon/gun/rifle/m16 = -1,
		/obj/item/ammo_magazine/rifle/m16 = -1,
		)

/datum/season_datum/weapons/guns/rifle_seasonal_two
	name = "rifles bucket 2"
	description = "Rifle guns, previously at import"
	item_list = list(
		/obj/item/weapon/gun/smg/uzi = -1,
		/obj/item/ammo_magazine/smg/uzi = -1,
		)

/datum/season_datum/weapons/guns/pistol_seasonal_one
	name = "pistols bucket 1"
	description = "Pistol guns, previously at import"
	item_list = list(
		/obj/item/weapon/gun/revolver/small = -1,
		/obj/item/ammo_magazine/revolver/small = -1,
		/obj/item/weapon/gun/revolver/m44 = -1,
		/obj/item/ammo_magazine/revolver = -1,
		)

/datum/season_datum/weapons/guns/pistol_seasonal_two
	name = "pistols bucket 2"
	description = "Pistol guns, previously at import"
	item_list = list(
		/obj/item/weapon/gun/pistol/g22 = -1,
		/obj/item/ammo_magazine/pistol/g22 = -1,
		/obj/item/weapon/gun/pistol/heavy = -1,
		/obj/item/ammo_magazine/pistol/heavy = -1,
		)

/datum/season_datum/weapons/guns/pistol_seasonal_three
	name = "pistols bucket 3"
	description = "Pistol guns, previously at import"
	item_list = list(
		/obj/item/weapon/gun/pistol/vp78 = -1,
		/obj/item/ammo_magazine/pistol/vp78 = -1,
		/obj/item/weapon/gun/pistol/highpower = -1,
		/obj/item/ammo_magazine/pistol/highpower = -1,
		)
