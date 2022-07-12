/obj/item/mecha_parts/mecha_equipment/weapon
	name = "mecha weapon"
	range = MECHA_RANGED
	equipment_slot = MECHA_WEAPON
	destroy_sound = 'sound/mecha/weapdestr.ogg'
	mech_flags = EXOSUIT_MODULE_COMBAT
	var/ammotype
	var/fire_sound
	var/projectiles_per_shot = 1
	var/variance = 0
	var/randomspread = FALSE //use random spread for machineguns, instead of shotgun scatter
	var/projectile_delay = 0
	var/obj/effect/firing_effect = /atom/movable/vis_obj/effect/muzzle_flash //the visual effect appearing when the weapon is fired.

/obj/item/mecha_parts/mecha_equipment/weapon/Initialize()
	. = ..()
	firing_effect = new firing_effect

/obj/item/mecha_parts/mecha_equipment/weapon/action(mob/source, atom/target, list/modifiers)
	if(!action_checks(target))
		return FALSE
	. = ..()
	chassis.vis_contents += firing_effect
	fire_bullet(source, target)
	addtimer(CALLBACK(src, .proc/remove_flash), 2)
	for(var/i in 1 to projectiles_per_shot)
		addtimer(CALLBACK(src, .proc/fire_bullet, source, target), (i-1)*projectile_delay)

	chassis.log_message("Fired from [name], targeting [target].", LOG_ATTACK)

///removes the flash object from viscontents
/obj/item/mecha_parts/mecha_equipment/weapon/proc/remove_flash()
	chassis.vis_contents -= firing_effect

///proc that actually fires the bullet after timer, should use autofire instead
/obj/item/mecha_parts/mecha_equipment/weapon/proc/fire_bullet(mob/source, atom/target)
	if(energy_drain && !chassis.has_charge(energy_drain))//in case we run out of energy mid-burst, such as emp
		return
	var/angle = Get_Angle(src, target)
	var/obj/projectile/projectile_obj = new(get_turf(src))
	projectile_obj.generate_bullet(GLOB.ammo_list[ammotype])
	projectile_obj.fire_at(target, chassis, chassis) // get_angle_with_scatter
	firing_effect.transform = turn(firing_effect.transform, angle)
	playsound(chassis, fire_sound, 50, TRUE)

//Base energy weapon type
/obj/item/mecha_parts/mecha_equipment/weapon/energy
	name = "general energy weapon"
	firing_effect = /atom/movable/vis_obj/effect/muzzle_flash

//Base ballistic weapon type
/obj/item/mecha_parts/mecha_equipment/weapon/ballistic
	name = "general ballistic weapon"
	fire_sound = 'sound/weapons/guns/fire/gunshot.ogg'
	var/projectiles
	var/projectiles_cache //ammo to be loaded in, if possible.
	var/projectiles_cache_max
	var/disabledreload //For weapons with no cache (like the rockets) which are reloaded by hand
	var/ammo_type

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/action_checks(target)
	if(!..())
		return FALSE
	if(projectiles <= 0)
		return FALSE
	return TRUE

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(action == "reload")
		rearm()
		return TRUE

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/rearm()
	if(projectiles < initial(projectiles))
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
		return TRUE

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/needs_rearm()
	return projectiles <= 0


/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/action(mob/source, atom/target, list/modifiers)
	. = ..()
	if(!.)
		return
	projectiles -= projectiles_per_shot

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
	projectiles_per_shot = 3
	variance = 6
	randomspread = 1
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
		return
	var/obj/O = new ammotype(chassis.loc)
	playsound(chassis, fire_sound, 50, TRUE)
	log_message("Launched a [O] from [src], targeting [target].", LOG_MECHA)
	projectiles--
	proj_init(O, source)
	O.throw_at(target, missile_range, missile_speed, source, FALSE)
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
	addtimer(CALLBACK(F, /obj/item/explosive/grenade/flashbang.proc/prime), det_time)
