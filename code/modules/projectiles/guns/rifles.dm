//-------------------------------------------------------

/obj/item/weapon/gun/rifle
	reload_sound = 'sound/weapons/guns/interact/rifle_reload.ogg'
	cocked_sound = 'sound/weapons/guns/interact/cocked.ogg'
	flags_equip_slot = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	force = 15
	flags_gun_features = GUN_CAN_POINTBLANK||GUN_AMMO_COUNTER|GUN_SMOKE_PARTICLES
	load_method = MAGAZINE //codex
	aim_slowdown = 0.35
	wield_delay = 0.6 SECONDS
	gun_skill_category = SKILL_RIFLES

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
	desc = "The Keckler and Hoch AR-18 carbine is one of the standard rifles used by the TerraGov Marine Corps. It's commonly used by people who prefer greater mobility in combat, like scouts and other light infantry. Uses 10x24mm caseless ammunition."
	icon_state = GUN_ICONSTATE_LOADED
	item_state = GUN_ICONSTATE_LOADED
	fire_sound = 'sound/weapons/guns/fire/tgmc/kinetic/gun_ar18.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/m41a_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/t18_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/t18_reload.ogg'
	caliber = CALIBER_10X24_CASELESS //codex
	max_shells = 36 //codex
	force = 20
	default_ammo_type = /obj/item/ammo_magazine/rifle/standard_carbine
	allowed_ammo_types = list(/obj/item/ammo_magazine/rifle/standard_carbine)
	greyscale_config = /datum/greyscale_config/gun
	colorable_allowed = PRESET_COLORS_ALLOWED
	item_icons = list(
		slot_l_hand_str = /datum/greyscale_config/gun_inhand/t18,
		slot_r_hand_str = /datum/greyscale_config/gun_inhand/r_hand/t18,
		slot_back_str = /datum/greyscale_config/worn_gun/t18,
		slot_s_store_str = /datum/greyscale_config/worn_gun/suit/t18,
	)
	attachable_allowed = list(
		/obj/item/attachable/stock/t18stock,
		/obj/item/attachable/reddot,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/angledgrip,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/gyro,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/flashlight/under,
		/obj/item/attachable/foldable/bipod,
		/obj/item/attachable/burstfire_assembly,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/suppressor,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/bayonetknife/som,
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

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_SMOKE_PARTICLES
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOBURST)
	starting_attachment_types = list(/obj/item/attachable/stock/t18stock)
	attachable_offset = list("muzzle_x" = 30, "muzzle_y" = 16,"rail_x" = 5, "rail_y" = 19, "under_x" = 18, "under_y" = 14, "stock_x" = 0, "stock_y" = 13)
	actions_types = list(/datum/action/item_action/aim_mode)
	aim_fire_delay = 0.1 SECONDS
	aim_speed_modifier = 2

	fire_delay = 0.2 SECONDS
	burst_delay = 0.1 SECONDS
	extra_delay = 0.1 SECONDS
	accuracy_mult = 1.05
	scatter = 0
	burst_amount = 4
	aim_slowdown = 0.30
	damage_falloff_mult = 0.9
	movement_acc_penalty_mult = 4

/obj/item/weapon/gun/rifle/standard_carbine/pointman
	starting_attachment_types = list(/obj/item/attachable/stock/t18stock, /obj/item/attachable/lasersight, /obj/item/attachable/flashlight)

/obj/item/weapon/gun/rifle/standard_carbine/standard
	starting_attachment_types = list(/obj/item/attachable/stock/t18stock, /obj/item/weapon/gun/grenade_launcher/underslung, /obj/item/attachable/reddot, /obj/item/attachable/extended_barrel)

/obj/item/weapon/gun/rifle/standard_carbine/scout
	starting_attachment_types = list(/obj/item/attachable/stock/t18stock, /obj/item/weapon/gun/grenade_launcher/underslung, /obj/item/attachable/motiondetector, /obj/item/attachable/extended_barrel)

/obj/item/weapon/gun/rifle/standard_carbine/engineer
	starting_attachment_types = list(/obj/item/attachable/stock/t18stock, /obj/item/attachable/magnetic_harness, /obj/item/attachable/lasersight)

/obj/item/weapon/gun/rifle/standard_carbine/plasma_pistol
	starting_attachment_types = list(/obj/item/attachable/stock/t18stock, /obj/item/weapon/gun/pistol/plasma_pistol, /obj/item/attachable/motiondetector, /obj/item/attachable/compensator)

//-------------------------------------------------------
//AR-12 Assault Rifle

/obj/item/weapon/gun/rifle/standard_assaultrifle
	name = "\improper AR-12 K&H assault rifle"
	desc = "The Keckler and Hoch AR-12 assault rifle used to be the TerraGov Marine Corps standard issue rifle before the AR-18 carbine replaced it. It is, however, still used widely despite that. The gun itself is very good at being used in most situations however it suffers in engagements at close quarters and is relatively hard to shoulder than some others. It uses 10x24mm caseless ammunition."
	icon_state = GUN_ICONSTATE_LOADED
	item_state = GUN_ICONSTATE_LOADED
	fire_sound = "gun_ar12"
	dry_fire_sound = 'sound/weapons/guns/fire/m41a_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/t18_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/t18_reload.ogg'
	caliber = CALIBER_10X24_CASELESS //codex
	max_shells = 50 //codex
	force = 20
	default_ammo_type = /obj/item/ammo_magazine/rifle/standard_assaultrifle
	allowed_ammo_types = list(/obj/item/ammo_magazine/rifle/standard_assaultrifle)
	greyscale_config = /datum/greyscale_config/gun/gun64
	colorable_allowed = PRESET_COLORS_ALLOWED
	item_icons = list(
		slot_l_hand_str = /datum/greyscale_config/gun_inhand,
		slot_r_hand_str = /datum/greyscale_config/gun_inhand/r_hand,
		slot_back_str = /datum/greyscale_config/worn_gun,
		slot_s_store_str = /datum/greyscale_config/worn_gun/suit,
	)
	attachable_allowed = list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/gyro,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/flashlight/under,
		/obj/item/attachable/foldable/bipod,
		/obj/item/attachable/burstfire_assembly,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/suppressor,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/bayonetknife/som,
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

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_SMOKE_PARTICLES
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOBURST)
	attachable_offset = list("muzzle_x" = 46, "muzzle_y" = 17,"rail_x" = 16, "rail_y" = 23, "under_x" = 33, "under_y" = 13, "stock_x" = 0, "stock_y" = 13)
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
	desc = "The San Cristo Arms DMR-37 is the TerraGov Marine Corps designated marksman rifle. It is rather well-known for it's very consistent target placement at longer than usual range, it however lacks a burst fire mode or an automatic mode. It is mostly used by people who prefer to do more careful shooting than most. Uses 10x27mm caseless caliber."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = GUN_ICONSTATE_LOADED
	item_state = GUN_ICONSTATE_LOADED
	greyscale_config = /datum/greyscale_config/gun/gun64/t37
	colorable_allowed = PRESET_COLORS_ALLOWED
	item_icons = list(
		slot_l_hand_str = /datum/greyscale_config/gun_inhand/t37,
		slot_r_hand_str = /datum/greyscale_config/gun_inhand/r_hand/t37,
		slot_back_str = /datum/greyscale_config/worn_gun/t37,
		slot_s_store_str = /datum/greyscale_config/worn_gun/suit/t37,
	)
	inhand_x_dimension = 64
	inhand_y_dimension = 32

	muzzleflash_iconstate = "muzzle_flash_medium"
	fire_sound = 'sound/weapons/guns/fire/tgmc/kinetic/gun_dmr37.ogg'
	fire_rattle = 'sound/weapons/guns/fire/tgmc/kinetic/gun_dmr37_low.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/m41a_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/m41a_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/m41a_reload.ogg'
	caliber = CALIBER_10x27_CASELESS //codex
	aim_slowdown = 0.75
	wield_delay = 0.8 SECONDS
	force = 20
	max_shells = 20 //codex
	default_ammo_type = /obj/item/ammo_magazine/rifle/standard_dmr
	allowed_ammo_types = list(/obj/item/ammo_magazine/rifle/standard_dmr)
	attachable_allowed = list(
		/obj/item/attachable/suppressor,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/bayonetknife/som,
		/obj/item/attachable/compensator,
		/obj/item/attachable/reddot,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/angledgrip,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/flashlight/under,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/foldable/bipod,
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

	flags_gun_features = GUN_AMMO_COUNTER|GUN_CAN_POINTBLANK|GUN_SMOKE_PARTICLES
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)
	starting_attachment_types = list(/obj/item/attachable/scope/mini/dmr)
	attachable_offset = list("muzzle_x" = 50, "muzzle_y" = 20,"rail_x" = 21, "rail_y" = 22, "under_x" = 31, "under_y" = 15, "stock_x" = 14, "stock_y" = 10)
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
	desc = "The San Cristo Arms BR-64 is the TerraGov Marine Corps main battle rifle. It is known for its consistent ability to perform well at most ranges, and medium range stopping power with bursts. It is mostly used by people who prefer a bigger round than the average. Uses 10x26.5smm caseless caliber."
	icon_state = "t64"
	item_state = "t64"
	icon = 'icons/Marine/gun64.dmi'
	item_icons = list(
		slot_l_hand_str = 'icons/mob/items_lefthand_64.dmi',
		slot_r_hand_str = 'icons/mob/items_righthand_64.dmi',
	)
	inhand_x_dimension = 64
	inhand_y_dimension = 32

	muzzleflash_iconstate = "muzzle_flash_medium"
	fire_sound = 'sound/weapons/guns/fire/tgmc/kinetic/gun_br64.ogg'
	fire_rattle = 'sound/weapons/guns/fire/tgmc/kinetic/gun_br64_low.ogg'
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
		/obj/item/attachable/stock/t64stock,
		/obj/item/weapon/gun/grenade_launcher/underslung/battle_rifle,
		/obj/item/attachable/suppressor,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/bayonetknife/som,
		/obj/item/attachable/compensator,
		/obj/item/attachable/reddot,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/angledgrip,
		/obj/item/attachable/flashlight/under,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/foldable/bipod,
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

	flags_gun_features = GUN_AMMO_COUNTER|GUN_CAN_POINTBLANK|GUN_SMOKE_PARTICLES
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOBURST)
	starting_attachment_types = list(/obj/item/attachable/stock/t64stock, /obj/item/weapon/gun/grenade_launcher/underslung/battle_rifle, /obj/item/attachable/scope/mini)
	attachable_offset = list("muzzle_x" = 44, "muzzle_y" = 19,"rail_x" = 18, "rail_y" = 23, "under_x" = 33, "under_y" = 13, "stock_x" = 11, "stock_y" = 14)
	actions_types = list(/datum/action/item_action/aim_mode)
	aim_fire_delay = 0.2 SECONDS
	aim_speed_modifier = 3

	fire_delay = 0.3 SECONDS
	burst_amount = 3
	burst_delay = 0.10 SECONDS
	extra_delay = 0.25 SECONDS
	accuracy_mult = 0.9
	scatter = 0

