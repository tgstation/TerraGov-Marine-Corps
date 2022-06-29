GLOBAL_LIST_EMPTY(cable_list)					    //Index for all cables, so that powernets don't have to look through the entire world all the time
GLOBAL_LIST_EMPTY(ammo_list)						//List of all ammo types. Used by guns to tell the projectile how to act.
GLOBAL_LIST_EMPTY(marine_turrets)

GLOBAL_LIST_EMPTY(droppod_list)
GLOBAL_LIST_EMPTY(tank_list)
GLOBAL_LIST_EMPTY(head_list)
GLOBAL_LIST_EMPTY(beacon_list)
GLOBAL_LIST_EMPTY(id_card_list)
GLOBAL_LIST_EMPTY(disposal_list)
GLOBAL_LIST_EMPTY(ladder_list)
GLOBAL_LIST_EMPTY(brig_closets)
GLOBAL_LIST_EMPTY(supply_pad_list)
GLOBAL_LIST_EMPTY(supply_beacon)

GLOBAL_LIST_EMPTY(xeno_tunnels)						//list of all /obj/structure/xeno/tunnel
GLOBAL_LIST_EMPTY(machines)					        //NOTE: this is a list of ALL machines now. The processing machines list is SSmachine.processing !
GLOBAL_LIST_EMPTY(faxmachines)
GLOBAL_LIST_EMPTY(mainship_lights)					//list of mainship lights, used for altering intensity and color during red and delta security levels
GLOBAL_LIST_EMPTY(intel_computers)					//All the intel computers for the random events
GLOBAL_LIST_EMPTY(nuke_disk_generators)
GLOBAL_LIST_EMPTY(nuke_list)						//list of all /obj/machinery/nuclearbomb
GLOBAL_LIST_EMPTY(active_nuke_list)
GLOBAL_LIST_EMPTY(nuke_spawn_locs)
GLOBAL_LIST_EMPTY(nuke_disk_list)					//list of all /obj/item/disk/nuclear
GLOBAL_LIST_EMPTY(nightfall_toggleable_lights)		//list of all atoms which light can be shut down
GLOBAL_LIST_EMPTY(zones_to_control)					//list of all areas that needs to be controlled to gain point in Civil War

GLOBAL_LIST_EMPTY(chemical_reactions_list)				///list of all /datum/chemical_reaction datums index by reactants, Used during chemical reactions
GLOBAL_LIST_EMPTY(chemical_reagents_list)				///list of all /datum/reagent datums instances indexed by reagent typepath. Used by chemistry stuff

GLOBAL_LIST_EMPTY(apcs_list)							//list of all Area Power Controller machines, separate from machines for powernet speeeeeeed.

GLOBAL_LIST_EMPTY(wire_color_directory)

GLOBAL_LIST_EMPTY(ai_status_displays)
GLOBAL_LIST_EMPTY(alert_consoles)			// Station alert consoles, /obj/machinery/computer/station_alert

GLOBAL_LIST_EMPTY(xeno_resin_silo_turfs)
GLOBAL_LIST_EMPTY(xeno_resin_silos)
GLOBAL_LIST_EMPTY(xeno_turret_turfs)
GLOBAL_LIST_EMPTY(xeno_resin_turrets)
GLOBAL_LIST_EMPTY(xeno_weed_node_turfs)
GLOBAL_LIST_EMPTY(xeno_resin_wall_turfs)
GLOBAL_LIST_EMPTY(xeno_resin_door_turfs)
GLOBAL_LIST_EMPTY(xeno_spawner)
GLOBAL_LIST_EMPTY(xeno_structure)
GLOBAL_LIST_EMPTY(xeno_critical_structure)

GLOBAL_LIST_EMPTY(shuttle_controls_list)
GLOBAL_LIST_EMPTY(lz1_shuttle_console_turfs_list)
GLOBAL_LIST_EMPTY(lz2_shuttle_console_turfs_list)

GLOBAL_LIST_EMPTY(fob_sentries_loc)
GLOBAL_LIST_EMPTY(fob_sentries_rebel_loc)
GLOBAL_LIST_EMPTY(sensor_towers)

GLOBAL_LIST_EMPTY(unmanned_vehicles)

GLOBAL_LIST_INIT(supply_drops, typecacheof(list(
	/obj/structure/closet/crate,
	/obj/structure/largecrate/supply,
	/obj/machinery/vending,
	/obj/vehicle/unmanned)))

//hypersleep related
GLOBAL_LIST_EMPTY(cryoed_item_list)

GLOBAL_LIST_INIT(do_not_preserve, typecacheof(list(
	/obj/item/clothing/mask/cigarette,
	/obj/item/clothing/glasses/sunglasses/fake,
	/obj/item/clothing/glasses/mgoggles,
	/obj/item/clothing/head/tgmcberet,
	/obj/item/clothing/head/headband,
	/obj/item/clothing/head/headset,
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
	/obj/item/storage/backpack/marine/satchel/corpsman,
	/obj/item/storage/backpack/marine/satchel/tech,
	/obj/item/storage/backpack/marine/standard), only_root_path = TRUE))
