//A thing for 'navigating' the current ship map up or down the gravity well.

#define HIGH_ORBIT 5
#define STANDARD_ORBIT 3
#define LOW_ORBIT 1

#define REQUIRED_POWER_AMOUNT 250000
#define AUTO_LOGOUT_TIME 1 MINUTES

#define AUTHORIZED 1
#define AUTHORIZED_PLUS 2

//so we can use the current orbit in other files
GLOBAL_VAR_INIT(current_orbit,STANDARD_ORBIT)

/obj/machinery/computer/navigation
	name = "\improper Helms computer"
	icon_state = "shuttlecomputer"
	screen_overlay = "shuttlecomputer_screen"
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
	///boolean this machine can be interacted with by the AI player. FALSE = can interact
	var/aidisabled = FALSE
	///timer id to prevent hardel from the varset call back
	var/timer_id

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


/obj/machinery/computer/navigation/Initialize(mapload) //need anything special?
	. = ..()
	desc = "The navigation console for the [SSmapping.configs[SHIP_MAP].map_name]."
	timer_id = addtimer(VARSET_CALLBACK(src, changing_orbit, FALSE), 10 MINUTES, TIMER_STOPPABLE) //ship is still heading to area cant change orbit yet if your not at the planet

/obj/machinery/computer/navigation/Destroy()
	deltimer(timer_id)
	return ..()

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
		dat += "<BR>\[ <A HREF='?src=[text_ref(src)];logout=1'>LOG OUT</A>]"
		dat += "<center><h4>[SSmapping.configs[SHIP_MAP].map_name]</h4></center>"//get the current ship map name

		dat += "<br><center><h3>[GLOB.current_orbit]</h3></center>" //display the current orbit level
		dat += "<br><center>Power Level: [get_power_amount()]|Engines prepared: [can_change_orbit(silent = TRUE) ? "Ready" : "Recalculating"]</center>" //display ship nav stats, power level, cooldown.

		if(get_power_amount() >= REQUIRED_POWER_AMOUNT)
			dat += "<center><b><a href='byond://?src=[text_ref(src)];UP=1'>Increase orbital level</a>|" //move farther away, current_orbit++
			dat += "<a href='byond://?src=[REF(src)];DOWN=1'>Decrease orbital level</a>|" //move closer in, current_orbit--
		else
			dat += "<center><h4>Insufficient Power Reserves to change orbit"
			dat += "<br>"

		dat += "</b></center>"

	else
		dat += "<BR>\[ <A HREF='?src=[text_ref(src)];login=1'>LOG IN</A> \]"

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
		do_orbit_checks("UP")
		TIMER_COOLDOWN_START(src, COOLDOWN_ORBIT_CHANGE, 1 MINUTES)

	else if (href_list["DOWN"])
		do_orbit_checks("DOWN")
		TIMER_COOLDOWN_START(src, COOLDOWN_ORBIT_CHANGE, 1 MINUTES)

	updateUsrDialog()


/obj/machinery/computer/navigation/proc/do_orbit_checks(direction)
	var/current_orbit = GLOB.current_orbit

	if(!can_change_orbit(current_orbit, direction))
		return

	message_admins("[ADMIN_TPMONTY(usr)] Has sent the ship [direction == "UP" ? "UPWARD" : "DOWNWARD"] in orbit")
	var/message = "Prepare for orbital change in 10 seconds.\nMoving [direction] the gravity well.\nSecure all belongings and prepare for engine ignition."
	priority_announce(message, title = "Orbit Change")
	addtimer(CALLBACK(src, PROC_REF(do_change_orbit), current_orbit, direction), 10 SECONDS)

/obj/machinery/computer/navigation/proc/can_change_orbit(current_orbit, direction, silent = FALSE)
	if(changing_orbit)
		if(!silent)
			to_chat(usr, span_warning("The ship is currently changing orbit."))
		return FALSE
	if(direction == "UP" && current_orbit == HIGH_ORBIT)
		if(!silent)
			to_chat(usr, span_warning("The ship is already at the highest orbit!"))
		return FALSE
	if(direction == "DOWN" && current_orbit == LOW_ORBIT)
		if(!silent)
			to_chat(usr, span_warning("The ship is already at the lowest orbit!"))
		return FALSE
	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_ORBIT_CHANGE))
		if(!silent)
			to_chat(usr, span_warning("The ship is currently recalculating based on previous selection."))
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
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(priority_announce), message, "Orbit Change"), 290 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(orbit_gets_changed), current_orbit, direction), 3 MINUTES)

/obj/machinery/computer/navigation/proc/orbit_gets_changed(current_orbit, direction)
	if(direction == "UP")
		if(current_orbit == LOW_ORBIT)
			current_orbit = STANDARD_ORBIT
		else
			current_orbit = HIGH_ORBIT

	if(direction == "DOWN")
		if(current_orbit == HIGH_ORBIT)
			current_orbit = STANDARD_ORBIT
		else
			current_orbit = LOW_ORBIT

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
			to_chat(M, span_warning("You are jolted against [M.buckled]!"))
			shake_camera(M, 3, 1)
		else
			to_chat(M, span_warning("The floor jolts under your feet!"))
			shake_camera(M, 10, 1)
			M.Knockdown(0.3 SECONDS)
		CHECK_TICK
