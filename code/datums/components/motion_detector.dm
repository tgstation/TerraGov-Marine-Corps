/datum/component/motion_detector
	/// The typed human of parent.
	var/mob/living/carbon/human/human_parent
	/// The timer id of a callback proc that checks if anything nearby moved recently.
	var/scan_timer
	/// How long between scans?
	var/scan_time = 2 SECONDS
	/// If something moved, how much time must pass before they do not show up on the scan?
	var/move_sensitivity = 1 SECONDS
	/// How far do we check?
	var/range = 16
	/// List of all blip effects.
	var/list/obj/effect/blips_list = list()

/datum/component/motion_detector/Initialize()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/motion_detector/RegisterWithParent()
	human_parent = parent
	clear_blips()
	deltimer(scan_timer)
	scan_timer = addtimer(CALLBACK(src, PROC_REF(do_scan)), scan_time, TIMER_LOOP|TIMER_STOPPABLE|TIMER_UNIQUE)

/datum/component/motion_detector/UnregisterFromParent()
	human_parent = null
	clear_blips()
	deltimer(scan_timer)
	scan_timer = null

/datum/component/motion_detector/vv_edit_var(var_name, var_value)
	if(NAMEOF(src, scan_time) == var_name)
		deltimer(scan_timer)
		scan_timer = addtimer(CALLBACK(src, PROC_REF(do_scan)), var_value, TIMER_LOOP|TIMER_STOPPABLE|TIMER_UNIQUE)
		return TRUE
	return ..()

/// Clears the human's screen of all blips.
/datum/component/motion_detector/proc/clear_blips()
	QDEL_LIST(blips_list)
	blips_list.Cut()

/// Scans a certain range for the recently moved and creates a blip for each of them.
/datum/component/motion_detector/proc/do_scan()
	// If they are not around to enjoy the blips, component goes away.
	if(!human_parent?.client || human_parent.stat != CONSCIOUS)
		RemoveComponent()
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
		if(nearby_xeno.last_move_time + move_sensitivity < world.time)
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
		blips_list += new /obj/effect/edge_blip(null, status, human_parent, screen_pos_x, screen_pos_y, dir)
		return
	blips_list += new /obj/effect/blip(get_turf(target), status, human_parent)

// ***************************************
// *********** Blips
// ***************************************

/obj/effect/blip
	plane = HIGH_GAME_PLANE
	layer = FLASH_LAYER
	icon = 'icons/blanks/572x480.dmi' // Widescreen support!
	icon_state = "nothing"
	appearance_flags = NONE // In sum, this makes the effect visible if you're on the same screen as the turf it was created on.
	pixel_x = -274
	pixel_y = -224

/obj/effect/blip/Initialize(mapload, identifier, mob/user)
	. = ..()
	var/image/blip_image = new('icons/effects/blips.dmi', src, "close_blip_[identifier]")
	blip_image.pixel_x = 274
	blip_image.pixel_y = 224
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/one_person, "motion_sensor_blip", blip_image, user) // Cursed, but it works!

/obj/effect/blip/Destroy()
	remove_alt_appearance("motion_sensor_blip")
	return ..()

/obj/effect/edge_blip
	plane = HIGH_GAME_PLANE
	layer = FLASH_LAYER
	icon = 'icons/effects/blips.dmi'
	/// The mob who can only see this blip.
	var/mob/seer

/obj/effect/edge_blip/Initialize(mapload, identifier, mob/user, screen_pos_x, screen_pos_y, direction)
	. = ..()
	if(!user?.client)
		return INITIALIZE_HINT_QDEL
	icon_state = "edge_blip_[identifier]"
	screen_loc = "[screen_pos_x],[screen_pos_y]"
	setDir(direction)
	update_icon()
	seer = user
	seer.client.screen += src

/obj/effect/edge_blip/Destroy()
	seer?.client?.screen -= src
	seer = null
	return ..()
