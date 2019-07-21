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

	var/disc_time = 10 SECONDS
	var/last_disc_timeleft = 0
	var/generate_timer

	var/obj/item/disk/nuclear/crash/red/red_disc
	var/obj/item/disk/nuclear/crash/green/green_disc
	var/obj/item/disk/nuclear/crash/blue/blue_disc

	var/last_error = ""

/obj/machinery/computer/nuke_disc_generator/process()
	. = ..()
	if(. || !generate_timer)
		return

	last_disc_timeleft = timeleft(generate_timer)
	deltimer(generate_timer)


/obj/machinery/computer/nuke_disc_generator/attack_hand(mob/user)
	. = ..()
	if(.)
		return

	interact(user)

/obj/machinery/computer/nuke_disc_generator/interact(mob/user)
	usr.set_interaction(src)
	var/dat = ""
	dat += "<a href='?src=[REF(src)];mach_close=computer'>Close</a><br><br>"
	dat += "<div align='center'><a href='?src=[REF(src)];generate=1'>Generate Disc</a></div>"
	dat += "<br/>"
	dat += "<hr/>"
	dat += "<div align='center'><h2>Status</h2></div>"
	dat += "<span><b>Time left</b>: [generate_timer ? timeleft(generate_timer) * 0.1 : 0]</span>"
	if(last_error != "")
		dat += "<br/>"
		dat += "<span><b>Error</b>: <span class='warning notice'>[last_error]</span></span>"

	var/datum/browser/popup = new(user, "computer", "<div align='center'>Nuke Disc Generator</div>")
	popup.set_content(dat)
	popup.open()

/obj/machinery/computer/nuke_disc_generator/Topic(href, href_list)
	. = ..()
	if(.)
		return

	last_error = ""
	if(href_list["generate"])
		if(generate_timer)
			last_error = "Already generating a disc, please wait..."
			to_chat(usr, "<span class='notice'>Already generating a disc, please wait.</span>")
			return

		var/timer = (last_disc_timeleft > 0) ? last_disc_timeleft : disc_time // If we had a previous timer, use it again

		if(!red_disc)	
			generate_timer = addtimer(CALLBACK(src, .proc/print_disc, TRUE, FALSE, FALSE), timer, TIMER_STOPPABLE)
			visible_message("<span class='notice'>Generating red disc...</span>")
			return

		if(!green_disc)	
			generate_timer = addtimer(CALLBACK(src, .proc/print_disc, FALSE, TRUE, FALSE), timer, TIMER_STOPPABLE)
			visible_message("<span class='notice'>Generating green disc...</span>")
			return

		if(!blue_disc)	
			generate_timer = addtimer(CALLBACK(src, .proc/print_disc, FALSE, FALSE, TRUE), timer, TIMER_STOPPABLE)
			visible_message("<span class='notice'>Generating blue disc...</span>")
			return
		last_error = "Unable to generate any more discs, lack of required entropy."

	updateUsrDialog()


/obj/machinery/computer/nuke_disc_generator/proc/print_disc(red = FALSE, green = FALSE, blue = FALSE)
	last_error = ""
	generate_timer = null
	if(red)
		if(red_disc != null)
			last_error = "Failed to generate red disc"
			visible_message("<span class='warning'>Failed to generate red disc</span>")
			return
		red_disc = new(loc)
		visible_message("<span class='notice bold'>Disc printed</span>")
		return

	if(green)
		if(green_disc != null)
			last_error = "Failed to generate green disc"
			visible_message("<span class='warning'>Failed to generate green disc</span>")
			return
		green_disc = new(loc)
		visible_message("<span class='notice bold'>Disc printed</span>")
		return

	if(blue)
		if(blue_disc != null)
			last_error = "Failed to generate blue disc"
			visible_message("<span class='warning'>Failed to generate blue disc</span>")
			return
		blue_disc = new(loc)
		visible_message("<span class='notice bold'>Disc printed</span>")
		return
		




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