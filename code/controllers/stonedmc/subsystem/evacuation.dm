SUBSYSTEM_DEF(evacuation)
	name = "Evacuation"
	flags = SS_NO_INIT|SS_TICKER

	var/list/pod_list = list()
	var/pod_cooldown
	var/evac_time
	var/evac_status = EVACUATION_STATUS_STANDING_BY

	var/obj/machinery/self_destruct/console/dest_master
	var/dest_rods[]
	var/dest_cooldown
	var/dest_index = 1
	var/dest_status = NUKE_EXPLOSION_INACTIVE

	var/flags_scuttle = FLAGS_SDEVAC_TIMELOCK


/datum/controller/subsystem/evacuation/proc/prepare()
	dest_master = locate()
	if(!dest_master)
		stack_trace("SSevacuation: Could not find dest_master.")
		return FALSE
	dest_rods = new
	for(var/obj/machinery/self_destruct/rod/I in dest_master.loc.loc)
		dest_rods += I
	if(!length(dest_rods))
		stack_trace("SSevacuation: Could not find any dest_rods.")
		qdel(dest_master)
		dest_master = null
		return FALSE

	dest_cooldown = SELF_DESTRUCT_ROD_STARTUP_TIME / length(dest_rods)
	dest_master.desc = "The main operating panel for a self-destruct system. It requires very little user input, but the final safety mechanism is manually unlocked.\nAfter the initial start-up sequence, [dest_rods.len] control rods must be armed, followed by manually flipping the detonation switch."


/datum/controller/subsystem/evacuation/fire()
	switch(evac_status)
		if(EVACUATION_STATUS_INITIATING)
			if(world.time < evac_time + EVACUATION_AUTOMATIC_DEPARTURE)
				return
			evac_status = EVACUATION_STATUS_IN_PROGRESS
		if(EVACUATION_STATUS_IN_PROGRESS)
			if(world.time < pod_cooldown + EVACUATION_POD_LAUNCH_COOLDOWN)
				return
			if(!length(pod_list)) // none left to pick from to evac
				if(!length(SSshuttle.escape_pods)) // no valid pods left, all have launched/exploded
					announce_evac_completion()
				return
			var/obj/docking_port/mobile/escape_pod/P = pick_n_take(pod_list)
			P.launch()

	switch(dest_status)
		if(NUKE_EXPLOSION_ACTIVE)
			if(!dest_master.loc || dest_master.active_state != SELF_DESTRUCT_MACHINE_ARMED || dest_index > length(dest_rods))
				return

			var/obj/machinery/self_destruct/rod/I = dest_rods[dest_index]
			if(world.time < dest_cooldown + I.activate_time)
				return

			I.toggle()

			if(++dest_index > length(dest_rods))
				return

			I = dest_rods[dest_index]
			I.activate_time = world.time



/datum/controller/subsystem/evacuation/proc/initiate_evacuation(override)
	if(evac_status != EVACUATION_STATUS_STANDING_BY)
		return FALSE
	if(!override && flags_scuttle & (FLAGS_EVACUATION_DENY|FLAGS_SDEVAC_TIMELOCK))
		return FALSE
	GLOB.enter_allowed = FALSE
	evac_time = world.time
	evac_status = EVACUATION_STATUS_INITIATING
	priority_announce("Emergency evacuation has been triggered. Please proceed to the escape pods.", "Priority Alert", sound = 'sound/AI/evacuate.ogg')
	xeno_message("A wave of adrenaline ripples through the hive. The fleshy creatures are trying to escape!")
	pod_list = SSshuttle.escape_pods.Copy()
	for(var/i in pod_list)
		var/obj/docking_port/mobile/escape_pod/P = i
		P.prep_for_launch()
	return TRUE


/datum/controller/subsystem/evacuation/proc/begin_launch()
	if(evac_status != EVACUATION_STATUS_INITIATING)
		return FALSE
	evac_status = EVACUATION_STATUS_IN_PROGRESS
	priority_announce("WARNING: Evacuation order confirmed. Launching escape pods.", "Priority Alert", sound = 'sound/AI/evacuation_confirmed.ogg')
	return TRUE


/datum/controller/subsystem/evacuation/proc/cancel_evacuation()
	if(evac_status != EVACUATION_STATUS_INITIATING)
		return FALSE
	GLOB.enter_allowed = TRUE
	evac_time = null
	evac_status = EVACUATION_STATUS_STANDING_BY
	priority_announce("Evacuation has been cancelled.", "Priority Alert", sound = 'sound/AI/evacuate_cancelled.ogg')
	for(var/i in pod_list)
		var/obj/docking_port/mobile/escape_pod/P = i
		P.unprep_for_launch()
	return TRUE


/datum/controller/subsystem/evacuation/proc/get_status_panel_eta()
	switch(evac_status)
		if(EVACUATION_STATUS_INITIATING)
			var/eta = EVACUATION_ESTIMATE_DEPARTURE
			. = "[(eta / 60) % 60]:[add_zero(num2text(eta % 60), 2)]"
		if(EVACUATION_STATUS_IN_PROGRESS)
			. = "NOW"

