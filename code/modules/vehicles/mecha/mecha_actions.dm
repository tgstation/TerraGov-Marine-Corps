/***************** MECHA ACTIONS *****************/

/obj/vehicle/sealed/mecha/generate_action_type()
	. = ..()
	if(istype(., /datum/action/vehicle/sealed/mecha))
		var/datum/action/vehicle/sealed/mecha/mecha = .
		mecha.chassis = src

/datum/action/vehicle/sealed/mecha
	action_icon = 'icons/mob/actions/actions_mecha.dmi'
	///mech owner of this action
	var/obj/vehicle/sealed/mecha/chassis

/datum/action/vehicle/sealed/mecha/Destroy()
	chassis = null
	return ..()

/datum/action/vehicle/sealed/mecha/mech_eject
	name = "Eject From Mech"
	action_icon_state = "mech_eject"

/datum/action/vehicle/sealed/mecha/mech_eject/action_activate(trigger_flags)
	if(!owner)
		return
	if(!chassis || !(owner in chassis.occupants))
		return
	chassis.resisted_against(owner)

/datum/action/vehicle/sealed/mecha/mech_toggle_internals
	name = "Toggle Internal Airtank Usage"
	action_icon_state = "mech_internals_off"
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_MECHABILITY_TOGGLE_INTERNALS,
	)

/datum/action/vehicle/sealed/mecha/mech_toggle_internals/action_activate(trigger_flags)
	if(!owner || !chassis || !(owner in chassis.occupants))
		return

	if(!chassis.internal_tank) //Just in case.
		chassis.use_internal_tank = FALSE
		chassis.balloon_alert(owner, "no tank available!")
		chassis.log_message("Switch to internal tank failed. No tank available.", LOG_MECHA)
		return

	chassis.use_internal_tank = !chassis.use_internal_tank
	action_icon_state = "mech_internals_[chassis.use_internal_tank ? "on" : "off"]"
	chassis.balloon_alert(owner, "taking air from [chassis.use_internal_tank ? "internal airtank" : "environment"]")
	chassis.log_message("Now taking air from [chassis.use_internal_tank?"internal airtank":"environment"].", LOG_MECHA)
	update_button_icon()

/datum/action/vehicle/sealed/mecha/mech_toggle_lights
	name = "Toggle Lights"
	action_icon_state = "mech_lights_off"

/datum/action/vehicle/sealed/mecha/mech_toggle_lights/action_activate(trigger_flags)
	if(!owner || !chassis || !(owner in chassis.occupants))
		return

	if(!(chassis.mecha_flags & HAS_HEADLIGHTS))
		chassis.balloon_alert(owner, "the mech lights are broken!")
		return
	chassis.mecha_flags ^= LIGHTS_ON
	if(chassis.mecha_flags & LIGHTS_ON)
		action_icon_state = "mech_lights_on"
	else
		action_icon_state = "mech_lights_off"
	chassis.set_light_on(chassis.mecha_flags & LIGHTS_ON)
	chassis.balloon_alert(owner, "toggled lights [chassis.mecha_flags & LIGHTS_ON ? "on":"off"]")
	playsound(chassis,'sound/mecha/brass_skewer.ogg', 40, TRUE)
	chassis.log_message("Toggled lights [(chassis.mecha_flags & LIGHTS_ON)?"on":"off"].", LOG_MECHA)
	update_button_icon()

/datum/action/vehicle/sealed/mecha/mech_view_stats
	name = "View Stats"
	action_icon_state = "mech_view_stats"
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_MECHABILITY_VIEW_STATS,
	)
/datum/action/vehicle/sealed/mecha/mech_view_stats/action_activate(trigger_flags)
	if(!owner || !chassis || !(owner in chassis.occupants))
		return

	chassis.ui_interact(owner)

/datum/action/vehicle/sealed/mecha/strafe
	name = "Toggle Strafing. Disabled when Alt is held."
	action_icon_state = "strafe"
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_MECHABILITY_TOGGLE_STRAFE,
	)
/datum/action/vehicle/sealed/mecha/strafe/action_activate(trigger_flags)
	if(!owner || !chassis || !(owner in chassis.occupants))
		return

	chassis.toggle_strafe()

/obj/vehicle/sealed/mecha/AltClick(mob/living/user)
	if(!(user in occupants))
		return
	if(!(user in return_controllers_with_flag(VEHICLE_CONTROL_DRIVE)))
		to_chat(user, span_warning("You're in the wrong seat to control movement."))
		return

	toggle_strafe()

/obj/vehicle/sealed/mecha/proc/toggle_strafe()
	if(!(mecha_flags & CANSTRAFE))
		for(var/occupant in occupants)
			balloon_alert(occupant, "No strafing mode")
		return

	strafe = !strafe
	for(var/occupant in occupants)
		balloon_alert(occupant, "Strafing mode [strafe?"on":"off"].")
		var/datum/action/action = LAZYACCESSASSOC(occupant_actions, occupant, /datum/action/vehicle/sealed/mecha/strafe)
		action?.update_button_icon()

