//A thing for 'navigating' the current ship map up or down the gravity well.

#define ESCAPE_VELOCITY 5
#define SAFE_DISTANCE 4
#define STANDARD_ORBIT 3
#define CLOSE_ORBIT 2
#define SKIM_ATMOSPHERE 1

#define REQUIRED_POWER_AMOUNT 250000
#define AUTO_LOGOUT_TIME 1 MINUTES

#define AUTHORIZED 1
#define AUTHORIZED_PLUS 2

//so we can use the current orbit in other files
GLOBAL_VAR_INIT(current_orbit,STANDARD_ORBIT)

/obj/machinery/computer/navigation
	name = "\improper Helms computer"
	icon_state = "shuttlecomputer"
	density = TRUE
	anchored = TRUE
	idle_power_usage = 10
	req_access = list(ACCESS_MARINE_BRIDGE)
	///boolean the spaceship it currently in the process of changing orbits
	var/changing_orbit = TRUE
	///boolean there is an authorized person logged into this console. TRUE = logged in authorized person
	var/authenticated = FALSE
	///boolean this machine is cut off from power and is sparking uncontrollably FALSE = everything fine
	var/shorted = FALSE
	///boolean this machine can be interacted with by the AI player. FELSE = can interact
	var/aidisabled = FALSE

//-------------------------------------------
// Standard procs
//-------------------------------------------

/obj/machinery/computer/navigation/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()

	if(.)
		return

	//keep this? make it hackable so regular marines can run?
	TOGGLE_BITFIELD(machine_stat, PANEL_OPEN)
	update_icon()
	to_chat(user, "The wires have been [CHECK_BITFIELD(machine_stat, PANEL_OPEN) ? "exposed" : "unexposed"]")


/obj/machinery/computer/navigation/Initialize() //need anything special?
	. = ..()
	desc = "The navigation console for the [SSmapping.configs[SHIP_MAP].map_name]."
	addtimer(VARSET_CALLBACK(src, changing_orbit, FALSE), 30 MINUTES) //people running away far too quickly it seems

/obj/machinery/computer/navigation/proc/reset(wire)
	switch(wire)
		if(WIRE_POWER)
			if(!wires.is_cut(WIRE_POWER))
				shorted = FALSE
				update_icon()
		if(WIRE_AI)
			if(!wires.is_cut(WIRE_AI))
				aidisabled = FALSE

//-------------------------------------------
// Special procs
//-------------------------------------------

/obj/machinery/computer/navigation/proc/get_power_amount()
	//check current powernet for total available power
	if(!powered())
		return 0

	var/area/here_we_are = get_area(src)
	var/obj/machinery/power/apc/myAPC = here_we_are.get_apc()

	return myAPC?.terminal?.powernet?.avail

/obj/machinery/computer/navigation/interact(mob/user)
	. = ..()
	if(.)
		return

	var/dat

	if(authenticated)
		dat += "<BR>\[ <A HREF='?src=\ref[src];logout=1'>LOG OUT</A> \]"
		dat += "<center><h4>[SSmapping.configs[SHIP_MAP].map_name]</h4></center>"//get the current ship map name

		dat += "<br><center><h3>[GLOB.current_orbit]</h3></center>" //display the current orbit level
		dat += "<br><center>Power Level: [get_power_amount()]|Engines prepared: [can_change_orbit(silent = TRUE) ? "Ready" : "Recalculating"]</center>" //display ship nav stats, power level, cooldown.

		if(get_power_amount() >= REQUIRED_POWER_AMOUNT)
			dat += "<center><b><a href='byond://?src=\ref[src];UP=1'>Increase orbital level</a>|" //move farther away, current_orbit++
			dat += "<a href='byond://?src=[REF(src)];DOWN=1'>Decrease orbital level</a>|" //move closer in, current_orbit--
		else
			dat += "<center><h4>Insufficient Power Reserves to change orbit"
			dat += "<br>"

		dat += "</b></center>"

	else
		dat += "<BR>\[ <A HREF='?src=\ref[src];login=1'>LOG IN</A> \]"

	var/datum/browser/popup = new(user, "Navigation", "<div align='center'>Navigation</div>")
	popup.set_content(dat)
	popup.open()