/datum/controller/subsystem/evacuation/proc/announce_evac_completion()
	priority_announce("ATTENTION: Evacuation complete.", "Priority Alert", sound = 'sound/AI/evacuation_complete.ogg')
	evac_status = EVACUATION_STATUS_COMPLETE


/datum/controller/subsystem/evacuation/proc/enable_self_destruct(override)
	if(dest_status != NUKE_EXPLOSION_INACTIVE)
		return FALSE
	if(!override && flags_scuttle & (FLAGS_SELF_DESTRUCT_DENY|FLAGS_SDEVAC_TIMELOCK))
		return FALSE
	dest_status = NUKE_EXPLOSION_ACTIVE
	dest_master.toggle()
	set_security_level(SEC_LEVEL_DELTA)
	return TRUE


/datum/controller/subsystem/evacuation/proc/cancel_self_destruct(override)
	if(dest_status != NUKE_EXPLOSION_ACTIVE)
		return FALSE
	var/obj/machinery/self_destruct/rod/I
	var/i
	for(i in SSevacuation.dest_rods)
		I = i
		if(I.active_state == SELF_DESTRUCT_MACHINE_ARMED && !override)
			dest_master.visible_message("<span class='warning'>WARNING: Unable to cancel detonation. Please disarm all control rods.</span>")
			return FALSE

	dest_status = NUKE_EXPLOSION_INACTIVE
	for(i in dest_rods)
		I = i
		if(I.active_state == SELF_DESTRUCT_MACHINE_ACTIVE || (I.active_state == SELF_DESTRUCT_MACHINE_ARMED && override)) 
			I.toggle(TRUE)
	dest_master.toggle(TRUE)
	dest_index = 1
	priority_announce("The emergency destruct system has been deactivated.", "Priority Alert", sound = 'sound/AI/selfdestruct_deactivated.ogg')
	if(evac_status == EVACUATION_STATUS_STANDING_BY)
		set_security_level(SEC_LEVEL_RED, TRUE)
	return TRUE


/datum/controller/subsystem/evacuation/proc/initiate_self_destruct(override)
	if(dest_status >= NUKE_EXPLOSION_IN_PROGRESS)
		return FALSE

	var/obj/machinery/self_destruct/rod/I
	for(var/i in dest_rods)
		I = i
		if(I.active_state != SELF_DESTRUCT_MACHINE_ARMED && !override)
			dest_master.visible_message("<span class='warning'>WARNING: Unable to trigger detonation. Please arm all control rods.</span>")
			return FALSE
	
	priority_announce("DANGER. DANGER. Self destruct system activated. DANGER. DANGER. Self destruct in progress. DANGER. DANGER.", "Priority Alert")
	GLOB.enter_allowed = FALSE
	dest_status = NUKE_EXPLOSION_IN_PROGRESS
	playsound(dest_master, 'sound/machines/alarm.ogg', 75, 0, 30)
	SEND_SOUND(world, pick('sound/theme/nuclear_detonation1.ogg','sound/theme/nuclear_detonation2.ogg'))

	var/list/z_levels = list(SSmapping.levels_by_trait(ZTRAIT_MARINE_MAIN_SHIP))
	var/ship_intact = TRUE

	var/f = SSmapping.levels_by_trait(ZTRAIT_MARINE_MAIN_SHIP)
	if(f in z_levels)
		ship_intact = FALSE

	for(var/x in GLOB.player_list)
		var/mob/M = x
		if(isobserver(M))
			continue
		shake_camera(M, 110, 4)

	addtimer(CALLBACK(src, .proc/show_cinematic, override, ship_intact), 10 SECONDS)


/datum/controller/subsystem/evacuation/proc/show_cinematic(override, ship_intact)
	var/obj/screen/cinematic/explosion/E = new

	for(var/x in GLOB.clients)
		var/client/C = x
		C.screen += E
		C.change_view(world.view)

	addtimer(CALLBACK(src, .proc/flick_cinematic, E, override, ship_intact), 1.5 SECONDS)


/datum/controller/subsystem/evacuation/proc/flick_cinematic(obj/screen/cinematic/explosion/E, override, ship_intact)
	flick(override ? "intro_override" : "intro_nuke", E)
	flick(ship_intact ? "ship_spared" : "ship_destroyed", E)
	SEND_SOUND(world, 'sound/effects/explosionfar.ogg')
	E.icon_state = ship_intact ? "summary_spared" : "summary_destroyed"

	dest_status = NUKE_EXPLOSION_FINISHED

	addtimer(CALLBACK(src, .proc/remove_cinematic, E), 10 SECONDS)


/datum/controller/subsystem/evacuation/proc/remove_cinematic(obj/screen/cinematic/explosion/E)
	for(var/x in GLOB.clients)
		var/client/C = x
		C.screen -= E


/datum/controller/subsystem/evacuation/proc/get_affected_zlevels()
	if(dest_status >= NUKE_EXPLOSION_IN_PROGRESS || evac_status != EVACUATION_STATUS_COMPLETE)
		return
	. = SSmapping.levels_by_any_trait(list(ZTRAIT_MARINE_MAIN_SHIP, ZTRAIT_LOW_ORBIT))