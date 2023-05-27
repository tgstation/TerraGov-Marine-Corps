/obj/item/weapon/gun/energy/lasgun/lasrifle/plasma
	name = "generic plasma weapon"
	icon = 'icons/Marine/marine-plasmaguns.dmi'
	default_ammo_type = /obj/item/cell/lasgun/plasma
	allowed_ammo_types = list(/obj/item/cell/lasgun/plasma)
	heat_per_fire = 5
	muzzle_flash_color = COLOR_DISABLER_BLUE
	muzzleflash_iconstate = "muzzle_flash_pulse"

/obj/item/weapon/gun/energy/lasgun/lasrifle/plasma/minigun
	name = "\improper PL-73 plasma thrower"
	desc = "The PL-73 Plasma Thrower is a high-quality weapon designed to deliver powerful performance in even the most challenging combat situations. With its sleek, durable design and intuitive controls, this plasma gun is the ultimate choice for those who demand the very best.\n\nFeaturing three distinct fire modes - rapid, incendiary, and glob - the PL-73 is capable of unleashing a devastating array of plasma-based attacks. Whether you're looking to overwhelm your enemies with a barrage of rapid-fire plasma bolts, ignite the surrounding area with intense heat and flames, or deliver a massive plasma ball that explodes on impact, the PL-73 has you covered.\n\nConstructed from only the highest quality materials, this weapon is built to last. Its ergonomic design and intuitive controls make it easy to handle, even in the heat of battle. So if you're looking for a powerful and reliable plasma gun that can help you take on even the toughest opponents, look no further than the PL-73 Plasma Thrower."
	icon_state = "plasma_minigun"
	item_state = "plasma_minigun"
	flags_equip_slot = ITEM_SLOT_BACK
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
	force = 30
	gun_firemode = GUN_FIREMODE_AUTOMATIC
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER
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