/obj/item/weapon/gun/rifle/standard_br/standard
	starting_attachment_types = list(/obj/item/attachable/stock/t64stock, /obj/item/weapon/gun/grenade_launcher/underslung/battle_rifle, /obj/item/attachable/reddot, /obj/item/attachable/extended_barrel)

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
		/obj/item/attachable/bayonetknife/som,
		/obj/item/attachable/compensator,
		/obj/item/attachable/reddot,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/angledgrip,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/gyro,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/flashlight/under,
		/obj/item/attachable/foldable/bipod,
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

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_SMOKE_PARTICLES
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOBURST)
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
		/obj/item/attachable/bayonetknife/som,
		/obj/item/attachable/reddot,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/angledgrip,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/gyro,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/flashlight/under,
		/obj/item/attachable/foldable/bipod,
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
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)


	burst_amount = 1
	burst_delay = 0.15 SECONDS
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
		/obj/item/attachable/bayonetknife/som,
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
		/obj/item/attachable/stock/m41a,
		/obj/item/weapon/gun/grenade_launcher/underslung/invisible,
		/obj/item/attachable/shoulder_mount,
	)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_SMOKE_PARTICLES
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOBURST)
	starting_attachment_types = list(/obj/item/attachable/stock/m41a, /obj/item/weapon/gun/grenade_launcher/underslung/invisible)
	attachable_offset = list("muzzle_x" = 41, "muzzle_y" = 19,"rail_x" = 12, "rail_y" = 24, "under_x" = 24, "under_y" = 13, "stock_x" = 22, "stock_y" = 16)

	burst_amount = 4
	burst_delay = 0.15 SECONDS
	scatter = 0
	fire_delay = 0.2 SECONDS



//-------------------------------------------------------

/obj/item/weapon/gun/rifle/mpi_km
	name = "\improper MPi-KM assault rifle"
	desc = "A cheap and robust rifle, sometimes better known as an 'AK'. Chambers 7.62x39mm. Despite lacking attachment points beyond its underbarrel, remains a popular product on the black market with its cheap cost and higher than usual caliber rounds."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "ak47"
	item_state = "ak47"
	caliber = CALIBER_762X39 //codex
	muzzleflash_iconstate = "muzzle_flash_medium"
	max_shells = 40 //codex
	fire_sound = 'sound/weapons/guns/fire/ak47.ogg'
	unload_sound = 'sound/weapons/guns/interact/ak47_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/ak47_reload.ogg'
	cocked_sound = 'sound/weapons/guns/interact/ak47_cocked.ogg'
	default_ammo_type = /obj/item/ammo_magazine/rifle/mpi_km/plum
	allowed_ammo_types = list(
		/obj/item/ammo_magazine/rifle/mpi_km,
		/obj/item/ammo_magazine/rifle/mpi_km/plum,
		/obj/item/ammo_magazine/rifle/mpi_km/black,
		/obj/item/ammo_magazine/rifle/mpi_km/carbine,
		/obj/item/ammo_magazine/rifle/mpi_km/carbine/plum,
		/obj/item/ammo_magazine/rifle/mpi_km/carbine/black,
		/obj/item/ammo_magazine/rifle/mpi_km/extended,
	)
	aim_slowdown = 0.5
	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/bayonetknife/som,
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

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_SMOKE_PARTICLES
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)
	attachable_offset = list("muzzle_x" = 35, "muzzle_y" = 18,"rail_x" = 6, "rail_y" = 20, "under_x" = 19, "under_y" = 14, "stock_x" = 5, "stock_y" = 12)
	starting_attachment_types = list(/obj/item/attachable/stock/mpi_km)
	force = 20

	burst_amount = 1
	fire_delay = 0.25 SECONDS
	scatter = 0
	wield_delay = 0.7 SECONDS

	placed_overlay_iconstate = "ak47"

/obj/item/weapon/gun/rifle/mpi_km/standard
	starting_attachment_types = list(
		/obj/item/attachable/stock/mpi_km,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/bayonet,
	)

/obj/item/weapon/gun/rifle/mpi_km/grenadier
	desc = "A cheap and robust rifle, sometimes better known as an 'AK'. Chambers 7.62x39mm. This one has a built in underbarrel grenade launcher and looks very old, but well looked after."
	starting_attachment_types = list(
		/obj/item/attachable/stock/mpi_km,
		/obj/item/weapon/gun/grenade_launcher/underslung/mpi,
		/obj/item/attachable/magnetic_harness,
	)

/obj/item/weapon/gun/rifle/mpi_km/black
	name = "\improper MPi-KM assault rifle"
	desc = "A cheap and robust rifle manufactured by the SOM, famed for its reliability and stopping power. Sometimes better known as an 'AK', it chambers 7.62x39mm."
	icon_state = "ak47_black"
	item_state = "ak47_black"
	default_ammo_type = /obj/item/ammo_magazine/rifle/mpi_km/black
	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/bayonetknife/som,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/buildasentry,
		/obj/item/attachable/stock/mpi_km/black,
		/obj/item/attachable/shoulder_mount,
		/obj/item/attachable/verticalgrip,
		/obj/item/weapon/gun/pistol/plasma_pistol,
		/obj/item/weapon/gun/shotgun/combat/masterkey,
		/obj/item/weapon/gun/flamer/mini_flamer,
		/obj/item/weapon/gun/grenade_launcher/underslung,
		/obj/item/weapon/gun/rifle/pepperball/pepperball_mini,
		/obj/item/weapon/gun/grenade_launcher/underslung/mpi, //alt sprite, unremovable
		/obj/item/attachable/reddot,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/flashlight/under,
	)
	starting_attachment_types = list(/obj/item/attachable/stock/mpi_km/black)

/obj/item/weapon/gun/rifle/mpi_km/black/magharness
	starting_attachment_types = list(
		/obj/item/attachable/stock/mpi_km/black,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/lasersight,
	)

/obj/item/weapon/gun/rifle/mpi_km/black/grenadier
	desc = "A cheap and robust rifle manufactured by the SOM, famed for its reliability and stopping power. Sometimes better known as an 'AK', it chambers 7.62x39mm. This one has a built in underbarrel grenade launcher."
	starting_attachment_types = list(
		/obj/item/attachable/stock/mpi_km/black,
		/obj/item/weapon/gun/grenade_launcher/underslung/mpi,
		/obj/item/attachable/reddot,
	)

// RPD

/obj/item/weapon/gun/rifle/lmg_d
	name = "\improper lMG-D light machinegun"
	desc = "A cheap and robust machinegun, sometimes better known as an 'RPD'. Chambers 7.62x39mm. Despite lacking attachment points beyond its underbarrel, remains a popular product on the black market with its cheap cost, high capacity and higher than usual caliber rounds."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "rpd"
	item_state = "rpd"
	fire_animation = "rpd_fire"
	caliber = CALIBER_762X39 //codex
	muzzleflash_iconstate = "muzzle_flash_medium"
	max_shells = 100  //codex
	wield_delay = 1.2 SECONDS
	aim_slowdown = 0.95
	fire_sound = 'sound/weapons/guns/fire/ak47.ogg'
	unload_sound = 'sound/weapons/guns/interact/ak47_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/ak47_reload.ogg'
	cocked_sound = 'sound/weapons/guns/interact/ak47_cocked.ogg'
	default_ammo_type = /obj/item/ammo_magazine/rifle/lmg_d
	allowed_ammo_types = list(/obj/item/ammo_magazine/rifle/lmg_d)

	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/bayonetknife/som,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/buildasentry,
		/obj/item/attachable/stock/lmg_d,
		/obj/item/attachable/shoulder_mount,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/foldable/bipod,
		/obj/item/weapon/gun/pistol/plasma_pistol,
		/obj/item/weapon/gun/shotgun/combat/masterkey,
		/obj/item/weapon/gun/flamer/mini_flamer,
		/obj/item/weapon/gun/grenade_launcher/underslung,
		/obj/item/weapon/gun/rifle/pepperball/pepperball_mini,
		/obj/item/weapon/gun/grenade_launcher/underslung/mpi,
		/obj/item/attachable/reddot,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/flashlight/under,
	)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_SMOKE_PARTICLES
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)

	attachable_offset = list("muzzle_x" = 35, "muzzle_y" = 18,"rail_x" = 6, "rail_y" = 20, "under_x" = 19, "under_y" = 14, "stock_x" = 6, "stock_y" = 14)
	starting_attachment_types = list(/obj/item/attachable/stock/lmg_d)

	fire_delay = 0.25 SECONDS
	scatter = 2
	burst_amount = 1
	movement_acc_penalty_mult = 6

/obj/item/weapon/gun/rifle/lmg_d/magharness
	starting_attachment_types = list(
		/obj/item/attachable/stock/lmg_d,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/foldable/bipod,
	)

//-------------------------------------------------------
//DP-27

