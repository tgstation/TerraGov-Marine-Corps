#define GENERATOR_NO_DAMAGE 0
#define GENERATOR_LIGHT_DAMAGE 1
#define GENERATOR_MEDIUM_DAMAGE 2
#define GENERATOR_HEAVY_DAMAGE 3
#define GENERATOR_EXPLODING 4

//Count of all generators on the ground
GLOBAL_VAR_INIT(generators_on_ground, 0)

/obj/machinery/power/geothermal
	name = "\improper G-11 geothermal generator"
	icon = 'icons/turf/geothermal.dmi'
	icon_state = "weld"
	desc = "A thermoelectric generator sitting atop a plasma-filled borehole. This one is heavily damaged. Use a blowtorch, then wirecutters, and then a wrench to repair it."
	anchored = TRUE
	density = TRUE
	resistance_flags = RESIST_ALL | DROPSHIP_IMMUNE
	var/power_gen_percent = 0 //100,000W at full capacity
	var/power_generation_max = 100000 //Full capacity
	var/buildstate = GENERATOR_HEAVY_DAMAGE //What state of building it are we on, 0-3, 1 is "broken", the default
	var/is_on = FALSE  //Is this damn thing on or what?
	var/time_to_break = 1.5 SECONDS //How long it takes to break each stage of the generator
	///Hive it should be powering and whether it should be generating hive psycic points instead of power on process()
	var/corrupted = XENO_HIVE_NORMAL
	///whether we wil allow these to be corrupted
	var/is_corruptible = TRUE
	///whether they should generate corruption if corrupted
	var/corruption_on = FALSE

/obj/machinery/power/geothermal/Initialize(mapload)
	. = ..()
	RegisterSignals(SSdcs, list(COMSIG_GLOB_OPEN_TIMED_SHUTTERS_LATE, COMSIG_GLOB_OPEN_TIMED_SHUTTERS_XENO_HIVEMIND, COMSIG_GLOB_OPEN_SHUTTERS_EARLY, COMSIG_GLOB_TADPOLE_LANDED_OUT_LZ, COMSIG_GLOB_TADPOLE_RAPPEL_DEPLOYED_OUT_LZ), PROC_REF(activate_corruption))
	update_icon()
	update_minimap_icon()

	if(is_ground_level(z))
		GLOB.generators_on_ground++

	if(corrupted)
		corrupt(corrupted)

/obj/machinery/power/geothermal/Destroy() //just in case
	if(is_ground_level(z))
		GLOB.generators_on_ground--
		if(is_on)
			GLOB.active_bluespace_generators--
	return ..()

/obj/machinery/power/geothermal/examine(mob/user, distance, infix, suffix)
	. = ..()
	if(corrupted)
		. += "It is covered in writhing tendrils [!isxeno(user) ? "that could be cut away with a welder" : ""]."
	if(!isxeno(user) && !is_corruptible)
		. += "It is reinforced, making us not able to corrupt it."

/obj/machinery/power/geothermal/should_have_node()
	return TRUE

//We don't want to cut/update the power overlays every single proc. Just when it actually changes. This should save on CPU cycles. Efficiency!
/obj/machinery/power/geothermal/update_icon_state()
	. = ..()
	switch(buildstate)
		if(GENERATOR_NO_DAMAGE)
			if(is_on)
				switch(power_gen_percent)
					if(0 to 25)
						icon_state = "on25"
					if(25 to 50)
						icon_state = "on50"
					if(50 to 75)
						icon_state = "on75"
					if(75 to 100)
						icon_state = "on100"
			else
				icon_state = "off"
		if(GENERATOR_HEAVY_DAMAGE)
			icon_state = "weld"
		if(GENERATOR_MEDIUM_DAMAGE)
			icon_state = "wire"
		if(GENERATOR_LIGHT_DAMAGE)
			icon_state = "wrench"

