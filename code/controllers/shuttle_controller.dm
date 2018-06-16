var/global/datum/shuttle_controller/shuttle_controller


/datum/shuttle_controller
	var/list/shuttles	//maps shuttle tags to shuttle datums, so that they can be looked up.
	var/list/process_shuttles	//simple list of shuttles, for processing
	var/list/locs_crash

/datum/shuttle_controller/proc/process()
	//process ferry shuttles
	for (var/datum/shuttle/ferry/shuttle in process_shuttles)

		// Hacky bullshit that should only apply for shuttle/marine's for now.
		if (shuttle.move_scheduled)
			spawn(-1)
				move_shuttle_to(shuttle.target_turf, 0, shuttle.shuttle_turfs, 0, shuttle.target_rotation, shuttle)

		if (shuttle.process_state)
			shuttle.process()


/datum/shuttle_controller/New()
	shuttles = list()
	process_shuttles = list()
	locs_crash = list()

	var/datum/shuttle/ferry/shuttle

	// Hangar Elevator
	shuttle = new/datum/shuttle/ferry/hangar()
	shuttle.location = 1
	shuttle.warmup_time = 3
	shuttle.move_time = ELEVATOR_TRANSIT_DURATION
	for(var/area/A in all_areas)
		if(A.type == /area/shuttle/almayer/elevator_hangar/lowerdeck)
			shuttle.area_offsite = A
			break

	for(var/area/A in all_areas)
		if(A.type == /area/shuttle/almayer/elevator_hangar/underdeck)
			shuttle.area_station = A
			break

	var/datum/shuttle/ferry/hangar/hangarelevator = shuttle
	hangarelevator.lower_railings() // to deal with railings being up

	shuttles["Hangar"] = shuttle
	process_shuttles += shuttle

	supply_controller.shuttle = shuttle

	// Maintenance Elevator
	shuttle = new/datum/shuttle/ferry/hangar/maintenance()
	shuttle.location = 1
	shuttle.warmup_time = 3
	shuttle.move_time = ELEVATOR_TRANSIT_DURATION
	for(var/area/A in all_areas)
		if(A.type == /area/shuttle/almayer/elevator_maintenance/upperdeck)
			shuttle.area_offsite = A
			break

	for(var/area/A in all_areas)
		if(A.type == /area/shuttle/almayer/elevator_maintenance/lowerdeck)
			shuttle.area_station = A
			break

	var/datum/shuttle/ferry/hangar/maintenance/maintenance_elevator = shuttle
	maintenance_elevator.lower_railings() // to deal with railings being up

	shuttles["Maintenance"] = shuttle
	process_shuttles += shuttle

	supply_controller.shuttle = shuttle


	// Supply shuttle
	shuttle = new/datum/shuttle/ferry/supply()
	shuttle.location = 1
	shuttle.warmup_time = 3
	shuttle.move_time = ELEVATOR_TRANSIT_DURATION
	for(var/area/A in all_areas)
		if(A.type == /area/supply/dock)
			shuttle.area_offsite = A
			break

	for(var/area/A in all_areas)
		if(A.type == /area/supply/station)
			shuttle.area_station = A
			break

	shuttles["Supply"] = shuttle
	process_shuttles += shuttle

	supply_controller.shuttle = shuttle

	var/datum/shuttle/ferry/marine/shuttle1 //Because I am using shuttle_tag, which is only defined under /datum/shuttle/ferry/marine
	//ALMAYER DROPSHIP 1
	shuttle1 = new
	shuttle1.location = 0
	shuttle1.warmup_time = 10
	shuttle1.move_time = DROPSHIP_TRANSIT_DURATION
	shuttle1.shuttle_tag = "[MAIN_SHIP_NAME] Dropship 1"
	shuttle1.info_tag = "Almayer Dropship"
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
	shuttle1.shuttle_tag = "[MAIN_SHIP_NAME] Dropship 2"
	shuttle1.info_tag = "Almayer Dropship"
	shuttle1.can_be_optimized = TRUE
	shuttle1.can_do_gun_mission = TRUE
	shuttle1.load_datums()
	shuttles[shuttle1.shuttle_tag] = shuttle1
	process_shuttles += shuttle1

	//START: ALMAYER SHUTTLES AND EVAC PODS
	var/datum/shuttle/ferry/marine/evacuation_pod/P
	for(var/i = 1 to MAIN_SHIP_ESCAPE_POD_NUMBER)
		P = new
		P.shuttle_tag = MAIN_SHIP_NAME + " Evac [i]"
		switch(i) //TODO: Do this procedurally.
			if(10 to 11) P.info_tag = "Alt Almayer Evac"
		P.load_datums()
		shuttles[P.shuttle_tag] = P
		process_shuttles += P


	//END: ALMAYER SHUTTLES AND EVAC PODS

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






