/datum/component/motion_detector
	/// The mob that everything is based around. If null, the component will do nothing.
	var/mob/detecting_mob
	/// If something moved, how much time must pass before they do not show up on the scan?
	var/move_sensitivity = 1 SECONDS
	/// How far do we check?
	var/range = 16
	/// List of all blip effects.
	var/list/obj/effect/blip/blips_list = list()

/datum/component/motion_detector/Initialize(mob/detecting_mob)
	src.detecting_mob = detecting_mob

/datum/component/motion_detector/RegisterWithParent()
	if(!detecting_mob)
		return
	START_PROCESSING(SSobj, src)

/datum/component/motion_detector/UnregisterFromParent()
	if(!detecting_mob)
		return
	STOP_PROCESSING(SSobj, src)
	clear_blips()
	detecting_mob = null

/datum/component/motion_detector/process()
	if(!detecting_mob)
		return
	do_scan()

/// Sets and handles all changes to the detecting_mob variable.
/datum/component/motion_detector/proc/set_detecting_mob(mob/new_detecting_mob)
	if(detecting_mob == new_detecting_mob)
		return
	clear_blips()
	if(!detecting_mob && new_detecting_mob)
		START_PROCESSING(SSobj, src)
	else if(detecting_mob && !new_detecting_mob)
		STOP_PROCESSING(SSobj, src)
	detecting_mob = new_detecting_mob

/// Clears the mob's screen of all blips.
/datum/component/motion_detector/proc/clear_blips()
	for(var/obj/effect/blip/blip AS in blips_list)
		blip.remove_blip(detecting_mob)
	blips_list.Cut()

/// Scans a certain range for the recently moved and creates a blip for each of them.
/datum/component/motion_detector/proc/do_scan()
	// If they are not around to enjoy the blips, they get no blips.
	if(!detecting_mob?.client || detecting_mob.stat != CONSCIOUS)
		return

	var/hostile_detected = FALSE
	var/our_iff_signal = NONE
	var/obj/item/card/id/detecting_id = detecting_mob.get_idcard(FALSE)
	if(detecting_id)
		our_iff_signal = detecting_id.iff_signal
	for (var/mob/living/carbon/human/nearby_human AS in cheap_get_humans_near(detecting_mob, range))
		if(nearby_human == detecting_mob)
			continue
		if(nearby_human.last_move_time + move_sensitivity < world.time)
			continue
		var/obj/item/card/id/nearby_id = nearby_human.get_idcard(FALSE)
		if(our_iff_signal && nearby_id && CHECK_BITFIELD(nearby_id.iff_signal, our_iff_signal))
			create_blip(nearby_human, MOTION_DETECTOR_FRIENDLY)
			continue
		create_blip(nearby_human, MOTION_DETECTOR_HOSTILE)
		hostile_detected = TRUE
	for (var/mob/living/carbon/xenomorph/nearby_xeno AS in cheap_get_xenos_near(detecting_mob, range))
		if(nearby_xeno.last_move_time + move_sensitivity < world.time)
			continue
		if(our_iff_signal && CHECK_BITFIELD(nearby_xeno.xeno_iff_check(), our_iff_signal))
			create_blip(nearby_xeno, MOTION_DETECTOR_FRIENDLY)
			continue
		create_blip(nearby_xeno, MOTION_DETECTOR_HOSTILE)
		hostile_detected = TRUE

	if(hostile_detected)
		playsound(detecting_mob.loc, 'sound/items/tick.ogg', 100, 0, 7, 2)
	addtimer(CALLBACK(src, PROC_REF(clear_blips)), 2 SECONDS)

/// Creates a colored blip for the detecting_mob's client that is either at: the target's location (if close enough) or on the edge of the client's screen (if far enough).
/datum/component/motion_detector/proc/create_blip(mob/target, status)
	var/list/actualview = getviewsize(detecting_mob.client.view)
	var/viewX = actualview[1]
	var/viewY = actualview[2]
	var/turf/center_view = get_view_center(detecting_mob)
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
		blips_list += new /obj/effect/blip/edge_blip(null, status, detecting_mob, screen_pos_x, screen_pos_y, dir)
		return
	blips_list += new /obj/effect/blip/close_blip(get_turf(target), status, detecting_mob, target.x - center_view.x, target.y - center_view.y)

// ***************************************
// *********** Blips
// ***************************************

/// Remove the blip from the user's screen.
/obj/effect/blip/proc/remove_blip(mob/user)
	return

/obj/effect/blip/edge_blip
	icon = 'icons/effects/blips.dmi'
	plane = ABOVE_HUD_PLANE
	/// A friendly/hostile identifier.
	var/identifier = MOTION_DETECTOR_HOSTILE

/obj/effect/blip/edge_blip/Initialize(mapload, identifier, mob/user, screen_pos_x, screen_pos_y, direction = SOUTH)
	. = ..()
	if(!user?.client)
		return INITIALIZE_HINT_QDEL
	screen_loc = "[screen_pos_x],[screen_pos_y]"
	user.client.screen += src
	src.identifier = identifier
	setDir(direction)
	update_icon()

/obj/effect/blip/edge_blip/remove_blip(mob/user)
	user?.client?.screen -= src
	qdel(src)

/obj/effect/blip/edge_blip/update_icon_state()
	. = ..()
	icon_state = "edge_blip_[identifier]"

/obj/effect/blip/close_blip
	plane = ABOVE_HUD_PLANE
	/// The image shown to the user.
	var/image/blip_image

/obj/effect/blip/close_blip/Initialize(mapload, identifier, mob/user, x_offset, y_offset)
	. = ..()
	if(!user?.client)
		return INITIALIZE_HINT_QDEL
	blip_image = image('icons/effects/blips.dmi', get_turf(user), "close_blip_[identifier]")
	blip_image.pixel_w = x_offset * 32
	blip_image.pixel_z = y_offset * 32
	SET_PLANE_EXPLICIT(blip_image, ABOVE_HUD_PLANE, src)
	user.client.images += blip_image

/obj/effect/blip/close_blip/remove_blip(mob/user)
	user?.client?.images -= blip_image
	qdel(src)

/obj/effect/blip/close_blip/Destroy()
	blip_image = null
	return ..()
