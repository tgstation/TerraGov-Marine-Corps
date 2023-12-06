/obj/item/mecha_parts/mecha_equipment/weapon
	name = "mecha weapon"
	range = MECHA_RANGED
	equipment_slot = MECHA_WEAPON
	destroy_sound = 'sound/mecha/weapdestr.ogg'
	mech_flags = EXOSUIT_MODULE_COMBAT
	/// ammo datum/object typepath
	var/datum/ammo/ammotype
	///sound file to play when this weapon you know, fires
	var/fire_sound
	///current tracked target for fire(), updated when user drags
	var/atom/current_target
	///current mob firing this weapon. used for tracking for iff and etc in fire()
	var/mob/current_firer
	///Tracks windups
	var/windup_checked = WEAPON_WINDUP_NOT_CHECKED
	///Muzzle flash visual reference
	var/atom/movable/vis_obj/effect/muzzle_flash/muzzle_flash
	///list for this weapons flash offsets Format: MECHA_SLOT = list(DIR = list(PIXEL_X, PIXEL_Y))
	var/list/flash_offsets = list(
		MECHA_R_ARM = list("N" = list(0,0), "S" = list(0,0), "E" = list(0,0), "W" = list(0,0)),
		MECHA_L_ARM = list("N" = list(0,0), "S" = list(0,0), "E" = list(0,0), "W" = list(0,0)),
	)
	///Icon state of the muzzle flash effect.
	var/muzzle_iconstate
	///color of the muzzle flash while shooting
	var/muzzle_flash_color = COLOR_VERY_SOFT_YELLOW
	///Range of light when we flash while shooting
	var/muzzle_flash_lum = 3
	///windup sound played during windup
	var/windup_sound
	///windup delay for this object
	var/windup_delay = 0
	///scatter of this weapon. in degrees and modified by arm this is attached to
	var/variance = 0
	/// since mech guns only get one firemode this is for all types of shots
	var/projectile_delay = 3
	/// time between shots in a burst
	var/projectile_burst_delay = 2
	///bullets per burst if firemode is set to burst
	var/burst_amount = 0
	///fire mode to use for autofire
	var/fire_mode = GUN_FIREMODE_AUTOMATIC
	///how many seconds automatic rearming takes
	var/rearm_time = 2 SECONDS
	/// smoke effect for when the gun fires
	var/smoke_effect = FALSE

/obj/item/mecha_parts/mecha_equipment/weapon/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatedfire/autofire, projectile_delay, projectile_delay, projectile_burst_delay, burst_amount, fire_mode, CALLBACK(src, PROC_REF(set_bursting)), CALLBACK(src, PROC_REF(reset_fire)), CALLBACK(src, PROC_REF(fire)))
	equip_cooldown = projectile_delay
	muzzle_flash = new(src, muzzle_iconstate)

/obj/item/mecha_parts/mecha_equipment/weapon/action_checks(atom/target, ignore_cooldown)
	. = ..()
	if(!.)
		return
	if(HAS_TRAIT(chassis, TRAIT_MELEE_CORE) && !CHECK_BITFIELD(range, MECHA_MELEE))
		to_chat(chassis.occupants, span_warning("Error -- Melee Core active."))
		return FALSE

/obj/item/mecha_parts/mecha_equipment/weapon/action(mob/source, atom/target, list/modifiers)
	if(!action_checks(target))
		return FALSE
	. = ..()

	set_target(get_turf_on_clickcatcher(target, source, list2params(modifiers)))
	if(!current_target)
		return
	if(windup_delay && windup_checked == WEAPON_WINDUP_NOT_CHECKED)
		windup_checked = WEAPON_WINDUP_CHECKING
		playsound(chassis.loc, windup_sound, 30, TRUE)
		if(!do_after(source, windup_delay, NONE, chassis, BUSY_ICON_DANGER, BUSY_ICON_DANGER, extra_checks = CALLBACK(src, PROC_REF(do_after_checks), current_target)))
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
	RegisterSignal(source, COMSIG_MOB_MOUSEUP, PROC_REF(stop_fire))
	RegisterSignal(source, COMSIG_MOB_MOUSEDRAG, PROC_REF(change_target))
	SEND_SIGNAL(src, COMSIG_MECH_FIRE)
	source?.client?.mouse_pointer_icon = 'icons/effects/supplypod_target.dmi'

