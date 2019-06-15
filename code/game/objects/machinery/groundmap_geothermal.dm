#define GEOTHERMAL_NO_DAMAGE     0
#define GEOTHERMAL_LIGHT_DAMAGE  1
#define GEOTHERMAL_MEDIUM_DAMAGE 2
#define GEOTHERMAL_HEAVY_DAMAGE  3

/obj/machinery/power/geothermal
	name = "\improper G-11 geothermal generator"
	icon = 'icons/turf/geothermal.dmi'
	icon_state = "weld"
	desc = "A thermoelectric generator sitting atop a plasma-filled borehole. This one is heavily damaged. Use a blowtorch, then wirecutters, and then a wrench to repair it."
	anchored = TRUE
	density = TRUE
	resistance_flags = UNACIDABLE
	var/power_gen_percent = 0 //100,000W at full capacity
	var/power_generation_max = 100000 //Full capacity
	var/buildstate = GEOTHERMAL_HEAVY_DAMAGE //What state of building it are we on, 0-3, 1 is "broken", the default
	var/is_on = FALSE  //Is this damn thing on or what?
	var/fail_rate = 10 //% chance of failure each fail_tick check
	var/fail_check_ticks = 100 //Check for failure every this many ticks
	var/cur_tick = 0 //Tick updater

//We don't want to cut/update the power overlays every single proc. Just when it actually changes. This should save on CPU cycles. Efficiency!
/obj/machinery/power/geothermal/update_icon()
	..()
	switch(buildstate)
		if(GEOTHERMAL_NO_DAMAGE)
			if(is_on)
				desc = "A thermoelectric generator sitting atop a borehole dug deep in the planet's surface. It generates energy by boiling the plasma steam that rises from the well.\nIt is old technology and has a large failure rate, and must be repaired frequently.\nIt is currently on, and beeping randomly amid faint hisses of steam."
				switch(power_gen_percent)
					if(25)
						icon_state = "on25"
					if(50)
						icon_state = "on50"
					if(75)
						icon_state = "on75"
					if(100)
						icon_state = "on100"
			else
				icon_state = "off"
				desc = "A thermoelectric generator sitting atop a borehole dug deep in the planet's surface. It generates energy by boiling the plasma steam that rises from the well.\nIt is old technology and has a large failure rate, and must be repaired frequently.\nIt is currently turned off and silent."
		if(GEOTHERMAL_HEAVY_DAMAGE)
			icon_state = "weld"
			desc = "A thermoelectric generator sitting atop a plasma-filled borehole. This one is heavily damaged. Use a blowtorch, wirecutters, and then a wrench to repair it."
		if(GEOTHERMAL_MEDIUM_DAMAGE)
			icon_state = "wire"
			desc = "A thermoelectric generator sitting atop a plasma-filled borehole. This one is damaged. Use wirecutters and then a wrench to repair it."
		if(GEOTHERMAL_LIGHT_DAMAGE)
			icon_state = "wrench"
			desc = "A thermoelectric generator sitting atop a plasma-filled borehole. This one is lightly damaged. Use a wrench to repair it."

/obj/machinery/power/geothermal/power_change()
	return

/obj/machinery/power/geothermal/process()
	if(!is_on || buildstate || !anchored || !powernet) //Default logic checking
		return FALSE

	if(!check_failure()) //Wait! Check to see if it breaks during processing
		if(power_gen_percent < 100)
			power_gen_percent++
			update_icon()
			switch(power_gen_percent)
				if(10)
					visible_message("[icon2html(src, viewers(src))] <span class='notice'><b>[src]</b> begins to whirr as it powers up.</span>")
				if(50)
					visible_message("[icon2html(src, viewers(src))] <span class='notice'><b>[src]</b> begins to hum loudly as it reaches half capacity.</span>")
				if(100)
					visible_message("[icon2html(src, viewers(src))] <span class='notice'><b>[src]</b> rumbles loudly as the combustion and thermal chambers reach full strength.</span>")
		add_avail(power_generation_max * (power_gen_percent / 100) ) //Nope, all good, just add the power

