/obj/vehicle/sealed/armored/generate_action_type()
	. = ..()
	if(istype(., /datum/action/vehicle/sealed/armored))
		var/datum/action/vehicle/sealed/armored/armor = .
		armor.chassis = src

///yes this is a blatant mech copypaste
/datum/action/vehicle/sealed/armored
	action_icon = 'icons/mob/actions/actions_mecha.dmi'
	///mech owner of this action
	var/obj/vehicle/sealed/armored/chassis

/datum/action/vehicle/sealed/armored/Destroy()
	chassis = null
	return ..()

/datum/action/vehicle/sealed/armored/eject
	name = "Eject From Mech"
	action_icon_state = "mech_eject"

/datum/action/vehicle/sealed/armored/eject/action_activate(trigger_flags)
	if(!owner)
		return
	if(!chassis || !(owner in chassis.occupants))
		return
	chassis.resisted_against(owner)

/datum/action/vehicle/sealed/armored/swap_seat
	name = "Switch Seats"
	action_icon_state = "mech_seat_swap"

#define ARMOR_DRIVER "Driver"
#define ARMOR_GUNNER "Gunner"
#define ARMOR_PASSENGER "Passenger"

/datum/action/vehicle/sealed/armored/swap_seat/action_activate(trigger_flags)
	if(!transfer_checks())
		return
	var/list/choices = list()
	if(!chassis.is_driver(owner))
		choices += ARMOR_DRIVER
	if(!chassis.is_equipment_controller(owner))
		choices += ARMOR_GUNNER
	choices += ARMOR_PASSENGER
	var/choice = tgui_input_list(owner, "Select a seat", chassis.name, choices)
	if(!choice)
		return
	if(!transfer_checks(choice))
		return
	chassis.balloon_alert(owner, "moving to other seat...")
	if(!do_after(owner, chassis.enter_delay, target = chassis, extra_checks=CALLBACK(src, PROC_REF(transfer_checks), choice)))
		chassis.balloon_alert(owner, "interrupted!")
		return
	chassis.remove_control_flags(owner, VEHICLE_CONTROL_MELEE|VEHICLE_CONTROL_EQUIPMENT|VEHICLE_CONTROL_DRIVE|VEHICLE_CONTROL_SETTINGS)
	switch(choice)
		if(ARMOR_GUNNER)
			chassis.balloon_alert(owner, "controlling gunner seat")
			chassis.add_control_flags(owner, VEHICLE_CONTROL_MELEE|VEHICLE_CONTROL_EQUIPMENT)
		if(ARMOR_DRIVER)
			chassis.balloon_alert(owner, "controlling pilot seat")
			chassis.add_control_flags(owner, VEHICLE_CONTROL_DRIVE|VEHICLE_CONTROL_SETTINGS)
		if(ARMOR_PASSENGER)
			chassis.balloon_alert(owner, "entered passenger seat")

///checks if owner can still transfer
/datum/action/vehicle/sealed/armored/swap_seat/proc/transfer_checks(choice)
	if(!owner || !chassis || !(owner in chassis.occupants))
		return FALSE
	if(length(chassis.occupants) >= chassis.max_occupants)
		chassis.balloon_alert(owner, "other seats occupied!")
		return FALSE
	switch(choice)
		if(ARMOR_GUNNER)
			if(length(chassis.return_controllers_with_flag(VEHICLE_CONTROL_EQUIPMENT)) >= 1)
				chassis.balloon_alert(owner, "gunner occupied!")
				return FALSE
		if(ARMOR_DRIVER)
			if(chassis.driver_amount() >= chassis.max_drivers)
				chassis.balloon_alert(owner, "driver occupied!")
				return FALSE
	return TRUE

#undef ARMOR_DRIVER
#undef ARMOR_GUNNER
#undef ARMOR_PASSENGER

/datum/action/vehicle/sealed/armored/toggle_lights
	name = "Toggle Lights"
	action_icon_state = "mech_lights_off"

/datum/action/vehicle/sealed/armored/toggle_lights/action_activate(trigger_flags)
	if(!owner || !chassis || !(owner in chassis.occupants))
		return

	if(!(chassis.armored_flags & ARMORED_HAS_HEADLIGHTS))
		chassis.balloon_alert(owner, "the vehicle's lights are broken!")
		return
	chassis.armored_flags ^= ARMORED_LIGHTS_ON
	if(chassis.armored_flags & ARMORED_LIGHTS_ON)
		action_icon_state = "mech_lights_on"
		chassis.set_light(initial(chassis.light_range))
	else
		action_icon_state = "mech_lights_off"
		chassis.set_light(0)
	chassis.balloon_alert(owner, "toggled lights [chassis.armored_flags & ARMORED_LIGHTS_ON ? "on":"off"]")
	playsound(chassis,'sound/mecha/brass_skewer.ogg', 40, TRUE)
	chassis.log_message("Toggled lights [(chassis.armored_flags & ARMORED_LIGHTS_ON)?"on":"off"].", LOG_MECHA)
	update_button_icon()

/datum/action/vehicle/sealed/armored/zoom
	name = "Zoom"
	action_icon_state = "mech_zoom_off"
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_MECHABILITY_TOGGLE_ZOOM,
	)

