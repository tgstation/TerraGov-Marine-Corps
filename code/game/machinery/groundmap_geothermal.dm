/obj/machinery/power/geothermal
	name = "\improper G-11 geothermal generator"
	icon = 'icons/turf/geothermal.dmi'
	icon_state = "weld"
	desc = "A thermoelectric generator sitting atop a plasma-filled borehole. This one is heavily damaged. Use a blowtorch, wrench, then wirecutters to repair it."
	anchored = 1
	density = 1
	directwired = 0     //Requires a cable directly underneath
	unacidable = 1      //NOPE.jpg
	var/power_gen_percent = 0 //100,000W at full capacity
	var/power_generation_max = 100000 //Full capacity
	var/powernet_connection_failed = 0 //Logic checking for powernets
	var/buildstate = 1 //What state of building it are we on, 0-3, 1 is "broken", the default
	var/is_on = 0  //Is this damn thing on or what?
	var/fail_rate = 10 //% chance of failure each fail_tick check
	var/fail_check_ticks = 100 //Check for failure every this many ticks
	var/cur_tick = 0 //Tick updater

//We don't want to cut/update the power overlays every single proc. Just when it actually changes. This should save on CPU cycles. Efficiency!
/obj/machinery/power/geothermal/update_icon()
	..()
	if(!buildstate && is_on)
		desc = "A thermoelectric generator sitting atop a borehole dug deep in the planet's surface. It generates energy by boiling the plasma steam that rises from the well.\nIt is old technology and has a large failure rate, and must be repaired frequently.\nIt is currently on, and beeping randomly amid faint hisses of steam."
		switch(power_gen_percent)
			if(25) icon_state = "on[power_gen_percent]"
			if(50) icon_state = "on[power_gen_percent]"
			if(75) icon_state = "on[power_gen_percent]"
			if(100) icon_state = "on[power_gen_percent]"


	else if (!buildstate && !is_on)
		icon_state = "off"
		desc = "A thermoelectric generator sitting atop a borehole dug deep in the planet's surface. It generates energy by boiling the plasma steam that rises from the well.\nIt is old technology and has a large failure rate, and must be repaired frequently.\nIt is currently turned off and silent."
	else
		if(buildstate == 1)
			icon_state = "weld"
			desc = "A thermoelectric generator sitting atop a plasma-filled borehole. This one is heavily damaged. Use a blowtorch, wirecutters, then wrench to repair it."
		else if(buildstate == 2)
			icon_state = "wire"
			desc = "A thermoelectric generator sitting atop a plasma-filled borehole. This one is damaged. Use a wirecutters, then wrench to repair it."
		else
			icon_state = "wrench"
			desc = "A thermoelectric generator sitting atop a plasma-filled borehole. This one is lightly damaged. Use a wrench to repair it."

/obj/machinery/power/geothermal/New()
	..()
	if(!connect_to_network()) //Should start with a cable piece underneath, if it doesn't, something's messed up in mapping
		powernet_connection_failed = 1

/obj/machinery/power/geothermal/power_change()
	return

/obj/machinery/power/geothermal/process()
	if(!is_on || buildstate || !anchored) //Default logic checking
		return 0

	if(!powernet && !powernet_connection_failed) //Powernet checking, make sure there's valid cables & powernets
		if(!connect_to_network())
			powernet_connection_failed = 1 //God damn it, where'd our network go
			is_on = 0
			stop_processing()
			spawn(150) // Error! Check again in 15 seconds. Someone could have blown/acided or snipped a cable
				powernet_connection_failed = 0
	else if(powernet) //All good! Let's fire it up!
		if(!check_failure()) //Wait! Check to see if it breaks during processing
			update_icon()
			if(power_gen_percent < 100) power_gen_percent++
			switch(power_gen_percent)
				if(10) visible_message("\icon[src] <span class='notice'><b>[src]</b> begins to whirr as it powers up.</span>")
				if(50) visible_message("\icon[src] <span class='notice'><b>[src]</b> begins to hum loudly as it reaches half capacity.</span>")
				if(99) visible_message("\icon[src] <span class='notice'><b>[src]</b> rumbles loudly as the combustion and thermal chambers reach full strength.</span>")
			add_avail(power_generation_max * (power_gen_percent / 100) ) //Nope, all good, just add the power

