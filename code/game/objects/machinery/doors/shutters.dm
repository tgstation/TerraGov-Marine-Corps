/obj/machinery/door/poddoor/shutters
	name = "\improper Shutters"
	icon = 'icons/obj/doors/rapid_pdoor.dmi'
	icon_state = "shutter1"
	power_channel = ENVIRON
	resistance_flags = DROPSHIP_IMMUNE

/obj/machinery/door/poddoor/shutters/Initialize(mapload)
	. = ..()
	if(density && closed_layer)
		layer = closed_layer
	else if(!density && open_layer)
		layer = open_layer
	else
		layer = PODDOOR_CLOSED_LAYER

/obj/machinery/door/poddoor/shutters/open()
	if(operating)
		return FALSE
	if(!SSticker)
		return FALSE
	if(!operating)
		operating = TRUE
	do_animate("opening")
	icon_state = "shutter0"
	playsound(loc, 'sound/machines/shutter.ogg', 25)
	addtimer(CALLBACK(src, PROC_REF(do_open)), 1 SECONDS)
	return TRUE

/obj/machinery/door/poddoor/shutters/proc/do_open()
	density = FALSE
	layer = open_layer
	set_opacity(FALSE)

	if(operating)
		operating = FALSE
	if(autoclose)
		addtimer(CALLBACK(src, PROC_REF(autoclose)), 150)

/obj/machinery/door/poddoor/shutters/close()
	if(operating)
		return
	operating = TRUE
	do_animate("closing")
	icon_state = "shutter1"
	layer = closed_layer
	density = TRUE
	if(visible)
		set_opacity(TRUE)
	playsound(loc, 'sound/machines/shutter.ogg', 25)
	addtimer(CALLBACK(src, PROC_REF(do_close)), 1 SECONDS)
	return TRUE

/obj/machinery/door/poddoor/shutters/proc/do_close()
	operating = FALSE


/obj/machinery/door/poddoor/shutters/update_icon()
	if(operating)
		return
	icon_state = "shutter[density]"


/obj/machinery/door/poddoor/shutters/do_animate(animation)
	switch(animation)
		if("opening")
			flick("shutterc0", src)
		if("closing")
			flick("shutterc1", src)


/obj/machinery/door/poddoor/shutters/timed_late
	icon = 'icons/obj/doors/mainship/blastdoors_shutters.dmi'
	name = "Timed Emergency Shutters"
	use_power = FALSE


/obj/machinery/door/poddoor/shutters/timed_late/Initialize(mapload)
	RegisterSignals(SSdcs, list(COMSIG_GLOB_OPEN_TIMED_SHUTTERS_LATE, COMSIG_GLOB_OPEN_TIMED_SHUTTERS_CRASH, COMSIG_GLOB_OPEN_TIMED_SHUTTERS_XENO_HIVEMIND, COMSIG_GLOB_CAMPAIGN_MISSION_STARTED), PROC_REF(open))
	return ..()


/obj/machinery/door/poddoor/shutters/opened
	icon_state = "shutter0"
	density = FALSE
	opacity = FALSE

/obj/machinery/door/poddoor/shutters/opened/medbay
	name = "Medbay Lockdown Shutters"
	id = "Medbay"

/obj/machinery/door/poddoor/shutters/opened/wy
	id = "wyoffice"

/obj/machinery/door/poddoor/shutters/mainship
	icon = 'icons/obj/doors/mainship/blastdoors_shutters.dmi'
	icon_state = "shutter1"
	openspeed = 4 //shorter open animation.

/obj/machinery/door/poddoor/shutters/mainship/thunderdome/one
	name = "Thunderdome Blast Door"
	id = "thunderdome1"
	resistance_flags = RESIST_ALL


/obj/machinery/door/poddoor/shutters/mainship/thunderdome/two
	name = "Thunderdome Blast Door"
	id = "thunderdome2"
	resistance_flags = RESIST_ALL

//transit shutters used by marine dropships
/obj/machinery/door/poddoor/shutters/transit
	name = "Transit shutters"
	desc = "Safety shutters to prevent dangerous depressurization during flight"
	icon = 'icons/obj/doors/mainship/blastdoors_shutters.dmi'
	resistance_flags = RESIST_ALL|DROPSHIP_IMMUNE
	id = "ghhjmugggggtgggbg" // do not have any button or thing have an ID assigned to this, it is a very bad idea.
	smoothing_groups = list(SMOOTH_GROUP_SURVIVAL_TITANIUM_WALLS)


/obj/machinery/door/poddoor/shutters/mainship/open
	density = FALSE
	opacity = FALSE
	layer = PODDOOR_OPEN_LAYER
	icon_state = "shutter0"