/obj/item/mecha_parts/mecha_equipment/weapon/proc/set_bursting(bursting)
	if(bursting)
		ADD_TRAIT(src, TRAIT_GUN_BURST_FIRING, VEHICLE_TRAIT)
		return
	REMOVE_TRAIT(src, TRAIT_GUN_BURST_FIRING, VEHICLE_TRAIT)

///Changes the current target.
/obj/item/mecha_parts/mecha_equipment/weapon/proc/change_target(datum/source, atom/src_object, atom/over_object, turf/src_location, turf/over_location, src_control, over_control, params)
	SIGNAL_HANDLER
	set_target(get_turf_on_clickcatcher(over_object, source, params))

///Sets the current target and registers for qdel to prevent hardels
/obj/item/mecha_parts/mecha_equipment/weapon/proc/set_target(atom/object)
	if(object == current_target || object == chassis)
		return
	if(current_target)
		UnregisterSignal(current_target, COMSIG_QDELETING)
	current_target = object
	if(current_target)
		RegisterSignal(current_target, COMSIG_QDELETING, PROC_REF(clean_target))

///Stops the Autofire component and resets the current cursor.
/obj/item/mecha_parts/mecha_equipment/weapon/proc/stop_fire(mob/living/source, atom/object, location, control, params)
	SIGNAL_HANDLER
	var/list/modifiers = params2list(params)
	if(!((modifiers[BUTTON] == RIGHT_CLICK) && chassis.equip_by_category[MECHA_R_ARM] == src) && !((modifiers[BUTTON] == LEFT_CLICK) && chassis.equip_by_category[MECHA_L_ARM] == src))
		return
	SEND_SIGNAL(src, COMSIG_MECH_STOP_FIRE)
	if(!HAS_TRAIT(src, TRAIT_GUN_BURST_FIRING))
		reset_fire()
	UnregisterSignal(source, list(COMSIG_MOB_MOUSEDRAG, COMSIG_MOB_MOUSEUP))

///Cleans the current target in case of Hardel
/obj/item/mecha_parts/mecha_equipment/weapon/proc/clean_target()
	SIGNAL_HANDLER
	current_target = get_turf(current_target)

///Resets the autofire component.
/obj/item/mecha_parts/mecha_equipment/weapon/proc/reset_fire()
	windup_checked = WEAPON_WINDUP_NOT_CHECKED
	current_firer?.client?.mouse_pointer_icon = chassis.mouse_pointer
	set_target(null)
	current_firer = null

///does any effects and changes to the projectile when it is fired
/obj/item/mecha_parts/mecha_equipment/weapon/proc/apply_weapon_modifiers(obj/projectile/projectile_to_fire, mob/firer)
	projectile_to_fire.shot_from = src
	if(istype(chassis, /obj/vehicle/sealed/mecha/combat/greyscale))
		var/obj/vehicle/sealed/mecha/combat/greyscale/grey = chassis
		var/datum/mech_limb/head/head = grey.limbs[MECH_GREY_HEAD]
		if(head)
			projectile_to_fire.accuracy *= head.accuracy_mod
		var/datum/mech_limb/arm/holding
		if(grey.equip_by_category[MECHA_R_ARM] == src)
			holding = grey.limbs[MECH_GREY_R_ARM]
		else
			holding = grey.limbs[MECH_GREY_L_ARM]
		projectile_to_fire.scatter = max(variance + holding?.scatter_mod, 0)
	projectile_to_fire.projectile_speed = projectile_to_fire.ammo.shell_speed
	if(projectile_to_fire.ammo.flags_ammo_behavior & AMMO_IFF)
		var/iff_signal
		if(ishuman(firer))
			var/mob/living/carbon/human/human_firer = firer
			var/obj/item/card/id/id = human_firer.get_idcard()
			iff_signal = id?.iff_signal
		projectile_to_fire.iff_signal = iff_signal