/obj/item/weapon/gun/rifle/dpm
	name = "\improper Degtyaryov 'RP' machine gun"
	desc = "A cheap and robust machine gun seen commonly in the fringes of the bubble. Fires high caliber rounds to accommodate for its sluggish rate of fire, it is generally found being called 'The Record Player' due to the resemblance. Fires 7.62x39mm AP rounds."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "dp27"
	item_state = "dp27"
	max_shells = 47 //codex
	caliber = CALIBER_762X39 //codex
	fire_sound = "svd_fire"
	dry_fire_sound = 'sound/weapons/guns/fire/dpm.ogg'
	unload_sound = 'sound/weapons/guns/interact/dpm_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/dpm_reload.ogg'
	default_ammo_type = /obj/item/ammo_magazine/rifle/dpm
	allowed_ammo_types = list(/obj/item/ammo_magazine/rifle/dpm)
	attachable_allowed = list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/stock/dpm,
	)

	flags_gun_features = GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)
	attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 17,"rail_x" = 22, "rail_y" = 17, "under_x" = 32, "under_y" = 14, "stock_x" = 13, "stock_y" = 9)
	starting_attachment_types = list(/obj/item/attachable/stock/dpm)
	actions_types = list(/datum/action/item_action/aim_mode)
	aim_fire_delay = 0.25 SECONDS
	aim_speed_modifier = 0.75

	fire_delay = 0.45 SECONDS
	damage_mult = 2
	burst_amount = 1
	accuracy_mult = 1
	scatter = 2
	recoil = -1
	wield_delay = 0.9 SECONDS
	aim_slowdown = 0.85
	movement_acc_penalty_mult = 4

//-------------------------------------------------------
//M16 RIFLE

/obj/item/weapon/gun/rifle/m16
	name = "\improper FN M16A4 assault rifle"
	desc = "A light, versatile assault rifle with a 30 round magazine, chambered to fire the 5.56x45mm NATO cartridge. The 4th generation in the M16 platform, this FN variant has added automatic fire selection and retains relevance among mercenaries and militias thanks to its high customizability. It is incredibly good at rapid burst fire, but must be paced correctly."
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
		/obj/item/attachable/bayonetknife/som,
		/obj/item/attachable/reddot,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/angledgrip,
		/obj/item/attachable/gyro,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/flashlight/under,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/foldable/bipod,
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

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_SMOKE_PARTICLES
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_BURSTFIRE)
	attachable_offset = list("muzzle_x" = 47, "muzzle_y" = 19,"rail_x" = 18, "rail_y" = 24, "under_x" = 29, "under_y" = 15, "stock_x" = 19, "stock_y" = 13)
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

/obj/item/weapon/gun/rifle/m16/spec_op
	starting_attachment_types = list(/obj/item/attachable/magnetic_harness, /obj/item/attachable/suppressor, /obj/item/weapon/gun/shotgun/combat/masterkey)

//-------------------------------------------------------
//FAMAS rifle, based on the F1

/obj/item/weapon/gun/rifle/famas
	name = "\improper FAMAS assault rifle"
	desc = "A light, versatile fast firing assault rifle with a 24 round magazine and short range scope, chambered to fire the 5.56x45mm NATO cartridge within a short amount of time."
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
		/obj/item/attachable/bayonetknife/som,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/angledgrip,
		/obj/item/attachable/gyro,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/foldable/bipod,
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

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_SMOKE_PARTICLES
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOBURST)
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

	icon_state = GUN_ICONSTATE_LOADED
	item_state = GUN_ICONSTATE_LOADED
	item_icons = list(
		slot_l_hand_str = /datum/greyscale_config/gun_inhand/t42,
		slot_r_hand_str = /datum/greyscale_config/gun_inhand/r_hand/t42,
		slot_back_str = /datum/greyscale_config/worn_gun/t42,
		slot_s_store_str = /datum/greyscale_config/worn_gun/suit/t42,
	)
	inhand_x_dimension = 64
	inhand_y_dimension = 32

	caliber = CALIBER_10X24_CASELESS //codex
	max_shells = 120 //codex
	force = 30
	aim_slowdown = 0.8
	wield_delay = 1 SECONDS
	fire_sound = 'sound/weapons/guns/fire/tgmc/kinetic/gun_mg42.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/m41a_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/T42_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/T42_reload.ogg'
	default_ammo_type = /obj/item/ammo_magazine/standard_lmg
	allowed_ammo_types = list(/obj/item/ammo_magazine/standard_lmg)
	greyscale_config = /datum/greyscale_config/gun/gun64/t42
	colorable_allowed = PRESET_COLORS_ALLOWED
	attachable_allowed = list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/flashlight/under,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/foldable/bipod,
		/obj/item/attachable/burstfire_assembly,
		/obj/item/attachable/angledgrip,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/suppressor,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/bayonetknife/som,
		/obj/item/attachable/scope,
		/obj/item/attachable/scope/marine,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/compensator,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/motiondetector,
		/obj/item/weapon/gun/pistol/plasma_pistol,
		/obj/item/weapon/gun/shotgun/combat/masterkey,
		/obj/item/weapon/gun/flamer/mini_flamer,
		/obj/item/weapon/gun/grenade_launcher/underslung,
		/obj/item/weapon/gun/rifle/pepperball/pepperball_mini,
	)

	flags_gun_features = GUN_AMMO_COUNTER|GUN_SMOKE_PARTICLES
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_AUTOBURST)
	gun_skill_category = SKILL_HEAVY_WEAPONS
	attachable_offset = list("muzzle_x" = 30, "muzzle_y" = 17,"rail_x" = 4, "rail_y" = 20, "under_x" = 16, "under_y" = 14, "stock_x" = 0, "stock_y" = 13)
	actions_types = list(/datum/action/item_action/aim_mode)
	aim_fire_delay = 0.1 SECONDS
	aim_speed_modifier = 2

	fire_delay = 0.2 SECONDS
	burst_delay = 0.15 SECONDS
	extra_delay = 0.05 SECONDS
	accuracy_mult = 1.1
	accuracy_mult_unwielded = 0.5
	scatter = 2
	scatter_unwielded = 80
	movement_acc_penalty_mult = 6

//-------------------------------------------------------
//MG-60 General Purpose Machine Gun

/obj/item/weapon/gun/rifle/standard_gpmg
	name = "\improper MG-60 Raummetall general purpose machine gun"
	desc = "The Raummetall MG-60 general purpose machinegun is the TGMC's current standard GPMG. Though usually seen mounted on vehicles, it is sometimes used by infantry to hold chokepoints or suppress enemies, or in rare cases for marching fire. It uses 10x26mm boxes."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = GUN_ICONSTATE_LOADED
	item_state = GUN_ICONSTATE_LOADED
	fire_animation = "loaded_fire"
	greyscale_config = /datum/greyscale_config/gun/gun64/t60
	colorable_allowed = PRESET_COLORS_ALLOWED
	item_icons = list(
		slot_l_hand_str = /datum/greyscale_config/gun_inhand/t60,
		slot_r_hand_str = /datum/greyscale_config/gun_inhand/r_hand/t60,
		slot_back_str = /datum/greyscale_config/worn_gun/t60,
		slot_s_store_str = /datum/greyscale_config/worn_gun/suit/t60,
	)
	inhand_x_dimension = 64
	inhand_y_dimension = 32

	caliber = CALIBER_10x26_CASELESS //codex
	max_shells = 200 //codex
	force = 35
	aim_slowdown = 1.2
	wield_delay = 1.5 SECONDS
	fire_sound = 'sound/weapons/guns/fire/tgmc/kinetic/gun_mg60.ogg'
	fire_rattle = 'sound/weapons/guns/fire/tgmc/kinetic/gun_mg60_low.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/m41a_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/T42_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/T42_reload.ogg'
	default_ammo_type = /obj/item/ammo_magazine/standard_gpmg
	allowed_ammo_types = list(/obj/item/ammo_magazine/standard_gpmg)
	attachable_allowed = list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/flashlight/under,
		/obj/item/attachable/foldable/bipod,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/bayonetknife/som,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/stock/t60stock,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/motiondetector,
		/obj/item/attachable/buildasentry,
		/obj/item/attachable/shoulder_mount,
	)

	flags_gun_features = GUN_AMMO_COUNTER|GUN_WIELDED_FIRING_ONLY|GUN_SMOKE_PARTICLES
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)
	starting_attachment_types = list(/obj/item/attachable/stock/t60stock)
	gun_skill_category = SKILL_HEAVY_WEAPONS
	attachable_offset = list("muzzle_x" = 42, "muzzle_y" = 21,"rail_x" = 6, "rail_y" = 23, "under_x" = 26, "under_y" = 15, "stock_x" = 8, "stock_y" = 13)
	actions_types = list(/datum/action/item_action/aim_mode)
	aim_fire_delay = 0.15 SECONDS
	aim_speed_modifier = 5.3

	fire_delay = 0.15 SECONDS
	damage_falloff_mult = 0.5
	burst_amount = 1
	accuracy_mult = 0.85
	accuracy_mult_unwielded = 0.4
	scatter = 7
	scatter_unwielded = 45
	movement_acc_penalty_mult = 7.25

	placed_overlay_iconstate = "lmg"

/obj/item/weapon/gun/rifle/standard_lmg/autorifleman
	starting_attachment_types = list(/obj/item/attachable/verticalgrip, /obj/item/attachable/reddot)

/obj/item/weapon/gun/rifle/standard_gpmg/machinegunner
	starting_attachment_types = list(/obj/item/attachable/stock/t60stock, /obj/item/attachable/foldable/bipod, /obj/item/attachable/reddot, /obj/item/attachable/extended_barrel)

//-------------------------------------------------------
//M41AE2 Heavy Pulse Rifle