/obj/item/weapon/gun/energy/lasgun/lasrifle/plasma/sniper
	name = "\improper PL-02 plasma sniper rifle"
	desc = "Introducing the PL-02 Plasma Sniper Rifle, the ultimate long-range weapon for those who demand nothing but the best. With its advanced features and sleek design, the PL-02 is the perfect addition to any marksman's arsenal. This powerful plasma rifle is designed for precision and accuracy, allowing you to take out your enemies from a distance with ease. Its advanced targeting system and high-powered scope make it easy to acquire and track targets, while its powerful plasma bolts deliver devastating damage. Constructed from high-quality materials, the PL-02 is built to last and can withstand even the toughest of environments. If you're looking for a reliable and powerful sniper rifle that can take out targets from a distance, look no further than the PL-02 Plasma Sniper Rifle."
	icon_state = "plasma_sniper"
	item_state = "plasma_sniper"
	flags_equip_slot = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	fire_sound = 'sound/weapons/guns/fire/plasma_fire_blast.ogg'
	unload_sound = 'sound/weapons/guns/interact/plasma_unload_3.ogg'
	reload_sound = 'sound/weapons/guns/interact/plasma_reload_3.ogg'
	ammo_datum_type = /datum/ammo/energy/plasma/sniper
	wield_delay = 0.8 SECONDS
	aim_slowdown = 0.9
	heat_per_fire = 10
	rounds_per_shot = 67
	fire_delay = 0.8 SECONDS
	aim_fire_delay = 0.2 SECONDS
	aim_speed_modifier = 0.4
	force = 25
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER
	attachable_offset = list("muzzle_x" = 56, "muzzle_y" = 16,"rail_x" = 5, "rail_y" = 19, "under_x" = 45, "under_y" = 14, "stock_x" = 0, "stock_y" = 13)
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
	fire_delay = 0.15 SECONDS
	gun_firemode = GUN_FIREMODE_AUTOMATIC
	ammo_datum_type = /datum/ammo/energy/plasma/rifle_standard
	force = 20
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER
	mode_list = list(
		"Standard" = /datum/lasrifle/base/plasma_rifle_mode/rifle_standard,
		"Marksman" = /datum/lasrifle/base/plasma_rifle_mode/rifle_marksman,
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
	heat_per_fire = 1
	rounds_per_shot = 20
	radial_icon_state = "plasma_weak"

/datum/lasrifle/base/plasma_rifle_mode/rifle_marksman
	fire_sound = 'sound/weapons/guns/fire/plasma_fire_heavy.ogg'
	ammo_datum_type = /datum/ammo/energy/plasma/rifle_marksman
	icon_state = "plasma_rifle"
	fire_mode = GUN_FIREMODE_AUTOMATIC
	fire_delay = 0.45 SECONDS
	heat_per_fire = 2
	rounds_per_shot = 40
	radial_icon_state = "plasma_strong"

/obj/item/weapon/gun/energy/lasgun/lasrifle/plasma/carbine
	name = "\improper PL-51 plasma carbine"
	desc = "Introducing the PL-51 Plasma Carbine, a compact and lightweight weapon designed for close to mid-range combat. With its sleek design and advanced features, the PL-51 is the perfect addition to any soldier's arsenal. This powerful plasma carbine is built for speed and agility, allowing you to quickly take out your enemies in close quarters combat. Its advanced targeting system and high-powered scope make it easy to acquire and track targets, while its standard, shotgun, and tri-fire firemodes give you the flexibility to adapt to any combat situation. Constructed from high-quality materials, the PL-51 is built to withstand even the toughest of environments. Whether you're engaging in urban combat or fighting in tight spaces, the PL-51 Plasma Carbine is the weapon of choice for any soldier looking for a reliable and versatile plasma carbine."
	icon_state = "plasma_carbine"
	item_state = "plasma_carbine"
	flags_equip_slot = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	fire_sound = 'sound/weapons/guns/fire/plasma_fire_fast.ogg'
	unload_sound = 'sound/weapons/guns/interact/plasma_unload_3.ogg'
	reload_sound = 'sound/weapons/guns/interact/plasma_reload_3.ogg'
	fire_sound = 'sound/weapons/guns/fire/plasma_fire_fast.ogg'
	ammo_datum_type = /datum/ammo/energy/plasma/carbine_standard/four
	icon_state = "plasma_carbine"
	gun_firemode = GUN_FIREMODE_AUTOBURST
	fire_delay = 0.3 SECONDS
	burst_amount = 3
	heat_per_fire = 1
	rounds_per_shot = 15
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER
	mode_list = list(
		"Standard" = /datum/lasrifle/base/plasma_rifle_mode/carbine_standard,
		"Shotgun" = /datum/lasrifle/base/plasma_rifle_mode/carbine_shotgun,
		"Tri-fire" = /datum/lasrifle/base/plasma_rifle_mode/carbine_trifire,
	)
	attachable_offset = list("muzzle_x" = 43, "muzzle_y" = 17,"rail_x" = 25, "rail_y" = 25, "under_x" = 33, "under_y" = 11, "stock_x" = 0, "stock_y" = 13)
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

/datum/lasrifle/base/plasma_rifle_mode/carbine_standard
	fire_sound = 'sound/weapons/guns/fire/plasma_fire_fast.ogg'
	ammo_datum_type = /datum/ammo/energy/plasma/carbine_standard/four
	icon_state = "plasma_carbine"
	fire_mode = GUN_FIREMODE_AUTOBURST
	fire_delay = 0.3 SECONDS
	burst_amount = 3
	heat_per_fire = 1
	rounds_per_shot = 15
	radial_icon_state = "plasma_bouncy"

/datum/lasrifle/base/plasma_rifle_mode/carbine_shotgun
	fire_sound = 'sound/weapons/guns/fire/plasma_fire_heavy.ogg'
	ammo_datum_type = /datum/ammo/energy/plasma/carbine_shotgun
	icon_state = "plasma_carbine"
	fire_mode = GUN_FIREMODE_SEMIAUTO
	fire_delay = 0.45 SECONDS
	heat_per_fire = 10
	rounds_per_shot = 66
	radial_icon_state = "plasma_strong"

/datum/lasrifle/base/plasma_rifle_mode/carbine_trifire
	fire_sound = 'sound/weapons/guns/fire/plasma_fire_fast.ogg'
	ammo_datum_type = /datum/ammo/energy/plasma/carbine_trifire
	icon_state = "plasma_carbine"
	fire_mode = GUN_FIREMODE_AUTOMATIC
	fire_delay = 0.15 SECONDS
	heat_per_fire = 3
	rounds_per_shot = 25
	radial_icon_state = "plasma_multi"

/obj/item/weapon/gun/energy/lasgun/lasrifle/plasma/pistol
	name = "\improper PL-85 plasma pistol"
	desc = "Introducing the PL-85 Plasma Pistol, a sleek and reliable weapon for any combat situation. With its compact design and advanced features, the PL-85 is the perfect sidearm for any soldier. This powerful plasma pistol is built for speed and accuracy, allowing you to take out your enemies with ease. Its advanced targeting system and high-powered scope make it easy to acquire and track targets, while its standard and automatic fire firemodes give you the flexibility to adapt to any combat situation. Constructed from high-quality materials, the PL-85 is built to withstand even the toughest of environments. Whether you're engaged in close quarters combat or need a reliable sidearm for backup, the PL-85 Plasma Pistol is the weapon of choice for any soldier looking for a dependable and powerful plasma pistol."
	icon_state = "plasma_pistol"
	item_state = "plasma_pistol"
	fire_sound = 'sound/weapons/guns/fire/plasma_fire_med.ogg'
	unload_sound = 'sound/weapons/guns/interact/plasma_unload_1.ogg'
	reload_sound = 'sound/weapons/guns/interact/plasma_reload_1.ogg'
	ammo_datum_type = /datum/ammo/energy/plasma/pistol_standard
	force = 15
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER
	mode_list = list(
		"Standard" = /datum/lasrifle/base/plasma_rifle_mode/pistol_standard,
		"Automatic" = /datum/lasrifle/base/plasma_rifle_mode/pistol_automatic,
		"Tri-fire" = /datum/lasrifle/base/plasma_rifle_mode/pistol_trifire,
	)
	attachable_offset = list("muzzle_x" = 30, "muzzle_y" = 16,"rail_x" = 13, "rail_y" = 22, "under_x" = 18, "under_y" = 12, "stock_x" = 0, "stock_y" = 13)
	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/reddot,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/magnetic_harness,
		/obj/item/weapon/gun/flamer/mini_flamer,
		/obj/item/attachable/motiondetector,
		/obj/item/weapon/gun/rifle/pepperball/pepperball_mini,
		/obj/item/attachable/lace,
	)

