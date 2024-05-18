/obj/item/mecha_equipment/ability
	name = "generic mech ability"
	desc = "You shouldnt be seeing this"
	equipment_slot = MECHA_UTILITY
	///if given, a single flag of who we want this ability to be granted to
	var/flag_controller = NONE
	///typepath of ability we want to grant
	var/ability_to_grant
	///reference to image that is used as an overlay
	var/image/overlay

/obj/item/mecha_equipment/ability/Initialize(mapload)
	. = ..()
	if(icon_state)
		overlay = image('icons/mecha/mecha_ability_overlays.dmi', icon_state = icon_state, layer = 10)

/obj/item/mecha_equipment/ability/attach(obj/vehicle/sealed/mecha/M, attach_right)
	. = ..()
	M.add_overlay(overlay)
	if(flag_controller)
		M.initialize_controller_action_type(ability_to_grant, flag_controller)
	else
		M.initialize_passenger_action_type(ability_to_grant)

/obj/item/mecha_equipment/ability/detach(atom/moveto)
	chassis.cut_overlay(overlay)
	if(flag_controller)
		chassis.destroy_controller_action_type(ability_to_grant, flag_controller)
	else
		chassis.destroy_passenger_action_type(ability_to_grant)
	return ..()

/obj/item/mecha_equipment/repair_droid
	name = "exosuit repair droid"
	desc = "An automated repair droid for exosuits. Scans for damage and repairs it. Can fix almost all types of external damage."
	icon_state = "repair_droid"
	energy_drain = 50
	range = 0
	activated = FALSE
	equipment_slot = MECHA_UTILITY
	/// Repaired health per second
	var/health_boost = 0.5
	///overlay to show on the mech
	var/image/droid_overlay

/obj/item/mecha_equipment/repair_droid/Destroy()
	STOP_PROCESSING(SSobj, src)
	chassis?.cut_overlay(droid_overlay)
	return ..()

/obj/item/mecha_equipment/repair_droid/attach(obj/vehicle/sealed/mecha/M, attach_right = FALSE)
	. = ..()
	droid_overlay = image(icon, icon_state = "repair_droid")
	M.add_overlay(droid_overlay)

/obj/item/mecha_equipment/repair_droid/detach()
	chassis.cut_overlay(droid_overlay)
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/mecha_equipment/repair_droid/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(action != "toggle")
		return
	chassis.cut_overlay(droid_overlay)
	if(activated)
		START_PROCESSING(SSobj, src)
		droid_overlay = image(icon, icon_state = "repair_droid_a")
		log_message("Activated.", LOG_MECHA)
	else
		STOP_PROCESSING(SSobj, src)
		droid_overlay = image(icon, icon_state = "repair_droid")
		log_message("Deactivated.", LOG_MECHA)
	chassis.add_overlay(droid_overlay)

/obj/item/mecha_equipment/repair_droid/process(delta_time)
	if(!chassis)
		return PROCESS_KILL
	var/h_boost = health_boost * delta_time
	var/repaired = FALSE
	if(chassis.internal_damage & MECHA_INT_SHORT_CIRCUIT)
		h_boost *= -2
	if(h_boost<0 || chassis.obj_integrity < chassis.max_integrity)
		chassis.repair_damage(h_boost)
		repaired = TRUE
	if(repaired)
		if(!chassis.use_power(energy_drain))
			activated = FALSE
			return PROCESS_KILL
	else //no repair needed, we turn off
		chassis.cut_overlay(droid_overlay)
		droid_overlay = image(icon, icon_state = "repair_droid")
		chassis.add_overlay(droid_overlay)
		activated = FALSE
		return PROCESS_KILL
