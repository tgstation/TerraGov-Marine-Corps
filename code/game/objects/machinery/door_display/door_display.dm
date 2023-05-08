///////////////////////////////////////////////////////////////////////////////////////////////
//  Parent of all door displays.
//  Description: This is a controls the timer for the brig doors, displays the timer on itself and
//               has a popup window when used, allowing to set the timer.
//  Code Notes: Combination of old brigdoor.dm code from rev4407 and the status_display.dm code
//  Date: 01/September/2010 -- changed 8/5/2023
//  Programmer: Veryinky
/////////////////////////////////////////////////////////////////////////////////////////////////
/obj/machinery/door_display
	name = "Door Display"
	icon = 'icons/obj/status_display.dmi'
	icon_state = "frame"
	desc = "A remote control for a door."
	anchored = TRUE
	density = FALSE
	interaction_flags = INTERACT_MACHINE_TGUI
	///Does this type allow for flashers?
	var/has_flash = FALSE
	///Does this type allow for shutters?
	var/has_shutters = FALSE
	var/open = FALSE		// If door is open.
	var/open_shutter = FALSE
	var/id = null     		// id of door it controls.
	var/list/obj/machinery/targets = list()

/obj/machinery/door_display/Initialize(mapload)
	. = ..()
	switch(dir)
		if(NORTH)
			pixel_y += -32
		if(SOUTH)
			pixel_y += 32
		if(EAST)
			pixel_x += 32
		if(WEST)
			pixel_x += -32

	return INITIALIZE_HINT_LATELOAD

/obj/machinery/door_display/LateInitialize()
	for(var/obj/machinery/door/D in GLOB.machines)
		if(D.id == id)
			targets += D
	if(has_flash)
		for(var/obj/machinery/flasher/flasher in GLOB.machines)
			if(flasher.id == id)
				targets += flasher

	if(!length(targets))
		machine_stat |= BROKEN
	update_icon()

/obj/machinery/door_display/proc/toggle_doors(state)
	for(var/obj/machinery/door/door in targets)
		if(state) //true for open
			door.open()
		else
			door.close()
	open = state

/obj/machinery/door_display/proc/toggle_shutters(state)
	if(!state)
		toggle_doors(FALSE)
	for(var/obj/machinery/door/poddoor/door in targets)
		if(door.density == !state)
			continue
		if(state) //true for open
			door.open()
		else
			door.close()
	open_shutter = state

/obj/machinery/door_display/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "DoorDisplay", "[name]")
		ui.open()

/obj/machinery/door_display/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return
	if(machine_stat & (NOPOWER|BROKEN))
		return FALSE
	switch(action)
		if("door")
			var/state = text2num(params["state"])
			if(!isnum(state))
				return FALSE
			toggle_doors(state)
			return TRUE
		if("shutter")
			var/state = text2num(params["state"])
			if(!isnum(state))
				return FALSE
			toggle_shutters(state)
			return TRUE
		if("flash")
			for(var/obj/machinery/flasher/flasher in targets)
				flasher.flash()
			return TRUE

/obj/machinery/door_display/ui_data(mob/user)
	var/list/data = list()
	data["has_flash"] = has_flash
	data["has_shutters"] = has_shutters
	data["shutter_state"] = open_shutter
	data["door_state"] = open
	data["id"] = id

	return data

//icon update function
// if NOPOWER, display blank
// if BROKEN, display blue screen of death icon AI uses
/obj/machinery/door_display/update_icon()
	cut_overlays()
	if (machine_stat & (NOPOWER))
		return
	if (machine_stat & (BROKEN))
		add_overlay("ai_bsod")
		return
	if(open)
		add_overlay("open")
	else
		add_overlay("closed")

//************ RESEARCH DOORS ****************\\
// Research cells have flashers and shutters/pod doors.
/obj/machinery/door_display/research_cell
	has_flash = TRUE
	has_shutters = TRUE

/obj/machinery/door_display/research_cell/toggle_doors(state)
	for(var/obj/machinery/door/airlock/door in targets)
		if(state) //true for open
			door.unlock()
			door.open()
		else
			door.close()
			door.lock(forced = TRUE)
	open = state

/obj/machinery/door_display/research_cell/cell
	name = "Containment Cell Control"
	id = "Containment Cell"

/obj/machinery/door_display/research_cell/cell/cell1
	name = "Containment Cell 1 Control"
	id = "Containment Cell 1"

/obj/machinery/door_display/research_cell/cell/cell2
	name = "Containment Cell 2 Control"
	id = "Containment Cell 2"
