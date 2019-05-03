//=========================================================================================
//===================================Shuttle Datum=========================================
//=========================================================================================
#define STATE_IDLE			4 //Pod is idle, not ready to launch.
#define STATE_BROKEN		5 //Pod failed to launch, is now broken.
#define STATE_READY			6 //Pod is armed and ready to go.
#define STATE_DELAYED		7 //Pod is being delayed from launching automatically.
#define STATE_LAUNCHING		8 //Pod is about to launch.
#define STATE_LAUNCHED		9 //Pod has successfully launched.
/*Other states are located in docking_program.dm, but they aren't important here.
This is built upon a weird network of different states, including docking states, moving
states, process states, and so forth. It's disorganized, but I tried to keep it in line
with the original.*/

/datum/shuttle/ferry/marine/evacuation_pod
	location = 0
	warmup_time = 5
	sound_target = 18
	sound_misc = 'sound/effects/escape_pod_launch.ogg'
	var/static/passengers = 0 //How many living escape on the shuttle. Does not count simple animals.
	var/cryo_cells[] //List of the crypods attached to the evac pod.
	var/area/staging_area //The area the shuttle starts in, used to link the various machinery.
	var/datum/computer/file/embedded_program/docking/simple/escape_pod/evacuation_program //The program that runs the doors.
	var/obj/machinery/door/airlock/evacuation/D //TODO Get rid of this.
	//docking_controller is the program that runs doors.
	//TODO: Make sure that the area has light once evac is in progress.

	//Can only go one way, never back. Very simple.
	process()
		switch(process_state)
			if(WAIT_LAUNCH)
				short_jump()
				process_state = IDLE_STATE

	//No safeties here. Everything is done through dock_state.
	launch()
		process_state = WAIT_LAUNCH

	can_launch() //Cannot launch it early before the evacuation takes place proper, and the pod must be ready. Cannot be delayed, broken, launching, or otherwise.
		if(..() && SSevacuation.evac_status >= EVACUATION_STATUS_INITIATING)
			switch(evacuation_program.dock_state)
				if(STATE_READY) return TRUE
				if(STATE_DELAYED)
					for(var/obj/machinery/cryopod/evacuation/C in cryo_cells) //If all are occupied, the pod will launch anyway.
						if(!C.occupant) return FALSE
					return TRUE

	//The pod can be delayed until after the automatic launch.
	can_cancel()
		. = (SSevacuation.evac_status > EVACUATION_STATUS_STANDING_BY && (evacuation_program.dock_state in STATE_READY to STATE_DELAYED)) //Must be evac time and the pod can't be launching/launched.

	short_jump()
		. = ..()
		evacuation_program.dock_state = STATE_LAUNCHED
		spawn(10)
			check_passengers("<br><br><span class='centerbold'><big>You have successfully left the [CONFIG_GET(string/ship_name)]. You may now ghost and observe the rest of the round.</big></span><br>")


/datum/shuttle/ferry/marine/evacuation_pod/New()
	. = ..()
	shuttle_tag = "[CONFIG_GET(string/ship_name)] Evac"
	info_tag = "[CONFIG_GET(string/ship_name)] Evac"