/datum/lasrifle/base/plasma_rifle_mode/pistol_standard
	fire_sound = 'sound/weapons/guns/fire/plasma_fire_med.ogg'
	ammo_datum_type = /datum/ammo/energy/plasma/pistol_standard
	icon_state = "plasma_pistol"
	fire_mode = GUN_FIREMODE_SEMIAUTO
	fire_delay = 0.15 SECONDS
	heat_per_fire = 3
	rounds_per_shot = 25
	radial_icon_state = "plasma_weak"

/datum/lasrifle/base/plasma_rifle_mode/pistol_automatic
	fire_sound = 'sound/weapons/guns/fire/plasma_fire_fast.ogg'
	ammo_datum_type = /datum/ammo/energy/plasma/pistol_automatic
	icon_state = "plasma_pistol"
	fire_mode = GUN_FIREMODE_AUTOMATIC
	fire_delay = 0.15 SECONDS
	heat_per_fire = 3
	rounds_per_shot = 25
	radial_icon_state = "plasma_strong"

/datum/lasrifle/base/plasma_rifle_mode/pistol_trifire
	fire_sound = 'sound/weapons/guns/fire/plasma_fire_med.ogg'
	ammo_datum_type = /datum/ammo/energy/plasma/pistol_trifire/four
	icon_state = "plasma_pistol"
	fire_mode = GUN_FIREMODE_AUTOMATIC
	fire_delay = 0.15 SECONDS
	heat_per_fire = 3
	rounds_per_shot = 25
	radial_icon_state = "plasma_multi"

/obj/item/weapon/gun/energy/lasgun/lasrifle/plasma/cannon
	name = "\improper PL-96 plasma cannon"
	desc = "Introducing the PL-96 Plasma Cannon, a devastating heavy weapon designed for maximum destruction. With its imposing size and advanced features, the PL-96 is the ultimate weapon for obliterating your enemies. This powerful plasma cannon is built for firepower and versatility, allowing you to take out multiple enemies at once with its swarm firemode, or engulf your foes in flames with its devastating flamer firemode. Its advanced targeting system makes it easy to acquire and track targets, while its standard firemode gives you the precision you need for long-range combat. Constructed from high-quality materials, the PL-96 is built to withstand even the most intense combat environments. Whether you're engaging in large-scale battles or need to take out heavily armored targets, the PL-96 Plasma Cannon is the weapon of choice for any soldier looking for a powerful and versatile plasma cannon."
	icon_state = "plasma_cannon"
	item_state = "plasma_cannon"
	flags_equip_slot = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	fire_sound = 'sound/weapons/guns/fire/plasma_fire_heavy.ogg'
	unload_sound = 'sound/weapons/guns/interact/plasma_unload_2.ogg'
	reload_sound = 'sound/weapons/guns/interact/plasma_reload_1.ogg'
	force = 35
	ammo_datum_type = /datum/ammo/energy/plasma/cannon_standard
	gun_firemode = GUN_FIREMODE_AUTOMATIC
	fire_delay = 1.2 SECONDS
	heat_per_fire = 25
	rounds_per_shot = 100
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER
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

/datum/lasrifle/base/plasma_rifle_mode/cannon_standard
	fire_sound = 'sound/weapons/guns/fire/plasma_fire_heavy.ogg'
	ammo_datum_type = /datum/ammo/energy/plasma/cannon_standard
	fire_mode = GUN_FIREMODE_AUTOMATIC
	fire_delay = 1.2 SECONDS
	heat_per_fire = 25
	rounds_per_shot = 100
	icon_state = "plasma_cannon"
	radial_icon_state = "plasma_cannon"

/datum/lasrifle/base/plasma_rifle_mode/cannon_heavy
	fire_sound = 'sound/weapons/guns/fire/plasma_fire_blast.ogg'
	ammo_datum_type = /datum/ammo/energy/plasma/cannon_heavy
	fire_mode = GUN_FIREMODE_AUTOMATIC
	fire_delay = 2
	heat_per_fire = 35
	rounds_per_shot = 150
	icon_state = "plasma_cannon"
	radial_icon_state = "laser_swarm"

/datum/lasrifle/base/plasma_rifle_mode/cannon_flamer
	fire_sound = 'sound/weapons/guns/fire/flamethrower3.ogg'
	ammo_datum_type = /datum/ammo/energy/plasma/cannon_flamer
	fire_mode = GUN_FIREMODE_AUTOMATIC
	fire_delay = 1.5 SECONDS
	heat_per_fire = 15
	rounds_per_shot = 75
	icon_state = "plasma_cannon"
	radial_icon_state = "plasma_fire"
