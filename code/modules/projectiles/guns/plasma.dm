/obj/item/weapon/gun/energy/lasgun/lasrifle/plasma
	name = "generic plasma weapon"
	icon = 'icons/Marine/marine-plasmaguns.dmi'
	default_ammo_type = /obj/item/cell/lasgun/plasma
	allowed_ammo_types = list(/obj/item/cell/lasgun/plasma)
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

/obj/item/weapon/gun/energy/lasgun/lasrifle/plasma/minigun
	name = "\improper PL-73 plasma thrower"
	desc = "The PL-73 Plasma Thrower is a high-quality weapon designed to deliver powerful performance in even the most challenging combat situations. With its sleek, durable design and intuitive controls, this plasma gun is the ultimate choice for those who demand the very best.\n\nFeaturing three distinct fire modes - rapid, incendiary, and glob - the PL-73 is capable of unleashing a devastating array of plasma-based attacks. Whether you're looking to overwhelm your enemies with a barrage of rapid-fire plasma bolts, ignite the surrounding area with intense heat and flames, or deliver a massive plasma ball that explodes on impact, the PL-73 has you covered.\n\nConstructed from only the highest quality materials, this weapon is built to last. Its ergonomic design and intuitive controls make it easy to handle, even in the heat of battle. So if you're looking for a powerful and reliable plasma gun that can help you take on even the toughest opponents, look no further than the PL-73 Plasma Thrower."
	icon_state = "plasma_minigun"
	item_state = "plasma_minigun"
	flags_equip_slot = ITEM_SLOT_BACK
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_AMMO_COUNT_BY_SHOTS_REMAINING|GUN_WIELDED_FIRING_ONLY
	w_class = WEIGHT_CLASS_BULKY
	fire_sound = 'sound/weapons/guns/fire/plasma_fire_med.ogg'
	unload_sound = 'sound/weapons/guns/interact/plasma_unload_2.ogg'
	reload_sound = 'sound/weapons/guns/interact/plasma_reload_3.ogg'
	ammo_datum_type = /datum/ammo/energy/plasma/minigun_rapid
	heat_per_fire = 0.5
	fire_delay = 0.15 SECONDS
	rounds_per_shot = 7

	wield_delay = 1.1 SECONDS
	aim_slowdown = 0.7
	movement_acc_penalty_mult = 6

	scatter = 6

	force = 30
	gun_firemode = GUN_FIREMODE_AUTOMATIC
	mode_list = list(
		"Rapid" = /datum/lasrifle/base/plasma_rifle_mode/minigun_rapid,
		"Incendiary" = /datum/lasrifle/base/plasma_rifle_mode/minigun_incendiary,
		"Glob" = /datum/lasrifle/base/plasma_rifle_mode/minigun_glob
	)
	attachable_offset = list("muzzle_x" = 49, "muzzle_y" = 16,"rail_x" = 21, "rail_y" = 25, "under_x" = 41, "under_y" = 12, "stock_x" = 0, "stock_y" = 13)
	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/reddot,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/flashlight,
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

/datum/lasrifle/base/plasma_rifle_mode/minigun_rapid
	fire_sound = 'sound/weapons/guns/fire/plasma_fire_med.ogg'
	icon_state = "plasma_minigun"
	ammo_datum_type = /datum/ammo/energy/plasma/minigun_rapid
	heat_per_fire = 0.5
	fire_delay = 0.15 SECONDS
	fire_mode = GUN_FIREMODE_AUTOMATIC
	rounds_per_shot = 7
	radial_icon_state = "plasma_weak"

/datum/lasrifle/base/plasma_rifle_mode/minigun_incendiary
	fire_sound = 'sound/weapons/guns/fire/plasma_fire_heavy.ogg'
	icon_state = "plasma_minigun"
	ammo_datum_type = /datum/ammo/energy/plasma/minigun_incendiary
	heat_per_fire = 5
	fire_delay = 0.35 SECONDS
	fire_mode = GUN_FIREMODE_AUTOMATIC
	rounds_per_shot = 29
	radial_icon_state = "plasma_fire"

