
#define MOTION_DETECTOR_LONG		0
#define MOTION_DETECTOR_SHORT		1

#define MOTION_DETECTOR_HOSTILE		0
#define MOTION_DETECTOR_FRIENDLY	1
#define MOTION_DETECTOR_DEAD		2
#define MOTION_DETECTOR_FUBAR		3 //i.e. can't be revived. Might have useful gear to loot though!


/obj/effect/detector_blip
	icon = 'icons/Marine/marine-items.dmi'
	icon_state = "detector_blip"
	var/identifier = MOTION_DETECTOR_HOSTILE
	layer = BELOW_FULLSCREEN_LAYER

	Dispose()
		..()
		return TA_REVIVE_ME

/obj/effect/detector_blip/friendly
	icon_state = "detector_blip_friendly"
	identifier = MOTION_DETECTOR_FRIENDLY

/obj/effect/detector_blip/dead
	icon_state = "detector_blip_dead"
	identifier = MOTION_DETECTOR_DEAD

/obj/effect/detector_blip/fubar
	icon_state = "detector_blip_fubar"
	identifier = MOTION_DETECTOR_FUBAR

/obj/item/device/motiondetector
	name = "tactical sensor"
	desc = "A device that detects hostile movement. Hostiles appear as red blips. Friendlies with the correct IFF signature appear as green, and their bodies as blue, unrevivable bodies as dark blue. It has a mode selection interface."
	icon = 'icons/Marine/marine-items.dmi'
	icon_state = "detector_off"
	item_state = "electronic"
	flags_atom = CONDUCT
	flags_equip_slot = SLOT_WAIST
	var/list/blip_pool = list()
	var/detector_range = 14
	var/detector_mode = MOTION_DETECTOR_LONG
	w_class = 2
	var/active = 0
	var/recycletime = 120
	var/long_range_cooldown = 2
	var/iff_signal = ACCESS_IFF_MARINE
	var/detect_friendlies = TRUE
	var/detect_revivable = TRUE
	var/detect_fubar = TRUE
	var/ping = TRUE

/obj/item/device/motiondetector/examine(mob/user as mob)
	if(get_dist(user,src) > 2)
		to_chat(user, "<span class = 'warning'>You're too far away to see [src]'s display!</span>")
	else
		var/details
		details += "[active ? " <b>Power:</b> ON</br>" : " <b>Power:</b> OFF</br>"]"
		details += "[detect_friendlies ? " <b>Friendly detection:</b> ACTIVE</br>" : " <b>Friendly detection:</b> INACTIVE</br>"]"
		details += "[detect_revivable ? " <b>Friendly revivable corpse detection:</b> ACTIVE</br>" : " <b>Friendly revivable corpse detection:</b> INACTIVE</br>"]"
		details += "[detect_fubar ? " <b>Friendly unrevivable corpse detection:</b> ACTIVE</br>" : " <b>Friendly unrevivable corpse detection:</b> INACTIVE</br>"]"
		to_chat(user, "<span class = 'notice'>[src]'s display shows the following settings:</br>[details]</span>")
	return ..()


/obj/item/device/motiondetector/Dispose()
	processing_objects.Remove(src)
	for(var/obj/X in blip_pool)
		cdel(X)
	blip_pool = list()
	..()

/obj/item/device/motiondetector/update_icon()
	if(active)
		icon_state = "detector_on_[detector_mode]"
	else
		icon_state = "detector_off"
	return ..()

/obj/item/device/motiondetector/process()
	if(!active)
		update_icon()
		processing_objects.Remove(src)
		return

	var/mob/living/carbon/human/human_user
	if(ishuman(loc))
		human_user = loc
	else
		active = FALSE
		update_icon()
		processing_objects.Remove(src)
		return

	recycletime--
	if(!recycletime)
		recycletime = initial(recycletime)
		for(var/X in blip_pool) //we dump and remake the blip pool every few minutes
			if(blip_pool[X])	//to clear blips assigned to mobs that are long gone.
				cdel(blip_pool[X]) //the blips are garbage-collected and reused via rnew() below
		blip_pool = list()

	if(!detector_mode)
		long_range_cooldown--
		if(long_range_cooldown) return
		else long_range_cooldown = initial(long_range_cooldown)

	if(ping)
		playsound(loc, 'sound/items/detector.ogg', 60, 0, 7, 2)

	var/detected
	var/status
	for(var/mob/living/M in orange(detector_range, human_user))
		if(!isturf(M.loc))
			continue
		if(isrobot(M))
			continue
		status = MOTION_DETECTOR_HOSTILE //Reset the status to default
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.get_target_lock(iff_signal)) //device checks for IFF data and status
				if(M.stat == DEAD)
					if(H.is_revivable() && H.get_ghost())
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
		if(world.time > M.l_move_time + 20 && (status == MOTION_DETECTOR_HOSTILE))
			continue //hasn't moved recently

		detected = TRUE

		if(human_user)
			show_blip(human_user, M, status)

		if(detected && ping)
			playsound(loc, 'sound/items/tick.ogg', 50, 0, 7, 2)


