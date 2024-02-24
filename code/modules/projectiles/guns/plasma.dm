/obj/item/weapon/gun/energy/lasgun/lasrifle/plasma
	name = "generic plasma weapon"
	icon = 'icons/obj/items/guns/plasma64.dmi'
	item_icons = list(
		slot_l_hand_str = 'icons/mob/inhands/guns/plasma_left_1.dmi',
		slot_r_hand_str = 'icons/mob/inhands/guns/plasma_right_1.dmi',
	)
	default_ammo_type = /obj/item/cell/lasgun/plasma_powerpack
	allowed_ammo_types = list(/obj/item/cell/lasgun/plasma_powerpack)
	heat_per_fire = 5
	muzzle_flash_color = COLOR_DISABLER_BLUE
	muzzleflash_iconstate = "muzzle_flash_pulse"
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_AMMO_COUNT_BY_SHOTS_REMAINING
	accuracy_mult = 1
	accuracy_mult_unwielded = 0.5
	scatter = 4
	scatter_unwielded = 35
	movement_acc_penalty_mult = 5
	damage_falloff_mult = 0.25

/obj/item/weapon/gun/energy/lasgun/lasrifle/plasma/rifle
	name = "\improper PL-38 plasma rifle"
	desc = "The PL-38 Plasma Rifle is an experimental addition to the TerraGov Marine Corps arsenal, rumored to be the child of some back door contract deals, it is a versatile weapon if you mind the rather cheap cooling systems. It has a normal beam mode similar to a rifle, a hipower mode that easily pierces through soft targets, and a blast mode that will easily melt through the armor of anything hit by it."
	icon_state = "plasma_rifle"
	item_state = "plasma_rifle"
	flags_equip_slot = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	fire_sound = 'sound/weapons/guns/fire/plasma_fire_med.ogg'
	unload_sound = 'sound/weapons/guns/interact/plasma_unload_3.ogg'
	reload_sound = 'sound/weapons/guns/interact/plasma_reload_2.ogg'

	wield_delay = 0.6 SECONDS
	aim_slowdown = 0.5

	accuracy_mult = 1.1
	scatter = -2

	fire_delay = 0.2 SECONDS
	heat_per_fire = 3.3
	cool_amount = 2.5
	rounds_per_shot = 10
	gun_firemode = GUN_FIREMODE_AUTOMATIC
	ammo_datum_type = /datum/ammo/energy/plasma/rifle_standard
	force = 20
	mode_list = list(
		"Standard" = /datum/lasrifle/base/plasma_rifle_mode/rifle_standard,
		"Piercing" = /datum/lasrifle/base/plasma_rifle_mode/rifle_marksman,
		"Blast" = /datum/lasrifle/base/plasma_rifle_mode/rifle_blast,
	)
	attachable_offset = list("muzzle_x" = 50, "muzzle_y" = 16,"rail_x" = 25, "rail_y" = 25, "under_x" = 37, "under_y" = 10, "stock_x" = 0, "stock_y" = 13)
	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/reddot,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/flashlight/under,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/angledgrip,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/scope/marine,
		/obj/item/attachable/scope/mini,
		/obj/item/weapon/gun/shotgun/combat/masterkey,
		/obj/item/weapon/gun/flamer/mini_flamer,
		/obj/item/weapon/gun/grenade_launcher/underslung,
		/obj/item/attachable/motiondetector,
		/obj/item/weapon/gun/rifle/pepperball/pepperball_mini,
	)

/datum/lasrifle/base/plasma_rifle_mode/rifle_standard
	fire_sound = 'sound/weapons/guns/fire/plasma_fire_med.ogg'
	ammo_datum_type = /datum/ammo/energy/plasma/rifle_standard
	icon_state = "plasma_rifle"
	fire_mode = GUN_FIREMODE_AUTOMATIC
	fire_delay = 0.2 SECONDS
	heat_per_fire = 3.3
	rounds_per_shot = 2.5
	radial_icon_state = "plasma_weak"
	message_to_user = "You set the plasma rifle's charge mode to standard fire."

/datum/lasrifle/base/plasma_rifle_mode/rifle_marksman
	fire_sound = 'sound/weapons/guns/fire/plasma_fire_heavy.ogg'
	ammo_datum_type = /datum/ammo/energy/plasma/rifle_marksman
	icon_state = "plasma_rifle"
	fire_mode = GUN_FIREMODE_AUTOMATIC
	fire_delay = 0.25 SECONDS
	heat_per_fire = 10
	rounds_per_shot = 12.5
	radial_icon_state = "plasma_strong"
	message_to_user = "You set the plasma rifle's charge mode to piercing fire."

