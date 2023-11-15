/obj/item/pinpointer
	name = "Xeno structure pinpointer"
	icon = 'icons/Marine/marine-navigation.dmi'
	icon_state = "pinoff"
	flags_atom = CONDUCT
	flags_equip_slot = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_TINY
	item_icons = list(
		slot_l_hand_str = 'icons/mob/inhands/equipment/engineering_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/equipment/engineering_right.dmi',
	)
	item_state = "electronic"
	throw_speed = 4
	throw_range = 20
	///What we're currently tracking
	var/atom/movable/target
	///The list of things we're tracking
	var/list/tracked_list
	///The hive we're tracking
	var/tracked_hivenumber = XENO_HIVE_NORMAL
	///The list of hives we will never track
	var/static/list/blacklisted_hivenumbers = list(XENO_HIVE_NONE, XENO_HIVE_ADMEME, XENO_HIVE_FALLEN)

/obj/item/pinpointer/Initialize(mapload)
	. = ..()
	tracked_list = GLOB.xeno_critical_structures_by_hive[tracked_hivenumber]

/obj/item/pinpointer/Destroy()
	target = null
	return ..()

/obj/item/pinpointer/proc/set_target(mob/living/user)
	///The hivenumbers that we're allowed to select structures to track from
	var/list/trackable_hivenumbers = list()
	for(var/hivenumber in GLOB.xeno_critical_structures_by_hive)
		if(hivenumber in blacklisted_hivenumbers) //no reason to ever track valhalla or admin beans
			continue
		if(!length(GLOB.xeno_critical_structures_by_hive[hivenumber])) //hives with no structures don't need tracking either
			continue
		trackable_hivenumbers |= hivenumber

	if(length(trackable_hivenumbers) == 1)
		tracked_list = GLOB.xeno_critical_structures_by_hive[trackable_hivenumbers[1]]

	else if(length(trackable_hivenumbers) > 1)
		tracked_hivenumber = tgui_input_list(user, "Select the hive you wish to track.", "Pinpointer", trackable_hivenumbers)
		if(!tracked_hivenumber)
			return
		tracked_list = GLOB.xeno_critical_structures_by_hive[tracked_hivenumber]

	if(!length(tracked_list))
		balloon_alert(user, "No signal")
		return
	target = tgui_input_list(user, "Select the structure you wish to track.", "Pinpointer", tracked_list)
	if(QDELETED(target))
		return
	var/turf/pinpointer_loc = get_turf(src)
	if(target.z != pinpointer_loc.z)
		balloon_alert(user, "Signal too weak")
		target = null
		return


/obj/item/pinpointer/attack_self(mob/living/user)
	if(active)
		deactivate(user)
	else
		activate(user)


/obj/item/pinpointer/proc/activate(mob/living/user)
	set_target(user)
	if(QDELETED(target))
		return
	active = TRUE
	START_PROCESSING(SSobj, src)
	balloon_alert(user, "Pinpointer activated")


/obj/item/pinpointer/proc/deactivate(mob/living/user)
	active = FALSE
	target = null
	STOP_PROCESSING(SSobj, src)
	icon_state = "pinoff"
	balloon_alert(user, "Pinpointer deactivated")


/obj/item/pinpointer/process()
	if(QDELETED(target))
		active = FALSE
		icon_state = "pinonnull"
		return PROCESS_KILL

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