/obj/item/weapon/gun/rifle/m412l1_hpr
	name = "\improper PR-412L1 heavy pulse rifle"
	desc = "A large weapon capable of laying down supressing fire, based on the PR-412 pulse rifle platform. Effective in burst fire. Uses 10x24mm caseless ammunition."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "m412l1"
	item_state = "m412l1"
	caliber = CALIBER_10X24_CASELESS //codex
	max_shells = 200 //codex
	aim_slowdown = 0.8
	wield_delay = 2 SECONDS
	fire_sound = 'sound/weapons/guns/fire/hmg.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/m41a_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/m41a_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/m41a_reload.ogg'
	default_ammo_type = /obj/item/ammo_magazine/m412l1_hpr
	allowed_ammo_types = list(/obj/item/ammo_magazine/m412l1_hpr)
	attachable_allowed = list(
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/reddot,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/flashlight/under,
		/obj/item/attachable/angledgrip,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/foldable/bipod,
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
		/obj/item/attachable/shoulder_mount,
	)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_WIELDED_FIRING_ONLY|GUN_SMOKE_PARTICLES
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOBURST)
	gun_skill_category = SKILL_HEAVY_WEAPONS
	attachable_offset = list("muzzle_x" = 42, "muzzle_y" = 19,"rail_x" = 17, "rail_y" = 21, "under_x" = 31, "under_y" = 15, "stock_x" = 18, "stock_y" = 15)
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
		/obj/item/attachable/compensator,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/foldable/bipod,
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
		/obj/item/attachable/foldable/bipod,
		/obj/item/attachable/burstfire_assembly,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/suppressor,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/bayonetknife/som,
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

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_SMOKE_PARTICLES
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
		/obj/item/attachable/bayonetknife/som,
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
//SH-15 AUTOMATIC SHOTGUN

/obj/item/weapon/gun/rifle/standard_autoshotgun
	name = "\improper Zauer SH-15 automatic shotgun"
	desc = "The Zauer SH-15 Automatic Assault Shotgun, this is a Terran Armories variant. Another iteration of the ZX series of firearms though it has been since regulated as part of the TGMC arsenal, hence the SH designation. It took over the various shotgun models as the semi-automatic shotgun provided to the TGMC. It is rifled, and loads primarily longer ranged munitions, being incompatible with buckshot shells. Takes 12-round 16 gauge magazines."
	icon_state = GUN_ICONSTATE_LOADED
	item_state = GUN_ICONSTATE_LOADED
	fire_sound = 'sound/weapons/guns/fire/tgmc/kinetic/gun_sh15.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/shotgun_empty.ogg'
	caliber = CALIBER_16G //codex
	max_shells = 12 //codex
	force = 20
	default_ammo_type = /obj/item/ammo_magazine/rifle/tx15_slug
	greyscale_config = /datum/greyscale_config/gun/tx15
	colorable_allowed = PRESET_COLORS_ALLOWED
	item_icons = list(
		slot_l_hand_str = /datum/greyscale_config/gun_inhand/tx15,
		slot_r_hand_str = /datum/greyscale_config/gun_inhand/r_hand/tx15,
		slot_back_str = /datum/greyscale_config/worn_gun/tx15,
		slot_s_store_str = /datum/greyscale_config/worn_gun/suit/tx15,
	)
	allowed_ammo_types = list(
		/obj/item/ammo_magazine/rifle/tx15_slug,
		/obj/item/ammo_magazine/rifle/tx15_flechette,
	)
	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/bayonetknife/som,
		/obj/item/attachable/reddot,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/angledgrip,
		/obj/item/attachable/gyro,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/stock/tx15,
		/obj/item/attachable/compensator,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/flashlight/under,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/motiondetector,
		/obj/item/weapon/gun/pistol/plasma_pistol,
		/obj/item/weapon/gun/flamer/mini_flamer,
		/obj/item/weapon/gun/grenade_launcher/underslung,
		/obj/item/weapon/gun/rifle/pepperball/pepperball_mini,
	)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_WIELDED_FIRING_ONLY|GUN_SMOKE_PARTICLES //Its a shotgun type weapon effectively, most shotgun type weapons shouldn't be able to point blank 1 handed.
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)
	starting_attachment_types = list(/obj/item/attachable/stock/tx15)
	attachable_offset = list("muzzle_x" = 30, "muzzle_y" = 16,"rail_x" = 12, "rail_y" = 17, "under_x" = 20, "under_y" = 13, "stock_x" = 26, "stock_y" = 13)
	gun_skill_category = SKILL_SHOTGUNS

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
	starting_attachment_types = list(/obj/item/attachable/stock/tx15, /obj/item/attachable/motiondetector, /obj/item/attachable/extended_barrel, /obj/item/weapon/gun/pistol/plasma_pistol)

//-------------------------------------------------------
//SG-29 Smart Machine Gun (It's more of a rifle than the SG.)

/obj/item/weapon/gun/rifle/standard_smartmachinegun
	name = "\improper SG-29 Raummetall-KT smart machine gun"
	desc = "The Raummetall-KT SG-29 is the TGMC's current standard IFF-capable medium machine gun. It's known for its ability to lay down heavy fire support very well. It is generally used when someone wants to hold a position or provide fire support. Requires special training and it cannot turn off IFF. It uses 10x26mm ammunition."
	icon_state = GUN_ICONSTATE_LOADED
	item_state = GUN_ICONSTATE_LOADED
	caliber = CALIBER_10x26_CASELESS //codex
	max_shells = 300 //codex
	force = 30
	aim_slowdown = 0.95
	wield_delay = 1.3 SECONDS
	fire_sound = "gun_smartgun"
	dry_fire_sound = 'sound/weapons/guns/fire/m41a_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/T42_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/T42_reload.ogg'
	greyscale_config = /datum/greyscale_config/gun/sg29
	colorable_allowed = PRESET_COLORS_ALLOWED
	item_icons = list(
		slot_l_hand_str = /datum/greyscale_config/gun_inhand/sg29,
		slot_r_hand_str = /datum/greyscale_config/gun_inhand/r_hand/sg29,
		slot_back_str = /datum/greyscale_config/worn_gun/sg29,
		slot_s_store_str = /datum/greyscale_config/worn_gun/suit/sg29,
	)
	default_ammo_type = /obj/item/ammo_magazine/standard_smartmachinegun
	allowed_ammo_types = list(/obj/item/ammo_magazine/standard_smartmachinegun)
	attachable_allowed = list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/foldable/bipod,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/flashlight/under,
		/obj/item/attachable/motiondetector,
		/obj/item/attachable/buildasentry,
		/obj/item/attachable/stock/sgstock,
		/obj/item/attachable/sgbarrel,
		/obj/item/attachable/shoulder_mount,
	)

	flags_gun_features = GUN_AMMO_COUNTER|GUN_WIELDED_FIRING_ONLY|GUN_IFF|GUN_SMOKE_PARTICLES
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)
	starting_attachment_types = list(/obj/item/attachable/stock/sgstock, /obj/item/attachable/sgbarrel)
	gun_skill_category = SKILL_SMARTGUN //Uses SG skill for the penalties.
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
	starting_attachment_types = list(/obj/item/attachable/stock/sgstock, /obj/item/attachable/sgbarrel, /obj/item/attachable/motiondetector, /obj/item/attachable/lasersight)

/obj/item/weapon/gun/rifle/standard_smartmachinegun/deathsquad
	starting_attachment_types = list(/obj/item/attachable/stock/sgstock, /obj/item/attachable/sgbarrel, /obj/item/attachable/magnetic_harness, /obj/item/attachable/lasersight)

/obj/item/weapon/gun/rifle/standard_smartmachinegun/patrol
	starting_attachment_types = list(/obj/item/attachable/stock/sgstock, /obj/item/attachable/sgbarrel, /obj/item/attachable/motiondetector, /obj/item/attachable/verticalgrip)

//-------------------------------------------------------
//SG Target Rifle, has underbarreled spotting rifle that applies effects.

/obj/item/weapon/gun/rifle/standard_smarttargetrifle
	name = "\improper SG-62 Kauser-KT smart target rifle"
	desc = "The Kauser-KT SG-62 is a IFF-capable rifle used by the TerraGov Marine Corps, coupled with a spotting rifle that is also IFF capable of applying various bullets with specialized ordnance, this is a gun with many answers to many situations... if you have the right ammo loaded. Requires special training and it cannot turn off IFF. It uses high velocity 10x27mm for the rifle and 12x66mm ammunition for the underslung rifle."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "sg62"
	item_state = "sg62"
	caliber = CALIBER_10x27_CASELESS //codex
	max_shells = 40 //codex
	aim_slowdown = 0.85
	wield_delay = 0.65 SECONDS
	fire_sound =  'sound/weapons/guns/fire/t62.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/m41a_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/T42_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/T42_reload.ogg'
	default_ammo_type = /obj/item/ammo_magazine/rifle/standard_smarttargetrifle
	allowed_ammo_types = list(/obj/item/ammo_magazine/rifle/standard_smarttargetrifle)
	attachable_allowed = list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/scope/marine,
		/obj/item/weapon/gun/rifle/standard_spottingrifle,
		/obj/item/attachable/stock/strstock,
		/obj/item/attachable/motiondetector,
		/obj/item/attachable/buildasentry,
		/obj/item/attachable/shoulder_mount,
	)

	flags_gun_features = GUN_AMMO_COUNTER|GUN_WIELDED_FIRING_ONLY|GUN_IFF|GUN_SMOKE_PARTICLES
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)
	gun_skill_category = SKILL_SMARTGUN //Uses SG skill for the penalties.
	attachable_offset = list("muzzle_x" = 12, "muzzle_y" = 22, "rail_x" = 15, "rail_y" = 22, "under_x" = 28, "under_y" = 16, "stock_x" = 12, "stock_y" = 14)
	starting_attachment_types = list(/obj/item/weapon/gun/rifle/standard_spottingrifle, /obj/item/attachable/stock/strstock)

	fire_delay = 0.5 SECONDS
	burst_amount = 0
	accuracy_mult_unwielded = 0.4
	accuracy_mult = 1.1
	scatter = 0
	scatter_unwielded = 20
	movement_acc_penalty_mult = 8

	placed_overlay_iconstate = "smartgun"

/obj/item/weapon/gun/rifle/standard_smarttargetrifle/motion
	starting_attachment_types = list(/obj/item/weapon/gun/rifle/standard_spottingrifle, /obj/item/attachable/stock/strstock, /obj/item/attachable/motiondetector)

