// -- Print disc computer
/obj/item/circuitboard/computer/nuke_disc_generator
	name = "Circuit board (Nuke Disc Generator)"
	build_path = /obj/machinery/computer/engine_computer


/obj/machinery/computer/nuke_disc_generator
	name = "Nuke Disc Generator"
	desc = "Used to generate the correct auth discs for the nuke."
	icon_state = "atmos" // TODO: Better icon state
	circuit = "/obj/item/circuitboard/computer/nuke_disc_generator"

	resistance_flags = INDESTRUCTIBLE|UNACIDABLE

	var/generate_time = 5 SECONDS // time for the machine to generate the disc
	var/segment_time = 1 SECONDS // time to start the hack
	var/total_segments = 5 // total number of times the hack is required
	var/completed_segments = 0 // what segment we are on, (once this hits total, disc is printed)
	var/current_timer

	var/disc_type = null
	var/obj/item/disk/nuclear/crash/disc

/obj/machinery/computer/nuke_disc_generator/Initialize()
	. = ..()

	if(!disc_type)
		stack_trace("disc_type is required to be set before init")
		return INITIALIZE_HINT_QDEL

/obj/machinery/computer/nuke_disc_generator/process()
	. = ..()
	if(. || !current_timer)
		return

	deltimer(current_timer)
	visible_message("<b>[src]</b> shuts down as it loses power. Any running programs will now exit")

/obj/machinery/computer/nuke_disc_generator/attack_hand(mob/user)
	. = ..()
	if(.)
		return

	interact(user)

/obj/machinery/computer/nuke_disc_generator/interact(mob/user)
	usr.set_interaction(src)
	var/dat = ""
	dat += "<a href='?src=[REF(src)];mach_close=computer'>Close</a><br><br>"
	dat += "<div align='center'><a href='?src=[REF(src)];generate=1'>Run Program</a></div>"
	dat += "<br/>"
	dat += "<hr/>"
	dat += "<div align='center'><h2>Status</h2></div>"

	var/message = "Error"
	if(completed_segments >= total_segments)
		message = "Disc generated"
	else if(current_timer)
		message = "Program running"
	else if(completed_segments == 0)
		message = "Idle"
	else if(completed_segments < total_segments)
		message = "Restart required. Please rerun the program"
	else
		message = "Unknown"

	var/progress = round((completed_segments / total_segments) * 100)

	dat += "<br/><span><b>Progress</b>: [progress]%</span>"
	dat += "<br/><span><b>Time left</b>: [current_timer ? round(timeleft(current_timer) * 0.1, 2) : 0.0]</span>"
	dat += "<br/><span><b>Message</b>: [message]</span>"

	var/datum/browser/popup = new(user, "computer", "<div align='center'>Nuke Disc Generator</div>")
	popup.set_content(dat)
	popup.open()

/obj/machinery/computer/nuke_disc_generator/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(href_list["generate"])
		if(current_timer)
			to_chat(usr, "<span class='warning'>A program is already running.</span>")
			return

		usr.visible_message("[usr] started a program to generate \the [disc]", "You started a program to generate \a [disc_type]")
		var/extra_check = CALLBACK(src, .process)
		if(!do_after(usr, segment_time, TRUE, src, BUSY_ICON_GENERIC, null, null, extra_check))
			return
		current_timer = addtimer(CALLBACK(src, .proc/complete_segment), generate_time, TIMER_STOPPABLE)

	updateUsrDialog()


/obj/machinery/computer/nuke_disc_generator/proc/complete_segment()
	current_timer = null
	completed_segments = min(completed_segments + 1, total_segments)

	if (completed_segments == total_segments)
		print_disc()


/obj/machinery/computer/nuke_disc_generator/proc/print_disc()
	if(disc != null)
		visible_message("<span class='warning'>Failed to generate red disc</span>")
		return
	disc = new disc_type(loc)
	visible_message("<span class='notice'>[src] beeps 'Disc printed'</span>")
	return
		
