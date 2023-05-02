/obj/item/weapon/gun/energy/lasgun/lasrifle/plasma
	name = "generic plasma weapon"
	icon = 'icons/Marine/marine-plasmaguns.dmi'
	default_ammo_type = /obj/item/cell/lasgun/plasma
	allowed_ammo_types = list(/obj/item/cell/lasgun/plasma)
	heat_per_fire = 5

/obj/item/weapon/gun/energy/lasgun/lasrifle/plasma/minigun
	name = "\improper PL-73 plasma thrower"
	icon_state = "plasma_minigun"
	item_state = "plasma_minigun"
	flags_equip_slot = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	ammo_datum_type = /datum/ammo/energy/plasma/minigun_rapid
	heat_per_fire = 0.5
	fire_delay = 0.15
	rounds_per_shot = 7
	wield_delay = 1.1
	aim_slowdown = 0.7
	gun_firemode = GUN_FIREMODE_AUTOMATIC
	mode_list = list(
		"Rapid" = /datum/lasrifle/base/plasma_rifle_mode/minigun_rapid,
		"Incendiary" = /datum/lasrifle/base/plasma_rifle_mode/minigun_incendiary,
		"Glob" = /datum/lasrifle/base/plasma_rifle_mode/minigun_glob
	)

/datum/lasrifle/base/plasma_rifle_mode/minigun_rapid
	fire_sound = ""
	icon_state = "plasma_minigun"
	ammo_datum_type = /datum/ammo/energy/plasma/minigun_rapid
	heat_per_fire = 0.5
	fire_delay = 0.15
	fire_mode = GUN_FIREMODE_AUTOMATIC
	rounds_per_shot = 7

/datum/lasrifle/base/plasma_rifle_mode/minigun_incendiary
	fire_sound = ""
	icon_state = "plasma_minigun"
	ammo_datum_type = /datum/ammo/energy/plasma/minigun_incendiary
	heat_per_fire = 5
	fire_delay = 0.35
	fire_mode = GUN_FIREMODE_AUTOMATIC
	rounds_per_shot = 29

/datum/lasrifle/base/plasma_rifle_mode/minigun_glob
	fire_sound = ""
	icon_state = "plasma_minigun"
	ammo_datum_type = /datum/ammo/energy/plasma/minigun_glob
	heat_per_fire = 25
	fire_delay = 0.15
	fire_mode = GUN_FIREMODE_SEMIAUTO
	rounds_per_shot = 100

/obj/item/weapon/gun/energy/lasgun/lasrifle/plasma/sniper
	name = "\improper PL-02 plasma sniper rifle"
	icon_state = "plasma_sniper"
	item_state = "plasma_sniper"
	flags_equip_slot = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	ammo_datum_type = /datum/ammo/energy/plasma/sniper
	heat_per_fire = 10
	rounds_per_shot = 67
	fire_delay = 0.8
	aim_fire_delay = 0.2
	aim_speed_modifier = 0.4

/obj/item/weapon/gun/energy/lasgun/lasrifle/plasma/rifle
	name = "\improper PL-38 plasma rifle"
	icon_state = "plasma_rifle"
	item_state = "plasma_rifle"
	flags_equip_slot = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	wield_delay = 0.45
	aim_slowdown = 0.6
	gun_firemode = GUN_FIREMODE_AUTOMATIC
	ammo_datum_type = /datum/ammo/energy/plasma/rifle_standard
	fire_delay = 0.15
	heat_per_fire = 1
	rounds_per_shot = 20
	mode_list = list(
		"Standard" = /datum/lasrifle/base/plasma_rifle_mode/rifle_standard,
		"Marksman" = /datum/lasrifle/base/plasma_rifle_mode/rifle_marksman,
	)

/datum/lasrifle/base/plasma_rifle_mode/rifle_standard
	ammo_datum_type = /datum/ammo/energy/plasma/rifle_standard
	icon_state = "plasma_rifle"
	fire_mode = GUN_FIREMODE_AUTOMATIC
	fire_delay = 0.15
	heat_per_fire = 1
	rounds_per_shot = 20

/datum/lasrifle/base/plasma_rifle_mode/rifle_marksman
	ammo_datum_type = /datum/ammo/energy/plasma/rifle_marksman
	icon_state = "plasma_rifle"
	fire_mode = GUN_FIREMODE_AUTOMATIC
	fire_delay = 0.45
	heat_per_fire = 2
	rounds_per_shot = 40