/obj/machinery/power/geothermal/examine(mob/user)
	. = ..()
	switch(buildstate)
		if(GENERATOR_NO_DAMAGE)
			if(!is_on)
				. += "It is currently turned off and silent."
		if(GENERATOR_HEAVY_DAMAGE)
			. += "This one is heavily damaged. Use a blowtorch, wirecutters, and then a wrench to repair it."
		if(GENERATOR_MEDIUM_DAMAGE)
			. += "This one is damaged. Use wirecutters and then a wrench to repair it."
		if(GENERATOR_LIGHT_DAMAGE)
			. += "This one is lightly damaged. Use a wrench to repair it."

/obj/machinery/power/geothermal/update_overlays()
	. = ..()
	if(corrupted)
		. += image(icon, src, "overlay_corrupted", layer)

/// Updates the minimap icon to whether the generator is running or not
/obj/machinery/power/geothermal/proc/update_minimap_icon()
	SSminimaps.remove_marker(src)
	SSminimaps.add_marker(src, MINIMAP_FLAG_ALL, image('icons/UI_icons/map_blips.dmi', null, "generator[is_on ? "_on" : "_off"]", MINIMAP_BLIPS_LAYER))

/obj/machinery/power/geothermal/power_change()
	return

///Allow generators to generate psych points
/obj/machinery/power/geothermal/proc/activate_corruption(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(SSdcs, list(COMSIG_GLOB_OPEN_TIMED_SHUTTERS_LATE, COMSIG_GLOB_OPEN_TIMED_SHUTTERS_XENO_HIVEMIND, COMSIG_GLOB_OPEN_SHUTTERS_EARLY, COMSIG_GLOB_TADPOLE_LANDED_OUT_LZ, COMSIG_GLOB_TADPOLE_RAPPEL_DEPLOYED_OUT_LZ))
	corruption_on = TRUE
	start_processing()

/obj/machinery/power/geothermal/process()
	if(corrupted && corruption_on)
		if(!GLOB.generators_on_ground) //Prevent division by 0
			return PROCESS_KILL
		if((length(GLOB.humans_by_zlevel["2"]) > 0.2 * length(GLOB.alive_human_list_faction[FACTION_TERRAGOV])))
			//You get points proportional to the % of generators corrupted (for example, if 66% of generators are corrupted the hive gets 0.66 points per second)
			var/points_generated = GENERATOR_PSYCH_POINT_OUTPUT / GLOB.generators_on_ground
			SSpoints.add_strategic_psy_points(corrupted, points_generated)
			SSpoints.add_tactical_psy_points(corrupted, points_generated*0.25)
		return
	if(!is_on || buildstate || !anchored || !powernet) //Default logic checking
		return PROCESS_KILL

	if(power_gen_percent < 100)
		power_gen_percent++
		update_icon()
		update_minimap_icon()
		switch(power_gen_percent)
			if(10)
				balloon_alert_to_viewers("begins to whirr as it powers up.")
			if(50)
				balloon_alert_to_viewers("hums loudly as it reaches half capacity.")
			if(100)
				balloon_alert_to_viewers("rumbles loudly as the generator reaches full strength.")
		add_avail(power_generation_max * (power_gen_percent / 100) ) //Nope, all good, just add the power

/obj/machinery/power/geothermal/attack_alien(mob/living/carbon/xenomorph/xeno_attacker, damage_amount = xeno_attacker.xeno_caste.melee_damage, damage_type = BRUTE, armor_type = MELEE, effects = TRUE, armor_penetration = xeno_attacker.xeno_caste.melee_ap, isrightclick = FALSE)
	. = ..()
	if(corrupted) //you have no reason to interact with it if its already corrupted
		return
	if(xeno_attacker.status_flags & INCORPOREAL || HAS_TRAIT_FROM(xeno_attacker, TRAIT_TURRET_HIDDEN, STEALTH_TRAIT))
		return

	while(buildstate < GENERATOR_HEAVY_DAMAGE)
		if(xeno_attacker.do_actions)
			return balloon_alert(xeno_attacker, "busy")
		if(!do_after(xeno_attacker, time_to_break, NONE, src, BUSY_ICON_DANGER, BUSY_ICON_HOSTILE))
			return
		xeno_attacker.do_attack_animation(src, ATTACK_EFFECT_CLAW)
		xeno_attacker.visible_message(span_danger("[xeno_attacker] slashes \the [src]!"), \
		span_danger("We slash \the [src]!"), null, 5)
		play_attack_sound(1)
		playsound(src, 'sound/effects/grillehit.ogg', 50, TRUE)
		damage_generator()
		record_generator_sabotages(xeno_attacker)

	if(buildstate == GENERATOR_HEAVY_DAMAGE && CHECK_BITFIELD(xeno_attacker.xeno_caste.can_flags, CASTE_CAN_CORRUPT_GENERATOR) && is_corruptible)
		to_chat(xeno_attacker, span_notice("You start to corrupt [src]"))
		if(!do_after(xeno_attacker, 10 SECONDS, NONE, src, BUSY_ICON_HOSTILE))
			return
		corrupt(xeno_attacker.hivenumber)
		to_chat(xeno_attacker, span_notice("You have corrupted [src]"))
		record_generator_sabotages(xeno_attacker)


/// Turns the build state back until generator entirely breaks
/obj/machinery/power/geothermal/proc/damage_generator()
	if(buildstate >= GENERATOR_HEAVY_DAMAGE)
		return FALSE
	balloon_alert_to_viewers("beeps wildly and sprays random pieces everywhere!")
	buildstate++
	if(is_on)
		turn_off()
	return TRUE

/obj/machinery/power/geothermal/attack_hand(mob/living/carbon/user)
	interact_hand(user)

/obj/machinery/power/geothermal/attack_ai(mob/living/silicon/ai/user)
	interact_hand(user)


/obj/machinery/power/geothermal/proc/interact_hand(mob/living/user)
	if(.)
		return
	if(!anchored) //Shouldn't actually be possible
		return FALSE
	if(user.incapacitated())
		return FALSE
	if(!ishuman(user) && !issilicon(user))
		to_chat(user, span_warning("You have no idea how to use that."))
		return FALSE
	if(corrupted)
		to_chat(user, span_warning("You have to clean that generator before it can be used!"))
		return FALSE

	if(buildstate == GENERATOR_HEAVY_DAMAGE)
		to_chat(usr, "<span class='info'>Use a blowtorch, then wirecutters, then a wrench to repair it.")
		return FALSE
	else if (buildstate == GENERATOR_MEDIUM_DAMAGE)
		to_chat(usr, "<span class='info'>Use a wirecutters, then wrench to repair it.")
		return FALSE
	else if (buildstate == GENERATOR_LIGHT_DAMAGE)
		to_chat(usr, "<span class='info'>Use a wrench to repair it.")
		return FALSE
	if(is_on)
		turn_off()
		return TRUE
	turn_on()
	return TRUE

/// Handle turning on the generator and updating power
/obj/machinery/power/geothermal/proc/turn_on()
	is_on = TRUE
	update_icon()
	update_desc()
	start_processing()


/// Handle turning off the generator and updating power
/obj/machinery/power/geothermal/proc/turn_off()
	is_on = FALSE
	power_gen_percent = 0
	update_icon()
	update_desc()
	stop_processing()

/obj/machinery/power/geothermal/welder_act(mob/living/user, obj/item/I)
	var/obj/item/tool/weldingtool/WT = I
	if(corrupted)
		if(user.skills.getRating(SKILL_ENGINEER) < SKILL_ENGINEER_ENGI)
			user.visible_message(span_notice("[user] fumbles around figuring out the resin tendrils on [src]."),
			span_notice("You fumble around trying to burn off the resin tendrils."))
			user.balloon_alert(user, "You fumble around trying to burn off the resin tendrils.")
			var/fumbling_time = 10 SECONDS - 2 SECONDS * user.skills.getRating(SKILL_ENGINEER)
			if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED, extra_checks = CALLBACK(WT, TYPE_PROC_REF(/obj/item/tool/weldingtool, isOn))))
				return

		if(!WT.remove_fuel(1, user))
			to_chat(user, span_warning("You need more welding fuel to complete this task."))
			return
		user.visible_message(span_notice("[user] carefully starts burning [src]'s resin off."),
		span_notice("You start carefully burning the resin off."))
		user.balloon_alert(user, "You start carefully burning the resin off.")

		if(!I.use_tool(src, user, 20 SECONDS - clamp((user.skills.getRating(SKILL_ENGINEER) - SKILL_ENGINEER_ENGI) * 5, 0, 20), 2, 25, null, BUSY_ICON_BUILD))
			return FALSE

		corrupted = 0
		stop_processing()
		update_icon()

	if(buildstate != GENERATOR_HEAVY_DAMAGE) //Already repaired!
		return

	if(user.skills.getRating(SKILL_ENGINEER) < SKILL_ENGINEER_ENGI)
		user.balloon_alert(user, "You fumble around figuring out how the internals work.")
		var/fumbling_time = 10 SECONDS - 2 SECONDS * user.skills.getRating(SKILL_ENGINEER)
		if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED, extra_checks = CALLBACK(WT, TYPE_PROC_REF(/obj/item/tool/weldingtool, isOn))) || buildstate != GENERATOR_HEAVY_DAMAGE || is_on)
			return

	if(!WT.remove_fuel(1, user))
		to_chat(user, span_warning("You need more welding fuel to complete this task."))
		return

	user.balloon_alert(user, "You start welding the internals back together.")
	if(!I.use_tool(src, user, 20 SECONDS - clamp((user.skills.getRating(SKILL_ENGINEER) - SKILL_ENGINEER_ENGI) * 5, 0, 20), 2, 25, null, BUSY_ICON_BUILD))
		return FALSE

	buildstate = GENERATOR_MEDIUM_DAMAGE
	user.balloon_alert(user, "You weld the internals back together.")
	update_icon()
	record_generator_repairs(user)
	return TRUE

