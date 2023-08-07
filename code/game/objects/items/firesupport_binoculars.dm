#define MODE_GUN "gun"
#define MODE_ROCKETS "rockets"
#define MODE_CRS_MSL "cruise"

GLOBAL_LIST_INIT(fire_support_types, list(
	MODE_GUN = new /datum/fire_support/gau,
	MODE_ROCKETS = new /datum/fire_support/rockets,
	MODE_CRS_MSL = new /datum/fire_support/cruise_missile,
	))

/datum/fire_support
	var/name = "misc firesupport"
	var/icon_state
	var/fire_support_type
	var/fire_support_flags
	var/cooldown_duration = 60 SECONDS
	var/cooldown_timer
	var/uses = -1
	var/scatter_range = 6
	var/impact_quantity = 1

	var/initiate_chat_message = "TARGET ACQUIRED. FIRE SUPPORT INBOUND."
	var/initiate_screen_message = "fire support inbound."
	var/initiate_title = "Garuda-2"
	var/initiate_sound = 'sound/effects/dropship_sonic_boom.ogg'
	var/delay_to_impact = 4 SECONDS
	var/atom/movable/screen/text/screen_text/picture/portrait_type = /atom/movable/screen/text/screen_text/picture/potrait/pilot

	var/obj/effect/temp_visual/start_visual = /obj/effect/temp_visual/dropship_flyby
	var/start_sound = 'sound/effects/casplane_flyby.ogg'

/datum/fire_support/proc/initiate_fire_support(turf/target_turf, mob/user)
	if(!uses)
		to_chat(user, span_notice("FIRE SUPPORT UNAVAILABLE"))
		return
	uses --
	addtimer(CALLBACK(src, PROC_REF(start_fire_support), target_turf), delay_to_impact)

	if(initiate_sound)
		playsound(target_turf, initiate_sound, 100)
	if(initiate_chat_message)
		to_chat(user, span_notice(initiate_chat_message))
	if(portrait_type && initiate_screen_message && initiate_title)
		user.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:left valign='top'><u>[initiate_title]</u></span><br>" + initiate_screen_message, portrait_type)

/datum/fire_support/proc/start_fire_support(turf/target_turf, attackdir = NORTH)
	cooldown_timer = addtimer(VARSET_CALLBACK(src, cooldown_timer, null), cooldown_duration)
	select_target(target_turf)

	if(start_visual)
		new start_visual(target_turf)
	if(start_sound)
		playsound(target_turf, start_sound, 100)

/datum/fire_support/proc/select_target(turf/target_turf)
	var/list/turf_list = list()
	for(var/turf/spread_turf in RANGE_TURFS(scatter_range, target_turf))
		turf_list += spread_turf
	for(var/i = 1 to impact_quantity)
		var/turf/impact_turf = pick(turf_list)
		addtimer(CALLBACK(src, PROC_REF(do_impact), impact_turf), 0.15 SECONDS * i)

/datum/fire_support/proc/do_impact(turf/target_turf)
	return

/datum/fire_support/gau
	name = "gun run"
	fire_support_type = MODE_GUN
	fire_support_flags
	impact_quantity = 5
	icon_state = "gau"
	initiate_chat_message = "TARGET ACQUIRED GUN RUN INBOUND."
	initiate_screen_message = "Target received, gun run inbound."

/datum/fire_support/gau/do_impact(turf/target_turf)
	var/revdir = REVERSE_DIR(NORTH)
	for(var/i=0 to 2)
		target_turf = get_step(target_turf, revdir)
	var/list/strafelist = list(target_turf)
	strafelist += get_step(target_turf, turn(NORTH, 90))
	strafelist += get_step(target_turf, turn(NORTH, -90)) //Build this list 3 turfs at a time for strafe_turfs
	for(var/b=0 to 6)
		target_turf = get_step(target_turf, NORTH)
		strafelist += target_turf
		strafelist += get_step(target_turf, turn(NORTH, 90))
		strafelist += get_step(target_turf, turn(NORTH, -90))

	if(!length(strafelist))
		return

	strafe_turfs(strafelist)

