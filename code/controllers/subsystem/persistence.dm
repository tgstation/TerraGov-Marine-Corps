//Season defines, universal for all seasons
#define LAST_UPDATE "last_update" //last time the season changed
#define CURRENT_SEASON "current_season" //current season of the section

//Current season info defines
#define CURRENT_SEASON_NUMBER "current_season_number"
#define CURRENT_SEASON_NAME "current_season_name"
#define CURRENT_SEASON_DESC "current_season_description"

//Season names
#define SEASONAL_GUNS "seasonal_guns"

SUBSYSTEM_DEF(persistence)
	name = "Persistence"
	init_order = INIT_ORDER_PERSISTENCE
	flags = SS_NO_FIRE

	///Stores how long each season should last
	var/list/seasons_durations = list(
		SEASONAL_GUNS = 24 HOURS,
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
		/datum/season_datum/weapons/guns/rifle_seasonal_three,
		/datum/season_datum/weapons/guns/pistol_seasonal_four,
		/datum/season_datum/weapons/guns/copsandrobbers_seasonal,
		/datum/season_datum/weapons/guns/smg_seasonal,
		/datum/season_datum/weapons/guns/storm_seasonal,
		/datum/season_datum/weapons/guns/shotgun_seasonal
		)
	)
	///The saved list of custom outfits names
	var/list/custom_loadouts = list()
	///When were the last rounds of specific game mode played, in ticks
	var/list/last_modes_round_date

///Loads data at the start of the round
/datum/controller/subsystem/persistence/Initialize()
	LoadSeasonalItems()
	load_custom_loadouts_list()
	load_last_civil_war_round_time()
	return ..()

///Stores data at the end of the round
/datum/controller/subsystem/persistence/proc/CollectData()
	save_custom_loadouts_list()
	save_last_civil_war_round_time()
	save_player_number()
	return

///Loads the last civil war round date
/datum/controller/subsystem/persistence/proc/load_last_civil_war_round_time()
	var/json_file = file("data/last_modes_round_date.json")
	if(!fexists(json_file))
		last_modes_round_date = list()
		return
	last_modes_round_date = json_decode(file2text(json_file))

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

///Save the date of the last civil war round
/datum/controller/subsystem/persistence/proc/save_last_civil_war_round_time()
	var/json_file = file("data/last_modes_round_date.json")
	fdel(json_file)
	WRITE_FILE(json_file, json_encode(last_modes_round_date))

///Saves the list of custom outfits names
/datum/controller/subsystem/persistence/proc/save_custom_loadouts_list()
	var/json_file = file("data/custom_loadouts.json")
	fdel(json_file)
	WRITE_FILE(json_file, json_encode(custom_loadouts))

/datum/controller/subsystem/persistence/proc/save_player_number()
	var/json_file = file("data/last_round_player_count.json")
	fdel(json_file)
	WRITE_FILE(json_file, json_encode(TGS_CLIENT_COUNT))

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

///Constructs a message with information about the active seasons and their current buckets
/datum/controller/subsystem/persistence/proc/seasons_info_message()
	var/message = ""
	for(var/season_entry in season_progress)
		var/season_name = jointext(splittext("[season_entry]", "_"), " ")
		var/season_name_first_letter = uppertext(copytext(season_name, 1, 2))
		var/season_name_remainder = copytext(season_name, 2, length(season_name) + 1)
		season_name = season_name_first_letter + season_name_remainder
		message += span_seasons_announce("<b>[season_name]</b> - season [season_progress[season_entry][CURRENT_SEASON_NUMBER]]<br>")
		message += span_season_additional_info("<b>Title:</b> [season_progress[season_entry][CURRENT_SEASON_NAME]]<br>")
		message += span_season_additional_info("<b>Description:</b> [season_progress[season_entry][CURRENT_SEASON_DESC]]<br>")

	return message

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
	season_progress[season_class] = list()
	season_progress[season_class][CURRENT_SEASON_NUMBER] = seasons_file_info[season_class][CURRENT_SEASON]
	var/seasons_buckets_list_index = season_progress[season_class][CURRENT_SEASON_NUMBER] % length(seasons_buckets[season_class]) + 1
	var/season_typepath = seasons_buckets[season_class][seasons_buckets_list_index]
	var/datum/season_datum/season_instance = new season_typepath

	//Does stuff with the initialized season datum
	season_progress[season_class][CURRENT_SEASON_NAME] = season_instance.name
	season_progress[season_class][CURRENT_SEASON_DESC] = season_instance.description
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
	name = "AK47 and M16"
	description = "Rifle guns, previously at import"
	item_list = list(
		/obj/item/weapon/gun/rifle/mpi_km = -1,
		/obj/item/ammo_magazine/rifle/mpi_km = -1,
		/obj/item/weapon/gun/rifle/m16 = -1,
		/obj/item/ammo_magazine/rifle/m16 = -1,
		)

