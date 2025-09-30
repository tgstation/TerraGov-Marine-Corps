/obj/item/binoculars/fire_support
	name = "pair of tactical binoculars"
	desc = "A pair of binoculars, used to mark targets for airstrikes and cruise missiles. Unique action to toggle mode. Ctrl+Click when using to target something."
	icon_state = "range_finders"
	w_class = WEIGHT_CLASS_SMALL
	///lase effect
	var/image/laser_overlay
	///lasing time
	var/target_acquisition_delay = 5 SECONDS
	///Last stored turf targetted by rangefinders
	var/turf/target_atom
	///Current mode for support request
	var/datum/fire_support/mode = null
	///firemodes available for these binos
	var/list/datum/fire_support/mode_list = list(
		FIRESUPPORT_TYPE_GUN_UNLIMITED,
		FIRESUPPORT_TYPE_ROCKETS_UNLIMITED,
		FIRESUPPORT_TYPE_CRUISE_MISSILE_UNLIMITED,
	)

/obj/item/binoculars/fire_support/Initialize(mapload)
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
	if(!mode)
		return
	. += span_boldnotice("They are currently set to [mode.name] mode: [mode.uses == -1 ? "unlimited" : "[mode.uses]"] uses remaining.")
	if(!mode.cooldown_timer)
		return
	. += span_warning("Available in [round(timeleft(mode.cooldown_timer) MILLISECONDS)] seconds.")

/obj/item/binoculars/fire_support/Destroy()
	unset_target()
	mode = null
	mode_list = null
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

	unset_target()

	if(!user?.client)
		return

	user.client.click_intercept = null
	user.reset_perspective(user)
	user.update_sight()

/obj/item/binoculars/fire_support/update_remote_sight(mob/living/user)
	user.lighting_cutoff = LIGHTING_CUTOFF_FULLBRIGHT
	user.sync_lighting_plane_cutoff()
	return TRUE

/obj/item/binoculars/fire_support/update_overlays()
	. = ..()
	if(mode)
		. += "binoculars_cas"
	else
		. += "binoculars_orbital"

///Selects a firemode
/obj/item/binoculars/fire_support/proc/select_radial(mob/user)
	if(user.get_active_held_item() != src)
		return
	if(!can_interact(user))
		return TRUE

	var/list/radial_options = list()
	for(var/fire_support_type in mode_list)
		if(!mode_list[fire_support_type].uses || !(mode_list[fire_support_type].fire_support_flags & FIRESUPPORT_AVAILABLE))
			continue
		radial_options[mode_list[fire_support_type].name] = image(icon = 'icons/mob/radial.dmi', icon_state = mode_list[fire_support_type].icon_state)

	var/mode_selected = show_radial_menu(user, src, radial_options, null, 48, null, TRUE, TRUE)
	for(var/option in mode_list)
		if(mode_list[option].name != mode_selected)
			continue
		mode = mode_list[option]
		user.balloon_alert(user, "[mode_selected] mode")
	update_icon()

///lases a target and calls fire support on it
/obj/item/binoculars/fire_support/proc/acquire_target(atom/target, mob/living/carbon/human/user)
	set waitfor = 0
	if(user.do_actions)
		balloon_alert_to_viewers("busy!")
		return
	if(is_mainship_level(user.z))
		user.balloon_alert(user, "can't use these here!")
		return
	if(faction && user.faction != faction)
		balloon_alert_to_viewers("security locks engaged")
		return
	if(laser_overlay)
		to_chat(user, span_warning("You're already targeting something."))
		return
	if(!bino_checks(target, user))
		return
	if(!can_see_target(target, user))
		balloon_alert_to_viewers("no clear view!")
		return

	playsound(src, 'sound/effects/nightvision.ogg', 35)
	to_chat(user, span_notice("INITIATING LASER TARGETING. Stand still."))
	target_atom = target
	laser_overlay = image('icons/obj/items/projectiles.dmi', icon_state = "sniper_laser", layer =-LASER_LAYER)
	target_atom.apply_fire_support_laser(laser_overlay)
	if(!do_after(user, target_acquisition_delay, NONE, user, BUSY_ICON_HOSTILE, extra_checks = CALLBACK(src, PROC_REF(can_see_target), target, user)))
		to_chat(user, span_danger("You lose sight of your target!"))
		playsound(user,'sound/machines/click.ogg', 25, 1)
		unset_target()
		return
	if(!bino_checks(target, user))
		return

	playsound(src, 'sound/effects/binoctarget.ogg', 35)
	mode.initiate_fire_support(get_turf(target_atom), user)
	unset_target()

