//-------------------------------------------------------

/obj/item/weapon/gun/rifle
	reload_sound = 'sound/weapons/guns/interact/rifle_reload.ogg'
	cocked_sound = 'sound/weapons/guns/interact/cocked.ogg'
	flags_equip_slot = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	force = 15
	flags_gun_features = GUN_CAN_POINTBLANK||GUN_AMMO_COUNTER
	load_method = MAGAZINE //codex
	aim_slowdown = 0.35
	wield_delay = 0.6 SECONDS
	gun_skill_category = GUN_SKILL_RIFLES

	burst_amount = 3
	burst_delay = 0.2 SECONDS
	accuracy_mult_unwielded = 0.6
	scatter = 0
	scatter_unwielded = 13
	recoil_unwielded = 4
	damage_falloff_mult = 0.5
	upper_akimbo_accuracy = 5
	lower_akimbo_accuracy = 3

//-------------------------------------------------------
//AR-18 Carbine

/obj/item/weapon/gun/rifle/standard_carbine
	name = "\improper AR-18 Kauser carbine"
	desc = "The Kauser and Hoch AR-18 carbine is one of the standard rifles used by the TerraGov Marine Corps. It's commonly used by people who prefer greater mobility in combat, like scouts and other light infantry. Uses 10x24mm caseless ammunition."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "t18"
	item_state = "t18"
	fire_sound = "gun_t12"
	dry_fire_sound = 'sound/weapons/guns/fire/m41a_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/t18_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/t18_reload.ogg'
	caliber = CALIBER_10X24_CASELESS //codex
	max_shells = 36 //codex
	force = 20
	default_ammo_type = /obj/item/ammo_magazine/rifle/standard_carbine
	allowed_ammo_types = list(/obj/item/ammo_magazine/rifle/standard_carbine)
	attachable_allowed = list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/angledgrip,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/gyro,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/bipod,
		/obj/item/attachable/burstfire_assembly,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/suppressor,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/compensator,
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
		/obj/item/attachable/shoulder_mount,
	)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_AUTOBURST)
	attachable_offset = list("muzzle_x" = 41, "muzzle_y" = 17,"rail_x" = 23, "rail_y" = 20, "under_x" = 29, "under_y" = 12, "stock_x" = 0, "stock_y" = 13)
	actions_types = list(/datum/action/item_action/aim_mode)
	aim_fire_delay = 0.1 SECONDS
	aim_speed_modifier = 2

	fire_delay = 0.2 SECONDS
	burst_delay = 0.1 SECONDS
	extra_delay = 0.05 SECONDS
	accuracy_mult = 1.05
	scatter = 0
	burst_scatter_mult = 0.25
	burst_amount = 4
	aim_slowdown = 0.30
	damage_falloff_mult = 0.9
	movement_acc_penalty_mult = 4

/obj/item/weapon/gun/rifle/standard_carbine/pointman
	starting_attachment_types = list(/obj/item/attachable/lasersight, /obj/item/attachable/flashlight)

/obj/item/weapon/gun/rifle/standard_carbine/standard
	starting_attachment_types = list(/obj/item/weapon/gun/grenade_launcher/underslung, /obj/item/attachable/reddot, /obj/item/attachable/extended_barrel)

/obj/item/weapon/gun/rifle/standard_carbine/scout
	starting_attachment_types = list(/obj/item/weapon/gun/grenade_launcher/underslung, /obj/item/attachable/motiondetector, /obj/item/attachable/extended_barrel)

/obj/item/weapon/gun/rifle/standard_carbine/engineer
	starting_attachment_types = list(/obj/item/attachable/magnetic_harness, /obj/item/attachable/lasersight)

/obj/item/weapon/gun/rifle/standard_carbine/plasma_pistol
	starting_attachment_types = list(/obj/item/weapon/gun/pistol/plasma_pistol, /obj/item/attachable/motiondetector, /obj/item/attachable/compensator)

//-------------------------------------------------------
//AR-12 Assault Rifle

/obj/item/weapon/gun/rifle/standard_assaultrifle
	name = "\improper AR-12 K&H assault rifle"
	desc = "The Keckler and Hoch AR-12 assault rifle used to be the TerraGov Marine Corps standard issue rifle before the AR-18 carbine replaced it. It is, however, still used widely despite that. The gun itself is very good at being used in most situations however it suffers in engagements at close quarters and is relatively hard to shoulder than some others. It uses 10x24mm caseless ammunition."
	icon = 'icons/marine/gun64.dmi'
	icon_state = "t12"
	item_state = "t12"
	fire_sound = "gun_t12"
	dry_fire_sound = 'sound/weapons/guns/fire/m41a_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/t18_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/t18_reload.ogg'
	caliber = CALIBER_10X24_CASELESS //codex
	max_shells = 50 //codex
	force = 20
	default_ammo_type = /obj/item/ammo_magazine/rifle/standard_assaultrifle
	allowed_ammo_types = list(/obj/item/ammo_magazine/rifle/standard_assaultrifle)
	attachable_allowed = list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/gyro,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/bipod,
		/obj/item/attachable/burstfire_assembly,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/suppressor,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/compensator,
		/obj/item/attachable/scope,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/scope/marine,
		/obj/item/attachable/angledgrip,
		/obj/item/weapon/gun/pistol/plasma_pistol,
		/obj/item/weapon/gun/shotgun/combat/masterkey,
		/obj/item/weapon/gun/flamer/mini_flamer,
		/obj/item/weapon/gun/grenade_launcher/underslung,
		/obj/item/attachable/motiondetector,
		/obj/item/attachable/buildasentry,
		/obj/item/weapon/gun/rifle/pepperball/pepperball_mini,
		/obj/item/attachable/shoulder_mount,
	)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_AUTOBURST)
	attachable_offset = list("muzzle_x" = 48, "muzzle_y" = 17,"rail_x" = 22, "rail_y" = 20, "under_x" = 35, "under_y" = 11, "stock_x" = 0, "stock_y" = 13)
	actions_types = list(/datum/action/item_action/aim_mode)
	aim_fire_delay = 0.1 SECONDS
	aim_speed_modifier = 2

	fire_delay = 0.2 SECONDS
	burst_delay = 0.15 SECONDS
	extra_delay = 0.05 SECONDS
	accuracy_mult = 1.1
	scatter = -2
	wield_delay = 0.7 SECONDS
	burst_amount = 3
	aim_slowdown = 0.4
	damage_falloff_mult = 0.5

	placed_overlay_iconstate = "t12"

/obj/item/weapon/gun/rifle/standard_assaultrifle/rifleman
	starting_attachment_types = list(/obj/item/attachable/reddot, /obj/item/attachable/extended_barrel, /obj/item/weapon/gun/grenade_launcher/underslung)

/obj/item/weapon/gun/rifle/standard_assaultrifle/engineer
	starting_attachment_types = list(/obj/item/attachable/magnetic_harness, /obj/item/attachable/extended_barrel, /obj/item/weapon/gun/flamer/mini_flamer)

/obj/item/weapon/gun/rifle/standard_assaultrifle/medic
	starting_attachment_types = list(/obj/item/attachable/magnetic_harness, /obj/item/attachable/extended_barrel, /obj/item/weapon/gun/grenade_launcher/underslung)

//-------------------------------------------------------
//DMR-37 DMR

/obj/item/weapon/gun/rifle/standard_dmr
	name = "\improper DMR-37 SCA designated marksman rifle"
	desc = "The San Cristo Arms DMR-37  is the TerraGov Marine Corps designated marksman rifle. It is rather well-known for it's very consistent target placement at longer than usual range, it however lacks a burst fire mode or an automatic mode. It is mostly used by people who prefer to do more careful shooting than most. Uses 10x27mm caseless caliber."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "t37"
	item_state = "t37"
	muzzleflash_iconstate = "muzzle_flash_medium"
	fire_sound = 'sound/weapons/guns/fire/DMR.ogg'
	fire_rattle = 'sound/weapons/guns/fire/DMR_low.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/m41a_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/m41a_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/m41a_reload.ogg'
	caliber = CALIBER_10x27_CASELESS //codex
	aim_slowdown = 0.75
	wield_delay = 0.8 SECONDS
	force = 20
	max_shells = 10 //codex
	default_ammo_type = /obj/item/ammo_magazine/rifle/standard_dmr
	allowed_ammo_types = list(/obj/item/ammo_magazine/rifle/standard_dmr)
	attachable_allowed = list(
		/obj/item/attachable/suppressor,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/compensator,
		/obj/item/attachable/reddot,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/angledgrip,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/bipod,
		/obj/item/attachable/gyro,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/scope,
		/obj/item/attachable/scope/marine,
		/obj/item/attachable/scope/mini/dmr,
		/obj/item/attachable/motiondetector,
		/obj/item/weapon/gun/pistol/plasma_pistol,
		/obj/item/weapon/gun/shotgun/combat/masterkey,
		/obj/item/weapon/gun/flamer/mini_flamer,
		/obj/item/weapon/gun/grenade_launcher/underslung,
		/obj/item/attachable/buildasentry,
		/obj/item/weapon/gun/rifle/pepperball/pepperball_mini,
		/obj/item/attachable/shoulder_mount,
	)

	flags_gun_features = GUN_AMMO_COUNTER|GUN_CAN_POINTBLANK
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_AUTOMATIC)
	starting_attachment_types = list(/obj/item/attachable/scope/mini/dmr)
	attachable_offset = list("muzzle_x" = 48, "muzzle_y" = 21,"rail_x" = 21, "rail_y" = 24, "under_x" = 31, "under_y" = 15, "stock_x" = 14, "stock_y" = 10)
	actions_types = list(/datum/action/item_action/aim_mode)
	aim_fire_delay = 0.2 SECONDS
	aim_speed_modifier = 2

	fire_delay = 0.65 SECONDS
	accuracy_mult = 1.15
	scatter = -4
	burst_amount = 1
	movement_acc_penalty_mult = 6