/obj/machinery/power/geothermal/wirecutter_act(mob/living/user, obj/item/I)
	if(buildstate != GENERATOR_MEDIUM_DAMAGE || is_on)
		return
	if(user.skills.getRating(SKILL_ENGINEER) < SKILL_ENGINEER_ENGI)
		user.balloon_alert(user, "You fumble around figuring out how the wiring works.")
		var/fumbling_time = 10 SECONDS - 2 SECONDS * user.skills.getRating(SKILL_ENGINEER)
		if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED) || buildstate != GENERATOR_MEDIUM_DAMAGE || is_on)
			return
	playsound(loc, 'sound/items/wirecutter.ogg', 25, 1)
	user.balloon_alert(user, "You start securing the wiring.")
	if(!do_after(user, 12 SECONDS - clamp((user.skills.getRating(SKILL_ENGINEER) - SKILL_ENGINEER_ENGI) * 4, 0, 12) SECONDS, NONE, src, BUSY_ICON_BUILD) || buildstate != GENERATOR_MEDIUM_DAMAGE || is_on)
		return FALSE

	playsound(loc, 'sound/items/wirecutter.ogg', 25, 1)
	buildstate = GENERATOR_LIGHT_DAMAGE
	user.balloon_alert(user, "You secure the wiring.")
	update_icon()
	record_generator_repairs(user)
	return TRUE