/obj/machinery/power/geothermal/proc/check_failure()
	cur_tick++
	if(cur_tick < fail_check_ticks) //Nope, not time for it yet
		return 0
	else if(cur_tick > fail_check_ticks) //Went past with no fail, reset the timer
		cur_tick = 0
		return 0
	if(rand(1,100) < fail_rate) //Oh snap, we failed! Shut it down!
		if(rand(0,3) == 0)
			visible_message("\icon[src] <span class='notice'><b>[src]</b> beeps wildly and a fuse blows! Use wirecutters, then a wrench to repair it.")
			buildstate = 2
			icon_state = "wire"
		else
			visible_message("\icon[src] <span class='notice'><b>[src]</b> beeps wildly and sprays random pieces everywhere! Use a wrench to repair it.")
			buildstate = 3
			icon_state = "wrench"
		is_on = 0
		power_gen_percent = 0
		update_icon()
		cur_tick = 0
		stop_processing()
		return 1
	return 0 //Nope, all fine

/obj/machinery/power/geothermal/attack_hand(mob/user as mob)
	if(!anchored) return 0 //Shouldn't actually be possible
	if(user.is_mob_incapacitated()) return 0
	if(!ishuman(user))
		user << "\red You have no idea how to use that." //No xenos or mankeys
		return 0

	add_fingerprint(user)

	if(user.mind && user.mind.cm_skills && user.mind.cm_skills.engineer < SKILL_ENGINEER_ENGI)
		user << "<span class='warning'>You have no clue how this thing works...</span>"
		return 0

	if(buildstate == 1)
		usr << "<span class='info'>Use a blowtorch, then wirecutters, then wrench to repair it."
		return 0
	else if (buildstate == 2)
		usr << "<span class='info'>Use a wirecutters, then wrench to repair it."
		return 0
	else if (buildstate == 3)
		usr << "<span class='info'>Use a wrench to repair it."
		return 0
	if(is_on)
		visible_message("\icon[src] <span class='warning'><b>[src]</b> beeps softly and the humming stops as [usr] shuts off the turbines.")
		is_on = 0
		power_gen_percent = 0
		cur_tick = 0
		icon_state = "off"
		stop_processing()
		return 1
	visible_message("\icon[src] <span class='warning'><b>[src]</b> beeps loudly as [usr] turns on the turbines and the generator begins spinning up.")
	icon_state = "on10"
	is_on = 1
	cur_tick = 0
	start_processing()
	return 1

/obj/machinery/power/geothermal/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(iswelder(O))
		if(buildstate == 1 && !is_on)
			if(user.mind && user.mind.cm_skills && user.mind.cm_skills.engineer < SKILL_ENGINEER_ENGI)
				user << "<span class='warning'>You have no clue how to repair this thing.</span>"
				return 0
			var/obj/item/tool/weldingtool/WT = O
			if(WT.remove_fuel(1, user))

				playsound(loc, 'sound/items/weldingtool_weld.ogg', 25)
				user.visible_message("<span class='notice'>[user] starts welding [src]'s internal damage.</span>",
				"<span class='notice'>You start welding [src]'s internal damage.</span>")
				if(do_after(user, 200, TRUE, 5, BUSY_ICON_BUILD))
					if(buildstate != 1 || is_on || !WT.isOn()) r_FAL
					playsound(loc, 'sound/items/Welder2.ogg', 25, 1)
					buildstate = 2
					user.visible_message("<span class='notice'>[user] welds [src]'s internal damage.</span>",
					"<span class='notice'>You weld [src]'s internal damage.</span>")
					update_icon()
					r_TRU
			else
				user << "<span class='warning'>You need more welding fuel to complete this task.</span>"
				return
	else if(iswirecutter(O))
		if(buildstate == 2 && !is_on)
			if(user.mind && user.mind.cm_skills && user.mind.cm_skills.engineer < SKILL_ENGINEER_ENGI)
				user << "<span class='warning'>You have no clue how to repair this thing.</span>"
				return 0
			playsound(loc, 'sound/items/Wirecutter.ogg', 25, 1)
			user.visible_message("<span class='notice'>[user] starts securing [src]'s wiring.</span>",
			"<span class='notice'>You start securing [src]'s wiring.</span>")
			if(do_after(user, 120, TRUE, 12, BUSY_ICON_BUILD))
				if(buildstate != 2 || is_on) r_FAL
				playsound(loc, 'sound/items/Wirecutter.ogg', 25, 1)
				buildstate = 3
				user.visible_message("<span class='notice'>[user] secures [src]'s wiring.</span>",
				"<span class='notice'>You secure [src]'s wiring.</span>")
				update_icon()
				r_TRU
	else if(iswrench(O))
		if(buildstate == 3 && !is_on)
			if(user.mind && user.mind.cm_skills && user.mind.cm_skills.engineer < SKILL_ENGINEER_ENGI)
				user << "<span class='warning'>You have no clue how to repair this thing.</span>"
				return 0
			playsound(loc, 'sound/items/Ratchet.ogg', 25, 1)
			user.visible_message("<span class='notice'>[user] starts repairing [src]'s tubing and plating.</span>",
			"<span class='notice'>You start repairing [src]'s tubing and plating.</span>")
			if(do_after(user, 150, TRUE, 15, BUSY_ICON_BUILD))
				if(buildstate != 3 || is_on) r_FAL
				playsound(loc, 'sound/items/Ratchet.ogg', 25, 1)
				buildstate = 0
				user.visible_message("<span class='notice'>[user] repairs [src]'s tubing and plating.</span>",
				"<span class='notice'>You repair [src]'s tubing and plating.</span>")
				update_icon()
				r_TRU
	else
		return ..() //Deal with everything else, like hitting with stuff

