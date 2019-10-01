GLOBAL_LIST_EMPTY(cable_list)					    //Index for all cables, so that powernets don't have to look through the entire world all the time
GLOBAL_LIST_EMPTY(ammo_list)						//List of all ammo types. Used by guns to tell the projectile how to act.
GLOBAL_LIST_EMPTY(cargo_ammo_vendors)				//Used by our gamemode code
GLOBAL_LIST_EMPTY(cargo_guns_vendors)				//Used by our gamemode code
GLOBAL_LIST_EMPTY(marine_vendors)					//Used by our gamemode code
GLOBAL_LIST_EMPTY(attachment_vendors)				//Used by our gamemode code

GLOBAL_LIST_EMPTY(tank_list)
GLOBAL_LIST_EMPTY(implant_list)
GLOBAL_LIST_EMPTY(head_list)
GLOBAL_LIST_EMPTY(beacon_list)
GLOBAL_LIST_EMPTY(id_card_list)
GLOBAL_LIST_EMPTY(disposal_list)
GLOBAL_LIST_EMPTY(ladder_list)
GLOBAL_LIST_EMPTY(brig_closets)
GLOBAL_LIST_EMPTY(supply_pad_list)

GLOBAL_LIST_EMPTY(xeno_tunnels)						//list of all /obj/structure/tunnel
GLOBAL_LIST_EMPTY(machines)					        //NOTE: this is a list of ALL machines now. The processing machines list is SSmachine.processing !
GLOBAL_LIST_EMPTY(faxmachines)
GLOBAL_LIST_EMPTY(nuke_disk_generators)
GLOBAL_LIST_EMPTY(nuke_list)						//list of all /obj/machinery/nuclearbomb
GLOBAL_LIST_EMPTY(active_nuke_list)
GLOBAL_LIST_EMPTY(nuke_spawn_locs)
GLOBAL_LIST_EMPTY(nuke_disk_list)					//list of all /obj/item/disk/nuclear

GLOBAL_LIST_EMPTY(chemical_reactions_list)				//list of all /datum/chemical_reaction datums. Used during chemical reactions
GLOBAL_LIST_EMPTY(chemical_reagents_list)				//list of all /datum/reagent datums indexed by reagent id. Used by chemistry stuff
GLOBAL_LIST_EMPTY(apcs_list)					//list of all Area Power Controller machines, separate from machines for powernet speeeeeeed.

GLOBAL_LIST_EMPTY(wire_color_directory)
GLOBAL_LIST_EMPTY(wire_name_directory)

GLOBAL_LIST_EMPTY(ai_status_displays)
GLOBAL_LIST_EMPTY(alert_consoles)			// Station alert consoles, /obj/machinery/computer/station_alert

GLOBAL_LIST_EMPTY(xeno_resin_silo_turfs)
GLOBAL_LIST_EMPTY(xeno_resin_silos)

GLOBAL_LIST_EMPTY(shuttle_controls_list)

GLOBAL_LIST_INIT(supply_drops, typecacheof(list(
	/obj/structure/closet/crate,
	/obj/machinery/vending)))

//hypersleep related
GLOBAL_LIST_INIT(cryoed_item_list, list(CRYO_ALPHA = list(), CRYO_BRAVO = list(), CRYO_CHARLIE = list(), CRYO_DELTA =list(), CRYO_SEC = list(), CRYO_REQ = list(), CRYO_ENGI = list(), CRYO_MED = list()))

GLOBAL_LIST_INIT(do_not_preserve, typecacheof(list(
	/obj/item/clothing/mask/cigarette,
	/obj/item/clothing/glasses/sunglasses/fake,
	/obj/item/clothing/glasses/mgoggles,
	/obj/item/clothing/head/tgmcberet,
	/obj/item/clothing/head/headband,
	/obj/item/clothing/head/headset,
	/obj/item/clothing/head/tgmcbandanna,
	/obj/item/clothing/gloves/black,
	/obj/item/weapon/baton,
	/obj/item/weapon/gun/energy/taser,
	/obj/item/clothing/glasses/sunglasses/sechud,
	/obj/item/radio/headset/mainship,
	/obj/item/card/id,
	/obj/item/clothing/under/marine,
	/obj/item/clothing/shoes/marine,
	/obj/item/clothing/head/tgmccap,
	/obj/item/trash)))

GLOBAL_LIST_INIT(do_not_preserve_empty, typecacheof(list(
	/obj/item/storage/backpack/marine/satchel,
	/obj/item/storage/belt/security/MP,
	/obj/item/storage/backpack/marine/satchel/corpsman,
	/obj/item/storage/backpack/marine/satchel/tech,
	/obj/item/storage/backpack/marine/standard), only_root_path = TRUE))