/obj/item/weapon/gun/rifle/standard_dmr/marksman
	starting_attachment_types = list(/obj/item/attachable/scope, /obj/item/attachable/angledgrip, /obj/item/attachable/extended_barrel)



//-------------------------------------------------------
//BR-64 BR

/obj/item/weapon/gun/rifle/standard_br
	name = "\improper BR-64 SCA battle rifle"
	desc = "The San Cristo Arms BR-64 is the TerraGov Marine Corps main battle rifle. It is known for its consistent ability to perform well at most ranges, and close range stopping power. It is mostly used by people who prefer a bigger round than the average. Uses 10x26.5smm caseless caliber."
	icon_state = "t64"
	item_state = "t64"
	icon = 'icons/Marine/gun64.dmi'
	muzzleflash_iconstate = "muzzle_flash_medium"
	fire_sound = 'sound/weapons/guns/fire/t64.ogg'
	fire_rattle = 'sound/weapons/guns/fire/t64_low.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/m41a_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/m41a_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/m41a_reload.ogg'
	caliber = CALIBER_10x265_CASELESS //codex
	aim_slowdown = 0.55
	wield_delay = 0.7 SECONDS
	force = 20
	max_shells = 36 //codex
	default_ammo_type = /obj/item/ammo_magazine/rifle/standard_br
	allowed_ammo_types = list(/obj/item/ammo_magazine/rifle/standard_br)
	attachable_allowed = list(
		/obj/item/attachable/suppressor,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/compensator,
		/obj/item/attachable/reddot,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/angledgrip,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/bipod,
		/obj/item/attachable/gyro,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/scope,
		/obj/item/attachable/scope/marine,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/motiondetector,
		/obj/item/weapon/gun/grenade_launcher/underslung,
		/obj/item/attachable/buildasentry,
		/obj/item/weapon/gun/rifle/pepperball/pepperball_mini,
		/obj/item/attachable/shoulder_mount,
	)

	flags_gun_features = GUN_AMMO_COUNTER|GUN_CAN_POINTBLANK
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_AUTOBURST)
	starting_attachment_types = list(/obj/item/attachable/scope/mini)
	attachable_offset = list("muzzle_x" = 49, "muzzle_y" = 17,"rail_x" = 27, "rail_y" = 21, "under_x" = 29, "under_y" = 10, "stock_x" = 14, "stock_y" = 10)
	actions_types = list(/datum/action/item_action/aim_mode)
	aim_fire_delay = 0.2 SECONDS
	aim_speed_modifier = 3

	autoburst_delay = 0.60 SECONDS
	fire_delay = 0.3 SECONDS
	burst_amount = 3
	burst_delay = 0.10 SECONDS
	extra_delay = 0.25 SECONDS
	accuracy_mult = 0.9
	scatter = 0

//-------------------------------------------------------
//PR-412 Pulse Rifle

/obj/item/weapon/gun/rifle/m412
	name = "\improper PR-412 pulse rifle"
	desc = "The PR-412 rifle is a Pulse Industries rifle, billed as a pulse rifle due to its use of electronic firing for faster velocity. A rather common sight in most systems. Uses 10x24mm caseless ammunition."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "m412"
	item_state = "m412"
	muzzleflash_iconstate = "muzzle_flash_medium"
	fire_sound = 'sound/weapons/guns/fire/M412.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/m41a_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/m41a_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/m41a_reload.ogg'
	caliber = CALIBER_10X24_CASELESS //codex
	max_shells = 40 //codex
	default_ammo_type = /obj/item/ammo_magazine/rifle
	allowed_ammo_types = list(
		/obj/item/ammo_magazine/rifle,
		/obj/item/ammo_magazine/rifle/extended,
		/obj/item/ammo_magazine/rifle/incendiary,
		/obj/item/ammo_magazine/rifle/ap,
	)
	attachable_allowed = list(
		/obj/item/attachable/suppressor,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/compensator,
		/obj/item/attachable/reddot,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/angledgrip,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/gyro,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/bipod,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/burstfire_assembly,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/scope,
		/obj/item/attachable/scope/mini,
		/obj/item/weapon/gun/pistol/plasma_pistol,
		/obj/item/weapon/gun/shotgun/combat/masterkey,
		/obj/item/weapon/gun/flamer/mini_flamer,
		/obj/item/weapon/gun/grenade_launcher/underslung,
		/obj/item/attachable/buildasentry,
		/obj/item/weapon/gun/rifle/pepperball/pepperball_mini,
		/obj/item/attachable/shoulder_mount,
	)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_AUTOBURST)
	starting_attachment_types = list(/obj/item/weapon/gun/grenade_launcher/underslung)
	attachable_offset = list("muzzle_x" = 44, "muzzle_y" = 19,"rail_x" = 15, "rail_y" = 21, "under_x" = 25, "under_y" = 16, "stock_x" = 18, "stock_y" = 15)

	fire_delay = 0.2 SECONDS
	burst_delay = 0.15 SECONDS
	accuracy_mult = 1.1
	scatter = -1
	wield_delay = 0.7 SECONDS
	burst_amount = 3
	aim_slowdown = 0.4
	damage_mult = 1.05 //Has smaller magazines



//-------------------------------------------------------
//PR-412 PMC VARIANT

/obj/item/weapon/gun/rifle/m412/elite
	name = "\improper PR-412E battle rifle"
	desc = "An \"Elite\" modification of the PR-412 pulse rifle series, given to special operation units. It has been given a stock and a longer barrel with an integrated barrel charger, with a red skull stenciled on the body for some reason."
	icon_state = "m412e"
	item_state = "m412e"
	default_ammo_type = /obj/item/ammo_magazine/rifle/ap
	attachable_allowed = list(
		/obj/item/attachable/suppressor,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/reddot,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/angledgrip,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/gyro,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/bipod,
		/obj/item/attachable/burstfire_assembly,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/scope,
		/obj/item/attachable/scope/mini,
		/obj/item/weapon/gun/pistol/plasma_pistol,
		/obj/item/weapon/gun/shotgun/combat/masterkey,
		/obj/item/weapon/gun/flamer/mini_flamer,
		/obj/item/weapon/gun/grenade_launcher/underslung,
		/obj/item/attachable/buildasentry,
		/obj/item/weapon/gun/rifle/pepperball/pepperball_mini,
		/obj/item/attachable/shoulder_mount,
	)

	attachable_offset = list("muzzle_x" = 44, "muzzle_y" = 19,"rail_x" = 15, "rail_y" = 21, "under_x" = 25, "under_y" = 16, "stock_x" = 18, "stock_y" = 15)
	starting_attachment_types = list(/obj/item/attachable/magnetic_harness, /obj/item/weapon/gun/grenade_launcher/underslung)


	burst_delay = 0.2 SECONDS
	accuracy_mult = 1.15
	damage_mult = 1.5
	scatter = -2
	force = 20


//-------------------------------------------------------
//PR-11

