/obj/machinery/computer/shuttle_control
	name = "shuttle control console"
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "shuttle"
	circuit = null

	var/shuttle_tag  // Used to coordinate data in shuttle controller.
	var/hacked = 0   // Has been emagged, no access restrictions.
	var/shuttle_optimized = 0 //Have the shuttle's flight subroutines been generated ?
	var/onboard = 0 //Wether or not the computer is on the physical ship. A bit hacky but that'll do.
	var/skip_time_lock = 0	// Allows admins to var edit the time lock away.
	var/obj/structure/dropship_equipment/selected_equipment //the currently selected equipment installed on the shuttle this console controls.
	var/list/shuttle_equipments = list() //list of the equipments on the shuttle this console controls

/obj/machinery/computer/shuttle_control/attack_hand(mob/user)
	if(..(user))
		return
	//src.add_fingerprint(user)	//shouldn't need fingerprints just for looking at it.
	if(!allowed(user) && !isXeno(user))
		user << "<span class='warning'>Access denied.</span>"
		return 1

	user.set_interaction(src)

	var/datum/shuttle/ferry/shuttle = shuttle_controller.shuttles[shuttle_tag]
	if(!isXeno(user) && (onboard || z == 1) && !shuttle.iselevator)
		if(shuttle.queen_locked)
			if(world.time < shuttle.last_locked + SHUTTLE_LOCK_COOLDOWN)
				user << "<span class='warning'>You can't seem to re-enable remote control, some sort of safety cooldown is in place. Please wait another [round((shuttle.last_locked + SHUTTLE_LOCK_COOLDOWN - world.time)/600)] minutes before trying again.</span>"
			else
				user << "<span class='notice'>You interact with the pilot's console and re-enable remote control.</span>"
				shuttle.last_locked = world.time
				shuttle.queen_locked = 0
		if(shuttle.door_override)
			if(world.time < shuttle.last_door_override + SHUTTLE_LOCK_COOLDOWN)
				user << "<span class='warning'>You can't seem to reverse the door override. Please wait another [round((shuttle.last_door_override + SHUTTLE_LOCK_COOLDOWN - world.time)/600)] minutes before trying again.</span>"
			else
				user << "<span class='notice'>You reverse the door override.</span>"
				shuttle.last_door_override = world.time
				shuttle.door_override = 0
	ui_interact(user)

