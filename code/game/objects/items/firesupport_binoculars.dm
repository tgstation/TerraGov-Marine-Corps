/obj/item/binoculars/fire_support
	name = "tactical binoculars"
	desc = "A pair of binoculars, used to mark targets for airstrikes and cruise missiles. Unique action to toggle mode. Ctrl+Click when using to target something."
	w_class = WEIGHT_CLASS_SMALL
	///Faction locks this item if specified
	var/faction = null
	///lase effect
	var/obj/effect/overlay/temp/laser_target/laser
	var/target_acquisition_delay = 5 SECONDS
	///Last stored turf targetted by rangefinders
	var/turf/targetturf
	///Current mode for support request
	var/mode = FIRESUPPORT_TYPE_GUN
	///firemodes available for these binos
	var/list/datum/fire_support/mode_list = list(
		FIRESUPPORT_TYPE_GUN,
		FIRESUPPORT_TYPE_ROCKETS,
		FIRESUPPORT_TYPE_CRUISE_MISSILE,
	)

/obj/item/binoculars/fire_support/Initialize()
	. = ..()
	update_icon()
	for(var/fire_support_type in mode_list)
		mode_list[fire_support_type] = GLOB.fire_support_types[fire_support_type]

/obj/item/binoculars/fire_support/unique_action(mob/user)
	. = ..()
	select_radial(user)
	return TRUE

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

///Selects a firemode
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

///lases a target and calls fire support on it
/obj/item/binoculars/fire_support/proc/acquire_target(atom/A, mob/living/carbon/human/user)
	set waitfor = 0

	if(faction && user.faction != faction)
		balloon_alert_to_viewers("Security locks engaged")
		return
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
		balloon_alert_to_viewers("On cooldown")
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

///Acquires coords of a target turf
/obj/item/binoculars/fire_support/proc/acquire_coordinates(atom/A, mob/living/carbon/human/user)
	var/turf/TU = get_turf(A)
	targetturf = TU
	to_chat(user, span_notice("COORDINATES: LONGITUDE [targetturf.x]. LATITUDE [targetturf.y]."))
	playsound(src, 'sound/effects/binoctarget.ogg', 35)