/obj/item/weapon/gun/rifle/m41a
	name = "\improper PR-11 pulse rifle"
	desc = "A strange failed electronically fired rifle, a rather unknown weapon of its time. It caused a surge in the use of electronic firing in the modern era though. Uses 10x24mm caseless ammunition. Has a irremoveable grenade launcher."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "m41a"
	item_state = "m41a"
	fire_sound = "gun_pulse"
	dry_fire_sound = 'sound/weapons/guns/fire/m41a_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/m41a_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/m41a_reload.ogg'
	aim_slowdown = 0.5
	wield_delay = 1.35 SECONDS
	max_shells = 95 //codex
	default_ammo_type = /obj/item/ammo_magazine/rifle/m41a
	allowed_ammo_types = list(/obj/item/ammo_magazine/rifle/m41a)
	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/reddot,
		/obj/item/attachable/suppressor,
		/obj/item/attachable/compensator,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/scope,
		/obj/item/attachable/buildasentry,
		/obj/item/attachable/stock/irremoveable/m41a,
		/obj/item/weapon/gun/grenade_launcher/underslung/invisible,
		/obj/item/attachable/shoulder_mount,
	)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_AUTOBURST)
	starting_attachment_types = list(/obj/item/attachable/stock/irremoveable/m41a, /obj/item/weapon/gun/grenade_launcher/underslung/invisible)
	attachable_offset = list("muzzle_x" = 41, "muzzle_y" = 19,"rail_x" = 12, "rail_y" = 24, "under_x" = 24, "under_y" = 13, "stock_x" = 22, "stock_y" = 16)

	burst_amount = 4
	burst_delay = 0.15 SECONDS
	scatter = 0
	fire_delay = 0.2 SECONDS



//-------------------------------------------------------

/obj/item/weapon/gun/rifle/mpi_km
	name = "\improper MPi-KM assault rifle"
	desc = "A cheap and robust rifle, sometimes better known as an 'AK'. Chambers 7.62x39mm. Despite lacking attachment points beyond its underbarrel, remains a popular product on the black market with its cheap cost and higher than usual caliber rounds."
	icon_state = "ak47"
	item_state = "ak47"
	caliber = CALIBER_762X39 //codex
	muzzleflash_iconstate = "muzzle_flash_medium"
	max_shells = 40 //codex
	fire_sound = 'sound/weapons/guns/fire/ak47.ogg'
	unload_sound = 'sound/weapons/guns/interact/ak47_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/ak47_reload.ogg'
	cocked_sound = 'sound/weapons/guns/interact/ak47_cocked.ogg'
	default_ammo_type = /obj/item/ammo_magazine/rifle/mpi_km
	allowed_ammo_types = list(/obj/item/ammo_magazine/rifle/mpi_km, /obj/item/ammo_magazine/rifle/mpi_km/extended)
	aim_slowdown = 0.6
	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/buildasentry,
		/obj/item/attachable/stock/mpi_km,
		/obj/item/attachable/shoulder_mount,
		/obj/item/attachable/verticalgrip,
		/obj/item/weapon/gun/pistol/plasma_pistol,
		/obj/item/weapon/gun/shotgun/combat/masterkey,
		/obj/item/weapon/gun/flamer/mini_flamer,
		/obj/item/weapon/gun/grenade_launcher/underslung,
		/obj/item/weapon/gun/rifle/pepperball/pepperball_mini,
		/obj/item/weapon/gun/grenade_launcher/underslung/mpi, //alt sprite, unremovable
	)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_AUTOMATIC)
	attachable_offset = list("muzzle_x" = 30, "muzzle_y" = 18,"rail_x" = 1, "rail_y" = 20, "under_x" = 14, "under_y" = 14, "stock_x" = 0, "stock_y" = 12)
	starting_attachment_types = list(/obj/item/attachable/stock/mpi_km)
	force = 20

	burst_amount = 1
	fire_delay = 0.25 SECONDS
	scatter = 2
	wield_delay = 0.8 SECONDS

	placed_overlay_iconstate = "ak47"

/obj/item/weapon/gun/rifle/mpi_km/magharness
	starting_attachment_types = list(
		/obj/item/attachable/stock/mpi_km,
		/obj/item/attachable/magnetic_harness,
	)

/obj/item/weapon/gun/rifle/mpi_km/standard
	starting_attachment_types = list(
		/obj/item/attachable/stock/mpi_km,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/bayonet,
	)

/obj/item/weapon/gun/rifle/mpi_km/grenadier //built in UGL
	desc = "A cheap and robust rifle, sometimes better known as an 'AK'. Chambers 7.62x39mm. This one has a built in underbarrel grenade launcher, and looks pretty old but well looked after."
	starting_attachment_types = list(
		/obj/item/attachable/stock/mpi_km,
		/obj/item/weapon/gun/grenade_launcher/underslung/mpi,
		/obj/item/attachable/magnetic_harness,
	)

//-------------------------------------------------------
//M16 RIFLE

/obj/item/weapon/gun/rifle/m16
	name = "\improper FN M16A4 assault rifle"
	desc = "A light, versatile assault rifle with a 30 round magazine, chambered to fire the 5.56x45mm NATO cartridge. The 4th generation in the M16 platform, this FN variant has added automatic fire selection and retains relevance among mercenaries and militias thanks to its high customizability. it is incredibly good at rapid burst fire, but must be paced correctly."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "m16a4"
	item_state = "m16a4"
	muzzleflash_iconstate = "muzzle_flash_medium"
	caliber = CALIBER_556X45 //codex
	max_shells = 30 //codex
	fire_sound = 'sound/weapons/guns/fire/m16.ogg'
	unload_sound = 'sound/weapons/guns/interact/m16_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/m16_reload.ogg'
	cocked_sound = 'sound/weapons/guns/interact/m16_cocked.ogg'
	default_ammo_type = /obj/item/ammo_magazine/rifle/m16
	allowed_ammo_types = list(/obj/item/ammo_magazine/rifle/m16)
	aim_slowdown = 0.4
	attachable_allowed = list(
		/obj/item/attachable/suppressor,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/reddot,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/angledgrip,
		/obj/item/attachable/gyro,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/bipod,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/compensator,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/m16sight,
		/obj/item/attachable/scope,
		/obj/item/attachable/scope/mini,
		/obj/item/weapon/gun/pistol/plasma_pistol,
		/obj/item/weapon/gun/shotgun/combat/masterkey,
		/obj/item/weapon/gun/flamer/mini_flamer,
		/obj/item/weapon/gun/grenade_launcher/underslung,
		/obj/item/attachable/buildasentry,
		/obj/item/weapon/gun/rifle/pepperball/pepperball_mini,
		/obj/item/attachable/shoulder_mount,
	)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOMATIC)
	attachable_offset = list("muzzle_x" = 47, "muzzle_y" = 19,"rail_x" = 18, "rail_y" = 24, "under_x" = 37, "under_y" = 14, "stock_x" = 19, "stock_y" = 13)
	actions_types = list(/datum/action/item_action/aim_mode)
	aim_fire_delay = 0.2 SECONDS
	aim_speed_modifier = 2.5

	fire_delay = 0.2 SECONDS
	scatter = 2
	extra_delay = -0.05 SECONDS
	burst_delay = 0.15 SECONDS
	accuracy_mult = 1.1
	wield_delay = 0.5 SECONDS
	damage_mult = 1.2

/obj/item/weapon/gun/rifle/m16/freelancer
	starting_attachment_types = list(/obj/item/attachable/magnetic_harness, /obj/item/attachable/bayonet, /obj/item/weapon/gun/shotgun/combat/masterkey)

/obj/item/weapon/gun/rifle/m16/ugl
	starting_attachment_types = list(/obj/item/attachable/magnetic_harness, /obj/item/attachable/bayonet, /obj/item/weapon/gun/grenade_launcher/underslung)

/obj/item/weapon/gun/rifle/m16/somleader
	starting_attachment_types = list(/obj/item/attachable/reddot)

/obj/item/weapon/gun/rifle/m16/somvet
	starting_attachment_types = list(/obj/item/attachable/magnetic_harness)

//-------------------------------------------------------
//FAMAS rifle, based on the F1

/obj/item/weapon/gun/rifle/famas
	name = "\improper FAMAS assault rifle"
	desc = "A light, versatile fast firing assault rifle with a 24 round magazine and short range scope, chambered to fire the 5.56x45mm NATO cartridge in 24 round magazines."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "famas"
	item_state = "famas"
	muzzleflash_iconstate = "muzzle_flash_medium"
	caliber = CALIBER_556X45 //codex
	max_shells = 24 //codex
	fire_sound = 'sound/weapons/guns/fire/famas.ogg'
	unload_sound = 'sound/weapons/guns/interact/m16_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/m16_reload.ogg'
	cocked_sound = 'sound/weapons/guns/interact/m16_cocked.ogg'
	default_ammo_type = /obj/item/ammo_magazine/rifle/famas
	allowed_ammo_types = list(/obj/item/ammo_magazine/rifle/famas)
	aim_slowdown = 0.4
	attachable_allowed = list(
		/obj/item/attachable/suppressor,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/angledgrip,
		/obj/item/attachable/gyro,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/bipod,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/compensator,
		/obj/item/attachable/burstfire_assembly,
		/obj/item/attachable/magnetic_harness,
		/obj/item/weapon/gun/pistol/plasma_pistol,
		/obj/item/weapon/gun/shotgun/combat/masterkey,
		/obj/item/weapon/gun/flamer/mini_flamer,
		/obj/item/weapon/gun/grenade_launcher/underslung,
		/obj/item/weapon/gun/rifle/pepperball/pepperball_mini,
	)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_AUTOBURST)
	attachable_offset = list("muzzle_x" = 38, "muzzle_y" = 17,"rail_x" = 22, "rail_y" = 24, "under_x" = 28, "under_y" = 12, "stock_x" = 19, "stock_y" = 13)

	fire_delay = 0.15 SECONDS
	burst_delay = 0.15 SECONDS
	accuracy_mult = 1.15
	wield_delay = 0.5 SECONDS
	damage_mult = 1.2
	scatter = 1
	movement_acc_penalty_mult = 4