/obj/machinery/computer/nuke_disc_generator/red
	disc_type = /obj/item/disk/nuclear/crash/red

/obj/machinery/computer/nuke_disc_generator/green
	disc_type = /obj/item/disk/nuclear/crash/green

/obj/machinery/computer/nuke_disc_generator/blue
	disc_type = /obj/item/disk/nuclear/crash/blue


// -- Engine computer
/obj/item/circuitboard/computer/enginecomputer
	name = "Circuit board (Cockpit Computer)"
	build_path = /obj/machinery/computer/engine_computer


/obj/machinery/computer/engine_computer
	name = "Cockpit Computer"
	desc = "Used to control the ships main thrusters."
	icon_state = "atmos" // TODO: Better icon state
	circuit = "/obj/item/circuitboard/computer/enginecomputer"

	var/list/obj/structure/shuttle/engine/fuel_dock/fuel_docks
	var/last_announce

/obj/machinery/computer/engine_computer/Initialize()
	. = ..()

	// Find the nearby
	fuel_docks = list() // TODO: We need a dedicated engine path
	for(var/obj/structure/shuttle/engine/fuel_dock/FD in range(25)) // This will need adjust when we get the placement down
		fuel_docks.Add(FD)

	last_announce = world.time


/obj/machinery/computer/engine_computer/attack_hand(mob/user)
	. = ..()
	if(.)
		return

	last_announce = world.time // reset every time someone uses the machine
	interact(user)


/obj/machinery/computer/engine_computer/interact(mob/user)
	usr.set_interaction(src)
	var/dat = ""
	dat += "<a href='?src=[REF(user)];mach_close=engine_computer'>Close</a><br><br>"

	// var/engine_count = 1
	// for(var/i in ship_engines)
	// 	dat += "<b>Engine #[engine_count++]</b><br/>"
	// 	var/obj/structure/shuttle/engine/E = i
	// 	var/fuel_level = max(0, min(100, round((E.fuel_current / E.fuel_max) * 100)))
	// 	dat += "<span>Engine Fuel: [E.fuel_current] / [E.fuel_max] ([fuel_level]%)</span><br />"
	// 	switch (fuel_level)
	// 		if(-INFINITY to 10)
	// 			dat += "<span class='notice'> - Engine fuel dangerously low</span><br />"
	// 		if(11 to 35)
	// 			dat += "<span class='warning'> - Engine fuel low</span><br />"
		
	// 	dat += "<br/>"
		
	dat += "<br/>"
	dat += "<div align='center'><a href='?src=[REF(user)];launch=1'>Launch Shuttle</a></div>"

	var/datum/browser/popup = new(user, "engine_computer", "<div align='center'>Engine Computer</div>")
	popup.set_content(dat)
	popup.open(FALSE)
	onclose(user, "engine_computer")


/obj/machinery/computer/engine_computer/Topic(href, href_list)
	. = ..()

	if(text2num(href_list["launch"]))
		// TODO: Add timer and launch the shuttle.
		message_admins("The Canterbury was launched")
		to_chat(world, "launch pushed")
		visible_message("Shuttle launching, please stand clear of the airlocks.")
		if(iscrashgamemode(SSticker.mode))
			var/datum/game_mode/crash/C = SSticker.mode
			C.marines_evac = TRUE
		return


/obj/machinery/computer/engine_computer/process()
	if(machine_stat & (BROKEN))
		icon_state = "atmosb" // TODO: replace icon
		return

	if (world.time < (last_announce + 1 MINUTES))	
		return

	// var/engine_alert = "<b>[src]</b> beeps, \"Fuel status - "
	// var/engine_count = 1
	// for(var/i in ship_engines)
	// 	var/obj/structure/shuttle/engine/E = i
	// 	var/fuel_level = max(0, min(100, round((E.fuel_current / E.fuel_max) * 100)))
	// 	engine_alert += "Engine #[engine_count++]: [fuel_level]%. "
	// engine_alert += "\""

	last_announce = world.time
	// visible_message(engine_alert)