//Putting these here since it's power-related
/obj/machinery/colony_floodlight_switch
	name = "Colony Floodlight Switch"
	icon = 'icons/turf/ground_map.dmi'
	icon_state = "panelnopower"
	desc = "This switch controls the floodlights surrounding the archaeology complex. It only functions when there is power."
	density = 0
	anchored = 1
	var/ispowered = 0
	var/turned_on = 0 //has to be toggled in engineering
	use_power = 1
	unacidable = 1
	var/list/floodlist = list() // This will save our list of floodlights on the map

/obj/machinery/colony_floodlight_switch/New() //Populate our list of floodlights so we don't need to scan for them ever again
	sleep(5) //let's make sure it exists first..
	for(var/obj/machinery/colony_floodlight/F in machines)
		floodlist += F
		F.fswitch = src
	..()
	start_processing()

/obj/machinery/colony_floodlight_switch/update_icon()
	if(!ispowered)
		icon_state = "panelnopower"
	else if(turned_on)
		icon_state = "panelon"
	else
		icon_state = "paneloff"

/obj/machinery/colony_floodlight_switch/process()
	var/lightpower = 0
	for(var/obj/machinery/colony_floodlight/C in floodlist)
		if(!C.is_lit)
			continue
		lightpower += C.power_tick
	use_power(lightpower)

/obj/machinery/colony_floodlight_switch/power_change()
	..()
	if((stat & NOPOWER))
		if(ispowered && turned_on)
			toggle_lights()
		ispowered = 0
		turned_on = 0
		update_icon()
	else
		ispowered = 1
		update_icon()

/obj/machinery/colony_floodlight_switch/proc/toggle_lights()
	for(var/obj/machinery/colony_floodlight/F in floodlist)
		spawn(rand(0,50))
			F.is_lit = !F.is_lit
			if(!F.damaged)
				if(F.is_lit) //Shut it down
					F.SetLuminosity(F.lum_value)
				else
					F.SetLuminosity(0)
			F.update_icon()
	return 0

/obj/machinery/colony_floodlight_switch/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/colony_floodlight_switch/attack_hand(mob/user as mob)
	if(!ishuman(user))
		user << "Nice try."
		return 0
	if(!ispowered)
		user << "Nothing happens."
		return 0
	playsound(src,'sound/machines/click.ogg', 15, 1)
	use_power(5)
	toggle_lights()
	turned_on = !(src.turned_on)
	update_icon()
	return 1


#define FLOODLIGHT_REPAIR_UNSCREW 	0
#define FLOODLIGHT_REPAIR_CROWBAR 	1
#define FLOODLIGHT_REPAIR_WELD 		2
#define FLOODLIGHT_REPAIR_CABLE 	3
#define FLOODLIGHT_REPAIR_SCREW 	4