/*
This processes tags and connections dynamically, so you do not need to modify or pregenerate linked objects.
There is no specific need to even have this complicated system in place, but I wanted something that worked
off an existing controller that allowed more robust functinonality. But in reality, all of the objects
are basically hard-linked together and do not need a go-between controller. The shuttle datum itself would
suffice.
*/
/datum/shuttle/ferry/marine/evacuation_pod/proc/link_support_units(turf/ref)
	var/datum/coords/C = info_datums[1] //Grab a coord for random turf.
	var/turf/T = locate(ref.x + C.x_pos, ref.y + C.y_pos, ref.z) //Get a turf from the coordinates.
	if(!istype(T))
		log_runtime("ERROR CODE EV0: unable to find the first turf of [shuttle_tag].")
		to_chat(world, "<span class='debuginfo'>ERROR CODE EV0: unable to find the first turf of [shuttle_tag].</span>")
		return FALSE

	staging_area = T.loc //Grab the area and store it on file.
	staging_area.name = "\improper[shuttle_tag]"

	D = locate() in staging_area
	if(!D)
		log_runtime("ERROR CODE EV1.5: could not find door in [shuttle_tag].")
		to_chat(world, "<span class='debuginfo'>ERROR CODE EV1: could not find door in [shuttle_tag].</span>")
		return FALSE
	D.id_tag = shuttle_tag //So that the door can be operated via controller later.


	var/obj/machinery/embedded_controller/radio/simple_docking_controller/escape_pod/R = locate() in staging_area //Grab the controller.
	if(!R)
		log_runtime("ERROR CODE EV1.5: could not find controller in [shuttle_tag].")
		to_chat(world, "<span class='debuginfo'>ERROR CODE EV1: could not find controller in [shuttle_tag].</span>")
		return FALSE

	//Set the tags.
	R.id_tag = shuttle_tag //Set tag.
	R.tag_door = shuttle_tag //Set the door tag.
	R.evacuation_program = new(R) //Make a new program with the right parent-child relationship. Make sure the master is specified in new().
	//R.docking_program = R.evacuation_program //Link them all to the same program, sigh.
	//R.program = R.evacuation_program
	evacuation_program = R.evacuation_program //For the shuttle, to shortcut the controller program.

	cryo_cells = new
	for(var/obj/machinery/cryopod/evacuation/E in staging_area)
		cryo_cells += E
		E.evacuation_program = evacuation_program
	if(!cryo_cells.len)
		log_runtime("ERROR CODE EV2: could not find cryo pods in [shuttle_tag].")
		to_chat(world, "<span class='debuginfo'>ERROR CODE EV2: could not find cryo pods in [shuttle_tag].</span>")
		return FALSE

#define MOVE_MOB_OUTSIDE \
for(var/obj/machinery/cryopod/evacuation/C in cryo_cells) C.go_out()

/datum/shuttle/ferry/marine/evacuation_pod/proc/toggle_ready()
	switch(evacuation_program.dock_state)
		if(STATE_IDLE)
			evacuation_program.dock_state = STATE_READY
			spawn()
				D.unlock()
				D.open()
				D.lock()
			//evacuation_program.open_door()
		if(STATE_READY)
			evacuation_program.dock_state = STATE_IDLE
			MOVE_MOB_OUTSIDE
			spawn(250)
				D.unlock()
				D.close()
				D.lock()

/datum/shuttle/ferry/marine/evacuation_pod/proc/prepare_for_launch()
	if(!can_launch()) return FALSE //Can't launch in some circumstances.
	evacuation_program.dock_state = STATE_LAUNCHING
	spawn()
		D.unlock()
		D.close()
		D.lock()
	evacuation_program.prepare_for_undocking()
	sleep(31)
	if(!check_passengers())
		evacuation_program.dock_state = STATE_BROKEN
		MOVE_MOB_OUTSIDE
		//evacuation_program.open_door()
		spawn()
			D.unlock()
			D.open()
			D.lock()
		evacuation_program.master.state("<span class='warning'>WARNING: Maximum weight limit reached, pod unable to launch. DANGER: Thruster failure imminent.</span>")
		playsound(evacuation_program.master,'sound/effects/alert.ogg', 25, 1)
		sleep(40)
		explosion(evacuation_program.master, -1, -1, 3, 4)
		sleep(20)
		staging_area.initialize_power_and_lighting(TRUE) //We want to reinitilize power usage and turn off everything.
		return FALSE
	launch()
	return TRUE

#undef MOVE_MOB_OUTSIDE