/obj/machinery/power/geothermal/proc/check_failure()
	cur_tick++
	if(cur_tick < fail_check_ticks) //Nope, not time for it yet
		return FALSE
	else if(cur_tick > fail_check_ticks) //Went past with no fail, reset the timer
		cur_tick = 0
		return FALSE
	if(rand(1,100) < fail_rate) //Oh snap, we failed! Shut it down!
		if(rand(0,3) == 0)
			visible_message("[icon2html(src, viewers(src))] <span class='notice'><b>[src]</b> beeps wildly and a fuse blows! Use wirecutters, then a wrench to repair it.")
			buildstate = GEOTHERMAL_MEDIUM_DAMAGE
			icon_state = "wire"
		else
			visible_message("[icon2html(src, viewers(src))] <span class='notice'><b>[src]</b> beeps wildly and sprays random pieces everywhere! Use a wrench to repair it.")
			buildstate = GEOTHERMAL_LIGHT_DAMAGE
			icon_state = "wrench"
		is_on = FALSE
		power_gen_percent = 0
		update_icon()
		cur_tick = 0
		stop_processing()
		return TRUE
	return FALSE //Nope, all fine

/obj/machinery/power/geothermal/attack_hand(mob/user as mob)
	. = ..()
	if(.)
		return
	if(!anchored) //Shouldn't actually be possible
		return FALSE
	if(user.incapacitated())
		return FALSE
	if(!ishuman(user))
		to_chat(user, "<span class='warning'>You have no idea how to use that.</span>")
		return FALSE

	if(buildstate == GEOTHERMAL_HEAVY_DAMAGE)
		to_chat(usr, "<span class='info'>Use a blowtorch, then wirecutters, then a wrench to repair it.")
		return FALSE
	else if (buildstate == GEOTHERMAL_MEDIUM_DAMAGE)
		to_chat(usr, "<span class='info'>Use a wirecutters, then wrench to repair it.")
		return FALSE
	else if (buildstate == GEOTHERMAL_LIGHT_DAMAGE)
		to_chat(usr, "<span class='info'>Use a wrench to repair it.")
		return FALSE
	if(is_on)
		visible_message("[icon2html(src, viewers(src))] <span class='warning'><b>[src]</b> beeps softly and the humming stops as [usr] shuts off the turbines.")
		is_on = FALSE
		power_gen_percent = 0
		cur_tick = 0
		icon_state = "off"
		stop_processing()
		return TRUE
	visible_message("[icon2html(src, viewers(src))] <span class='warning'><b>[src]</b> beeps loudly as [usr] turns on the turbines and the generator begins spinning up.")
	icon_state = "on10"
	is_on = TRUE
	cur_tick = 0
	start_processing()
	return TRUE

/obj/machinery/power/geothermal/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(iswelder(I))
		var/obj/item/tool/weldingtool/WT = I
		if(user.mind?.cm_skills && user.mind.cm_skills.engineer < SKILL_ENGINEER_ENGI)
			user.visible_message("<span class='notice'>[user] fumbles around figuring out [src]'s internals.</span>",
			"<span class='notice'>You fumble around figuring out [src]'s internals.</span>")
			var/fumbling_time = 100 - 20 * user.mind.cm_skills.engineer
			if(!do_after(user, fumbling_time, TRUE, src, BUSY_ICON_UNSKILLED, extra_checks = CALLBACK(WT, /obj/item/tool/weldingtool/proc/isOn)) || buildstate != GEOTHERMAL_HEAVY_DAMAGE || is_on)
				return

		if(!WT.remove_fuel(1, user))
			to_chat(user, "<span class='warning'>You need more welding fuel to complete this task.</span>")
			return
		playsound(loc, 'sound/items/weldingtool_weld.ogg', 25)
		user.visible_message("<span class='notice'>[user] starts welding [src]'s internal damage.</span>",
		"<span class='notice'>You start welding [src]'s internal damage.</span>")
		
		if(!do_after(user, 200, TRUE, src, BUSY_ICON_BUILD, extra_checks = CALLBACK(WT, /obj/item/tool/weldingtool/proc/isOn)) || buildstate != GEOTHERMAL_HEAVY_DAMAGE || is_on)
			return FALSE
		
		playsound(loc, 'sound/items/welder2.ogg', 25, 1)
		buildstate = GEOTHERMAL_MEDIUM_DAMAGE
		user.visible_message("<span class='notice'>[user] welds [src]'s internal damage.</span>",
		"<span class='notice'>You weld [src]'s internal damage.</span>")
		update_icon()
		return TRUE
	else if(iswirecutter(I))
		if(buildstate != GEOTHERMAL_MEDIUM_DAMAGE || is_on)
			return
		if(user.mind?.cm_skills && user.mind.cm_skills.engineer < SKILL_ENGINEER_ENGI)
			user.visible_message("<span class='notice'>[user] fumbles around figuring out [src]'s wiring.</span>",
			"<span class='notice'>You fumble around figuring out [src]'s wiring.</span>")
			var/fumbling_time = 100 - 20 * user.mind.cm_skills.engineer
			if(!do_after(user, fumbling_time, TRUE, src, BUSY_ICON_UNSKILLED) || buildstate != GEOTHERMAL_MEDIUM_DAMAGE || is_on)
				return
		playsound(loc, 'sound/items/wirecutter.ogg', 25, 1)
		user.visible_message("<span class='notice'>[user] starts securing [src]'s wiring.</span>",
		"<span class='notice'>You start securing [src]'s wiring.</span>")
		
		if(!do_after(user, 120, TRUE, src, BUSY_ICON_BUILD) || buildstate != GEOTHERMAL_MEDIUM_DAMAGE || is_on)
			return FALSE

		playsound(loc, 'sound/items/wirecutter.ogg', 25, 1)
		buildstate = GEOTHERMAL_LIGHT_DAMAGE
		user.visible_message("<span class='notice'>[user] secures [src]'s wiring.</span>",
		"<span class='notice'>You secure [src]'s wiring.</span>")
		update_icon()
		return TRUE
	else if(iswrench(I))
		if(buildstate != GEOTHERMAL_LIGHT_DAMAGE || is_on)
			return
		if(user.mind?.cm_skills && user.mind.cm_skills.engineer < SKILL_ENGINEER_ENGI)
			user.visible_message("<span class='notice'>[user] fumbles around figuring out [src]'s tubing and plating.</span>",
			"<span class='notice'>You fumble around figuring out [src]'s tubing and plating.</span>")
			var/fumbling_time = 100 - 20 * user.mind.cm_skills.engineer
			if(!do_after(user, fumbling_time, TRUE, src, BUSY_ICON_UNSKILLED) || buildstate != GEOTHERMAL_LIGHT_DAMAGE || is_on)
				return

		playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
		user.visible_message("<span class='notice'>[user] starts repairing [src]'s tubing and plating.</span>",
		"<span class='notice'>You start repairing [src]'s tubing and plating.</span>")

		if(!do_after(user, 150, TRUE, src, BUSY_ICON_BUILD) || buildstate != GEOTHERMAL_LIGHT_DAMAGE || is_on)
			return FALSE

		playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
		buildstate = GEOTHERMAL_NO_DAMAGE
		user.visible_message("<span class='notice'>[user] repairs [src]'s tubing and plating.</span>",
		"<span class='notice'>You repair [src]'s tubing and plating.</span>")
		update_icon()
		return TRUE

