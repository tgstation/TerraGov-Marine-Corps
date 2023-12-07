GLOBAL_LIST_EMPTY(cable_list)					    //Index for all cables, so that powernets don't have to look through the entire world all the time
GLOBAL_LIST_INIT(ammo_list, init_ammo_list())						//List of all ammo types. Used by guns to tell the projectile how to act.

/proc/init_ammo_list()
	. = list()
	// Our ammo stuff is initialized here.
	var/blacklist = list(/datum/ammo/energy, /datum/ammo/bullet/shotgun, /datum/ammo/xeno)
	for(var/t in subtypesof(/datum/ammo) - blacklist)
		var/datum/ammo/A = new t
		.[A.type] = A

GLOBAL_LIST_EMPTY(marine_turrets)

GLOBAL_LIST_EMPTY(droppod_list)
GLOBAL_LIST_EMPTY(tank_list)
GLOBAL_LIST_EMPTY(mechas_list)
GLOBAL_LIST_EMPTY(head_list)
GLOBAL_LIST_EMPTY(beacon_list)
GLOBAL_LIST_EMPTY(id_card_list)
GLOBAL_LIST_EMPTY(disposal_list)
GLOBAL_LIST_EMPTY(ladder_list)
GLOBAL_LIST_EMPTY(patrol_point_list)
GLOBAL_LIST_EMPTY(brig_closets)
GLOBAL_LIST_EMPTY(supply_pad_list)
GLOBAL_LIST_EMPTY(supply_beacon)
GLOBAL_LIST_EMPTY(eord_roomba_spawns)

GLOBAL_LIST_EMPTY(machines)					        //NOTE: this is a list of ALL machines now. The processing machines list is SSmachine.processing !
GLOBAL_LIST_EMPTY(faxmachines)
GLOBAL_LIST_EMPTY(atmospumps)
GLOBAL_LIST_EMPTY(mainship_lights)					//list of mainship lights, used for altering intensity and color during red and delta security levels
GLOBAL_LIST_EMPTY(ship_alarms)						//list of shipside alarm effects used for delta level alert sirens
GLOBAL_LIST_EMPTY(intel_computers)					//All the intel computers for the random events
GLOBAL_LIST_EMPTY(nuke_disk_generators)
GLOBAL_LIST_EMPTY(nuke_list)						//list of all /obj/machinery/nuclearbomb
GLOBAL_LIST_EMPTY(active_nuke_list)
GLOBAL_LIST_EMPTY(nuke_spawn_locs)
GLOBAL_LIST_EMPTY(nuke_disk_spawn_locs)				///list of spawn locations for nuke disk consoles
GLOBAL_LIST_EMPTY(nuke_disk_list)					//list of all /obj/item/disk/nuclear
GLOBAL_LIST_EMPTY(nightfall_toggleable_lights)		//list of all atoms which light can be shut down
GLOBAL_LIST_EMPTY(main_overwatch_consoles)			//list of all main overwatch consoles
///List of all objectives in the campaign gamemode loaded in the current mission
GLOBAL_LIST_EMPTY(campaign_objectives)
///List of non-objective campaign related structures loaded in the current mission
GLOBAL_LIST_EMPTY(campaign_structures)
///List of all mech spawners in campaign mode
GLOBAL_LIST_EMPTY(campaign_mech_spawners)
///Locations for rewards to spawn by faction
GLOBAL_LIST_EMPTY(campaign_reward_spawners)
///List of all teleporter arrays
GLOBAL_LIST_EMPTY(teleporter_arrays)
///List of all droppod bays
GLOBAL_LIST_EMPTY(droppod_bays)
GLOBAL_LIST_EMPTY(landing_lights)

GLOBAL_LIST_EMPTY(chemical_reactions_list)				///list of all /datum/chemical_reaction datums index by reactants, Used during chemical reactions
GLOBAL_LIST_EMPTY(chemical_reagents_list)				///list of all /datum/reagent datums instances indexed by reagent typepath. Used by chemistry stuff
GLOBAL_LIST_INIT(randomized_pill_icons, init_pill_icons())

/proc/init_pill_icons()
	. = list()
	for(var/i in 1 to 21)
		. += "pill[i]"
	shuffle(.)

GLOBAL_LIST_EMPTY(apcs_list)							//list of all Area Power Controller machines, separate from machines for powernet speeeeeeed.

GLOBAL_LIST_EMPTY(wire_color_directory)

GLOBAL_LIST_EMPTY(ai_status_displays)
GLOBAL_LIST_EMPTY(alert_consoles)			// Station alert consoles, /obj/machinery/computer/station_alert

GLOBAL_LIST_EMPTY(xeno_tunnels_by_hive)						//list of all /obj/structure/xeno/tunnel
GLOBAL_LIST_EMPTY(xeno_resin_silo_turfs)
GLOBAL_LIST_EMPTY(xeno_weed_node_turfs)
GLOBAL_LIST_EMPTY(xeno_resin_door_turfs)
GLOBAL_LIST_EMPTY(xeno_resin_wall_turfs)
GLOBAL_LIST_EMPTY(xeno_tunnel_spawn_turfs)
GLOBAL_LIST_EMPTY(xeno_jelly_pod_turfs)
GLOBAL_LIST_EMPTY(xeno_resin_silos_by_hive)
GLOBAL_LIST_EMPTY(xeno_resin_turrets_by_hive)
GLOBAL_LIST_EMPTY(xeno_spawners_by_hive)
GLOBAL_LIST_EMPTY(xeno_structures_by_hive)
GLOBAL_LIST_EMPTY(xeno_critical_structures_by_hive)

GLOBAL_LIST_EMPTY(shuttle_controls_list)

GLOBAL_LIST_EMPTY(fob_sentries_loc)
GLOBAL_LIST_EMPTY(sensor_towers)

GLOBAL_LIST_EMPTY(unmanned_vehicles)

GLOBAL_LIST_INIT(supply_drops, typecacheof(list(
	/obj/structure/closet/crate,
	/obj/structure/largecrate/supply,
	/obj/structure/largecrate/packed,
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
	/obj/item/storage/backpack/marine/corpsman/satchel,
	/obj/item/storage/backpack/marine/satchel/tech,
	/obj/item/storage/backpack/marine/standard), only_root_path = TRUE))