/obj/item/weapon/gun/rifle/famas/freelancermedic
	starting_attachment_types = list(/obj/item/attachable/lasersight, /obj/item/attachable/magnetic_harness, /obj/item/attachable/bayonet)


//-------------------------------------------------------
//MG-42 Light Machine Gun

/obj/item/weapon/gun/rifle/standard_lmg
	name = "\improper MG-42 Kauser light machine gun"
	desc = "The Kauser MG-42 is the TGMC's current standard non-IFF-capable LMG. It's known for its ability to lay down heavy fire support very well. It is generally used when someone wants to hold a position or provide fire support. It uses 10x24mm ammunition."
	icon = 'icons/Marine/gun64.dmi'
	item_icons = list(
		slot_l_hand_str = 'icons/mob/items_lefthand_64.dmi',
		slot_r_hand_str = 'icons/mob/items_righthand_64.dmi',
	)

	inhand_x_dimension = 64
	inhand_y_dimension = 32

	icon_state = "t42"
	item_state = "t42"
	caliber = CALIBER_10X24_CASELESS //codex
	max_shells = 120 //codex
	force = 30
	aim_slowdown = 0.8
	wield_delay = 1 SECONDS
	fire_sound =  'sound/weapons/guns/fire/t42.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/m41a_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/T42_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/T42_reload.ogg'
	default_ammo_type = /obj/item/ammo_magazine/standard_lmg
	allowed_ammo_types = list(/obj/item/ammo_magazine/standard_lmg)
	attachable_allowed = list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/bipod,
		/obj/item/attachable/angledgrip,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/suppressor,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/scope,
		/obj/item/attachable/scope/marine,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/compensator,
		/obj/item/attachable/magnetic_harness,
		/obj/item/weapon/gun/pistol/plasma_pistol,
		/obj/item/weapon/gun/shotgun/combat/masterkey,
		/obj/item/weapon/gun/flamer/mini_flamer,
		/obj/item/weapon/gun/grenade_launcher/underslung,
		/obj/item/weapon/gun/rifle/pepperball/pepperball_mini,
	)

	flags_gun_features = GUN_AMMO_COUNTER
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_AUTOMATIC)
	gun_skill_category = GUN_SKILL_HEAVY_WEAPONS
	attachable_offset = list("muzzle_x" = 49, "muzzle_y" = 16,"rail_x" = 20, "rail_y" = 19, "under_x" = 24, "under_y" = 9, "stock_x" = 0, "stock_y" = 13)
	actions_types = list(/datum/action/item_action/aim_mode)
	aim_fire_delay = 0.2 SECONDS
	aim_speed_modifier = 5

	fire_delay = 0.2 SECONDS
	burst_amount = 1
	accuracy_mult = 1.1
	accuracy_mult_unwielded = 0.5
	scatter = 2
	scatter_unwielded = 80

//-------------------------------------------------------
//MG-60 General Purpose Machine Gun

/obj/item/weapon/gun/rifle/standard_gpmg
	name = "\improper MG-60 Raummetall general purpose machine gun"
	desc = "The Raummetall MG-60 general purpose machinegun is the TGMC's current standard GPMG. Though usually seen mounted on vehicles, it is sometimes used by infantry to hold chokepoints or suppress enemies, or in rare cases for marching fire. It uses 10x26mm boxes."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "t60"
	item_state = "t60"
	caliber = CALIBER_10x26_CASELESS //codex
	max_shells = 250 //codex
	force = 35
	aim_slowdown = 1.2
	wield_delay = 1.5 SECONDS
	fire_sound =  'sound/weapons/guns/fire/GPMG.ogg'
	fire_rattle =  'sound/weapons/guns/fire/GPMG_low.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/m41a_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/T42_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/T42_reload.ogg'
	default_ammo_type = /obj/item/ammo_magazine/standard_gpmg
	allowed_ammo_types = list(/obj/item/ammo_magazine/standard_gpmg)
	attachable_allowed = list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/bipod,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/suppressor,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/scope,
		/obj/item/attachable/scope/marine,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/stock/t60stock,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/motiondetector,
		/obj/item/attachable/buildasentry,
		/obj/item/attachable/shoulder_mount,
	)

	flags_gun_features = GUN_AMMO_COUNTER|GUN_WIELDED_FIRING_ONLY
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_AUTOMATIC)
	starting_attachment_types = list(/obj/item/attachable/stock/t60stock)
	gun_skill_category = GUN_SKILL_HEAVY_WEAPONS
	attachable_offset = list("muzzle_x" = 41, "muzzle_y" = 21,"rail_x" = 8, "rail_y" = 23, "under_x" = 25, "under_y" = 14, "stock_x" = 11, "stock_y" = 14)
	actions_types = list(/datum/action/item_action/aim_mode)
	aim_fire_delay = 0.2 SECONDS
	aim_speed_modifier = 6

	fire_delay = 0.15 SECONDS
	damage_falloff_mult = 0.5
	burst_amount = 1
	accuracy_mult_unwielded = 0.4
	scatter = 7
	scatter_unwielded = 45
	movement_acc_penalty_mult = 6

	placed_overlay_iconstate = "lmg"

/obj/item/weapon/gun/rifle/standard_lmg/autorifleman
	starting_attachment_types = list(/obj/item/attachable/verticalgrip, /obj/item/attachable/reddot)

/obj/item/weapon/gun/rifle/standard_gpmg/machinegunner
	starting_attachment_types = list(/obj/item/attachable/stock/t60stock, /obj/item/attachable/bipod, /obj/item/attachable/reddot, /obj/item/attachable/extended_barrel)

//-------------------------------------------------------
//M41AE2 Heavy Pulse Rifle

/obj/item/weapon/gun/rifle/m412l1_hpr
	name = "\improper PR-412L1 heavy pulse rifle"
	desc = "A large weapon capable of laying down supressing fire, based on the PR-412 pulse rifle platform. Uses 10x24mm caseless ammunition."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "m412l1"
	item_state = "m412l1"
	caliber = CALIBER_10X24_CASELESS //codex
	max_shells = 200 //codex
	aim_slowdown = 0.8
	wield_delay = 2 SECONDS
	fire_sound =  'sound/weapons/guns/fire/hmg.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/m41a_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/m41a_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/m41a_reload.ogg'
	default_ammo_type = /obj/item/ammo_magazine/m412l1_hpr
	allowed_ammo_types = list(/obj/item/ammo_magazine/m412l1_hpr)
	attachable_allowed = list(
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/reddot,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/angledgrip,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/bipod,
		/obj/item/attachable/compensator,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/scope,
		/obj/item/attachable/scope/marine,
		/obj/item/attachable/scope/mini,
		/obj/item/weapon/gun/pistol/plasma_pistol,
		/obj/item/weapon/gun/shotgun/combat/masterkey,
		/obj/item/weapon/gun/flamer/mini_flamer,
		/obj/item/weapon/gun/grenade_launcher/underslung,
		/obj/item/attachable/buildasentry,
		/obj/item/weapon/gun/rifle/pepperball/pepperball_mini,
		/obj/item/attachable/stock/irremoveable/rifle,
		/obj/item/attachable/shoulder_mount,
	)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_WIELDED_FIRING_ONLY
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_AUTOBURST)
	gun_skill_category = GUN_SKILL_HEAVY_WEAPONS
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 19,"rail_x" = 8, "rail_y" = 21, "under_x" = 22, "under_y" = 15, "stock_x" = 9, "stock_y" = 15)
	starting_attachment_types = list(/obj/item/attachable/stock/irremoveable/rifle)
	actions_types = list(/datum/action/item_action/aim_mode)
	aim_fire_delay = 0.15 SECONDS
	aim_speed_modifier = 2

	fire_delay = 0.3 SECONDS
	burst_amount = 5
	burst_delay = 0.1 SECONDS
	accuracy_mult_unwielded = 0.5
	accuracy_mult = 1.05
	scatter = 5
	scatter_unwielded = 25
	recoil_unwielded = 5
	force = 20

	placed_overlay_iconstate = "lmg"

