///Puts the vehicle into a wrecked state
/obj/vehicle/sealed/armored/proc/wreck_vehicle()
	if(armored_flags & ARMORED_IS_WRECK)
		return FALSE
	for(var/mob/occupant AS in occupants)
		mob_exit(occupant, FALSE, TRUE)
	armored_flags |= ARMORED_IS_WRECK
	obj_integrity = max_integrity
	update_appearance(UPDATE_ICON_STATE|UPDATE_DESC|UPDATE_NAME)
	if(turret_overlay)
		turret_overlay.icon_state += "_wreck"
		turret_overlay?.primary_overlay?.icon_state += "_wreck"
	update_minimap_icon()
	return TRUE

///Attaches plasteel to the wreck, the first stage of extraction
/obj/vehicle/sealed/armored/proc/start_wreck_prep(mob/user, obj/item/stack/sheet/plasteel/plasteel)
	if(armored_flags & ARMORED_WRECK_PREP_STAGE_ONE)
		user.balloon_alert(user, "already prepped")
		return
	if(plasteel.amount < ARMORED_WRECK_PLASTEEL_REQ)
		user.balloon_alert(user, "need [ARMORED_WRECK_PLASTEEL_REQ]")
		return
	if(LAZYACCESS(user.do_actions, src))
		return FALSE
	var/skill_diff = SKILL_ENGINEER_ENGI - user.skills.getRating(SKILL_ENGINEER)
	if((skill_diff > 0) && !do_after(user, skill_diff SECONDS, NONE, src, BUSY_ICON_UNSKILLED))
		return
	if(!do_after(user, (5 + skill_diff) SECONDS, NONE, src, BUSY_ICON_BUILD))
		return
	if(armored_flags & ARMORED_WRECK_PREP_STAGE_ONE)
		user.balloon_alert(user, "already prepped")
		return
	if(!plasteel.use(ARMORED_WRECK_PLASTEEL_REQ))
		user.balloon_alert(user, "need [ARMORED_WRECK_PLASTEEL_REQ]")
		return
	playsound(loc, 'sound/items/ratchet.ogg', 25, TRUE)
	armored_flags |= ARMORED_WRECK_PREP_STAGE_ONE
	balloon_alert_to_viewers("wreck prepped!")

///The fastening process for the fulton on the wreck, the final stage of extraction
/obj/vehicle/sealed/armored/proc/prep_wreck(mob/user)
	if(LAZYACCESS(user.do_actions, src))
		return FALSE
	if(wreck_repair_stage >= ARMORED_WRECK_STAGE_MAX)
		user.balloon_alert(user, "ready to extract")
		return

	var/skill_diff = SKILL_ENGINEER_ENGI - user.skills.getRating(SKILL_ENGINEER)
	if((skill_diff > 0) && !do_after(user, skill_diff SECONDS, NONE, src, BUSY_ICON_UNSKILLED))
		return

	while(wreck_repair_stage < ARMORED_WRECK_STAGE_MAX)
		playsound(loc, 'sound/items/ratchet.ogg', 25, TRUE)
		if(!do_after(user, (5 + skill_diff) SECONDS, NONE, src, BUSY_ICON_BUILD))
			return
		if(wreck_repair_stage >= ARMORED_WRECK_STAGE_MAX)
			return
		wreck_repair_stage++

	balloon_alert_to_viewers("ready to extract!")
	SEND_SIGNAL(src, COMSIG_ARMORED_DO_EXTRACT, user)

///Returns the vehicle to base and restores it to working order
/obj/vehicle/sealed/armored/proc/return_to_base()
	var/turf/return_turf
	for(var/dock in SSshuttle.mobile) //this could be some other landmark
		if(istype(dock, /obj/docking_port/mobile/supply/vehicle))
			return_turf = get_turf(dock)
			break
	if(!return_turf)
		return
	forceMove(return_turf)
	unwreck_vehicle()

///Returns the vehicle to an unwrecked state
/obj/vehicle/sealed/armored/proc/unwreck_vehicle(restore = FALSE)
	if(!(armored_flags & ARMORED_IS_WRECK))
		return FALSE
	armored_flags &= ~(ARMORED_IS_WRECK|ARMORED_WRECK_PREP_STAGE_ONE|ARMORED_WRECK_PREP_STAGE_TWO)
	wreck_repair_stage = 0
	obj_integrity = restore ? max_integrity : 50
	update_appearance(UPDATE_ICON_STATE|UPDATE_DESC|UPDATE_NAME)
	if(turret_overlay)
		UnregisterSignal(turret_overlay, COMSIG_ATOM_DIR_CHANGE)
		turret_overlay.icon_state = turret_overlay.base_icon_state
		turret_overlay?.primary_overlay?.icon_state = turret_overlay?.primary_overlay?.base_icon_state
	update_minimap_icon()
	return TRUE