/obj/machinery/door/poddoor/shutters/mainship/selfdestruct
	name = "Self Destruct Lockdown"
	id = "sd_lockdown"
	resistance_flags = RESIST_ALL

/obj/machinery/door/poddoor/shutters/mainship/open/hangar
	name = "\improper Hangar Shutters"
	id = "hangar_shutters"

/obj/machinery/door/poddoor/shutters/mainship/open/checkpoint
	name = "Checkpoint Shutters"


/obj/machinery/door/poddoor/shutters/mainship/open/checkpoint/north
	id = "northcheckpoint"


/obj/machinery/door/poddoor/shutters/mainship/open/checkpoint/south
	id = "southcheckpoint"

/obj/machinery/door/poddoor/shutters/mainship/open/medical
	name = "Medbay Lockdown Shutters"
	id = "medbay_lockdown"

/obj/machinery/door/poddoor/shutters/mainship/open/indestructible
	resistance_flags = RESIST_ALL|DROPSHIP_IMMUNE


/obj/machinery/door/poddoor/shutters/transit/open
	density = FALSE
	opacity = FALSE
	resistance_flags = RESIST_ALL|DROPSHIP_IMMUNE
	layer = PODDOOR_OPEN_LAYER
	icon_state = "shutter0"

/obj/machinery/door/poddoor/shutters/barren
	resistance_flags = UNACIDABLE|DROPSHIP_IMMUNE

/obj/machinery/door/poddoor/shutters/mainship/pressure
	name = "pressure shutters"
	density = FALSE
	opacity = FALSE
	resistance_flags = RESIST_ALL|DROPSHIP_IMMUNE
	icon_state = "shutter0"
	open_layer = PODDOOR_CLOSED_LAYER
	closed_layer = PODDOOR_CLOSED_LAYER

/obj/machinery/door/poddoor/shutters/tadpole_cockpit
	name = "pressure shutters"
	density = FALSE
	opacity = FALSE
	icon_state = "shutter0"
	open_layer = PODDOOR_CLOSED_LAYER
	closed_layer = PODDOOR_CLOSED_LAYER

//mainship shutters
/obj/machinery/door/poddoor/shutters/mainship/hangar
	name = "\improper Hangar Shutters"
	id = "hangar_shutters"

/obj/machinery/door/poddoor/shutters/mainship/hangar/fuel
	name = "\improper Solid Fuel Storage"
	id = "solid_fuel"

/obj/machinery/door/poddoor/shutters/mainship/req
	name = "\improper Requisitions Shutters"
	icon_state = "shutter1"

/obj/machinery/door/poddoor/shutters/mainship/req/ro
	name = "\improper RO Line"
	id = "ROlobby"
/obj/machinery/door/poddoor/shutters/mainship/req/ro1
	name = "\improper RO Line 1"
	id = "ROlobby1"

/obj/machinery/door/poddoor/shutters/mainship/req/ro2
	name = "\improper RO Line 2"
	id = "ROlobby2"

/obj/machinery/door/poddoor/shutters/mainship/containment
	name = "\improper Containment Cell"
	id = "containmentcell"
	icon_state = "shutter1"

/obj/machinery/door/poddoor/shutters/mainship/containment/cell1
	name = "\improper Containment Cell 1"
	id = "containmentcell_1"

/obj/machinery/door/poddoor/shutters/mainship/containment/cell2
	name = "\improper Containment Cell 2"
	id = "containmentcell_2"

/obj/machinery/door/poddoor/shutters/mainship/brigarmory
	name = "\improper Brig Armory Shutters"
	id = "brig_armory"
	icon_state = "shutter1"

/obj/machinery/door/poddoor/shutters/mainship/cic
	name = "\improper CIC Shutters"

/obj/machinery/door/poddoor/shutters/mainship/cic/armory
	name = "\improper Armory Shutters"
	id = "cic_armory"
	icon_state = "shutter1"

/obj/machinery/door/poddoor/shutters/mainship/engineering/armory
	name = "\improper Engineering Armory Shutters"
	id = "engi_armory"
	icon_state = "shutter1"

/obj/machinery/door/poddoor/shutters/mainship/corporate
	name = "\improper Privacy Shutters"
	id = "cl_shutters"

/obj/machinery/door/poddoor/shutters/mainship/corporate
	name = "\improper Privacy Shutters"
	id = "cl_shutters"

/obj/machinery/door/poddoor/shutters/mainship/cell
	name = "\improper Containment Cell"
	id = "Containment Cell"

/obj/machinery/door/poddoor/shutters/mainship/cell/cell1
	name = "\improper Containment Cell 1"
	id = "Containment Cell 1"

/obj/machinery/door/poddoor/shutters/mainship/cell/cell2
	name = "\improper Containment Cell 2"
	id = "Containment Cell 2"