/obj/item/weapon/gun/rifle/m412l1_hpr/freelancer
	starting_attachment_types = list(
		/obj/item/attachable/stock/irremoveable/rifle,
		/obj/item/attachable/compensator,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/bipod,
	)
//-------------------------------------------------------
//USL TYPE 71 RIFLE

/obj/item/weapon/gun/rifle/type71
	name = "\improper Type 71 pulse rifle"
	desc = "The primary rifle of the USL pirates, the Type 71 is a reliable rifle chambered in 7.62x39mm, firing in three round bursts to conserve ammunition. A newer model for surpression roles to comply with overmatch doctrines is in progress and only issued to a limited number of privates in the USL."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "type71"
	item_state = "type71"
	muzzleflash_iconstate = "muzzle_flash_medium"
	caliber = CALIBER_762X39 //codex
	max_shells = 42 //codex
	fire_sound = 'sound/weapons/guns/fire/type71.ogg'
	unload_sound = 'sound/weapons/guns/interact/type71_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/type71_reload.ogg'
	cocked_sound = 'sound/weapons/guns/interact/type71_cocked.ogg'
	default_ammo_type = /obj/item/ammo_magazine/rifle/type71
	allowed_ammo_types = list(/obj/item/ammo_magazine/rifle/type71)
	aim_slowdown = 0.6
	wield_delay = 0.7 SECONDS
	attachable_allowed = list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/gyro,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/bipod,
		/obj/item/attachable/burstfire_assembly,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/suppressor,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/compensator,
		/obj/item/attachable/scope,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/scope/marine,
		/obj/item/attachable/angledgrip,
		/obj/item/weapon/gun/pistol/plasma_pistol,
		/obj/item/weapon/gun/shotgun/combat/masterkey,
		/obj/item/weapon/gun/flamer/mini_flamer,
		/obj/item/weapon/gun/grenade_launcher/underslung,
		/obj/item/weapon/gun/rifle/pepperball/pepperball_mini,
		/obj/item/weapon/gun/flamer/mini_flamer/unremovable,
		/obj/item/attachable/suppressor/unremovable/invisible,
		/obj/item/attachable/scope/unremovable,
	)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER
	attachable_offset = list("muzzle_x" = 41, "muzzle_y" = 19,"rail_x" = 18, "rail_y" = 24, "under_x" = 34, "under_y" = 16, "stock_x" = 19, "stock_y" = 13)
	gun_firemode_list = list(GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOBURST)
	actions_types = list(/datum/action/item_action/aim_mode)
	aim_fire_delay = 0.15 SECONDS
	aim_speed_modifier = 2

	fire_delay = 0.25 SECONDS
	burst_amount = 3
	accuracy_mult = 1.1
	accuracy_mult_unwielded = 0.8
	scatter = -1


/obj/item/weapon/gun/rifle/type71/flamer
	name = "\improper Type 71 pulse rifle"
	desc = " This appears to be a less common variant of the usual Type 71, with an undermounted flamethrower and improved iron sights."
	attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 18,"rail_x" = 12, "rail_y" = 23, "under_x" = 20, "under_y" = 13, "stock_x" = 24, "stock_y" = 13)
	attachable_allowed = list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/suppressor,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/compensator,
		/obj/item/attachable/scope,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/scope/marine,
		/obj/item/weapon/gun/flamer/mini_flamer/unremovable,
	)
	starting_attachment_types = list(/obj/item/weapon/gun/flamer/mini_flamer/unremovable)

/obj/item/weapon/gun/rifle/type71/flamer/standard
	starting_attachment_types = list(
		/obj/item/weapon/gun/flamer/mini_flamer/unremovable,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/magnetic_harness,
	)

/obj/item/weapon/gun/rifle/type71/commando
	name = "\improper Type 73 'Commando' pulse carbine"
	desc = "An much rarer variant of the standard Type 71, this version contains an integrated supressor, a scope, and lots of fine-tuning. Many parts have been replaced, filed down, and improved upon. As a result, this variant is rarely seen outside of elite units."
	icon_state = "type71"
	item_state = "type71"
	wield_delay = 0 //Ends up being .5 seconds due to scope
	attachable_offset = list("muzzle_x" = 30, "muzzle_y" = 19,"rail_x" = 10, "rail_y" = 22, "under_x" = 21, "under_y" = 18, "stock_x" = 21, "stock_y" = 18)
	starting_attachment_types = list(/obj/item/attachable/suppressor/unremovable/invisible, /obj/item/attachable/scope/unremovable)

	fire_delay = 0.3 SECONDS
	burst_amount = 2
	accuracy_mult = 1.25
	accuracy_mult_unwielded = 0.8
	damage_mult = 1.3

/obj/item/weapon/gun/rifle/type71/seasonal
	desc = "The primary rifle of many space pirates and militias, the Type 71 is a reliable rifle chambered in 7.62x39mm, firing in three round bursts to conserve ammunition."

//-------------------------------------------------------
//TX-16 AUTOMATIC SHOTGUN

/obj/item/weapon/gun/rifle/standard_autoshotgun
	name = "\improper Zauer SH-15 automatic shotgun"
	desc = "The Zauer SH-15 Automatic Assault Shotgun, produced by Terran Armories. Another iteration of the ZX series of firearms, taking over the SX as the semi-automatic shotgun provided to the TGMC. Compared to the SX, this Shotgun is rifled, and loads primarily longer ranged munitions, being incompatible with buckshot shells. Takes 12-round 16 gauge magazines."
	icon_state = "tx15"
	item_state = "tx15"
	fire_sound = 'sound/weapons/guns/fire/shotgun.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/shotgun_empty.ogg'
	caliber = CALIBER_16G //codex
	max_shells = 12 //codex
	force = 20
	default_ammo_type = /obj/item/ammo_magazine/rifle/tx15_slug
	allowed_ammo_types = list(
		/obj/item/ammo_magazine/rifle/tx15_slug,
		/obj/item/ammo_magazine/rifle/tx15_flechette,
	)
	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/reddot,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/angledgrip,
		/obj/item/attachable/gyro,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/stock/tx15,
		/obj/item/attachable/compensator,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/motiondetector,
		/obj/item/weapon/gun/pistol/plasma_pistol,
		/obj/item/weapon/gun/flamer/mini_flamer,
		/obj/item/weapon/gun/grenade_launcher/underslung,
		/obj/item/weapon/gun/rifle/pepperball/pepperball_mini,
	)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_WIELDED_FIRING_ONLY //Its a shotgun type weapon effectively, most shotgun type weapons shouldn't be able to point blank 1 handed.
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_AUTOMATIC)
	starting_attachment_types = list(/obj/item/attachable/stock/tx15)
	attachable_offset = list("muzzle_x" = 30, "muzzle_y" = 16,"rail_x" = 12, "rail_y" = 17, "under_x" = 20, "under_y" = 13, "stock_x" = 26, "stock_y" = 13)
	gun_skill_category = GUN_SKILL_SHOTGUNS

	fire_delay = 1 SECONDS
	accuracy_mult = 1.15
	burst_amount = 1
	scatter = -2
	movement_acc_penalty_mult = 3

/obj/item/weapon/gun/rifle/standard_autoshotgun/engineer
	starting_attachment_types = list(/obj/item/attachable/stock/tx15, /obj/item/attachable/magnetic_harness, /obj/item/weapon/gun/grenade_launcher/underslung)

/obj/item/weapon/gun/rifle/standard_autoshotgun/standard
	starting_attachment_types = list(/obj/item/attachable/stock/tx15, /obj/item/attachable/magnetic_harness, /obj/item/attachable/heavy_barrel, /obj/item/weapon/gun/grenade_launcher/underslung)

/obj/item/weapon/gun/rifle/standard_autoshotgun/plasma_pistol
	starting_attachment_types = list(/obj/item/attachable/stock/tx15, /obj/item/attachable/reddot, /obj/item/attachable/extended_barrel, /obj/item/weapon/gun/pistol/plasma_pistol)

//-------------------------------------------------------
//SG-29 Smart Machine Gun (It's more of a rifle than the SG.)

