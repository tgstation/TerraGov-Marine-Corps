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
	var/open = FALSE
	var/cooldown = FALSE
	var/changing_orbit = FALSE
	var/authenticated = 0

//-------------------------------------------
// Standard procs
//-------------------------------------------

/obj/machinery/computer/navigation/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(isscrewdriver(I)) //keep this? make it hackable so regular marines can run?
		open = !open
		update_icon()
		to_chat(user, "<span class='notice'>Maintenance panel is now [open ? "opened" : "closed"].</span>")

//figure out where the hacking wire stuff is.

//-------------------------------------------
// Special procs
//-------------------------------------------

/obj/machinery/computer/navigation/proc/get_power_amount()
	//check current powernet for total available power
	var/power_amount = 0
	if(!powered())
		return power_amount
	
	return power_amount

/obj/machinery/computer/navigation/Initialize() //need anything special?
	GLOB.orbital_mechanics.current_orbit = STANDARD_ORBIT
	desc = "The navigation console for the [SSmapping.configs[SHIP_MAP].map_name]."
	. = ..()


/obj/machinery/computer/navigation/interact(mob/user)
	. = ..()
	if(.)
		return

	//should add a check here for id card. Captain and SO's are the only people who can fly this boat.

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
		addtimer(VARSET_CALLBACK(src, cooldown, FALSE), 5 MINUTES)

	else if (href_list["DOWN"])
		do_orbit_checks("DOWN")
		cooldown = TRUE
		addtimer(VARSET_CALLBACK(src, cooldown, FALSE), 5 MINUTES)

	else if (href_list["escape"])

		sleep(1200 SECONDS) //ten minutes
		//end the round, xeno minor.

	updateUsrDialog()


/obj/machinery/computer/navigation/proc/do_orbit_checks(direction)
	var/current_orbit = GLOB.orbital_mechanics.current_orbit
	if(cooldown)
		return

	if(can_change_orbit(current_orbit, direction))
		do_change_orbit(current_orbit, direction)

/obj/machinery/computer/navigation/proc/can_change_orbit(current_orbit, direction)
	if(cooldown)
		return FALSE
	if(direction == "UP" && current_orbit == ESCAPE_VELOCITY)
		to_chat(usr, "The ship is already at escape velocity! It is already prepped for the escape jump!")
		return FALSE
	if(direction == "DOWN" && current_orbit == SKIM_ATMOSPHERE)
		to_chat(usr, "WARNING, AUTOMATIC SAFETY ENGAGED. ")
		return FALSE
	if(get_power_amount() <= 500000)
		return FALSE
	return TRUE

/obj/machinery/computer/navigation/proc/do_change_orbit(current_orbit, direction)

	//chug that sweet sweet powernet juice, like 80% of total
	if(powered()) //do we still have power?
		idle_power_usage = 5000
	else
		return
	changing_orbit = TRUE
	addtimer(VARSET_CALLBACK(src, changing_orbit, FALSE), 5 MINUTES)
	if(direction == "UP")
		current_orbit++
	
	if(direction == "DOWN")
		current_orbit--

	GLOB.orbital_mechanics.current_orbit = current_orbit

//emp_act() not needed to be special
