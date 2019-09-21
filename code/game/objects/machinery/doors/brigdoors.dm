/obj/machinery/door_timer
	name = "Door Timer"
	icon = 'icons/obj/status_display.dmi'
	icon_state = "frame"
	desc = "A remote control for a door."
	req_access = list(ACCESS_MARINE_BRIG)
	anchored = TRUE    		// can't pick it up
	density = FALSE       		// can walk through it.
	var/id = null     		// id of door it controls.
	var/releasetime = 0		// when world.timeofday reaches it - release the prisoner
	var/timing = 1    		// boolean, true/1 timer is on, false/0 means it's not timing
	var/picture_state		// icon_state of alert picture, if not displaying text/numbers
	var/list/obj/machinery/targets = list()
	var/timetoset = 0		// Used to set releasetime upon starting the timer

	maptext_height = 26
	maptext_width = 32

/obj/machinery/door_timer/Initialize(mapload, newDir)
	. = ..()

	if(newDir)
		setDir(newDir)

	switch(dir)
		if(NORTH)
			pixel_y = 32
		if(SOUTH)
			pixel_y = -32
		if(EAST)
			pixel_x = 32
		if(WEST)
			pixel_x = -32

	for(var/obj/machinery/door/window/brigdoor/M in GLOB.machines)
		if (M.id == src.id)
			targets += M

	for(var/obj/machinery/flasher/F in GLOB.machines)
		if(F.id == src.id)
			targets += F

	for(var/obj/structure/closet/secure_closet/brig/C in GLOB.brig_closets)
		if(C.id == src.id)
			targets += C

	if(targets.len==0)
		machine_stat |= BROKEN
	update_icon()

//Main door timer loop, if it's timing and time is >0 reduce time by 1.
// if it's less than 0, open door, reset timer
// update the door_timer window and the icon
/obj/machinery/door_timer/process()

	if(machine_stat & (NOPOWER|BROKEN))	return
	if(src.timing)

		// poorly done midnight rollover
		// (no seriously there's gotta be a better way to do this)
		var/timeleft = timeleft()
		if(timeleft > 1e5)
			src.releasetime = 0


		if(world.timeofday > src.releasetime)
			src.timer_end() // open doors, reset timer, clear status screen
			src.timing = 0

		src.updateUsrDialog()
		src.update_icon()

	else
		timer_end()

	return

// open/closedoor checks if door_timer has power, if so it checks if the
// linked door is open/closed (by density) then opens it/closes it.

// Closes and locks doors, power check
/obj/machinery/door_timer/proc/timer_start()
	if(machine_stat & (NOPOWER|BROKEN))	return 0

	// Set releasetime
	releasetime = world.timeofday + timetoset

	for(var/obj/machinery/door/window/brigdoor/door in targets)
		if(door.density)	continue
		INVOKE_ASYNC(door, /obj/machinery/door.proc/close)

	for(var/obj/structure/closet/secure_closet/brig/C in targets)
		if(C.broken)	continue
		if(C.opened && !C.close())	continue
		C.locked = 1
		C.icon_state = C.icon_locked
	start_processing()
	return 1


// Opens and unlocks doors, power check
/obj/machinery/door_timer/proc/timer_end()
	if(machine_stat & (NOPOWER|BROKEN))	return 0

	// Reset releasetime
	releasetime = 0

	for(var/obj/machinery/door/window/brigdoor/door in targets)
		if(!door.density)	continue
		INVOKE_ASYNC(door, /obj/machinery/door.proc/open)

	for(var/obj/structure/closet/secure_closet/brig/C in targets)
		if(C.broken)	continue
		if(C.opened)	continue
		C.locked = 0
		C.icon_state = C.icon_closed
	stop_processing()
	return 1


// Check for releasetime timeleft
/obj/machinery/door_timer/proc/timeleft()
	. = (releasetime - world.timeofday)/10
	if(. < 0)
		. = 0

// Set timetoset
/obj/machinery/door_timer/proc/timeset(seconds)
	timetoset = seconds * 10

	if(timetoset <= 0)
		timetoset = 0

	return


