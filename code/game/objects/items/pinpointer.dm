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


/obj/item/pinpointer/proc/set_target(mob/living/user)
	if(!length(tracked_list))
		to_chat(user, span_warning("No traceable signals found!"))
		return
	target = tgui_input_list(user, "Select the item you wish to track.", "Pinpointer", tracked_list)
	if(QDELETED(target))
		return
	var/turf/pinpointer_loc = get_turf(src)
	if(target.z != pinpointer_loc.z)
		to_chat(user, span_warning("Chosen target signal too weak. Choose another."))
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
	to_chat(user, span_notice("You activate the pinpointer"))


/obj/item/pinpointer/proc/deactivate(mob/living/user)
	active = FALSE
	target = null
	STOP_PROCESSING(SSobj, src)
	icon_state = "pinoff"
	to_chat(user, span_notice("You deactivate the pinpointer"))


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

/obj/item/pinpointer/crash
	name = "nuke pinpointer"
	desc = "A pinpointer designed to detect the encrypted emissions of nuclear devices"


/obj/item/pinpointer/crash/Initialize()
	. = ..()
	tracked_list += GLOB.nuke_disk_generators
	tracked_list += GLOB.nuke_list


/obj/item/pinpointer/crash/examine(mob/user)
	. = ..()
	for(var/i in GLOB.nuke_list)
		var/obj/machinery/nuclearbomb/bomb = i
		if(!bomb.timer_enabled)
			continue
		to_chat(user, "Extreme danger.  Arming signal detected.   Time remaining: [bomb.timeleft]")

/obj/item/pinpointer/pool
	name = "pool pinpointer"
	desc = "A pinpointer able to detect the psychic energy emmaning from spawning pools"

/obj/item/pinpointer/pool/Initialize()
	. = ..()
	tracked_list = GLOB.xeno_resin_silos
