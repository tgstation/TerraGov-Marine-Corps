/*!
 * Greyscale mech equipment file
 *
 * Basically all equipment that you can add onto a mech should go here
 * naming scheme is [Greek titan/titan relative] + [weapon type]
 * when setting variance remember that it's negatively modified by the arm it's attached to
 * note that weapon vars are not the same as guns
 * Notably:
 * No autoburst var, uses basic var instead
 * only one firemode per gun
 * equip_cooldown gets overriden unless propjectile is thrown
 */

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/pistol
	name = "\improper Cottus pistol"
	icon = 'icons/mecha/mecha_equipment_64x32.dmi'
	desc = "The smallest weapon available to mechs. It packs a small punch, but allows the mech to achieve higher mobility."
	icon_state = "pistol"
	fire_sound = 'sound/mecha/weapons/mech_pistol.ogg'
	muzzle_iconstate = "muzzle_flash_light"
	flash_offsets = list(
		MECHA_R_ARM = list("N" = list(36,30), "S" = list(-2,16), "E" = list(44,16), "W" = list(-13,36)),
		MECHA_L_ARM = list("N" = list(-4,30), "S" = list(32,16), "E" = list(44,36), "W" = list(-13,16)),
	)
	mech_flags = EXOSUIT_MODULE_GREYSCALE
	ammotype = /datum/ammo/bullet/pistol/mech
	obj_integrity = 500
	projectiles = 20
	projectiles_cache = 400
	projectiles_cache_max = 400
	variance = 10
	slowdown = 0
	projectile_delay = 0.3 SECONDS
	harmful = TRUE
	ammo_type = MECHA_AMMO_PISTOL
	hud_icons = list("pistol", "pistol_empty")
	fire_mode = GUN_FIREMODE_SEMIAUTO

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/burstpistol
	name = "\improper Crius burst pistol"
	icon = 'icons/mecha/mecha_equipment_64x32.dmi'
	desc = "A burstfiring weapon fitted for mechs. Offers higher mobility and accuracy than larger weapons, but reduced damage."
	icon_state = "burstpistol"
	fire_sound = 'sound/mecha/weapons/mech_pistol.ogg'
	muzzle_iconstate = "muzzle_flash_light"
	mech_flags = EXOSUIT_MODULE_GREYSCALE
	flash_offsets = list(
		MECHA_R_ARM = list("N" = list(36,30), "S" = list(-2,8), "E" = list(52,8), "W" = list(-21,28)),
		MECHA_L_ARM = list("N" = list(-4,30), "S" = list(32,8), "E" = list(52,28), "W" = list(-20,8)),
	)
	ammotype = /datum/ammo/bullet/pistol/mech/burst
	obj_integrity = 450
	projectiles = 42
	projectiles_cache = 820
	projectiles_cache_max = 820
	variance = 15
	slowdown = 0.1
	projectile_delay = 0.6 SECONDS
	burst_amount = 3
	projectile_burst_delay = 0.1 SECONDS
	harmful = TRUE
	ammo_type = MECHA_AMMO_BURSTPISTOL
	hud_icons = list("pistol_light", "pistol_empty")
	fire_mode = GUN_FIREMODE_AUTOBURST

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/smg
	name = "\improper Coeus submachine gun"
	icon = 'icons/mecha/mecha_equipment_64x32.dmi'
	desc = "As the smallest autofiring weapon, it offers improved mobility but less firepower than most of it's larger cousins."
	muzzle_iconstate = "muzzle_flash_light"
	icon_state = "smg"
	fire_sound = 'sound/mecha/weapons/mech_smg.ogg'
	mech_flags = EXOSUIT_MODULE_GREYSCALE
	flash_offsets = list(
		MECHA_R_ARM = list("N" = list(36,30), "S" = list(-2,12), "E" = list(54,14), "W" = list(-20,34)),
		MECHA_L_ARM = list("N" = list(-4,30), "S" = list(32,12), "E" = list(52,34), "W" = list(-22,14)),
	)
	ammotype = /datum/ammo/bullet/smg/mech
	obj_integrity = 400
	projectiles = 60
	projectiles_cache = 420
	projectiles_cache_max = 420
	variance = 20
	projectile_delay = 0.15 SECONDS
	slowdown = 0.15
	harmful = TRUE
	ammo_type = MECHA_AMMO_SMG
	hud_icons = list("smg", "smg_empty")
	fire_mode = GUN_FIREMODE_AUTOMATIC

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/burstrifle
	name = "\improper Tethys burst rifle"
	icon = 'icons/mecha/mecha_equipment_64x32.dmi'
	desc = "Medium-sized mech assault weapon. Similar to the Cronus assault rifle, but fires in bursts."
	icon_state = "burstrifle"
	fire_sound = 'sound/mecha/weapons/mech_rifle.ogg'
	mech_flags = EXOSUIT_MODULE_GREYSCALE
	flash_offsets = list(
		MECHA_R_ARM = list("N" = list(36,30), "S" = list(-2,-6), "E" = list(64,17), "W" = list(-33,37)),
		MECHA_L_ARM = list("N" = list(-4,30), "S" = list(32,-6), "E" = list(63,37), "W" = list(-34,17)),
	)
	ammotype = /datum/ammo/bullet/rifle/mech/burst
	obj_integrity = 400
	projectiles = 72
	projectiles_cache = 360
	projectiles_cache_max = 360
	variance = 15
	projectile_delay = 0.6 SECONDS
	burst_amount = 3
	projectile_burst_delay = 0.2 SECONDS
	slowdown = 0.25
	harmful = TRUE
	ammo_type = MECHA_AMMO_BURSTRIFLE
	hud_icons = list("hivelo", "hivelo_empty")
	fire_mode = GUN_FIREMODE_AUTOBURST

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/assault_rifle
	name = "\improper Cronus assault rifle"
	icon = 'icons/mecha/mecha_equipment_64x32.dmi'
	desc = "The stock-and-standard extra-sized multipurpose rifle for TGMC mech units."
	icon_state = "assaultrifle"
	fire_sound = 'sound/mecha/weapons/mech_rifle.ogg'
	mech_flags = EXOSUIT_MODULE_GREYSCALE
	flash_offsets = list(
		MECHA_R_ARM = list("N" = list(36,30), "S" = list(-2,-6), "E" = list(64,17), "W" = list(-34,37)),
		MECHA_L_ARM = list("N" = list(-4,30), "S" = list(32,-6), "E" = list(64,37), "W" = list(-34,17)),
	)
	ammotype = /datum/ammo/bullet/rifle/mech
	obj_integrity = 400
	projectiles = 50
	projectiles_cache = 300
	projectiles_cache_max = 300
	variance = 15
	projectile_delay = 0.2 SECONDS
	slowdown = 0.2
	harmful = TRUE
	ammo_type = MECHA_AMMO_RIFLE
	hud_icons = list("rifle", "rifle_empty")
	fire_mode = GUN_FIREMODE_AUTOMATIC

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/shotgun
	name = "\improper Phoebe shotgun"
	icon = 'icons/mecha/mecha_equipment_64x32.dmi'
	desc = "The TGMC classic weapon, but bigger and better! Fires plus-sized buckshot for high damage in close combat."
	icon_state = "shotgun"
	fire_sound = 'sound/mecha/weapons/mech_shotgun.ogg'
	mech_flags = EXOSUIT_MODULE_GREYSCALE
	flash_offsets = list(
		MECHA_R_ARM = list("N" = list(36,30), "S" = list(-2,-4), "E" = list(61,16), "W" = list(-31,36)),
		MECHA_L_ARM = list("N" = list(-4,30), "S" = list(32,-4), "E" = list(61,36), "W" = list(-31,16)),
	)
	ammotype = /datum/ammo/bullet/shotgun/mech
	obj_integrity = 350
	projectiles = 10
	projectiles_cache = 50
	projectiles_cache_max = 50
	variance = 6
	projectile_delay = 1.5 SECONDS
	slowdown = 0.3
	harmful = TRUE
	ammo_type = MECHA_AMMO_SHOTGUN
	hud_icons = list("shotgun_buckshot", "shotgun_empty")
	fire_mode = GUN_FIREMODE_SEMIAUTO

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/greyscale_lmg
	name = "\improper Briareus LMG"
	icon = 'icons/mecha/mecha_equipment_64x32.dmi'
	desc = "A massive hulk of metal that fires base-bleed LMG rounds. Like the standard LMG, but bigger, better and heavier."
	icon_state = "lmg"
	fire_sound = 'sound/mecha/weapons/mech_lmg.ogg'
	mech_flags = EXOSUIT_MODULE_GREYSCALE
	flash_offsets = list(
		MECHA_R_ARM = list("N" = list(36,30), "S" = list(-2,-6), "E" = list(64,17), "W" = list(-34,37)),
		MECHA_L_ARM = list("N" = list(-4,30), "S" = list(32,-6), "E" = list(64,37), "W" = list(-34,17)),
	)
	ammotype = /datum/ammo/bullet/rifle/mech/lmg
	obj_integrity = 400
	projectiles = 80
	projectiles_cache = 400
	projectiles_cache_max = 400
	variance = 25
	projectile_delay = 0.15 SECONDS
	slowdown = 0.3
	harmful = TRUE
	ammo_type = MECHA_AMMO_GREY_LMG
	hud_icons = list("rifle_heavy", "rifle_empty")
	fire_mode = GUN_FIREMODE_AUTOMATIC

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/light_cannon
	name = "\improper Leto light autocannon"
	icon = 'icons/mecha/mecha_equipment_64x32.dmi'
	desc = "A drum-fed autocannon that fires fragmentation rounds that burst in a frontal cone when the bullet impacts. Extra effective against clusters of enemies."
	icon_state = "lightcannon"
	fire_sound = 'sound/mecha/weapons/mech_light_cannon.ogg'
	mech_flags = EXOSUIT_MODULE_GREYSCALE
	flash_offsets = list(
		MECHA_R_ARM = list("N" = list(36,30), "S" = list(-2,-15), "E" = list(80,4), "W" = list(-50,24)),
		MECHA_L_ARM = list("N" = list(-4,30), "S" = list(32,-15), "E" = list(80,24), "W" = list(-50,4)),
	)
	ammotype = /datum/ammo/tx54/mech
	obj_integrity = 400
	projectiles = 30
	projectiles_cache = 300
	projectiles_cache_max = 300
	variance = 20
	projectile_delay = 0.7 SECONDS
	slowdown = 0.4
	harmful = TRUE
	ammo_type = MECHA_AMMO_LIGHTCANNON
	hud_icons = list("grenade_airburst", "grenade_empty")
	fire_mode = GUN_FIREMODE_AUTOMATIC