//---ELEVATOR---//
	// Elevator I
	shuttle = new /datum/shuttle/ferry/elevator()
	shuttle.location = 0
	shuttle.warmup_time = 10
	shuttle.recharge_time = ELEVATOR_RECHARGE

	for(var/area/A in all_areas)
		if(A.type == /area/shuttle/elevator1/underground)
			shuttle.area_offsite = A
			break

	for(var/area/A in all_areas)
		if(A.type == /area/shuttle/elevator1/ground)
			shuttle.area_station = A
			break

	for(var/area/A in all_areas)
		if(A.type == /area/shuttle/elevator1/transit)
			shuttle.area_transition = A
			break

	shuttle.move_time = ELEVATOR_TRANSIT_DURATION
	shuttle.iselevator = 1
	shuttles["Elevator 1"] = shuttle
	process_shuttles += shuttle

	// Elevator II
	shuttle = new /datum/shuttle/ferry/elevator()
	shuttle.location = 0
	shuttle.warmup_time = 10
	shuttle.recharge_time = ELEVATOR_RECHARGE

	for(var/area/A in all_areas)
		if(A.type == /area/shuttle/elevator2/underground)
			shuttle.area_offsite = A
			break

	for(var/area/A in all_areas)
		if(A.type == /area/shuttle/elevator2/ground)
			shuttle.area_station = A
			break

	for(var/area/A in all_areas)
		if(A.type == /area/shuttle/elevator2/transit)
			shuttle.area_transition = A
			break

	shuttle.transit_direction = NORTH
	shuttle.move_time = ELEVATOR_TRANSIT_DURATION
	shuttle.iselevator = 1
	shuttles["Elevator 2"] = shuttle
	process_shuttles += shuttle

	// Elevator III
	shuttle = new /datum/shuttle/ferry/elevator()
	shuttle.location = 0
	shuttle.warmup_time = 10
	shuttle.recharge_time = ELEVATOR_RECHARGE
	for(var/area/A in all_areas)
		if(A.type == /area/shuttle/elevator3/underground)
			shuttle.area_offsite = A
			break

	for(var/area/A in all_areas)
		if(A.type == /area/shuttle/elevator3/ground)
			shuttle.area_station = A
			break

	for(var/area/A in all_areas)
		if(A.type == /area/shuttle/elevator3/transit)
			shuttle.area_transition = A
			break
	shuttle.transit_direction = NORTH
	shuttle.move_time = ELEVATOR_TRANSIT_DURATION
	shuttle.iselevator = 1
	shuttles["Elevator 3"] = shuttle
	process_shuttles += shuttle

	// Elevator IV
	shuttle = new /datum/shuttle/ferry/elevator()
	shuttle.location = 0
	shuttle.warmup_time = 10
	shuttle.recharge_time = ELEVATOR_RECHARGE
	for(var/area/A in all_areas)
		if(A.type == /area/shuttle/elevator4/underground)
			shuttle.area_offsite = A
			break

	for(var/area/A in all_areas)
		if(A.type == /area/shuttle/elevator4/ground)
			shuttle.area_station = A
			break

	for(var/area/A in all_areas)
		if(A.type == /area/shuttle/elevator4/transit)
			shuttle.area_transition = A
			break
	shuttle.transit_direction = NORTH
	shuttle.move_time = ELEVATOR_TRANSIT_DURATION
	shuttle.iselevator = 1
	shuttles["Elevator 4"] = shuttle
	process_shuttles += shuttle

//This is called by gameticker after all the machines and radio frequencies have been properly initialized
/datum/shuttle_controller/proc/setup_shuttle_docks()
	var/datum/shuttle/shuttle
	var/list/dock_controller_map = list()	//so we only have to iterate once through each list

	for(var/shuttle_tag in shuttles)
		shuttle = shuttles[shuttle_tag]
		if(istype(shuttle, /datum/shuttle/ferry/marine)) continue //Evac pods ignore this, as do other marine ferries.
		if(shuttle.docking_controller_tag)
			dock_controller_map[shuttle.docking_controller_tag] = shuttle

	//search for the controllers, if we have one.
	if(dock_controller_map.len)
		for(var/obj/machinery/embedded_controller/radio/C in machines)	//only radio controllers are supported at the moment
			if (istype(C.program, /datum/computer/file/embedded_program/docking))
				if(C.id_tag in dock_controller_map)
					shuttle = dock_controller_map[C.id_tag]
					shuttle.docking_controller = C.program
					dock_controller_map -= C.id_tag


	//sanity check
	//NO SANITY
//	if (dock_controller_map.len || dock_controller_map_station.len || dock_controller_map_offsite.len)
//		var/dat = ""
//		for (var/dock_tag in dock_controller_map + dock_controller_map_station + dock_controller_map_offsite)
//			dat += "\"[dock_tag]\", "
//		world << "\red \b warning: shuttles with docking tags [dat] could not find their controllers!"

	//makes all shuttles docked to something at round start go into the docked state
	for(var/shuttle_tag in shuttles)
		shuttle = shuttles[shuttle_tag]
		shuttle.dock()
