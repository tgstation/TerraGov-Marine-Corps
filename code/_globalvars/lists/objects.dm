GLOBAL_LIST_EMPTY(cable_list)					    //Index for all cables, so that powernets don't have to look through the entire world all the time
GLOBAL_LIST_EMPTY(object_list)						//list of all /obj
GLOBAL_LIST_EMPTY(turfs)							//list of all /turf
GLOBAL_LIST_EMPTY(structure_list)					//list of all /obj/structure
GLOBAL_LIST_EMPTY(item_list)					    //list of all /obj/item
GLOBAL_LIST_EMPTY(ammo_list)						//List of all ammo types. Used by guns to tell the projectile how to act.
GLOBAL_LIST_EMPTY(effect_list)
GLOBAL_LIST_EMPTY(cargo_ammo_vendors)				//Used by our gamemode code
GLOBAL_LIST_EMPTY(cargo_guns_vendors)				//Used by our gamemode code
GLOBAL_LIST_EMPTY(marine_vendors)					//Used by our gamemode code
GLOBAL_LIST_EMPTY(attachment_vendors)				//Used by our gamemode code

GLOBAL_LIST_EMPTY(xeno_tunnels)						//list of all /obj/structure/tunnel
GLOBAL_LIST_EMPTY(portals)					        //list of all /obj/effect/portal
GLOBAL_LIST_EMPTY(airlocks)					        //list of all airlocks
GLOBAL_LIST_EMPTY(machines)					        //NOTE: this is a list of ALL machines now. The processing machines list is SSmachine.processing !
GLOBAL_LIST_EMPTY(faxmachines)
GLOBAL_LIST_EMPTY(navbeacons)					    //list of all bot nagivation beacons, used for patrolling.
GLOBAL_LIST_EMPTY(teleportbeacons)			        //list of all tracking beacons used by teleporters
GLOBAL_LIST_EMPTY(deliverybeacons)			        //list of all MULEbot delivery beacons.
GLOBAL_LIST_EMPTY(deliverybeacontags)			    //list of all tags associated with delivery beacons.
GLOBAL_LIST_EMPTY(nuke_list)
GLOBAL_LIST_EMPTY(alarmdisplay)				        //list of all machines or programs that can display station alerts
GLOBAL_LIST_EMPTY(singularities)				    //list of all singularities on the station (actually technically all engines)

GLOBAL_LIST(chemical_reactions_list)				//list of all /datum/chemical_reaction datums. Used during chemical reactions
GLOBAL_LIST(chemical_reagents_list)				//list of all /datum/reagent datums indexed by reagent id. Used by chemistry stuff
GLOBAL_LIST_EMPTY(materials_list)				//list of all /datum/material datums indexed by material id.
GLOBAL_LIST_EMPTY(tech_list)					//list of all /datum/tech datums indexed by id.
GLOBAL_LIST_EMPTY(surgeries_list)				//list of all surgeries by name, associated with their path.
GLOBAL_LIST_EMPTY(crafting_recipes)				//list of all table craft recipes
GLOBAL_LIST_EMPTY(rcd_list)					//list of Rapid Construction Devices.
GLOBAL_LIST_EMPTY(apcs_list)					//list of all Area Power Controller machines, separate from machines for powernet speeeeeeed.
GLOBAL_LIST_EMPTY(tracked_implants)			//list of all current implants that are tracked to work out what sort of trek everyone is on. Sadly not on lavaworld not implemented...
GLOBAL_LIST_EMPTY(tracked_chem_implants)			//list of implants the prisoner console can track and send inject commands too
GLOBAL_LIST_EMPTY(poi_list)					//list of points of interest for observe/follow
GLOBAL_LIST_EMPTY(pinpointer_list)			//list of all pinpointers. Used to change stuff they are pointing to all at once.
GLOBAL_LIST_EMPTY(meteor_list)				// List of all meteors.
GLOBAL_LIST_EMPTY(active_jammers)             // List of active radio jammers
GLOBAL_LIST_EMPTY(ladders)
GLOBAL_LIST_EMPTY(trophy_cases)

GLOBAL_LIST_EMPTY(wire_color_directory)
GLOBAL_LIST_EMPTY(wire_name_directory)

GLOBAL_LIST_EMPTY(ai_status_displays)

GLOBAL_LIST_EMPTY(mob_spawners) 		    // All mob_spawn objects
GLOBAL_LIST_EMPTY(alert_consoles)			// Station alert consoles, /obj/machinery/computer/station_alert

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
	/obj/item/clothing/head/tgmcbandana,
	/obj/item/clothing/gloves/black,
	/obj/item/weapon/baton,
	/obj/item/weapon/gun/energy/taser,
	/obj/item/clothing/glasses/sunglasses/sechud,
	/obj/item/radio/headset/almayer,
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