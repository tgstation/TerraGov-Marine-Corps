/obj/vehicle/sealed/mecha/mob_try_enter(mob/M)
	if(!ishuman(M)) // no silicons or drones in mechas.
		return
	log_message("[M] tried to move into [src].", LOG_MECHA)
	if(dna_lock)
		var/mob/living/carbon/entering_carbon = M
		if(md5(REF(entering_carbon)) != dna_lock)
			to_chat(M, span_warning("Access denied. [name] is secured with a DNA lock."))
			log_message("Permission denied (DNA LOCK).", LOG_MECHA)
			return
	if(!operation_allowed(M))
		to_chat(M, span_warning("Access denied. Insufficient operation keycodes."))
		log_message("Permission denied (No keycode).", LOG_MECHA)
		return
	. = ..()
	if(.)
		moved_inside(M)

/obj/vehicle/sealed/mecha/enter_checks(mob/M)
	if(obj_integrity <= 0)
		to_chat(M, span_warning("You cannot get in the [src], it has been destroyed!"))
		return FALSE
	if(M.buckled)
		to_chat(M, span_warning("You can't enter the exosuit while buckled."))
		log_message("Permission denied (Buckled).", LOG_MECHA)
		return FALSE
	if(LAZYLEN(M.buckled_mobs))
		to_chat(M, span_warning("You can't enter the exosuit with other creatures attached to you!"))
		log_message("Permission denied (Attached mobs).", LOG_MECHA)
		return FALSE
	var/obj/item/I = M.get_item_by_slot(SLOT_BACK)
	if(I && istype(I, /obj/item/jetpack_marine))
		to_chat(M, span_warning("Something on your back prevents you from entering the mech!"))
		return FALSE
	return ..()

///proc called when a new non-mmi/AI mob enters this mech
/obj/vehicle/sealed/mecha/proc/moved_inside(mob/living/newoccupant)
	if(!(newoccupant?.client))
		return FALSE
	if(ishuman(newoccupant) && !Adjacent(newoccupant))
		return FALSE
	newoccupant.drop_all_held_items()
	add_occupant(newoccupant)
	if(newoccupant.loc != src)
		newoccupant.forceMove(src)
	newoccupant.update_mouse_pointer()
	add_fingerprint(newoccupant, "moved in as pilot")
	log_message("[newoccupant] moved in as pilot.", LOG_MECHA)
	setDir(dir_in)
	playsound(src, 'sound/machines/windowdoor.ogg', 50, TRUE)
	set_mouse_pointer()
	for(var/faction in GLOB.faction_to_data_hud)
		var/datum/atom_hud/squad/hud_type = GLOB.huds[GLOB.faction_to_data_hud[faction]]
		if(faction == newoccupant.faction)
			hud_type.add_to_hud(src)
		else
			hud_type.remove_from_hud(src)

	if(!internal_damage)
		SEND_SOUND(newoccupant, sound('sound/mecha/nominal.ogg',volume=50))
	return TRUE

/obj/vehicle/sealed/mecha/mob_exit(mob/M, silent, forced)
	var/atom/movable/mob_container
	var/turf/newloc = get_turf(src)
	if(ishuman(M))
		mob_container = M
	else
		return ..()
	mecha_flags  &= ~SILICON_PILOT
	mob_container.forceMove(newloc)//ejecting mob container
	log_message("[mob_container] moved out.", LOG_MECHA)
	SStgui.close_user_uis(M, src)
	setDir(dir_in)
	return ..()

/obj/vehicle/sealed/mecha/add_occupant(mob/M, control_flags)
	RegisterSignal(M, COMSIG_MOB_DEATH, PROC_REF(mob_exit), TRUE)
	RegisterSignal(M, COMSIG_MOB_MOUSEDOWN, PROC_REF(on_mouseclick), TRUE)
	RegisterSignal(M, COMSIG_MOB_SAY, PROC_REF(display_speech_bubble), TRUE)
	RegisterSignal(M, COMSIG_LIVING_DO_RESIST, TYPE_PROC_REF(/atom/movable, resisted_against), TRUE)
	. = ..()
	update_icon()
	//tgmc addition start
	if(istype(equip_by_category[MECHA_R_ARM], /obj/item/mecha_parts/mecha_equipment/weapon/ballistic))
		var/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/gun = equip_by_category[MECHA_R_ARM]
		M.hud_used.add_ammo_hud(gun, gun.hud_icons, gun.projectiles)
	if(istype(equip_by_category[MECHA_L_ARM], /obj/item/mecha_parts/mecha_equipment/weapon/ballistic))
		var/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/gun = equip_by_category[MECHA_L_ARM]
		M.hud_used.add_ammo_hud(gun, gun.hud_icons, gun.projectiles)
	//tgmc addition end

/obj/vehicle/sealed/mecha/remove_occupant(mob/M)
	//tgmc addition start
	M.hud_used.remove_ammo_hud(equip_by_category[MECHA_R_ARM])
	M.hud_used.remove_ammo_hud(equip_by_category[MECHA_L_ARM])
	//tgmc addition end
	UnregisterSignal(M, COMSIG_MOB_DEATH)
	UnregisterSignal(M, COMSIG_MOB_MOUSEDOWN)
	UnregisterSignal(M, COMSIG_MOB_SAY)
	UnregisterSignal(M, COMSIG_LIVING_DO_RESIST)
	M.clear_alert(ALERT_CHARGE)
	M.clear_alert(ALERT_MECH_DAMAGE)
	if(M.client)
		M.update_mouse_pointer()
		M.client.view_size.reset_to_default()
		zoom_mode = FALSE
	. = ..()
	update_icon()

/obj/vehicle/sealed/mecha/resisted_against(mob/living/user)
	to_chat(user, span_notice("You begin the ejection procedure. Equipment is disabled during this process. Hold still to finish ejecting."))
	is_currently_ejecting = TRUE
	if(do_after(user, exit_delay, NONE, src))
		to_chat(user, span_notice("You exit the mech."))
		mob_exit(user, TRUE)
	else
		to_chat(user, span_notice("You stop exiting the mech. Weapons are enabled again."))
	is_currently_ejecting = FALSE