/obj/machinery/computer/shuttle_control/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 0)
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

	var/shuttle_status_message
	if(shuttle.transit_gun_mission && (onboard || shuttle.moving_status != SHUTTLE_IDLE))
		shuttle_status_message = "<b>Flight type:</b> <span style='font-weight: bold;color: #ff4444'>FLYBY. </span>"
	else //console not onboard stays on TRANSPORT and only shows FIRE MISSION when shuttle has already launched
		shuttle_status_message = "<b>Flight type:</b> <span style='font-weight: bold;color: #44ff44'>TRANSPORT. </span>"

	if(shuttle.transit_optimized) //If the shuttle is recharging, just go ahead and tell them it's unoptimized (it will be once recharged)
		if(shuttle.recharging && shuttle.moving_status == SHUTTLE_IDLE)
			shuttle_status_message += "<br>No custom flight subroutines have been submitted for the upcoming flight" //FYI: Flight plans are reset once recharging ends
		else
			shuttle_status_message += "<br>Custom flight subroutines have been submitted for the [shuttle.moving_status == SHUTTLE_INTRANSIT ? "ongoing":"upcoming"] flight."
	else
		if(shuttle.moving_status == SHUTTLE_INTRANSIT)
			shuttle_status_message += "<br>Default failsafe flight subroutines are being used for the current flight."
		else
			shuttle_status_message += "<br>No custom flight subroutines have been submitted for the upcoming flight"

	var/effective_recharge_time = shuttle.recharge_time
	if(shuttle.transit_optimized)
		effective_recharge_time *= SHUTTLE_OPTIMIZE_FACTOR_RECHARGE

	var/recharge_status = effective_recharge_time - shuttle.recharging

	var/is_dropship = FALSE
	if(istype(shuttle, /datum/shuttle/ferry/marine))
		is_dropship = TRUE

	data = list(
		"shuttle_status" = shuttle_status,
		"shuttle_state" = shuttle_state,
		"has_docking" = shuttle.docking_controller? 1 : 0,
		"docking_status" = shuttle.docking_controller? shuttle.docking_controller.get_docking_status() : null,
		"docking_override" = shuttle.docking_controller? shuttle.docking_controller.override_enabled : null,
		"can_launch" = shuttle.can_launch(),
		"can_cancel" = shuttle.can_cancel(),
		"can_force" = shuttle.can_force(),
		"can_optimize" = shuttle.can_optimize(),
		"optimize_allowed" = shuttle.can_be_optimized,
		"optimized" = shuttle.transit_optimized,
		"gun_mission_allowed" = shuttle.can_do_gun_mission,
		"shuttle_status_message" = shuttle_status_message,
		"recharging" = shuttle.recharging,
		"recharging_seconds" = round(shuttle.recharging/10),
		"recharge_time" = effective_recharge_time,
		"recharge_status" = recharge_status,
		"human_user" = ishuman(user),
		"is_dropship" = is_dropship,
		"onboard" = onboard,
	)

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)

	if (!ui)
		ui = new(user, src, ui_key, shuttle.iselevator? "elevator_control_console.tmpl" : "shuttle_control_console.tmpl", shuttle.iselevator? "Elevator Control" : "Shuttle Control", 550, 500)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/computer/shuttle_control/Topic(href, href_list)
	if(..())
		return

	add_fingerprint(usr)

	var/datum/shuttle/ferry/shuttle = shuttle_controller.shuttles[shuttle_tag]
	if (!istype(shuttle))
		return

	if(href_list["move"])
		if(shuttle.recharging) //Prevent the shuttle from moving again until it finishes recharging. This could be made to look better by using the shuttle computer's visual UI.
			if(shuttle.iselevator)
				usr << "<span class='warning'>The elevator is loading and unloading. Please hold.</span>"
			else
				usr << "<span class='warning'>The shuttle's engines are still recharging and cooling down.</span>"
			return
		if(shuttle.queen_locked && !isXenoQueen(usr))
			usr << "<span class='warning'>The shuttle isn't responding to prompts, it looks like remote control was disabled.</span>"
			return
		//Comment to test
		if(!skip_time_lock && world.time < SHUTTLE_TIME_LOCK && istype(shuttle, /datum/shuttle/ferry/marine))
			usr << "<span class='warning'>The shuttle is still undergoing pre-flight fuelling and cannot depart yet. Please wait another [round((SHUTTLE_TIME_LOCK-world.time)/600)] minutes before trying again.</span>"
			return
		spawn(0)
		if(shuttle.moving_status == SHUTTLE_IDLE) //Multi consoles, hopefully this will work

			if(shuttle.locked) return

			//Alert code is the Queen is the one calling it, the shuttle is on the ground and the shuttle still allows alerts
			if(isXenoQueen(usr) && shuttle.location == 1 && shuttle.alerts_allowed && onboard && !shuttle.iselevator)
				var/i = alert("Warning: Once you launch the shuttle you will not be able to bring it back. Confirm anyways?", "WARNING", "Yes", "No")
				if(shuttle.moving_status != SHUTTLE_IDLE || shuttle.locked || shuttle.location != 1 || !shuttle.alerts_allowed || !shuttle.queen_locked || shuttle.recharging) return
				if(istype(shuttle, /datum/shuttle/ferry/marine) && src.z == 1 && i == "Yes") //Shit's about to kick off now
					var/datum/shuttle/ferry/marine/shuttle1 = shuttle
					shuttle1.transit_gun_mission = 0
					shuttle1.launch_crash()
					command_announcement.Announce("Unscheduled dropship departure detected from operational area. Hijack likely. Shutting down autopilot.", \
					"Dropship Alert", new_sound = 'sound/AI/hijack.ogg')
					shuttle.alerts_allowed--
					usr << "<span class='danger'>A loud alarm erupts from [src]! The fleshy hosts must know that you can access it!</span>"
					var/mob/living/carbon/Xenomorph/Queen/Q = usr // typechecked above
					xeno_message("<span class='xenoannounce'>The Queen has commanded the metal bird to depart for the metal hive in the sky! Rejoice!</span>",3,Q.hivenumber)
					playsound(src, 'sound/misc/queen_alarm.ogg')
				else if(i == "No")
					return
				else
					shuttle.launch(src)

			else if(!onboard && isXenoQueen(usr) && shuttle.location == 1 && !shuttle.iselevator)
				usr << "<span class='alert'>Hrm, that didn't work. Maybe try the one on the ship?</span>"
				return
			else
				if(z == 1) shuttle.transit_gun_mission = 0 //remote launch always do transport flight.
				shuttle.launch(src)
			log_admin("[usr] ([usr.key]) launched a [shuttle.iselevator? "elevator" : "shuttle"] from [src]")
			message_admins("[usr] ([usr.key]) launched a [shuttle.iselevator? "elevator" : "shuttle"] using [src].")

	if(href_list["optimize"])
		if(shuttle.transit_optimized) return
		var/mob/M = usr
		if(M.mind && M.mind.cm_skills && !M.mind.cm_skills.pilot)
			usr << "<span class='warning'>A screen with graphics and walls of physics and engineering values open, you immediately force it closed.</span>"
		else
			usr << "<span class='notice'>You load in and review a custom flight plan you took time to prepare earlier. This should cut half of the transport flight time on its own!</span>"
			shuttle.transit_optimized = 1
			return

	if(href_list["fire_mission"])
		if(shuttle.moving_status != SHUTTLE_IDLE) return
		if(shuttle.locked) return
		shuttle.transit_gun_mission = !shuttle.transit_gun_mission
		if(shuttle.transit_gun_mission)
			var/mob/M = usr
			if(M.mind && M.mind.cm_skills && !M.mind.cm_skills.pilot) //only pilots can activate the fire mission mode, but everyone can reset it back to transport..
				usr << "<span class='warning'>A screen with graphics and walls of physics and engineering values open, you immediately force it closed.</span>"
				return
			else
				usr << "<span class='notice'>You upload a flight plan for a low altitude flyby above the planet.</span>"
		else
			usr << "<span class='notice'>You reset the flight plan to a transport mission between the Almayer and the planet.</span>"

	if(href_list["lockdown"])
		if(shuttle.door_override || z == 3)
			return // its been locked down by the queen

		var/ship_id = "sh_dropship1"
		if(shuttle_tag == "[MAIN_SHIP_NAME] Dropship 2")
			ship_id = "sh_dropship2"

		for(var/obj/machinery/door/airlock/dropship_hatch/M in machines)
			if(M.id == ship_id)
				if(M.locked && M.density)
					continue // jobs done
				else if(!M.locked && M.density)
					M.lock() // closed but not locked yet
					continue
				else
					M.do_command("secure_close")

		var/obj/machinery/door/airlock/multi_tile/almayer/reardoor
		switch(ship_id)
			if("sh_dropship1")
				for(var/obj/machinery/door/airlock/multi_tile/almayer/dropshiprear/ds1/D in machines)
					reardoor = D
			if("sh_dropship2")
				for(var/obj/machinery/door/airlock/multi_tile/almayer/dropshiprear/ds2/D in machines)
					reardoor = D

		if(!reardoor.locked && reardoor.density)
			reardoor.lock() // closed but not locked yet
		else if(reardoor.locked && !reardoor.density)
			spawn()
				reardoor.unlock()
				sleep(1)
				reardoor.close()
				sleep(reardoor.openspeed + 1) // let it close
				reardoor.lock() // THEN lock it
		else
			spawn()
				reardoor.close()
				sleep(reardoor.openspeed + 1)
				reardoor.lock()

	if(href_list["release"])
		var/ship_id = "sh_dropship1"
		if(shuttle_tag == "[MAIN_SHIP_NAME] Dropship 2")
			ship_id = "sh_dropship2"

		for(var/obj/machinery/door/airlock/dropship_hatch/M in machines)
			if(M.id == ship_id)
				if(M.z != 4)
					M.unlock()

		var/obj/machinery/door/airlock/multi_tile/almayer/reardoor
		switch(ship_id)
			if("sh_dropship1")
				for(var/obj/machinery/door/airlock/multi_tile/almayer/dropshiprear/ds1/D in machines)
					reardoor = D
			if("sh_dropship2")
				for(var/obj/machinery/door/airlock/multi_tile/almayer/dropshiprear/ds2/D in machines)
					reardoor = D
		if(reardoor.z != 4)
			reardoor.unlock()

	if(href_list["side door"])
		if(shuttle.door_override || z == 3)
			return // its been locked down by the queen

		var/ship_id = "sh_dropship1"
		if(shuttle_tag == "[MAIN_SHIP_NAME] Dropship 2")
			ship_id = "sh_dropship2"

		for(var/obj/machinery/door/airlock/dropship_hatch/M in machines)
			if(M.id == ship_id)
				var/is_right_side = text2num(href_list["right side"])
				if(is_right_side)
					if(M.dir != WEST)
						continue
				else
					if(M.dir != EAST)
						continue
				var/sidename = is_right_side ? "right" : "left"
				if(M.locked)
					M.unlock()
					usr << "<span class='warning'>You hear a [sidename] door unlock.</span>" // yes this will give two messages but is important for when the two doors are out of sync
				else
					M.lock()
					usr << "<span class='warning'>You hear a [sidename] door lock.</span>"

	if(href_list["rear door"])
		if(shuttle.door_override || z == 3)
			return // its been locked down by the queen

		var/ship_id = "sh_dropship1"
		if(shuttle_tag == "[MAIN_SHIP_NAME] Dropship 2")
			ship_id = "sh_dropship2"
		var/obj/machinery/door/airlock/multi_tile/almayer/reardoor
		switch(ship_id)
			if("sh_dropship1")
				for(var/obj/machinery/door/airlock/multi_tile/almayer/dropshiprear/ds1/D in machines)
					reardoor = D
			if("sh_dropship2")
				for(var/obj/machinery/door/airlock/multi_tile/almayer/dropshiprear/ds2/D in machines)
					reardoor = D
		if(reardoor)
			if(reardoor.locked)
				reardoor.unlock()
				usr << "<span class='warning'>You hear the rear door unlock.</span>"
			else
				reardoor.lock()
				usr << "<span class='warning'>You hear the rear door lock.</span>"
		else
			usr << "<span class='warning'>The console flashes a warning about the rear door not being present.</span>"

	ui_interact(usr)