/obj/machinery/power/geothermal/wrench_act(mob/living/user, obj/item/I)
	if(buildstate != GENERATOR_LIGHT_DAMAGE || is_on)
		return
	if(user.skills.getRating(SKILL_ENGINEER) < SKILL_ENGINEER_ENGI)
		user.balloon_alert(user, "You fumble around figuring out the tubing and plating.")
		var/fumbling_time = 10 SECONDS - 2 SECONDS * user.skills.getRating(SKILL_ENGINEER)
		if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED) || buildstate != GENERATOR_LIGHT_DAMAGE || is_on)
			return

	playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
	user.balloon_alert(user, "You start repairing the tubing and plating.")

	if(!do_after(user, 15 SECONDS - clamp((user.skills.getRating(SKILL_ENGINEER) - SKILL_ENGINEER_ENGI) * 5, 0, 15) SECONDS, NONE, src, BUSY_ICON_BUILD) || buildstate != GENERATOR_LIGHT_DAMAGE || is_on)
		return FALSE

	playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
	buildstate = GENERATOR_NO_DAMAGE
	user.balloon_alert(user, "You repair the tubing and plating.")
	update_icon()
	record_generator_repairs(user)
	return TRUE

/obj/machinery/power/geothermal/proc/corrupt(hivenumber)
	corrupted = hivenumber
	update_icon()
	start_processing()