/obj/machinery/power/geothermal/bigred //used on big red
	name = "\improper Reactor Turbine"
	power_generation_max = 1e+6

#undef GEOTHERMAL_NO_DAMAGE
#undef GEOTHERMAL_LIGHT_DAMAGE
#undef GEOTHERMAL_MEDIUM_DAMAGE
#undef GEOTHERMAL_HEAVY_DAMAGE

#define SWITCH_OFF 0
#define SWITCH_ON  1
/obj/machinery/colony_floodlight_switch
	name = "Colony Floodlight Switch"
	icon = 'icons/obj/machines/floodlight.dmi'
	icon_state = "panelnopower"
	desc = "This switch controls the floodlights surrounding the archaeology complex. It only functions when there is power."
	density = FALSE
	anchored = TRUE
	var/turned_on = FALSE //has to be toggled in engineering
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 0
	resistance_flags = UNACIDABLE
	var/list/floodlist = list() // This will save our list of floodlights on the map

/obj/machinery/colony_floodlight_switch/Initialize()
	..()
	. = INITIALIZE_HINT_LATELOAD

/obj/machinery/colony_floodlight_switch/LateInitialize() //Populate our list of floodlights so we don't need to scan for them ever again
	. = ..()
	for(var/obj/machinery/colony_floodlight/F in GLOB.machines)
		floodlist += F
		F.fswitch = src

/obj/machinery/colony_floodlight_switch/update_icon()
	if(machine_stat & NOPOWER)
		icon_state = "panelnopower"
	else if(turned_on)
		icon_state = "panelon"
	else
		icon_state = "paneloff"

/obj/machinery/colony_floodlight_switch/power_change()
	..()
	if(machine_stat & NOPOWER)
		if(turned_on)
			toggle_lights(SWITCH_OFF)
			turned_on = FALSE
	update_icon()

/obj/machinery/colony_floodlight_switch/proc/toggle_power()
	turned_on = !turned_on


/obj/machinery/colony_floodlight_switch/proc/toggle_lights(switch_on)
	for(var/obj/machinery/colony_floodlight/F in floodlist)
		addtimer(CALLBACK(F, /obj/machinery/colony_floodlight/proc/toggle_light, switch_on), rand(0,50))

