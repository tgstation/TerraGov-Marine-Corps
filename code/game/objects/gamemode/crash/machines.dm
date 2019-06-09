/obj/item/circuitboard/computer/pilotcomputer
	name = "Circuit board (Cockpit Computer)"
	build_path = /obj/machinery/computer/pilot_computer



/obj/machinery/computer/pilot_computer
	name = "Cockpit Computer"
	desc = "Used to control the ships main thrusters."
	icon_state = "atmos" // TODO: Better icon state
	circuit = "/obj/item/circuitboard/computer/pilotcomputer"


	var/list/obj/structure/shuttle/engine/ship_engines

	// TODO: Move this to the engine when it exists
	var/current_fuel = 0
	var/total_fuel = 1000

/obj/machinery/computer/pilot_computer/Initialize()
	. = ..()

	// Find the nearby
	ship_engines = list() // TODO: We need a dedicated engine path
	for(var/obj/structure/shuttle/engine/E in range(25)) // This will need adjust when we get the placement down
		ship_engines.Add(E)


/obj/machinery/computer/pilot_computer/attack_hand(mob/user)
	if(machine_stat & (BROKEN|NOPOWER))
		return
	interact(user)
	return


/obj/machinery/computer/pilot_computer/interact(mob/user)
	usr.set_interaction(src)
	var/dat = "<meta http-equiv='refresh' content='10'>"
	dat += "<a href='?src=[REF(user)];mach_close=pilot_computer'>close</a><br><br>"

	dat += "<span>Engine Fuel: [current_fuel] / [total_fuel]</span>"
	dat += "<br/><br/><br/>"
	dat += "<div align='center'><a href='?src=[REF(user)];launch=1'>Launch Shuttle</a></div>"

	var/datum/browser/popup = new(user, "pilot_computer", "<div align='center'>Cockpit Computer</div>")
	popup.set_content(dat)
	popup.open(FALSE)
	onclose(user, "pilot_computer")


/obj/machinery/computer/pilot_computer/Topic(href, href_list)
	if(..())
		return

	if(href_list["launch"])
		// TODO: Add timer and launch the shuttle.
		visible_message("Shuttle launching, please stand clear of the airlocks.")
	
	return


/obj/machinery/computer/pilot_computer/process()
	if (machine_stat & (NOPOWER))
		icon_state = "atmos0"
		return
	if(machine_stat & (BROKEN))
		icon_state = "atmosb"
		return

	current_fuel = 0
	for(var/i in ship_engines)
		var/obj/structure/shuttle/engine/E = i
		// current_fuel += E.fuel_amount  //TODO: Enable when engines work

	if (current_fuel > total_fuel)
		visible_message("Ship fueled") // TODO: Better message
