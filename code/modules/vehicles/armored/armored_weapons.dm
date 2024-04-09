/obj/item/armored_weapon
	name = "\improper LTB main battle tank cannon"
	desc = "A TGMC vehicle's main turret cannon. It fires 86mm rocket propelled shells"
	icon = 'icons/obj/armored/hardpoint_modules.dmi'
	icon_state = "ltb_cannon"
	///owner this is attached to
	var/obj/vehicle/sealed/armored/chassis
	///The turret icon if we equip the weapon in a secondary slot, you should null this if its unequippable as such
	var/secondary_equipped_icon
	///Weapon slot this weapon fits in
	var/weapon_slot = MODULE_PRIMARY

	///currently loaded ammo. initial value is ammo we start with
	var/obj/item/ammo_magazine/ammo = /obj/item/ammo_magazine/tank/ltb_cannon
	///Current loaded magazines: top one empties into ammo
	var/list/obj/item/ammo_magazine/ammo_magazine = list()
	///maximum magazines ammo_magazine can hold
	var/maximum_magazines = 5
	///ammo types we'll be able to accept
	var/list/accepted_ammo = list(
		/obj/item/ammo_magazine/tank/tank_glauncher,
		/obj/item/ammo_magazine/tank/ltb_cannon,
	)
	///current tracked target for fire(), updated when user drags
	var/atom/current_target
	///current mob firing this weapon. used for tracking for iff and etc in fire()
	var/mob/current_firer

	///sound file to play when this weapon you know, fires
	var/fire_sound = list('sound/weapons/guns/fire/tank_cannon1.ogg', 'sound/weapons/guns/fire/tank_cannon2.ogg')
	///Tracks windups
	var/windup_checked = WEAPON_WINDUP_NOT_CHECKED
	///windup sound played during windup
	var/windup_sound
	///windup delay for this object
	var/windup_delay = 0
	///scatter of this weapon. in degrees and modified by arm this is attached to
	var/variance = 0
	/// since mech guns only get one firemode this is for all types of shots
	var/projectile_delay = 5 SECONDS
	/// time between shots in a burst
	var/projectile_burst_delay = 2
	///bullets per burst if firemode is set to burst
	var/burst_amount = 0
	///fire mode to use for autofire
	var/fire_mode = GUN_FIREMODE_SEMIAUTO
	///how many seconds automatic, and manual, reloading takes
	var/rearm_time = 4 SECONDS
	///ammo hud icon to display when no ammo is loaded
	var/hud_state_empty = "shell_empty"

/obj/item/armored_weapon/Initialize(mapload)
	. = ..()
	if(ammo)
		ammo = new ammo(src)
	AddComponent(/datum/component/automatedfire/autofire, projectile_delay, projectile_delay, projectile_burst_delay, burst_amount, fire_mode, CALLBACK(src, PROC_REF(set_bursting)), CALLBACK(src, PROC_REF(reset_fire)), CALLBACK(src, PROC_REF(fire)))

/obj/item/armored_weapon/Destroy()
	if(chassis)
		detach(get_turf(chassis))
	if(isdatum(ammo))
		QDEL_NULL(ammo)
	QDEL_LIST(ammo_magazine)
	return ..()

///called by the chassis: begins firing, yes this is stolen from mech but I made both so bite me
/obj/item/armored_weapon/proc/begin_fire(mob/source, atom/target, list/modifiers)
	if(!ammo || ammo.current_rounds < 0)
		playsound(source, 'sound/weapons/guns/fire/empty.ogg', 15, 1)
		return
	if(TIMER_COOLDOWN_CHECK(chassis, COOLDOWN_MECHA_EQUIPMENT(type)))
		return
	TIMER_COOLDOWN_START(chassis, COOLDOWN_MECHA_EQUIPMENT(type), projectile_delay)

	set_target(get_turf_on_clickcatcher(target, source, list2params(modifiers)))
	if(!current_target)
		return
	RegisterSignal(source, COMSIG_MOB_MOUSEUP, PROC_REF(stop_fire))
	RegisterSignal(source, COMSIG_MOB_MOUSEDRAG, PROC_REF(change_target))
	if(windup_delay && windup_checked == WEAPON_WINDUP_NOT_CHECKED)
		windup_checked = WEAPON_WINDUP_CHECKING
		playsound(chassis.loc, windup_sound, 30, TRUE)
		if(!do_after(source, windup_delay, IGNORE_TARGET_LOC_CHANGE, chassis, BUSY_ICON_DANGER, BUSY_ICON_DANGER, extra_checks = CALLBACK(src, PROC_REF(do_after_checks), current_target)))
			windup_checked = WEAPON_WINDUP_NOT_CHECKED
			return
		windup_checked = WEAPON_WINDUP_CHECKED
	if(QDELETED(current_target))
		windup_checked = WEAPON_WINDUP_NOT_CHECKED
		return
	current_firer = source
	if(fire_mode == GUN_FIREMODE_SEMIAUTO)
		var/fire_return // todo fix: code expecting return values from async
		ASYNC
			fire_return = fire()
		if(!fire_return || windup_checked == WEAPON_WINDUP_CHECKING)
			return
		reset_fire()
		return
	SEND_SIGNAL(src, COMSIG_ARMORED_FIRE)
	source?.client?.mouse_pointer_icon = 'icons/effects/supplypod_target.dmi'

