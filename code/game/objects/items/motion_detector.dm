/obj/effect/detector_blip
	icon = 'icons/Marine/marine-items.dmi'
	icon_state = "detector_blip_dir"
	layer = BELOW_FULLSCREEN_LAYER
	plane = ABOVE_HUD_PLANE
	var/identifier = MOTION_DETECTOR_HOSTILE
	var/edge_blip = FALSE
	///The image shown on the user screen
	var/image/blip_image

/// Print the blip on the operator screen
/obj/effect/detector_blip/proc/show_bip(mob/operator, mob/target, screen_pos_x, screen_pos_y,)
	if(!operator?.client)
		return
	if(edge_blip) // we want to draw the blip directly on the screen edges, so we use client.screen
		moveToNullspace()
		icon_state = initial(icon_state)
		screen_loc = "[screen_pos_x],[screen_pos_y]"
		operator.client.screen += src
	else //we want to draw the blip on the target, so we need a game loc, so we use client.images
		forceMove(get_turf(target))
		icon_state = ""
		if(!blip_image)
			blip_image = image('icons/Marine/marine-items.dmi', src, "detector_blip[identifier]")
		blip_image.layer = BELOW_FULLSCREEN_LAYER
		operator.client.images |= blip_image
	addtimer(CALLBACK(src, .proc/remove_blip, operator), 1 SECONDS)

/// Remove the blip from the operator screen
/obj/effect/detector_blip/proc/remove_blip(mob/operator)
	if(QDELETED(operator))
		return
	if(!operator?.client)
		return
	if(edge_blip)
		operator.client.screen -= src
		return
	operator.client.images -= blip_image

/obj/effect/detector_blip/friendly
	icon_state = "detector_blip_dir_friendly"
	identifier = MOTION_DETECTOR_FRIENDLY

/obj/effect/detector_blip/dead
	icon_state = "detector_blip_dir_dead"
	identifier = MOTION_DETECTOR_DEAD

/obj/item/attachable/motiondetector
	name = "tactical sensor"
	desc = "A device that detects hostile movement. Hostiles appear as red blips. Friendlies with the correct IFF signature appear as green, and their bodies as blue, unrevivable bodies as dark blue. It has a mode selection interface."
	icon_state = "minidetector"
	attach_icon = "sniperscope_a"
	slot = ATTACHMENT_SLOT_RAIL
	attachment_action_type = /datum/action/item_action/toggle/motion_detector
	/// Our list of blips
	var/list/obj/effect/detector_blip/blip_pool = list()
	/// Who's using this item
	var/mob/living/carbon/human/operator
	/// A recycle countdown, when at zero the blip pool is cleaned up
	var/recycle_countdown = MOTION_DETECTOR_RECYCLE_TIME
	/// Distane to the closest hostile
	var/closest_hostile_distance = MOTION_DETECTOR_RANGE + 1

/obj/item/attachable/motiondetector/Destroy()
	clean_user()
	return ..()

/obj/item/attachable/motiondetector/activate_attachment(mob/user, turn_off)
	if(operator)
		clean_user()
		return
	operator = user
	RegisterSignal(operator, list(COMSIG_PARENT_QDELETING, COMSIG_GUN_USER_UNSET), .proc/clean_user)
	RegisterSignal(src, list(COMSIG_ITEM_EQUIPPED_TO_SLOT, COMSIG_ITEM_REMOVED_INVENTORY), .proc/clean_user)
	START_PROCESSING(SSslowprocess, src)
	update_icon()

/obj/item/attachable/motiondetector/detach_from_master_gun()
	. = ..()
	clean_user()

/obj/item/attachable/motiondetector/attack_self(mob/user)
	activate_attachment(user)

obj/item/attachable/motiondetector/update_icon()
	. = ..()
	for(var/datum/action/action AS in master_gun?.actions)
		action.update_button_icon()

/obj/item/attachable/motiondetector/update_icon_state()
	icon_state = initial(icon_state) + (isnull(operator) ? "" : "_on")

/// Signal handler to clean out user vars
/obj/item/attachable/motiondetector/proc/clean_user()
	SIGNAL_HANDLER
	STOP_PROCESSING(SSslowprocess, src)
	if(operator)
		UnregisterSignal(operator, list(COMSIG_PARENT_QDELETING, COMSIG_GUN_USER_UNSET))
		UnregisterSignal(src, list(COMSIG_ITEM_EQUIPPED_TO_SLOT, COMSIG_ITEM_REMOVED_INVENTORY))
		operator = null
	QDEL_LIST_ASSOC_VAL(blip_pool)
	update_icon()

/obj/item/attachable/motiondetector/process()
	if(!operator?.client || operator.stat != CONSCIOUS)
		clean_user()
		return
	closest_hostile_distance = MOTION_DETECTOR_RANGE + 1
	for (var/mob/living/carbon/human/nearby_human AS in cheap_get_humans_near(operator, MOTION_DETECTOR_RANGE))
		if(nearby_human == operator)
			continue
		prepare_blip(nearby_human, nearby_human.stat != DEAD ? nearby_human.wear_id?.iff_signal & operator.wear_id.iff_signal ? MOTION_DETECTOR_FRIENDLY : MOTION_DETECTOR_HOSTILE : MOTION_DETECTOR_DEAD)
	for (var/mob/living/carbon/xenomorph/nearby_xeno AS in cheap_get_xenos_near(operator, MOTION_DETECTOR_RANGE))
		prepare_blip(nearby_xeno, nearby_xeno.stat == DEAD ? MOTION_DETECTOR_DEAD : MOTION_DETECTOR_HOSTILE)
	if(closest_hostile_distance <= MOTION_DETECTOR_RANGE)
		operator.playsound_local(loc, 'sound/items/tick.ogg', 100 - closest_hostile_distance * 3, 0, 7, 2)
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
	if(detector_blip.identifier == MOTION_DETECTOR_HOSTILE)
		closest_hostile_distance = min(closest_hostile_distance, get_dist(target, operator))

	var/list/actualview = getviewsize(operator.client.view)
	var/viewX = actualview[1]
	var/viewY = actualview[2]
	var/turf/center_view = get_view_center(operator)
	detector_blip.setDir(SOUTH)
	detector_blip.edge_blip = FALSE
	var/screen_pos_y = target.y - center_view.y + round(viewY * 0.5) + 1
	if(screen_pos_y < 1)
		detector_blip.edge_blip = TRUE
		screen_pos_y = 1
	else if (screen_pos_y > viewY)
		detector_blip.setDir(NORTH)
		detector_blip.edge_blip = TRUE
		screen_pos_y = viewY
	var/screen_pos_x = target.x - center_view.x + round(viewX * 0.5) + 1
	if(screen_pos_x < 1)
		detector_blip.setDir(detector_blip.edge_blip ? detector_blip.dir == SOUTH ? SOUTHWEST : NORTHWEST : WEST)
		detector_blip.edge_blip = TRUE
		screen_pos_x = 1
	else if (screen_pos_x > viewX)
		detector_blip.setDir(detector_blip.edge_blip ? detector_blip.dir == SOUTH ? SOUTHEAST : NORTHEAST : EAST)
		detector_blip.edge_blip = TRUE
		screen_pos_x = viewX
	detector_blip.show_bip(operator, target, screen_pos_x, screen_pos_y)
