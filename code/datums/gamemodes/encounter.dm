/datum/game_mode/hvh/combat_patrol/encounter
	name = "Encounter"
	config_tag = "Encounter"
	round_type_flags = MODE_LATE_OPENING_SHUTTER_TIMER|MODE_TWO_HUMAN_FACTIONS|MODE_INFESTATION|MODE_PSY_POINTS|MODE_SILO_RESPAWN|MODE_ENCOUNTER|MODE_HUMAN_ONLY
	xeno_abilities_flags = ABILITY_ENCOUNTER
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
	)
	job_points_needed_by_job_type = list(
		/datum/job/terragov/squad/smartgunner = 5,
		/datum/job/som/squad/veteran = 5,
		/datum/job/xenomorph = ENCOUNTER_LARVA_POINTS_NEEDED,
	)
	var/list/evo_requirements = list(
		/datum/xeno_caste/queen = 6,
	)
	wave_timer_length = 2 MINUTES
	max_game_time = 60 MINUTES
	game_timer_delay = 0
	whitelist_ship_maps = list(MAP_COMBAT_PATROL_BASE)
	blacklist_ship_maps = null
	whitelist_ground_maps = list(MAP_BIG_RED, MAP_ICE_COLONY, MAP_ICY_CAVES, MAP_DESPARITY, MAP_CORSAT, MAP_RESEARCH_OUTPOST, MAP_BLUESUMMERS, MAP_KUTJEVO_REFINERY, MAP_GELIDA_IV)

	var/capture_point_target = 900
	///TGMC's point count
	var/tgmc_cap_points = 0
	///SOM's point count
	var/som_cap_points = 0
	///Xenos' point count
	var/xeno_cap_points = 0
	///Tower req value for owning faction per process()
	var/tower_req_value = 5
	///Tower xeno tactical point value for owning faction per process()
	var/tower_xeno_tactical_point_value = 1
	///Tower xeno strategic point value for owning faction per process()
	var/tower_xeno_strategic_point_value = 3

/datum/game_mode/hvh/combat_patrol/encounter/announce()
	to_chat(world, "<b>The current game mode is - Free for all!</b>")
	to_chat(world, "<b>SOM and Terragov forces are fighting for control of this sector and an alien threat has emerged, capture the sensor towers for your team.</b>")

/datum/game_mode/hvh/combat_patrol/encounter/get_deploy_point_message(mob/living/user)
	. = "Capture as many sensor towers as possible, deny them to the other team."

/datum/game_mode/hvh/combat_patrol/encounter/process()
	. = ..()
	for(var/obj/structure/campaign_objective/capture_objective/sensor_tower/tower in GLOB.campaign_objectives)
		if(tower.owning_faction == FACTION_TERRAGOV)
			tgmc_cap_points += 1
			SSpoints.supply_points[FACTION_TERRAGOV] += tower_req_value
		else if(tower.owning_faction == FACTION_SOM)
			som_cap_points+= 1
			SSpoints.supply_points[FACTION_SOM] += tower_req_value
		else if(tower.owning_faction == FACTION_XENO)
			xeno_cap_points += 1
			SSpoints.add_tactical_psy_points(XENO_HIVE_NORMAL, tower_xeno_tactical_point_value)
			SSpoints.add_strategic_psy_points(XENO_HIVE_NORMAL, tower_xeno_strategic_point_value)

/datum/game_mode/hvh/combat_patrol/encounter/post_setup()
	. = ..()

	var/num_towers = max(3, (floor(length(GLOB.clients) / 5)))
	capture_point_target = num_towers * 300

	for(num_towers, num_towers < length(GLOB.sensor_towers))
		GLOB.sensor_towers -= pick(GLOB.sensor_towers)

	for(var/turf/T AS in GLOB.sensor_towers)
		new /obj/structure/campaign_objective/capture_objective/sensor_tower(T)

	for(var/i in GLOB.xeno_encounter_resin_silo_turfs)
		new /obj/structure/xeno/silo(i)

	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_HVH_REQ)

	// Apply Evolution Xeno Population Locks:
	for(var/datum/xeno_caste/caste AS in evo_requirements)
		GLOB.xeno_caste_datums[caste][XENO_UPGRADE_BASETYPE].evolve_min_xenos = evo_requirements[caste]

	respawn_wave(FALSE)