/// do after checks for the mecha equipment do afters
/obj/item/armored_weapon/proc/do_after_checks(atom/target)
	if(!chassis)
		return FALSE
	if(QDELETED(current_target))
		return FALSE
	if(chassis.primary_weapon == src)
		var/dir_target_diff = get_between_angles(Get_Angle(chassis, current_target), dir2angle(chassis.turret_overlay.dir))
		if(dir_target_diff > (ARMORED_FIRE_CONE_ALLOWED / 2))
			if(!chassis.swivel_turret(current_target))
				return FALSE
		dir_target_diff = get_between_angles(Get_Angle(chassis, current_target), dir2angle(chassis.turret_overlay.dir))
		if(dir_target_diff > (ARMORED_FIRE_CONE_ALLOWED / 2))
			return FALSE
	return TRUE

///callback wrapper for adding/removing trait
/obj/item/armored_weapon/proc/set_bursting(bursting)
	if(bursting)
		ADD_TRAIT(src, TRAIT_GUN_BURST_FIRING, VEHICLE_TRAIT)
		return
	REMOVE_TRAIT(src, TRAIT_GUN_BURST_FIRING, VEHICLE_TRAIT)

///Changes the current target.
/obj/item/armored_weapon/proc/change_target(datum/source, atom/src_object, atom/over_object, turf/src_location, turf/over_location, src_control, over_control, params)
	SIGNAL_HANDLER
	set_target(get_turf_on_clickcatcher(over_object, source, params))

///Sets the current target and registers for qdel to prevent hardels
/obj/item/armored_weapon/proc/set_target(atom/object)
	if(object == current_target || object == chassis)
		return
	if(current_target)
		UnregisterSignal(current_target, COMSIG_QDELETING)
	current_target = object
	if(current_target)
		RegisterSignal(current_target, COMSIG_QDELETING, PROC_REF(clean_target))

///Stops the Autofire component and resets the current cursor.
/obj/item/armored_weapon/proc/stop_fire(mob/living/source, atom/object, location, control, params)
	SIGNAL_HANDLER
	var/list/modifiers = params2list(params)
	if(!((modifiers[BUTTON] == RIGHT_CLICK) && chassis.secondary_weapon == src) && !((modifiers[BUTTON] == LEFT_CLICK) && chassis.primary_weapon == src))
		return
	SEND_SIGNAL(src, COMSIG_ARMORED_STOP_FIRE)
	if(!HAS_TRAIT(src, TRAIT_GUN_BURST_FIRING))
		reset_fire()
	UnregisterSignal(source, list(COMSIG_MOB_MOUSEDRAG, COMSIG_MOB_MOUSEUP))

///Cleans the current target in case of Hardel
/obj/item/armored_weapon/proc/clean_target()
	SIGNAL_HANDLER
	current_target = get_turf(current_target)

///Resets the autofire component.
/obj/item/armored_weapon/proc/reset_fire()
	windup_checked = WEAPON_WINDUP_NOT_CHECKED
	current_firer?.client?.mouse_pointer_icon = chassis.mouse_pointer
	set_target(null)
	current_firer = null

///does any effects and changes to the projectile when it is fired
/obj/item/armored_weapon/proc/apply_weapon_modifiers(obj/projectile/projectile_to_fire, mob/firer)
	projectile_to_fire.shot_from = src
	projectile_to_fire.projectile_speed = projectile_to_fire.ammo.shell_speed
	if(chassis.hitbox?.tank_desants)
		projectile_to_fire.hit_atoms += chassis.hitbox.tank_desants
	if((projectile_to_fire.ammo.ammo_behavior_flags & AMMO_IFF) && ishuman(firer))
		var/mob/living/carbon/human/human_firer = firer
		var/obj/item/card/id/id = human_firer.get_idcard()
		projectile_to_fire.iff_signal = id?.iff_signal
	if(firer)
		projectile_to_fire.def_zone = firer.zone_selected