/datum/season_datum/weapons/guns/rifle_seasonal_two
	name = "Pulse Rifles"
	description = "A failed classic and it's eventual successor."
	item_list = list(
		/obj/item/weapon/gun/rifle/m412 = -1,
		/obj/item/ammo_magazine/rifle = -1,
		/obj/item/weapon/gun/rifle/m41a = -1,
		/obj/item/ammo_magazine/rifle/m41a = -1,
		)

/datum/season_datum/weapons/guns/rifle_seasonal_three
	name = "Burst and CQC"
	description = "A Machinecarbine and a burst fire heavy rifle."
	item_list = list(
		/obj/item/weapon/gun/rifle/type71/seasonal = -1,
		/obj/item/ammo_magazine/rifle/type71 = -1,
		/obj/item/weapon/gun/rifle/alf_machinecarbine = -1,
		/obj/item/ammo_magazine/rifle/alf_machinecarbine = -1,
		)

/datum/season_datum/weapons/guns/pistol_seasonal_one
	name = "Bouncy revolver and average revolver"
	description = "A rather average revolver and it's far bouncier smaller cousin."
	item_list = list(
		/obj/item/weapon/gun/revolver/small = -1,
		/obj/item/ammo_magazine/revolver/small = -1,
		/obj/item/weapon/gun/revolver/single_action/m44 = -1,
		/obj/item/ammo_magazine/revolver = -1,
		)

/datum/season_datum/weapons/guns/pistol_seasonal_four
	name = "Judge and Nagant"
	description = "More revolvers for the revolver mains."
	item_list = list(
		/obj/item/weapon/gun/revolver/judge = -1,
		/obj/item/ammo_magazine/revolver/judge = -1,
		/obj/item/ammo_magazine/revolver/judge/buckshot = -1,
		/obj/item/weapon/gun/revolver/upp = -1,
		/obj/item/ammo_magazine/revolver/upp = -1,
		)

/datum/season_datum/weapons/guns/pistol_seasonal_two
	name = "G22 and a heavy pistol"
	description = "More pistols for the pistol mains."
	item_list = list(
		/obj/item/weapon/gun/pistol/g22 = -1,
		/obj/item/ammo_magazine/pistol/g22 = -1,
		/obj/item/weapon/gun/pistol/heavy = -1,
		/obj/item/ammo_magazine/pistol/heavy = -1,
		)

/datum/season_datum/weapons/guns/pistol_seasonal_three
	name = "High-power pistols"
	description = "More pistols in the vendors, why not?"
	item_list = list(
		/obj/item/weapon/gun/pistol/vp78 = -1,
		/obj/item/ammo_magazine/pistol/vp78 = -1,
		/obj/item/weapon/gun/pistol/highpower = -1,
		/obj/item/ammo_magazine/pistol/highpower = -1,
		)

/datum/season_datum/weapons/guns/copsandrobbers_seasonal
	name = "Cops and robbers"
	description = "A Revolver and a classic SMG. Truly cops and robbers."
	item_list = list(
		/obj/item/weapon/gun/smg/uzi = -1,
		/obj/item/ammo_magazine/smg/uzi = -1,
		/obj/item/weapon/gun/revolver/cmb = -1,
		/obj/item/ammo_magazine/revolver/cmb = -1,
		)

/datum/season_datum/weapons/guns/smg_seasonal
	name = "SMGs"
	description = "Two different SMGs. A classic and a new guy."
	item_list = list(
		/obj/item/weapon/gun/smg/m25 = -1,
		/obj/item/ammo_magazine/smg/m25 = -1,
		/obj/item/weapon/gun/smg/mp7 = -1,
		/obj/item/ammo_magazine/smg/mp7 = -1,
		)

/datum/season_datum/weapons/guns/storm_seasonal
	name = "Storm weapons"
	description = "Two classics on opposite sides, both made for CQC."
	item_list = list(
		/obj/item/weapon/gun/rifle/mkh = -1,
		/obj/item/ammo_magazine/rifle/mkh = -1,
		/obj/item/weapon/gun/smg/ppsh = -1,
		/obj/item/ammo_magazine/smg/ppsh = -1,
		/obj/item/ammo_magazine/smg/ppsh/extended = -1,
		)

/datum/season_datum/weapons/guns/shotgun_seasonal
	name = "Pumps"
	description = "Two classic pump shotguns from older times."
	item_list = list(
		/obj/item/weapon/gun/shotgun/combat = -1,
		/obj/item/weapon/gun/shotgun/pump/cmb = -1,
		)

