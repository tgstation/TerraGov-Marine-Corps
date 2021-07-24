
#define MOTION_DETECTOR_LONG 0
#define MOTION_DETECTOR_SHORT 1

#define MOTION_DETECTOR_HOSTILE ""
#define MOTION_DETECTOR_FRIENDLY "_friendly"
#define MOTION_DETECTOR_DEAD "_dead"
#define MOTION_DETECTOR_FUBAR "_fubar" //i.e. can't be revived. Might have useful gear to loot though!


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

/obj/effect/detector_blip/fubar
	icon_state = "detector_blip_fubar"
	identifier = MOTION_DETECTOR_FUBAR

/obj/effect/detector_blip/Destroy()
	center = null
	target_turf = null
	return ..()

/obj/effect/detector_blip/update_icon_state()
	icon_state = "detector_blip[edge_blip ? "_dir" : ""][identifier]"

/obj/item/motiondetector
	name = "tactical sensor"
	desc = "A device that detects hostile movement. Hostiles appear as red blips. Friendlies with the correct IFF signature appear as green, and their bodies as blue, unrevivable bodies as dark blue. It has a mode selection interface."
	icon = 'icons/Marine/marine-items.dmi'
	icon_state = "detector_off"
	item_state = "electronic"
	flags_atom = CONDUCT
	flags_equip_slot = ITEM_SLOT_BELT
	var/list/blip_pool = list()
	var/detector_range = 14
	var/detector_mode = MOTION_DETECTOR_LONG
	w_class = WEIGHT_CLASS_SMALL
	var/recycletime = 120
	var/long_range_cooldown = 2
	/// Iff signal to distinguish friendlies from foes
	var/iff_signal = NONE
	var/detect_friendlies = TRUE
	var/detect_revivable = TRUE
	var/detect_fubar = TRUE
	var/ping = TRUE
	var/mob/living/carbon/human/operator

/obj/item/motiondetector/examine(mob/user as mob)
	. = ..()
	if(get_dist(user,src) > 2)
		to_chat(user, "<span class = 'warning'>You're too far away to see [src]'s display!</span>")
	else
		var/details
		details += "[active ? " <b>Power:</b> ON</br>" : " <b>Power:</b> OFF</br>"]"
		details += "[detect_friendlies ? " <b>Friendly detection:</b> ACTIVE</br>" : " <b>Friendly detection:</b> INACTIVE</br>"]"
		details += "[detect_revivable ? " <b>Friendly revivable corpse detection:</b> ACTIVE</br>" : " <b>Friendly revivable corpse detection:</b> INACTIVE</br>"]"
		details += "[detect_fubar ? " <b>Friendly unrevivable corpse detection:</b> ACTIVE</br>" : " <b>Friendly unrevivable corpse detection:</b> INACTIVE</br>"]"
		to_chat(user, "<span class = 'notice'>[src]'s display shows the following settings:</br>[details]</span>")


/obj/item/motiondetector/Destroy()
	STOP_PROCESSING(SSobj, src)
	for(var/obj/X in blip_pool)
		qdel(X)
	blip_pool = list()
	return ..()

/obj/item/motiondetector/dropped(mob/user)
	. = ..()
	operator = null


/obj/item/motiondetector/update_icon()
	if(active)
		icon_state = "detector_on_[detector_mode]"
	else
		icon_state = "detector_off"
	return ..()

/obj/item/motiondetector/proc/deactivate()
	active = FALSE
	operator = null
	update_icon()
	STOP_PROCESSING(SSobj, src)

