//A thing for 'navigating' the current ship map up or down the gravity well.

#define CURRENT_ORBIT 3

#define ESCAPE_VELOCITY 5
#define SAFE_DISTANCE 4
#define STANDARD_ORBIT 3
#define CLOSE_ORBIT 2
#define SKIM_ATMOSPHERE 1


/obj/machinery/computer/navigation
	name = "\improper Helms computer"
	density = TRUE
	anchored = TRUE
	var/open = FALSE
	var/cooldown = FALSE

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
	return power_amount

/obj/machinery/computer/navigation/Initialize() //need anything special?
	. = ..()


/obj/machinery/computer/navigation/interact(mob/user)
	. = ..()
	if(.)
		return
	var/dat
	dat += "<center><h4>[SHIP_NAME]</h4></center>"//get the current ship map name

	dat += "<br><center><h3>[src.temp]</h3></center>" //display the current orbit level
	dat += "<br><center>Health: [src.player_hp]|Magic: [src.player_mp]|Enemy Health: [src.enemy_hp]</center>" //display ship nav stats, power level, cooldown.

	if(get_power_amount() >= 5000000) //some arbitrary number
		dat += "<center><b><a href='byond://?src=\ref[src];UP=1'>Increase orbital level</a>|" //move farther away, current_orbit++
		dat += "<a href='byond://?src=[REF(src)];DOWN=1'>Decrease orbital level</a>|" //move closer in, current_orbit--
	else
		dat += "<center><h4>Insufficient Power Reserves"
		dat += "<br>"

	if(CURRENT_ORBIT == ESCAPE_VELOCITY)
		dat += "<center><h4><a href='byond://?src=[REF(src)];escape=1'>RETREAT</a>" //big ol red escape button. ends round after X minutes

	dat += "</b></center>"

	var/datum/browser/popup = new(user, "arcade", "<div align='center'>Arcade</div>")
	popup.set_content(dat)
	popup.open()


/obj/machinery/computer/navigation/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if (href_list["UP"])
		CURRENT_ORBIT++
		cooldown = TRUE
		sleep(600 SECONDS) //five minutes or whatever is the better cooldown timer
		cooldown = FALSE
		do_orbit_checks('UP')


	else if (href_list["DOWN"])
		CURRENT_ORBIT--
		cooldown = TRUE
		sleep(600 SECONDS) //five minutes or whatever is the better cooldown timer
		cooldown = FALSE
		do_orbit_checks('DOWN')

	else if (href_list["escape"])

		sleep(1200 SECONDS) //ten minutes
		//end the round, xeno minor.

	updateUsrDialog()


/obj/machinery/computer/navigation/proc/do_orbit_checks(var/direction)
	var/current_orbit = CURRENT_ORBIT

	if(can_change_orbit(current_orbit, direction))

	if(direction == 'UP')
		current_orbit++
		set_cooldown_timer()
	
	if(direction == 'DOWN')
		current_orbit--
		set_cooldown_timer()

/obj/machinery/computer/navigation/proc/can_change_orbit(var/current_orbit, var/direction)
	if(cooldown)
		return FALSE
	if(direction == 'UP' && current_orbit == ESCAPE_VELOCITY)
		return FALSE
	if(direction == 'DOWN' && current_orbit == SKIM_ATMOSPHERE)
		return FALSE
	if(get_power_amount() <= 500000)
		return FALSE

//emp_act() not needed to be special
