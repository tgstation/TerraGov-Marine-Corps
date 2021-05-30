//List of all visible and accessible slot on the loadout maker
GLOBAL_LIST_INIT(visible_item_slot_list, list(
	slot_head_str,
	slot_back_str,
	slot_wear_mask_str,
	slot_glasses_str,
	slot_w_uniform_str,
	slot_wear_suit_str,
	slot_gloves_str,
	slot_shoes_str,
	slot_s_store_str,
	slot_belt_str,
	slot_l_store_str,
	slot_r_store_str,
))

///All the vendor types which the automated loadout vendor can take items from
GLOBAL_LIST_INIT(loadout_linked_vendor, list(
	/obj/machinery/vending/marine/shared,
	/obj/machinery/vending/uniform_supply,
	/obj/machinery/vending/armor_supply,
	/obj/machinery/vending/marineFood,
))

///An assoc list of all objects that are job linked, and can be saved a limited amount of time on a loadout
GLOBAL_LIST_INIT(loadout_role_limited_objects, list(
	SQUAD_MARINE = list(
		/obj/item/storage/pouch/grenade/slightlyfull = 2,
		/obj/item/storage/pouch/firstaid/full = 2,
		/obj/item/storage/pouch/firstaid/injectors/full = 2,
		/obj/item/storage/pouch/construction/full = 2,
		/obj/item/storage/pouch/tools/full = 2,
	),
	SQUAD_ENGINEER = list(
		/obj/item/storage/pouch/grenade/slightlyfull = 2,
		/obj/item/storage/pouch/firstaid/full = 2,
		/obj/item/storage/pouch/firstaid/injectors/full = 2,
		/obj/item/storage/pouch/tools/full = 2,
		/obj/item/clothing/glasses/welding = 1,
		/obj/item/clothing/gloves/marine/insulated = 1,
		/obj/item/storage/backpack/marine/satchel/tech = 1,
		/obj/item/storage/backpack/marine/engineerpack = 1,
		/obj/item/storage/pouch/electronics/full = 2,
		/obj/item/storage/belt/utility/full = 1,
		/obj/item/explosive/plastique = 1,
		/obj/item/explosive/grenade/chem_grenade/razorburn_smol = 1,
		/obj/item/cell/high = 1,
		/obj/item/tool/shovel/etool = 1,
		/obj/item/lightreplacer = 1,
		/obj/item/circuitboard/general = 1,
	),
	SQUAD_CORPSMAN = list(
		/obj/item/storage/pouch/grenade/slightlyfull = 2,
		/obj/item/storage/pouch/hypospray/corps/full = 2,
		/obj/item/storage/pouch/autoinjector/advanced/full = 2,
		/obj/item/storage/pouch/medkit/full = 2,
		/obj/item/clothing/glasses/hud/health = 1,
		/obj/item/clothing/tie/storage/white_vest/medic = 1,
		/obj/item/storage/backpack/marine/satchel/corpsman = 1,
		/obj/item/storage/backpack/marine/corpsman = 1,
		/obj/item/storage/belt/medicLifesaver = 1, //Issue here, you can have both when in normal gameplay you can only have one
		/obj/item/storage/belt/medical = 1,
		/obj/item/bodybag/cryobag = 1,
		/obj/item/defibrillator = 1,
		/obj/item/healthanalyzer = 1,
		/obj/item/roller/medevac = 1,
		/obj/item/medevac_beacon = 1,
		/obj/item/roller = 1,
		/obj/item/tweezers = 1,
		/obj/item/reagent_containers/hypospray/advanced/oxycodone = 1,
		/obj/item/storage/firstaid/adv = 1,
	),
	SQUAD_SMARTGUNNER = list(
		/obj/item/storage/pouch/firstaid/full = 2,
		/obj/item/storage/pouch/firstaid/injectors/full = 2,
		/obj/item/clothing/glasses/night/m56_goggles = 1,
		/obj/item/weapon/gun/rifle/standard_smartmachinegun = 1,
		/obj/item/ammo_magazine/standard_smartmachinegun = 3,
	),
	SQUAD_LEADER = list(
		/obj/item/storage/pouch/grenade/slightlyfull = 2,
		/obj/item/storage/pouch/firstaid/full = 2,
		/obj/item/storage/pouch/firstaid/injectors/full = 2,
		/obj/item/storage/pouch/construction/full = 2,
		/obj/item/storage/pouch/tools/full = 2,
		/obj/item/explosive/plastique = 1,
		/obj/item/squad_beacon = 1,
		/obj/item/squad_beacon = 1,
		/obj/item/squad_beacon/bomb = 1,
		/obj/item/whistle = 1,
		/obj/item/radio = 1,
		/obj/item/motiondetector = 1,
		/obj/item/binoculars/tactical = 1,
		/obj/item/pinpointer/pool = 1,
	),
))

///Items that once they are in loadouts, should not have stock checked when sold by the loadout vendor
GLOBAL_LIST_INIT(bypass_vendor_item, typecacheof(list(
	/obj/item/ammo_magazine/handful,
	)))

///Items that should be saved in loadouts no matter what
GLOBAL_LIST_INIT(bypass_loadout_check_item, typecacheof(list(
	/obj/item/clothing/under/marine,
)))

///List of all supported job titles by the loadout vendors
GLOBAL_LIST_INIT(loadout_job_supported, list(
	SQUAD_MARINE,
	SQUAD_ENGINEER,
	SQUAD_CORPSMAN,
	SQUAD_SMARTGUNNER,
	SQUAD_LEADER,
))

///Assoc list linking the job title with their specific points vendor
GLOBAL_LIST_INIT(job_specific_points_vendor, list(
	SQUAD_ENGINEER = GLOB.engineer_gear_listed_products,
	SQUAD_CORPSMAN = GLOB.medic_gear_listed_products,
	SQUAD_LEADER = GLOB.leader_gear_listed_products,
))
	

//Defines use for the visualisation of loadouts
#define NO_OFFSET "0%"
#define NO_SCALING 1
#define MODULAR_ARMOR_OFFSET_Y "-10%"
#define MODULAR_ARMOR_SCALING 1.2

///The maximum number of loadouts one player can have per job
#define MAXIMUM_LOADOUT 15

/// The currently accepted loadout version, all other loadouts will be erased from savefiles
#define CURRENT_LOADOUT_VERSION 2