/obj/machinery/colony_floodlight
	name = "Colony Floodlight"
	icon = 'icons/turf/ground_map.dmi'
	icon_state = "floodoff"
	density = 1
	anchored = 1
	var/damaged = 0 //Can be smashed by xenos
	var/is_lit = 0 //whether the floodlight is switched to on or off. Does not necessarily mean it emits light.
	unacidable = 1
	var/power_tick = 800 // power each floodlight takes up per process
	use_power = 0 //It's the switch that uses the actual power, not the lights
	var/obj/machinery/colony_floodlight_switch/fswitch = null //Reverse lookup for power grabbing in area
	var/lum_value = 7
	var/repair_state = 0
	var/health = 120

/obj/machinery/colony_floodlight/Dispose()
	SetLuminosity(0)
	if(fswitch)
		fswitch.floodlist -= src
		fswitch = null
	. = ..()

/obj/machinery/colony_floodlight/update_icon()
	if(damaged)
		icon_state = "flooddmg"
	else if(is_lit)
		icon_state = "floodon"
	else
		icon_state = "floodoff"

/obj/machinery/colony_floodlight/attackby(obj/item/I, mob/user)
	if(damaged)
		if(isscrewdriver(I))
			if(user.mind && user.mind.cm_skills && user.mind.cm_skills.engineer < SKILL_ENGINEER_ENGI)
				user << "<span class='warning'>You have no clue how to repair [src].</span>"
				return 0

			if(repair_state == FLOODLIGHT_REPAIR_UNSCREW)
				playsound(loc, 'sound/items/Screwdriver.ogg', 25, 1)
				user.visible_message("<span class='notice'>[user] starts unscrewing [src]'s maintenance hatch.</span>", \
				"<span class='notice'>You start unscrewing [src]'s maintenance hatch.</span>")
				if(do_after(user, 20, TRUE, 5, BUSY_ICON_BUILD))
					if(disposed || repair_state != FLOODLIGHT_REPAIR_UNSCREW)
						return
					playsound(loc, 'sound/items/Screwdriver.ogg', 25, 1)
					repair_state = FLOODLIGHT_REPAIR_CROWBAR
					user.visible_message("<span class='notice'>[user] unscrews [src]'s maintenance hatch.</span>", \
					"<span class='notice'>You unscrew [src]'s maintenance hatch.</span>")

			else if(repair_state == FLOODLIGHT_REPAIR_SCREW)
				playsound(loc, 'sound/items/Screwdriver.ogg', 25, 1)
				user.visible_message("<span class='notice'>[user] starts screwing [src]'s maintenance hatch closed.</span>", \
				"<span class='notice'>You start screwing [src]'s maintenance hatch closed.</span>")
				if(do_after(user, 20, TRUE, 5, BUSY_ICON_BUILD))
					if(disposed || repair_state != FLOODLIGHT_REPAIR_SCREW)
						return
					playsound(loc, 'sound/items/Screwdriver.ogg', 25, 1)
					damaged = 0
					repair_state = FLOODLIGHT_REPAIR_UNSCREW
					health = initial(health)
					user.visible_message("<span class='notice'>[user] screws [src]'s maintenance hatch closed.</span>", \
					"<span class='notice'>You screw [src]'s maintenance hatch closed.</span>")
					if(is_lit)
						SetLuminosity(lum_value)
					update_icon()
			return TRUE

		else if(iscrowbar(I))
			if(user.mind && user.mind.cm_skills && user.mind.cm_skills.engineer < SKILL_ENGINEER_ENGI)
				user << "<span class='warning'>You have no clue how to repair [src].</span>"
				return 0

			if(repair_state == FLOODLIGHT_REPAIR_CROWBAR)
				playsound(src.loc, 'sound/items/Crowbar.ogg', 25, 1)
				user.visible_message("<span class='notice'>[user] starts prying [src]'s maintenance hatch open.</span>",\
				"<span class='notice'>You start prying [src]'s maintenance hatch open.</span>")
				if(do_after(user, 20, TRUE, 5, BUSY_ICON_BUILD))
					if(disposed || repair_state != FLOODLIGHT_REPAIR_CROWBAR)
						return
					playsound(src.loc, 'sound/items/Crowbar.ogg', 25, 1)
					repair_state = FLOODLIGHT_REPAIR_WELD
					user.visible_message("<span class='notice'>[user] pries [src]'s maintenance hatch open.</span>",\
					"<span class='notice'>You pry [src]'s maintenance hatch open.</span>")
			return TRUE

		else if(iswelder(I))
			var/obj/item/tool/weldingtool/WT = I

			if(user.mind && user.mind.cm_skills && user.mind.cm_skills.engineer < SKILL_ENGINEER_ENGI)
				user << "<span class='warning'>You have no clue how to repair [src].</span>"
				return 0

			if(repair_state == FLOODLIGHT_REPAIR_WELD)
				if(WT.remove_fuel(1, user))
					playsound(loc, 'sound/items/weldingtool_weld.ogg', 25)
					user.visible_message("<span class='notice'>[user] starts welding [src]'s damage.</span>",
					"<span class='notice'>You start welding [src]'s damage.</span>")
					if(do_after(user, 40, TRUE, 5, BUSY_ICON_BUILD))
						if(disposed || !WT.isOn() || repair_state != FLOODLIGHT_REPAIR_WELD)
							return
						playsound(loc, 'sound/items/Welder2.ogg', 25, 1)
						repair_state = FLOODLIGHT_REPAIR_CABLE
						user.visible_message("<span class='notice'>[user] welds [src]'s damage.</span>",
						"<span class='notice'>You weld [src]'s damage.</span>")
						return 1
				else
					user << "<span class='warning'>You need more welding fuel to complete this task.</span>"
			return TRUE

		else if(iscoil(I))
			var/obj/item/stack/cable_coil/C = I
			if(user.mind && user.mind.cm_skills && user.mind.cm_skills.engineer < SKILL_ENGINEER_ENGI)
				user << "<span class='warning'>You have no clue how to repair [src].</span>"
				return 0

			if(repair_state == FLOODLIGHT_REPAIR_CABLE)
				if(C.get_amount() < 2)
					user << "<span class='warning'>You need two coils of wire to replace the damaged cables.</span>"
					return
				playsound(loc, 'sound/items/Deconstruct.ogg', 25, 1)
				user.visible_message("<span class='notice'>[user] starts replacing [src]'s damaged cables.</span>",\
				"<span class='notice'>You start replacing [src]'s damaged cables.</span>")
				if(do_after(user, 20, TRUE, 5, BUSY_ICON_GENERIC))
					if(disposed || repair_state != FLOODLIGHT_REPAIR_CABLE)
						return
					if(C.use(2))
						playsound(loc, 'sound/items/Deconstruct.ogg', 25, 1)
						repair_state = FLOODLIGHT_REPAIR_SCREW
						user.visible_message("<span class='notice'>[user] starts replaces [src]'s damaged cables.</span>",\
						"<span class='notice'>You replace [src]'s damaged cables.</span>")
			return TRUE


	..()
	return 0