/obj/machinery/colony_floodlight_switch/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/colony_floodlight_switch/attack_hand(mob/user as mob)
	. = ..()
	if(.)
		return
	if(!ishuman(user))
		to_chat(user, "Nice try.")
		return FALSE
	if(machine_stat & NOPOWER)
		to_chat(user, "Nothing happens.")
		return FALSE
	playsound(src,'sound/machines/click.ogg', 15, 1)
	toggle_lights(turned_on ? SWITCH_OFF : SWITCH_ON)
	toggle_power()
	update_icon()
	return TRUE

#define FLOODLIGHT_REPAIR_FINE 		 0
#define FLOODLIGHT_REPAIR_WIRECUTTER 1
#define FLOODLIGHT_REPAIR_WELD		 2
#define FLOODLIGHT_TICK_CONSUMPTION 800
/obj/machinery/colony_floodlight
	name = "Colony Floodlight"
	icon = 'icons/obj/machines/floodlight.dmi'
	icon_state = "floodoff"
	density = TRUE
	anchored = TRUE
	var/damaged = FALSE //Can be smashed by xenos
	var/is_lit = FALSE //whether the floodlight is switched to on or off. Does not necessarily mean it emits light.
	resistance_flags = UNACIDABLE
	use_power = NO_POWER_USE //It's the switch that uses the actual power, not the lights
	var/obj/machinery/colony_floodlight_switch/fswitch = null //Reverse lookup for power grabbing in area
	var/lum_value = 7
	var/repair_state = FLOODLIGHT_REPAIR_FINE
	max_integrity = 120

/obj/machinery/colony_floodlight/Destroy()
	toggle_light(SWITCH_OFF)
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
	if(CHECK_BITFIELD(machine_stat, PANEL_OPEN))
		icon_state = "[icon_state]_o"

/obj/machinery/colony_floodlight/attack_larva(mob/living/carbon/xenomorph/larva/M)
	M.visible_message("[M] starts biting [src]!","In a rage, you start biting [src], but with no effect!", null, 5)

/obj/machinery/colony_floodlight/proc/breakdown()
	playsound(src, "shatter", 70, 1)
	damaged = TRUE
	repair_state = FLOODLIGHT_REPAIR_WELD
	toggle_light(SWITCH_OFF)

/obj/machinery/colony_floodlight/attack_alien(mob/living/carbon/xenomorph/M)
	if(!is_lit)
		to_chat(M, "Why bother? It's just some weird metal thing.")
		return FALSE
	else if(damaged)
		to_chat(M, "It's already damaged.")
		return FALSE
	else if(CHECK_BITFIELD(machine_stat, PANEL_OPEN))
		breakdown()
	else
		M.animation_attack_on(src)
		M.visible_message("[M] slashes away at [src]!","You slash and claw at the bright light!", null, null, 5)
		obj_integrity  = max(obj_integrity - rand(M.xeno_caste.melee_damage_lower, M.xeno_caste.melee_damage_upper), 0)
		if(!obj_integrity)
			ENABLE_BITFIELD(machine_stat, PANEL_OPEN)
			playsound(loc, 'sound/items/trayhit2.ogg', 25, 1)
			update_icon()
		else
			playsound(loc, "alien_claw_metal", 25, 1)

