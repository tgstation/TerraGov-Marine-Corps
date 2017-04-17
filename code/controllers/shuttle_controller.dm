
var/global/datum/shuttle_controller/shuttle_controller


/datum/shuttle_controller
	var/list/shuttles	//maps shuttle tags to shuttle datums, so that they can be looked up.
	var/list/process_shuttles	//simple list of shuttles, for processing

/datum/shuttle_controller/proc/process()
	//process ferry shuttles
	for (var/datum/shuttle/ferry/shuttle in process_shuttles)
		if (shuttle.process_state)
			shuttle.process()


/datum/shuttle_controller/New()
	shuttles = list()
	process_shuttles = list()

	var/datum/shuttle/ferry/shuttle

	// Escape shuttle and pods
	shuttle = new/datum/shuttle/ferry/emergency()
	shuttle.location = 1
	shuttle.warmup_time = 10
	shuttle.area_offsite = locate(/area/shuttle/escape/centcom)
	shuttle.area_station = locate(/area/shuttle/escape/station)
	shuttle.area_transition = locate(/area/shuttle/escape/transit)
	shuttle.transit_direction = NORTH
	shuttle.move_time = SHUTTLE_TRANSIT_DURATION_RETURN
	shuttles["Escape"] = shuttle
	process_shuttles += shuttle

	shuttle = new/datum/shuttle/ferry/escape_pod()
	shuttle.location = 0
	shuttle.warmup_time = 0
	shuttle.area_station = locate(/area/shuttle/escape_pod1/station)
	shuttle.area_offsite = locate(/area/shuttle/escape_pod1/centcom)
	shuttle.area_transition = locate(/area/shuttle/escape_pod1/transit)
	shuttle.transit_direction = NORTH
	shuttle.move_time = SHUTTLE_TRANSIT_DURATION_RETURN
	process_shuttles += shuttle
	shuttles["Escape Pod 1"] = shuttle

	shuttle = new/datum/shuttle/ferry/escape_pod()
	shuttle.location = 0
	shuttle.warmup_time = 0
	shuttle.area_station = locate(/area/shuttle/escape_pod2/station)
	shuttle.area_offsite = locate(/area/shuttle/escape_pod2/centcom)
	shuttle.area_transition = locate(/area/shuttle/escape_pod2/transit)
	shuttle.transit_direction = NORTH
	shuttle.move_time = SHUTTLE_TRANSIT_DURATION_RETURN
	process_shuttles += shuttle
	shuttles["Escape Pod 2"] = shuttle

	shuttle = new/datum/shuttle/ferry/escape_pod()
	shuttle.location = 0
	shuttle.warmup_time = 0
	shuttle.area_station = locate(/area/shuttle/escape_pod3/station)
	shuttle.area_offsite = locate(/area/shuttle/escape_pod3/centcom)
	shuttle.area_transition = locate(/area/shuttle/escape_pod3/transit)
	shuttle.transit_direction = EAST
	shuttle.move_time = SHUTTLE_TRANSIT_DURATION_RETURN
	process_shuttles += shuttle
	shuttles["Escape Pod 3"] = shuttle

	//There is no pod 4, apparently.

	shuttle = new/datum/shuttle/ferry/escape_pod()
	shuttle.location = 0
	shuttle.warmup_time = 0
	shuttle.area_station = locate(/area/shuttle/escape_pod5/station)
	shuttle.area_offsite = locate(/area/shuttle/escape_pod5/centcom)
	shuttle.area_transition = locate(/area/shuttle/escape_pod5/transit)
	shuttle.transit_direction = EAST //should this be WEST? I have no idea.
	shuttle.move_time = SHUTTLE_TRANSIT_DURATION_RETURN
	process_shuttles += shuttle
	shuttles["Escape Pod 5"] = shuttle

	//give the emergency shuttle controller it's shuttles
	emergency_shuttle.shuttle = shuttles["Escape"]
	emergency_shuttle.escape_pods = list(
		shuttles["Escape Pod 1"],
		shuttles["Escape Pod 2"],
		shuttles["Escape Pod 3"],
		shuttles["Escape Pod 5"],
	)

	// Supply shuttle
	shuttle = new/datum/shuttle/ferry/supply()
	shuttle.location = 1
	shuttle.warmup_time = 10
	shuttle.area_offsite = locate(/area/supply/dock)
	shuttle.area_station = locate(/area/supply/station)
	shuttles["Supply"] = shuttle
	process_shuttles += shuttle

	supply_controller.shuttle = shuttle

	// Admin shuttles.
	shuttle = new()
	shuttle.location = 1
	shuttle.warmup_time = 10
	shuttle.area_offsite = locate(/area/shuttle/transport1/centcom)
	shuttle.area_station = locate(/area/shuttle/transport1/station)
	shuttles["Centcom"] = shuttle
	process_shuttles += shuttle

	shuttle = new()
	shuttle.location = 1
	shuttle.warmup_time = 10	//want some warmup time so people can cancel.
	shuttle.area_offsite = locate(/area/shuttle/administration/centcom)
	shuttle.area_station = locate(/area/shuttle/administration/station)
	shuttles["Administration"] = shuttle
	process_shuttles += shuttle