/*
You could potentially make stuff like crypods in these, but they should generally not be allowed to build inside pods.
This can probably be done a lot more elegantly either way, but it'll suffice for now.
*/
/datum/shuttle/ferry/marine/evacuation_pod/proc/check_passengers(msg)
	. = TRUE
	var/n = 0 //Generic counter.
	var/mob/M
	for(var/obj/machinery/cryopod/evacuation/C in cryo_cells)
		if(C.occupant)
			n++
			if(C.occupant.stat != DEAD && msg) to_chat(C.occupant, msg)
	//Hardcoded typecast, which should be changed into some weight system of some kind eventually.
	var/area/A = msg ? evacuation_program.master.loc.loc : staging_area //Before or after launch.
	for(var/i in A)
		if(istype(i, /obj/mecha) || istype(i, /obj/vehicle/multitile))
			. = FALSE //Manned or unmanned, these are too big. It won't launch at all.
		else if(istype(i, /obj/structure/closet))
			M = locate(/mob/living/carbon/human) in i
			if(M)
				n++ //No hiding in closets.
				if(M.stat != DEAD && msg) to_chat(M, msg)
		else if(ishuman(i) || iscyborg(i))
			n++ //Dead or alive, counts as a thing.
			M = i
			if(M.stat != DEAD && msg) to_chat(M, msg)
		else if(istype(i, /mob/living/carbon/Xenomorph))
			var/mob/living/carbon/Xenomorph/X = i
			if(X.mob_size == MOB_SIZE_BIG) return FALSE //Huge xenomorphs will automatically fail the launch.
			n++
			if(X.stat != DEAD && msg) to_chat(X, msg)
	if(n > cryo_cells.len)  . = FALSE //Default is 3 cryo cells and three people inside the pod.
	if(msg)
		passengers += n //Return the total number of occupants instead if it successfully launched.
		return TRUE

//=========================================================================================
//==================================Console Object=========================================
//=========================================================================================
/*
These were written by a crazy person, so that datums are constantly inserted for child objects,
the same datums that serve a similar purpose all-around. Incredibly stupid, but there you go.
As such, a new tracker datum must be constructed to follow proper child inheritance.
*/

//This controller goes on the escape pod itself.
/obj/machinery/embedded_controller/radio/simple_docking_controller/escape_pod
	name = "escape pod controller"
	resistance_flags = UNACIDABLE|INDESTRUCTIBLE
	var/datum/computer/file/embedded_program/docking/simple/escape_pod/evacuation_program //Runs the doors and states.
	//door_tag is the tag for the pod door.
	//id_tag is the generic connection tag.
	//TODO make sure you can't C4 this.

	ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
		var/launch_status[] = evacuation_program.check_launch_status()
		var/data[] = list(
			"docking_status"	= evacuation_program.dock_state,
			"door_state"		= evacuation_program.memory["door_status"]["state"],
			"door_lock"			= evacuation_program.memory["door_status"]["lock"],
			"can_lock"			= evacuation_program.dock_state == (STATE_READY || STATE_DELAYED) ? 1:0,
			"can_force"			= evacuation_program.dock_state == (STATE_READY || STATE_DELAYED) ? 1:0,
			"can_delay"			= launch_status[2]
		)

		ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)

		if (!ui)
			ui = new(user, src, ui_key, "escape_pod_console.tmpl", id_tag, 470, 290)
			ui.set_initial_data(data)
			ui.open()
			ui.set_auto_update(1)

	Topic(href, href_list)
		if(..()) return TRUE	//Has to return true to fail. For some reason.

		var/datum/shuttle/ferry/marine/evacuation_pod/P = shuttle_controller.shuttles[id_tag]
		switch(href_list["command"])
			if("force_launch")
				P.prepare_for_launch()
			if("delay_launch")
				evacuation_program.dock_state = evacuation_program.dock_state == STATE_DELAYED ? STATE_READY : STATE_DELAYED
			if("lock_door")
				if(P.D.density) //Closed
					spawn()
						P.D.unlock()
						P.D.open()
						P.D.lock()
				else //Open
					spawn()
						P.D.unlock()
						P.D.close()
						P.D.lock()


//=========================================================================================
//================================Controller Program=======================================
//=========================================================================================

//A docking controller program for a simple door based docking port
/datum/computer/file/embedded_program/docking/simple/escape_pod
	dock_state = STATE_IDLE //Controls the state of the docking. We manipulate it directly and add a few more to the default.
	//master is the console object.
	//door_tag is the tag for the pod door.
	//id_tag is the generic connection tag.

	//receive_user_command(command)
	//	if(dock_state == STATE_READY)
	//		..(command)

	prepare_for_undocking()
		playsound(master,'sound/effects/escape_pod_warmup.ogg', 50, 1)
		//close_door()