/datum/lasrifle/base/plasma_rifle_mode/minigun_glob
	fire_sound = 'sound/weapons/guns/fire/tank_flamethrower.ogg'
	icon_state = "plasma_minigun"
	ammo_datum_type = /datum/ammo/energy/plasma/minigun_glob
	heat_per_fire = 25
	fire_delay = 0.15 SECONDS
	fire_mode = GUN_FIREMODE_SEMIAUTO
	rounds_per_shot = 100
	radial_icon_state = "plasma_cannon"
/obj/item/weapon/gun/energy/lasgun/lasrifle/plasma/rifle
	name = "\improper PL-38 plasma rifle"
	desc = "Introducing the PL-38 Plasma Rifle, a versatile weapon for any combat situation. With its sleek design and advanced features, the PL-38 is the perfect addition to any soldier's arsenal. This powerful plasma rifle is built for speed and accuracy, allowing you to take out your enemies with ease. Its advanced targeting system and high-powered scope make it easy to acquire and track targets, while its marksman and standard firemodes give you the flexibility to adapt to any situation. Constructed from high-quality materials, the PL-38 is built to withstand even the toughest of combat environments. Whether you're on the front lines of battle or engaging in covert operations, the PL-38 Plasma Rifle is the weapon of choice for any soldier looking for a reliable and powerful plasma rifle."
	icon_state = "plasma_rifle"
	item_state = "plasma_rifle"
	flags_equip_slot = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	fire_sound = 'sound/weapons/guns/fire/plasma_fire_med.ogg'
	unload_sound = 'sound/weapons/guns/interact/plasma_unload_3.ogg'
	reload_sound = 'sound/weapons/guns/interact/plasma_reload_2.ogg'

	wield_delay = 0.4 SECONDS
	aim_slowdown = 0.5

	accuracy_mult = 1.1
	scatter = -2

	fire_delay = 0.15 SECONDS
	heat_per_fire = 3
	rounds_per_shot = 10
	gun_firemode = GUN_FIREMODE_AUTOMATIC
	ammo_datum_type = /datum/ammo/energy/plasma/rifle_standard
	force = 20
	mode_list = list(
		"Standard" = /datum/lasrifle/base/plasma_rifle_mode/rifle_standard,
		"Piercing" = /datum/lasrifle/base/plasma_rifle_mode/rifle_marksman,
		"Overcharge" = /datum/lasrifle/base/plasma_rifle_mode/rifle_overcharge,
	)
	attachable_offset = list("muzzle_x" = 50, "muzzle_y" = 16,"rail_x" = 25, "rail_y" = 25, "under_x" = 37, "under_y" = 10, "stock_x" = 0, "stock_y" = 13)
	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/reddot,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/flashlight,
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
	fire_delay = 0.15 SECONDS
	heat_per_fire = 3
	rounds_per_shot = 10
	radial_icon_state = "plasma_weak"

/datum/lasrifle/base/plasma_rifle_mode/rifle_marksman
	fire_sound = 'sound/weapons/guns/fire/plasma_fire_heavy.ogg'
	ammo_datum_type = /datum/ammo/energy/plasma/rifle_marksman
	icon_state = "plasma_rifle"
	fire_mode = GUN_FIREMODE_AUTOMATIC
	fire_delay = 0.45 SECONDS
	heat_per_fire = 6
	rounds_per_shot = 20
	radial_icon_state = "plasma_strong"

/datum/lasrifle/base/plasma_rifle_mode/rifle_overcharge
	fire_sound = 'sound/weapons/guns/fire/plasma_fire_blast.ogg'
	ammo_datum_type = /datum/ammo/energy/plasma/rifle_overcharge
	icon_state = "plasma_rifle"
	fire_mode = GUN_FIREMODE_SEMIAUTO
	fire_delay = 0.50 SECONDS
	heat_per_fire = 100
	rounds_per_shot = 50
	radial_icon_state = "plasma_cannon"
