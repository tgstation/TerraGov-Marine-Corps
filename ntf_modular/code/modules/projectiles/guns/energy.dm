/obj/item/weapon/gun/energy/lasgun/lasrifle/plasma_kz/kpx
	name = "\improper KPX/47 Spectra"
	desc = "Kaizoku Plasma eXperimental branded plasma rifle built on reworked volkite induction tech, optimized to fire focused purple beams with excellent accuracy. Designed for adaptable field use and compatible with an extended range of attachments."
	icon = 'ntf_modular/icons/obj/items/guns/energy64.dmi'
	icon_state = "spectra"
	worn_icon_state = "spectra"
	ammo_level_icon = ""
	inhand_x_dimension = 64
	inhand_y_dimension = 32
	fire_sound = 'sound/weapons/guns/fire/volkite_1.ogg'
	dry_fire_sound = 'sound/weapons/guns/misc/error.ogg'
	unload_sound = 'sound/weapons/guns/interact/volkite_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/volkite_reload.ogg'
	worn_icon_list = list(
		slot_l_hand_str = 'ntf_modular/icons/mob/inhands/guns/energy_left_64.dmi',
		slot_r_hand_str = 'ntf_modular/icons/mob/inhands/guns/energy_right_64.dmi',
	)
	fire_sound = 'sound/weapons/guns/fire/volkite_3.ogg'
	max_shots = 40
	ammo_datum_type = /datum/ammo/energy/volkite/kz_plasma
	rounds_per_shot = 36
	default_ammo_type = /obj/item/cell/lasgun/volkite
	gun_firemode = GUN_FIREMODE_AUTOMATIC
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)
	gun_features_flags = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_ENERGY|GUN_AMMO_COUNT_BY_SHOTS_REMAINING|GUN_SHOWS_LOADED
	allowed_ammo_types = list(
		/obj/item/cell/lasgun/volkite,
	)
	attachable_allowed = list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/angledgrip,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/gyro,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/flashlight/under,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/suppressor,
		/obj/item/attachable/bayonet/converted,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonet/som,
		/obj/item/attachable/scope,
		/obj/item/attachable/scope/marine,
		/obj/item/attachable/scope/mini,
		/obj/item/weapon/gun/pistol/plasma_pistol,
		/obj/item/weapon/gun/shotgun/combat/masterkey,
		/obj/item/weapon/gun/flamer/mini_flamer,
		/obj/item/weapon/gun/grenade_launcher/underslung,
		/obj/item/attachable/motiondetector,
		/obj/item/attachable/buildasentry,
		/obj/item/weapon/gun/rifle/pepperball/pepperball_mini,
		/obj/item/weapon/gun/flamer/hydro_cannon,
		/obj/item/attachable/shoulder_mount,
	)
	attachable_offset = list("muzzle_x" = 48, "muzzle_y" = 21,"rail_x" = 14, "rail_y" = 24, "under_x" = 42, "under_y" = 13, "stock_x" = 22, "stock_y" = 12)
	accuracy_mult = 1
	accuracy_mult_unwielded = 0.4
	aim_slowdown = 0.6
	damage_falloff_mult = 0.5
	scatter = 2
	scatter_unwielded = 25
	recoil_unwielded = 5
	wield_delay = 0.9 SECONDS
	fire_delay = 0.25 SECONDS


/datum/ammo/energy/volkite/kz_plasma
	name = "superheated plasma energy bolt"
	icon_state = "disablershot"
	hud_state = "laser_heat"
	hud_state_empty = "battery_empty_flash"
	ammo_behavior_flags = AMMO_ENERGY|AMMO_SOUND_PITCH
	bullet_color = COLOR_VIOLET
	armor_type = ENERGY
	max_range = 26
	accurate_range = 15
	shell_speed = 3.5
	accuracy_variation = 3
	damage = 30 //No fire burst so maybe fine.
	sundering = 2.5
	deflagrate_multiplier = 0