/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser_rifle
	name = "\improper Aegaeon laser rifle"
	icon = 'icons/mecha/mecha_equipment_64x32.dmi'
	desc = "Standard mech laser rifle. Does not require amnmo refills and shoots highly accurate lasers that immediately hit, but deals slightly less damage compared to similar weapons."
	icon_state = "lasermg"
	fire_sound = 'sound/mecha/weapons/mech_laser_heavy.ogg'
	mech_flags = EXOSUIT_MODULE_GREYSCALE
	flash_offsets = list(
		MECHA_R_ARM = list("N" = list(33,68), "S" = list(-2,-6), "E" = list(80,13), "W" = list(-50,33)),
		MECHA_L_ARM = list("N" = list(0,68), "S" = list(32,-6), "E" = list(80,33), "W" = list(-50,13)),
	)
	ammotype = /datum/ammo/energy/lasgun/marine/mech
	obj_integrity = 400
	energy_drain = 10
	variance = 0
	projectile_delay = 0.4 SECONDS
	slowdown = 0.4
	harmful = TRUE
	fire_mode = GUN_FIREMODE_AUTOMATIC

/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser_projector
	name = "\improper Gyges laser projector"
	icon = 'icons/mecha/mecha_equipment_64x32.dmi'
	desc = "A laser projector, capable of burstfiring. Does not require amnmo refills and shoots highly accurate lasers that immediately hit, but deals slightly less damage compared to similar weapons."
	icon_state = "laserrifle"
	fire_sound = 'sound/mecha/weapons/mech_laser_heavy.ogg'
	mech_flags = EXOSUIT_MODULE_GREYSCALE
	flash_offsets = list(
		MECHA_R_ARM = list("N" = list(33,52), "S" = list(-2,-6), "E" = list(75,11), "W" = list(-45,31)),
		MECHA_L_ARM = list("N" = list(0,52), "S" = list(32,-6), "E" = list(75,31), "W" = list(-45,11)),
	)
	ammotype = /datum/ammo/energy/lasgun/marine/mech/burst
	obj_integrity = 400
	energy_drain = 5
	variance = 0
	projectile_delay = 0.6 SECONDS
	burst_amount = 3
	projectile_burst_delay = 0.2 SECONDS
	slowdown = 0.4
	harmful = TRUE
	fire_mode = GUN_FIREMODE_AUTOBURST