///actually executes firing when autofire asks for it, returns TRUE to keep firing FALSE to stop
/obj/item/mecha_parts/mecha_equipment/weapon/proc/fire()
	if(!action_checks(current_target, TRUE))
		return NONE
	var/dir_target_diff = get_between_angles(Get_Angle(chassis, current_target), dir2angle(chassis.dir))
	if(dir_target_diff > (MECH_FIRE_CONE_ALLOWED / 2))
		return AUTOFIRE_CONTINUE

	var/type_to_spawn = CHECK_BITFIELD(initial(ammotype.flags_ammo_behavior), AMMO_HITSCAN) ? /obj/projectile/hitscan : /obj/projectile
	var/obj/projectile/projectile_to_fire = new type_to_spawn(get_turf(src), initial(ammotype.hitscan_effect_icon))
	projectile_to_fire.generate_bullet(GLOB.ammo_list[ammotype])

	apply_weapon_modifiers(projectile_to_fire, current_firer)
	var/firing_angle = get_angle_with_scatter(chassis, current_target, projectile_to_fire.scatter, projectile_to_fire.p_x, projectile_to_fire.p_y)

	playsound(chassis, fire_sound, 25, TRUE)
	projectile_to_fire.fire_at(current_target, chassis, null, projectile_to_fire.ammo.max_range, projectile_to_fire.projectile_speed, firing_angle, suppress_light = HAS_TRAIT(src, TRAIT_GUN_SILENCED))

	chassis.use_power(energy_drain)
	chassis.log_message("Fired from [name], targeting [current_target] at [AREACOORD(current_target)].", LOG_ATTACK)

	if(!muzzle_flash || muzzle_flash.applied)
		return AUTOFIRE_CONTINUE|AUTOFIRE_SUCCESS

	var/prev_light = light_range
	if(!light_on && (light_range <= muzzle_flash_lum))
		set_light_range(muzzle_flash_lum)
		set_light_color(muzzle_flash_color)
		set_light_on(TRUE)
		addtimer(CALLBACK(src, PROC_REF(reset_light_range), prev_light), 1 SECONDS)

	var/mech_slot = chassis.equip_by_category[MECHA_R_ARM] == src ? MECHA_R_ARM : MECHA_L_ARM
	muzzle_flash.pixel_x = flash_offsets[mech_slot][dir2text_short(chassis.dir)][1]
	muzzle_flash.pixel_y = flash_offsets[mech_slot][dir2text_short(chassis.dir)][2]
	switch(chassis.dir)
		if(NORTH)
			muzzle_flash.layer = initial(muzzle_flash.layer)
		if(SOUTH, EAST, WEST)
			muzzle_flash.layer = ABOVE_ALL_MOB_LAYER+0.01
	muzzle_flash.transform = null
	muzzle_flash.transform = turn(muzzle_flash.transform, firing_angle)
	chassis.vis_contents += muzzle_flash
	muzzle_flash.applied = TRUE

	addtimer(CALLBACK(src, PROC_REF(remove_flash), muzzle_flash), 0.2 SECONDS)
	if(smoke_effect)
		var/x_component = sin(firing_angle) * 40
		var/y_component = cos(firing_angle) * 40
		var/obj/effect/abstract/particle_holder/gun_smoke = new(get_turf(src), /particles/firing_smoke)
		gun_smoke.particles.velocity = list(x_component, y_component)
		gun_smoke.particles.position = list(flash_offsets[mech_slot][dir2text_short(chassis.dir)][1] - 16, flash_offsets[mech_slot][dir2text_short(chassis.dir)][2])
		addtimer(VARSET_CALLBACK(gun_smoke.particles, count, 0), 5)
		addtimer(VARSET_CALLBACK(gun_smoke.particles, drift, 0), 3)
		QDEL_IN(gun_smoke, 0.6 SECONDS)
	return AUTOFIRE_CONTINUE|AUTOFIRE_SUCCESS

/obj/item/mecha_parts/mecha_equipment/weapon/proc/reset_light_range(lightrange)
	set_light_range(lightrange)
	set_light_color(initial(light_color))
	if(lightrange <= 0)
		set_light_on(FALSE)

///removes the flash object from viscontents
/obj/item/mecha_parts/mecha_equipment/weapon/proc/remove_flash(atom/movable/vis_obj/effect/muzzle_flash/flash)
	chassis.vis_contents -= flash
	flash.applied = FALSE

//Base energy weapon type
/obj/item/mecha_parts/mecha_equipment/weapon/energy
	name = "general energy weapon"
	muzzle_flash_color = COLOR_LASER_RED
	muzzle_iconstate = "muzzle_flash_laser"

