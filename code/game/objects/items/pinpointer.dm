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
		to_chat(user, "<span class='warning'>No traceable signals found!</span>")
		return
	target = tgui_input_list(user, "Select the item you wish to track.", "Pinpointer", tracked_list)
	if(QDELETED(target))
		return
	var/turf/pinpointer_loc = get_turf(src)
	if(target.z != pinpointer_loc.z)
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

/obj/item/psy_tracker
	name = "psy tracker"
	desc = "A pinpointer able to detect the psychic energy emmaning from resin silos, and from the hive ruler if there are no silos"
	icon_state = "pinoff"
	flags_atom = CONDUCT
	flags_equip_slot = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_TINY
	item_state = "electronic"
	throw_speed = 4
	throw_range = 20
	/// The atom tracked by the psy tracker
	var/atom/target

/obj/item/psy_tracker/Initialize()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_SILO_CREATED, .proc/silo_created)
	RegisterSignal(SSdcs, COMSIG_SILO_DESTROYED, .proc/silo_destroyed)

/obj/item/psy_tracker/proc/set_target(atom/_target)
	if(target == _target)
		return
	if(target)
		UnregisterSignal(target, COMSIG_PARENT_QDELETING)
	target = _target
	if(target)
		START_PROCESSING(SSobj, src)
		RegisterSignal(target, COMSIG_PARENT_QDELETING, .proc/clean_target)

/// Signal handler to prevent hard del of target
/obj/item/psy_tracker/proc/clean_target()
	SIGNAL_HANDLER
	set_target(null)
	STOP_PROCESSING(SSobj, src)

/// Signal handler to notify the psy tracker user that a new silo has been created
/obj/item/psy_tracker/proc/silo_created()
	SIGNAL_HANDLER
	if(!istype(target, /obj/structure/resin/silo))
		set_target(null)
	if(!is_ground_level(loc.z))
		return
	say("A new silo has been created, total number of psy sources : [GLOB.xeno_resin_silos.len]")

/// Signal handler to notify the psy tracker user that a silo has been destroyed
/obj/item/psy_tracker/proc/silo_destroyed(datum/source)
	SIGNAL_HANDLER
	if(!is_ground_level(loc.z))
		return
	say("A silo has been destroyed, total number of psy sources : [GLOB.xeno_resin_silos.len]")

/obj/item/psy_tracker/attack_self(mob/living/user)
	if(!is_ground_level(loc.z))
		to_chat(user, "<span class='warning'>No signals has been detected, interferences from ship is the most likely cause.</span>")
		return
	if(!GLOB.xeno_resin_silos.len)
		to_chat(user, "<span class='warning'>No silo signal detected.</span>")
		var/datum/hive_status/normal_hive = GLOB.hive_datums[XENO_HIVE_NORMAL]
		if(!normal_hive.living_xeno_ruler)
			return
		to_chat(user, "<span class='warning'>Able to track a weaker mobile psy source!</span>")
		set_target(normal_hive.living_xeno_ruler)
		return
	set_target(tgui_input_list(user, "Select the silo you wish to track.", "Psy tracker", GLOB.xeno_resin_silos))

/obj/item/psy_tracker/process()
	if(!target)
		icon_state = "pinonnull"
		STOP_PROCESSING(SSobj, src)
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