/obj/item/weapon/gun/rifle/standard_spottingrifle
	name = "SG-153 spotting rifle"
	desc = "An underslung spotting rifle, generally found ontop of another gun."
	icon_state = "sg153"
	icon = 'icons/Marine/gun64.dmi'
	fire_sound =  'sound/weapons/guns/fire/spottingrifle.ogg'
	caliber = CALIBER_12x7
	slot = ATTACHMENT_SLOT_UNDER
	max_shells = 5
	default_ammo_type =/obj/item/ammo_magazine/rifle/standard_spottingrifle
	allowed_ammo_types = list(
		/obj/item/ammo_magazine/rifle/standard_spottingrifle,
		/obj/item/ammo_magazine/rifle/standard_spottingrifle/highimpact,
		/obj/item/ammo_magazine/rifle/standard_spottingrifle/heavyrubber,
		/obj/item/ammo_magazine/rifle/standard_spottingrifle/plasmaloss,
		/obj/item/ammo_magazine/rifle/standard_spottingrifle/tungsten,
		/obj/item/ammo_magazine/rifle/standard_spottingrifle/incendiary,
		/obj/item/ammo_magazine/rifle/standard_spottingrifle/flak,
	)
	force = 5
	attachable_allowed = list()
	actions_types = list()
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO)
	flags_gun_features = GUN_IS_ATTACHMENT|GUN_WIELDED_FIRING_ONLY|GUN_ATTACHMENT_FIRE_ONLY|GUN_AMMO_COUNTER|GUN_IFF|GUN_SMOKE_PARTICLES
	flags_attach_features = NONE
	fire_delay = 1 SECONDS
	accuracy_mult = 1.25
	pixel_shift_x = 18
	pixel_shift_y = 16

//-------------------------------------------------------
//Sectoid Rifle

/obj/item/weapon/gun/rifle/sectoid_rifle
	name = "alien rifle"
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

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_ENERGY|GUN_SMOKE_PARTICLES
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOBURST)
	attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 18,"rail_x" = 12, "rail_y" = 23, "under_x" = 23, "under_y" = 15, "stock_x" = 22, "stock_y" = 12)

	fire_delay = 0.5 SECONDS
	burst_amount = 3
	burst_delay = 0.15 SECONDS
	accuracy_mult = 2
	accuracy_mult_unwielded = 0.8
	movement_acc_penalty_mult = 3

/obj/item/weapon/gun/rifle/sectoid_rifle/Initialize(mapload, spawn_empty)
	. = ..()
	AddComponent(/datum/component/reequip, list(SLOT_BACK)) //Sectoids have alien powers that make them not lose their gun

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
	desc = "The Bauer SR-127 is the standard issue bolt action rifle used by the TGMC. Known for its long range accuracy and use by marksmen despite its age and lack of IFF, though careful aim allows fire support from behind. It has an irremoveable scope. Uses 8.6×70mm box magazines."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = GUN_ICONSTATE_LOADED
	item_state = GUN_ICONSTATE_LOADED
	greyscale_config = /datum/greyscale_config/gun/gun64/shotgun/tl127
	colorable_allowed = PRESET_COLORS_ALLOWED
	item_icons = list(
		slot_l_hand_str = /datum/greyscale_config/gun_inhand/tl127,
		slot_r_hand_str = /datum/greyscale_config/gun_inhand/r_hand/tl127,
		slot_back_str = /datum/greyscale_config/worn_gun/tl127,
		slot_s_store_str = /datum/greyscale_config/worn_gun/suit/tl127,
	)

	inhand_x_dimension = 64
	inhand_y_dimension = 32
	fire_sound = 'sound/weapons/guns/fire/tgmc/kinetic/gun_sr127.ogg'
	fire_rattle = 'sound/weapons/guns/fire/tgmc/kinetic/gun_sr127_low.ogg'
	cocked_sound = 'sound/weapons/guns/interact/tl-127_bolt.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/sniper_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/m41a_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/m41a_reload.ogg'
	caliber = CALIBER_86X70 //codex
	max_shells = 10 //codex
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
		/obj/item/attachable/bayonetknife/som,
		/obj/item/attachable/compensator,
		/obj/item/attachable/foldable/bipod,
	)

	flags_gun_features = GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER|GUN_SMOKE_PARTICLES
	reciever_flags = AMMO_RECIEVER_REQUIRES_UNIQUE_ACTION|AMMO_RECIEVER_MAGAZINES|AMMO_RECIEVER_UNIQUE_ACTION_LOCKS|AMMO_RECIEVER_AUTO_EJECT

	cock_animation = GUN_ICONSTATE_PUMP
	cocked_message = "You rack the bolt!"

	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO)
	attachable_offset = list("muzzle_x" = 40, "muzzle_y" = 19,"rail_x" = 10, "rail_y" = 22, "under_x" = 33, "under_y" = 16, "stock_x" = 8, "stock_y" = 12)
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

/obj/item/weapon/gun/rifle/chambered/unscoped
	starting_attachment_types = list(/obj/item/attachable/stock/tl127stock)

//-------------------------------------------------------
//SR-81 Auto-Sniper

/obj/item/weapon/gun/rifle/standard_autosniper
	name = "\improper SR-81 Kauser-KT automatic sniper rifle"
	desc = "The Kauser-KT SR-81 is the TerraGov Marine Corps's automatic sniper rifle usually married to it's iconic NVG/KTLD scope combo. It is notable for its high rate of fire for its class, and has decent performance in any range. Uses 8.6x70mm caseless with specialized pressures for IFF fire."
	icon_state = GUN_ICONSTATE_LOADED
	item_state = GUN_ICONSTATE_LOADED
	fire_sound = 'sound/weapons/guns/fire/sniper.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/sniper_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/m41a_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/m41a_reload.ogg'
	caliber = CALIBER_86X70 //codex
	max_shells = 20 //codex
	default_ammo_type = /obj/item/ammo_magazine/rifle/autosniper
	allowed_ammo_types = list(/obj/item/ammo_magazine/rifle/autosniper)
	greyscale_config = /datum/greyscale_config/gun/gun64/t81
	colorable_allowed = PRESET_COLORS_ALLOWED
	item_icons = list(
		slot_l_hand_str = /datum/greyscale_config/gun_inhand/t81,
		slot_r_hand_str = /datum/greyscale_config/gun_inhand/r_hand/t81,
		slot_back_str = /datum/greyscale_config/worn_gun/t81,
		slot_s_store_str = /datum/greyscale_config/worn_gun/suit/t81,
	)
	attachable_allowed = list(
		/obj/item/attachable/scope/nightvision,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/suppressor,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/bayonetknife/som,
		/obj/item/attachable/compensator,
	)

	flags_gun_features = GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER|GUN_IFF|GUN_SMOKE_PARTICLES
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)
	attachable_offset = list("muzzle_x" = 48, "muzzle_y" = 18,"rail_x" = 23, "rail_y" = 23, "under_x" = 38, "under_y" = 16, "stock_x" = 9, "stock_y" = 12)
	starting_attachment_types = list(
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
	icon_state = GUN_ICONSTATE_LOADED
	item_state = GUN_ICONSTATE_LOADED
	caliber = CALIBER_492X34_CASELESS //codex
	max_shells = 70 //codex
	wield_delay = 0.65 SECONDS
	fire_sound = 'sound/weapons/guns/fire/tgmc/kinetic/gun_ar11.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/m41a_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/T42_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/T42_reload.ogg'
	default_ammo_type = /obj/item/ammo_magazine/rifle/tx11
	allowed_ammo_types = list(/obj/item/ammo_magazine/rifle/tx11)
	greyscale_config = /datum/greyscale_config/gun/tx11
	colorable_allowed = PRESET_COLORS_ALLOWED
	item_icons = list(
		slot_l_hand_str = /datum/greyscale_config/gun_inhand/tx11,
		slot_r_hand_str = /datum/greyscale_config/gun_inhand/r_hand/tx11,
		slot_back_str = /datum/greyscale_config/worn_gun/tx11,
		slot_s_store_str = /datum/greyscale_config/worn_gun/suit/tx11,
	)
	attachable_allowed = list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/bayonetknife/som,
		/obj/item/attachable/flashlight/under,
		/obj/item/attachable/scope/mini/tx11,
		/obj/item/attachable/stock/tx11,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/motiondetector,
		/obj/item/attachable/scope/marine,
	)

	flags_gun_features = GUN_AMMO_COUNTER|GUN_SMOKE_PARTICLES
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOBURST)
	starting_attachment_types = list(/obj/item/attachable/stock/tx11, /obj/item/attachable/scope/mini/tx11)
	attachable_offset = list("muzzle_x" = 31, "muzzle_y" = 17,"rail_x" = 6, "rail_y" = 20, "under_x" = 20, "under_y" = 12, "stock_x" = 17, "stock_y" = 14)
	actions_types = list(/datum/action/item_action/aim_mode)
	aim_fire_delay = 0.15 SECONDS

	fire_delay = 0.25 SECONDS
	burst_amount = 3
	burst_delay = 0.05 SECONDS
	extra_delay = 0.15 SECONDS
	accuracy_mult_unwielded = 0.5
	accuracy_mult = 1.15
	scatter = -1
	scatter_unwielded = 15
	aim_slowdown = 0.45
	movement_acc_penalty_mult = 6

/obj/item/weapon/gun/rifle/tx11/scopeless
	starting_attachment_types = list(/obj/item/attachable/stock/tx11)

/obj/item/weapon/gun/rifle/tx11/freelancerone
	starting_attachment_types = list(/obj/item/attachable/stock/tx11, /obj/item/attachable/magnetic_harness, /obj/item/attachable/bayonet, /obj/item/attachable/lasersight)

/obj/item/weapon/gun/rifle/tx11/freelancertwo
	starting_attachment_types = list(/obj/item/attachable/stock/tx11, /obj/item/attachable/motiondetector, /obj/item/attachable/bayonet, /obj/item/attachable/lasersight)

