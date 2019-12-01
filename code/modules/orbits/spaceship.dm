//A thing for 'navigating' the current ship map up or down the gravity well.

#define ESCAPE_VELOCITY 	5
#define SAFE_DISTANCE 		4
#define STANDARD_ORBIT 		3
#define CLOSE_ORBIT 		2
#define SKIM_ATMOSPHERE 	1

//so we can use the current orbit in other files
GLOBAL_DATUM_INIT(orbital_mechanics, /datum/orbital_mechanics, new)

//just in case people want to add other ways of changing how the round feels
/datum/orbital_mechanics
	var/current_orbit = 3

/obj/machinery/computer/navigation
	name = "\improper Helms computer"
	density = TRUE
	anchored = TRUE
	idle_power_usage = 10
	var/cooldown = FALSE
	var/changing_orbit = FALSE
	var/authenticated = 0
	var/shorted = FALSE
	var/aidisabled = FALSE

//-------------------------------------------
// Standard procs
//-------------------------------------------

/obj/machinery/computer/navigation/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(isscrewdriver(I)) //keep this? make it hackable so regular marines can run?
		TOGGLE_BITFIELD(machine_stat, PANEL_OPEN)
		update_icon()
		to_chat(user, "The wires have been [CHECK_BITFIELD(machine_stat, PANEL_OPEN) ? "exposed" : "unexposed"]")
		return

/obj/machinery/computer/navigation/Initialize() //need anything special?
	desc = "The navigation console for the [SSmapping.configs[SHIP_MAP].map_name]."
	. = ..()

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
	var/power_amount = 0
	if(!powered())
		return power_amount
	
	return power_amount

/obj/machinery/computer/navigation/interact(mob/user)
	. = ..()
	if(.)
		return

	var/dat

	if(authenticated)
		dat += "<BR>\[ <A HREF='?src=\ref[src];logout=1'>LOG OUT</A> \]"
		dat += "<center><h4>[SSmapping.configs[SHIP_MAP].map_name]</h4></center>"//get the current ship map name

		dat += "<br><center><h3>[GLOB.orbital_mechanics.current_orbit]</h3></center>" //display the current orbit level
		dat += "<br><center>Power Level: [get_power_amount()]|Engines prepared: [!cooldown]</center>" //display ship nav stats, power level, cooldown.

		if(get_power_amount() >= 5000000) //some arbitrary number
			dat += "<center><b><a href='byond://?src=\ref[src];UP=1'>Increase orbital level</a>|" //move farther away, current_orbit++
			dat += "<a href='byond://?src=[REF(src)];DOWN=1'>Decrease orbital level</a>|" //move closer in, current_orbit--
		else
			dat += "<center><h4>Insufficient Power Reserves to change orbit"
			dat += "<br>"

		if(GLOB.orbital_mechanics.current_orbit == ESCAPE_VELOCITY)
			dat += "<center><h4><a href='byond://?src=[REF(src)];escape=1'>RETREAT</a>" //big ol red escape button. ends round after X minutes

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

	if("login")
		if(isAI(usr))
			authenticated = 2
			updateUsrDialog()
			return
		var/mob/living/carbon/human/C = usr
		var/obj/item/card/id/I = C.get_active_held_item()
		if(istype(I))
			if(check_access(I))
				authenticated = 1
			if(ACCESS_MARINE_BRIDGE in I.access)
				authenticated = 2
		else
			I = C.wear_id
			if(istype(I))
				if(check_access(I))
					authenticated = 1
				if(ACCESS_MARINE_BRIDGE in I.access)
					authenticated = 2
	if("logout")
		authenticated = 0

	if (href_list["UP"])
		do_orbit_checks("UP")
		cooldown = TRUE
		addtimer(VARSET_CALLBACK(src, cooldown, FALSE), 1 MINUTES)

	else if (href_list["DOWN"])
		do_orbit_checks("DOWN")
		cooldown = TRUE
		addtimer(VARSET_CALLBACK(src, cooldown, FALSE), 1 MINUTES)

	else if (href_list["escape"])
		do_orbit_checks("escape")
		cooldown = TRUE
		addtimer(VARSET_CALLBACK(src, cooldown, FALSE), 1 MINUTES)
		//end the round, xeno minor.

	updateUsrDialog()


/obj/machinery/computer/navigation/proc/do_orbit_checks(direction)
	var/current_orbit = GLOB.orbital_mechanics.current_orbit
	if(cooldown)
		return

	if(can_change_orbit(current_orbit, direction))
		if(direction == "escape")
			var/message = "The [SSmapping.configs[SHIP_MAP].map_name] is preparing to leave orbit.<br><br>Secure all belongings and prepare for engine ignition."
			priority_announce(message, title = "Retreat")
			addtimer(CALLBACK(src, .proc/do_change_orbit, current_orbit, direction), 10 SECONDS)

		var/message = "Prepare for orbital change in 10 seconds.<br><br>Moving [direction] the gravity well.<br><br>Secure all belongings and prepare for engine ignition."
		priority_announce(message, title = "Orbit Change")
		addtimer(CALLBACK(src, .proc/do_change_orbit, current_orbit, direction), 10 SECONDS)

/obj/machinery/computer/navigation/proc/can_change_orbit(current_orbit, direction)
	if(cooldown)
		to_chat(usr, "The ship is currently recalculating based on previous selection.")
		return FALSE
	if(changing_orbit)
		to_chat(usr, "The ship is currently changing orbit.")
		return FALSE
	if(direction == "UP" && current_orbit == ESCAPE_VELOCITY)
		to_chat(usr, "The ship is already at escape velocity! It is already prepped for the escape jump!")
		return FALSE
	if(direction == "DOWN" && current_orbit == SKIM_ATMOSPHERE)
		to_chat(usr, "WARNING, AUTOMATIC SAFETY ENGAGED. OVERRIDING USER INPUT.")
		return FALSE
	if(get_power_amount() <= 500000)
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

	if(direction == "escape")
		addtimer(CALLBACK(src, .proc/retreat), 10 MINUTES)
		return

	var/message = "Arriving at new orbital level.<br><br>Prepare for engine ignition and stabilization."
	addtimer(CALLBACK(src, .proc/priority_announce, message, "Orbit Change"), 290 SECONDS)
	addtimer(CALLBACK(src, .proc/orbit_gets_changed, current_orbit, direction), 5 MINUTES)
	
/obj/machinery/computer/navigation/proc/orbit_gets_changed(current_orbit, direction)
	if(direction == "UP")
		current_orbit++
	
	if(direction == "DOWN")
		current_orbit--

	GLOB.orbital_mechanics.current_orbit = current_orbit
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
			M.knock_down(3)
		CHECK_TICK

/obj/machinery/computer/navigation/proc/retreat()

	if(isdistress(SSticker.mode))
		var/datum/game_mode/distress/distress_mode = SSticker.mode
		if(distress_mode.round_stage == DISTRESS_DROPSHIP_CRASHED)
			//Xenos got onto the ship before it fully got away.
			return

		var/message = "The [SSmapping.configs[SHIP_MAP].map_name] has left the AO."
		priority_announce(message, title = "Retreat")

		distress_mode.round_stage = DISTRESS_MARINE_RETREAT
	//This is the place where you can add checks for if the ship contains a thing.
	//a macguffin if you will, that changes the victory condition
