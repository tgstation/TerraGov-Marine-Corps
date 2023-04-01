/obj/item/binoculars

	name = "binoculars"
	desc = "A pair of binoculars."
	icon_state = "binoculars"

	flags_atom = CONDUCT
	force = 5.0
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 5.0
	throw_range = 15
	throw_speed = 3
	zoom_tile_offset = 11
	zoom_viewsize = 12


/obj/item/binoculars/attack_self(mob/user)
	if(user.interactee && istype(user.interactee, /obj/machinery/deployable))
		to_chat(user, span_warning("You can't use this right now!"))
		return
	zoom(user)

#define MODE_CAS 0
#define MODE_RAILGUN 1
#define MODE_ORBITAL 2
#define MODE_RANGE_FINDER 3

/obj/item/binoculars/tactical
	name = "tactical binoculars"
	desc = "A pair of binoculars, with a laser targeting function. Unique action to toggle mode. Alt+Click to change selected linked mortar. Ctrl+Click when using to target something. Shift+Click to get coordinates. Ctrl+Shift+Click to fire OB when lasing in OB mode"
	var/laser_cooldown = 0
	var/cooldown_duration = 200 //20 seconds
	var/obj/effect/overlay/temp/laser_target/laser
	var/target_acquisition_delay = 100 //10 seconds
	var/mode = 0  //Able to be switched between modes, 0 for cas laser, 1 for finding coordinates, 2 for directing railgun, 3 for orbital bombardment, 4 for range finding and mortar targeting.
	var/changable = TRUE //If set to FALSE, you can't toggle the mode between CAS and coordinate finding
	var/ob_fired = FALSE // If the user has fired the OB
	var/turf/current_turf // The target turf, used for OBs
	///Last stored turf targetted by rangefinders
	var/turf/targetturf
	///Linked mortar for remote targeting.
	var/list/obj/machinery/deployable/mortar/linked_mortars = list()
	/// Selected mortar index
	var/selected_mortar = 1

/obj/item/binoculars/tactical/Initialize()
	. = ..()
	update_icon()

/obj/item/binoculars/tactical/unique_action(mob/user)
	. = ..()
	toggle_mode(user)
	return TRUE

/obj/item/binoculars/tactical/examine(mob/user)
	. = ..()
	switch(mode)
		if(MODE_CAS)
			. += span_notice("They are currently set to CAS marking mode.")
		if(MODE_RANGE_FINDER)
			. += span_notice("They are currently set to range finding mode.")
		if(MODE_RAILGUN)
			. += span_notice("They are currently set to railgun targeting mode.")
		if(MODE_ORBITAL)
			. += span_notice("They are currently set to orbital bombardment mode.")
	. += span_notice("Use on a mortar to link it for remote targeting.")
	if(length(linked_mortars))
		. += span_notice("They are currently linked to [length(linked_mortars)] mortar(s).")
		. += span_notice("They are currently set to mortar [selected_mortar].")
		return
	. += span_notice("They are not linked to a mortar.")

/obj/item/binoculars/tactical/Destroy()
	if(laser)
		QDEL_NULL(laser)
	return ..()


/obj/item/binoculars/tactical/InterceptClickOn(mob/user, params, atom/object)
	var/list/pa = params2list(params)
	if(!pa.Find("ctrl") && pa.Find("shift"))
		acquire_coordinates(object, user)
		return TRUE

	if(pa.Find("ctrl") && !pa.Find("shift"))
		acquire_target(object, user)
		return TRUE

	if(pa.Find("ctrl") && pa.Find("shift"))
		try_fire_ob(object, user)
		return TRUE

	return FALSE

/obj/item/binoculars/tactical/onzoom(mob/living/user)
	. = ..()
	user.reset_perspective(src)
	user.update_sight()
	user.client.click_intercept = src

/obj/item/binoculars/tactical/onunzoom(mob/living/user)
	. = ..()

	QDEL_NULL(laser)

	if(!user?.client)
		return

	user.client.click_intercept = null
	user.reset_perspective(user)
	user.update_sight()


/obj/item/binoculars/tactical/update_remote_sight(mob/living/user)
	user.see_in_dark = 32 // Should include the offset from zoom and client viewport
	user.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	user.sync_lighting_plane_alpha()
	return TRUE