/obj/item/weapon/gun/rifle/tx11/standard
	starting_attachment_types = list(/obj/item/attachable/stock/tx11, /obj/item/attachable/reddot, /obj/item/attachable/lasersight)

//-------------------------------------------------------
//AR-21 Assault Rifle

/obj/item/weapon/gun/rifle/standard_skirmishrifle
	name = "\improper AR-21 Kauser skirmish rifle"
	desc = "The Kauser AR-21 is a versatile rifle is developed to bridge a gap between higher caliber weaponry and a normal rifle. It fires a strong 10x25mm round, which has decent stopping power. It however suffers in magazine size and movement capablity compared to smaller peers."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = GUN_ICONSTATE_LOADED
	item_state = GUN_ICONSTATE_LOADED
	item_icons = list(
		slot_l_hand_str = /datum/greyscale_config/gun_inhand/t21,
		slot_r_hand_str = /datum/greyscale_config/gun_inhand/r_hand/t21,
		slot_back_str = /datum/greyscale_config/worn_gun/t21,
		slot_s_store_str = /datum/greyscale_config/worn_gun/suit/t21,
	)

	inhand_x_dimension = 64
	inhand_y_dimension = 32
	fire_sound = 'sound/weapons/guns/fire/tgmc/kinetic/gun_ar21.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/t21_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/t21_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/t21_reload.ogg'
	caliber = CALIBER_10X25_CASELESS //codex
	max_shells = 30 //codex
	force = 20
	default_ammo_type = /obj/item/ammo_magazine/rifle/standard_skirmishrifle
	allowed_ammo_types = list(/obj/item/ammo_magazine/rifle/standard_skirmishrifle)
	greyscale_config = /datum/greyscale_config/gun/gun64/t21
	colorable_allowed = PRESET_COLORS_ALLOWED
	attachable_allowed = list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/gyro,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/foldable/bipod,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/suppressor,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/bayonetknife/som,
		/obj/item/attachable/compensator,
		/obj/item/attachable/scope,
		/obj/item/attachable/flashlight/under,
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

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_SMOKE_PARTICLES
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)
	attachable_offset = list("muzzle_x" = 46, "muzzle_y" = 16,"rail_x" = 18, "rail_y" = 19, "under_x" = 34, "under_y" = 13, "stock_x" = 0, "stock_y" = 13)
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
		/obj/item/attachable/flashlight/under,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/suppressor,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/bayonetknife/som,
	)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_SMOKE_PARTICLES
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOBURST)
	attachable_offset = list("muzzle_x" = 31, "muzzle_y" = 16,"rail_x" = 10, "rail_y" = 19, "under_x" = 21, "under_y" = 13, "stock_x" = 0, "stock_y" = 13)

	fire_delay = 0.2 SECONDS
	burst_delay = 0.1 SECONDS
	extra_delay = 0.2 SECONDS
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
	desc = "A certified classic, this reproduction design was hailed as the first successful assault rifle concept, generally termed a 'storm rifle'. Has a higher than usual firerate for its class, but suffers in capacity. This version of it chambers 7.62x39mm."
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
		/obj/item/attachable/foldable/bipod,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/suppressor,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/bayonetknife/som,
	)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_SMOKE_PARTICLES
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)
	attachable_offset = list("muzzle_x" = 51, "muzzle_y" = 18,"rail_x" = 24, "rail_y" = 22, "under_x" = 36, "under_y" = 16, "stock_x" = 0, "stock_y" = 12)

	accuracy_mult = 1.1
	burst_amount = 1
	fire_delay = 0.2 SECONDS
	scatter = 1
	wield_delay = 0.5 SECONDS
	movement_acc_penalty_mult = 4

//-------------------------------------------------------
// GL-54 grenade launcher
/obj/item/weapon/gun/rifle/tx54
	name = "\improper GL-54 grenade launcher"
	desc = "A magazine fed, semi-automatic grenade launcher designed to shoot airbursting smart grenades. Requires a T49 scope for precision aiming."
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
		/obj/item/attachable/foldable/bipod,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/scope,
		/obj/item/attachable/scope/marine,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/motiondetector,
		/obj/item/attachable/flashlight/under,
		/obj/item/attachable/buildasentry,
		/obj/item/attachable/shoulder_mount,
	)

	flags_gun_features = GUN_AMMO_COUNTER|GUN_WIELDED_STABLE_FIRING_ONLY|GUN_WIELDED_FIRING_ONLY|GUN_SMOKE_PARTICLES
	starting_attachment_types = list(/obj/item/attachable/scope/optical)
	default_ammo_type = null
	allowed_ammo_types = list(
		/obj/item/ammo_magazine/rifle/tx54,
		/obj/item/ammo_magazine/rifle/tx54/he,
		/obj/item/ammo_magazine/rifle/tx54/incendiary,
		/obj/item/ammo_magazine/rifle/tx54/smoke,
		/obj/item/ammo_magazine/rifle/tx54/smoke/dense,
		/obj/item/ammo_magazine/rifle/tx54/smoke/tangle,
		/obj/item/ammo_magazine/rifle/tx54/razor,
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
	name = "\improper GL-55 20mm grenade launcher"
	desc = "A weapon-mounted, reloadable, five-shot grenade launcher."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "tx55gl"
	placed_overlay_iconstate = "tx55gl"
	attachable_allowed = list()
	flags_gun_features = GUN_AMMO_COUNTER|GUN_IS_ATTACHMENT|GUN_ATTACHMENT_FIRE_ONLY|GUN_WIELDED_STABLE_FIRING_ONLY|GUN_WIELDED_FIRING_ONLY|GUN_SMOKE_PARTICLES
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
	desc = "Officially designated an Objective Individual Combat Weapon, the AR-55 features an upper bullpup 20mm grenade launcher designed to fire a variety of specialised rounds, and an underslung assault rifle using 10x24mm caseless ammunition. Somewhat cumbersome to use due to its size and weight. Requires a T49 scope for precision aiming."
	icon_state = "tx55"
	item_state = "tx55"
	fire_sound = "gun_ar12"
	dry_fire_sound = 'sound/weapons/guns/fire/m41a_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/t18_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/t18_reload.ogg'
	caliber = CALIBER_10X24_CASELESS //codex
	max_shells = 36 //codex
	wield_delay = 1 SECONDS
	default_ammo_type = /obj/item/ammo_magazine/rifle/standard_carbine
	allowed_ammo_types = list(/obj/item/ammo_magazine/rifle/standard_carbine)
	attachable_allowed = list(
		/obj/item/attachable/scope/optical,
		/obj/item/weapon/gun/rifle/tx54/mini,
		/obj/item/attachable/reddot,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/gyro,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/foldable/bipod,
		/obj/item/attachable/flashlight/under,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/suppressor,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/bayonetknife/som,
		/obj/item/attachable/compensator,
		/obj/item/attachable/scope,
		/obj/item/attachable/scope/marine,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/motiondetector,
	)

	flags_gun_features = GUN_AMMO_COUNTER|GUN_SMOKE_PARTICLES
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOBURST)
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
//A true classic, the Garand. Ping.

/obj/item/weapon/gun/rifle/garand
	name = "\improper CAU C1 Garand self loading rifle"
	desc = "The Carlford-1 is a remastered classic made by Carlford Armories, made to fit in the modern day. Most of the noticeable differences are minor rail modifications. Other than that, it is a faithful recreation with the trademark ping sound and all. Uses .30-06 enbloc clips."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "garand"
	item_state = "garand"
	item_icons = list(
		slot_l_hand_str = 'icons/mob/items_lefthand_64.dmi',
		slot_r_hand_str = 'icons/mob/items_righthand_64.dmi',
	)

	inhand_x_dimension = 64
	inhand_y_dimension = 32
	fire_sound = 'sound/weapons/guns/fire/garand.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/sniper_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/garand_ping.ogg'
	reload_sound = 'sound/weapons/guns/interact/m41a_reload.ogg'
	empty_sound = null
	caliber = CALIBER_3006 //codex
	max_shells = 8 //codex
	default_ammo_type = /obj/item/ammo_magazine/rifle/garand
	allowed_ammo_types = list(
		/obj/item/ammo_magazine/rifle/garand,
	)
	attachable_allowed = list(
		/obj/item/attachable/stock/garand,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/suppressor,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/bayonetknife/som,
		/obj/item/attachable/compensator,
		/obj/item/attachable/foldable/bipod,
	)

	flags_gun_features = GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER|GUN_SMOKE_PARTICLES
	reciever_flags = AMMO_RECIEVER_MAGAZINES|AMMO_RECIEVER_AUTO_EJECT|AMMO_RECIEVER_CYCLE_ONLY_BEFORE_FIRE

	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO)
	attachable_offset = list("muzzle_x" = 40, "muzzle_y" = 19,"rail_x" = 9, "rail_y" = 22, "under_x" = 33, "under_y" = 16, "stock_x" = 0, "stock_y" = 11)
	actions_types = list(/datum/action/item_action/aim_mode)
	aim_fire_delay = 1.25 SECONDS

	starting_attachment_types = list(
		/obj/item/attachable/stock/garand,
	)

	burst_amount = 0
	fire_delay = 0.8 SECONDS
	accuracy_mult = 1.15
	accuracy_mult_unwielded = 0.75
	scatter = 0
	scatter_unwielded = 25
	recoil = 0
	recoil_unwielded = 4
	aim_slowdown = 0.75
	wield_delay = 1 SECONDS
	movement_acc_penalty_mult = 6

//-------------------------------------------------------
// V-31 SOM rifle

