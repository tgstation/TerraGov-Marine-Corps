/obj/effect/detector_blip
	icon = 'icons/Marine/marine-items.dmi'
	icon_state = "detector_blip"
	layer = BELOW_FULLSCREEN_LAYER
	var/identifier = MOTION_DETECTOR_HOSTILE
	var/edge_blip = FALSE
	var/turf/center
	var/turf/target_turf

/obj/effect/detector_blip/friendly
	icon_state = "detector_blip_friendly"
	identifier = MOTION_DETECTOR_FRIENDLY

/obj/effect/detector_blip/dead
	icon_state = "detector_blip_dead"
	identifier = MOTION_DETECTOR_DEAD

/obj/effect/detector_blip/Destroy()
	center = null
	target_turf = null
	return ..()

/obj/effect/detector_blip/update_icon_state()
	icon_state = "detector_blip[edge_blip ? "_dir" : ""][identifier]"

/obj/item/attachable/motiondetector
	name = "tactical sensor"
	desc = "A device that detects hostile movement. Hostiles appear as red blips. Friendlies with the correct IFF signature appear as green, and their bodies as blue, unrevivable bodies as dark blue. It has a mode selection interface."
	icon_state = "marinescope_a"
	attach_icon = "marinescope_a"
	slot = ATTACHMENT_SLOT_RAIL
	/// Our list of blips
	var/list/obj/effect/detector_blip/blip_pool = list()
	/// Who's using this item
	var/mob/living/carbon/human/operator
	/// A recycle countdown, when at zero the blip pool is cleaned up
	var/recycle_countdown = MOTION_DETECTOR_RECYCLE_TIME

/obj/item/attachable/motiondetector/Destroy()
	clean_user()
	return ..()

/obj/item/attachable/motiondetector/activate_attachment(mob/user, turn_off)
	. = ..()
	if(operator)
		clean_user()
		return
	operator = user
	RegisterSignal(operator, COMSIG_PARENT_QDELETING, .proc/clean_user)
	START_PROCESSING(SSobj, src)

/// Signal handler to clean out user vars
/obj/item/attachable/motiondetector/proc/clean_user()
	SIGNAL_HANDLER
	STOP_PROCESSING(SSobj, src)
	if(operator)
		UnregisterSignal(operator, COMSIG_PARENT_QDELETING)
		operator = null
	QDEL_LIST_ASSOC_VAL(blip_pool)

/obj/item/attachable/motiondetector/process()
	. = ..()
	if(!operator?.client || operator.stat != CONSCIOUS)
		clean_user()
		return
	for (var/mob/living/carbon/human/nearby_human AS in cheap_get_humans_near(operator, MOTION_DETECTOR_RANGE))
		if(nearby_human == operator)
			continue
		prepare_blip(nearby_human, nearby_human.stat != DEAD ? nearby_human.wear_id?.iff_signal & operator.wear_id.iff_signal ? MOTION_DETECTOR_FRIENDLY : MOTION_DETECTOR_HOSTILE : MOTION_DETECTOR_DEAD)
	for (var/mob/living/carbon/xenomorph/nearby_xeno AS in cheap_get_xenos_near(operator, MOTION_DETECTOR_RANGE))
		prepare_blip(nearby_xeno, nearby_xeno.stat == DEAD ? MOTION_DETECTOR_DEAD : MOTION_DETECTOR_HOSTILE)
	recycle_countdown--
	if(recycle_countdown <= 0)
		recycle_countdown = MOTION_DETECTOR_RECYCLE_TIME
		QDEL_LIST_ASSOC_VAL(blip_pool)

///Prepare the blip to be print on the operator screen
/obj/item/attachable/motiondetector/proc/prepare_blip(mob/target, status)
	if(!operator.client)
		return
	if(!blip_pool[target])
		switch(status)
			if(MOTION_DETECTOR_HOSTILE)
				blip_pool[target] = new /obj/effect/detector_blip()
			if(MOTION_DETECTOR_FRIENDLY)
				blip_pool[target] = new /obj/effect/detector_blip/friendly()
			if(MOTION_DETECTOR_DEAD)
				blip_pool[target] = new /obj/effect/detector_blip/dead()

	var/obj/effect/detector_blip/detector_blip = blip_pool[target]
	var/turf/center_view = get_view_center(operator)
	if(in_view_range(operator, target))
		detector_blip.setDir(initial(detector_blip.dir)) //Update the ping sprite
		detector_blip.edge_blip = FALSE
	else
		detector_blip.setDir(get_dir(center_view, target))
		detector_blip.edge_blip = TRUE
	detector_blip.update_icon()

	var/list/actualview = getviewsize(operator.client.view)
	var/viewX = actualview[1]
	var/viewY = actualview[2]
	var/screen_pos_x = clamp(target.x - center_view.x + round(viewX * 0.5) + 1, 1, viewX)
	var/screen_pos_y = clamp(target.y - center_view.y + round(viewY * 0.5) + 1, 1, viewY)
	detector_blip.screen_loc = "[screen_pos_x],[screen_pos_y]"
	detector_blip.center = center_view
	detector_blip.target_turf = get_turf(target)
	detector_blip.show_bip(operator)

/// Print the blip on the operator screen
/obj/effect/detector_blip/proc/show_bip(mob/operator)
	if(!operator?.client)
		return
	operator.client.screen += src
	RegisterSignal(operator, COMSIG_MOVABLE_MOVED, .proc/on_movement)
	addtimer(CALLBACK(src, .proc/remove_blip, operator), 1 SECONDS)

/// Remove the blip from the operator screen
/obj/effect/detector_blip/proc/remove_blip(mob/operator)
	center = null
	target_turf = null
	if(QDELETED(operator))
		return
	UnregisterSignal(operator, COMSIG_MOVABLE_MOVED)
	if(!operator?.client)
		return
	operator.client.screen -= src

/// Signal handler to move the blip when the operator is moving
/obj/effect/detector_blip/proc/on_movement(datum/source, atom/oldloc, direction, Forced)
	SIGNAL_HANDLER
	var/mob/operator = source
	if(!operator.client || operator.z != oldloc.z)
		remove_blip(operator)
		return
	var/x_movement = operator.x - oldloc.x
	var/y_movement = operator.y - oldloc.y
	center = locate(center.x + x_movement, center.y + y_movement, center.z)
	var/list/temp_list = getviewsize(operator.client.view)
	var/viewX = temp_list[1]
	var/viewY = temp_list[2]
	temp_list = splittext(screen_loc,",")
	var/screen_pos_x = text2num(temp_list[1]) - x_movement
	var/screen_pos_y = text2num(temp_list[2]) - y_movement
	var/in_edge = FALSE
	if(screen_pos_x <= 1)
		screen_pos_x = 1
		in_edge = TRUE
	else if(screen_pos_x >= viewX)
		screen_pos_x = viewX
		in_edge = TRUE
	if(screen_pos_y <= 1)
		screen_pos_y = 1
		in_edge = TRUE
	else if(screen_pos_y >= viewY)
		screen_pos_y = viewY
		in_edge = TRUE
	edge_blip = in_edge
	update_icon()
	screen_loc = "[screen_pos_x],[screen_pos_y]"
