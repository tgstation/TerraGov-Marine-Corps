///This component allows gun mounting on vehicle types
/datum/component/fire_support
	///lase effect
	var/image/laser_overlay
	///lasing time
	var/target_acquisition_delay = 5 SECONDS
	///Last stored turf targetted by rangefinders
	var/turf/target_atom
	///Current mode for support request
	var/datum/fire_support/mode = null
	///firemodes available for these binos
	var/list/datum/fire_support/mode_list

/datum/component/fire_support/Initialize(list/new_mode_list)
	. = ..()
	if(!ismovable(parent) || !length(new_mode_list))
		return COMPONENT_INCOMPATIBLE
	mode_list = list()
	for(var/fire_support_type in new_mode_list)
		mode_list[fire_support_type] = GLOB.fire_support_types[fire_support_type]

/datum/component/fire_support/RegisterWithParent()
	RegisterSignals(parent, list(COMSIG_DATUM_INTERACT_SET, COMSIG_ITEM_ZOOMED), PROC_REF(on_interact))
	RegisterSignals(parent, list(COMSIG_DATUM_INTERACT_UNSET, COMSIG_ITEM_UNZOOMED), PROC_REF(on_uninteract))

	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

	RegisterSignal(parent, COMSIG_ITEM_UNIQUE_ACTION, PROC_REF(on_unique_action)) //todo: periscope doesn't have this

/datum/component/fire_support/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_DATUM_INTERACT_SET,
		COMSIG_DATUM_INTERACT_UNSET,
		COMSIG_ITEM_ZOOMED,
		COMSIG_ITEM_UNZOOMED,
		COMSIG_ITEM_UNIQUE_ACTION,
		COMSIG_ATOM_EXAMINE,
	))
	unset_target()
	mode = null
	mode_list = null
	return ..()

/datum/component/fire_support/proc/on_interact(datum/source, mob/user)
	SIGNAL_HANDLER
	user.client.click_intercept = src

/datum/component/fire_support/proc/on_uninteract(datum/source, mob/user)
	SIGNAL_HANDLER
	user.client.click_intercept = null

/datum/component/fire_support/proc/on_unique_action(datum/source, mob/user)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(select_radial), user)