/obj/item/weapon/gun/rifle/som
	name = "\improper V-31 assault rifle"
	desc = "The V-31 was the primary rifle of the Sons of Mars until the introduction of more advanced energy weapons. Nevertheless, the V-31 continues to see common use due to its comparative ease of production and maintenance, and due to the inbuilt low velocity railgun designed for so called 'micro' grenades. Has good handling due to its compact bullpup design, and is generally effective at all ranges. Uses 10x25mm caseless ammunition."
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
		/obj/item/attachable/foldable/bipod,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/suppressor,
		/obj/item/attachable/flashlight/under,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/bayonetknife/som,
		/obj/item/attachable/compensator,
		/obj/item/attachable/scope,
		/obj/item/attachable/scope/marine,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/motiondetector,
	)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_SMOKE_PARTICLES
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOBURST)
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

	accuracy_mult = 1
	accuracy_mult_unwielded = 0.55
	scatter = 1
	scatter_unwielded = 15

	burst_amount = 3
	burst_delay = 0.1 SECONDS
	extra_delay = 0.1 SECONDS

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

//-------------------------------------------------------
// V-34 SOM carbine
/obj/item/weapon/gun/rifle/som_carbine
	name = "\improper V-34 carbine"
	desc = "An old but robust weapon that saw extensive use in the Martian uprising. A comparatively light and compact weapon, it still packs a considerable punch thanks to a good rate of fire and high calibre, although at range its effective drops off considerably. It is chambered in 7.62x39mm."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "v34"
	item_state = "v34"
	caliber = CALIBER_762X39
	muzzleflash_iconstate = "muzzle_flash"
	max_shells = 30
	fire_sound = 'sound/weapons/guns/fire/ak47.ogg'
	unload_sound = 'sound/weapons/guns/interact/ak47_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/ak47_reload.ogg'
	cocked_sound = 'sound/weapons/guns/interact/ak47_cocked.ogg'
	default_ammo_type = /obj/item/ammo_magazine/rifle/mpi_km/carbine
	allowed_ammo_types = list(
		/obj/item/ammo_magazine/rifle/mpi_km,
		/obj/item/ammo_magazine/rifle/mpi_km/plum,
		/obj/item/ammo_magazine/rifle/mpi_km/black,
		/obj/item/ammo_magazine/rifle/mpi_km/carbine,
		/obj/item/ammo_magazine/rifle/mpi_km/carbine/plum,
		/obj/item/ammo_magazine/rifle/mpi_km/carbine/black,
		/obj/item/ammo_magazine/rifle/mpi_km/extended,
	)
	attachable_allowed = list(
		/obj/item/attachable/foldable/som_carbine,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/verticalgrip,
	)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_SMOKE_PARTICLES
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)
	attachable_offset = list("muzzle_x" = 30, "muzzle_y" = 18,"rail_x" = 8, "rail_y" = 20, "under_x" = 17, "under_y" = 13, "stock_x" = -6, "stock_y" = 16)
	starting_attachment_types = list(/obj/item/attachable/foldable/som_carbine)
	force = 15

	burst_amount = 1
	fire_delay = 0.15 SECONDS
	accuracy_mult = 0.75
	scatter = 12
	recoil = 1.5
	wield_delay = 0.4 SECONDS
	aim_slowdown = 0.3
	movement_acc_penalty_mult = 4
	damage_falloff_mult = 1.4
	damage_mult = 0.9

/obj/item/weapon/gun/rifle/som_carbine/mag_harness
	starting_attachment_types = list(/obj/item/attachable/foldable/som_carbine, /obj/item/attachable/magnetic_harness)

/obj/item/weapon/gun/rifle/som_carbine/black
	desc = "A modern redesign by the SOM of an ancient weapon that saw extensive use in the Martian uprising. A comparatively light and compact weapon, it still packs a considerable punch thanks to a good rate of fire and high calibre, although at range its effective drops off considerably. It is chambered in 7.62x39mm."
	icon_state = "v34_black"
	item_state = "v34_black"
	default_ammo_type = /obj/item/ammo_magazine/rifle/mpi_km/carbine/black
	attachable_allowed = list(
		/obj/item/attachable/foldable/som_carbine,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/reddot,
	)

/obj/item/weapon/gun/rifle/som_carbine/black/standard
	starting_attachment_types = list(
		/obj/item/attachable/foldable/som_carbine,
		/obj/item/attachable/reddot,
	)

//-------------------------------------------------------
// V-41 SOM LMG

/obj/item/weapon/gun/rifle/som_mg
	name = "\improper V-41 machine gun"
	desc = "The V-41 is a large man portable machine used by the SOM, allowing for sustained, accurate suppressive firepower at the cost of mobility and handling. Commonly seen where their preferred tactics of fast, mobile aggression is ill suited. Takes 10x26mm Caseless."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "v41"
	item_state = "v41"
	fire_animation = "v41_fire"
	item_icons = list(
		slot_l_hand_str = 'icons/mob/items_lefthand_64.dmi',
		slot_r_hand_str = 'icons/mob/items_righthand_64.dmi',
	)

	inhand_x_dimension = 64
	inhand_y_dimension = 32
	caliber = CALIBER_10x26_CASELESS
	max_shells = 200
	force = 35
	wield_delay = 1.5 SECONDS
	fire_sound = 'sound/weapons/guns/fire/v41.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/m41a_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/T42_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/v41_reload.ogg'
	cocked_sound = 'sound/weapons/guns/interact/v41_cocked.ogg'
	default_ammo_type = /obj/item/ammo_magazine/som_mg
	allowed_ammo_types = list(/obj/item/ammo_magazine/som_mg)
	attachable_allowed = list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/flashlight/under,
		/obj/item/attachable/foldable/bipod,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/scope,
		/obj/item/attachable/scope/marine,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/stock/som_mg_stock,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/motiondetector,
		/obj/item/attachable/buildasentry,
		/obj/item/attachable/shoulder_mount,
	)

	flags_gun_features = GUN_AMMO_COUNTER|GUN_WIELDED_FIRING_ONLY|GUN_SMOKE_PARTICLES
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)
	starting_attachment_types = list(/obj/item/attachable/stock/som_mg_stock)
	gun_skill_category = SKILL_HEAVY_WEAPONS
	attachable_offset = list("muzzle_x" = 53, "muzzle_y" = 19,"rail_x" = 14, "rail_y" = 23, "under_x" = 41, "under_y" = 14, "stock_x" = -32, "stock_y" = 0)
	actions_types = list(/datum/action/item_action/aim_mode)
	aim_fire_delay = 0.2 SECONDS
	aim_slowdown = 1.2

	fire_delay = 0.2 SECONDS
	burst_amount = 1
	accuracy_mult = 0.9
	accuracy_mult_unwielded = 0.4
	scatter = 6
	scatter_unwielded = 40
	movement_acc_penalty_mult = 7

	placed_overlay_iconstate = "lmg"

/obj/item/weapon/gun/rifle/som_mg/standard
	starting_attachment_types = list(/obj/item/attachable/stock/som_mg_stock, /obj/item/attachable/foldable/bipod, /obj/item/attachable/reddot, /obj/item/attachable/extended_barrel)

//-------------------------------------------------------
//L-11 ICC Sharpshooter Rifle

/obj/item/weapon/gun/rifle/icc_sharpshooter
	name = "\improper L-11 sharpshooter rifle"
	desc = "The L-11 is a venerable and battle-tested rifle used by the ICCAF. Although rather heavy, long and unwieldy compared to most ICCAF rifles, which focus on getting up close and personal, it easily makes up with excellent long-range potential when compared to most of its peers, mostly seen in use by reserve troops who expect to fight at distance, rather than up close. Uses 10x27mm magazines."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "l11"
	item_state = "l11"
	item_icons = list(
		slot_l_hand_str = 'icons/mob/items_lefthand_64.dmi',
		slot_r_hand_str = 'icons/mob/items_righthand_64.dmi',
	)
	inhand_x_dimension = 64
	inhand_y_dimension = 32

	muzzleflash_iconstate = "muzzle_flash_medium"
	fire_sound = "fal_fire"
	dry_fire_sound = 'sound/weapons/guns/fire/m41a_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/fal_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/fal_reload.ogg'
	caliber = CALIBER_10x27_CASELESS //codex
	aim_slowdown = 0.8
	wield_delay = 0.85 SECONDS
	force = 20
	max_shells = 20 //codex
	default_ammo_type = /obj/item/ammo_magazine/rifle/icc_sharpshooter
	allowed_ammo_types = list(/obj/item/ammo_magazine/rifle/icc_sharpshooter)
	attachable_allowed = list(
		/obj/item/attachable/stock/icc_sharpshooter,
		/obj/item/attachable/suppressor,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/bayonetknife/som,
		/obj/item/attachable/compensator,
		/obj/item/attachable/reddot,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/angledgrip,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/flashlight/under,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/foldable/bipod,
		/obj/item/attachable/gyro,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/scope,
		/obj/item/attachable/scope/marine,
		/obj/item/attachable/motiondetector,
		/obj/item/weapon/gun/pistol/plasma_pistol,
		/obj/item/weapon/gun/shotgun/combat/masterkey,
		/obj/item/weapon/gun/flamer/mini_flamer,
		/obj/item/weapon/gun/grenade_launcher/underslung/mpi/removeable,
	)
	starting_attachment_types = list(/obj/item/attachable/stock/icc_sharpshooter)

	flags_gun_features = GUN_AMMO_COUNTER|GUN_CAN_POINTBLANK|GUN_SMOKE_PARTICLES
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)
	attachable_offset = list("muzzle_x" = 40, "muzzle_y" = 14, "rail_x" = 15, "rail_y" = 17, "under_x" = 23, "under_y" = 10, "stock_x" = 17, "stock_y" = 10)
	actions_types = list(/datum/action/item_action/aim_mode)
	aim_fire_delay = 0.1 SECONDS
	aim_speed_modifier = 2

	burst_amount = 1
	fire_delay = 0.7 SECONDS
	damage_mult = 1.1
	accuracy_mult = 1.15
	scatter = 0
	movement_acc_penalty_mult = 5

/obj/item/weapon/gun/rifle/icc_sharpshooter/medic
	starting_attachment_types = list(/obj/item/attachable/stock/icc_sharpshooter, /obj/item/attachable/reddot, /obj/item/attachable/verticalgrip, /obj/item/attachable/heavy_barrel)

//-------------------------------------------------------
// L-15 ICC Battlecarbine