/obj/item/weapon/gun/energy/lasgun/lasrifle/plasma/carbine
	name = "\improper PL-51 plasma carbine"
	icon_state = "plasma_carbine"
	item_state = "plasma_carbine"
	flags_equip_slot = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	gun_firemode = GUN_FIREMODE_AUTOMATIC
	wield_delay = 0.3
	aim_slowdown = 0.4
	burst_delay = 0.05
	mode_list = list(
		"Standard" = /datum/lasrifle/base/plasma_rifle_mode/carbine_standard,
		"Shotgun" = /datum/lasrifle/base/plasma_rifle_mode/carbine_shotgun,
		"Tri-fire" = /datum/lasrifle/base/plasma_rifle_mode/carbine_trifire,
	)

/datum/lasrifle/base/plasma_rifle_mode/carbine_standard
	ammo_datum_type = /datum/ammo/energy/plasma/rifle_marksman
	icon_state = "plasma_carbine"
	fire_mode = GUN_FIREMODE_BURSTFIRE
	fire_delay = 0.3
	burst_amount = 3
	heat_per_fire = 1
	rounds_per_shot = 15

/datum/lasrifle/base/plasma_rifle_mode/carbine_shotgun
	ammo_datum_type = /datum/ammo/energy/plasma/rifle_marksman
	icon_state = "plasma_carbine"
	fire_mode = GUN_FIREMODE_SEMIAUTO
	fire_delay = 0.45
	heat_per_fire = 10
	rounds_per_shot = 66

/datum/lasrifle/base/plasma_rifle_mode/carbine_trifire
	ammo_datum_type = /datum/ammo/energy/plasma/carbine_trifire/four
	icon_state = "plasma_carbine"
	fire_mode = GUN_FIREMODE_AUTOMATIC
	fire_delay = 0.15
	heat_per_fire = 3
	rounds_per_shot = 25

/obj/item/weapon/gun/energy/lasgun/lasrifle/plasma/pistol
	name = "\improper PL-85 plasma pistol"
	icon_state = "plasma_pistol"
	item_state = "plasma_pistol"
	ammo_datum_type = /datum/ammo/energy/plasma/pistol_standard
	mode_list = list(
		"Standard" = /datum/lasrifle/base/plasma_rifle_mode/pistol_standard,
		"Automatic" = /datum/lasrifle/base/plasma_rifle_mode/pistol_automatic,
	)

/datum/lasrifle/base/plasma_rifle_mode/pistol_standard
	ammo_datum_type = /datum/ammo/energy/plasma/pistol_standard
	icon_state = "plasma_pistol"
	fire_mode = GUN_FIREMODE_SEMIAUTO
	fire_delay = 0.15
	heat_per_fire = 3
	rounds_per_shot = 25

/datum/lasrifle/base/plasma_rifle_mode/pistol_automatic
	ammo_datum_type = /datum/ammo/energy/plasma/pistol_automatic
	icon_state = "plasma_pistol"
	fire_mode = GUN_FIREMODE_AUTOMATIC
	fire_delay = 0.15
	heat_per_fire = 3
	rounds_per_shot = 25

/obj/item/weapon/gun/energy/lasgun/lasrifle/plasma/cannon
	name = "\improper PL-96 plasma cannon"
	icon_state = "plasma_cannon"
	item_state = "plasma_cannon"
	flags_equip_slot = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	ammo_datum_type = /datum/ammo/energy/plasma/cannon_standard
	mode_list = list(
		"Standard" = /datum/lasrifle/base/plasma_rifle_mode/cannon_standard,
		"Swarm" = /datum/lasrifle/base/plasma_rifle_mode/cannon_swarm,
		"Flamer" = /datum/lasrifle/base/plasma_rifle_mode/cannon_flamer,
	)

/datum/lasrifle/base/plasma_rifle_mode/cannon_standard
	ammo_datum_type = /datum/ammo/energy/plasma/cannon_standard
	icon_state = "plasma_cannon"

/datum/lasrifle/base/plasma_rifle_mode/cannon_swarm
	ammo_datum_type = /datum/ammo/energy/plasma/cannon_swarm
	icon_state = "plasma_cannon"

/datum/lasrifle/base/plasma_rifle_mode/cannon_flamer
	ammo_datum_type = /datum/ammo/energy/plasma/cannon_flamer
	icon_state = "plasma_cannon"