/obj/item/weapon/gun/rifle/standard_smartmachinegun
	name = "\improper SG-29 Raummetall-KT smart machine gun"
	desc = "The Raummetall-KT SG-29 is the TGMC's current standard IFF-capable medium machine gun. It's known for its ability to lay down heavy fire support very well. It is generally used when someone wants to hold a position or provide fire support. Requires special training and it cannot turn off IFF. It uses 10x26mm ammunition."
	icon_state = "sg29"
	item_state = "sg29"
	caliber = CALIBER_10x26_CASELESS //codex
	max_shells = 300 //codex
	force = 30
	aim_slowdown = 0.95
	wield_delay = 1.3 SECONDS
	fire_sound = "gun_smartgun"
	dry_fire_sound = 'sound/weapons/guns/fire/m41a_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/T42_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/T42_reload.ogg'
	default_ammo_type = /obj/item/ammo_magazine/standard_smartmachinegun
	allowed_ammo_types = list(/obj/item/ammo_magazine/standard_smartmachinegun)
	attachable_allowed = list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/bipod,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/motiondetector,
		/obj/item/attachable/buildasentry,
		/obj/item/attachable/stock/sgstock,
		/obj/item/attachable/sgbarrel,
		/obj/item/attachable/shoulder_mount,
	)

	flags_gun_features = GUN_AMMO_COUNTER|GUN_WIELDED_FIRING_ONLY|GUN_IFF
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_AUTOMATIC)
	starting_attachment_types = list(/obj/item/attachable/stock/sgstock, /obj/item/attachable/sgbarrel)
	gun_skill_category = GUN_SKILL_SMARTGUN //Uses SG skill for the penalties.
	attachable_offset = list("muzzle_x" = 42, "muzzle_y" = 17,"rail_x" = 15, "rail_y" = 21, "under_x" = 24, "under_y" = 14, "stock_x" = 12, "stock_y" = 13)
	fire_delay = 0.2 SECONDS
	burst_amount = 0
	accuracy_mult_unwielded = 0.5
	accuracy_mult = 1.1
	scatter = -5
	scatter_unwielded = 40
	movement_acc_penalty_mult = 4

	placed_overlay_iconstate = "smartgun"

/obj/item/weapon/gun/rifle/standard_smartmachinegun/pmc
	starting_attachment_types = list(/obj/item/attachable/stock/sgstock, /obj/item/attachable/sgbarrel, /obj/item/attachable/magnetic_harness)

/obj/item/weapon/gun/rifle/standard_smartmachinegun/patrol
	starting_attachment_types = list(/obj/item/attachable/stock/sgstock, /obj/item/attachable/sgbarrel, /obj/item/attachable/motiondetector, /obj/item/attachable/bipod)

//-------------------------------------------------------
//Sectoid Rifle

/obj/item/weapon/gun/rifle/sectoid_rifle
	name = "\improper alien rifle"
	desc = "An unusual gun of alien origin. It is lacking a trigger or any obvious way to fire it."
	icon_state = "alien_rifle"
	item_state = "alien_rifle"
	fire_sound = 'sound/weapons/guns/fire/alienplasma.ogg'
	fire_rattle = 'sound/weapons/guns/fire/alienplasma.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/vp70_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/m41a_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/m4ra_reload.ogg'
	max_shells = 20//codex stuff
	ammo_datum_type = /datum/ammo/energy/plasma
	muzzleflash_iconstate = "muzzle_flash_pulse"
	default_ammo_type = /obj/item/ammo_magazine/rifle/sectoid_rifle
	allowed_ammo_types = list(/obj/item/ammo_magazine/rifle/sectoid_rifle)
	wield_delay = 0.4 SECONDS

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_ENERGY
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOBURST)
	attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 18,"rail_x" = 12, "rail_y" = 23, "under_x" = 23, "under_y" = 15, "stock_x" = 22, "stock_y" = 12)

	fire_delay = 0.5 SECONDS
	burst_amount = 3
	burst_delay = 0.15 SECONDS
	accuracy_mult = 2
	accuracy_mult_unwielded = 0.8
	movement_acc_penalty_mult = 3

//only sectoids can fire it
/obj/item/weapon/gun/rifle/sectoid_rifle/able_to_fire(mob/user)
	. = ..()
	if(!.)
		return
	if(!ishuman(user))
		return FALSE
	var/mob/living/carbon/human/H = user
	if(!(H.species.species_flags & USES_ALIEN_WEAPONS))
		to_chat(user, span_warning("There's no trigger on this gun, you have no idea how to fire it!"))
		return FALSE
	return TRUE


//-------------------------------------------------------
//SR-127 bolt action sniper rifle

/obj/item/weapon/gun/rifle/chambered
	name = "\improper SR-127 Bauer bolt action rifle"
	desc = "The Bauer SR-127 is the standard issue bolt action rifle used by the TGMC. Known for its long range accuracy and use by marksmen despite its age and lack of IFF. It has an irremoveable scope. Uses 8.6×70mm box magazines."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "tl127"
	item_state = "tl127"
	fire_sound = 'sound/weapons/guns/fire/tl127.ogg'
	fire_rattle = 'sound/weapons/guns/fire/tl127_low.ogg'
	cocked_sound = 'sound/weapons/guns/interact/tl-127_bolt.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/sniper_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/m41a_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/m41a_reload.ogg'
	caliber = CALIBER_86X70 //codex
	max_shells = 7 //codex
	default_ammo_type = /obj/item/ammo_magazine/rifle/chamberedrifle
	allowed_ammo_types = list(
		/obj/item/ammo_magazine/rifle/chamberedrifle,
		/obj/item/ammo_magazine/rifle/chamberedrifle/flak,
	)
	attachable_allowed = list(
		/obj/item/attachable/scope/unremovable/tl127,
		/obj/item/attachable/stock/tl127stock,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/suppressor,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/compensator,
		/obj/item/attachable/bipod,
	)

	flags_gun_features = GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER
	reciever_flags = AMMO_RECIEVER_REQUIRES_UNIQUE_ACTION|AMMO_RECIEVER_MAGAZINES|AMMO_RECIEVER_UNIQUE_ACTION_LOCKS|AMMO_RECIEVER_AUTO_EJECT
	cocked_message = "You rack the bolt!"
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO)
	attachable_offset = list("muzzle_x" = 41, "muzzle_y" = 19,"rail_x" = 8, "rail_y" = 21, "under_x" = 37, "under_y" = 16, "stock_x" = 9, "stock_y" = 12)
	actions_types = list(/datum/action/item_action/aim_mode)
	aim_fire_delay = 1 SECONDS

	starting_attachment_types = list(
		/obj/item/attachable/scope/unremovable/tl127,
		/obj/item/attachable/stock/tl127stock,
	)

	burst_amount = 0
	fire_delay = 1.35 SECONDS
	accuracy_mult = 1.15
	accuracy_mult_unwielded = 0.7
	scatter = -5
	scatter_unwielded = 20
	recoil = 0
	recoil_unwielded = 4
	aim_slowdown = 1
	wield_delay = 1.3 SECONDS
	cock_delay = 0.7 SECONDS
	movement_acc_penalty_mult = 6


//-------------------------------------------------------
//SR-81 Auto-Sniper

/obj/item/weapon/gun/rifle/standard_autosniper
	name = "\improper SR-81 Kauser-KT automatic sniper rifle"
	desc = "The Kauser-KT SR-81 is the TerraGov Marine Corps's automatic sniper rifle usually married to it's iconic NVG/KTLD scope combo. It's users use it for it's high rate of fire for it's class, and has decent performance in any range. Uses 8.6x70mm caseless with specialized pressures for IFF fire."
	icon_state = "t81"
	item_state = "t81"
	fire_sound = 'sound/weapons/guns/fire/sniper.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/sniper_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/m41a_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/m41a_reload.ogg'
	caliber = CALIBER_86X70 //codex
	max_shells = 20 //codex
	default_ammo_type = /obj/item/ammo_magazine/rifle/autosniper
	allowed_ammo_types = list(/obj/item/ammo_magazine/rifle/autosniper)
	attachable_allowed = list(
		/obj/item/attachable/autosniperbarrel,
		/obj/item/attachable/scope/nightvision,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/suppressor,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/compensator,
	)

	flags_gun_features = GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER|GUN_IFF
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_AUTOMATIC)
	attachable_offset = list("muzzle_x" = 48, "muzzle_y" = 18,"rail_x" = 23, "rail_y" = 23, "under_x" = 38, "under_y" = 16, "stock_x" = 9, "stock_y" = 12)
	starting_attachment_types = list(
		/obj/item/attachable/autosniperbarrel,
		/obj/item/attachable/scope/nightvision,
	)

	burst_amount = 0
	fire_delay = 0.55 SECONDS
	accuracy_mult = 1.1
	accuracy_mult_unwielded = 0.7
	scatter = -5
	scatter_unwielded = 20
	recoil = 0
	recoil_unwielded = 4
	aim_slowdown = 1
	wield_delay = 1.3 SECONDS
	movement_acc_penalty_mult = 6

//-------------------------------------------------------
//AR-11 Rifle, based on the gamer-11

