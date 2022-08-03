///Remove the blip from the operator screen
/atom/movable/effect/blip/proc/remove_blip(mob/operator)
	return

/atom/movable/effect/blip/edge_blip
	icon = 'icons/Marine/marine-items.dmi'
	plane = ABOVE_HUD_PLANE
	/// A friendly/hostile identifier
	var/identifier = MOTION_DETECTOR_HOSTILE

/atom/movable/effect/blip/edge_blip/Initialize(mapload, identifier, mob/operator, screen_pos_x, screen_pos_y, direction = SOUTH)
	. = ..()
	if(!operator?.client)
		return INITIALIZE_HINT_QDEL
	screen_loc = "[screen_pos_x],[screen_pos_y]"
	operator.client.screen += src
	src.identifier = identifier
	setDir(direction)
	update_icon()

/// Remove the blip from the operator screen
/atom/movable/effect/blip/edge_blip/remove_blip(mob/operator)
	operator.client.screen -= src
	qdel(src)

/atom/movable/effect/blip/edge_blip/update_icon_state()
	icon_state = "edge_blip_[identifier]"

/atom/movable/effect/blip/close_blip
	plane = ABOVE_HUD_PLANE
	var/image/blip_image

/atom/movable/effect/blip/close_blip/Initialize(mapload, identifier, mob/operator)
	. = ..()
	if(!operator?.client)
		return INITIALIZE_HINT_QDEL
	blip_image = image('icons/Marine/marine-items.dmi', src, "close_blip_[identifier]")
	blip_image.layer = BELOW_FULLSCREEN_LAYER
	operator.client.images += blip_image

/// Remove the blip from the operator images
/atom/movable/effect/blip/close_blip/remove_blip(mob/operator)
	operator.client?.images -= blip_image
	qdel(src)

/atom/movable/effect/blip/close_blip/Destroy()
	blip_image = null
	return ..()

/obj/item/attachable/motiondetector
	name = "tactical sensor"
	desc = "A device that detects hostile movement. Hostiles appear as red blips. Friendlies with the correct IFF signature appear as green, and their bodies as blue, unrevivable bodies as dark blue. It has a mode selection interface."
	icon_state = "minidetector"
	slot = ATTACHMENT_SLOT_RAIL
	attachment_action_type = /datum/action/item_action/toggle/motion_detector
	/// Who's using this item
	var/mob/living/carbon/human/operator
	///If a hostile was detected
	var/hostile_detected = FALSE
	///The time needed after the last move to not be detected by this motion detector
	var/move_sensitivity = 1 SECONDS
	///The range of this motion detector
	var/range = 16
	///The list of all the blips
	var/list/atom/movable/effect/blip/blips_list = list()

/obj/item/attachable/motiondetector/Destroy()
	clean_operator()
	return ..()

/obj/item/attachable/motiondetector/activate(mob/user, turn_off)
	if(operator)
		clean_operator()
		return
	operator = user
	RegisterSignal(operator, list(COMSIG_PARENT_QDELETING, COMSIG_GUN_USER_UNSET), .proc/clean_operator)
	RegisterSignal(src, list(COMSIG_ITEM_EQUIPPED_TO_SLOT, COMSIG_ITEM_REMOVED_INVENTORY), .proc/clean_operator)
	UnregisterSignal(operator, COMSIG_GUN_USER_SET)
	START_PROCESSING(SSobj, src)
	update_icon()

///Activate the attachement when your are putting the gun out of your suit slot
/obj/item/attachable/motiondetector/proc/start_processing_again(datum/source, obj/item/weapon/gun/equipping)
	SIGNAL_HANDLER
	if(equipping != master_gun)
		return
	activate(source)

/obj/item/attachable/motiondetector/on_detach()
	. = ..()
	clean_operator()

/obj/item/attachable/motiondetector/attack_self(mob/user)
	activate(user)

/obj/item/attachable/motiondetector/update_icon()
	. = ..()
	for(var/datum/action/action AS in master_gun?.actions)
		action.update_button_icon()

/obj/item/attachable/motiondetector/update_icon_state()
	icon_state = initial(icon_state) + (isnull(operator) ? "" : "_on")

/obj/item/attachable/motiondetector/equipped(mob/user, slot)
	. = ..()
	if(!ishandslot(slot))
		clean_operator()

/obj/item/attachable/motiondetector/removed_from_inventory(mob/user)
	. = ..()
	clean_operator()

/// Signal handler to clean out user vars
/obj/item/attachable/motiondetector/proc/clean_operator()
	SIGNAL_HANDLER
	if(operator.l_hand == src || operator.r_hand == src || operator.l_hand == loc || operator.r_hand == loc)
		return
	STOP_PROCESSING(SSobj, src)
	clean_blips()
	if(operator)
		if(!QDELETED(operator))
			RegisterSignal(operator, COMSIG_GUN_USER_SET, .proc/start_processing_again)
		UnregisterSignal(operator, list(COMSIG_PARENT_QDELETING, COMSIG_GUN_USER_UNSET))
		UnregisterSignal(src, list(COMSIG_ITEM_EQUIPPED_TO_SLOT, COMSIG_ITEM_REMOVED_INVENTORY))
		operator = null
	update_icon()

/obj/item/attachable/motiondetector/process()
	if(!operator?.client || operator.stat != CONSCIOUS)
		clean_operator()
		return
	hostile_detected = FALSE
	for (var/mob/living/carbon/human/nearby_human AS in cheap_get_humans_near(operator, range))
		if(nearby_human == operator)
			continue
		if(nearby_human.last_move_time + move_sensitivity < world.time)
			continue
		prepare_blip(nearby_human, nearby_human.wear_id?.iff_signal & operator.wear_id.iff_signal ? MOTION_DETECTOR_FRIENDLY : MOTION_DETECTOR_HOSTILE)
	for (var/mob/living/carbon/xenomorph/nearby_xeno AS in cheap_get_xenos_near(operator, range))
		if(nearby_xeno.last_move_time + move_sensitivity < world.time )
			continue
		prepare_blip(nearby_xeno, MOTION_DETECTOR_HOSTILE)
	if(hostile_detected)
		operator.playsound_local(loc, 'sound/items/tick.ogg', 100, 0, 7, 2)
	addtimer(CALLBACK(src, .proc/clean_blips), 1 SECONDS)

///Clean all blips from operator screen
/obj/item/attachable/motiondetector/proc/clean_blips()
	if(!operator)//We already cleaned
		return
	for(var/atom/movable/effect/blip/blip AS in blips_list)
		blip.remove_blip(operator)
	blips_list.Cut()

///Prepare the blip to be print on the operator screen
/obj/item/attachable/motiondetector/proc/prepare_blip(mob/target, status)
	if(!operator.client)
		return
	if(status == MOTION_DETECTOR_HOSTILE)
		hostile_detected = TRUE

	var/list/actualview = getviewsize(operator.client.view)
	var/viewX = actualview[1]
	var/viewY = actualview[2]
	var/turf/center_view = get_view_center(operator)
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
		blips_list += new /atom/movable/effect/blip/edge_blip(null, status, operator, screen_pos_x, screen_pos_y, dir)
		return
	blips_list += new /atom/movable/effect/blip/close_blip(get_turf(target), status, operator)