///actually executes firing when autofire asks for it, returns TRUE to keep firing FALSE to stop
/obj/item/armored_weapon/proc/fire()
	if(chassis.primary_weapon == src)
		var/dir_target_diff = get_between_angles(Get_Angle(chassis, current_target), dir2angle(chassis.turret_overlay.dir))
		if(dir_target_diff > (ARMORED_FIRE_CONE_ALLOWED / 2))
			chassis.swivel_turret(current_target)
			return AUTOFIRE_CONTINUE
	else if(chassis.turret_overlay)
		chassis.turret_overlay.cut_overlay(chassis.turret_overlay.secondary_overlay)
		chassis.turret_overlay.secondary_overlay.dir = get_cardinal_dir(chassis, current_target)
		chassis.turret_overlay.add_overlay(chassis.turret_overlay.secondary_overlay)
	else
		chassis.cut_overlay(chassis.secondary_weapon_overlay)
		chassis.secondary_weapon_overlay.dir = get_cardinal_dir(chassis, current_target)
		chassis.add_overlay(chassis.secondary_weapon_overlay)


	var/type_to_spawn = CHECK_BITFIELD(initial(ammo.default_ammo.ammo_behavior_flags), AMMO_HITSCAN) ? /obj/projectile/hitscan : /obj/projectile
	var/obj/projectile/projectile_to_fire = new type_to_spawn(get_turf(src), initial(ammo.default_ammo.hitscan_effect_icon))
	projectile_to_fire.generate_bullet(GLOB.ammo_list[ammo.default_ammo])

	apply_weapon_modifiers(projectile_to_fire, current_firer)
	var/firing_angle = get_angle_with_scatter(chassis, current_target, variance, projectile_to_fire.p_x, projectile_to_fire.p_y)

	playsound(chassis, islist(fire_sound) ? pick(fire_sound):fire_sound, 20, TRUE)
	projectile_to_fire.fire_at(current_target, current_firer, chassis, projectile_to_fire.ammo.max_range, projectile_to_fire.projectile_speed, firing_angle, suppress_light = HAS_TRAIT(src, TRAIT_GUN_SILENCED))

	chassis.log_message("Fired from [name], targeting [current_target] at [AREACOORD(current_target)].", LOG_ATTACK)

	if(chassis.primary_weapon == src && !chassis.turret_overlay.flashing)
		chassis.turret_overlay.set_flashing(TRUE)
		addtimer(CALLBACK(chassis.turret_overlay, TYPE_PROC_REF(/atom/movable/vis_obj/turret_overlay, set_flashing), FALSE), 7, TIMER_CLIENT_TIME)
		chassis.interior?.breech.on_main_fire(ammo)

	ammo.current_rounds--
	for(var/mob/occupant AS in chassis.occupants)
		occupant.hud_used.update_ammo_hud(src, list(ammo.default_ammo.hud_state, ammo.default_ammo.hud_state_empty), ammo.current_rounds)
	if(ammo.current_rounds > 0)
		return AUTOFIRE_CONTINUE|AUTOFIRE_SUCCESS
	playsound(src, 'sound/weapons/guns/misc/empty_alarm.ogg', 25, 1)
	eject_ammo()
	if(LAZYACCESS(current_firer.do_actions, src) || length(ammo_magazine) < 1)
		return AUTOFIRE_SUCCESS
	var/obj/item/ammo_magazine/tank/new_mag = ammo_magazine[1]
	if(istype(new_mag) && new_mag.loading_sound)
		// .5 sec delay to let other sounds play out
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), src, new_mag.loading_sound, 40), 5)
	if(!do_after(current_firer, rearm_time, IGNORE_HELD_ITEM|IGNORE_LOC_CHANGE, chassis, BUSY_ICON_GENERIC))
		return AUTOFIRE_SUCCESS
	reload()
	return AUTOFIRE_CONTINUE|AUTOFIRE_SUCCESS

///eject current ammo from tank
/obj/item/armored_weapon/proc/eject_ammo()
	for(var/mob/occupant AS in chassis.occupants)
		occupant.hud_used.update_ammo_hud(src, list(hud_state_empty, hud_state_empty), 0)
	ammo.update_appearance()
	var/obj/item/ammo_magazine/old_ammo = ammo
	ammo = null
	if(chassis.interior)
		if(chassis.primary_weapon == src)
			chassis.interior.breech.do_eject_ammo(old_ammo)
		else
			chassis.interior.secondary_breech.do_eject_ammo(old_ammo)
		return
	old_ammo.forceMove(chassis.exit_location())

///load topmost ammo magazine, if there is any
/obj/item/armored_weapon/proc/reload()
	if(ammo)
		eject_ammo()
	ammo = popleft(ammo_magazine)
	for(var/mob/occupant AS in chassis.occupants)
		occupant.hud_used.update_ammo_hud(src, list(ammo.default_ammo.hud_state, ammo.default_ammo.hud_state_empty), ammo.current_rounds)

