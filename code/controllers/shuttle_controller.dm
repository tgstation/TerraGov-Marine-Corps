var/global/datum/controller/shuttle_controller/shuttle_controller


/datum/controller/shuttle_controller
	var/list/shuttles	//maps shuttle tags to shuttle datums, so that they can be looked up.
	var/list/process_shuttles	//simple list of shuttles, for processing
	var/list/locs_crash

/datum/controller/shuttle_controller/process()
	//process ferry shuttles
	for (var/datum/shuttle/ferry/shuttle in process_shuttles)

		// Hacky bullshit that should only apply for shuttle/marine's for now.
		if (shuttle.move_scheduled)
			spawn(-1)
				move_shuttle_to(shuttle.target_turf, 0, shuttle.shuttle_turfs, 0, shuttle.target_rotation, shuttle)

		if (shuttle.process_state)
			shuttle.process()


/datum/controller/shuttle_controller/New()
	shuttles = list()
	process_shuttles = list()
	locs_crash = list()

	var/datum/shuttle/ferry/marine/shuttle1 //Because I am using shuttle_tag, which is only defined under /datum/shuttle/ferry/marine
	//ALMAYER DROPSHIP 1
	shuttle1 = new
	shuttle1.location = 0
	shuttle1.warmup_time = 10
	shuttle1.move_time = DROPSHIP_TRANSIT_DURATION
	shuttle1.shuttle_tag = "[CONFIG_GET(string/ship_name)] Dropship 1"
	shuttle1.info_tag = "[CONFIG_GET(string/ship_name)] Dropship"
	shuttle1.can_be_optimized = TRUE
	shuttle1.can_do_gun_mission = TRUE
	shuttle1.load_datums()
	shuttles[shuttle1.shuttle_tag] = shuttle1
	process_shuttles += shuttle1

	//ALMAYER DROPSHIP 2
	shuttle1 = new
	shuttle1.location = 0
	shuttle1.warmup_time = 10
	shuttle1.move_time = DROPSHIP_TRANSIT_DURATION
	shuttle1.shuttle_tag = "[CONFIG_GET(string/ship_name)] Dropship 2"
	shuttle1.info_tag = "[CONFIG_GET(string/ship_name)] Dropship"
	shuttle1.can_be_optimized = TRUE
	shuttle1.can_do_gun_mission = TRUE
	shuttle1.load_datums()
	shuttles[shuttle1.shuttle_tag] = shuttle1
	process_shuttles += shuttle1

	// Distress Shuttles - ERT
	var/datum/shuttle/ferry/ert/ES
	ES = new ()
	ES.location = 1

	for(var/area/A in all_areas)
		if(A.type == /area/shuttle/distress/start)
			ES.area_offsite = A
			break

	for(var/area/A in all_areas)
		if(A.type == /area/shuttle/distress/arrive_1)
			ES.area_station = A
			break

	for(var/area/A in all_areas)
		if(A.type == /area/shuttle/distress/transit)
			ES.area_transition = A
			break

	shuttles["Distress"] = ES
	process_shuttles += ES


	//PMC ert shuttle

	ES = new ()
	ES.location = 1

	for(var/area/A in all_areas)
		if(A.type == /area/shuttle/distress/start_pmc)
			ES.area_offsite = A
			break

	for(var/area/A in all_areas)
		if(A.type == /area/shuttle/distress/arrive_2)
			ES.area_station = A
			break

	for(var/area/A in all_areas)
		if(A.type == /area/shuttle/distress/transit_pmc)
			ES.area_transition = A
			break

	shuttles["Distress_PMC"] = ES
	process_shuttles += ES


	//UPP ert shuttle

	ES = new()
	ES.location = 1

	for(var/area/A in all_areas)
		if(A.type == /area/shuttle/distress/start_upp)
			ES.area_offsite = A
			break

	for(var/area/A in all_areas)
		if(A.type == /area/shuttle/distress/arrive_3)
			ES.area_station = A
			break

	for(var/area/A in all_areas)
		if(A.type == /area/shuttle/distress/transit_upp)
			ES.area_transition = A
			break

	shuttles["Distress_UPP"] = ES
	process_shuttles += ES


	//Big ert Shuttle

	ES = new()
	ES.location = 1
	ES.use_umbilical = TRUE

	for(var/area/A in all_areas)
		if(A.type == /area/shuttle/distress/start_big)
			ES.area_offsite = A
			break

	for(var/area/A in all_areas)
		if(A.type == /area/shuttle/distress/arrive_n_hangar)
			ES.area_station = A
			break

	for(var/area/A in all_areas)
		if(A.type == /area/shuttle/distress/transit_big)
			ES.area_transition = A
			break

	shuttles["Distress_Big"] = ES
	process_shuttles += ES

//This is called by gameticker after all the machines and radio frequencies have been properly initialized
/datum/controller/shuttle_controller/proc/setup_shuttle_docks()
	return

/datum/controller/shuttle_controller/stat_entry()
	if(!statclick)
		statclick = new/obj/effect/statclick/debug(null, "Debug", src)
	stat("Shuttle:", statclick)