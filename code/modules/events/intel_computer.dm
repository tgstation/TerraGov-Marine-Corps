/datum/round_event_control/intel_computer
	name = "Intel computer activation"
	typepath = /datum/round_event/intel_computer
	weight = 25

	gamemode_blacklist = list("Crash", "Combat Patrol", "Sensor Capture", "Campaign", "Zombie Crash")
	/// the intel computer for the next event to activate
	var/obj/machinery/computer/intel_computer/intel_computer

/datum/round_event_control/intel_computer/can_spawn_event(players_amt, gamemode, force = FALSE)
	. = ..()
	if(!.)
		return
	if(istype(intel_computer) && (!(intel_computer.active)))
		return TRUE
	if(length(GLOB.intel_computers) <= 0)
		return FALSE
	for(var/obj/machinery/computer/intel_computer/I in shuffle(GLOB.intel_computers))
		if(I.active)
			continue
		intel_computer = I
		break
	if((!istype(intel_computer)) || intel_computer.active)
		intel_computer = null
		return FALSE
	return TRUE

/datum/round_event/intel_computer
	var/areas_list = list()

/datum/round_event/intel_computer/start()
	var/datum/round_event_control/intel_computer/intel_control = control
	if(!istype(intel_control))
		intel_control = new
	var/obj/machinery/computer/intel_computer/intel_computer = intel_control.intel_computer
	if((!istype(intel_computer)) || intel_computer.active)
		if(!intel_control.can_spawn_event(force = TRUE))
			qdel(src)
			return
		intel_computer = intel_control.intel_computer
	areas_list = list(get_area(intel_computer))
	activate(intel_computer)
	intel_control.intel_computer = null
	for(var/obj/machinery/computer/intel_computer/I in shuffle(GLOB.intel_computers))
		if(I.active)
			continue
		if(I == intel_computer)
			continue
		if(prob(25)) //25% chance to activate and roll for another to pop up.
			areas_list |= get_area(I)
			activate(I)
			continue
		break
	minor_announce("Our data sifting algorithm has detected valuable classified information on a access points in: [english_list(areas_list)]. Should this data be recovered by ground forces, a reward will be given in the form of increased assets. Watch out for hostile forces, this is now a likely conflict zone.", title = "NTC Intel Division")
	xeno_message("We sense a looming threat from [english_list(areas_list)]. We must keep the hosts away from there.")
	qdel(src)

///sets the icon on the map. Toggles it between active and inactive, notifies xenos and marines of the existence of the computer.
/datum/round_event/intel_computer/proc/activate(obj/machinery/computer/intel_computer/I)
	I.active = TRUE
	//ntf later edit to tie resetting to the event itself instead of shitty timer so there is less computers to go around, but more reward.
	START_PROCESSING(SSmachines, I)
	I.first_login = FALSE
	I.logged_in = FALSE
	I.progress = 0
	I.printing = FALSE
	I.printing_complete = FALSE
	I.update_icon()
	I.update_minimap_icon()