/obj/item/device/motiondetector/proc/show_blip(mob/user, mob/target, status)
	set waitfor = 0
	if(user.client)

		if(!blip_pool[target])
			switch(status)
				if(MOTION_DETECTOR_HOSTILE)
					blip_pool[target] = rnew(/obj/effect/detector_blip)
					//blip_pool[target].icon_state = "detector_blip_friendly"
				if(MOTION_DETECTOR_FRIENDLY)
					blip_pool[target] = rnew(/obj/effect/detector_blip/friendly)
					//blip_pool[target].icon_state = "detector_blip_friendly"
				if(MOTION_DETECTOR_DEAD)
					blip_pool[target] = rnew(/obj/effect/detector_blip/dead)
					//blip_pool[target].icon_state = "detector_blip_dead"
				if(MOTION_DETECTOR_FUBAR)
					blip_pool[target] = rnew(/obj/effect/detector_blip/fubar)
					//blip_pool[target].icon_state = "detector_blip_fubar"

		var/obj/effect/detector_blip/DB = blip_pool[target]
		var/c_view = user.client.view
		var/view_x_offset = 0
		var/view_y_offset = 0
		if(c_view > 7)
			if(user.client.pixel_x >= 0) view_x_offset = round(user.client.pixel_x/32)
			else view_x_offset = CEILING(user.client.pixel_x/32, 1)
			if(user.client.pixel_y >= 0) view_y_offset = round(user.client.pixel_y/32)
			else view_y_offset = CEILING(user.client.pixel_y/32, 1)

		var/diff_dir_x = 0
		var/diff_dir_y = 0
		if(target.x - user.x > c_view + view_x_offset) diff_dir_x = 4
		else if(target.x - user.x < -c_view + view_x_offset) diff_dir_x = 8
		if(target.y - user.y > c_view + view_y_offset) diff_dir_y = 1
		else if(target.y - user.y < -c_view + view_y_offset) diff_dir_y = 2
		if(diff_dir_x || diff_dir_y)
			switch(status)
				if(MOTION_DETECTOR_HOSTILE)
					DB.icon_state = "detector_blip_dir"
				if(MOTION_DETECTOR_FRIENDLY)
					DB.icon_state = "detector_blip_dir_friendly"
				if(MOTION_DETECTOR_DEAD)
					DB.icon_state = "detector_blip_dir_dead"
				if(MOTION_DETECTOR_FUBAR)
					DB.icon_state = "detector_blip_dir_fubar"
			DB.dir = diff_dir_x + diff_dir_y

		else
			DB.dir = initial(DB.dir) //Update the ping sprite
			switch(status)
				if(MOTION_DETECTOR_HOSTILE)
					DB.icon_state = "detector_blip"
				if(MOTION_DETECTOR_FRIENDLY)
					DB.icon_state = "detector_blip_friendly"
				if(MOTION_DETECTOR_DEAD)
					DB.icon_state = "detector_blip_dead"
				if(MOTION_DETECTOR_FUBAR)
					DB.icon_state = "detector_blip_fubar"

		DB.screen_loc = "[CLAMP(c_view + 1 - view_x_offset + (target.x - user.x), 1, 2*c_view+1)],[CLAMP(c_view + 1 - view_y_offset + (target.y - user.y), 1, 2*c_view+1)]"
		user.client.screen += DB
		sleep(12)
		if(user.client)
			user.client.screen -= DB

/obj/item/device/motiondetector/pmc
	name = "motion detector (PMC)"
	desc = "A device that detects hostile movement. Hostiles appear as red blips. Friendlies with the correct IFF signature appear as green, and their bodies as blue, unrevivable bodies as dark blue. It has a mode selection interface. This one has been modified for use by the W-Y PMC forces."
	iff_signal = ACCESS_IFF_PMC


/obj/item/device/motiondetector/Topic(href, href_list)
	//..()
	if(usr.stat || usr.is_mob_restrained())
		return
	if(((istype(usr, /mob/living/carbon/human) && ((!( ticker ) || (ticker && ticker.mode != "monkey")) && usr.contents.Find(src))) || (usr.contents.Find(master) || (in_range(src, usr) && istype(loc, /turf)))))
		usr.set_interaction(src)
		if(href_list["power"])
			active = !active
			if(active)
				to_chat(usr, "<span class='notice'>You activate [src].</span>")
				processing_objects.Add(src)
			else
				to_chat(usr, "<span class='notice'>You deactivate [src].</span>")
				processing_objects.Remove(src)
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

		if(!( master ))
			if(istype(loc, /mob))
				attack_self(loc)
			else
				for(var/mob/M in viewers(1, src))
					if(M.client)
						attack_self(M)
		else
			if(istype(master.loc, /mob))
				attack_self(master.loc)
			else
				for(var/mob/M in viewers(1, master))
					if(M.client)
						attack_self(M)
	else
		usr << browse(null, "window=radio")
		return
	return

/obj/item/device/motiondetector/attack_self(mob/user as mob, flag1)
	if(!istype(user, /mob/living/carbon/human))
		return
	user.set_interaction(src)
	var/dat = {"<TT>

<A href='?src=\ref[src];power=1'><B>Power Control:</B>  [active ? "Off" : "On"]</A><BR>
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
<A href='?src=\ref[src];detect_fubar=1'><B>Set Unrevivable Detection:</B> [detect_fubar ? "Off" : "On"]</A><BR>
 </TT>"}
	user << browse(dat, "window=radio")
	onclose(user, "radio")
	return

/obj/item/device/motiondetector/scout
	name = "MK2 recon tactical sensor"
	desc = "A device that detects hostile movement; this one is specially minaturized for reconnaissance units. Hostiles appear as red blips. Friendlies with the correct IFF signature appear as green, and their bodies as blue, unrevivable bodies as dark blue. It has a mode selection interface."
	icon_state = "minidetector_off"
	w_class = 1 //We can have this in our pocket and still get pings
	ping = FALSE //Stealth modo

/obj/item/device/motiondetector/scout/update_icon()
	if(active)
		icon_state = "minidetector_on_[detector_mode]"
	else
		icon_state = "minidetector_off"
	return ..()