/datum/computer/file/embedded_program/docking/simple/escape_pod/proc/check_launch_status()
	var/datum/shuttle/ferry/marine/evacuation_pod/P = shuttle_controller.shuttles[id_tag]
	. = list(P.can_launch(), P.can_cancel())

//=========================================================================================
//================================Evacuation Sleeper=======================================
//=========================================================================================

/obj/machinery/cryopod/evacuation
	machine_stat = MACHINE_DO_NOT_PROCESS
	resistance_flags = UNACIDABLE|INDESTRUCTIBLE
	time_till_despawn = INFINITY //near infinite so despawn never occurs.
	var/being_forced = FALSE //Simple variable to prevent sound spam.
	var/datum/computer/file/embedded_program/docking/simple/escape_pod/evacuation_program

/obj/machinery/cryopod/evacuation/attackby(obj/item/grab/G, mob/user)
	if(istype(G))
		if(being_forced)
			to_chat(user, "<span class='warning'>There's something forcing it open!</span>")
			return FALSE

		if(evacuation_program.dock_state < STATE_READY)
			to_chat(user, "<span class='warning'>The cryo pod is not responding to commands!</span>")
			return FALSE

	return ..()

/obj/machinery/cryopod/evacuation/climb_in(mob/user)
	if(evacuation_program.dock_state < STATE_READY)
		to_chat(user, "<span class='warning'>The cryo pod is not responding to commands!</span>")
		return FALSE
	return ..()

/obj/machinery/cryopod/evacuation/attack_alien(mob/living/carbon/Xenomorph/user)
	if(being_forced)
		to_chat(user, "<span class='xenowarning'>It's being forced open already!</span>")
		return FALSE

	if(!occupant)
		to_chat(user, "<span class='xenowarning'>There is nothing of interest in there.</span>")
		return FALSE

	being_forced = !being_forced
	visible_message("<span class='warning'>[user] begins to pry the [src]'s cover!</span>", 3)
	playsound(src,'sound/effects/metal_creaking.ogg', 25, 1)
	if(do_after(user, 20, FALSE, 5, BUSY_ICON_HOSTILE))
		go_out() //Force the occupant out.
	being_forced = !being_forced

/obj/machinery/door/airlock/evacuation
	name = "\improper Evacuation Airlock"
	icon = 'icons/obj/doors/almayer/pod_doors.dmi'
	resistance_flags = UNACIDABLE|INDESTRUCTIBLE

/obj/machinery/door/airlock/evacuation/Initialize()
	. = ..()
	lock()

	//Can't interact with them, mostly to prevent grief and meta.
/obj/machinery/door/airlock/evacuation/Bumped()
	return FALSE
/obj/machinery/door/airlock/evacuation/attackby()
	return FALSE
/obj/machinery/door/airlock/evacuation/attack_hand()
	return FALSE
/obj/machinery/door/airlock/evacuation/attack_alien()
	return FALSE //Probably a better idea that these cannot be forced open.
/obj/machinery/door/airlock/evacuation/attack_ai()
	return FALSE

#undef STATE_IDLE
#undef STATE_READY
#undef STATE_BROKEN
#undef STATE_LAUNCHED

/*
//Leaving this commented out for the CL pod, which should have a way to open from the outside.

//This controller is for the escape pod berth (station side)
/obj/machinery/embedded_controller/radio/simple_docking_controller/escape_pod_berth
	name = "escape pod berth controller"

/obj/machinery/embedded_controller/radio/simple_docking_controller/escape_pod_berth/initialize()
	..()
	docking_program = new/datum/computer/file/embedded_program/docking/simple/escape_pod(src)
	program = docking_program

/obj/machinery/embedded_controller/radio/simple_docking_controller/escape_pod_berth/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	var/armed = null
	if (istype(docking_program, /datum/computer/file/embedded_program/docking/simple/escape_pod))
		var/datum/computer/file/embedded_program/docking/simple/escape_pod/P = docking_program
		armed = P.armed

	var/data[] = list(
		"docking_status" = docking_program.get_docking_status(),
		"override_enabled" = docking_program.override_enabled,
		"armed" = armed,
	)

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)

	if (!ui)
		ui = new(user, src, ui_key, "escape_pod_berth_console.tmpl", name, 470, 290)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)
*/