//Base ballistic weapon type
/obj/item/mecha_parts/mecha_equipment/weapon/ballistic
	name = "general ballistic weapon"
	fire_sound = 'sound/weapons/guns/fire/gunshot.ogg'
	smoke_effect = TRUE
	///ammo left in the mag
	var/projectiles
	///ammo left total
	var/projectiles_cache
	///ammo total storable
	var/projectiles_cache_max
	///Whather this object only uses one mag and cannot be reloaded with the UI button
	var/disabledreload
	/// string define for the ammo type that this can be reloaded with
	var/ammo_type
	///list of icons to display for ammo counter: list("hud_normal", "hud_empty")
	var/hud_icons = list("rifle", "rifle_empty")

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/attach(obj/vehicle/sealed/mecha/M, attach_right)
	. = ..()
	for(var/mob/occupant AS in chassis.occupants)
		occupant.hud_used.add_ammo_hud(src, hud_icons, projectiles)

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/detach(atom/moveto)
	for(var/mob/occupant AS in chassis.occupants)
		occupant.hud_used.remove_ammo_hud(src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/action_checks(target)
	if(!..())
		return FALSE
	if(projectiles <= 0)
		return FALSE
	return TRUE

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(action == "reload")
		var/mob/occupant = usr
		if(occupant && !do_after(occupant, rearm_time, IGNORE_HELD_ITEM, chassis, BUSY_ICON_GENERIC))
			return FALSE
		rearm()
		return TRUE

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/rearm()
	if(projectiles >= initial(projectiles))
		return FALSE
	var/projectiles_to_add = initial(projectiles) - projectiles
	if(!projectiles_cache)
		return FALSE
	if(projectiles_to_add <= projectiles_cache)
		projectiles = projectiles + projectiles_to_add
		projectiles_cache = projectiles_cache - projectiles_to_add
	else
		projectiles = projectiles + projectiles_cache
		projectiles_cache = 0
	log_message("Rearmed [src].", LOG_MECHA)
	for(var/mob/occupant AS in chassis.occupants)
		occupant.hud_used.update_ammo_hud(src, hud_icons, projectiles)
	return TRUE

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/needs_rearm()
	return projectiles <= 0

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/fire()
	. = ..()
	if(!(. & AUTOFIRE_SUCCESS))
		return
	projectiles--
	for(var/mob/occupant AS in chassis.occupants)
		occupant.hud_used.update_ammo_hud(src, hud_icons, projectiles)
	if(projectiles > 0)
		return
	playsound(src, 'sound/weapons/guns/misc/empty_alarm.ogg', 25, 1)
	if(LAZYACCESS(current_firer.do_actions, src) || projectiles_cache < 1)
		return
	if(!do_after(current_firer, rearm_time, IGNORE_HELD_ITEM, chassis, BUSY_ICON_GENERIC))
		return
	rearm()

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/carbine
	name = "\improper FNX-99 \"Hades\" Carbine"
	desc = "A weapon for combat exosuits. Shoots incendiary bullets."
	icon_state = "mecha_carbine"
	equip_cooldown = 10
	ammotype = /datum/ammo/bullet/machinegun
	projectiles = 24
	projectiles_cache = 24
	projectiles_cache_max = 96
	harmful = TRUE
	ammo_type = MECHA_AMMO_INCENDIARY

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot
	name = "\improper LBX AC 10 \"Scattershot\""
	desc = "A weapon for combat exosuits. Shoots a spread of pellets."
	icon_state = "mecha_scatter"
	equip_cooldown = 20
	ammotype = /datum/ammo/bullet/shotgun/buckshot
	projectiles = 40
	projectiles_cache = 40
	projectiles_cache_max = 160
	variance = 25
	harmful = TRUE
	ammo_type = MECHA_AMMO_BUCKSHOT

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg
	name = "\improper Ultra AC 2"
	desc = "A weapon for combat exosuits. Shoots a rapid, three shot burst."
	icon_state = "mecha_uac2"
	equip_cooldown = 10
	ammotype = /datum/ammo/bullet/minigun
	projectiles = 300
	projectiles_cache = 300
	projectiles_cache_max = 1200
	variance = 6
	projectile_delay = 2
	harmful = TRUE
	ammo_type = MECHA_AMMO_LMG

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack
	name = "\improper SRM-8 missile rack"
	desc = "A weapon for combat exosuits. Launches light explosive missiles."
	icon_state = "mecha_missilerack"
	ammotype = /datum/ammo/rocket/atgun_shell/he
	fire_sound = 'sound/weapons/guns/fire/tank_cannon1.ogg'
	projectiles = 8
	projectiles_cache = 0
	projectiles_cache_max = 0
	disabledreload = TRUE
	equip_cooldown = 60
	harmful = TRUE
	ammo_type = MECHA_AMMO_MISSILE_HE

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/breaching
	name = "\improper BRM-6 missile rack"
	desc = "A weapon for combat exosuits. Launches low-explosive breaching missiles designed to explode only when striking a sturdy target."
	icon_state = "mecha_missilerack_six"
	ammotype = /datum/ammo/rocket/atgun_shell
	fire_sound = 'sound/weapons/guns/fire/tank_cannon1.ogg'
	projectiles = 6
	projectiles_cache = 0
	projectiles_cache_max = 0
	disabledreload = TRUE
	equip_cooldown = 60
	harmful = TRUE
	ammo_type = MECHA_AMMO_MISSILE_AP


/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher
	var/missile_speed = 2
	var/missile_range = 30

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/action(mob/source, atom/target, list/modifiers)
	if(!action_checks(target))
		return FALSE
	var/dir_target_diff = get_between_angles(Get_Angle(chassis, target), dir2angle(chassis.dir))
	if(dir_target_diff > (MECH_FIRE_CONE_ALLOWED / 2))
		return TRUE
	var/obj/O = new ammotype(chassis.loc)
	playsound(chassis, fire_sound, 50, TRUE)
	log_message("Launched a [O] from [src], targeting [target].", LOG_MECHA)
	projectiles--
	proj_init(O, source)
	O.throw_at(target, missile_range, missile_speed, source, FALSE)
	TIMER_COOLDOWN_START(chassis, COOLDOWN_MECHA_EQUIPMENT(type), equip_cooldown)
	chassis.use_power(energy_drain)
	if(smoke_effect)
		var/firing_angle = Get_Angle(get_turf(src), target)
		var/x_component = sin(firing_angle) * 40
		var/y_component = cos(firing_angle) * 40
		var/obj/effect/abstract/particle_holder/gun_smoke = new(get_turf(src), /particles/firing_smoke)
		gun_smoke.particles.velocity = list(x_component, y_component)
		var/mech_slot = chassis.equip_by_category[MECHA_R_ARM] == src ? MECHA_R_ARM : MECHA_L_ARM
		gun_smoke.particles.position = list(flash_offsets[mech_slot][dir2text_short(chassis.dir)][1] - 16, flash_offsets[mech_slot][dir2text_short(chassis.dir)][2])
		addtimer(VARSET_CALLBACK(gun_smoke.particles, count, 0), 5)
		addtimer(VARSET_CALLBACK(gun_smoke.particles, drift, 0), 3)
		QDEL_IN(gun_smoke, 0.6 SECONDS)
	for(var/mob/occupant AS in chassis.occupants)
		occupant.hud_used.update_ammo_hud(src, hud_icons, projectiles)
	if(projectiles > 0)
		return TRUE
	playsound(src, 'sound/weapons/guns/misc/empty_alarm.ogg', 25, 1)
	return TRUE

//used for projectile initilisation (priming flashbang) and additional logging
/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/proc/proj_init(obj/O, mob/user)
	return


/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/flashbang
	name = "\improper SGL-6 grenade launcher"
	desc = "A weapon for combat exosuits. Launches primed flashbangs."
	icon_state = "mecha_grenadelnchr"
	ammotype = /obj/item/explosive/grenade/flashbang
	fire_sound = 'sound/weapons/guns/fire/grenadelauncher.ogg'
	projectiles = 6
	projectiles_cache = 6
	projectiles_cache_max = 24
	missile_speed = 1.5
	equip_cooldown = 60
	ammo_type = MECHA_AMMO_FLASHBANG
	var/det_time = 20

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/flashbang/proj_init(obj/item/explosive/grenade/flashbang/F, mob/user)
	var/turf/T = get_turf(src)
	message_admins("[ADMIN_LOOKUPFLW(user)] fired a [F] in [ADMIN_VERBOSEJMP(T)]")
	log_game("[key_name(user)] fired a [F] in [AREACOORD(T)]")
	addtimer(CALLBACK(F, TYPE_PROC_REF(/obj/item/explosive/grenade/flashbang, prime)), det_time)