/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser_smg
	name = "\improper Mnemosyne laser SMG"
	icon = 'icons/mecha/mecha_equipment_64x32.dmi'
	desc = "Standard mech laser SMG. Does not require amnmo refills and shoots highly accurate lasers that immediately hit, but deals slightly less damage compared to similar weapons. More mobile than the laser rifle."
	icon_state = "lasersmg"
	fire_sound = 'sound/mecha/weapons/mech_laser_light.ogg'
	flash_offsets = list(
		MECHA_R_ARM = list("N" = list(33,48), "S" = list(-2,6), "E" = list(67,11), "W" = list(-37,31)),
		MECHA_L_ARM = list("N" = list(0,48), "S" = list(32,6), "E" = list(67,31), "W" = list(-37,11)),
	)
	mech_flags = EXOSUIT_MODULE_GREYSCALE
	ammotype = /datum/ammo/energy/lasgun/marine/mech/smg
	obj_integrity = 400
	energy_drain = 5
	variance = 0
	projectile_delay = 0.2 SECONDS
	slowdown = 0.2
	harmful = TRUE
	fire_mode = GUN_FIREMODE_AUTOMATIC

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/heavy_cannon
	name = "\improper Themis heavy cannon"
	icon = 'icons/mecha/mecha_equipment_64x32.dmi'
	desc = "Nothing says \"Go to hell\" like a tank cannon mounted on a war robot. Packs a big punch despite needing a reload after each shot."
	icon_state = "heavycannon"
	fire_sound = 'sound/mecha/weapons/mech_heavy_cannon.ogg'
	flash_offsets = list(
		MECHA_R_ARM = list("N" = list(36,48), "S" = list(-1,1), "E" = list(72,32), "W" = list(-42,48)),
		MECHA_L_ARM = list("N" = list(-4,48), "S" = list(33,1), "E" = list(72,48), "W" = list(-42,32)),
	)
	mech_flags = EXOSUIT_MODULE_GREYSCALE
	ammotype = /datum/ammo/bullet/apfsds
	obj_integrity = 400
	projectiles = 1
	projectiles_cache = 10
	projectiles_cache_max = 10
	variance = 0
	projectile_delay = 1 SECONDS
	slowdown = 1.2
	harmful = TRUE
	ammo_type = MECHA_AMMO_HEAVYCANNON
	hud_icons = list("shell_apcr", "shell_empty")
	fire_mode = GUN_FIREMODE_SEMIAUTO

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/minigun
	name = "\improper Rhea vulcan cannon"
	icon = 'icons/mecha/mecha_equipment_64x32.dmi'
	desc = "Mobility isn't needed when you can just hide behind a hail of bullets! Requires windup before firing."
	icon_state = "minigun"
	fire_sound = 'sound/mecha/weapons/mech_minigun.ogg'
	windup_sound = 'sound/weapons/guns/fire/tank_minigun_start.ogg'
	flash_offsets = list(
		MECHA_R_ARM = list("N" = list(35,60), "S" = list(-2,-11), "E" = list(64,0), "W" = list(-34,20)),
		MECHA_L_ARM = list("N" = list(-2,60), "S" = list(32,-11), "E" = list(64,20), "W" = list(-34,0)),
	)
	mech_flags = EXOSUIT_MODULE_GREYSCALE
	ammotype = /datum/ammo/bullet/minigun/mech
	obj_integrity = 400
	projectiles = 200
	projectiles_cache = 600
	projectiles_cache_max = 600
	variance = 35
	projectile_delay = 1.5
	slowdown = 0.7
	windup_delay = 0.5 SECONDS
	harmful = TRUE
	ammo_type = MECHA_AMMO_MINIGUN
	hud_icons = list("smartgun", "smartgun_empty")
	fire_mode = GUN_FIREMODE_AUTOMATIC

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/sniper
	name = "\improper Oceanus sniper rifle"
	icon = 'icons/mecha/mecha_equipment_64x32.dmi'
	desc = "A anti-tank rifle only capable of being wielded by mechs. Originally designed for fighting small armored vehicles, but works just as well against similarly sized creatures. Has IFF."
	icon_state = "sniper"
	fire_sound = 'sound/mecha/weapons/mech_sniper.ogg'
	flash_offsets = list(
		MECHA_R_ARM = list("N" = list(36,30), "S" = list(-2,-14), "E" = list(80,0), "W" = list(-50,22)),
		MECHA_L_ARM = list("N" = list(-4,30), "S" = list(32,-14), "E" = list(80,22), "W" = list(-50,0)),
	)
	mech_flags = EXOSUIT_MODULE_GREYSCALE
	ammotype = /datum/ammo/bullet/sniper/mech
	obj_integrity = 200
	projectiles = 15
	projectiles_cache = 60
	projectiles_cache_max = 60
	variance = -15
	projectile_delay = 1 SECONDS
	slowdown = 0.6
	harmful = TRUE
	ammo_type = MECHA_AMMO_SNIPER
	hud_icons = list("sniper_supersonic", "sniper_empty")
	fire_mode = GUN_FIREMODE_SEMIAUTO

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/grenadelauncher
	name = "\improper Hyperion grenade launcher"
	desc = "The TGMC's definitive answer to whether a bigger boom is better. Fires standard HEDP grenades."
	icon = 'icons/mecha/mecha_equipment_64x32.dmi'
	icon_state = "grenadelauncher"
	fire_sound = 'sound/weapons/guns/fire/grenadelauncher.ogg'
	mech_flags = EXOSUIT_MODULE_GREYSCALE
	ammotype = /obj/item/explosive/grenade
	obj_integrity = 350
	projectiles = 10
	projectiles_cache = 20
	projectiles_cache_max = 20
	projectile_delay = 1.5 SECONDS
	missile_speed = 1.5
	equip_cooldown = 2 SECONDS
	slowdown = 0.4
	ammo_type = MECHA_AMMO_GRENADE
	hud_icons = list("grenade_he", "grenade_empty")
	fire_mode = GUN_FIREMODE_SEMIAUTO

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/grenadelauncher/proj_init(obj/item/explosive/grenade/nade, mob/user)
	var/turf/T = get_turf(src)
	log_game("[key_name(user)] fired a [nade] in [AREACOORD(T)]")
	nade.det_time = min(1 SECONDS, nade.det_time)
	nade.launched = TRUE
	nade.activate(user)
	nade.throwforce += nade.launchforce

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/flamethrower
	name = "\improper Helios flamethrower"
	icon = 'icons/mecha/mecha_equipment_64x32.dmi'
	desc = "A specialized flamer for mounting on mechs. Bad mobility, but the additional napalm more than makes up for it."
	icon_state = "flamer"
	fire_sound = 'sound/mecha/weapons/mech_flamer.ogg'
	flash_offsets = list(
		MECHA_R_ARM = list("N" = list(36,30), "S" = list(-2,-11), "E" = list(77,3), "W" = list(-47,23)),
		MECHA_L_ARM = list("N" = list(-4,30), "S" = list(32,-11), "E" = list(77,23), "W" = list(-47,3)),
	)
	mech_flags = EXOSUIT_MODULE_GREYSCALE
	ammotype = /datum/ammo/flamethrower/mech_flamer
	obj_integrity = 250
	projectiles = 20
	projectiles_cache = 20 // low ammo counts so player cant just spam fire while rushing infinitely
	projectiles_cache_max = 20
	variance = 0
	projectile_delay = 2 SECONDS
	slowdown = 0.4
	harmful = TRUE
	ammo_type = MECHA_AMMO_FLAMER
	hud_icons = list("flame", "flame_empty")
	fire_mode = GUN_FIREMODE_SEMIAUTO

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/rpg
	name = "\improper Iapetus missile pod"
	icon = 'icons/mecha/mecha_equipment_64x32.dmi'
	desc = "A mech missile pod. Does not hold a lot of spare ammo and requires frequent external refills. But hey, exploding missiles all the way!"
	icon_state = "rpg"
	fire_sound = 'sound/mecha/weapons/mech_rpg.ogg'
	flash_offsets = list(
		MECHA_R_ARM = list("N" = list(36,48), "S" = list(-1,1), "E" = list(56,20), "W" = list(-26,36)),
		MECHA_L_ARM = list("N" = list(-4,48), "S" = list(33,1), "E" = list(56,36), "W" = list(-26,20)),
	)
	mech_flags = EXOSUIT_MODULE_GREYSCALE
	ammotype = /datum/ammo/rocket/mech
	obj_integrity = 400
	projectiles = 1
	projectiles_cache = 1
	projectiles_cache_max = 1
	variance = 0
	projectile_delay = 2 SECONDS
	slowdown = 0.7
	harmful = TRUE
	ammo_type = MECHA_AMMO_RPG
	hud_icons = list("rocket_he", "rocket_empty")
	fire_mode = GUN_FIREMODE_SEMIAUTO