/datum/lasrifle/base/plasma_rifle_mode/rifle_blast
	fire_sound = 'sound/weapons/guns/fire/plasma_fire_blast.ogg'
	ammo_datum_type = /datum/ammo/energy/plasma/rifle_blast
	icon_state = "plasma_rifle"
	fire_mode = GUN_FIREMODE_SEMIAUTO
	fire_delay = 2 SECONDS
	heat_per_fire = 33
	rounds_per_shot = 50
	radial_icon_state = "plasma_multi"
	message_to_user = "You set the plasma rifle's charge mode to blast fire."

/obj/item/weapon/gun/energy/lasgun/lasrifle/plasma/cannon
	name = "\improper PL-96 plasma cannon"
	desc = "The PL-96 Plasma Cannon is an experimental addition to the TerraGov Marine Corps arsenal, rumored to be the child of some back door contract deals, is an absolutely incredibly devastating weapon to behold... if you mind the incredibly poor cooling mechanisms and unwieldiness of the whole package. It has a normal beam mode similar to a machinegun, a fire glob mode that leaves devastating flames in the aftermath, and a Charge mode nicknamed the 'Femur breaker' due to its incredible armor shattering potiential upon hitting a target."
	icon_state = "plasma_cannon"
	item_state = "plasma_cannon"
	flags_equip_slot = ITEM_SLOT_BACK
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_AMMO_COUNT_BY_SHOTS_REMAINING|GUN_WIELDED_FIRING_ONLY
	w_class = WEIGHT_CLASS_BULKY
	gun_skill_category = SKILL_HEAVY_WEAPONS

	aim_slowdown = 1.2
	wield_delay = 1.7 SECONDS
	movement_acc_penalty_mult = 6

	accuracy_mult = 1
	accuracy_mult_unwielded = 0.5
	scatter = 2

	fire_sound = 'sound/weapons/guns/fire/plasma_fire_heavy.ogg'
	unload_sound = 'sound/weapons/guns/interact/plasma_unload_2.ogg'
	reload_sound = 'sound/weapons/guns/interact/plasma_reload_1.ogg'
	force = 35
	ammo_datum_type = /datum/ammo/energy/plasma/cannon_standard
	gun_firemode = GUN_FIREMODE_AUTOMATIC
	fire_delay = 0.15 SECONDS
	heat_per_fire = 2
	cool_amount = 1.5
	rounds_per_shot = 5
	mode_list = list(
		"Standard" = /datum/lasrifle/base/plasma_rifle_mode/cannon_standard,
		"Charge" = /datum/lasrifle/base/plasma_rifle_mode/cannon_heavy,
		"Glob" = /datum/lasrifle/base/plasma_rifle_mode/cannon_glob,
	)
	attachable_offset = list("muzzle_x" = 49, "muzzle_y" = 16,"rail_x" = 25, "rail_y" = 26, "under_x" = 42, "under_y" = 11, "stock_x" = 0, "stock_y" = 13)
	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/reddot,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/motiondetector,
	)

/datum/lasrifle/base/plasma_rifle_mode/cannon_standard
	fire_sound = 'sound/weapons/guns/fire/plasma_fire_heavy.ogg'
	ammo_datum_type = /datum/ammo/energy/plasma/cannon_standard
	fire_mode = GUN_FIREMODE_AUTOMATIC
	fire_delay = 0.15 SECONDS
	heat_per_fire = 2
	rounds_per_shot = 2
	icon_state = "plasma_cannon"
	radial_icon_state = "plasma_cannon"
	message_to_user = "You set the plasma cannon's charge mode to standard fire."

/datum/lasrifle/base/plasma_rifle_mode/cannon_heavy
	fire_sound = 'sound/weapons/guns/fire/plasma_fire_blast.ogg'
	ammo_datum_type = /datum/ammo/energy/plasma/cannon_heavy
	fire_mode = GUN_FIREMODE_AUTOMATIC
	fire_delay = 1 SECONDS
	heat_per_fire = 50
	rounds_per_shot = 100
	windup_delay = 1 SECONDS
	icon_state = "plasma_cannon"
	radial_icon_state = "plasma_fire"
	message_to_user = "You set the plasma cannon's charge mode to heavy."

/datum/lasrifle/base/plasma_rifle_mode/cannon_glob
	fire_sound = 'sound/weapons/guns/fire/flamethrower3.ogg'
	ammo_datum_type = /datum/ammo/energy/plasma/cannon_glob
	fire_mode = GUN_FIREMODE_AUTOMATIC
	fire_delay = 2 SECONDS
	heat_per_fire = 50
	rounds_per_shot = 100
	icon_state = "plasma_cannon"
	radial_icon_state = "plasma_strong"
	message_to_user = "You set the plasma cannon's charge mode to fire glob mode."
