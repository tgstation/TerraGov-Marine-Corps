


/datum/shuttle/ferry/ert
	transit_direction = NORTH
	move_time = DROPSHIP_TRANSIT_DURATION
	var/use_umbilical = FALSE

/datum/shuttle/ferry/ert/can_launch()
	//ert shuttle at the start area.
	if(moving_status == SHUTTLE_IDLE && location == 1)
		for(var/datum/shuttle/ferry/ert/F in shuttle_controller.process_shuttles)
			if(F != src)
				//other ERT shuttles already docked on almayer or about to be
				if(!F.location || F.moving_status != SHUTTLE_IDLE)
					if(F.area_station == area_station) //can't stack two shuttles on the same spot.
						return FALSE
	. = ..()



/datum/shuttle/ferry/ert/close_doors(area/A)
	if(!A || !istype(A)) //somehow
		return

	for(var/obj/machinery/door/D in A)
		if(!D.density)
			spawn(0)
				D.close()

	if(use_umbilical && location == 0)
		var/umbili_id
		if(istype(area_station, /area/shuttle/distress/arrive_n_hangar))
			umbili_id = "n_umbilical"
		else if(istype(area_station, /area/shuttle/distress/arrive_s_hangar))
			umbili_id = "s_umbilical"
		else return
		for(var/obj/machinery/door/poddoor/PD in machines)
			if(!PD.density && PD.id == umbili_id)
				spawn(0)
					PD.close()



/datum/shuttle/ferry/ert/open_doors(area/A)
	if(!A || !istype(A)) //somehow
		return

	for(var/obj/machinery/door/unpowered/D in A)
		if(D.density)
			spawn(0)
				D.open()

	for(var/obj/machinery/door/airlock/D in A)
		if(D.density)
			spawn(0)
				D.open()


	if(use_umbilical && location == 0) //arrival at almayer
		var/umbili_id
		if(istype(area_station, /area/shuttle/distress/arrive_n_hangar))
			umbili_id = "n_umbilical"
		else if(istype(area_station, /area/shuttle/distress/arrive_s_hangar))
			umbili_id = "s_umbilical"
		else return
		//open the almayer's north of south umbilical shutters and the shuttle's north or south shutters
		for(var/obj/machinery/door/poddoor/PD in machines)
			if(PD.density && PD.id == umbili_id)
				spawn(0)
					PD.open()

	else
		for(var/obj/machinery/door/poddoor/shutters/P in A)
			if(P.density)
				spawn(0)
					P.open()

		var/shutter_id
		if(istype(area_station, /area/shuttle/distress/arrive_2))
			shutter_id = "portert"
		else if(istype(area_station, /area/shuttle/distress/arrive_1))
			shutter_id = "starboardert"
		else if(istype(area_station, /area/shuttle/distress/arrive_3))
			shutter_id = "aftert"
		if(shutter_id)
			for(var/obj/machinery/door/poddoor/shutters/T in machines)
				if(T.density && shutter_id == T.id)
					spawn(0)
						T.open()



/obj/machinery/computer/shuttle_control/ert
	icon_state = "syndishuttle"
	shuttle_tag = "Distress"
	unacidable = TRUE

/obj/machinery/computer/shuttle_control/ert/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 0)
	var/data[0]
	var/datum/shuttle/ferry/shuttle = shuttle_controller.shuttles[shuttle_tag]
	if (!istype(shuttle))
		return

	var/shuttle_state
	switch(shuttle.moving_status)
		if(SHUTTLE_IDLE) shuttle_state = "idle"
		if(SHUTTLE_WARMUP) shuttle_state = "warmup"
		if(SHUTTLE_INTRANSIT) shuttle_state = "in_transit"
		if(SHUTTLE_CRASHED) shuttle_state = "crashed"

	var/shuttle_status
	switch (shuttle.process_state)
		if(IDLE_STATE)
			if (shuttle.in_use)
				shuttle_status = "Busy."
			else if (!shuttle.location)
				shuttle_status = "Standing by at station."
			else
				shuttle_status = "Standing by at an off-site location."
		if(WAIT_LAUNCH, FORCE_LAUNCH)
			shuttle_status = "Shuttle has received command and will depart shortly."
		if(WAIT_ARRIVE)
			shuttle_status = "Proceeding to destination."
		if(WAIT_FINISH)
			shuttle_status = "Arriving at destination now."

	data = list(
		"shuttle_status" = shuttle_status,
		"shuttle_state" = shuttle_state,
		"has_docking" = shuttle.docking_controller? 1 : 0,
		"docking_status" = shuttle.docking_controller? shuttle.docking_controller.get_docking_status() : null,
		"docking_override" = shuttle.docking_controller? shuttle.docking_controller.override_enabled : null,
		"can_launch" = shuttle.can_launch(),
		"can_cancel" = shuttle.can_cancel(),
		"can_force" = shuttle.can_force(),
		"recharging" = shuttle.recharging,
		"recharging_seconds" = round(shuttle.recharging/10),
		"recharge_time" = shuttle.recharge_time,
	)

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)

	if (!ui)
		ui = new(user, src, ui_key, "ert_shuttle_control_console.tmpl" , "ERT Shuttle Control", 550, 500)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)


/obj/machinery/computer/shuttle_control/ert/Topic(href, href_list)
	if(..())
		return

	usr.set_interaction(src)
	src.add_fingerprint(usr)

	var/datum/shuttle/ferry/ert/MS = shuttle_controller.shuttles[shuttle_tag]
	if(!istype(MS)) return

	if(href_list["select_dock"])

		if(MS.moving_status == SHUTTLE_IDLE && z == ADMIN_Z_LEVEL)
			var/dock_id = /area/shuttle/distress/arrive_1
			var/dock_list = list("Port", "Starboard", "Aft")
			if(MS.use_umbilical)
				dock_list = list("Port Hangar", "Starboard Hangar")
			var/dock_name = input("Where on the [MAIN_SHIP_NAME] should the shuttle dock?", "Select a docking zone:") as null|anything in dock_list
			if(MS.moving_status != SHUTTLE_IDLE || z != ADMIN_Z_LEVEL)
				return
			switch(dock_name)
				if("Port") dock_id = /area/shuttle/distress/arrive_2
				if("Starboard") dock_id = /area/shuttle/distress/arrive_1
				if("Aft") dock_id = /area/shuttle/distress/arrive_3
				if("Port Hangar") dock_id = /area/shuttle/distress/arrive_s_hangar
				if("Starboard Hangar") dock_id = /area/shuttle/distress/arrive_n_hangar
				else return

			for(var/datum/shuttle/ferry/ert/F in shuttle_controller.process_shuttles)
				if(F != MS)
					//other ERT shuttles already docked on almayer or about to be
					if(!F.location || F.moving_status != SHUTTLE_IDLE)
						if(F.area_station.type == dock_id)
							usr << "\red The [dock_name] dock area is unavailable."
							return

			for(var/area/A in all_areas)
				if(A.type == dock_id)
					MS.area_station = A
					usr << "\red You set the docking area on the Almayer to \"[dock_name]\"."
					break

		ui_interact(usr)