/obj/machinery/power/geothermal/bigred //used on big red
	name = "\improper Reactor Turbine"
	power_generation_max = 1e+6

/obj/machinery/power/geothermal/reinforced
	name = "\improper Reinforced Reactor Turbine"
	is_corruptible = FALSE

//Counter of how many TBGs there are active, for disks
GLOBAL_VAR_INIT(active_bluespace_generators, 0)

/**
 * Thermo-bluespace generator
 *
 * The main, big boy generator that engineers need to be concerned with
 * While active -- Generates a shitton of power and overclocks disk generation speed
 * Xenos can disable it after a short windup, which if the generator is running, triggers a massive explosion
		*/

/obj/machinery/power/geothermal/tbg
	name = "\improper Thermo-Bluespace Generator"
	desc = "A marvel of modern engineering and a shining example of pioneering bluespace technology, able to power entire colonies with very little material consumption - perfectly suited for isolated areas on the outer rim.\nHighly volatile, but that shouldn't matter on some quiet backwater colony, right..?"
	icon = 'icons/obj/machines/tbg.dmi'
	power_generation_max = 5000000 //Powers an entire colony
	time_to_break = 10 SECONDS
	voice_filter = "alimiter=0.9,acompressor=threshold=0.2:ratio=20:attack=10:release=50:makeup=2,highpass=f=1000"
	//Stores whether we're in the turning off animation
	var/winding_down = FALSE
	//List of turbines connected for visuals
	var/list/connected_turbines = list()
	//Ambient soundloop
	var/datum/looping_sound/generator/tbg/ambient_soundloop
	//Explosion alarm soundloop
	var/datum/looping_sound/alarm_loop/generator/alarm_soundloop

	COOLDOWN_DECLARE(toggle_power)

/obj/machinery/power/geothermal/tbg/Initialize()
	. = ..()
	ambient_soundloop = new(list(src), is_on)
	alarm_soundloop = new(list(src), buildstate == GENERATOR_EXPLODING)
	for(var/direction in GLOB.cardinals)
		var/obj/machinery/power/tbg_turbine/potential_turbine = locate(/obj/machinery/power/tbg_turbine, get_step(src, direction))
		if(!potential_turbine)
			continue
		connected_turbines += potential_turbine
		potential_turbine.connected = src

/obj/machinery/power/geothermal/tbg/Destroy()
	QDEL_NULL(ambient_soundloop)
	QDEL_NULL(alarm_soundloop)
	for(var/obj/machinery/power/tbg_turbine/turbine AS in connected_turbines)
		QDEL_NULL(turbine)
	return ..()

/obj/machinery/power/geothermal/tbg/update_icon_state()
	. = ..()
	if(winding_down)
		icon_state = "on25"
	if(buildstate == GENERATOR_EXPLODING)
		icon_state = "exploding"
	for(var/obj/machinery/power/tbg_turbine/turbine in connected_turbines)
		turbine.update_icon()

/obj/machinery/power/geothermal/tbg/interact_hand(mob/living/user)
	if(!COOLDOWN_CHECK(src, toggle_power))
		balloon_alert(user, "Busy")
		return
	return ..()

/obj/machinery/power/geothermal/tbg/turn_on()
	COOLDOWN_START(src, toggle_power, 10 SECONDS)
	ambient_soundloop.start()
	GLOB.active_bluespace_generators++
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_BLUESPACE_GEN_ACTIVATED, TRUE)
	return ..()

/obj/machinery/power/geothermal/tbg/turn_off()
	COOLDOWN_START(src, toggle_power, 10 SECONDS)
	. = ..()
	winding_down = TRUE
	update_icon()
	addtimer(CALLBACK(src, PROC_REF(finish_winding_down)), 10 SECONDS)
	ambient_soundloop.stop()
	GLOB.active_bluespace_generators--
	if(!GLOB.active_bluespace_generators)
		SEND_GLOBAL_SIGNAL(COMSIG_GLOB_ALL_BLUESPACE_GEN_DEACTIVATED, FALSE)