/obj/item/weapon/gun/energy/lasgun/lasrifle/plasma/cannon
	name = "\improper PL-96 plasma cannon"
	desc = "Introducing the PL-96 Plasma Cannon, a devastating heavy weapon designed for maximum destruction. With its imposing size and advanced features, the PL-96 is the ultimate weapon for obliterating your enemies. This powerful plasma cannon is built for firepower and versatility, allowing you to take out multiple enemies at once with its swarm firemode, or engulf your foes in flames with its devastating flamer firemode. Its advanced targeting system makes it easy to acquire and track targets, while its standard firemode gives you the precision you need for long-range combat. Constructed from high-quality materials, the PL-96 is built to withstand even the most intense combat environments. Whether you're engaging in large-scale battles or need to take out heavily armored targets, the PL-96 Plasma Cannon is the weapon of choice for any soldier looking for a powerful and versatile plasma cannon."
	icon_state = "plasma_cannon"
	item_state = "plasma_cannon"
	flags_equip_slot = ITEM_SLOT_BACK
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_AMMO_COUNT_BY_SHOTS_REMAINING|GUN_WIELDED_FIRING_ONLY
	w_class = WEIGHT_CLASS_BULKY

	wield_delay = 1.5 SECONDS
	aim_slowdown = 1.1
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
	fire_delay = 1.2 SECONDS
	heat_per_fire = 33
	rounds_per_shot = 50
	mode_list = list(
		"Standard" = /datum/lasrifle/base/plasma_rifle_mode/cannon_standard,
		"Heavy" = /datum/lasrifle/base/plasma_rifle_mode/cannon_heavy,
		"Flamer" = /datum/lasrifle/base/plasma_rifle_mode/cannon_flamer,
	)
	attachable_offset = list("muzzle_x" = 49, "muzzle_y" = 16,"rail_x" = 25, "rail_y" = 26, "under_x" = 42, "under_y" = 11, "stock_x" = 0, "stock_y" = 13)
	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/reddot,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/scope/marine,
		/obj/item/attachable/scope/mini,
		/obj/item/weapon/gun/shotgun/combat/masterkey,
		/obj/item/weapon/gun/flamer/mini_flamer,
		/obj/item/weapon/gun/grenade_launcher/underslung,
		/obj/item/attachable/motiondetector,
		/obj/item/weapon/gun/rifle/pepperball/pepperball_mini,
	)

/datum/lasrifle/base/plasma_rifle_mode/cannon_standard
	fire_sound = 'sound/weapons/guns/fire/plasma_fire_heavy.ogg'
	ammo_datum_type = /datum/ammo/energy/plasma/cannon_standard
	fire_mode = GUN_FIREMODE_AUTOMATIC
	fire_delay = 1.2 SECONDS
	heat_per_fire = 33
	rounds_per_shot = 50
	icon_state = "plasma_cannon"
	radial_icon_state = "plasma_cannon"

/datum/lasrifle/base/plasma_rifle_mode/cannon_heavy
	fire_sound = 'sound/weapons/guns/fire/plasma_fire_blast.ogg'
	ammo_datum_type = /datum/ammo/energy/plasma/cannon_heavy
	fire_mode = GUN_FIREMODE_AUTOMATIC
	fire_delay = 2 SECONDS
	heat_per_fire = 45
	rounds_per_shot = 75
	windup_delay = 0.5 SECONDS
	icon_state = "plasma_cannon"
	radial_icon_state = "laser_swarm"

/datum/lasrifle/base/plasma_rifle_mode/cannon_flamer
	fire_sound = 'sound/weapons/guns/fire/flamethrower3.ogg'
	ammo_datum_type = /datum/ammo/energy/plasma/cannon_flamer
	fire_mode = GUN_FIREMODE_AUTOMATIC
	fire_delay = 0.25 SECONDS
	heat_per_fire = 25
	rounds_per_shot = 20
	icon_state = "plasma_cannon"
	radial_icon_state = "plasma_fire"
