///Remove the blip from the operator screen
/obj/effect/blip/proc/remove_blip(mob/operator)
	return

/obj/effect/blip/edge_blip
	icon = 'icons/effects/blips.dmi'
	plane = ABOVE_HUD_PLANE
	/// A friendly/hostile identifier
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

///Remove the blip from the operator screen
/obj/effect/blip/edge_blip/remove_blip(mob/operator)
	operator?.client?.screen -= src
	qdel(src)

/obj/effect/blip/edge_blip/update_icon_state()
	. = ..()
	icon_state = "edge_blip_[identifier]"

/obj/effect/blip/close_blip
	plane = ABOVE_HUD_PLANE
	var/image/blip_image

/obj/effect/blip/close_blip/Initialize(mapload, identifier, mob/user)
	. = ..()
	if(!user?.client)
		return INITIALIZE_HINT_QDEL
	blip_image = image('icons/effects/blips.dmi', src, "close_blip_[identifier]")
	SET_PLANE_EXPLICIT(blip_image, ABOVE_HUD_PLANE, src)
	user.client.images += blip_image

/// Remove the blip from the operator images
/obj/effect/blip/close_blip/remove_blip(mob/user)
	user?.client?.images -= blip_image
	qdel(src)

/obj/effect/blip/close_blip/Destroy()
	blip_image = null
	return ..()

/obj/item/attachable/motiondetector
	name = "tactical sensor"
	desc = "A device that detects hostile movement. Hostiles appear as red blips. Friendlies with the correct IFF signature appear as green, and their bodies as blue, unrevivable bodies as dark blue. It has a mode selection interface."
	icon_state = "minidetector"
	icon = 'icons/obj/items/guns/attachments/rail.dmi'
	slot = ATTACHMENT_SLOT_RAIL
	attachment_action_type = /datum/action/item_action/toggle
	/// Who's using this item
	var/mob/living/carbon/human/operator
	///If a hostile was detected
	var/hostile_detected = FALSE
	///The time needed after the last move to not be detected by this motion detector
	var/move_sensitivity = 1 SECONDS
	///The range of this motion detector
	var/range = 16
	///The list of all the blips
	var/list/obj/effect/blip/blips_list = list()

/obj/item/attachable/motiondetector/Destroy()
	clean_operator(forced = TRUE)
	return ..()

/obj/item/attachable/motiondetector/activate(mob/user, turn_off)
	if(operator)
		clean_operator(forced = TRUE)
		return TRUE
	operator = user
	RegisterSignals(operator, list(COMSIG_QDELETING, COMSIG_GUN_USER_UNSET), PROC_REF(clean_operator))
	RegisterSignals(src, list(COMSIG_ITEM_EQUIPPED_TO_SLOT, COMSIG_ITEM_REMOVED_INVENTORY), PROC_REF(clean_operator))
	UnregisterSignal(operator, COMSIG_GUN_USER_SET)
	START_PROCESSING(SSobj, src)
	update_icon()
	return TRUE

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

/obj/item/attachable/motiondetector/update_icon_state()
	. = ..()
	icon_state = initial(icon_state) + (isnull(operator) ? "" : "_on")

/obj/item/attachable/motiondetector/equipped(mob/user, slot)
	. = ..()
	if(!ishandslot(slot))
		clean_operator()

/obj/item/attachable/motiondetector/removed_from_inventory(mob/user)
	. = ..()
	clean_operator(forced = TRUE) //Exploit prevention. If you are putting the tac sensor into a storage in your hand (Like holding a satchel), hand == loc will return

/// Signal handler to clean out user vars
/obj/item/attachable/motiondetector/proc/clean_operator(datum/source, obj/item/weapon/gun/gun, forced = FALSE)
	SIGNAL_HANDLER
	if(!forced && operator && (operator.l_hand == src || operator.r_hand == src || operator.l_hand == loc || operator.r_hand == loc))
		return
	STOP_PROCESSING(SSobj, src)
	clean_blips()
	if(operator)
		if(!QDELETED(operator))
			RegisterSignal(operator, COMSIG_GUN_USER_SET, PROC_REF(start_processing_again))
		UnregisterSignal(operator, list(COMSIG_QDELETING, COMSIG_GUN_USER_UNSET))
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
		playsound(loc, 'sound/items/tick.ogg', 100, 0, 7, 2)
	addtimer(CALLBACK(src, PROC_REF(clean_blips)), 1 SECONDS)

///Clean all blips from operator screen
/obj/item/attachable/motiondetector/proc/clean_blips()
	if(!operator)//We already cleaned
		return
	for(var/obj/effect/blip/blip AS in blips_list)
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
		blips_list += new /obj/effect/blip/edge_blip(null, status, operator, screen_pos_x, screen_pos_y, dir)
		return
	blips_list += new /obj/effect/blip/close_blip(get_turf(target), status, operator)