/// Updates the turbine animation after the winding down sound effect has finished
/obj/machinery/power/geothermal/tbg/proc/finish_winding_down()
	winding_down = FALSE
	update_icon()

/obj/machinery/power/geothermal/tbg/damage_generator()
	if(buildstate >= GENERATOR_EXPLODING) //Already exploding; can't be damaged more than that!
		return FALSE
	. = ..()
	if(!.)
		return FALSE

	var/sparks_target = pick(src, connected_turbines)
	var/datum/effect_system/spark_spread/sparks = new
	sparks.set_up(2, 0, sparks_target)
	sparks.attach(sparks_target)
	sparks.start()

	if(buildstate == GENERATOR_HEAVY_DAMAGE)
		initiate_meltdown()

	return TRUE

/// Triggers generator meltdown process
/obj/machinery/power/geothermal/tbg/proc/initiate_meltdown()
	buildstate = GENERATOR_EXPLODING
	update_icon()
	var/area/generator_area = get_area(src)
	var/obj/machinery/power/apc/current_apc = generator_area.get_apc()
	current_apc.emp_act(2)

	addtimer(CALLBACK(src, PROC_REF(trigger_alarms)), 3 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(finish_meltdown)), 60 SECONDS)

	//Devastate range -- Heavy range -- Light range -- Fire range -- Time until explosion
	var/list/list_of_explosions = list(
		list(0, 5, 10, 2, 40 SECONDS),
		list(0, 10, 15, 7, 43 SECONDS),
		list(0, 10, 17, 7, 45 SECONDS),
		list(0, 15, 20, 15, 46 SECONDS),
		list(0, 15, 20, 15, 47 SECONDS),
		list(0, 15, 20, 15, 49 SECONDS),
		list(0, 15, 20, 15, 50 SECONDS),
		list(0, 15, 20, 15, 52 SECONDS),
		list(0, 20, 24, 35, 56 SECONDS),
	)
	for(var/explosion_data in list_of_explosions)
		var/turf/epicenter = locate(loc.x + rand(-2,2), loc.y + rand(-2,2), loc.z)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(explosion), epicenter, explosion_data[1], explosion_data[2], explosion_data[3], explosion_data[4], explosion_data[4]), explosion_data[5])
	//Destroy generator after big explosion happens
	QDEL_IN(src, 56 SECONDS)

/// Triggers alarm visual effects and queues alarm warnings for ongoing TBG meltdown
/obj/machinery/power/geothermal/tbg/proc/trigger_alarms()
	alarm_soundloop.start()
	//Trigger alarm lights
	for(var/obj/machinery/floor_warn_light/toggleable/generator/light AS in GLOB.generator_alarm_lights)
		light.enable()

	say("WARNING: REACTOR MELTDOWN IMMINENT. Attempting to diagnose the issue...")
	var/list/warning_messages = list(
		list("STABILISATION REQUIRES BLUESPACE COMBUSTION. PLEASE EVACUATE THE AREA.", 3 SECONDS),
		list("BLUESPACE COMBUSTION IN T-30 SECONDS", 7 SECONDS),
		list("BLUESPACE COMBUSTION IN T-15 SECONDS", 22 SECONDS),
		list("BLUESPACE COMBUSTION IMMINENT. PLEASE EVACUATE THE AREA IMMEDIATELY.", 27 SECONDS),
		list("EXPLOSION IN 5", 32 SECONDS),
		list("4", 33 SECONDS),
		list("3", 34 SECONDS),
		list("2", 35 SECONDS),
		list("1", 36 SECONDS),
		list("CATASTROPHIC MELTDOWN AVERTED. HEAT LEVELS NOMINAL.", 40 SECONDS),
		list("ATTEMPTING TO CONTAIN EXTERNAL COMBUSTION PROCESS...", 44 SECONDS),
		list("CONTAINMENT FAILED (1). RE-ATTEMPTING...", 47 SECONDS),
		list("CONTAINMENT FAILED (2). RE-ATTEMPTING...", 49 SECONDS),
		list("CONTAINMENT FAILED (3). SELF-DESTRUCT IMMINENT.", 53 SECONDS),
	)
	for(var/warning_data in warning_messages)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/atom/movable, say), warning_data[1]), warning_data[2])