/obj/item/weapon/gun/rifle/tx11
	name = "\improper AR-11 K&H combat rifle"
	desc = "The Keckler and Hoch AR-11 is the former standard issue rifle of the TGMC. Most of them have been mothballed into storage long ago, but some still pop up in marine or mercenary hands. It is known for its large magazine size and great burst fire, but rather awkward to use, especially during combat. It uses 4.92×34mm caseless HV ammunition."
	icon_state = "tx11"
	item_state = "tx11"
	caliber = CALIBER_492X34_CASELESS //codex
	max_shells = 70 //codex
	wield_delay = 0.65 SECONDS
	fire_sound = 'sound/weapons/guns/fire/M412.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/m41a_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/T42_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/T42_reload.ogg'
	default_ammo_type = /obj/item/ammo_magazine/rifle/tx11
	allowed_ammo_types = list(/obj/item/ammo_magazine/rifle/tx11)
	attachable_allowed = list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/scope/mini/tx11,
		/obj/item/attachable/stock/irremoveable/tx11,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/motiondetector,
		/obj/item/attachable/scope/marine,
	)

	flags_gun_features = GUN_AMMO_COUNTER
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_AUTOBURST)
	starting_attachment_types = list(/obj/item/attachable/stock/irremoveable/tx11, /obj/item/attachable/scope/mini/tx11)
	attachable_offset = list("muzzle_x" = 31, "muzzle_y" = 17,"rail_x" = 8, "rail_y" = 20, "under_x" = 16, "under_y" = 13, "stock_x" = 19, "stock_y" = 23)
	actions_types = list(/datum/action/item_action/aim_mode)
	aim_fire_delay = 0.15 SECONDS

	fire_delay = 0.25 SECONDS
	burst_amount = 3
	burst_delay = 0.05 SECONDS
	extra_delay = 0.1 SECONDS
	accuracy_mult_unwielded = 0.5
	accuracy_mult = 1.15
	scatter = -1
	scatter_unwielded = 15
	burst_scatter_mult = 0.33
	aim_slowdown = 0.45
	movement_acc_penalty_mult = 6

/obj/item/weapon/gun/rifle/tx11/scopeless
	starting_attachment_types = list(/obj/item/attachable/stock/irremoveable/tx11)

/obj/item/weapon/gun/rifle/tx11/freelancerone
	starting_attachment_types = list(/obj/item/attachable/stock/irremoveable/tx11, /obj/item/attachable/magnetic_harness, /obj/item/attachable/bayonet, /obj/item/attachable/lasersight)

/obj/item/weapon/gun/rifle/tx11/freelancertwo
	starting_attachment_types = list(/obj/item/attachable/stock/irremoveable/tx11, /obj/item/attachable/motiondetector, /obj/item/attachable/bayonet, /obj/item/attachable/lasersight)

/obj/item/weapon/gun/rifle/tx11/standard
	starting_attachment_types = list(/obj/item/attachable/stock/irremoveable/tx11, /obj/item/attachable/reddot, /obj/item/attachable/lasersight)

//-------------------------------------------------------
//AR-21 Assault Rifle

/obj/item/weapon/gun/rifle/standard_skirmishrifle
	name = "\improper AR-21 Kauser skirmish rifle"
	desc = "The Kauser AR-21 is a versatile rifle is developed to bridge a gap between higher caliber weaponry and a normal rifle. It fires a strong 10x25 round, which has decent stopping power. It however suffers in magazine size and movement capablity compared to smaller peers. It uses 10x25mm caseless ammunition."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "t21"
	item_state = "t21"
	fire_sound = 'sound/weapons/guns/fire/t21.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/t21_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/t21_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/t21_reload.ogg'
	caliber = CALIBER_10X25_CASELESS //codex
	max_shells = 30 //codex
	force = 20
	default_ammo_type = /obj/item/ammo_magazine/rifle/standard_skirmishrifle
	allowed_ammo_types = list(/obj/item/ammo_magazine/rifle/standard_skirmishrifle)
	attachable_allowed = list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/gyro,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/bipod,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/suppressor,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/compensator,
		/obj/item/attachable/scope,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/scope/marine,
		/obj/item/attachable/angledgrip,
		/obj/item/weapon/gun/pistol/plasma_pistol,
		/obj/item/weapon/gun/shotgun/combat/masterkey,
		/obj/item/weapon/gun/flamer/mini_flamer,
		/obj/item/weapon/gun/grenade_launcher/underslung,
		/obj/item/attachable/motiondetector,
		/obj/item/weapon/gun/rifle/pepperball/pepperball_mini,
	)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_AUTOMATIC)
	attachable_offset = list("muzzle_x" = 46, "muzzle_y" = 16,"rail_x" = 18, "rail_y" = 19, "under_x" = 34, "under_y" = 12, "stock_x" = 0, "stock_y" = 13)
	actions_types = list(/datum/action/item_action/aim_mode)
	aim_fire_delay = 0.15 SECONDS
	aim_speed_modifier = 2.5

	fire_delay = 0.25 SECONDS
	burst_amount = 1
	burst_delay = 0.15 SECONDS
	accuracy_mult = 1.2
	scatter = -2
	wield_delay = 0.6 SECONDS
	aim_slowdown = 0.5
	damage_falloff_mult = 0.5

/obj/item/weapon/gun/rifle/standard_skirmishrifle/standard
	starting_attachment_types = list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/extended_barrel,
		/obj/item/weapon/gun/grenade_launcher/underslung,
	)

//-------------------------------------------------------
//AF-51B MACHINEcarbine

/obj/item/weapon/gun/rifle/alf_machinecarbine
	name = "\improper ALF-51B Kauser machinecarbine"
	desc = "The Kauser ALF-51B is an unoffical modification of a ALF-51, or better known as the AR-18 carbine, modified to SMG length of barrel, rechambered for a stronger round, and belt based. Truly the peak of CQC. Useless past that. Aiming is impossible. Uses 10x25mm caseless ammunition."
	icon_state = "alf51b"
	item_state = "alf51b"
	fire_animation = "alf51b_fire"
	fire_sound = 'sound/weapons/guns/fire/t18b.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/m41a_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/t18_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/t18_reload.ogg'
	caliber = CALIBER_10X25_CASELESS //codex
	max_shells = 80 //codex
	force = 20
	default_ammo_type = /obj/item/ammo_magazine/rifle/alf_machinecarbine
	allowed_ammo_types = list(/obj/item/ammo_magazine/rifle/alf_machinecarbine)
	attachable_allowed = list(
		/obj/item/attachable/flashlight,
		/obj/item/attachable/bipod,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/suppressor,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
	)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_AUTOBURST)
	attachable_offset = list("muzzle_x" = 31, "muzzle_y" = 16,"rail_x" = 10, "rail_y" = 19, "under_x" = 21, "under_y" = 13, "stock_x" = 0, "stock_y" = 13)

	fire_delay = 0.2 SECONDS
	burst_delay = 0.1 SECONDS
	extra_delay = 0.5 SECONDS
	///Same delay as normal burst mode
	autoburst_delay = 0.7 SECONDS
	scatter = 4
	burst_amount = 4
	aim_slowdown = 0.3
	wield_delay = 0.4 SECONDS
	damage_falloff_mult = 3
	movement_acc_penalty_mult = 4

/obj/item/weapon/gun/rifle/alf_machinecarbine/freelancer
	starting_attachment_types = list(
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/bayonet,
	)

/obj/item/weapon/gun/rifle/alf_machinecarbine/assault
	starting_attachment_types = list(
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/verticalgrip,
	)

//-------------------------------------------------------
// MKH-98

/obj/item/weapon/gun/rifle/mkh
	name = "\improper MKH-98 storm rifle"
	desc = "A certified classic, this design was hailed as the first successful assault rifle concept, generally termed a 'storm rifle'. Has a higher than usual firerate for it's class, but suffers in capacity. This version of it chambers 7.62x39mm."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "mkh98"
	item_state = "mkh98"
	caliber = CALIBER_762X39 //codex
	muzzleflash_iconstate = "muzzle_flash_medium"
	max_shells = 30 //codex
	fire_sound = 'sound/weapons/guns/fire/ak47.ogg'
	unload_sound = 'sound/weapons/guns/interact/ak47_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/ak47_reload.ogg'
	cocked_sound = 'sound/weapons/guns/interact/ak47_cocked.ogg'
	default_ammo_type = /obj/item/ammo_magazine/rifle/mkh
	allowed_ammo_types = list(/obj/item/ammo_magazine/rifle/mkh)
	aim_slowdown = 0.35
	attachable_allowed = list(
		/obj/item/attachable/flashlight,
		/obj/item/attachable/bipod,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/suppressor,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
	)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_AUTOMATIC)
	attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 17,"rail_x" = 15, "rail_y" = 17, "under_x" = 24, "under_y" = 13, "stock_x" = 0, "stock_y" = 12)

	accuracy_mult = 1.1
	burst_amount = 1
	fire_delay = 0.2 SECONDS
	scatter = 1
	wield_delay = 0.5 SECONDS
	movement_acc_penalty_mult = 4