/*
	shuttle = new()
	shuttle.area_offsite = locate(/area/shuttle/alien/base)
	shuttle.area_station = locate(/area/shuttle/alien/mine)
	shuttles["Alien"] = shuttle
	//process_shuttles += shuttle	//don't need to process this. It can only be moved using admin magic anyways.
*/

	// NMV SULACO - Shuttle
	var/datum/shuttle/ferry/marine/shuttle1 = new //Because I am using shuttle_tag, which is only defined under /datum/shuttle/ferry/marine
	shuttle1.location = 0
	shuttle1.warmup_time = 10
	shuttle1.can_be_optimized = 1 //This shuttle uses complex flight maneuvers and can be optimized
	shuttle1.transit_direction = NORTH
	shuttle1.move_time = DROPSHIP_TRANSIT_DURATION
	shuttle1.shuttle_tag = "Dropship 1"
	shuttle1.load_datums()
	shuttles["Dropship 1"] = shuttle1
	process_shuttles += shuttle1

	// NMV SULACO - DropPod
	shuttle1 = new
	shuttle1.location = 0
	shuttle1.warmup_time = 10
	shuttle1.transit_direction = NORTH
	shuttle1.move_time = DROPPOD_TRANSIT_DURATION
	shuttle1.shuttle_tag = "Dropship 2"
	shuttle1.load_datums()
	shuttles["Dropship 2"] = shuttle1
	process_shuttles += shuttle1

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


	// ERT Shuttle
	var/datum/shuttle/ferry/multidock/specops/ERT = new()
	ERT.location = 0
	ERT.warmup_time = 10
	ERT.area_offsite = locate(/area/shuttle/specops/station)	//centcom is the home station, the Exodus is offsite
	ERT.area_station = locate(/area/shuttle/specops/centcom)
	shuttles["Special Operations"] = ERT
	process_shuttles += ERT

//This is called by gameticker after all the machines and radio frequencies have been properly initialized
/datum/shuttle_controller/proc/setup_shuttle_docks()
	var/datum/shuttle/shuttle
	var/datum/shuttle/ferry/multidock/multidock
	var/list/dock_controller_map = list()	//so we only have to iterate once through each list

	//multidock shuttles
	var/list/dock_controller_map_station = list()
	var/list/dock_controller_map_offsite = list()

	for (var/shuttle_tag in shuttles)
		shuttle = shuttles[shuttle_tag]
		if (shuttle.docking_controller_tag)
			dock_controller_map[shuttle.docking_controller_tag] = shuttle
		if (istype(shuttle, /datum/shuttle/ferry/multidock))
			multidock = shuttle
			dock_controller_map_station[multidock.docking_controller_tag_station] = multidock
			dock_controller_map_offsite[multidock.docking_controller_tag_offsite] = multidock

	//escape pod arming controllers
	var/datum/shuttle/ferry/escape_pod/pod
	var/list/pod_controller_map = list()
	for (var/datum/shuttle/ferry/escape_pod/P in emergency_shuttle.escape_pods)
		if (P.dock_target_station)
			pod_controller_map[P.dock_target_station] = P

	//search for the controllers, if we have one.
	if (dock_controller_map.len)
		for (var/obj/machinery/embedded_controller/radio/C in machines)	//only radio controllers are supported at the moment
			if (istype(C.program, /datum/computer/file/embedded_program/docking))
				if (C.id_tag in dock_controller_map)
					shuttle = dock_controller_map[C.id_tag]
					shuttle.docking_controller = C.program
					dock_controller_map -= C.id_tag

					//escape pods
					if(istype(C, /obj/machinery/embedded_controller/radio/simple_docking_controller/escape_pod) && istype(shuttle, /datum/shuttle/ferry/escape_pod))
						var/obj/machinery/embedded_controller/radio/simple_docking_controller/escape_pod/EPC = C
						EPC.pod = shuttle

				if (C.id_tag in dock_controller_map_station)
					multidock = dock_controller_map_station[C.id_tag]
					if (istype(multidock))
						multidock.docking_controller_station = C.program
						dock_controller_map_station -= C.id_tag
				if (C.id_tag in dock_controller_map_offsite)
					multidock = dock_controller_map_offsite[C.id_tag]
					if (istype(multidock))
						multidock.docking_controller_offsite = C.program
						dock_controller_map_offsite -= C.id_tag

				//escape pods
				if (C.id_tag in pod_controller_map)
					pod = pod_controller_map[C.id_tag]
					if (istype(C.program, /datum/computer/file/embedded_program/docking/simple/escape_pod/))
						pod.arming_controller = C.program

	//sanity check
	//NO SANITY
//	if (dock_controller_map.len || dock_controller_map_station.len || dock_controller_map_offsite.len)
//		var/dat = ""
//		for (var/dock_tag in dock_controller_map + dock_controller_map_station + dock_controller_map_offsite)
//			dat += "\"[dock_tag]\", "
//		world << "\red \b warning: shuttles with docking tags [dat] could not find their controllers!"

	//makes all shuttles docked to something at round start go into the docked state
	for (var/shuttle_tag in shuttles)
		shuttle = shuttles[shuttle_tag]
		shuttle.dock()
