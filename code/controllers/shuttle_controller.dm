var/global/datum/shuttle_controller/shuttle_controller


/datum/shuttle_controller
	var/list/shuttles	//maps shuttle tags to shuttle datums, so that they can be looked up.
	var/list/process_shuttles	//simple list of shuttles, for processing
	var/list/locs_crash

/datum/shuttle_controller/proc/process()
	//process ferry shuttles
	for (var/datum/shuttle/ferry/shuttle in process_shuttles)
		if (shuttle.process_state)
			shuttle.process()


/datum/shuttle_controller/New()
	shuttles = list()
	process_shuttles = list()
	locs_crash = list()

	var/datum/shuttle/ferry/shuttle

	// Supply shuttle
	shuttle = new/datum/shuttle/ferry/supply()
	shuttle.location = 1
	shuttle.warmup_time = 10
	shuttle.area_offsite = locate(/area/supply/dock)
	shuttle.area_station = locate(/area/supply/station)
	shuttles["Supply"] = shuttle
	process_shuttles += shuttle

	supply_controller.shuttle = shuttle

	var/datum/shuttle/ferry/marine/shuttle1 = new //Because I am using shuttle_tag, which is only defined under /datum/shuttle/ferry/marine
	//ALMAYER DROPSHIP 1
	shuttle1 = new
	shuttle1.location = 0
	shuttle1.warmup_time = 10
	shuttle1.move_time = DROPPOD_TRANSIT_DURATION
	shuttle1.shuttle_tag = "[MAIN_SHIP_NAME] Dropship 1"
	shuttle1.info_tag = "Almayer Dropship"
	shuttle1.load_datums()
	shuttles[shuttle1.shuttle_tag] = shuttle1
	process_shuttles += shuttle1

	//ALMAYER DROPSHIP 2
	shuttle1 = new
	shuttle1.location = 0
	shuttle1.warmup_time = 10
	shuttle1.move_time = DROPPOD_TRANSIT_DURATION
	shuttle1.shuttle_tag = "[MAIN_SHIP_NAME] Dropship 2"
	shuttle1.info_tag = "Almayer Dropship"
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

	// Distress Shuttle - ERT
	shuttle = new()
	shuttle.location = 1
	shuttle.warmup_time = 10
	shuttle.area_offsite = locate(/area/shuttle/distress_start)
	shuttle.area_station = pick(locate(/area/shuttle/distress_arrive_1),locate(/area/shuttle/distress_arrive_2),locate(/area/shuttle/distress_arrive_3))
	shuttle.area_transition = locate(/area/shuttle/distress_transit)
	shuttle.transit_direction = NORTH
	shuttle.move_time = DROPSHIP_TRANSIT_DURATION
	shuttles["Distress"] = shuttle
	process_shuttles += shuttle

//---ELEVATOR---//
	// Elevator I
	shuttle = new()
	shuttle.location = 0
	shuttle.warmup_time = 20
	shuttle.recharge_time = ELEVATOR_RECHARGE
	shuttle.area_offsite = locate(/area/shuttle/elevator1/underground)
	shuttle.area_station = locate(/area/shuttle/elevator1/ground)
	shuttle.area_transition = locate(/area/shuttle/elevator1/transit)
	shuttle.move_time = ELEVATOR_TRANSIT_DURATION
	shuttle.iselevator = 1
	shuttles["Elevator 1"] = shuttle
	process_shuttles += shuttle

	// Elevator II
	shuttle = new()
	shuttle.location = 0
	shuttle.warmup_time = 20
	shuttle.recharge_time = ELEVATOR_RECHARGE
	shuttle.area_offsite = locate(/area/shuttle/elevator2/underground)
	shuttle.area_station = locate(/area/shuttle/elevator2/ground)
	shuttle.area_transition = locate(/area/shuttle/elevator2/transit)
	shuttle.transit_direction = NORTH
	shuttle.move_time = ELEVATOR_TRANSIT_DURATION
	shuttle.iselevator = 1
	shuttles["Elevator 2"] = shuttle
	process_shuttles += shuttle

	// Elevator III
	shuttle = new()
	shuttle.location = 0
	shuttle.warmup_time = 20
	shuttle.recharge_time = ELEVATOR_RECHARGE
	shuttle.area_offsite = locate(/area/shuttle/elevator3/underground)
	shuttle.area_station = locate(/area/shuttle/elevator3/ground)
	shuttle.area_transition = locate(/area/shuttle/elevator3/transit)
	shuttle.transit_direction = NORTH
	shuttle.move_time = ELEVATOR_TRANSIT_DURATION
	shuttle.iselevator = 1
	shuttles["Elevator 3"] = shuttle
	process_shuttles += shuttle

	// Elevator IV
	shuttle = new()
	shuttle.location = 0
	shuttle.warmup_time = 20
	shuttle.recharge_time = ELEVATOR_RECHARGE
	shuttle.area_offsite = locate(/area/shuttle/elevator4/underground)
	shuttle.area_station = locate(/area/shuttle/elevator4/ground)
	shuttle.area_transition = locate(/area/shuttle/elevator4/transit)
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