/obj/machinery/computer/navigation/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(href_list["login"])
		if(isAI(usr))
			authenticated = AUTHORIZED_PLUS
			updateUsrDialog()
			addtimer(VARSET_CALLBACK(src, authenticated, FALSE), AUTO_LOGOUT_TIME) //autologout
			return
		var/mob/living/carbon/human/C = usr
		var/obj/item/card/id/I = C.get_active_held_item()
		if(istype(I))
			if(check_access(I))
				authenticated = AUTHORIZED
			if(ACCESS_MARINE_BRIDGE in I.access)
				authenticated = AUTHORIZED_PLUS
			addtimer(VARSET_CALLBACK(src, authenticated, FALSE), AUTO_LOGOUT_TIME) //autologout
		else
			I = C.wear_id
			if(istype(I))
				if(check_access(I))
					authenticated = AUTHORIZED
				if(ACCESS_MARINE_BRIDGE in I.access)
					authenticated = AUTHORIZED_PLUS
				addtimer(VARSET_CALLBACK(src, authenticated, FALSE), AUTO_LOGOUT_TIME) //autologout
	if(href_list["logout"])
		authenticated = FALSE

	if (href_list["UP"])
		message_admins("[ADMIN_TPMONTY(usr)] Has sent the ship Upward in orbit")
		do_orbit_checks("UP")
		TIMER_COOLDOWN_START(src, COOLDOWN_ORBIT_CHANGE, 1 MINUTES)

	else if (href_list["DOWN"])
		message_admins("[ADMIN_TPMONTY(usr)] Has sent the ship Downward in orbit")
		do_orbit_checks("DOWN")
		TIMER_COOLDOWN_START(src, COOLDOWN_ORBIT_CHANGE, 1 MINUTES)

	updateUsrDialog()


/obj/machinery/computer/navigation/proc/do_orbit_checks(direction)
	var/current_orbit = GLOB.current_orbit

	if(!can_change_orbit(current_orbit, direction))
		return

	var/message = "Prepare for orbital change in 10 seconds.\nMoving [direction] the gravity well.\nSecure all belongings and prepare for engine ignition."
	priority_announce(message, title = "Orbit Change")
	addtimer(CALLBACK(src, .proc/do_change_orbit, current_orbit, direction), 10 SECONDS)

/obj/machinery/computer/navigation/proc/can_change_orbit(current_orbit, direction, silent = FALSE)
	if(changing_orbit)
		if(!silent)
			to_chat(usr, "<span class='warning'>The ship is currently changing orbit.</span>")
		return FALSE
	if(direction == "UP" && current_orbit == ESCAPE_VELOCITY)
		if(!silent)
			to_chat(usr, "<span class='warning'>The ship is already at escape velocity!</span>")
		return FALSE
	if(direction == "DOWN" && current_orbit == SKIM_ATMOSPHERE)
		if(!silent)
			to_chat(usr, "<span class='warning'>WARNING, AUTOMATIC SAFETY ENGAGED. OVERRIDING USER INPUT.</span>")
		return FALSE
	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_ORBIT_CHANGE))
		if(!silent)
			to_chat(usr, "<span class='warning'>The ship is currently recalculating based on previous selection.</span>")
		return FALSE
	return TRUE

/obj/machinery/computer/navigation/proc/do_change_orbit(current_orbit, direction)

	//chug that sweet sweet powernet juice, like 80% of total
	if(powered()) //do we still have power?
		idle_power_usage = 5000
		addtimer(VARSET_CALLBACK(src, idle_power_usage, 10), 5 MINUTES)
	else
		return
	changing_orbit = TRUE
	engine_shudder()

	var/message = "Arriving at new orbital level. Prepare for engine ignition and stabilization."
	addtimer(CALLBACK(GLOBAL_PROC, .proc/priority_announce, message, "Orbit Change"), 290 SECONDS)
	addtimer(CALLBACK(src, .proc/orbit_gets_changed, current_orbit, direction), 5 MINUTES)

/obj/machinery/computer/navigation/proc/orbit_gets_changed(current_orbit, direction)
	if(direction == "UP")
		current_orbit++

	if(direction == "DOWN")
		current_orbit--

	GLOB.current_orbit = current_orbit
	changing_orbit = FALSE
	engine_shudder()

//whole lotta shaking going on
/obj/machinery/computer/navigation/proc/engine_shudder()
	for(var/i in GLOB.alive_living_list) //knock down mobs
		var/mob/living/M = i
		if(!is_mainship_level(M.z))
			continue
		if(M.buckled)
			to_chat(M, "<span class='warning'>You are jolted against [M.buckled]!</span>")
			shake_camera(M, 3, 1)
		else
			to_chat(M, "<span class='warning'>The floor jolts under your feet!</span>")
			shake_camera(M, 10, 1)
			M.Knockdown(3)
		CHECK_TICK