/obj/item/motiondetector/process()
	if(!active)
		deactivate()
		return

	if(!operator)
		deactivate()
		return

	if(get_turf(src) != get_turf(operator))
		deactivate()
		return

	if(operator.stat == DEAD)
		deactivate()
		return

	if(!operator.client)
		deactivate()
		return

	recycletime--
	if(!recycletime)
		recycletime = initial(recycletime)
		for(var/X in blip_pool) //we dump and remake the blip pool every few minutes
			if(blip_pool[X])	//to clear blips assigned to mobs that are long gone.
				qdel(blip_pool[X]) //the blips are garbage-collected and reused via rnew() below
		blip_pool = list()

	if(!detector_mode)
		long_range_cooldown--
		if(long_range_cooldown)
			return
		else
			long_range_cooldown = initial(long_range_cooldown)

	if(ping)
		playsound(loc, 'sound/items/detector.ogg', 60, 0, 7, 2)

	var/detected
	var/status
	for(var/mob/living/M in orange(detector_range, operator))
		if(!isturf(M.loc))
			continue
		status = MOTION_DETECTOR_HOSTILE //Reset the status to default
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(!(H.wear_id?.iff_signal & iff_signal)) //device checks for IFF data and status
				if(M.stat == DEAD)
					if(H.has_working_organs() && H.get_ghost())
						if(detect_revivable)
							status = MOTION_DETECTOR_DEAD //Dead, but revivable.
						else
							continue
					else
						if(detect_fubar)
							status = MOTION_DETECTOR_FUBAR //Dead and unrevivable; FUBAR
						else
							continue
				else
					if(detect_friendlies)
						status = MOTION_DETECTOR_FRIENDLY
					else
						continue
		if(world.time > M.last_move_time + 20 && (status == MOTION_DETECTOR_HOSTILE))
			continue //hasn't moved recently

		detected = TRUE

		show_blip(operator, M, status)

		if(detected && ping)
			playsound(loc, 'sound/items/tick.ogg', 50, 0, 7, 2)


/obj/item/motiondetector/proc/show_blip(mob/user, mob/target, status)
	if(!user.client)
		return
	if(!blip_pool[target])
		switch(status)
			if(MOTION_DETECTOR_HOSTILE)
				blip_pool[target] = new /obj/effect/detector_blip()
			if(MOTION_DETECTOR_FRIENDLY)
				blip_pool[target] = new /obj/effect/detector_blip/friendly()
			if(MOTION_DETECTOR_DEAD)
				blip_pool[target] = new /obj/effect/detector_blip/dead()
			if(MOTION_DETECTOR_FUBAR)
				blip_pool[target] = new /obj/effect/detector_blip/fubar()

	var/obj/effect/detector_blip/DB = blip_pool[target]
	var/turf/center_view = get_turf(user)
	if(user.client.pixel_x || user.client.pixel_y)
		var/view_x_offset
		if(user.client.pixel_x >= 0)
			view_x_offset = round(user.client.pixel_x / 32) //Floor.
		else
			view_x_offset = CEILING(user.client.pixel_x / 32, 1)
		var/view_y_offset
		if(user.client.pixel_y >= 0)
			view_y_offset = round(user.client.pixel_y / 32) //Floor.
		else
			view_y_offset = CEILING(user.client.pixel_y / 32, 1)
		center_view = locate(user.x + view_x_offset, user.y + view_y_offset, user.z)

	if(target in range(user.client.view, center_view))
		DB.setDir(initial(DB.dir)) //Update the ping sprite
		DB.edge_blip = FALSE
	else
		DB.setDir(get_dir(center_view, target))
		DB.edge_blip = TRUE
	DB.update_icon()

	var/list/actualview = getviewsize(user.client.view)
	var/viewX = actualview[1]
	var/viewY = actualview[2]
	var/screen_pos_x = clamp(target.x - center_view.x + round(viewX * 0.5) + 1, 1, viewX)
	var/screen_pos_y = clamp(target.y - center_view.y + round(viewY * 0.5) + 1, 1, viewY)
	DB.screen_loc = "[screen_pos_x],[screen_pos_y]"
	DB.center = center_view
	DB.target_turf = get_turf(target)
	DB.apply_bip(user)


/obj/effect/detector_blip/proc/apply_bip(mob/user)
	if(!user?.client)
		return
	user.client.screen += src
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, .proc/on_movement)
	addtimer(CALLBACK(src, .proc/remove_blip, user), 1 SECONDS)