/obj/machinery/computer/shuttle_control/attackby(obj/item/W as obj, mob/user as mob)

	if (istype(W, /obj/item/card/emag))
		src.req_access = list()
		src.req_one_access = list()
		hacked = 1
		usr << "You short out the console's ID checking system. It's now available to everyone!"
	else
		..()

/obj/machinery/computer/shuttle_control/bullet_act(var/obj/item/projectile/Proj)
	visible_message("[Proj] ricochets off [src]!")
	return 0

/obj/machinery/computer/shuttle_control/ex_act(severity)
	if(unacidable) return //unacidable shuttle consoles are also immune to explosions.
	..()




//Dropship control console

/obj/machinery/computer/shuttle_control/dropship1
	name = "\improper 'Alamo' dropship console"
	desc = "The remote controls for the 'Alamo' Dropship. Named after the Alamo Mission, stage of the Battle of the Alamo in the United States' state of Texas in the Spring of 1836. The defenders held to the last, encouraging other Texans to rally to the flag."
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "shuttle"

	unacidable = 1
	exproof = 1
	req_one_access_txt = "22;200"

/obj/machinery/computer/shuttle_control/dropship1/New()
	..()
	shuttle_tag = "[MAIN_SHIP_NAME] Dropship 1"

/obj/machinery/computer/shuttle_control/dropship1/onboard
	name = "\improper 'Alamo' flight controls"
	desc = "The flight controls for the 'Alamo' Dropship. Named after the Alamo Mission, stage of the Battle of the Alamo in the United States' state of Texas in the Spring of 1836. The defenders held to the last, encouraging other Texians to rally to the flag."
	icon = 'icons/Marine/shuttle-parts.dmi'
	icon_state = "console"
	onboard = 1