/datum/component/fire_support/proc/on_examine(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER
	if(!mode)
		return
	examine_text += span_boldnotice("They are currently set to [mode.name] mode: [mode.uses == -1 ? "unlimited" : "[mode.uses]"] uses remaining.")
	if(!mode.cooldown_timer)
		return
	examine_text += span_warning("Available in [round(timeleft(mode.cooldown_timer) MILLISECONDS)] seconds.")

/datum/component/fire_support/InterceptClickOn(mob/user, params, atom/object)
	var/list/pa = params2list(params)
	if(!pa.Find("ctrl") && pa.Find("shift"))
		acquire_coordinates(object, user)
		return TRUE

	if(pa.Find("ctrl") && !pa.Find("shift"))
		acquire_target(object, user)
		return TRUE

	return FALSE

///Returns where our lase is actually coming from
/datum/component/fire_support/proc/get_anchor(mob/user)
	if(!user?.client?.eye) //this probably should never happen??
		return user
	var/atom/client_eye = user.client.eye
	if(isturf(client_eye.loc))
		return client_eye
	return client_eye.loc //this ensures we can see balloon alerts for binos in hand etc

///Selects a firemode
/datum/component/fire_support/proc/select_radial(mob/user)
	if(isitem(parent) && (user.get_active_held_item() != parent))
		return
	if(!parent.can_interact(user))
		return TRUE

	var/list/radial_options = list()
	for(var/fire_support_type in mode_list)
		if(!mode_list[fire_support_type].uses || !(mode_list[fire_support_type].fire_support_flags & FIRESUPPORT_AVAILABLE))
			continue
		radial_options[mode_list[fire_support_type].name] = image(icon = 'icons/mob/radial.dmi', icon_state = mode_list[fire_support_type].icon_state)

	var/atom/anchor = get_anchor(user)
	var/mode_selected = show_radial_menu(user, anchor, radial_options, null, 48, tooltips = TRUE)
	for(var/option in mode_list)
		if(mode_list[option].name != mode_selected)
			continue
		mode = mode_list[option]
		anchor.balloon_alert(user, "[mode_selected] mode")

///lases a target and calls fire support on it
/datum/component/fire_support/proc/acquire_target(atom/target, mob/living/carbon/human/user)
	set waitfor = 0
	var/atom/anchor = get_anchor(user)
	if(user.do_actions)
		anchor.balloon_alert(user, "busy!")
		return
	if(is_mainship_level(anchor.z))
		anchor.balloon_alert(user, "can't use these here!")
		return
	var/atom/movable/parent_movable = parent
	if(parent_movable.faction && user.faction != parent_movable.faction) //this is like the only place we use movable parent so far
		anchor.balloon_alert(user, "security locks engaged")
		return
	if(laser_overlay)
		to_chat(user, span_warning("You're already targeting something."))
		return
	if(!bino_checks(target, user))
		return
	if(!can_see_target(target, user))
		anchor.balloon_alert(user, "no clear view!")
		return

	playsound(parent, 'sound/effects/nightvision.ogg', 35, FALSE, SHORT_SOUND_RANGE)
	to_chat(user, span_notice("INITIATING LASER TARGETING. Stand still."))
	target_atom = target
	laser_overlay = image('icons/obj/items/projectiles.dmi', icon_state = "laser_target_yellow", layer =-LASER_LAYER)
	target_atom.apply_fire_support_laser(laser_overlay)
	if(!do_after(user, target_acquisition_delay, NONE, anchor, BUSY_ICON_HOSTILE, extra_checks = CALLBACK(src, PROC_REF(can_see_target), target, user))) //make sure this works with anchor
		to_chat(user, span_danger("You lose sight of your target!"))
		playsound(user,'sound/machines/click.ogg', 25, TRUE, SUPPRESSED_SOUND_RANGE)
		unset_target()
		return
	if(!bino_checks(target, user))
		playsound(user,'sound/machines/click.ogg', 25, TRUE, SUPPRESSED_SOUND_RANGE)
		unset_target()
		return

	playsound(parent, 'sound/effects/binoctarget.ogg', 35, FALSE, SHORT_SOUND_RANGE)
	mode.initiate_fire_support(get_turf(target_atom), user)
	unset_target()

///Internal bino checks, mainly around firemode
/datum/component/fire_support/proc/bino_checks(atom/target, mob/living/user)
	var/atom/anchor = get_anchor(user)
	if(!mode)
		anchor.balloon_alert(user, "select a mode!")
		return FALSE
	if(!(mode.fire_support_flags & FIRESUPPORT_AVAILABLE))
		anchor.balloon_alert(user, "[lowertext(mode.name)] unavailable!")
		return FALSE
	if(!mode.uses)
		anchor.balloon_alert(user, "[lowertext(mode.name)] expended!")
		return FALSE
	if(mode.cooldown_timer)
		anchor.balloon_alert(user, "on cooldown!")
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
/datum/component/fire_support/proc/can_see_target(atom/target, mob/living/user)
	if(QDELETED(target))
		return FALSE
	var/atom/anchor = get_anchor(user)
	var/turf/anchor_turf = get_turf(anchor)
	if(target.z != anchor_turf.z)
		return FALSE
	if(!line_of_sight(anchor, target, 30, TRUE))
		if(!line_of_sight(anchor_turf, target, 30, TRUE)) //debug
			return FALSE
	return TRUE

///Unsets the target and cleans up
/datum/component/fire_support/proc/unset_target()
	if(target_atom)
		target_atom.remove_fire_support_laser(laser_overlay)
		target_atom = null
	if(laser_overlay)
		QDEL_NULL(laser_overlay)

///Acquires coords of a target turf
/datum/component/fire_support/proc/acquire_coordinates(atom/A, mob/living/carbon/human/user)
	var/turf/target_turf = get_turf(A)
	to_chat(user, span_notice("COORDINATES: LONGITUDE [target_turf.x]. LATITUDE [target_turf.y]."))
	playsound(parent, 'sound/effects/binoctarget.ogg', 35, FALSE, SHORT_SOUND_RANGE)


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
