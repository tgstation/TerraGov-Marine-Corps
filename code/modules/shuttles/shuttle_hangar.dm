/datum/shuttle/ferry/hangar
	iselevator = 1
	var/away_location = 1	//the location to hide at while pretending to be in-transit
	var/late_chance = 0
	var/max_late_time = 300
	var/railing_upper_id = "hangar_upper_railing"
	var/railing_lower_id = "hangar_lower_railing"
	var/gear_id = "hangarelevatorgear"
	//var/obj/effect/elevator/supply/SW //elevator effects
	//var/obj/effect/elevator/supply/SE
	//var/obj/effect/elevator/supply/NW
	//var/obj/effect/elevator/supply/NE
	var/HangarElevatorUpper_x
	var/HangarElevatorUpper_y
	var/HangarElevatorUpper_z
	var/HangarElevatorLower_x
	var/HangarElevatorLower_y
	var/HangarElevatorLower_z

/datum/shuttle/ferry/hangar/New()
	..()

	var/turf/HangarUpperElevatorLoc = get_turf(HangarUpperElevator)
	var/turf/HangarLowerElevatorLoc = get_turf(HangarLowerElevator)
	HangarElevatorUpper_x = HangarUpperElevatorLoc.x
	HangarElevatorUpper_y = HangarUpperElevatorLoc.y
	HangarElevatorUpper_z = HangarUpperElevatorLoc.z
	HangarElevatorLower_x = HangarLowerElevatorLoc.x
	HangarElevatorLower_y = HangarLowerElevatorLoc.y
	HangarElevatorLower_z = HangarLowerElevatorLoc.z

/datum/shuttle/ferry/hangar/process()

	switch(process_state)
		if (WAIT_LAUNCH)
			if(!preflight_checks())
				announce_preflight_failure()
				process_state = SHUTTLE_IDLE
				return .
			if (skip_docking_checks() || docking_controller.can_launch())

				//world << "shuttle/ferry/process: area_transition=[area_transition], travel_time=[travel_time]"
				if (move_time && area_transition)
					long_jump(interim=area_transition, travel_time=move_time, direction=transit_direction)
				else
					short_jump()

				process_state = WAIT_ARRIVE

		if (FORCE_LAUNCH)
			if (move_time && area_transition)
				long_jump(interim=area_transition, travel_time=move_time, direction=transit_direction)
			else
				short_jump()

			process_state = WAIT_ARRIVE

		if (WAIT_ARRIVE)
			if (moving_status == SHUTTLE_IDLE)
				dock()
				in_use = null	//release lock
				process_state = WAIT_FINISH

		if (WAIT_FINISH)
			if (skip_docking_checks() || docking_controller.docked() || world.time > last_dock_attempt_time + DOCK_ATTEMPT_TIMEOUT)
				process_state = IDLE_STATE
				arrived()

		if (FORCE_CRASH)
			short_jump_crash()

/datum/shuttle/ferry/hangar/proc/short_jump_crash(var/area/origin,var/area/destination)
	if(isnull(location))
		return

	for(var/obj/machinery/computer/shuttle_control/almayer/hangar/H in machines)
		cdel(H)
	lower_railings(1)
	if(!at_station())
		moving_status = SHUTTLE_INTRANSIT
		playsound(locate(HangarElevatorUpper_x,HangarElevatorUpper_y,HangarElevatorUpper_z), 'sound/effects/bang.ogg', 40, 0)
		playsound(locate(HangarElevatorLower_x,HangarElevatorLower_y,HangarElevatorLower_z), 'sound/effects/bang.ogg', 20, 0)
		lower_railings(1)

		if(!destination)
			destination = get_location_area(!location)
		if(!origin)
			origin = get_location_area(location)
		move(origin, destination)
	moving_status = SHUTTLE_CRASHED

/datum/shuttle/ferry/hangar/short_jump(var/area/origin,var/area/destination)
	if(moving_status != SHUTTLE_IDLE)
		return

	if(isnull(location))
		return

	recharging = 1

	if(!destination)
		destination = get_location_area(!location)
	if(!origin)
		origin = get_location_area(location)

	//it would be cool to play a sound here
	moving_status = SHUTTLE_WARMUP
	spawn(warmup_time*10)
		if (moving_status == SHUTTLE_IDLE)
			return	//someone cancelled the launch

		raise_railings()
		sleep(20)

		//We pretend it's a long_jump by making the shuttle stay at centcom for the "in-transit" period.
		var/area/away_area = get_location_area(away_location)
		moving_status = SHUTTLE_INTRANSIT

		playsound(locate(HangarElevatorLower_x,HangarElevatorLower_y,HangarElevatorLower_z), 'sound/machines/elevator_move.ogg', 50, 0)
		playsound(locate(HangarElevatorUpper_x,HangarElevatorUpper_y,HangarElevatorUpper_z), 'sound/machines/elevator_move.ogg', 50, 0)

		//If we are at the away_area then we are just pretending to move, otherwise actually do the move
		if (origin != away_area)
			start_gears(SOUTH)
			sleep(30)
			move(origin, away_area)
		else
			start_gears(NORTH)
			sleep(30)
			move(away_area, destination)
		sleep(20)
		moving_status = SHUTTLE_IDLE
		stop_gears()

		lower_railings()

		spawn(0)
			recharging = 0


