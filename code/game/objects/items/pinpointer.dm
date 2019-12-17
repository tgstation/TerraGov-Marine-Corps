#define PINPOINTER_MODE_DISK "disk"
#define PINPOINTER_MODE_DISK_GENERATOR "disk_generator"
#define PINPOINTER_MODE_NUKE "nuke"


/obj/item/pinpointer
	name = "pinpointer"
	icon_state = "pinoff"
	flags_atom = CONDUCT
	flags_equip_slot = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_TINY
	item_state = "electronic"
	throw_speed = 4
	throw_range = 20
	var/atom/movable/target
	var/list/tracked_list
	var/mode = PINPOINTER_MODE_DISK


/obj/item/pinpointer/Initialize()
	. = ..()
	switch(mode)
		if(PINPOINTER_MODE_DISK)
			tracked_list = GLOB.nuke_disk_list
		if(PINPOINTER_MODE_DISK_GENERATOR)
			tracked_list = GLOB.nuke_disk_generators
		if(PINPOINTER_MODE_NUKE)
			tracked_list = GLOB.nuke_list


/obj/item/pinpointer/examine(mob/user)
	. = ..()
	switch(mode)
		if(PINPOINTER_MODE_DISK, PINPOINTER_MODE_DISK_GENERATOR, PINPOINTER_MODE_NUKE)
			for(var/i in GLOB.nuke_list)
				var/obj/machinery/nuclearbomb/bomb = i
				if(!bomb.timer_enabled)
					continue
				to_chat(user, "Extreme danger.  Arming signal detected.   Time remaining: [bomb.timeleft]")


/obj/item/pinpointer/proc/set_target(mob/living/user)
	if(!length(tracked_list))
		to_chat(user, "<span class='warning'>No traceable signals found!</span>")
		return
	target = input("Select the item you wish to track.", "Pinpointer") as null|anything in tracked_list
	if(QDELETED(target))
		return
	var/turf/disk_loc = get_turf(src)
	if(target.z != disk_loc.z)
		to_chat(user, "<span class='warning'>Chosen target signal too weak. Choose another.</span>")
		target = null
		return


/obj/item/pinpointer/attack_self(mob/living/user)
	if(active)
		deactivate(user)
	else
		activate(user)


/obj/item/pinpointer/proc/activate(mob/living/user)
	set_target(user)
	if(!target)
		return
	active = TRUE
	START_PROCESSING(SSobj, src)
	to_chat(user, "<span class='notice'>You activate the pinpointer</span>")


/obj/item/pinpointer/proc/deactivate(mob/living/user)
	active = FALSE
	target = null
	STOP_PROCESSING(SSobj, src)
	icon_state = "pinoff"
	to_chat(user, "<span class='notice'>You deactivate the pinpointer</span>")


/obj/item/pinpointer/process()
	if(!target)
		icon_state = "pinonnull"
		active = FALSE
		return

	setDir(get_dir(src, target))
	switch(get_dist(src, target))
		if(0)
			icon_state = "pinondirect"
		if(1 to 8)
			icon_state = "pinonclose"
		if(9 to 16)
			icon_state = "pinonmedium"
		if(16 to INFINITY)
			icon_state = "pinonfar"


/obj/item/pinpointer/advpinpointer
	name = "advanced pinpointer"
	desc = "A larger version of the normal pinpointer, this unit features a helpful quantum entanglement detection system to locate various objects that do not broadcast a locator signal."
	mode = PINPOINTER_MODE_DISK_GENERATOR


/obj/item/pinpointer/advpinpointer/verb/toggle_mode()
	set category = "Object"
	set name = "Toggle Pinpointer Mode"
	set src in view(1)

	if(active)
		deactivate()

	switch(alert("Please select the mode you want to put the pinpointer in.", "Pinpointer Mode Select", "Disk Recovery", "Disk Generator Tracking", "Nuclear Fission Device Tracking"))
		if("Disk Recovery")
			do_toggle_mode(PINPOINTER_MODE_DISK)
			activate(usr)
			return
		if("Disk Generator Tracking")
			do_toggle_mode(PINPOINTER_MODE_DISK_GENERATOR)
			activate(usr)
			return
		if("Nuclear Fission Device Tracking")
			do_toggle_mode(PINPOINTER_MODE_NUKE)
			activate(usr)
			return


/obj/item/pinpointer/advpinpointer/proc/do_toggle_mode(new_mode)
	switch(new_mode)
		if(PINPOINTER_MODE_DISK)
			tracked_list = GLOB.nuke_disk_list
		if(PINPOINTER_MODE_DISK_GENERATOR)
			tracked_list = GLOB.nuke_disk_generators
		if(PINPOINTER_MODE_NUKE)
			tracked_list = GLOB.nuke_list
		else
			CRASH("do_toggle_mode called with an invalid new_mode")
	mode = new_mode


#undef PINPOINTER_MODE_DISK
#undef PINPOINTER_MODE_DISK_GENERATOR
#undef PINPOINTER_MODE_NUKE
