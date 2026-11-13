/datum/wires/navigation
	holder_type = /obj/machinery/computer/navigation
	proper_name = "Navigation"


/datum/wires/navigation/New(atom/holder)
	wires = list(
		WIRE_POWER,
		WIRE_IDSCAN, WIRE_AI
	)
	add_duds(6)
	return ..()


/datum/wires/navigation/can_interact(mob/user)
	. = ..()
	if(!.)
		return
	var/obj/machinery/computer/navigation/A = holder
	if(CHECK_BITFIELD(A.machine_stat, PANEL_OPEN))
		return TRUE


/datum/wires/navigation/get_status()
	var/obj/machinery/computer/navigation/A = holder
	. = list()
	. += "The interface light is [A.authenticated ? "red" : "green"]."
	. += "The short indicator is [A.shorted ? "lit" : "off"]."
	. += "The AI connection light is [!A.aidisabled ? "on" : "off"]."


/datum/wires/navigation/on_pulse(wire)
	var/obj/machinery/computer/navigation/A = holder
	switch(wire)
		if(WIRE_POWER) // Short out for a long time.
			if(!A.shorted)
				A.shorted = TRUE
				A.update_icon()
			addtimer(CALLBACK(A, TYPE_PROC_REF(/obj/machinery/computer/navigation, reset), wire), 2 MINUTES)
		if(WIRE_IDSCAN) // Toggle lock.
			A.authenticated = !A.authenticated //this may not be ideal, human is 1 AI is 2.
		if(WIRE_AI) // Disable AI control for a while.
			if(!A.aidisabled)
				A.aidisabled = TRUE
			addtimer(CALLBACK(A, TYPE_PROC_REF(/obj/machinery/computer/navigation, reset), wire), 10 SECONDS)


/datum/wires/navigation/on_cut(wire, mend, mob/user)
	var/obj/machinery/computer/navigation/A = holder
	switch(wire)
		if(WIRE_POWER) // Short out forever.
			A.shock(usr, 50)
			A.shorted = !mend
			A.update_icon()
		if(WIRE_IDSCAN)
			if(!mend)
				A.authenticated = TRUE
		if(WIRE_AI)
			A.aidisabled = mend // Enable/disable AI control.
