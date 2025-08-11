/datum/component/motion_detector
	/// The typed human of parent.
	var/mob/living/carbon/human/human_parent
	/// The ID of the timer that checks if anything nearby moved recently.
	var/scan_timer
	/// How long between scans?
	var/scan_time = 2 SECONDS
	/// If something moved, how much time must pass before they do not show up on the scan?
	var/move_sensitivity = 1 SECONDS
	/// How far do we check?
	var/range = 16
	/// List of all blips.
	var/list/obj/effect/blip/blips_list = list()

/datum/component/motion_detector/Initialize()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/motion_detector/RegisterWithParent()
	human_parent = parent
	clear_blips()
	deltimer(scan_timer)
	scan_timer = addtimer(CALLBACK(src, PROC_REF(do_scan)), scan_time, TIMER_LOOP|TIMER_STOPPABLE)

/datum/component/motion_detector/UnregisterFromParent()
	human_parent = null
	clear_blips()
	deltimer(scan_timer)
	scan_timer = null

/// Clears the human's screen of all blips.
/datum/component/motion_detector/proc/clear_blips()
	for(var/obj/effect/blip/blip AS in blips_list)
		blip.remove_blip(human_parent)
	blips_list.Cut()

/// Scans a certain range for the recently moved and creates a blip for each of them.
/datum/component/motion_detector/proc/do_scan()
	// If they are not around to enjoy the blips, component goes away.
	if(!human_parent?.client || human_parent.stat != CONSCIOUS)
		qdel(src)
		return

	var/hostile_detected = FALSE
	for (var/mob/living/carbon/human/nearby_human AS in cheap_get_humans_near(human_parent, range))
		if(nearby_human == human_parent)
			continue
		if(nearby_human.last_move_time + move_sensitivity < world.time)
			continue
		var/detector_status = nearby_human.wear_id?.iff_signal & human_parent.wear_id.iff_signal ? MOTION_DETECTOR_FRIENDLY : MOTION_DETECTOR_HOSTILE
		create_blip(nearby_human, detector_status)
		if(detector_status == MOTION_DETECTOR_HOSTILE)
			hostile_detected = TRUE
	for (var/mob/living/carbon/xenomorph/nearby_xeno AS in cheap_get_xenos_near(human_parent, range))
		if(nearby_xeno.last_move_time + move_sensitivity < world.time )
			continue
		create_blip(nearby_xeno, MOTION_DETECTOR_HOSTILE)
		hostile_detected = TRUE

	if(hostile_detected)
		playsound(human_parent.loc, 'sound/items/tick.ogg', 100, 0, 7, 2)
	addtimer(CALLBACK(src, PROC_REF(clear_blips)), min(1 SECONDS, scan_time))

/// Creates a colored blip for the human_parent's client that is either at: the target's location (if close enough) or on the edge of the client's screen (if far enough).
/datum/component/motion_detector/proc/create_blip(mob/target, status)
	var/list/actualview = getviewsize(human_parent.client.view)
	var/viewX = actualview[1]
	var/viewY = actualview[2]
	var/turf/center_view = get_view_center(human_parent)
	var/screen_pos_y = target.y - center_view.y + round(viewY * 0.5) + 1
	var/dir
	if(screen_pos_y < 1)
		dir = SOUTH
		screen_pos_y = 1
	else if (screen_pos_y > viewY)
		dir = NORTH
		screen_pos_y = viewY
	var/screen_pos_x = target.x - center_view.x + round(viewX * 0.5) + 1
	if(screen_pos_x < 1)
		dir = (dir ? dir == SOUTH ? SOUTHWEST : NORTHWEST : WEST)
		screen_pos_x = 1
	else if (screen_pos_x > viewX)
		dir = (dir ? dir == SOUTH ? SOUTHEAST : NORTHEAST : EAST)
		screen_pos_x = viewX
	if(dir)
		blips_list += new /obj/effect/blip/edge_blip(null, status, human_parent, screen_pos_x, screen_pos_y, dir)
		return
	blips_list += new /obj/effect/blip/close_blip(get_turf(target), status, human_parent)

// ***************************************
// *********** Blips
// ***************************************

///Remove the blip from the operator screen.
/obj/effect/blip/proc/remove_blip(mob/operator)
	return

/obj/effect/blip/edge_blip
	icon = 'icons/effects/blips.dmi'
	plane = ABOVE_HUD_PLANE
	/// A friendly/hostile identifier.
	var/identifier = MOTION_DETECTOR_HOSTILE

/obj/effect/blip/edge_blip/Initialize(mapload, identifier, mob/operator, screen_pos_x, screen_pos_y, direction = SOUTH)
	. = ..()
	if(!operator?.client)
		return INITIALIZE_HINT_QDEL
	screen_loc = "[screen_pos_x],[screen_pos_y]"
	operator.client.screen += src
	src.identifier = identifier
	setDir(direction)
	update_icon()

/// Remove the blip from the operator screen.
/obj/effect/blip/edge_blip/remove_blip(mob/operator)
	operator?.client?.screen -= src
	qdel(src)

/obj/effect/blip/edge_blip/update_icon_state()
	. = ..()
	icon_state = "edge_blip_[identifier]"

/obj/effect/blip/close_blip
	plane = ABOVE_HUD_PLANE
	var/image/blip_image

/obj/effect/blip/close_blip/Initialize(mapload, identifier, mob/operator)
	. = ..()
	if(!operator?.client)
		return INITIALIZE_HINT_QDEL
	blip_image = image('icons/effects/blips.dmi', src, "close_blip_[identifier]")
	SET_PLANE_EXPLICIT(blip_image, ABOVE_HUD_PLANE, src)
	operator.client.images += blip_image

/// Remove the blip from the operator images.
/obj/effect/blip/close_blip/remove_blip(mob/operator)
	operator?.client?.images -= blip_image
	qdel(src)

/obj/effect/blip/close_blip/Destroy()
	blip_image = null
	return ..()