/obj/machinery/colony_floodlight/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(isscrewdriver(I))
		TOGGLE_BITFIELD(machine_stat, PANEL_OPEN)
		if(CHECK_BITFIELD(machine_stat, PANEL_OPEN))
			to_chat(user, "<span class='notice'>You open the maintenance hatch of [src].</span>")
		else
			to_chat(user, "<span class='notice'>You close the maintenance hatch of [src].</span>")
		update_icon()
		return FALSE

	if(!damaged)
		return

	if(iswelder(I))
		var/obj/item/tool/weldingtool/WT = I

		if(user.mind?.cm_skills && user.mind.cm_skills.engineer < SKILL_ENGINEER_ENGI)
			user.visible_message("<span class='notice'>[user] fumbles around figuring out [src]'s internals.</span>",
			"<span class='notice'>You fumble around figuring out [src]'s internals.</span>")
			var/fumbling_time = 60 - 20 * user.mind.cm_skills.engineer
			if(!do_after(user, fumbling_time, TRUE, src, BUSY_ICON_UNSKILLED) || repair_state != FLOODLIGHT_REPAIR_WELD)
				return FALSE

		if(!WT.remove_fuel(1, user))
			to_chat(user, "<span class='warning'>You need more welding fuel to complete this task.</span>")
			return
		playsound(loc, 'sound/items/weldingtool_weld.ogg', 25)
		user.visible_message("<span class='notice'>[user] starts welding [src]'s damage.</span>",
		"<span class='notice'>You start welding [src]'s damage.</span>")

		if(!do_after(user, 40, TRUE, src, BUSY_ICON_BUILD, extra_checks = CALLBACK(WT, /obj/item/tool/weldingtool/proc/isOn)) || repair_state != FLOODLIGHT_REPAIR_WELD)
			return FALSE

		playsound(loc, 'sound/items/welder2.ogg', 25, 1)
		repair_state = FLOODLIGHT_REPAIR_WIRECUTTER
		user.visible_message("<span class='notice'>[user] welds [src]'s damage.</span>",
		"<span class='notice'>You weld [src]'s damage.</span>")
		return TRUE

	else if(iswirecutter(I))
		if(user.mind?.cm_skills && user.mind.cm_skills.engineer < SKILL_ENGINEER_ENGI)
			user.visible_message("<span class='notice'>[user] fumbles around figuring out [src]'s wiring.</span>",
			"<span class='notice'>You fumble around figuring out [src]'s wiring.</span>")
			var/fumbling_time = 60 - 20 * user.mind.cm_skills.engineer
			if(!do_after(user, fumbling_time, TRUE, src, BUSY_ICON_UNSKILLED) || repair_state != FLOODLIGHT_REPAIR_WIRECUTTER)
				return FALSE

		playsound(loc, 'sound/items/wirecutter.ogg', 25, 1)
		user.visible_message("<span class='notice'>[user] starts mending [src]'s damaged cables.</span>",\
		"<span class='notice'>You start mending [src]'s damaged cables.</span>")

		if(!do_after(user, 20, TRUE, src, BUSY_ICON_BUILD) || repair_state != FLOODLIGHT_REPAIR_WIRECUTTER)
			return FALSE

		playsound(loc, 'sound/items/wirecutter.ogg', 25, 1)
		repair_state = FLOODLIGHT_REPAIR_FINE
		damaged = FALSE
		obj_integrity = initial(obj_integrity)
		toggle_light(SWITCH_ON)
		user.visible_message("<span class='notice'>[user] mend [src]'s damaged cables.</span>",\
		"<span class='notice'>You mend [src]'s damaged cables.</span>")
		return TRUE

/obj/machinery/colony_floodlight/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(ishuman(user))
		if(damaged)
			to_chat(user, "<span class='warning'>[src] is damaged.</span>")
		else if(!is_lit)
			to_chat(user, "<span class='warning'>Nothing happens. Looks like it's powered elsewhere.</span>")
		return FALSE

/obj/machinery/colony_floodlight/examine(mob/user)
	..()
	if(ishuman(user))
		if(damaged)
			to_chat(user, "<span class='warning'>It is damaged.</span>")
			if(!user.mind || !user.mind.cm_skills || user.mind.cm_skills.engineer >= SKILL_ENGINEER_ENGI)
				if(!CHECK_BITFIELD(machine_stat, PANEL_OPEN))
					to_chat(user, "<span class='info'>You must first open its maintenance hatch.</span>")
				else
					switch(repair_state)
						if(FLOODLIGHT_REPAIR_WELD)
							to_chat(user, "<span class='info'>You must weld the damage to it.</span>")
						if(FLOODLIGHT_REPAIR_WIRECUTTER)
							to_chat(user, "<span class='info'>You must mend its damaged cables.</span>")
						else
							to_chat(user, "<span class='info'>You must screw its maintenance hatch closed.</span>")
		else if(!is_lit)
			to_chat(user, "<span class='info'>It doesn't seem powered.</span>")
		if(CHECK_BITFIELD(machine_stat, PANEL_OPEN))
			to_chat(user, "<span class='notice'>The maintenance hatch is open.</span>")

/obj/machinery/colony_floodlight/proc/toggle_light(switch_on)
	if(!fswitch) //no master, should never happen
		return

	if(switch_on && !is_lit)
		if(damaged || !anchored || !fswitch.turned_on)
			return
		set_light(lum_value)
		fswitch.active_power_usage += FLOODLIGHT_TICK_CONSUMPTION
		is_lit = TRUE
		update_icon()
	else if(!switch_on && is_lit)
		set_light(0)
		fswitch.active_power_usage -= FLOODLIGHT_TICK_CONSUMPTION
		is_lit = FALSE
		update_icon()

#undef FLOODLIGHT_REPAIR_FINE
#undef FLOODLIGHT_REPAIR_WELD
#undef FLOODLIGHT_REPAIR_WIRECUTTER
#undef FLOODLIGHT_TICK_CONSUMPTION
#undef SWITCH_OFF
#undef SWITCH_ON