/obj/machinery/computer/shuttle_control/dropship2
	name = "\improper 'Normandy' dropship console"
	desc = "The remote controls for the 'Normandy' Dropship. Named after a department in France, noteworthy for the famous naval invasion of Normandy on the 6th of June 1944, a bloody but decisive victory in World War II and the campaign for the Liberation of France."
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "shuttle"
	unacidable = 1
	exproof = 1
	req_one_access_txt = "12;22;200"

/obj/machinery/computer/shuttle_control/dropship2/New()
	..()
	shuttle_tag = "[MAIN_SHIP_NAME] Dropship 2"

/obj/machinery/computer/shuttle_control/dropship2/onboard
	name = "\improper 'Normandy' flight controls"
	desc = "The flight controls for the 'Normandy' Dropship. Named after a department in France, noteworthy for the famous naval invasion of Normandy on the 6th of June 1944, a bloody but decisive victory in World War II and the campaign for the Liberation of France."
	icon = 'icons/Marine/shuttle-parts.dmi'
	icon_state = "console"
	onboard = 1





//Elevator control console

/obj/machinery/computer/shuttle_control/ice_colony
	name = "Elevator Console"
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "elevator_screen"
	unacidable = 1
	exproof = 1
	density = 0
	req_access = null

/obj/machinery/computer/shuttle_control/ice_colony/proc/animate_on()
	icon_state = "elevator_screen_animated"

/obj/machinery/computer/shuttle_control/ice_colony/proc/animate_off()
	icon_state = "elevator_screen"

/obj/machinery/computer/shuttle_control/ice_colony/elevator1
	shuttle_tag = "Elevator 1"

/obj/machinery/computer/shuttle_control/ice_colony/elevator2
	shuttle_tag = "Elevator 2"

/obj/machinery/computer/shuttle_control/ice_colony/elevator3
	shuttle_tag = "Elevator 3"

/obj/machinery/computer/shuttle_control/ice_colony/elevator4
	shuttle_tag = "Elevator 4"