///Takes the top 3 turfs and miniguns them, then repeats until none left
/datum/fire_support/gau/proc/strafe_turfs(list/strafelist)
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
		addtimer(CALLBACK(src, PROC_REF(strafe_turfs), strafelist), 0.2 SECONDS)

/datum/fire_support/rockets
	name = "rocket barrage"
	fire_support_type = MODE_ROCKETS
	fire_support_flags
	scatter_range = 9
	impact_quantity = 15
	icon_state = "rockets"
	initiate_chat_message = "TARGET ACQUIRED ROCKET RUN INBOUND."
	initiate_screen_message = "Rockets hot, incoming!"

/datum/fire_support/rockets/do_impact(turf/target_turf)
	explosion(target_turf, 0, 2, 5, 2)

/datum/fire_support/cruise_missile
	name = "cruise missile strike"
	fire_support_type = MODE_CRS_MSL
	fire_support_flags
	scatter_range = 1
	icon_state = "cruise"
	initiate_chat_message = "TARGET ACQUIRED CRUISE MISSILE INBOUND."
	initiate_screen_message = "Cruise missile programmed, one out."
	initiate_sound = 'sound/weapons/rocket_incoming.ogg'
	start_visual = null
	start_sound = null

/datum/fire_support/cruise_missile/select_target(turf/target_turf)
	explosion(target_turf, 4, 5, 6)

/obj/item/binoculars/fire_support
	name = "tactical binoculars"
	desc = "A pair of binoculars, used to mark targets for airstrikes and cruise missiles. Unique action to toggle mode. Ctrl+Click when using to target something."
	var/obj/effect/overlay/temp/laser_target/laser
	var/target_acquisition_delay = 5 SECONDS
	///Last stored turf targetted by rangefinders
	var/turf/targetturf
	///Current mode for support request
	var/mode = MODE_GUN

	var/list/datum/fire_support/mode_list = list(
		MODE_GUN,
		MODE_ROCKETS,
		MODE_CRS_MSL,
	)
	w_class = WEIGHT_CLASS_TINY

/obj/item/binoculars/fire_support/Initialize()
	. = ..()
	update_icon()
	for(var/fire_support_type in mode_list)
		mode_list[fire_support_type] = GLOB.fire_support_types[fire_support_type]

/obj/item/binoculars/fire_support/unique_action(mob/user)
	. = ..()
	select_radial(user)
	return TRUE

/obj/item/binoculars/fire_support/proc/select_radial(mob/user)
	if(user.get_active_held_item() != src)
		return
	if(!can_interact(user))
		return TRUE

	var/list/radial_options = list()
	for(var/fire_support_type in mode_list)
		radial_options[fire_support_type] = image(icon = 'icons/mob/radial.dmi', icon_state = mode_list[fire_support_type].icon_state)

	mode = show_radial_menu(user, src, radial_options, null, 48, null, TRUE, TRUE)
	user.balloon_alert(user, "[mode_list[mode].name] mode")
	update_icon()

/obj/item/binoculars/fire_support/examine(mob/user)
	. = ..()
	. += span_notice("They are currently set to [mode_list[mode].name] targeting mode.")

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
	if(!mode_list[mode].uses)
		balloon_alert_to_viewers("[mode_list[mode].name] expended")
		return
	if(mode_list[mode].cooldown_timer)
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
	if(!mode_list[mode].uses)
		balloon_alert_to_viewers("[mode_list[mode].name] expended")
		return
	if(mode_list[mode].cooldown_timer)
		balloon_alert_to_viewers("On cooldown.")
		return

	playsound(src, 'sound/effects/binoctarget.ogg', 35)
	QDEL_NULL(laser)
	mode_list[mode].initiate_fire_support(TU, user)

/obj/item/binoculars/fire_support/proc/acquire_coordinates(atom/A, mob/living/carbon/human/user)
	var/turf/TU = get_turf(A)
	targetturf = TU
	to_chat(user, span_notice("COORDINATES: LONGITUDE [targetturf.x]. LATITUDE [targetturf.y]."))
	playsound(src, 'sound/effects/binoctarget.ogg', 35)

#undef MODE_GUN
#undef MODE_ROCKETS
#undef MODE_CRS_MSL