/obj/effect/detector_blip/proc/remove_blip(mob/user)
	center = null
	target_turf = null
	if(QDELETED(user))
		return
	UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
	if(!user?.client)
		return
	user.client.screen -= src


/obj/effect/detector_blip/proc/on_movement(datum/source, atom/oldloc, direction, Forced)
	SIGNAL_HANDLER
	var/mob/user = source
	if(!user.client || user.z != oldloc.z)
		remove_blip(user)
		return
	var/x_movement = user.x - oldloc.x
	var/y_movement = user.y - oldloc.y
	center = locate(center.x + x_movement, center.y + y_movement, center.z)
	var/list/temp_list = getviewsize(user.client.view)
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

/obj/item/motiondetector/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(href_list["power"])
		active = !active
		if(active)
			to_chat(usr, "<span class='notice'>You activate [src].</span>")
			operator = usr
			var/obj/item/card/id/id = operator.get_idcard()
			iff_signal = id?.iff_signal
			START_PROCESSING(SSobj, src)
		else
			to_chat(usr, "<span class='notice'>You deactivate [src].</span>")
			STOP_PROCESSING(SSobj, src)
		update_icon()

	else if(href_list["detector_mode"])
		detector_mode = !detector_mode
		if(detector_mode)
			to_chat(usr, "<span class='notice'>You switch [src] to short range mode.</span>")
			detector_range = 7
		else
			to_chat(usr, "<span class='notice'>You switch [src] to long range mode.</span>")
			detector_range = 14

	else if(href_list["detect_friendlies"])
		detect_friendlies = !( detect_friendlies )

	else if(href_list["detect_revivable"])
		detect_revivable = !( detect_revivable )

	else if(href_list["detect_fubar"])
		detect_fubar = !( detect_fubar )

	update_icon()
	updateUsrDialog()


/obj/item/motiondetector/interact(mob/user)
	. = ..()
	if(.)
		return

	var/dat = {"
<A href='?src=\ref[src];power=1'><B>Power Control:</B>  [active ? "On" : "Off"]</A><BR>
<BR>
<B>Detection Settings:</B><BR>
<BR>
<B>Detection Mode:</B> [detector_mode ? "Short Range" : "Long Range"]<BR>
<A href='?src=\ref[src];detector_mode=1'><B>Set Detector Mode:</B> [detector_mode ? "Long Range" : "Short Range"]</A><BR>
<BR>
<B>Friendly Detection Status:</B> [detect_friendlies ? "ACTIVE" : "INACTIVE"]<BR>
<A href='?src=\ref[src];detect_friendlies=1'><B>Set Friendly Detection:</B> [detect_friendlies ? "Off" : "On"]</A><BR>
<BR>
<B>Revivable Detection Status:</B> [detect_revivable ? "ACTIVE" : "INACTIVE"]<BR>
<A href='?src=\ref[src];detect_revivable=1'><B>Set Revivable Detection:</B> [detect_revivable ? "Off" : "On"]</A><BR>
<BR>
<B>Unrevivable Detection Status:</B> [detect_fubar ? "ACTIVE" : "INACTIVE"]<BR>
<A href='?src=\ref[src];detect_fubar=1'><B>Set Unrevivable Detection:</B> [detect_fubar ? "Off" : "On"]</A><BR>"}

	var/datum/browser/popup = new(user, "motiondetector")
	popup.set_content(dat)
	popup.open()


/obj/item/motiondetector/scout
	name = "MK2 recon tactical sensor"
	desc = "A device that detects hostile movement; this one is specially minaturized for reconnaissance units. Hostiles appear as red blips. Friendlies with the correct IFF signature appear as green, and their bodies as blue, unrevivable bodies as dark blue. It has a mode selection interface."
	icon_state = "minidetector_off"
	w_class = WEIGHT_CLASS_TINY //We can have this in our pocket and still get pings
	ping = FALSE //Stealth modo


/obj/item/motiondetector/scout/update_icon()
	if(active)
		icon_state = "minidetector_on_[detector_mode]"
	else
		icon_state = "minidetector_off"