/datum/game_mode/hvh/combat_patrol/encounter/get_status_tab_items(datum/dcs, mob/source, list/items)
	. = ..()
	items += "Terragov Marine Corps capture points: [tgmc_cap_points]/[capture_point_target]"
	items += "Sons of Mars capture points: [som_cap_points]/[capture_point_target]"
	items += "Xenomorph capture points: [xeno_cap_points]/[capture_point_target]"

//End game checks
/datum/game_mode/hvh/combat_patrol/encounter/check_finished()
	if(round_finished)
		return TRUE

	if(tgmc_cap_points >= capture_point_target)
		if((som_cap_points >= capture_point_target) || (xeno_cap_points >= capture_point_target))
			message_admins("Round finished: [MODE_COMBAT_PATROL_DRAW]")
			round_finished = MODE_COMBAT_PATROL_DRAW
			return TRUE
		message_admins("Round finished: [MODE_COMBAT_PATROL_MARINE_MAJOR]")
		round_finished = MODE_COMBAT_PATROL_MARINE_MAJOR
		return TRUE

	if(som_cap_points >= capture_point_target)
		if((tgmc_cap_points >= capture_point_target) || (xeno_cap_points >= capture_point_target))
			message_admins("Round finished: [MODE_COMBAT_PATROL_DRAW]")
			round_finished = MODE_COMBAT_PATROL_DRAW
			return TRUE
		message_admins("Round finished: [MODE_COMBAT_PATROL_SOM_MAJOR]")
		round_finished = MODE_COMBAT_PATROL_SOM_MAJOR
		return TRUE

	if(xeno_cap_points >= capture_point_target)
		if((som_cap_points >= capture_point_target) || (tgmc_cap_points >= capture_point_target))
			message_admins("Round finished: [MODE_COMBAT_PATROL_DRAW]")
			round_finished = MODE_COMBAT_PATROL_DRAW
			return TRUE
		message_admins("Round finished: [MODE_INFESTATION_X_MAJOR]")
		round_finished = MODE_INFESTATION_X_MAJOR
		return TRUE

/datum/game_mode/hvh/combat_patrol/encounter/respawn_wave(repeat = TRUE)
	var/list/player_list = count_humans(SSmapping.levels_by_trait(ZTRAIT_GROUND), COUNT_IGNORE_ALIVE_SSD)
	var/active_som = length(player_list[1])
	var/active_tgmc = length(player_list[2])
	for(var/mob/dead/observer/o in GLOB.observer_list)//Recently dead are active because they will be respawned now too
		if(DEATHTIME_CHECK(o))
			if(o.faction == FACTION_TERRAGOV)
				active_tgmc++
			else if(o.faction ==FACTION_SOM)
				active_som++
	var/active_humans = active_som + active_tgmc

	. = ..()

	var/datum/job/xeno_job = SSjob.GetJobType(/datum/job/xenomorph)
	var/num_xenos = xeno_job.total_positions - xeno_job.current_positions //burrowed

	for(var/mob/living/carbon/xenomorph/xeno AS in GLOB.alive_xeno_list_hive[XENO_HIVE_NORMAL])
		if(xeno.xeno_caste.caste_flags & CASTE_IS_A_MINION)
			continue
		num_xenos++

	var/desired_xeno_count = max(2, floor(active_humans/ ENCOUNTER_XENO_HUMAN_RATIO))
	var/xenos_to_add = desired_xeno_count - num_xenos

	if(xenos_to_add > 0)
		xeno_job.total_positions += xenos_to_add
