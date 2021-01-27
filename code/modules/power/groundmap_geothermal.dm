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
	resistance_flags = UNACIDABLE | INDESTRUCTIBLE
	var/power_gen_percent = 0 //100,000W at full capacity
	var/power_generation_max = 100000 //Full capacity
	var/buildstate = GEOTHERMAL_HEAVY_DAMAGE //What state of building it are we on, 0-3, 1 is "broken", the default
	var/is_on = FALSE  //Is this damn thing on or what?
	var/fail_rate = 0 //% chance of failure each fail_tick check
	var/fail_check_ticks = 100 //Check for failure every this many ticks
	var/cur_tick = 0 //Tick updater

/obj/machinery/power/geothermal/should_have_node()
	return TRUE

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

		//Resets the fail_rate incase the xenos have been fucking with it.
		fail_rate = initial(fail_rate)

		is_on = FALSE
		power_gen_percent = 0
		update_icon()
		cur_tick = 0
		stop_processing()
		return TRUE
	return FALSE //Nope, all fine

/obj/machinery/power/geothermal/attack_alien(mob/living/carbon/xenomorph/X)
	. = ..()
	// Can't damage a broken generator
	if(buildstate)
		return
	X.do_attack_animation(src, ATTACK_EFFECT_CLAW)
	play_attack_sound(1)
	X.visible_message("<span class='danger'>\The [X] slashes at \the [src], tearing at it's components!</span>",
		"<span class='danger'>We start slashing at \the [src], tearing at it's components!</span>")
	fail_rate += 5 // 5% fail rate every attack


/obj/machinery/power/geothermal/attack_hand(mob/living/user)
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
		if(user.skills.getRating("engineer") < SKILL_ENGINEER_ENGI)
			user.visible_message("<span class='notice'>[user] fumbles around figuring out [src]'s internals.</span>",
			"<span class='notice'>You fumble around figuring out [src]'s internals.</span>")
			var/fumbling_time = 10 SECONDS - 2 SECONDS * user.skills.getRating("engineer")
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
		if(user.skills.getRating("engineer") < SKILL_ENGINEER_ENGI)
			user.visible_message("<span class='notice'>[user] fumbles around figuring out [src]'s wiring.</span>",
			"<span class='notice'>You fumble around figuring out [src]'s wiring.</span>")
			var/fumbling_time = 10 SECONDS - 2 SECONDS * user.skills.getRating("engineer")
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
		if(user.skills.getRating("engineer") < SKILL_ENGINEER_ENGI)
			user.visible_message("<span class='notice'>[user] fumbles around figuring out [src]'s tubing and plating.</span>",
			"<span class='notice'>You fumble around figuring out [src]'s tubing and plating.</span>")
			var/fumbling_time = 10 SECONDS - 2 SECONDS * user.skills.getRating("engineer")
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