///swap seats, for two person mecha
/datum/action/vehicle/sealed/mecha/swap_seat
	name = "Switch Seats"
	action_icon_state = "mech_seat_swap"

/datum/action/vehicle/sealed/mecha/swap_seat/action_activate(trigger_flags)
	if(!owner || !chassis || !(owner in chassis.occupants))
		return

	if(length(chassis.occupants) == chassis.max_occupants)
		chassis.balloon_alert(owner, "other seat occupied!")
		return
	var/list/drivers = chassis.return_drivers()
	chassis.balloon_alert(owner, "moving to other seat...")
	chassis.is_currently_ejecting = TRUE
	if(!do_after(owner, chassis.exit_delay, target = chassis))
		chassis.balloon_alert(owner, "interrupted!")
		chassis.is_currently_ejecting = FALSE
		return
	chassis.is_currently_ejecting = FALSE
	if(owner in drivers)
		chassis.balloon_alert(owner, "controlling gunner seat")
		chassis.remove_control_flags(owner, VEHICLE_CONTROL_DRIVE|VEHICLE_CONTROL_SETTINGS)
		chassis.add_control_flags(owner, VEHICLE_CONTROL_MELEE|VEHICLE_CONTROL_EQUIPMENT)
	else
		chassis.balloon_alert(owner, "controlling pilot seat")
		chassis.remove_control_flags(owner, VEHICLE_CONTROL_MELEE|VEHICLE_CONTROL_EQUIPMENT)
		chassis.add_control_flags(owner, VEHICLE_CONTROL_DRIVE|VEHICLE_CONTROL_SETTINGS)
	chassis.update_appearance()

/datum/action/vehicle/sealed/mecha/reload
	name = "Reload equipped weapons"
	action_icon_state = "reload"
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_MECHABILITY_RELOAD,
	)

/datum/action/vehicle/sealed/mecha/reload/action_activate(trigger_flags)
	if(!owner || !chassis || !(owner in chassis.occupants))
		return

	for(var/i in chassis.equip_by_category)
		if(!istype(chassis.equip_by_category[i], /obj/item/mecha_parts/mecha_equipment))
			continue
		INVOKE_ASYNC(chassis.equip_by_category[i], TYPE_PROC_REF(/obj/item/mecha_parts/mecha_equipment, attempt_rearm), owner)

/datum/action/vehicle/sealed/mecha/repairpack
	name = "Use Repairpack"
	action_icon_state = "repair"
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_MECHABILITY_REPAIRPACK,
	)

/datum/action/vehicle/sealed/mecha/repairpack/action_activate(trigger_flags)
	if(!can_repair())
		return

	chassis.balloon_alert(owner, "Repairing...")
	chassis.canmove = FALSE
	chassis.equipment_disabled = TRUE
	chassis.set_mouse_pointer()
	if(!do_after(owner, 6 SECONDS, NONE, chassis, extra_checks=CALLBACK(src, PROC_REF(can_repair))))
		chassis.canmove = TRUE
		chassis.equipment_disabled = FALSE
		chassis.set_mouse_pointer()
		return
	chassis.canmove = TRUE
	chassis.equipment_disabled = FALSE
	chassis.set_mouse_pointer()
	chassis.stored_repairpacks--
	// does not count as actual repairs for end of round because its annoying to decouple from normal repair and this isnt representative of a real repair
	chassis.repair_damage(chassis.max_integrity)
	var/obj/vehicle/sealed/mecha/combat/greyscale/greyscale = chassis
	if(!istype(greyscale))
		return
	for(var/limb_key in greyscale.limbs)
		var/datum/mech_limb/limb = greyscale.limbs[limb_key]
		limb?.do_repairs(initial(limb.part_health))

///checks whether we can still repair this mecha
/datum/action/vehicle/sealed/mecha/repairpack/proc/can_repair()
	if(!owner || !chassis || !(owner in chassis.occupants))
		return FALSE
	if(!chassis.stored_repairpacks)
		chassis.balloon_alert(owner, "No repairpacks")
		return FALSE
	return TRUE


/datum/action/vehicle/sealed/mecha/swap_controlled_weapons
	name = "Swap Weapon set"
	action_icon_state = "weapon_swap"
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_MECHABILITY_SWAPWEAPONS,
	)

/datum/action/vehicle/sealed/mecha/swap_controlled_weapons/action_activate(trigger_flags)
	var/obj/vehicle/sealed/mecha/combat/greyscale/core/greyscale = chassis
	greyscale.swap_weapons()

