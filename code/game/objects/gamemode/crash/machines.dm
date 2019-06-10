/obj/item/circuitboard/computer/pilotcomputer
	name = "Circuit board (Cockpit Computer)"
	build_path = /obj/machinery/computer/pilot_computer


/obj/machinery/computer/pilot_computer
	name = "Cockpit Computer"
	desc = "Used to control the ships main thrusters."
	icon_state = "atmos" // TODO: Better icon state
	circuit = "/obj/item/circuitboard/computer/pilotcomputer"

	var/list/obj/structure/shuttle/engine/ship_engines
	var/last_announce

/obj/machinery/computer/pilot_computer/Initialize()
	. = ..()

	// Find the nearby
	ship_engines = list() // TODO: We need a dedicated engine path
	for(var/obj/structure/shuttle/engine/E in range(25)) // This will need adjust when we get the placement down
		ship_engines.Add(E)

	last_announce = world.time


/obj/machinery/computer/pilot_computer/attack_hand(mob/user)
	if(machine_stat & (BROKEN|NOPOWER))
		return

	last_announce = world.time // reset every time someone uses the machine
	interact(user)
	return


/obj/machinery/computer/pilot_computer/interact(mob/user)
	usr.set_interaction(src)
	var/dat = ""
	dat += "<a href='?src=[REF(user)];mach_close=pilot_computer'>Close</a><br><br>"

	var/engine_count = 1
	for(var/i in ship_engines)
		dat += "<b>Engine #[engine_count++]</b><br/>"
		var/obj/structure/shuttle/engine/E = i
		var/fuel_level = max(0, min(100, round((E.fuel_current / E.fuel_max) * 100)))
		dat += "<span>Engine Fuel: [E.fuel_current] / [E.fuel_max] ([fuel_level]%)</span><br />"
		switch (fuel_level)
			if(-INFINITY to 10)
				dat += "<span class='notice'> - Engine fuel dangerously low</span><br />"
			if(11 to 35)
				dat += "<span class='warning'> - Engine fuel low</span><br />"
		
		dat += "<br/>"
		
	dat += "<br/>"
	dat += "<div align='center'><a href='?src=[REF(user)];launch=1'>Launch Shuttle</a></div>"

	var/datum/browser/popup = new(user, "pilot_computer", "<div align='center'>Cockpit Computer</div>")
	popup.set_content(dat)
	popup.open(FALSE)
	onclose(user, "pilot_computer")


/obj/machinery/computer/pilot_computer/Topic(href, href_list)
	. = ..()
	if(.)
		to_chat("returning bad")
		return

	if(href_list["launch"])
		// TODO: Add timer and launch the shuttle.
		to_chat(world, "launch pushed")
		visible_message("Shuttle launching, please stand clear of the airlocks.")
		return
	return


/obj/machinery/computer/pilot_computer/process()
	if(machine_stat & (BROKEN))
		icon_state = "atmosb" // TODO: replace icon
		return

	if (world.time < (last_announce + 1 MINUTES))	
		return

	var/engine_alert = "Fuel status: "
	var/engine_count = 1
	for(var/i in ship_engines)
		var/obj/structure/shuttle/engine/E = i
		var/fuel_level = max(0, min(100, round((E.fuel_current / E.fuel_max) * 100)))
		engine_alert += "Engine #[engine_count++]: [fuel_level]%. "

	last_announce = world.time
	visible_message(engine_alert)