/obj/machinery/colony_floodlight/attack_hand(mob/user)
	if(ishuman(user))
		if(damaged)
			user << "<span class='warning'>[src] is damaged.</span>"
		else if(!is_lit)
			user << "<span class='warning'>Nothing happens. Looks like it's powered elsewhere.</span>"
		return 0
	..()

/obj/machinery/colony_floodlight/examine(mob/user)
	..()
	if(ishuman(user))
		if(damaged)
			user << "<span class='warning'>It is damaged.</span>"
			if(!user.mind || !user.mind.cm_skills || user.mind.cm_skills.engineer >= SKILL_ENGINEER_ENGI)
				switch(repair_state)
					if(FLOODLIGHT_REPAIR_UNSCREW) user << "<span class='info'>You must first unscrew its maintenance hatch.</span>"
					if(FLOODLIGHT_REPAIR_CROWBAR) user << "<span class='info'>You must crowbar its maintenance hatch open.</span>"
					if(FLOODLIGHT_REPAIR_WELD) user << "<span class='info'>You must weld the damage to it.</span>"
					if(FLOODLIGHT_REPAIR_CABLE) user << "<span class='info'>You must replace its damaged cables.</span>"
					if(FLOODLIGHT_REPAIR_SCREW) user << "<span class='info'>You must screw its maintenance hatch closed.</span>"
		else if(!is_lit)
			user << "<span class='info'>It doesn't seem powered.</span>"

#undef FLOODLIGHT_REPAIR_UNSCREW
#undef FLOODLIGHT_REPAIR_CROWBAR
#undef FLOODLIGHT_REPAIR_WELD
#undef FLOODLIGHT_REPAIR_CABLE
#undef FLOODLIGHT_REPAIR_SCREW