/// Finalises TBG meltdown and resets it back to its initial state
/obj/machinery/power/geothermal/tbg/proc/finish_meltdown()
	buildstate = GENERATOR_HEAVY_DAMAGE
	update_icon()
	alarm_soundloop.stop()
	//Disable alarmlights
	for(var/obj/machinery/floor_warn_light/toggleable/generator/light AS in GLOB.generator_alarm_lights)
		light.disable()
	say("Bluespace restabilisation successful. Planetary assets protected.")

/// TBG turbine attached to the TBG; purely visual
/obj/machinery/power/tbg_turbine
	name = "\improper Generator Turbine"
	desc = "A generator turbine attached to the colony's thermo-bluespace generator."
	icon = 'icons/obj/machines/tbg.dmi'
	icon_state = "circ-on75-neutral"
	anchored = TRUE
	density = TRUE
	resistance_flags = RESIST_ALL | DROPSHIP_IMMUNE
	//Determines turbine icon type
	var/icon_type = "neutral"
	//The generator we are connected to
	var/obj/machinery/power/geothermal/tbg/connected

/obj/machinery/power/tbg_turbine/Destroy()
	if(src in connected?.connected_turbines)
		connected.connected_turbines -= src
	return ..()

/obj/machinery/power/tbg_turbine/update_icon_state()
	if(!connected)
		return
	if(connected.winding_down)
		icon_state = "circ-on25"
		return

	if(connected.buildstate != GENERATOR_NO_DAMAGE)
		icon_state = "circ-weld"
		return

	if(!connected.is_on)
		icon_state = "circ-off"
		return

	switch(connected.power_gen_percent)
		if(0 to 25)
			icon_state = "circ-on25"
		if(25 to 50)
			icon_state = "circ-on50"
		if(50 to 75)
			icon_state = "circ-on75-[icon_type]"
		if(75 to 100)
			icon_state = "circ-on100-[icon_type]"


/obj/machinery/power/tbg_turbine/update_overlays()
	. = ..()
	if(connected?.corrupted)
		. += image(icon, src, "circ_overlay_corrupted", layer)

// Forward all repair/xeno attack actions to the central TBG engine
/obj/machinery/power/tbg_turbine/welder_act(mob/living/user, obj/item/I)
	if(connected)
		connected.welder_act(user, I)

/obj/machinery/power/tbg_turbine/wirecutter_act(mob/living/user, obj/item/I)
	if(connected)
		connected.wirecutter_act(user, I)

/obj/machinery/power/tbg_turbine/wrench_act(mob/living/user, obj/item/I)
	if(connected)
		connected.wrench_act(user, I)

/obj/machinery/power/tbg_turbine/attack_alien(mob/living/carbon/xenomorph/xeno_attacker, damage_amount = xeno_attacker.xeno_caste.melee_damage, damage_type = BRUTE, armor_type = MELEE, effects = TRUE, armor_penetration = xeno_attacker.xeno_caste.melee_ap, isrightclick = FALSE)
	if(connected)
		connected.attack_alien(xeno_attacker, damage_amount,  damage_type, armor_type, effects, armor_penetration, isrightclick)

//Hot/cold turbine sprites have more feedback than the generic turbine
/obj/machinery/power/tbg_turbine/heat
	icon_type = "heat"
	icon_state = "circ-on75-heat"

/obj/machinery/power/tbg_turbine/cold
	icon_type = "cold"
	icon_state = "circ-on75-cold"



#undef GENERATOR_NO_DAMAGE
#undef GENERATOR_LIGHT_DAMAGE
#undef GENERATOR_MEDIUM_DAMAGE
#undef GENERATOR_HEAVY_DAMAGE