///Internal bino checks, mainly around firemode
/obj/item/binoculars/fire_support/proc/bino_checks(atom/target, mob/living/user)
	if(!mode)
		balloon_alert_to_viewers("select a mode!")
		return FALSE
	if(!(mode.fire_support_flags & FIRESUPPORT_AVAILABLE))
		balloon_alert_to_viewers("[lowertext(mode.name)] unavailable!")
		return FALSE
	if(!mode.uses)
		balloon_alert_to_viewers("[lowertext(mode.name)] expended!")
		return FALSE
	if(mode.cooldown_timer)
		balloon_alert_to_viewers("on cooldown!")
		return FALSE
	var/area/targ_area = get_area(target)
	if(isspacearea(targ_area))
		to_chat(user, span_warning("Cannot fire into space."))
		return FALSE
	if(targ_area.ceiling >= CEILING_UNDERGROUND)
		to_chat(user, span_warning("DEPTH WARNING: Target too deep for ordnance."))
		return FALSE
	return TRUE

///Checks if we can draw LOS to the target
/obj/item/binoculars/fire_support/proc/can_see_target(atom/target, mob/living/user)
	if(QDELETED(target))
		return FALSE
	if(target.z != user.z)
		return FALSE
	if(!(user in viewers(zoom_tile_offset + zoom_viewsize + 3, target)))
		return FALSE
	return TRUE

///Unsets the target and cleans up
/obj/item/binoculars/fire_support/proc/unset_target()
	if(target_atom)
		target_atom.remove_fire_support_laser(laser_overlay)
		target_atom = null
	if(laser_overlay)
		QDEL_NULL(laser_overlay)

///Acquires coords of a target turf
/obj/item/binoculars/fire_support/proc/acquire_coordinates(atom/A, mob/living/carbon/human/user)
	var/turf/target_turf = get_turf(A)
	to_chat(user, span_notice("COORDINATES: LONGITUDE [target_turf.x]. LATITUDE [target_turf.y]."))
	playsound(src, 'sound/effects/binoctarget.ogg', 35)


/obj/item/binoculars/fire_support/campaign
	faction = FACTION_TERRAGOV
	mode_list = list(
		FIRESUPPORT_TYPE_GUN,
		FIRESUPPORT_TYPE_ROCKETS,
		FIRESUPPORT_TYPE_CRUISE_MISSILE,
		FIRESUPPORT_TYPE_LASER,
		FIRESUPPORT_TYPE_HE_MORTAR,
		FIRESUPPORT_TYPE_INCENDIARY_MORTAR,
		FIRESUPPORT_TYPE_ACID_SMOKE_MORTAR,
		FIRESUPPORT_TYPE_SMOKE_MORTAR,
		FIRESUPPORT_TYPE_SENTRY_POD,
		FIRESUPPORT_TYPE_SUPPLY_POD,
	)

/obj/item/binoculars/fire_support/campaign/som
	faction = FACTION_SOM
	mode_list = list(
		FIRESUPPORT_TYPE_VOLKITE,
		FIRESUPPORT_TYPE_INCEND_ROCKETS,
		FIRESUPPORT_TYPE_RAD_MISSILE,
		FIRESUPPORT_TYPE_HE_MORTAR_SOM,
		FIRESUPPORT_TYPE_INCENDIARY_MORTAR_SOM,
		FIRESUPPORT_TYPE_SATRAPINE_SMOKE_MORTAR,
		FIRESUPPORT_TYPE_SMOKE_MORTAR_SOM,
		FIRESUPPORT_TYPE_TELE_COPE,
	)

///Sets a laser overlay for fire support binos
/atom/proc/apply_fire_support_laser(image/laser_overlay)
	add_overlay(laser_overlay)

/mob/living/carbon/apply_fire_support_laser(image/laser_overlay)
	overlays_standing[LASER_LAYER] = laser_overlay
	apply_overlay(LASER_LAYER)

///Removes a laser overlay for fire support binos
/atom/proc/remove_fire_support_laser(image/laser_overlay)
	cut_overlay(laser_overlay)

/mob/living/carbon/remove_fire_support_laser(image/laser_overlay)
	remove_overlay(LASER_LAYER)
