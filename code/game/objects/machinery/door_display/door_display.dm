///////////////////////////////////////////////////////////////////////////////////////////////
//  Parent of all door displays.
//  Description: This is a controls the timer for the brig doors, displays the timer on itself and
//               has a popup window when used, allowing to set the timer.
//  Code Notes: Combination of old brigdoor.dm code from rev4407 and the status_display.dm code
//  Date: 01/September/2010
//  Programmer: Veryinky
/////////////////////////////////////////////////////////////////////////////////////////////////
/obj/machinery/door_display
	name = "Door Display"
	icon = 'icons/obj/status_display.dmi'
	icon_state = "frame"
	desc = "A remote control for a door."
	anchored = TRUE
	density = FALSE
	var/open = FALSE		// If door is open.
	var/id = null     		// id of door it controls.
	var/list/obj/machinery/targets = list()

/obj/machinery/door_display/Initialize()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/door_display/LateInitialize()
	for(var/obj/machinery/door/D in GLOB.machines)
		if (D.id == id)
			targets += D

	if(!length(targets))
		machine_stat |= BROKEN
	update_icon()

// open/closedoor checks if door_display has power, if so it checks if the
// linked door is open/closed (by density) then opens it/closes it.

// Opens and locks doors, power check
/obj/machinery/door_display/proc/open_door()
	if(machine_stat & (NOPOWER|BROKEN))
		return FALSE

	for(var/obj/machinery/door/D in targets)
		if(!D.density)
			continue
		D.open()

	open = TRUE

	return TRUE


// Closes and unlocks doors, power check
/obj/machinery/door_display/proc/close_door()
	if(machine_stat & (NOPOWER|BROKEN))
		return FALSE

	for(var/obj/machinery/door/D in targets)
		if(D.density)
			continue
		D.close()

	open = FALSE

	return TRUE

// Allows AIs to use door_display, see human attack_hand function below
/obj/machinery/door_display/attack_ai(mob/user as mob)
	return attack_hand(user)

// Allows humans to use door_display
// Opens dialog window when someone clicks on door timer
// Allows altering timer and the timing boolean.
/obj/machinery/door_display/attack_hand(mob/user as mob)
	. = ..()
	if(.)
		return

	user.set_interaction(src)

	var/datum/browser/popup = new(user, "computer", "<div align='center'>Door controls</div>", 300, 240)
	popup.set_content(display_contents(user))
	popup.open(FALSE)

/obj/machinery/door_display/proc/display_contents(mob/user as mob)
	var/data = "<HTML><BODY><TT>"

	data += "<HR>Linked Door:</hr>"
	data += " <b> [id]</b><br/>"

	if (open)
		data += "<a href='?src=\ref[src];open=0'>Close Door</a><br/>"
	else
		data += "<a href='?src=\ref[src];open=1'>Open Door</a><br/>"

	data += "<br/>"

	data += "<br/><a href='?src=\ref[user];mach_close=computer'>Close Display</a>"
	data += "</TT></BODY></HTML>"

	return data

/obj/machinery/door_display/Topic(href, href_list)
	. = ..()
	if(.)
		return
	if(!allowed(usr))
		return FALSE

	usr.set_interaction(src)

	if(href_list["open"])
		if (open)
			close_door()
		else
			open_door()
		update_icon()

	updateUsrDialog()

	return TRUE


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
	var/open_shutter = FALSE

/obj/machinery/door_display/research_cell/LateInitialize()
	..()
	for(var/obj/machinery/flasher/F in GLOB.machines)
		if(F.id == id)
			targets += F

/obj/machinery/door_display/research_cell/display_contents(mob/user as mob)

	var/data = "<hr>Linked Door:</hr>"
	data += " <b> [id]</b><br/><br/>"

	if(open_shutter)
		data += "<a href='?src=\ref[src];shutter=0; open=0'>Close Shutter</a><br/>"
	else
		data += "<a href='?src=\ref[src];shutter=1'>Open Shutter</a><br/>"

	if(!open_shutter)
		data += "<span class='linkOff'>Open Door</span><br/>"
	else
		if (open)
			data += "<a href='?src=\ref[src];open=0'>Close Door</a><br/>"
		else
			data += "<a href='?src=\ref[src];open=1'>Open Door</a><br/>"

	data += "<br/>"

	for(var/obj/machinery/flasher/F in targets)
		if(F.last_flash + 150 > world.time)
			data += "<span class='linkOff'>Flash Charging</span>"
		else
			data += "<a href='?src=\ref[src];flasher=1'>Activate Flash</a>"

	data += "<br/>"

	data += "<a href='?src=\ref[user];mach_close=computer'>Close Display</a>"

	return data

/obj/machinery/door_display/research_cell/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(href_list["flasher"]) //flashing timer is checked in the /flash proc, so the href is safe
		for(var/obj/machinery/flasher/F in targets)
			F.flash()

	if(href_list["shutter"])
		if (open_shutter)
			close_door()
			close_shutter()
		else
			open_shutter()
		update_icon()


	updateUsrDialog()

	return TRUE

/obj/machinery/door_display/research_cell/open_door()
	if(machine_stat & (NOPOWER|BROKEN))
		return FALSE

	for(var/obj/machinery/door/airlock/D in targets)
		if(!D.density)
			continue
		D.unlock()
		D.open()

	open = TRUE

	return TRUE

/obj/machinery/door_display/research_cell/close_door()
	if(machine_stat & (NOPOWER|BROKEN))
		return FALSE

	for(var/obj/machinery/door/airlock/D in targets)
		if(D.density)
			continue
		D.close()
		D.lock()

	open = FALSE

	return TRUE

/obj/machinery/door_display/research_cell/proc/open_shutter()
	if(machine_stat & (NOPOWER|BROKEN))
		return FALSE

	for(var/obj/machinery/door/poddoor/D in targets)
		if(!D.density)
			continue
		D.open()

	open_shutter = TRUE

	return TRUE

/obj/machinery/door_display/research_cell/proc/close_shutter()
	if(machine_stat & (NOPOWER|BROKEN))
		return FALSE

	for(var/obj/machinery/door/poddoor/D in targets)
		if(D.density)
			continue
		D.close()

	open_shutter = FALSE

	return TRUE