///attach this weapon to a chassis
/obj/item/armored_weapon/proc/attach(obj/vehicle/sealed/armored/tank, attach_primary)
	if(attach_primary)
		tank.primary_weapon?.detach(tank.exit_location())
		tank.primary_weapon = src
		tank.turret_overlay.update_gun_overlay(icon_state)
	else
		tank.secondary_weapon?.detach(tank.exit_location())
		tank.secondary_weapon = src
		if(tank.turret_overlay)
			// do not remove the dir = SOUTH becuase otherwise byond flips an internal flag so the dir is inherited from the turret
			tank.turret_overlay.secondary_overlay = image(tank.turret_icon, icon_state = icon_state + "_" + "[tank.turret_overlay.dir]", dir = SOUTH)
			tank.turret_overlay.add_overlay(tank.turret_overlay.secondary_overlay)
		else
			tank.secondary_weapon_overlay = image(tank.turret_icon, icon_state = icon_state + "_" + "[tank.dir]")
			tank.update_appearance(UPDATE_OVERLAYS)
	chassis = tank
	forceMove(tank)
	var/icon_list
	if(ammo?.default_ammo)
		icon_list = list(ammo.default_ammo.hud_state, ammo.default_ammo.hud_state_empty)
	else
		icon_list = list(hud_state_empty, hud_state_empty)
	for(var/mob/occupant AS in chassis.occupants)
		occupant.hud_used.add_ammo_hud(src, icon_list, ammo ? ammo.current_rounds : 0)

///detach this weapon to a chassis
/obj/item/armored_weapon/proc/detach(atom/moveto)
	if(chassis.primary_weapon == src)
		chassis.primary_weapon = null
		chassis.turret_overlay.update_gun_overlay()
	else
		chassis.secondary_weapon = null
		if(chassis.turret_overlay)
			chassis.turret_overlay.cut_overlay(chassis.turret_overlay.secondary_overlay)
			chassis.turret_overlay.secondary_overlay = null
		else
			chassis.secondary_weapon_overlay = null
			chassis.update_appearance(UPDATE_OVERLAYS)
	for(var/mob/occupant AS in chassis.occupants)
		occupant.hud_used.remove_ammo_hud(src)
	chassis = null
	forceMove(moveto)

/obj/item/armored_weapon/secondary_weapon
	name = "secondary cupola minigun"
	desc = "A robotically controlled minigun that spews lead."
	icon_state = "cupola"
	fire_sound = 'sound/weapons/guns/fire/tank_minigun_loop.ogg'
	windup_delay = 5
	windup_sound = 'sound/weapons/guns/fire/tank_minigun_start.ogg'
	weapon_slot = MODULE_SECONDARY
	secondary_equipped_icon = 'icons/obj/armored/3x3/tank_secondary_gun.dmi'
	ammo = /obj/item/ammo_magazine/tank/secondary_cupola
	accepted_ammo = list(/obj/item/ammo_magazine/tank/secondary_cupola)
	fire_mode = GUN_FIREMODE_AUTOMATIC
	projectile_delay = 2
	variance = 5
	rearm_time = 1 SECONDS
	maximum_magazines = 5
	hud_state_empty = "rifle_empty"

/obj/item/armored_weapon/ltaap
	name = "\improper LTA-AP chaingun"
	desc = "A hefty, large caliber chaingun"
	icon_state = "ltaap_chaingun"
	fire_sound = 'sound/weapons/guns/fire/tank_minigun_loop.ogg'
	windup_delay = 5
	windup_sound = 'sound/weapons/guns/fire/tank_minigun_start.ogg'
	weapon_slot = MODULE_PRIMARY
	secondary_equipped_icon = 'icons/obj/armored/3x3/tank_secondary_gun.dmi'
	ammo = /obj/item/ammo_magazine/tank/ltaap_chaingun
	accepted_ammo = list(/obj/item/ammo_magazine/tank/ltaap_chaingun)
	fire_mode = GUN_FIREMODE_AUTOMATIC
	variance = 5
	projectile_delay = 0.1 SECONDS
	rearm_time = 3 SECONDS
	maximum_magazines = 5
	hud_state_empty = "rifle_empty"

/obj/item/armored_weapon/apc_cannon
	name = "MKV-7 utility payload launcher"
	desc = "A double barrelled cannon which can rapidly deploy utility packages to the battlefield."
	icon_state = "APC uninstalled dualcannon"
	fire_sound = 'sound/weapons/guns/fire/tank_smokelauncher.ogg'
	ammo = /obj/item/ammo_magazine/tank/tank_slauncher
	accepted_ammo = list(
		/obj/item/ammo_magazine/tank/tank_slauncher,
		/obj/item/ammo_magazine/tank/tank_glauncher,
	)
	projectile_delay = 0.7 SECONDS
	hud_state_empty = "grenade_empty"