/obj/machinery/door_timer/interact(mob/user)
	. = ..()
	if(.)
		return

	// Used for the 'time left' display
	var/second = round(timeleft() % 60)
	var/minute = round((timeleft() - second) / 60)

	// Used for 'set timer'
	var/setsecond = round((timetoset / 10) % 60)
	var/setminute = round(((timetoset / 10) - setsecond) / 60)

	var/dat

	dat += " <b>Door [src.id] controls</b><br/>"

	// Start/Stop timer
	if (src.timing)
		dat += "<a href='?src=\ref[src];timing=0'>Stop Timer and open door</a><br/>"
	else
		dat += "<a href='?src=\ref[src];timing=1'>Activate Timer and close door</a><br/>"

	// Time Left display (uses releasetime)
	dat += "Time Left: [(minute ? text("[minute]:") : null)][second] <br/>"
	dat += "<br/>"

	// Set Timer display (uses timetoset)
	if(src.timing)
		dat += "Set Timer: [(setminute ? text("[setminute]:") : null)][setsecond]  <a href='?src=\ref[src];change=1'>Set</a><br/>"
	else
		dat += "Set Timer: [(setminute ? text("[setminute]:") : null)][setsecond]<br/>"

	// Controls
	dat += "<a href='?src=\ref[src];tp=-60'>-</a> <a href='?src=\ref[src];tp=-1'>-</a> <a href='?src=\ref[src];tp=1'>+</a> <A href='?src=\ref[src];tp=60'>+</a><br/>"

	// Mounted flash controls
	for(var/obj/machinery/flasher/F in targets)
		if(F.last_flash && (F.last_flash + 150) > world.time)
			dat += "<br/><A href='?src=\ref[src];fc=1'>Flash Charging</A>"
		else
			dat += "<br/><A href='?src=\ref[src];fc=1'>Activate Flash</A>"

	var/datum/browser/popup = new(user, "computer", "<div align='center'>Timer System</div>", 400, 500)
	popup.set_content(dat)
	popup.open()


/obj/machinery/door_timer/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(href_list["timing"])
		src.timing = text2num(href_list["timing"])

		if(src.timing)
			src.timer_start()
		else
			src.timer_end()

	else
		if(href_list["tp"])  //adjust timer, close door if not already closed
			var/tp = text2num(href_list["tp"])
			var/addtime = (timetoset / 10)
			addtime += tp
			addtime = min(max(round(addtime), 0), 3600)

			timeset(addtime)

		if(href_list["fc"])
			for(var/obj/machinery/flasher/F in targets)
				F.flash()

		if(href_list["change"])
			src.timer_start()

	updateUsrDialog()
	update_icon()


//icon update function
// if NOPOWER, display blank
// if BROKEN, display blue screen of death icon AI uses
// if timing=true, run update display function
/obj/machinery/door_timer/update_icon()
	if(machine_stat & (NOPOWER))
		icon_state = "frame"
		return
	if(machine_stat & (BROKEN))
		set_picture("ai_bsod")
		return
	if(src.timing)
		var/disp1 = id
		var/timeleft = timeleft()
		var/disp2 = "[add_zero(num2text((timeleft / 60) % 60),2)]~[add_zero(num2text(timeleft % 60), 2)]"
		if(length(disp2) > 5)
			disp2 = "Error"
		update_display(disp1, disp2)
	else
		if(maptext)	maptext = ""
	return


// Adds an icon in case the screen is broken/off, stolen from status_display.dm
/obj/machinery/door_timer/proc/set_picture(state)
	picture_state = state
	overlays.Cut()
	overlays += image('icons/obj/status_display.dmi', icon_state=picture_state)


//Checks to see if there's 1 line or 2, adds text-icons-numbers/letters over display
// Stolen from status_display
/obj/machinery/door_timer/proc/update_display(line1, line2)
	var/new_text = {"<div style="font-size:'5pt'; color:'#09f'; font:'Arial Black';text-align:center;" valign="top">[line1]<br>[line2]</div>"}
	if(maptext != new_text)
		maptext = new_text


//Actual string input to icon display for loop, with 5 pixel x offsets for each letter.
//Stolen from status_display
/obj/machinery/door_timer/proc/texticon(tn, px = 0, py = 0)
	var/image/I = image('icons/obj/status_display.dmi', "blank")
	var/len = lentext(tn)

	for(var/d = 1 to len)
		var/char = copytext(tn, len-d+1, len-d+2)
		if(char == " ")
			continue
		var/image/ID = image('icons/obj/status_display.dmi', icon_state=char)
		ID.pixel_x = -(d-1)*5 + px
		ID.pixel_y = py
		I.overlays += ID
	return I


/obj/machinery/door_timer/cell_1
	name = "Cell 1"
	id = "Cell 1"

/obj/machinery/door_timer/cell_2
	name = "Cell 2"
	id = "Cell 2"

/obj/machinery/door_timer/cell_3
	name = "Cell 3"
	id = "Cell 3"

/obj/machinery/door_timer/cell_4
	name = "Cell 4"
	id = "Cell 4"

/obj/machinery/door_timer/cell_5
	name = "Cell 5"
	id = "Cell 5"

/obj/machinery/door_timer/cell_6
	name = "Cell 6"
	id = "Cell 6"