/obj/item/weapon/gun/rifle/icc_battlecarbine
	name = "\improper L-15 battlecarbine"
	desc = "The L-15 battlecarbine is the standard rifle of the ICCAF, boasting a high caliber round and a menacing profile, it presents an excellent CQC firearm. However it struggles at range due to high dropoff from the short barrel, units that use it say that you need to close the gap at any cost to see the true efficacy of this weapon. Uses 10x25mm caseless ammunition."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "l15"
	item_state = "l15"
	item_icons = list(
		slot_l_hand_str = 'icons/mob/items_lefthand_64.dmi',
		slot_r_hand_str = 'icons/mob/items_righthand_64.dmi',
	)

	inhand_x_dimension = 64
	inhand_y_dimension = 32

	fire_sound = 'sound/weapons/guns/fire/mdr.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/m41a_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/mdr_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/mdr_reload.ogg'
	caliber = CALIBER_10X25_CASELESS //codex
	max_shells = 30 //codex
	force = 20
	default_ammo_type = /obj/item/ammo_magazine/rifle/icc_battlecarbine
	allowed_ammo_types = list(/obj/item/ammo_magazine/rifle/icc_battlecarbine)
	attachable_allowed = list(
		/obj/item/attachable/suppressor,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/bayonetknife/som,
		/obj/item/attachable/compensator,
		/obj/item/attachable/reddot,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/angledgrip,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/flashlight/under,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/foldable/bipod,
		/obj/item/attachable/gyro,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/scope,
		/obj/item/attachable/scope/marine,
		/obj/item/attachable/motiondetector,
		/obj/item/weapon/gun/pistol/plasma_pistol,
		/obj/item/weapon/gun/shotgun/combat/masterkey,
		/obj/item/weapon/gun/flamer/mini_flamer,
		/obj/item/weapon/gun/grenade_launcher/underslung/mpi/removeable,
		/obj/item/weapon/gun/rifle/pepperball/pepperball_mini,
	)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_SMOKE_PARTICLES
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)
	attachable_offset = list("muzzle_x" = 44, "muzzle_y" = 19,"rail_x" = 20, "rail_y" = 23, "under_x" = 33, "under_y" = 13, "stock_x" = 0, "stock_y" = 13)
	actions_types = list(/datum/action/item_action/aim_mode)
	aim_fire_delay = 0.25 SECONDS
	aim_speed_modifier = 1.65

	burst_amount = 1
	fire_delay = 0.2 SECONDS
	scatter = 3
	aim_slowdown = 0.35
	wield_delay = 0.35 SECONDS
	damage_falloff_mult = 2.5
	movement_acc_penalty_mult = 4

/obj/item/weapon/gun/rifle/icc_battlecarbine/standard
	starting_attachment_types = list(/obj/item/weapon/gun/grenade_launcher/underslung/mpi/removeable, /obj/item/attachable/magnetic_harness, /obj/item/attachable/extended_barrel)


//-------------------------------------------------------
// ML-12 ICC Confrontation Rifle

/obj/item/weapon/gun/rifle/icc_confrontationrifle
	name = "\improper ML-12 confrontation rifle"
	desc = "The ML-12 confrontation rifle is an absolute beast of a weapon used by the ICCAF. Featuring a high caliber round in a short package, it will absolutely shred enemy targets at close quarters, a operator must mind the incredible recoil while making followup shots, however. Uses 10x28mm caseless ammunition."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "ml12"
	item_state = "ml12"
	item_icons = list(
		slot_l_hand_str = 'icons/mob/items_lefthand_64.dmi',
		slot_r_hand_str = 'icons/mob/items_righthand_64.dmi',
	)

	inhand_x_dimension = 64
	inhand_y_dimension = 32

	fire_sound = 'sound/weapons/guns/fire/ml12.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/m41a_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/ml12_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/ml12_reload.ogg'
	caliber = CALIBER_10X28_CASELESS //codex
	max_shells = 25 //codex
	force = 20
	default_ammo_type = /obj/item/ammo_magazine/rifle/icc_confrontationrifle
	allowed_ammo_types = list(/obj/item/ammo_magazine/rifle/icc_confrontationrifle)
	attachable_allowed = list(
		/obj/item/attachable/suppressor,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/bayonetknife/som,
		/obj/item/attachable/compensator,
		/obj/item/attachable/reddot,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/foldable/bipod,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/scope,
		/obj/item/attachable/scope/marine,
		/obj/item/attachable/motiondetector,
	)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_SMOKE_PARTICLES
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)
	attachable_offset = list("muzzle_x" = 48, "muzzle_y" = 18,"rail_x" = 24, "rail_y" = 26, "under_x" = 36, "under_y" = 14, "stock_x" = 0, "stock_y" = 13)
	actions_types = list(/datum/action/item_action/aim_mode)
	aim_fire_delay = 0.3 SECONDS
	aim_speed_modifier = 2.5

	burst_amount = 1
	fire_delay = 0.45 SECONDS
	aim_slowdown = 0.55
	wield_delay = 0.65 SECONDS
	damage_falloff_mult = 2
	movement_acc_penalty_mult = 6.5

	min_scatter = 4
	max_scatter = 20
	scatter_increase = 5
	scatter_decay = 1
	scatter_decay_unwielded = 0.5

/obj/item/weapon/gun/rifle/icc_confrontationrifle/leader
	starting_attachment_types = list(/obj/item/attachable/lasersight, /obj/item/attachable/magnetic_harness, /obj/item/attachable/extended_barrel)

//-------------------------------------------------------
//ML-41 Autoshotgun

/obj/item/weapon/gun/rifle/icc_autoshotgun
	name = "\improper ML-41 autoshotgun"
	desc = "The ML-41 Automatic Shotgun is used by the ICCAF in fast paced boarding assaults, fielding a wide variety of ammo for all situations. Takes 16-round 12 gauge drums."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "ml41"
	item_state = "ml41"
	fire_sound = 'sound/weapons/guns/fire/shotgun.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/shotgun_empty.ogg'
	caliber = CALIBER_12G //codex
	max_shells = 16 //codex
	force = 20
	default_ammo_type = /obj/item/ammo_magazine/rifle/icc_autoshotgun
	allowed_ammo_types = list(
		/obj/item/ammo_magazine/rifle/icc_autoshotgun,
		/obj/item/ammo_magazine/rifle/icc_autoshotgun/frag,
	)
	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/bayonetknife/som,
		/obj/item/attachable/reddot,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/angledgrip,
		/obj/item/attachable/gyro,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/compensator,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/flashlight/under,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/motiondetector,
	)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_WIELDED_FIRING_ONLY|GUN_SMOKE_PARTICLES //Its a shotgun type weapon effectively, most shotgun type weapons shouldn't be able to point blank 1 handed.
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)
	attachable_offset = list("muzzle_x" = 30, "muzzle_y" = 26,"rail_x" = 26, "rail_y" = 24, "under_x" = 40, "under_y" = 16, "stock_x" = 26, "stock_y" = 13)
	gun_skill_category = SKILL_SHOTGUNS

	fire_delay = 0.9 SECONDS
	accuracy_mult = 1.15
	damage_mult = 0.5
	aim_slowdown = 0.6
	wield_delay = 0.55 SECONDS
	burst_amount = 1
	scatter = 8
	movement_acc_penalty_mult = 2

/obj/item/weapon/gun/rifle/icc_autoshotgun/guard
	starting_attachment_types = list(/obj/item/attachable/verticalgrip, /obj/item/attachable/magnetic_harness)

//-------------------------------------------------------
//L-88 Assaultcarbine and EM-88 'Export' Varient

/obj/item/weapon/gun/rifle/icc_assaultcarbine
	name = "\improper L-88 assault carbine"
	desc = "An aged, reliable but outdated bullpup rifle used by ICCAF reserve personnel it is best used in close quarters when you need to quickly clear corners at rapid pace, has an integral foregrip and unmagnified scope to increase accuracy and reduce drag. Chambered in 5.56x45mm NATO."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "l88"
	item_state = "l88"
	muzzleflash_iconstate = "muzzle_flash_medium"
	caliber = CALIBER_556X45 //codex
	max_shells = 30 //codex
	fire_sound = 'sound/weapons/guns/fire/famas.ogg'
	unload_sound = 'sound/weapons/guns/interact/m16_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/m16_reload.ogg'
	cocked_sound = 'sound/weapons/guns/interact/m16_cocked.ogg'
	default_ammo_type = /obj/item/ammo_magazine/rifle/icc_assaultcarbine
	allowed_ammo_types = list(
		/obj/item/ammo_magazine/rifle/icc_assaultcarbine,
		/obj/item/ammo_magazine/rifle/icc_assaultcarbine/export,
	)
	attachable_allowed = list(
		/obj/item/attachable/suppressor,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/bayonetknife/som,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/compensator,
		/obj/item/attachable/magnetic_harness,
	)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOBURST)
	attachable_offset = list("muzzle_x" = 44, "muzzle_y" = 19,"rail_x" = 8, "rail_y" = 21, "under_x" = 28, "under_y" = 12, "stock_x" = 19, "stock_y" = 13)

	fire_delay = 0.2 SECONDS
	burst_delay = 0.1 SECONDS
	extra_delay = 0.15 SECONDS
	accuracy_mult = 1.15
	damage_mult = 1.2
	damage_falloff_mult = 1.5
	wield_delay = 0.65 SECONDS
	aim_slowdown = 0.2
	scatter = 0

/obj/item/weapon/gun/rifle/icc_assaultcarbine/export
	name = "\improper L&S EM-88 assault carbine"
	desc = "An aged, reliable, but outdated bullpup rifle usually seen within ICC space due to being surplused long ago, some of these surplus models sometimes find themselves within TGMC space via underhanded means. It's best used in close quarters when you need to quickly clear corners at rapid pace, has an integral foregrip and unmagnified scope to increase accuracy and reduce drag. Chambered in 5.56x45mm NATO."
	icon_state = "l88_export"
	item_state = "l88_export"
	default_ammo_type = /obj/item/ammo_magazine/rifle/icc_assaultcarbine/export
