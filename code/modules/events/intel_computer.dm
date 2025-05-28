/datum/round_event_control/intel_computer
	name = "Intel computer activation"
	typepath = /datum/round_event/intel_computer
	weight = 25

	gamemode_blacklist = list("Crash", "Combat Patrol", "Sensor Capture", "Campaign")

/datum/round_event_control/intel_computer/can_spawn_event(	players_amt, gamemode)
	if(length(GLOB.intel_computers) <= 0)
		return FALSE
	return ..()

/datum/round_event/intel_computer/start()
	for(var/obj/machinery/computer/intel_computer/I in shuffle(GLOB.intel_computers))
		if(I.active)
			continue

		activate(I)
		break

///sets the icon on the map. Toggles it between active and inactive, notifies xenos and marines of the existence of the computer.
/datum/round_event/intel_computer/proc/activate(obj/machinery/computer/intel_computer/I)
	I.active = TRUE

	I.update_minimap_icon()
	minor_announce("Our data sifting algorithm has detected valuable classified information on a access point in [get_area(I)]. Should this data be recovered by ground forces, a reward will be given in the form of increased assets. Watch out for hostile forces, this is now a likely conflict zone.", title = "NTC Intel Division")
	xeno_message("We sense a looming threat from [get_area(I)]. We must keep the hosts away from there.")
//ntf later edit to tie resetting to the event itself instead of shitty timer so there is less computers to go around, but more reward.
	START_PROCESSING(SSmachines, I)
	I.first_login = FALSE
	I.logged_in = FALSE
	I.progress = 0
	I.printing = FALSE
	I.printing_complete = FALSE
	I.update_icon()