/datum/action/vehicle/sealed/mecha/assault_armor
	name = "Assault Armor"
	action_icon_state = "assaultarmor"
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_MECHABILITY_ASSAULT_ARMOR,
	)
	///power cost of activation
	var/power_cost = 300
	///num of projectiles we burst
	var/projectile_count = 20
	///ammo type used by the projectiles
	var/datum/ammo/ammo_type = /datum/ammo/energy/assault_armor

/datum/action/vehicle/sealed/mecha/assault_armor/action_activate(trigger_flags)
	. = ..()
	if(!.)
		return
	if(!owner?.client || !chassis || !(owner in chassis.occupants))
		return
	if(!chassis.use_power(power_cost))
		chassis.balloon_alert(owner, "No power")
		return
	if(owner.do_actions)
		return
	if(TIMER_COOLDOWN_RUNNING(chassis, COOLDOWN_MECHA_ASSAULT_ARMOR))
		var/time = S_TIMER_COOLDOWN_TIMELEFT(chassis, COOLDOWN_MECHA_ASSAULT_ARMOR)/10
		chassis.balloon_alert(owner, "[time] seconds")
		return
	S_TIMER_COOLDOWN_START(chassis, COOLDOWN_MECHA_ASSAULT_ARMOR, 2 MINUTES)
	var/added_movetime = chassis.move_delay
	chassis.move_delay += added_movetime
	var/obj/effect/overlay/lightning_charge/charge = new(chassis)
	charge.pixel_x -= chassis.pixel_x
	charge.pixel_y -= chassis.pixel_y
	chassis.vis_contents += charge
	if(!do_after(owner, 0.5 SECONDS, IGNORE_LOC_CHANGE, chassis))
		chassis.vis_contents -= charge
		chassis.move_delay -= added_movetime
		qdel(charge)
		return
	chassis.vis_contents -= charge
	qdel(charge)
	new /obj/effect/temp_visual/lightning_discharge(get_turf(chassis))
	chassis.move_delay -= added_movetime
	for(var/turf/location in RANGE_TURFS(1, chassis))
		for(var/mob/living/target in location)
			target.take_overall_damage(200, BURN, LASER, updating_health=TRUE, penetration=30, max_limbs=6)
	playsound(chassis, 'sound/weapons/burst_phaser2.ogg', GUN_FIRE_SOUND_VOLUME, TRUE)

/datum/action/vehicle/sealed/mecha/cloak
	name = "Cloak"
	action_icon_state = "cloak_off"
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_MECHABILITY_CLOAK,
	)
	/// Whether mech is currently cloaked
	var/cloaked = FALSE
	///power cost of maintaining cloak per second
	var/power_cost = 40

/datum/action/vehicle/sealed/mecha/cloak/action_activate(trigger_flags)
	. = ..()
	if(!.)
		return
	if(!owner?.client || !chassis || !(owner in chassis.occupants))
		return
	if(cloaked)
		stop_cloaking()
		return
	if(TIMER_COOLDOWN_RUNNING(chassis, COOLDOWN_MECHA_EQUIPMENT(type)))
		chassis.balloon_alert(owner, "Cooldown")
		return
	TIMER_COOLDOWN_START(chassis, COOLDOWN_MECHA_EQUIPMENT(type), 1 SECONDS) // anti sound spammers
	cloaked = TRUE
	action_icon_state = "cloak_on"
	update_button_icon()
	ADD_TRAIT(chassis, TRAIT_SILENT_FOOTSTEPS, type)
	playsound(chassis, 'sound/effects/pred_cloakon.ogg', 60, TRUE)
	chassis.become_warped_invisible(50)
	START_PROCESSING(SSobj, src)
	chassis.mecha_flags |= CANNOT_INTERACT

/datum/action/vehicle/sealed/mecha/cloak/process(seconds_per_tick)
	if(!owner || !(owner in chassis.occupants))
		stop_cloaking()
		return
	if(!chassis.use_power(seconds_per_tick*power_cost))
		stop_cloaking()

/datum/action/vehicle/sealed/mecha/cloak/remove_action(mob/M)
	if(cloaked)
		stop_cloaking()
	return ..()

///cleanup from stoping cloaking
/datum/action/vehicle/sealed/mecha/cloak/proc/stop_cloaking()
	cloaked = FALSE
	action_icon_state = "cloak_off"
	update_button_icon()
	chassis.mecha_flags &= ~CANNOT_INTERACT
	STOP_PROCESSING(SSobj, src)
	chassis.stop_warped_invisible()
	REMOVE_TRAIT(chassis, TRAIT_SILENT_FOOTSTEPS, type)
	playsound(chassis, 'sound/effects/pred_cloakoff.ogg', 60, TRUE)
	for(var/obj/item/mecha_parts/mecha_equipment/weapon/gun in chassis.flat_equipment)
		TIMER_COOLDOWN_START(chassis, COOLDOWN_MECHA_EQUIPMENT(gun.cooldown_key), min(gun.equip_cooldown/2, 1 SECONDS))