/obj/item/binoculars/tactical/update_overlays()
	. = ..()
	if(mode)
		. += "binoculars_range"
	else
		. += "binoculars_laser"

/// Proc that when called checks if the selected mortar isnt out of list bounds and if it is, resets to 1
/obj/item/binoculars/tactical/proc/check_mortar_index()
	if(!linked_mortars)
		return
	if(!length(linked_mortars))
		selected_mortar = 1 // set back to default but it still wont fire because no mortars and thats good
		return
	if(selected_mortar > length(linked_mortars))
		selected_mortar = 1

/obj/item/binoculars/tactical/AltClick(mob/user)
	. = ..()
	if(!length(linked_mortars))
		return
	selected_mortar += 1
	check_mortar_index()
	var/obj/mortar = linked_mortars[selected_mortar]
	to_chat(user, span_notice("NOW SENDING COORDINATES TO MORTAR [selected_mortar] AT: LONGITUDE [mortar.x]. LATITUDE [mortar.y]."))

/obj/item/binoculars/tactical/verb/toggle_mode(mob/user)
	set category = "Object"
	set name = "Toggle Laser Mode"
	if(!user && isliving(loc))
		user = loc
	if (laser)
		to_chat(user, "<span class='warning'>You can't switch mode while targeting")
		return
	if(!changable)
		to_chat(user, "These binoculars only have one mode.")
		return
	mode += 1
	if(mode > MODE_RANGE_FINDER)
		mode = MODE_CAS
	switch(mode)
		if(MODE_CAS)
			to_chat(user, span_notice("You switch [src] to CAS marking mode."))
		if(MODE_RAILGUN)
			to_chat(user, span_notice("You switch [src] to railgun targeting mode."))
		if(MODE_ORBITAL)
			to_chat(user, span_notice("You switch [src] to orbital bombardment targeting mode."))
		if(MODE_RANGE_FINDER)
			to_chat(user, span_notice("You switch [src] to range finding mode."))
	update_icon()
	playsound(user, 'sound/items/binoculars.ogg', 15, 1)

/obj/item/binoculars/tactical/proc/acquire_coordinates(atom/A, mob/living/carbon/human/user)
	var/turf/TU = get_turf(A)
	targetturf = TU
	to_chat(user, span_notice("COORDINATES: LONGITUDE [targetturf.x]. LATITUDE [targetturf.y]."))
	playsound(src, 'sound/effects/binoctarget.ogg', 35)