/datum/action/vehicle/sealed/armored/zoom/action_activate(trigger_flags)
	if(!owner?.client || !chassis || !(owner in chassis.occupants))
		return
	chassis.zoom_mode = !chassis.zoom_mode
	action_icon_state = "mech_zoom_[chassis.zoom_mode ? "on" : "off"]"
	chassis.log_message("Toggled zoom mode.", LOG_MECHA)
	to_chat(owner, "<font color='[chassis.zoom_mode?"blue":"red"]'>Zoom mode [chassis.zoom_mode?"en":"dis"]abled.</font>")
	if(chassis.zoom_mode)
		owner.client.view_size.add(3)
		SEND_SOUND(owner, sound('sound/mecha/imag_enh.ogg', volume=50))
	else
		owner.client.view_size.add(-3)
	update_button_icon()

/datum/action/vehicle/sealed/armored/zoom/remove_action(mob/M)
	if(chassis.zoom_mode)
		M.client.view_size.reset_to_default()
		chassis.zoom_mode = FALSE
	return ..()

/datum/action/vehicle/sealed/armored/horn
	name = "Honk Horn"
	action_icon = 'icons/mob/actions/actions_vehicle.dmi'
	action_icon_state = "car_horn"
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_KB_VEHICLEHONK,
	)

/datum/action/vehicle/sealed/armored/horn/action_activate(trigger_flags)
	if(!owner?.client || !chassis || !(owner in chassis.occupants))
		return
	if(TIMER_COOLDOWN_RUNNING(chassis, COOLDOWN_ARMORED_HORN))
		return

	chassis.visible_message("[chassis] honks its horn!")
	playsound(chassis.loc, 'sound/vehicles/horns/armored_horn.ogg', 70)
	TIMER_COOLDOWN_START(chassis, COOLDOWN_ARMORED_HORN, 15 SECONDS) //To keep people's eardrums intact

/datum/action/vehicle/sealed/armored/strafe
	name = "Toggle Strafing. Disabled when Alt is held."
	action_icon_state = "strafe"
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_MECHABILITY_TOGGLE_STRAFE,
	)

/datum/action/vehicle/sealed/armored/strafe/action_activate(trigger_flags)
	if(!owner || !chassis || !(owner in chassis.occupants))
		return
	chassis.toggle_strafe()

///Toggles strafemode on or off
/obj/vehicle/sealed/armored/proc/toggle_strafe()
	strafe = !strafe

	for(var/occupant in occupants)
		balloon_alert(occupant, "Strafing mode [strafe?"on":"off"].")
		var/datum/action/action = LAZYACCESSASSOC(occupant_actions, occupant, /datum/action/vehicle/sealed/armored/strafe)
		action?.update_button_icon()

/datum/action/vehicle/sealed/armored/smoke_screen
	name = "Smokescreen"
	action_icon_state = "mech_smoke"
	keybinding_signals = list(KEYBINDING_NORMAL = COMSIG_MECHABILITY_SMOKE)
	///Uses of this ability remaining
	var/shots_remaining = 6

/datum/action/vehicle/sealed/armored/smoke_screen/New(Target)
	. = ..()
	visual_references[VREF_MUTABLE_AMMO_COUNTER] = mutable_appearance(null, null, ACTION_LAYER_MAPTEXT)

/datum/action/vehicle/sealed/armored/smoke_screen/action_activate(trigger_flags)
	if(!owner || !chassis || !(owner in chassis.occupants))
		return
	if(TIMER_COOLDOWN_RUNNING(chassis, COOLDOWN_ARMORED_SMOKE))
		return
	if(!shots_remaining)
		playsound(chassis.loc, 'sound/weapons/guns/interact/m92_cocked.ogg', 40, TRUE)
		return

	shots_remaining --
	chassis.visible_message("[chassis] pops smoke!")
	playsound(chassis.loc, 'sound/weapons/guns/fire/grenadelauncher.ogg', 80, TRUE)
	TIMER_COOLDOWN_START(chassis, COOLDOWN_ARMORED_SMOKE, 2 SECONDS)

	var/list/source_turfs = list()
	var/origin_turf  = chassis.hitbox.get_projectile_loc(src)
	source_turfs += get_step(origin_turf, turn(chassis.dir, -90))
	source_turfs += get_step(origin_turf, turn(chassis.dir, 90))

	var/datum/ammo/ammo_type = /datum/ammo/bullet/micro_rail/smoke_burst/tank
	for(var/turf/source_turf in source_turfs)
		var/turf/target_turf = get_ranged_target_turf(source_turf, get_dir(chassis, source_turf), 5)
		var/atom/movable/projectile/projectile_to_fire = new /atom/movable/projectile(source_turf)
		projectile_to_fire.generate_bullet(GLOB.ammo_list[ammo_type])
		if(chassis.hitbox?.tank_desants)
			projectile_to_fire.hit_atoms += chassis.hitbox.tank_desants
		projectile_to_fire.fire_at(target_turf, owner, chassis, projectile_to_fire.ammo.max_range, projectile_to_fire.projectile_speed)

	update_button_icon()

/datum/action/vehicle/sealed/armored/smoke_screen/update_button_icon()
	if(!button)
		return
	var/mutable_appearance/ammo_counter = visual_references[VREF_MUTABLE_AMMO_COUNTER]
	button.cut_overlay(visual_references[VREF_MUTABLE_AMMO_COUNTER])
	ammo_counter.maptext = MAPTEXT("[shots_remaining]/[initial(shots_remaining)]")
	visual_references[VREF_MUTABLE_AMMO_COUNTER] = ammo_counter
	button.add_overlay(ammo_counter)
	return ..()