//-------------------------------------------------------
// GL-54 grenade launcher
/obj/item/weapon/gun/rifle/tx54
	name = "GL-54 grenade launcher"
	desc = "A magazine fed, semiautomatic grenade launcher designed to shoot airbursting smart grenades. Requires a T49 scope for precision aiming."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "tx54"
	item_state = "tx54" ///todo
	max_shells = 5 //codex
	max_chamber_items = 1
	fire_delay = 1.2 SECONDS
	fire_sound = 'sound/weapons/guns/fire/underbarrel_grenadelauncher.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/shotgun_empty.ogg'
	caliber = CALIBER_20MM //codex
	attachable_allowed = list(
		/obj/item/attachable/scope/optical,
		/obj/item/attachable/reddot,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/bipod,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/scope,
		/obj/item/attachable/scope/marine,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/motiondetector,
		/obj/item/attachable/buildasentry,
		/obj/item/attachable/shoulder_mount,
	)

	flags_gun_features = GUN_AMMO_COUNTER|GUN_WIELDED_STABLE_FIRING_ONLY|GUN_WIELDED_FIRING_ONLY
	starting_attachment_types = list(/obj/item/attachable/scope/optical)
	default_ammo_type = null
	allowed_ammo_types = list(
		/obj/item/ammo_magazine/rifle/tx54,
		/obj/item/ammo_magazine/rifle/tx54/he,
		/obj/item/ammo_magazine/rifle/tx54/incendiary,
	)
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO)
	attachable_offset = list("muzzle_x" = 31, "muzzle_y" = 17,"rail_x" = 12, "rail_y" = 20, "under_x" = 28, "under_y" = 13, "stock_x" = -1, "stock_y" = 17)
	aim_slowdown = 0.8
	wield_delay = 0.8 SECONDS
	burst_amount = 1
	accuracy_mult = 1.15
	scatter = -2
	aim_fire_delay = 0.2 SECONDS
	aim_speed_modifier = 2

//-------------------------------------------------------
// AR-55 built in grenade launcher

/obj/item/weapon/gun/rifle/tx54/mini
	name = "GL-55 20mm grenade launcher"
	desc = "A weapon-mounted, reloadable, five-shot grenade launcher."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "tx55gl"
	placed_overlay_iconstate = "tx55gl"
	attachable_allowed = list()
	flags_gun_features = GUN_AMMO_COUNTER|GUN_IS_ATTACHMENT|GUN_ATTACHMENT_FIRE_ONLY|GUN_WIELDED_STABLE_FIRING_ONLY|GUN_WIELDED_FIRING_ONLY
	flags_attach_features = NONE
	slot = ATTACHMENT_SLOT_STOCK
	default_ammo_type = /obj/item/ammo_magazine/rifle/tx54
	attach_delay = 3 SECONDS
	detach_delay = 3 SECONDS
	actions_types = list(/datum/action/item_action/aim_mode)
	starting_attachment_types = list()

//-------------------------------------------------------
// AR-55 rifle

/obj/item/weapon/gun/rifle/tx55
	name = "\improper AR-55 assault rifle"
	desc = "Officially designated an Objective Individual Combat Weapon, The AR-55 features an upper bullpup 20mm grenade launcher designed to fire a variety of specialised rounds, and an underslung assault rifle using 10x24mm caseless ammunition. Somewhat cumbersome to use due to its size and weight. Requires a T49 scope for precision aiming."
	icon_state = "tx55"
	item_state = "tx55"
	fire_sound = "gun_t12"
	dry_fire_sound = 'sound/weapons/guns/fire/m41a_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/t18_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/t18_reload.ogg'
	caliber = CALIBER_10X24_CASELESS //codex
	max_shells = 36 //codex
	wield_delay = 1 SECONDS
	default_ammo_type = /obj/item/ammo_magazine/rifle/tx55
	allowed_ammo_types = list(/obj/item/ammo_magazine/rifle/tx55)
	attachable_allowed = list(
		/obj/item/attachable/scope/optical,
		/obj/item/weapon/gun/rifle/tx54/mini,
		/obj/item/attachable/reddot,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/gyro,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/bipod,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/suppressor,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/compensator,
		/obj/item/attachable/scope,
		/obj/item/attachable/scope/marine,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/motiondetector,
	)

	flags_gun_features = GUN_AMMO_COUNTER
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_AUTOBURST)
	starting_attachment_types = list(
		/obj/item/weapon/gun/rifle/tx54/mini,
		/obj/item/attachable/scope/optical,
	)
	attachable_offset = list("muzzle_x" = 31, "muzzle_y" = 17,"rail_x" = 13, "rail_y" = 22, "under_x" = 21, "under_y" = 14, "stock_x" = -1, "stock_y" = 17)

	aim_fire_delay = 0.1 SECONDS
	aim_speed_modifier = 2
	fire_delay = 0.2 SECONDS
	burst_delay = 0.15 SECONDS
	extra_delay = 0.05 SECONDS
	accuracy_mult_unwielded = 0.5
	scatter = 1
	scatter_unwielded = 15
	burst_scatter_mult = 2
	aim_slowdown = 1
	movement_acc_penalty_mult = 6

/obj/item/weapon/gun/rifle/tx55/freelancer
	starting_attachment_types = list(
		/obj/item/weapon/gun/rifle/tx54/mini,
		/obj/item/attachable/scope/optical,
		/obj/item/attachable/compensator,
		/obj/item/attachable/gyro,
	)

/obj/item/weapon/gun/rifle/tx55/combat_patrol //no scope for HvH
	starting_attachment_types = list(
		/obj/item/weapon/gun/rifle/tx54/mini,
		/obj/item/attachable/motiondetector,
		/obj/item/attachable/compensator,
		/obj/item/attachable/verticalgrip,
	)

//-------------------------------------------------------
// V-31 SOM rifle

/obj/item/weapon/gun/rifle/som
	name = "\improper V-31 assault rifle"
	desc = "The V-31 was the primary rifle of the Sons of Mars until the introduction of more advanced energy weapons. Nevertheless the V-31 continues to see common use due to it's comparative ease of production and maintenance, and due to the inbuilt low velocity railgun designed for so called 'micro' grenades. Has good handling due to its compact bullpup design, and is generally effective at all ranges. Uses 10x25mm caseless ammunition."
	icon_state = "v31"
	icon = 'icons/Marine/gun64.dmi'
	item_state = "v31"
	fire_sound = 'sound/weapons/guns/fire/som_rifle.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/m41a_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/t18_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/t18_reload.ogg'
	caliber = CALIBER_10X24_CASELESS
	max_shells = 50
	default_ammo_type = /obj/item/ammo_magazine/rifle/som
	allowed_ammo_types = list(/obj/item/ammo_magazine/rifle/som, /obj/item/ammo_magazine/rifle/som/ap, /obj/item/ammo_magazine/rifle/som/incendiary)
	attachable_allowed = list(
		/obj/item/weapon/gun/shotgun/micro_grenade,
		/obj/item/attachable/reddot,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/gyro,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/bipod,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/suppressor,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/compensator,
		/obj/item/attachable/scope,
		/obj/item/attachable/scope/marine,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/motiondetector,
	)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_AUTOBURST)
	starting_attachment_types = list(
		/obj/item/weapon/gun/shotgun/micro_grenade,
	)
	attachable_offset = list("muzzle_x" = 45, "muzzle_y" = 16,"rail_x" = 23, "rail_y" = 24, "under_x" = 33, "under_y" = 11, "stock_x" = -1, "stock_y" = 17)
	actions_types = list(/datum/action/item_action/aim_mode)

	wield_delay = 0.6 SECONDS

	aim_fire_delay = 0.1 SECONDS
	aim_speed_modifier = 2

	fire_delay = 0.2 SECONDS
	aim_slowdown = 0.35

	accuracy_mult = 1.05
	accuracy_mult_unwielded = 0.55
	scatter = 1
	scatter_unwielded = 15

	burst_amount = 3
	burst_delay = 0.1 SECONDS
	extra_delay = 0.1 SECONDS
	autoburst_delay = 0.3 SECONDS

	damage_falloff_mult = 0.7

/obj/item/weapon/gun/rifle/som/standard
	starting_attachment_types = list(
		/obj/item/weapon/gun/shotgun/micro_grenade,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/reddot,
	)

/obj/item/weapon/gun/rifle/som/veteran
	default_ammo_type = /obj/item/ammo_magazine/rifle/som/ap
	starting_attachment_types = list(
		/obj/item/weapon/gun/shotgun/micro_grenade,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/reddot,
	)

/obj/item/weapon/gun/rifle/som/mag_harness
	starting_attachment_types = list(
		/obj/item/weapon/gun/shotgun/micro_grenade,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/extended_barrel,
	)

/obj/item/weapon/gun/rifle/som/basic //export model
	starting_attachment_types = list(
		/obj/item/weapon/gun/shotgun/micro_grenade,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/bayonet,
	)