/obj/item/binoculars/tactical/proc/acquire_target(atom/A, mob/living/carbon/human/user)
	set waitfor = 0

	if(laser)
		to_chat(user, span_warning("You're already targeting something."))
		return

	if(world.time < laser_cooldown)
		to_chat(user, span_warning("[src]'s laser battery is recharging."))
		return

	var/turf/TU = get_turf(A)
	var/distance = get_dist(TU, get_turf(user))
	var/zoom_screen_size = zoom_tile_offset + zoom_viewsize + 1
	if(TU.z != user.z || distance == -1 || (distance > zoom_screen_size))
		to_chat(user, span_warning("You can't focus properly through \the [src] while looking through something else."))
		return


	if(!user.mind)
		return
	var/datum/squad/S = user.assigned_squad

	var/laz_name = ""
	laz_name += user.get_paygrade()
	laz_name += user.name
	if(S)
		laz_name += " ([S.name])"


	var/area/targ_area = get_area(A)
	if(!istype(TU))
		return
	var/is_outside = FALSE
	if(is_ground_level(TU.z))
		switch(targ_area.ceiling)
			if(CEILING_NONE)
				is_outside = TRUE
			if(CEILING_GLASS)
				is_outside = TRUE
			if(CEILING_METAL)
				is_outside = TRUE
	if(!is_outside)
		to_chat(user, span_warning("DEPTH WARNING: Target too deep for ordnance."))
		return
	if(user.do_actions)
		return
	playsound(src, 'sound/effects/nightvision.ogg', 35)
	if(mode != MODE_RANGE_FINDER)
		to_chat(user, span_notice("INITIATING LASER TARGETING. Stand still."))
		if(!do_after(user, max(1.5 SECONDS, target_acquisition_delay - (2.5 SECONDS * user.skills.getRating(SKILL_LEADERSHIP))), TRUE, TU, BUSY_ICON_GENERIC) || world.time < laser_cooldown || laser)
			return
	if(targ_area.flags_area & OB_CAS_IMMUNE)
		to_chat(user, span_warning("Our payload won't reach this target!"))
		return
	switch(mode)
		if(MODE_CAS)
			to_chat(user, span_notice("TARGET ACQUIRED. LASER TARGETING IS ONLINE. DON'T MOVE."))
			var/obj/effect/overlay/temp/laser_target/cas/CS = new (TU, 0, laz_name, S)
			laser = CS
			playsound(src, 'sound/effects/binoctarget.ogg', 35)
			while(laser)
				if(!do_after(user, 5 SECONDS, TRUE, laser, BUSY_ICON_GENERIC))
					QDEL_NULL(laser)
					break
		if(MODE_RANGE_FINDER)
			if(!length(linked_mortars))
				to_chat(user, span_notice("No linked mortars found."))
				return
			check_mortar_index() // incase varedit screws something up
			targetturf = TU
			to_chat(user, span_notice("COORDINATES TARGETED BY MORTAR [selected_mortar]: LONGITUDE [targetturf.x]. LATITUDE [targetturf.y]."))
			playsound(src, 'sound/effects/binoctarget.ogg', 35)
			var/obj/machinery/deployable/mortar/mortar = linked_mortars[selected_mortar]
			mortar.recieve_target(TU,user)
			return
		if(MODE_RAILGUN)
			to_chat(user, span_notice("ACQUIRING TARGET. RAILGUN TRIANGULATING. DON'T MOVE."))
			if((GLOB.marine_main_ship?.rail_gun?.last_firing + 300 SECONDS) > world.time)
				to_chat(user, "[icon2html(src, user)] [span_warning("The Rail Gun hasn't cooled down yet!")]")
			else if(!targ_area)
				to_chat(user, "[icon2html(src, user)] [span_warning("No target detected!")]")
			else
				var/obj/effect/overlay/temp/laser_target/RGL = new (TU, 0, laz_name, S)
				laser = RGL
				playsound(src, 'sound/effects/binoctarget.ogg', 35)
				if(!do_after(user, 2 SECONDS, TRUE, user, BUSY_ICON_GENERIC))
					QDEL_NULL(laser)
					return
				to_chat(user, span_notice("TARGET ACQUIRED. RAILGUN IS FIRING. DON'T MOVE."))
				while(laser)
					GLOB.marine_main_ship?.rail_gun?.fire_rail_gun(TU,user)
					if(!do_after(user, 3 SECONDS, TRUE, laser, BUSY_ICON_GENERIC))
						QDEL_NULL(laser)
						break
		if(MODE_ORBITAL)
			to_chat(user, span_notice("ACQUIRING TARGET. ORBITAL CANNON TRIANGULATING. DON'T MOVE."))
			if(!targ_area)
				to_chat(user, "[icon2html(src, user)] [span_warning("No target detected!")]")
			else
				var/obj/effect/overlay/temp/laser_target/OB/OBL = new (TU, 0, laz_name, S)
				laser = OBL
				playsound(src, 'sound/effects/binoctarget.ogg', 35)
				if(!do_after(user, 15 SECONDS, TRUE, user, BUSY_ICON_GENERIC))
					QDEL_NULL(laser)
					return
				to_chat(user, span_notice("TARGET ACQUIRED. ORBITAL CANNON IS READY TO FIRE."))
				// Wait for that ALT click to fire
				current_turf = TU
				ob_fired = FALSE // Reset the fired state
				while(laser && !ob_fired)
					if(!do_after(user, 5 SECONDS, TRUE, laser, BUSY_ICON_GENERIC))
						QDEL_NULL(laser)
						break
				current_turf = null

/obj/item/binoculars/tactical/proc/try_fire_ob(atom/A, mob/living/carbon/human/user)
	if(mode != MODE_ORBITAL)
		return
	if(A != laser || !current_turf)
		return // Gotta click on a laser target
	ob_fired = TRUE
	var/x_offset = rand(-2,2) //Little bit of randomness.
	var/y_offset = rand(-2,2)
	var/turf/target = locate(current_turf.x + x_offset,current_turf.y + y_offset,current_turf.z)
	GLOB.marine_main_ship?.orbital_cannon?.fire_ob_cannon(target, user)
	var/warhead_type = GLOB.marine_main_ship.orbital_cannon.tray.warhead.name
	for(var/mob/living/silicon/ai/AI AS in GLOB.ai_list)
		to_chat(AI, span_warning("NOTICE - Orbital bombardment triggered by ground operator. Warhead type: [warhead_type]. Target: [AREACOORD_NO_Z(current_turf)]"))
		playsound(AI,'sound/machines/triple_beep.ogg', 25, 1, 20)
	to_chat(user, span_notice("FIRING REQUEST RECIEVED. CLEAR TARGET AREA"))
	log_attack("[key_name(user)] fired a [warhead_type] in [AREACOORD(current_turf)].")
	message_admins("[ADMIN_TPMONTY(user)] fired a [warhead_type] in [ADMIN_VERBOSEJMP(current_turf)].")
	QDEL_NULL(laser)

///Sets or unsets the binocs linked mortar.
/obj/item/binoculars/tactical/proc/set_mortar(mortar)
	if(mortar in linked_mortars)
		UnregisterSignal(mortar, COMSIG_PARENT_QDELETING)
		linked_mortars -= mortar
		return FALSE
	linked_mortars += mortar
	RegisterSignal(mortar, COMSIG_PARENT_QDELETING, PROC_REF(clean_refs))
	return TRUE

///Proc called when linked_mortar is deleted.
/obj/item/binoculars/tactical/proc/clean_refs(datum/source)
	SIGNAL_HANDLER
	linked_mortars -= source
	check_mortar_index()
	say("NOTICE: connection lost with linked mortar.")

/obj/item/binoculars/tactical/scout
	name = "scout tactical binoculars"
	desc = "A modified version of tactical binoculars with an advanced laser targeting function. Ctrl+Click to target something."
	cooldown_duration = 80
	target_acquisition_delay = 30

//For events
/obj/item/binoculars/tactical/range
	name = "range-finder"
	desc = "A pair of binoculars designed to find coordinates. Shift+Click or Ctrl+Click to get coordinates when using."
	changable = 0
	mode = MODE_RANGE_FINDER

#undef MODE_CAS
#undef MODE_RANGE_FINDER
#undef MODE_RAILGUN
#undef MODE_ORBITAL

#define MODE_GUN "gun"
#define MODE_ROCKETS "rockets"
#define MODE_CRS_MSL "cruise"
#define MODE_SUPPLY "supply"

/obj/item/binoculars/fire_support
	name = "tactical binoculars"
	desc = "A pair of binoculars, used to mark targets for airstrikes and cruise missiles. Unique action to toggle mode. Ctrl+Click when using to target something."
	var/obj/effect/overlay/temp/laser_target/laser
	var/target_acquisition_delay = 5 SECONDS
	///Last stored turf targetted by rangefinders
	var/turf/targetturf
	///Cooldown for gun run
	var/gun_cooldown = 3 MINUTES
	///Cooldown for rocket run
	var/rockets_cooldown = 3 MINUTES
	///Cooldown for cruise missile strike
	var/cruise_cooldown = 3 MINUTES
	///Cooldown for supply drop
	var/supply_cooldown = 2 MINUTES
	///Timer for gun run
	var/static/gun_timer
	///Timer for for rocket run
	var/static/rockets_timer
	///Timer for cruise missile strike
	var/static/cruise_timer
	///Timer for supply drop
	var/static/supply_timer
	///Current mode for support request
	var/mode = MODE_GUN
	///Delay to impact post targeting
	var/delay_to_impact = 4 SECONDS

/obj/item/binoculars/fire_support/Initialize()
	. = ..()
	update_icon()

/obj/item/binoculars/fire_support/unique_action(mob/user)
	. = ..()
	select_radial(user)
	return TRUE

/obj/item/binoculars/fire_support/proc/select_radial(mob/user)
	if(user.get_active_held_item() != src)
		return
	if(!can_interact(user))
		return TRUE

	var/list/radial_options = list(
		MODE_GUN = image(icon = 'icons/mob/radial.dmi', icon_state = "gau"),
		MODE_ROCKETS = image(icon = 'icons/mob/radial.dmi', icon_state = "rockets"),
		MODE_CRS_MSL = image(icon = 'icons/mob/radial.dmi', icon_state = "cruise"),
		MODE_SUPPLY = image(icon = 'icons/mob/radial.dmi', icon_state = "supply"),
		)

	mode = show_radial_menu(user, src, radial_options, null, 48, null, TRUE, TRUE)
	switch(mode)
		if(MODE_GUN)
			user.balloon_alert(user, "Gun run mode")
		if(MODE_ROCKETS)
			user.balloon_alert(user, "Rocket run mode")
		if(MODE_CRS_MSL)
			user.balloon_alert(user, "Cruise missile mode")
		if(MODE_SUPPLY)
			user.balloon_alert(user, "Supply drop mode")
	update_icon()

/obj/item/binoculars/fire_support/examine(mob/user)
	. = ..()
	switch(mode)
		if(MODE_GUN)
			. += span_notice("They are currently set to gun run marking mode.")
		if(MODE_ROCKETS)
			. += span_notice("They are currently set to rocket targeting mode.")
		if(MODE_CRS_MSL)
			. += span_notice("They are currently set to cruise missile targeting mode.")
		if(MODE_SUPPLY)
			. += span_notice("They are currently set to supply drop mode.")

/obj/item/binoculars/fire_support/Destroy()
	if(laser)
		QDEL_NULL(laser)
	return ..()


/obj/item/binoculars/fire_support/InterceptClickOn(mob/user, params, atom/object)
	var/list/pa = params2list(params)
	if(!pa.Find("ctrl") && pa.Find("shift"))
		acquire_coordinates(object, user)
		return TRUE

	if(pa.Find("ctrl") && !pa.Find("shift"))
		acquire_target(object, user)
		return TRUE

	return FALSE

/obj/item/binoculars/fire_support/onzoom(mob/living/user)
	. = ..()
	user.reset_perspective(src)
	user.update_sight()
	user.client.click_intercept = src

/obj/item/binoculars/fire_support/onunzoom(mob/living/user)
	. = ..()

	QDEL_NULL(laser)

	if(!user?.client)
		return

	user.client.click_intercept = null
	user.reset_perspective(user)
	user.update_sight()


/obj/item/binoculars/fire_support/update_remote_sight(mob/living/user)
	user.see_in_dark = 32 // Should include the offset from zoom and client viewport
	user.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	user.sync_lighting_plane_alpha()
	return TRUE

/obj/item/binoculars/fire_support/update_overlays()
	. = ..()
	if(mode)
		. += "binoculars_range"
	else
		. += "binoculars_laser"

/obj/item/binoculars/fire_support/proc/acquire_target(atom/A, mob/living/carbon/human/user)
	set waitfor = 0

	if(laser)
		to_chat(user, span_warning("You're already targeting something."))
		return

	if(!mode)
		balloon_alert_to_viewers("Select a mode!")
		return
	else if(mode == MODE_GUN && gun_timer)
		balloon_alert_to_viewers("On cooldown.")
		return
	else if(mode == MODE_ROCKETS && rockets_timer)
		balloon_alert_to_viewers("On cooldown.")
		return
	else if(mode == MODE_CRS_MSL && cruise_timer)
		balloon_alert_to_viewers("On cooldown.")
		return
	else if(mode == MODE_SUPPLY && supply_timer)
		balloon_alert_to_viewers("On cooldown.")
		return

	var/turf/TU = get_turf(A)
	var/distance = get_dist(TU, get_turf(user))
	var/zoom_screen_size = zoom_tile_offset + zoom_viewsize + 1
	if(TU.z != user.z || distance == -1 || (distance > zoom_screen_size))
		to_chat(user, span_warning("You can't focus properly through \the [src] while looking through something else."))
		return

	if(!user.mind)
		return

	var/area/targ_area = get_area(A)
	if(!istype(TU))
		return
	var/is_outside = FALSE
	if(is_ground_level(TU.z))
		switch(targ_area.ceiling)
			if(CEILING_NONE)
				is_outside = TRUE
			if(CEILING_GLASS)
				is_outside = TRUE
			if(CEILING_METAL)
				is_outside = TRUE
	if(!is_outside)
		to_chat(user, span_warning("DEPTH WARNING: Target too deep for ordnance."))
		return
	if(user.do_actions)
		return
	playsound(src, 'sound/effects/nightvision.ogg', 35)
	to_chat(user, span_notice("INITIATING LASER TARGETING. Stand still."))
	if(!do_after(user, target_acquisition_delay, TRUE, user, BUSY_ICON_HOSTILE))
		return
	if(!mode)
		balloon_alert_to_viewers("Select a mode!")
		return
	else if(mode == MODE_GUN && gun_timer)
		balloon_alert_to_viewers("On cooldown.")
		return
	else if(mode == MODE_ROCKETS && rockets_timer)
		balloon_alert_to_viewers("On cooldown.")
		return
	else if(mode == MODE_CRS_MSL && cruise_timer)
		balloon_alert_to_viewers("On cooldown.")
		return
	else if(mode == MODE_SUPPLY && supply_timer)
		balloon_alert_to_viewers("On cooldown.")
		return
	playsound(src, 'sound/effects/binoctarget.ogg', 35)
	switch(mode)
		if(MODE_GUN)
			to_chat(user, span_notice("TARGET ACQUIRED GUN RUN INBOUND."))
			user.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:left valign='top'><u>Garuda-2</u></span><br>" + "Target received, gun run inbound.", /atom/movable/screen/text/screen_text/picture/potrait/pilot)
			var/obj/effect/overlay/temp/laser_target/cas/CS = new (TU, delay_to_impact)
			laser = CS
			playsound(TU, 'sound/effects/dropship_sonic_boom.ogg', 75)
			addtimer(CALLBACK(src, PROC_REF(gun_run), TU), delay_to_impact)
		if(MODE_ROCKETS)
			to_chat(user, span_notice("TARGET ACQUIRED ROCKET RUN INBOUND."))
			user.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:left valign='top'><u>Garuda-2</u></span><br>" + "Rockets hot, incoming!", /atom/movable/screen/text/screen_text/picture/potrait/pilot)
			var/obj/effect/overlay/temp/laser_target/cas/CS = new (TU, delay_to_impact)
			laser = CS
			playsound(TU, 'sound/effects/dropship_sonic_boom.ogg', 75)
			addtimer(CALLBACK(src, PROC_REF(rocket_run), TU), delay_to_impact)
		if(MODE_CRS_MSL)
			to_chat(user, span_notice("TARGET ACQUIRED CRUISE MISSILE INBOUND."))
			user.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:left valign='top'><u>Lt-Manley</u></span><br>" + "Cruise missile programmed, 1 out.", /atom/movable/screen/text/screen_text/picture/potrait/lt)
			var/obj/effect/overlay/temp/laser_target/cas/CS = new (TU, delay_to_impact)
			laser = CS
			playsound(TU, 'sound/weapons/rocket_incoming.ogg', 65)
			addtimer(CALLBACK(src, PROC_REF(cruise_missile), TU), delay_to_impact)
		if(MODE_SUPPLY)
			to_chat(user, span_notice("TARGET ACQUIRED SUPPLY CRATE INBOUND."))
			user.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:left valign='top'><u>Lt-Manley</u></span><br>" + "Supply crate sent.", /atom/movable/screen/text/screen_text/picture/potrait/lt)
			var/obj/effect/overlay/temp/laser_target/cas/CS = new (TU, delay_to_impact)
			laser = CS
			addtimer(CALLBACK(src, PROC_REF(supply), TU), delay_to_impact)

/obj/item/binoculars/fire_support/proc/gun_run(turf/T, attackdir = NORTH)
	QDEL_NULL(laser)
	var/list/turf_list = list()
	for(var/turf/spread_turf in RANGE_TURFS(3, T))
		turf_list += spread_turf
	for(var/i = 1 to 5)
		var/turf/impact_turf = pick(turf_list)
		addtimer(CALLBACK(src, PROC_REF(gun_run_fire), impact_turf), 0.15 SECONDS * i)
	new /obj/effect/temp_visual/dropship_flyby(T)
	playsound(T, 'sound/effects/casplane_flyby.ogg', 40)
	gun_timer = addtimer(CALLBACK(src, PROC_REF(gun_clear_timer)), gun_cooldown)

/obj/item/binoculars/fire_support/proc/gun_run_fire(turf/T)
	strafe_turfs(get_turfs_to_impact(T))

/obj/item/binoculars/fire_support/proc/get_turfs_to_impact(turf/impact)
	var/turf/beginning = impact
	var/revdir = REVERSE_DIR(NORTH)
	for(var/i=0 to 2)
		beginning = get_step(beginning, revdir)
	var/list/strafelist = list(beginning)
	strafelist += get_step(beginning, turn(NORTH, 90))
	strafelist += get_step(beginning, turn(NORTH, -90)) //Build this list 3 turfs at a time for strafe_turfs
	for(var/b=0 to 2*2)
		beginning = get_step(beginning, NORTH)
		strafelist += beginning
		strafelist += get_step(beginning, turn(NORTH, 90))
		strafelist += get_step(beginning, turn(NORTH, -90))

	return strafelist

///Takes the top 3 turfs and miniguns them, then repeats until none left
/obj/item/binoculars/fire_support/proc/strafe_turfs(list/strafelist)
	var/turf/strafed
	playsound(strafelist[1], 'sound/weapons/gauimpact.ogg', 40, 1, 20, falloff = 3)
	for(var/i=1 to 3)
		strafed = strafelist[1]
		strafelist -= strafed
		strafed.ex_act(EXPLODE_HEAVY)
		new /obj/effect/particle_effect/expl_particles(strafed)
		new /obj/effect/temp_visual/heavyimpact(strafed)
		for(var/atom/movable/AM AS in strafed)
			AM.ex_act(EXPLODE_HEAVY)

	if(length(strafelist))
		addtimer(CALLBACK(src, PROC_REF(strafe_turfs), strafelist), 2)

/obj/item/binoculars/fire_support/proc/gun_clear_timer()
	gun_timer = null

/obj/item/binoculars/fire_support/proc/rocket_run(turf/T)
	QDEL_NULL(laser)
	new /obj/effect/temp_visual/dropship_flyby(T)
	var/list/turf_list = list()
	for(var/turf/spread_turf in RANGE_TURFS(5, T))
		turf_list += spread_turf
	for(var/i = 1 to 15)
		var/turf/impact_turf = pick(turf_list)
		addtimer(CALLBACK(src, PROC_REF(rocket_run_fire), impact_turf), 0.15 SECONDS * i)
	rockets_timer = addtimer(CALLBACK(src, PROC_REF(rocket_clear_timer)), rockets_cooldown)

/obj/item/binoculars/fire_support/proc/rocket_run_fire(turf/T)
	explosion(T, 0, 2, 5, 3)

/obj/item/binoculars/fire_support/proc/rocket_clear_timer()
	rockets_timer = null

/obj/item/binoculars/fire_support/proc/cruise_missile(turf/T)
	QDEL_NULL(laser)
	explosion(T, 5)
	cruise_timer = addtimer(CALLBACK(src, PROC_REF(cruise_clear_timer)), cruise_cooldown)

/obj/item/binoculars/fire_support/proc/cruise_clear_timer()
	cruise_timer = null

/obj/item/binoculars/fire_support/proc/supply(turf/T)
	QDEL_NULL(laser)
	new /obj/structure/largecrate/supply/ammo/uscm(T)
	supply_timer = addtimer(CALLBACK(src, PROC_REF(supply_clear_timer)), supply_cooldown)

/obj/item/binoculars/fire_support/proc/supply_clear_timer()
	supply_timer = null

/obj/item/binoculars/fire_support/proc/acquire_coordinates(atom/A, mob/living/carbon/human/user)
	var/turf/TU = get_turf(A)
	targetturf = TU
	to_chat(user, span_notice("COORDINATES: LONGITUDE [targetturf.x]. LATITUDE [targetturf.y]."))
	playsound(src, 'sound/effects/binoctarget.ogg', 35)

#undef MODE_GUN
#undef MODE_ROCKETS
#undef MODE_CRS_MSL
#undef MODE_SUPPLY
