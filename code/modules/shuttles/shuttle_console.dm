/obj/machinery/computer/shuttle_control
	name = "shuttle control console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "shuttle"
	circuit = null

	var/shuttle_tag  // Used to coordinate data in shuttle controller.
	var/hacked = 0   // Has been emagged, no access restrictions.
	var/shuttle_optimized = 0 //Have the shuttle's flight subroutines been generated ?
	var/onboard = 0 //Wether or not the computer is on the physical ship. A bit hacky but that'll do.

/obj/machinery/computer/shuttle_control/attack_hand(user as mob)
	if(..(user))
		return
	//src.add_fingerprint(user)	//shouldn't need fingerprints just for looking at it.
	if(!allowed(user) && !isXeno(user))
		user << "<span class='warning'>Access denied.</span>"
		return 1

	var/datum/shuttle/ferry/shuttle = shuttle_controller.shuttles[shuttle_tag]
	if(!isXeno(user) && onboard && shuttle.queen_locked && !shuttle.iselevator)
		user << "<span class='notice'>You interact with the pilot's console and re-enable remote control.</span>"
		shuttle.queen_locked = 0
	ui_interact(user)

/obj/machinery/computer/shuttle_control/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	var/data[0]
	var/datum/shuttle/ferry/shuttle = shuttle_controller.shuttles[shuttle_tag]
	if (!istype(shuttle))
		return

	var/shuttle_state
	switch(shuttle.moving_status)
		if(SHUTTLE_IDLE) shuttle_state = "idle"
		if(SHUTTLE_WARMUP) shuttle_state = "warmup"
		if(SHUTTLE_INTRANSIT) shuttle_state = "in_transit"

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

	var/shuttle_status_optimization
	if(shuttle.transit_optimized) //If the shuttle is recharging, just go ahead and tell them it's unoptimized (it will be once recharged)
		if(shuttle.recharging && shuttle.moving_status == SHUTTLE_IDLE)
			shuttle_status_optimization = "No custom flight subroutines have been submitted for the upcoming flight" //FYI: Flight plans are reset once recharging ends
		else
			shuttle_status_optimization = "Custom flight subroutines have been submitted for the [shuttle.moving_status == SHUTTLE_INTRANSIT ? "ongoing":"upcoming"] flight."
	else
		if(shuttle.moving_status == SHUTTLE_INTRANSIT)
			shuttle_status_optimization = "Default failsafe flight subroutines are being used for the current flight."
		else
			shuttle_status_optimization = "No custom flight subroutines have been submitted for the upcoming flight"

	var/effective_recharge_time = shuttle.recharge_time
	if(shuttle.transit_optimized)
		effective_recharge_time *= 0.5

	var/recharge_status = effective_recharge_time - shuttle.recharging

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
		"shuttle_status_optimization" = shuttle_status_optimization,
		"recharging" = shuttle.recharging,
		"recharging_seconds" = round(shuttle.recharging/10),
		"recharge_time" = effective_recharge_time,
		"recharge_status" = recharge_status,
	)

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)

	if (!ui)
		ui = new(user, src, ui_key, shuttle.iselevator? "elevator_control_console.tmpl" : "shuttle_control_console.tmpl", shuttle.iselevator? "Elevator Control" : "Shuttle Control", 550, 350)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/computer/shuttle_control/Topic(href, href_list)
	if(..())
		return

	usr.set_machine(src)
	src.add_fingerprint(usr)

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
		spawn(0)
		if(shuttle.moving_status == SHUTTLE_IDLE) //Multi consoles, hopefully this will work

			//Alert code is the Queen is the one calling it, the shuttle is on the ground and the shuttle still allows alerts
			if(isXenoQueen(usr) && shuttle.location == 1 && shuttle.alerts_allowed && onboard && !shuttle.iselevator)
				command_announcement.Announce("Unscheduled dropship departure detected from operational area. Illegal credentials detected. Hijack likely, shutting down auto-pilot.", \
				"Dropship Alert", new_sound = 'sound/misc/queen_alarm.ogg')
				usr << "<span class='danger'>A loud alarm erupts from [src]! The fleshy hosts must know that you can access it!</span>"
				shuttle.alerts_allowed--
				var/i = alert("Warning: Once you launch the shuttle you will not be able to bring it back. Confirm anyways?", "WARNING", "Yes", "No")
				if(istype(shuttle, /datum/shuttle/ferry/marine) && src.z == 1 && i == "Yes") //Shit's about to kick off now
					var/datum/shuttle/ferry/marine/shuttle1 = shuttle
					shuttle1.launch_crash()
				else
					shuttle.launch(src)

			else if(!onboard && isXenoQueen(usr) && shuttle.location == 1 && !shuttle.iselevator)
				usr << "<span class='alert'>Hrm, that didn't work. Maybe try the one on the ship?</span>"
				return
			else
				shuttle.launch(src)
			log_admin("[usr] ([usr.key]) launched a [shuttle.iselevator? "elevator" : "shuttle"] from [src]")
			message_admins("[usr] ([usr.key]) launched a [shuttle.iselevator? "elevator" : "shuttle"] using [src].")
	if(href_list["optimize"])
		var/mob/M = usr
		if(M.mind.assigned_role == "Pilot Officer")
			usr << "<span class='notice'>You load in and review a custom flight plan you took time to prepare earlier. This should cut half of the flight time on its own!</span>"
			shuttle.transit_optimized = 1
		else
			usr << "<span class='warning'>A screen with graphics and walls of physics and engineering values open, you immediately force it closed.</span>"
			return

//We need process to handle the ticking values
/obj/machinery/computer/shuttle_control/process()
	..()
	updateUsrDialog()
	return 1

//	if(href_list["force"])
//		if(shuttle.moving_status  == SHUTTLE_IDLE)
//			shuttle.force_launch(src)
//	else if(href_list["cancel"])
//		shuttle.cancel_launch(src)

/obj/machinery/computer/shuttle_control/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if (istype(W, /obj/item/weapon/card/emag))
		src.req_access = list()
		src.req_one_access = list()
		hacked = 1
		usr << "You short out the console's ID checking system. It's now available to everyone!"
	else
		..()

/obj/machinery/computer/shuttle_control/bullet_act(var/obj/item/projectile/Proj)
	visible_message("[Proj] ricochets off [src]!")
	return 0
