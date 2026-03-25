#define CAPTURE_POINT_TARGET 400

/datum/game_mode/hvh/combat_patrol/encounter
	name = "Encounter"
	config_tag = "Encounter"
	round_type_flags = MODE_LATE_OPENING_SHUTTER_TIMER|MODE_TWO_HUMAN_FACTIONS|MODE_INFESTATION|MODE_MUTATIONS_OBTAINABLE|MODE_PSY_POINTS|MODE_SILO_RESPAWN|MODE_ENCOUNTER
	xeno_abilities_flags = ABILITY_CRASH
	factions = list(FACTION_TERRAGOV, FACTION_SOM, FACTION_XENO)
	valid_job_types = list(
		/datum/job/terragov/squad/engineer = 8,
		/datum/job/terragov/squad/corpsman = 8,
		/datum/job/terragov/squad/smartgunner = 4,
		/datum/job/terragov/squad/leader = 4,
		/datum/job/terragov/squad/standard = -1,
		/datum/job/som/squad/leader = 4,
		/datum/job/som/squad/veteran = 4,
		/datum/job/som/squad/engineer = 8,
		/datum/job/som/squad/medic = 8,
		/datum/job/som/squad/standard = -1,
		/datum/job/xenomorph = 1
	)
	job_points_needed_by_job_type = list(
		/datum/job/terragov/squad/smartgunner = 5,
		/datum/job/som/squad/veteran = 5,
		/datum/job/xenomorph = ENCOUNTER_LARVA_POINTS_NEEDED,
	)
	wave_timer_length = 2 MINUTES
	max_game_time = 30 MINUTES
	game_timer_delay = 0
	blacklist_ground_maps = list(MAP_WHISKEY_OUTPOST, MAP_OSCAR_OUTPOST, MAP_FORT_PHOBOS, MAP_CHIGUSA, MAP_CORSAT)
	///mission completion target

	///TGMC's point count
	var/TGMC_cap_points = 0
	///SOM's point count
	var/SOM_cap_points = 0
	///Xenos' point count
	var/XENO_cap_points = 0
	///Tower req value for owning faction per process()
	var/tower_req_value = 10
	///Tower xeno tactical point value for owning faction per process()
	var/tower_xeno_tactical_point_value = 3
	///Tower xeno strategic point value for owning faction per process()
	var/tower_xeno_strategic_point_value = 7

/datum/game_mode/hvh/combat_patrol/encounter/announce()
	to_chat(world, "<b>The current game mode is - Free for all!</b>")
	to_chat(world, "<b>SOM and Terragov forces are fighting for control of this sector and an alien threat has emerged, capture the sensor towers for your team.</b>")

/datum/game_mode/hvh/combat_patrol/encounter/get_deploy_point_message(mob/living/user)
	. = "Capture as many sensor towers as possible, deny them to the other team."

/datum/game_mode/hvh/combat_patrol/encounter/process()
	. = ..()
	for(var/obj/structure/campaign_objective/capture_objective/sensor_tower/tower in GLOB.campaign_objectives)
		if(tower.owning_faction == FACTION_TERRAGOV)
			TGMC_cap_points += 1
			SSpoints.supply_points[FACTION_TERRAGOV] += tower_req_value
		else if(tower.owning_faction == FACTION_SOM)
			SOM_cap_points+= 1
			SSpoints.supply_points[FACTION_SOM] += tower_req_value
		else if(tower.owning_faction == FACTION_XENO)
			XENO_cap_points += 1
			SSpoints.add_tactical_psy_points(XENO_HIVE_NORMAL, tower_xeno_tactical_point_value)
			SSpoints.add_strategic_psy_points(XENO_HIVE_NORMAL, tower_xeno_strategic_point_value)
	return ..()

/datum/game_mode/hvh/combat_patrol/encounter/post_setup()
	. = ..()

	for(var/turf/T AS in GLOB.sensor_towers)
		new /obj/structure/sensor_tower(T)

	for(var/i in GLOB.xeno_encounter_resin_silo_turfs)
		new /obj/structure/xeno/silo(i)

	var/weed_type
	for(var/turf/T in GLOB.xeno_weed_node_turfs)
		weed_type = pickweight(GLOB.weed_prob_list)
		new weed_type(T)

	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_HVH_REQ)

	// Apply Evolution Xeno Population Locks:
	// for(var/datum/xeno_caste/caste AS in evo_requirements)
	// 	GLOB.xeno_caste_datums[caste][XENO_UPGRADE_BASETYPE].evolve_min_xenos = evo_requirements[caste]

/datum/game_mode/hvh/combat_patrol/encounter/get_status_tab_items(datum/dcs, mob/source, list/items)
	. = ..()
	items += "Terragov Marine Corps capture points: [TGMC_cap_points]/[CAPTURE_POINT_TARGET]"
	items += "Sons of Mars capture points: [SOM_cap_points]/[CAPTURE_POINT_TARGET]"
	items += "Xenomorph capture points: [XENO_cap_points]/[CAPTURE_POINT_TARGET]"

//End game checks
/datum/game_mode/hvh/combat_patrol/encounter/check_finished()
	if(round_finished)
		return TRUE

	if(TGMC_cap_points >= CAPTURE_POINT_TARGET)
		message_admins("Round finished: [MODE_COMBAT_PATROL_MARINE_MAJOR]")
		round_finished = MODE_COMBAT_PATROL_MARINE_MAJOR
		return TRUE

	if(SOM_cap_points >= CAPTURE_POINT_TARGET)
		message_admins("Round finished: [MODE_COMBAT_PATROL_SOM_MAJOR]")
		round_finished = MODE_COMBAT_PATROL_SOM_MAJOR
		return TRUE

	if(XENO_cap_points >= CAPTURE_POINT_TARGET)
		message_admins("Round finished: [MODE_INFESTATION_X_MAJOR]")
		round_finished = MODE_INFESTATION_X_MAJOR
		return TRUE