/datum/shuttle/ferry/hangar/proc/at_station()
	return (!location)

//returns 1 if the shuttle is idle and we can still mess with the cargo shopping list
/datum/shuttle/ferry/hangar/proc/idle()
	return (moving_status == SHUTTLE_IDLE)

//returns the ETA in minutes
/datum/shuttle/ferry/hangar/proc/eta_minutes()
	var/ticksleft = arrive_time - world.time
	return round(ticksleft/600,1)

/datum/shuttle/ferry/hangar/proc/raise_railings()
	var/effective = 0
	for(var/obj/machinery/door/poddoor/M in machines)
		if((M.id == railing_lower_id || M.id == railing_upper_id) && !M.density)
			effective = 1
			spawn()
				M.close()
	if(effective)
		playsound(locate(HangarElevatorUpper_x,HangarElevatorUpper_y,HangarElevatorUpper_z), 'sound/machines/elevator_openclose.ogg', 50, 0)
		playsound(locate(HangarElevatorLower_x,HangarElevatorLower_y,HangarElevatorLower_z), 'sound/machines/elevator_openclose.ogg', 50, 0)


/datum/shuttle/ferry/hangar/proc/lower_railings(var/force=0)
	var/effective = 0
	var/railing_id
	var/turf/soundturf
	var/other_id
	if(at_station())
		railing_id = railing_lower_id
		other_id = railing_upper_id
		soundturf = locate(HangarElevatorLower_x,HangarElevatorLower_y,HangarElevatorLower_z)
	else
		railing_id = railing_upper_id
		other_id = railing_lower_id
		soundturf = locate(HangarElevatorUpper_x,HangarElevatorUpper_y,HangarElevatorUpper_z)
	for(var/obj/machinery/door/poddoor/M in machines)
		if(M.id == railing_id && M.density)
			effective = 1
			spawn()
				M.open()
		if(force && M.id == other_id && M.density)
			spawn()
				M.open()
	if(effective)
		playsound(soundturf, 'sound/machines/elevator_openclose.ogg', 50, 0)

/datum/shuttle/ferry/hangar/proc/start_gears(var/direction = 1)
	for(var/obj/machinery/gear/M in machines)
		if(M.id == gear_id)
			spawn()
				M.icon_state = "gear_moving"
				M.dir = direction

/datum/shuttle/ferry/hangar/proc/stop_gears()
	for(var/obj/machinery/gear/M in machines)
		if(M.id == gear_id)
			spawn()
				M.icon_state = "gear"

// Maintenance Elevator
/datum/shuttle/ferry/hangar/maintenance
	railing_upper_id = "maintenance_upper_railing"
	railing_lower_id = "maintenance_lower_railing"
	gear_id = "maintenance_elevator_strut"

/datum/shuttle/ferry/hangar/maintenance/start_gears(var/direction = 1)
	var/list/obj/machinery/elevator_strut/top/strut_top = list()
	var/list/obj/machinery/elevator_strut/bottom/strut_bottom = list()

	for (var/obj/machinery/elevator_strut/top/S in machines)
		if (S.id == gear_id)
			strut_top += S

	for (var/obj/machinery/elevator_strut/bottom/S in machines)
		if (S.id == gear_id)
			strut_bottom += S

	spawn()
		for (var/obj/x in strut_top)
			x.icon_state  = "strut_top_moving"
		for (var/obj/x in strut_bottom)
			x.icon_state = "strut_bottom_moving"

/datum/shuttle/ferry/hangar/maintenance/stop_gears()
	var/list/obj/machinery/elevator_strut/top/strut_top = list()
	var/list/obj/machinery/elevator_strut/bottom/strut_bottom = list()

	for (var/obj/machinery/elevator_strut/top/S in machines)
		if (S.id == gear_id)
			strut_top += S

	for (var/obj/machinery/elevator_strut/bottom/S in machines)
		if (S.id == gear_id)
			strut_bottom += S

	spawn()
		for (var/obj/x in strut_top)
			x.icon_state  = "strut_top"
		for (var/obj/x in strut_bottom)
			x.icon_state = "strut_bottom"
