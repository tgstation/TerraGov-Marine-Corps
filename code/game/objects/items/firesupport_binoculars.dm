#define MODE_GUN "gun"
#define MODE_ROCKETS "rockets"
#define MODE_CRS_MSL "cruise"
//#define MODE_SUPPLY "supply"

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
	//var/supply_cooldown = 2 MINUTES
	///Timer for gun run
	var/static/gun_timer
	///Timer for for rocket run
	var/static/rockets_timer
	///Timer for cruise missile strike
	var/static/cruise_timer
	///Timer for supply drop
	//var/static/supply_timer
	///Current mode for support request
	var/mode = MODE_GUN
	///Delay to impact post targeting
	var/delay_to_impact = 4 SECONDS
	w_class = WEIGHT_CLASS_TINY

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
	//	MODE_SUPPLY = image(icon = 'icons/mob/radial.dmi', icon_state = "supply"),
		)

	mode = show_radial_menu(user, src, radial_options, null, 48, null, TRUE, TRUE)
	switch(mode)
		if(MODE_GUN)
			user.balloon_alert(user, "Gun run mode")
		if(MODE_ROCKETS)
			user.balloon_alert(user, "Rocket run mode")
		if(MODE_CRS_MSL)
			user.balloon_alert(user, "Cruise missile mode")
	//	if(MODE_SUPPLY)
	//		user.balloon_alert(user, "Supply drop mode")
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
	//	if(MODE_SUPPLY)
	//		. += span_notice("They are currently set to supply drop mode.")

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
	//else if(mode == MODE_SUPPLY && supply_timer)
	//	balloon_alert_to_viewers("On cooldown.")
	//	return

	var/turf/TU = get_turf(A)
	var/distance = get_dist(TU, get_turf(user))
	var/zoom_screen_size = zoom_tile_offset + zoom_viewsize + 1
	if(TU.z != user.z || distance == -1 || (distance > zoom_screen_size))
		to_chat(user, span_warning("You can't focus properly through \the [src] while looking through something else."))
		return

	if(!user.mind)
		return

	var/area/targ_area = get_area(A)
	if(isspacearea(targ_area))
		to_chat(user, span_warning("Cannot fire into space."))
		return
	if(targ_area.ceiling >= CEILING_UNDERGROUND)
		to_chat(user, span_warning("DEPTH WARNING: Target too deep for ordnance."))
		return
	if(user.do_actions)
		return
	playsound(src, 'sound/effects/nightvision.ogg', 35)
	to_chat(user, span_notice("INITIATING LASER TARGETING. Stand still."))
	var/obj/effect/overlay/temp/laser_target/cas/CS = new (TU)
	laser = CS
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
	//else if(mode == MODE_SUPPLY && supply_timer)
	//	balloon_alert_to_viewers("On cooldown.")
	//	return
	playsound(src, 'sound/effects/binoctarget.ogg', 35)
	switch(mode)
		if(MODE_GUN)
			to_chat(user, span_notice("TARGET ACQUIRED GUN RUN INBOUND."))
			user.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:left valign='top'><u>Garuda-2</u></span><br>" + "Target received, gun run inbound.", /atom/movable/screen/text/screen_text/picture/potrait/pilot)
			playsound(TU, 'sound/effects/dropship_sonic_boom.ogg', 75)
			addtimer(CALLBACK(src, PROC_REF(gun_run), TU), delay_to_impact)
		if(MODE_ROCKETS)
			to_chat(user, span_notice("TARGET ACQUIRED ROCKET RUN INBOUND."))
			user.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:left valign='top'><u>Garuda-2</u></span><br>" + "Rockets hot, incoming!", /atom/movable/screen/text/screen_text/picture/potrait/pilot)
			playsound(TU, 'sound/effects/dropship_sonic_boom.ogg', 75)
			addtimer(CALLBACK(src, PROC_REF(rocket_run), TU), delay_to_impact)
		if(MODE_CRS_MSL)
			to_chat(user, span_notice("TARGET ACQUIRED CRUISE MISSILE INBOUND."))
			user.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:left valign='top'><u>Lt-Manley</u></span><br>" + "Cruise missile programmed, 1 out.", /atom/movable/screen/text/screen_text/picture/potrait)
			playsound(TU, 'sound/weapons/rocket_incoming.ogg', 65)
			addtimer(CALLBACK(src, PROC_REF(cruise_missile), TU), delay_to_impact)
		//if(MODE_SUPPLY)
		//	to_chat(user, span_notice("TARGET ACQUIRED SUPPLY CRATE INBOUND."))
		//	user.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:left valign='top'><u>Lt-Manley</u></span><br>" + "Supply crate sent.", /atom/movable/screen/text/screen_text/picture/potrait)
		//	addtimer(CALLBACK(src, PROC_REF(supply), TU), delay_to_impact)

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
	explosion(T, 5, 5, 6)
	cruise_timer = addtimer(CALLBACK(src, PROC_REF(cruise_clear_timer)), cruise_cooldown)

/obj/item/binoculars/fire_support/proc/cruise_clear_timer()
	cruise_timer = null

//obj/item/binoculars/fire_support/proc/supply(turf/T)
//	QDEL_NULL(laser)
//	new /obj/structure/largecrate/supply/ammo/psy(T)
//	supply_timer = addtimer(CALLBACK(src, PROC_REF(supply_clear_timer)), supply_cooldown)

//obj/item/binoculars/fire_support/proc/supply_clear_timer()
//	supply_timer = null

/obj/item/binoculars/fire_support/proc/acquire_coordinates(atom/A, mob/living/carbon/human/user)
	var/turf/TU = get_turf(A)
	targetturf = TU
	to_chat(user, span_notice("COORDINATES: LONGITUDE [targetturf.x]. LATITUDE [targetturf.y]."))
	playsound(src, 'sound/effects/binoctarget.ogg', 35)

#undef MODE_GUN
#undef MODE_ROCKETS
#undef MODE_CRS_MSL
//#undef MODE_SUPPLY
