///box for storage of ammo and gun
/obj/item/storage/box/tl102
	name = "\improper HSG-102 crate"
	desc = "A large and rusted metal case. It has not seen much use. Written in faded letters on its top, it says, \"This is a HSG-102 heavy smartgun\". There are many other warning labels atop that are too faded to read."
	icon = 'icons/Marine/marine-hmg.dmi'
	icon_state = "crate"
	w_class = WEIGHT_CLASS_HUGE
	storage_slots = 7
	bypass_w_limit = list(
		/obj/item/weapon/gun/tl102,
		/obj/item/ammo_magazine/tl102,
	)

/obj/item/storage/box/tl102/Initialize(mapload)
	. = ..()
	new /obj/item/weapon/gun/tl102(src) //gun itself
	new /obj/item/ammo_magazine/tl102(src) //ammo for the gun

///HSG-102, now with full auto. It is not a superclass of deployed guns, however there are a few varients.
/obj/item/weapon/gun/tl102
	name = "\improper HSG-102 mounted heavy smartgun"
	desc = "The HSG-102 heavy machinegun, it's too heavy to be wielded or operated without the tripod. IFF capable. No extra work required, just deploy it with Ctrl-Click. Can be repaired with a blowtorch once deployed."

	w_class = WEIGHT_CLASS_HUGE
	flags_equip_slot = ITEM_SLOT_BACK
	icon = 'icons/Marine/marine-hmg.dmi'
	icon_state = "turret"

	fire_sound = 'sound/weapons/guns/fire/hmg2.ogg'
	reload_sound = 'sound/weapons/guns/interact/minigun_cocked.ogg'

	default_ammo_type = /obj/item/ammo_magazine/tl102

	scatter = 10
	deployed_scatter_change = -10
	fire_delay = 0.25 SECONDS

	burst_amount = 3
	burst_delay = 0.1 SECONDS
	extra_delay = 1 SECONDS
	accuracy_mult = 1.2 //it's got a bipod
	burst_accuracy_bonus = 1
	burst_scatter_mult = 0

	flags_item = IS_DEPLOYABLE|TWOHANDED
	flags_gun_features = GUN_AMMO_COUNTER|GUN_DEPLOYED_FIRE_ONLY|GUN_WIELDED_FIRING_ONLY|GUN_IFF|GUN_SMOKE_PARTICLES
	gun_firemode_list = list(GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOMATIC)

	attachable_allowed = list(
		/obj/item/attachable/scope/unremovable/tl102,
	)

	starting_attachment_types = list(
		/obj/item/attachable/scope/unremovable/tl102,
	)

	allowed_ammo_types = list(
		/obj/item/ammo_magazine/tl102,
	)

	deploy_time = 5 SECONDS
	undeploy_time = 3 SECONDS
	deployable_item = /obj/machinery/deployable/mounted

	max_integrity = 200
	soft_armor = list(MELEE = 0, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 50, BIO = 100, FIRE = 0, ACID = 20)

///Unmovable ship mounted version.
/obj/item/weapon/gun/tl102/hsg_nest
	name = "\improper HSG-102 heavy smartgun nest"
	desc = "A HSG-102 heavy smartgun mounted upon a small reinforced post with sandbags to provide a small machinegun nest for all your defense purpose needs.</span>"
	icon = 'icons/Marine/marine-hmg.dmi'
	icon_state = "entrenched"

	default_ammo_type = /obj/item/ammo_magazine/tl102/hsg_nest

	attachable_allowed = list(/obj/item/attachable/scope/unremovable/tl102/nest)
	starting_attachment_types = list(
		/obj/item/attachable/scope/unremovable/tl102/nest,
	)

	allowed_ammo_types = list(
		/obj/item/ammo_magazine/tl102,
		/obj/item/ammo_magazine/tl102/hsg_nest,
	)
	flags_item = IS_DEPLOYABLE|TWOHANDED|DEPLOYED_NO_PICKUP|DEPLOY_ON_INITIALIZE
	soft_armor = list(MELEE = 0, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 50, BIO = 100, FIRE = 0, ACID = 0)

/obj/item/weapon/gun/tl102/hsg_nest/sandless
	icon_state = "entrenched_sandless"

//-------------------------------------------------------
//MG-2005 mounted minigun

/obj/item/weapon/gun/standard_minigun
	name = "\improper MG-2005 mounted minigun"
	desc = "The MG-2005 mounted minigun is a gun simple in principle, it will shoot a lot of bullets really fast and will rip through xeno hordes."

	w_class = WEIGHT_CLASS_HUGE
	flags_equip_slot = ITEM_SLOT_BACK
	icon = 'icons/Marine/marine-hmg.dmi'
	icon_state = "minigun"
	caliber = CALIBER_762X51

	fire_sound = 'sound/weapons/guns/fire/minigun.ogg'
	reload_sound = 'sound/weapons/guns/interact/minigun_cocked.ogg'

	default_ammo_type = /obj/item/ammo_magazine/heavy_minigun

	scatter = 10
	deployed_scatter_change = -8
	fire_delay = 0.10 SECONDS
	windup_delay = 0.4 SECONDS
	windup_sound = 'sound/weapons/guns/fire/tank_minigun_start.ogg'

	flags_item = IS_DEPLOYABLE|TWOHANDED
	flags_gun_features = GUN_AMMO_COUNTER|GUN_DEPLOYED_FIRE_ONLY|GUN_WIELDED_FIRING_ONLY|GUN_SMOKE_PARTICLES
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)
	actions_types = list(/datum/action/item_action/aim_mode)
	aim_time = 2 SECONDS
	aim_fire_delay = 0.05 SECONDS

	attachable_allowed = list(/obj/item/attachable/scope/unremovable/tl102)

	starting_attachment_types = list(/obj/item/attachable/scope/unremovable/tl102)

	allowed_ammo_types = list(/obj/item/ammo_magazine/heavy_minigun)

	deploy_time = 5 SECONDS
	undeploy_time = 3 SECONDS
	deployable_item = /obj/machinery/deployable/mounted

	max_integrity = 300
	soft_armor = list(MELEE = 0, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 50, BIO = 100, FIRE = 0, ACID = 20)

///Unmovable ship mounted version.
/obj/item/weapon/gun/standard_minigun/nest
	name = "\improper MG-2005 mounted minigun nest"
	desc = "A MG-2005 mounted minigun mounted upon a small reinforced post with sandbags."
	icon = 'icons/Marine/marine-hmg.dmi'
	icon_state = "minigun_nest"

	flags_item = IS_DEPLOYABLE|TWOHANDED|DEPLOYED_NO_PICKUP|DEPLOY_ON_INITIALIZE

	attachable_allowed = list(/obj/item/attachable/scope/unremovable/tl102/nest)

	starting_attachment_types = list(/obj/item/attachable/scope/unremovable/tl102/nest)

	soft_armor = list(MELEE = 0, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 50, BIO = 100, FIRE = 0, ACID = 20)

//-------------------------------------------------------
//ATR-22 mounted heavy anti-air gun

/obj/item/weapon/gun/standard_auto_cannon
	name = "\improper ATR-22 mounted flak gun"
	desc = "The ATR-22 is a recoiling barrel 20mm autocannon, created to be used against low flying targets, it is however able to engage ground targets at medium ranges with extreme efficency even if the recoil makes it near impossible to hit anything close by, its bullets will shred hard targets such as armored foes or walls. Both barrels can be fired at the same time rather than in sequence, but will incur large scatter penalties do so."
	w_class = WEIGHT_CLASS_HUGE
	flags_equip_slot = ITEM_SLOT_BACK
	icon = 'icons/Marine/marine-ac.dmi'
	icon_state = "autocannon"
	fire_sound = "ac_fire"
	reload_sound = 'sound/weapons/guns/interact/minigun_cocked.ogg'

	default_ammo_type = /obj/item/ammo_magazine/auto_cannon

	scatter = 10
	deployed_scatter_change = -10
	fire_delay = 0.4 SECONDS
	burst_amount = 12
	burst_delay = 0.2 SECONDS
	burst_scatter_mult = 0.65
	extra_delay = 1.5 SECONDS

	flags_item = IS_DEPLOYABLE|TWOHANDED|DEPLOYED_NO_PICKUP|DEPLOY_ON_INITIALIZE
	flags_gun_features = GUN_AMMO_COUNTER|GUN_DEPLOYED_FIRE_ONLY|GUN_WIELDED_FIRING_ONLY|GUN_IFF|GUN_SMOKE_PARTICLES
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOBURST)

	attachable_allowed = list(/obj/item/attachable/scope/unremovable/standard_atgun)

	starting_attachment_types = list(/obj/item/attachable/scope/unremovable/standard_atgun)

	allowed_ammo_types = list(
		/obj/item/ammo_magazine/auto_cannon,
		/obj/item/ammo_magazine/auto_cannon/flak,
	)

	undeploy_time = 2000 SECONDS
	deployable_item = /obj/machinery/deployable/mounted/moveable/auto_cannon

	max_integrity = 500
	soft_armor = list(MELEE = 60, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 50, BIO = 100, FIRE = 0, ACID = 0)

/obj/machinery/deployable/mounted/moveable/auto_cannon
	resistance_flags = XENO_DAMAGEABLE|UNACIDABLE
	coverage = 85 //has a shield

//-------------------------------------------------------
//TE-9001 mounted heavy laser

/obj/item/weapon/gun/energy/lasgun/lasrifle/heavy_laser
	name = "\improper TE-9001 mounted heavy laser"
	desc = "The TE-9001 mounted heavy laser is a non-IFF heavy laser that is powerful enough to start a sizeable fire on its impact, this weapon is exceptional at area denial and has direct fire capability on the side."

	w_class = WEIGHT_CLASS_HUGE
	flags_equip_slot = ITEM_SLOT_BACK
	icon = 'icons/Marine/marine-hmg.dmi'
	icon_state = "heavylaser"

	fire_sound = 'sound/weapons/guns/fire/tank_flamethrower.ogg'
	reload_sound = 'sound/weapons/guns/interact/minigun_cocked.ogg'

	default_ammo_type = /obj/item/cell/lasgun/heavy_laser
	ammo_datum_type = /datum/ammo/energy/lasgun/marine/heavy_laser

	scatter = 10
	deployed_scatter_change = -10
	fire_delay = 0.7 SECONDS

	flags_item = IS_DEPLOYABLE|TWOHANDED|DEPLOYED_NO_PICKUP|DEPLOY_ON_INITIALIZE
	flags_gun_features = GUN_AMMO_COUNTER|GUN_DEPLOYED_FIRE_ONLY|GUN_WIELDED_FIRING_ONLY|GUN_SMOKE_PARTICLES
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)

	attachable_allowed = list(/obj/item/attachable/scope/unremovable/tl102/nest)

	starting_attachment_types = list(/obj/item/attachable/scope/unremovable/tl102/nest)

	allowed_ammo_types = list(/obj/item/cell/lasgun/heavy_laser)

	deploy_time = 5 SECONDS
	undeploy_time = 3 SECONDS
	deployable_item = /obj/machinery/deployable/mounted

	max_integrity = 400
	soft_armor = list(MELEE = 0, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 50, BIO = 100, FIRE = 0, ACID = 0)

	mode_list = list(
		"Standard" = /datum/lasrifle/heavy_laser/standard,
		"Shatter Burst" = /datum/lasrifle/heavy_laser/burst,
		"Ricochet" = /datum/lasrifle/heavy_laser/ricochet,
	)

/datum/lasrifle/heavy_laser/standard
	rounds_per_shot = 15
	ammo_datum_type = /datum/ammo/energy/lasgun/marine/heavy_laser
	fire_delay = 0.7 SECONDS
	burst_amount = 1
	fire_sound = 'sound/weapons/guns/fire/tank_flamethrower.ogg'
	message_to_user = "You set the heavy laser to glob mode."
	fire_mode = GUN_FIREMODE_SEMIAUTO
	radial_icon_state = "laser_overcharge"
	description = "Fires a laser glob that ignites things on hit."

/datum/lasrifle/heavy_laser/burst
	rounds_per_shot = 5
	ammo_datum_type = /datum/ammo/energy/lasgun/marine/shatter/heavy_laser
	fire_delay = 1 SECONDS
	burst_amount = 3
	fire_sound = 'sound/weapons/guns/fire/Laser Rifle Standard.ogg'
	message_to_user = "You set the heavy laser to burst fire mode."
	fire_mode = GUN_FIREMODE_AUTOBURST
	icon_state = GUN_ICONSTATE_LOADED
	description = "Fires a rapid pulse laser, dealing mediocre damage and shattering armor, but suffers from increased scatter and poorer falloff."

/datum/lasrifle/heavy_laser/ricochet
	rounds_per_shot = 15
	fire_delay = 0.5 SECONDS
	ammo_datum_type = /datum/ammo/energy/lasgun/marine/ricochet/four
	fire_sound = 'sound/weapons/guns/fire/laser3.ogg'
	message_to_user = "You set the heavy laser to ricochet mode."
	fire_mode = GUN_FIREMODE_SEMIAUTO
	icon_state = GUN_ICONSTATE_LOADED
	radial_icon_state = "laser_ricochet"
	description = "Fires an experiment laser pulse capable of bouncing off many wall surfaces. The laser increases in potency when bouncing, before collapsing entirely after exceeding its threshold."


/obj/item/weapon/gun/energy/lasgun/lasrifle/heavy_laser/deployable
	icon_state = "heavylaser_deployable"
	flags_item = IS_DEPLOYABLE|TWOHANDED

//-------------------------------------------------------
//FK-88 mounted heavy infantry support gun

/obj/item/weapon/gun/heavy_isg
	name = "\improper FK-88 mounted flak gun"
	desc = "The FK-88 is a big gun, offically meant to be used against large hostile wildlife or unruly crowds, this cannon will most definitely give a very bad day to anything that gets caught in its line of fire. Takes quite a while to dial in your shots. Uses 15cm shells."

	w_class = WEIGHT_CLASS_HUGE
	flags_equip_slot = ITEM_SLOT_BACK
	icon = 'icons/Marine/marine-fkgun.dmi'
	icon_state = "isg"
	fire_sound = 'sound/weapons/guns/fire/tank_cannon1.ogg'
	reload_sound = 'sound/weapons/guns/interact/tat36_reload.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/launcher_empty.ogg'

	default_ammo_type = /obj/item/ammo_magazine/heavy_isg/he
	max_shells = 1 //codex
	caliber = CALIBER_15CM // codex

	scatter = 10
	deployed_scatter_change = -10
	fire_delay = 10 SECONDS

	flags_item = IS_DEPLOYABLE|TWOHANDED|DEPLOYED_NO_PICKUP|DEPLOY_ON_INITIALIZE|DEPLOYED_ANCHORED_FIRING_ONLY
	flags_gun_features = GUN_AMMO_COUNTER|GUN_DEPLOYED_FIRE_ONLY|GUN_WIELDED_FIRING_ONLY|GUN_SMOKE_PARTICLES
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO)

	attachable_allowed = list(/obj/item/attachable/scope/unremovable/tl102/nest)

	starting_attachment_types = list(/obj/item/attachable/scope/unremovable/tl102/nest)

	allowed_ammo_types = list(
		/obj/item/ammo_magazine/heavy_isg/he,
		/obj/item/ammo_magazine/heavy_isg/sabot,
	)

	deploy_time = 6 SECONDS
	undeploy_time = 3 SECONDS
	deployable_item = /obj/machinery/deployable/mounted/moveable/isg

	max_integrity = 800
	soft_armor = list(MELEE = 60, BULLET = 60, LASER = 60, ENERGY = 50, BOMB = 50, BIO = 100, FIRE = 0, ACID = 0)

/obj/machinery/deployable/mounted/moveable/isg
	coverage = 90 // Has a shield.
	anchor_time = 4 SECONDS
	has_anchored_sprite = TRUE
	pixel_x = -16
	pixel_y = -11

///This is my meme version, the first version of the HSG-102 to have auto-fire, revel in its presence.
/obj/item/weapon/gun/tl102/death
	name = "\improper \"Death incarnate\" heavy machine gun"
	desc = "It looks like a regular HSG-102, however glowing archaeic writing glows faintly on its sides and top. It beckons for blood."
	icon = 'icons/Marine/marine-hmg.dmi'

	aim_slowdown = 3
	scatter = 30
	deployed_scatter_change = -27

	fire_delay = 0.5
	burst_amount = 3
	burst_delay = 0.1 SECONDS

	aim_slowdown = 3
	wield_delay = 5 SECONDS

	flags_gun_features = GUN_AMMO_COUNTER|GUN_IFF|GUN_SMOKE_PARTICLES

// This is a deployed IFF-less MACHINEGUN, has 500 rounds, drums do not fit anywhere but your belt slot and your back slot. But it has 500 rounds. That's nice.

/obj/item/weapon/gun/heavymachinegun
	name = "\improper HMG-08 heavy machinegun"
	desc = "An absolute monster of a weapon, this is a watercooled heavy machinegun modernized by some crazy armorer with a wheeling kit included. Considering the mish mash of parts for the wheeling kit, you think its from another model of the gun. The pinnacle at holding a chokepoint. Holds 500 rounds of 10x28mm caseless in a box case. IS NOT IFF CAPABLE. Aiming carefully recommended. Can be repaired with a blowtorch once deployed. Alt Right click to unanchor and reanchor it."
	w_class = WEIGHT_CLASS_HUGE
	flags_equip_slot = ITEM_SLOT_BACK
	icon = 'icons/Marine/marine-hmg.dmi'
	icon_state = "mg08"

	fire_sound = 'sound/weapons/guns/fire/mg08.ogg'
	reload_sound = 'sound/weapons/guns/interact/minigun_cocked.ogg'
	caliber = CALIBER_10X28

	default_ammo_type = /obj/item/ammo_magazine/heavymachinegun
	allowed_ammo_types = list(/obj/item/ammo_magazine/heavymachinegun, /obj/item/ammo_magazine/heavymachinegun/small)

	scatter = 10
	deployed_scatter_change = -8
	fire_delay = 0.2 SECONDS
	accuracy_mult = 1.1 //it's mounted

	burst_amount = 1

	flags_item = IS_DEPLOYABLE|TWOHANDED
	flags_gun_features = GUN_AMMO_COUNTER|GUN_DEPLOYED_FIRE_ONLY|GUN_WIELDED_FIRING_ONLY|GUN_SMOKE_PARTICLES
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)

	attachable_allowed = list(
		/obj/item/attachable/scope/unremovable/heavymachinegun,
	)

	starting_attachment_types = list(
		/obj/item/attachable/scope/unremovable/heavymachinegun,
	)

	deploy_time = 8 SECONDS
	undeploy_time = 3 SECONDS
	deployable_item = /obj/machinery/deployable/mounted/moveable

	max_integrity = 200
	soft_armor = list(MELEE = 0, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 50, BIO = 100, FIRE = 0, ACID = 20)



//-------------------------------------------------------
//MG-27 Medium Machine Gun

/obj/item/weapon/gun/standard_mmg
	name = "\improper MG-27 medium machinegun"
	desc = "The MG-27 is the SG-29s aging IFF-less cousin, made for rapid accurate machinegun fire in a short amount of time, you could use it while standing, not a great idea. Use the tripod for actual combat. It uses 10x27mm boxes."
	flags_equip_slot = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	icon = 'icons/Marine/marine-mmg.dmi'
	icon_state = "t27"
	item_state = "t27"
	caliber = CALIBER_10x27_CASELESS // codex
	max_shells = 150 //codex
	force = 40
	aim_slowdown = 1.2
	wield_delay = 2 SECONDS
	fire_sound = 'sound/weapons/guns/fire/tgmc/kinetic/gun_mg27.ogg'
	fire_rattle = 'sound/weapons/guns/fire/tgmc/kinetic/gun_mg27_low.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/m41a_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/T42_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/T42_reload.ogg'
	default_ammo_type = /obj/item/ammo_magazine/standard_mmg
	allowed_ammo_types = list(/obj/item/ammo_magazine/standard_mmg)
	attachable_allowed = list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/motiondetector,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/flashlight/under,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/bayonetknife/som,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/scope/unremovable/mmg,
		/obj/item/attachable/stock/t27,
	)

	starting_attachment_types = list(/obj/item/attachable/stock/t27)
	attachable_offset = list("muzzle_x" = 45, "muzzle_y" = 19,"rail_x" = 18, "rail_y" = 24, "under_x" = 28, "under_y" = 13, "stock_x" = 0, "stock_y" = 0)

	flags_item = IS_DEPLOYABLE|TWOHANDED
	flags_gun_features = GUN_AMMO_COUNTER|GUN_WIELDED_FIRING_ONLY|GUN_SMOKE_PARTICLES
	deployable_item = /obj/machinery/deployable/mounted
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)
	actions_types = list(/datum/action/item_action/aim_mode)
	aim_fire_delay = 0.05 SECONDS
	aim_speed_modifier = 5
	soft_armor = list(MELEE = 0, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 50, BIO = 100, FIRE = 0, ACID = 0)


	scatter = 30 // you're not firing this standing.
	deployed_scatter_change = -70 // innumerable amount of reduced scatter when deployed,
	recoil = 2
	scatter_unwielded = 45
	accuracy_mult = 1.1 //it's got a bipod
	fire_delay = 0.15 SECONDS
	burst_amount = 1
	deploy_time = 1 SECONDS
	damage_falloff_mult = 0.25
	undeploy_time = 0.5 SECONDS
	max_integrity = 200


/obj/item/weapon/gun/standard_mmg/machinegunner
	starting_attachment_types = list(/obj/item/attachable/stock/t27, /obj/item/attachable/scope/unremovable/mmg)

/obj/item/weapon/gun/clf_heavyrifle
	name = "\improper PTR-41/1785 anti-mech gun"
	desc = "The PTR-41/1785 is a bottom shelf solution modernized for dealing with armor, while one could use it while standing it is obviously not a great idea. It is recommended to be used while the bipod is deployed. It uses 14.5mm high velocity rounds that will certainly leave a hole in whatever unfortunate soul is hit by it."
	w_class = WEIGHT_CLASS_BULKY
	icon = 'icons/Marine/clf_heavyrifle.dmi'
	icon_state = "ptrs"
	item_state = "ptrs"
	item_icons = list(
		slot_l_hand_str = 'icons/mob/items_lefthand_64.dmi',
		slot_r_hand_str = 'icons/mob/items_righthand_64.dmi',
	)
	inhand_x_dimension = 64
	inhand_y_dimension = 32
	caliber = CALIBER_14X5 // codex
	max_shells = 5 //codex
	max_chamber_items = 5
	force = 30
	fire_sound = 'sound/weapons/guns/fire/ptrs.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/m41a_empty.ogg'
	reload_sound = 'sound/weapons/guns/interact/shotgun_shell_insert.ogg'
	hand_reload_sound = 'sound/weapons/guns/interact/shotgun_shell_insert.ogg'
	cocked_sound = 'sound/weapons/guns/interact/shotgun_reload.ogg'
	opened_sound = 'sound/weapons/guns/interact/shotgun_open.ogg'
	flags_gun_features = GUN_AMMO_COUNTER|GUN_WIELDED_FIRING_ONLY|GUN_WIELDED_STABLE_FIRING_ONLY
	reciever_flags = AMMO_RECIEVER_HANDFULS
	default_ammo_type = /datum/ammo/bullet/sniper/clf_heavyrifle
	attachable_allowed = list(
		/obj/item/attachable/motiondetector,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/flashlight/under,
		/obj/item/attachable/stock/clf_heavyrifle,
		/obj/item/attachable/scope,
	)

	starting_attachment_types = list(/obj/item/attachable/stock/clf_heavyrifle)
	attachable_offset = list("muzzle_x" = 45, "muzzle_y" = 19,"rail_x" = 18, "rail_y" = 24, "under_x" = 28, "under_y" = 13, "stock_x" = 8, "stock_y" = 0)

	flags_item = IS_DEPLOYABLE|TWOHANDED
	flags_gun_features = GUN_AMMO_COUNTER|GUN_WIELDED_FIRING_ONLY
	deployable_item = /obj/machinery/deployable/mounted
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)
	actions_types = list(/datum/action/item_action/aim_mode)
	aim_fire_delay = 2 SECONDS
	aim_speed_modifier = 3
	soft_armor = list(MELEE = 0, BULLET = 50, LASER = 0, ENERGY = 0, BOMB = 50, BIO = 100, FIRE = 0, ACID = 0)


	scatter = 16
	deployed_scatter_change = -16
	recoil = 4
	scatter_unwielded = 45
	accuracy_mult = 1
	burst_amount = 1
	fire_delay = 1.35 SECONDS
	aim_slowdown = 2
	deploy_time = 1 SECONDS // Meant to be used by ERT's
	undeploy_time = 0.25 SECONDS
	movement_acc_penalty_mult = 20 // Good luck hitting on the move, bruv

//-------------------------------------------------------
//AT-36 Anti Tank Gun

/obj/item/weapon/gun/standard_atgun
	name = "\improper AT-36 anti tank gun"
	desc = "The AT-36 is a light dual purpose anti tank and anti personnel weapon used by the TGMC. Used for light vehicle or bunker busting on a short notice. Best used by two people. It can move around with wheels, and has an ammo rack intergral to the weapon. CANNOT BE UNDEPLOYED ONCE DEPLOYED! It uses several types of 37mm shells boxes. Alt-right click on it to anchor it so that it cannot be moved by anyone, then alt-right click again to move it."
	w_class = WEIGHT_CLASS_BULKY
	icon = 'icons/Marine/marine-atgun.dmi'
	icon_state = "tat36"
	item_state = "tat36"
	caliber = CALIBER_37MM // codex
	max_shells = 1 //codex
	fire_sound = 'sound/weapons/guns/fire/tat36.ogg'
	reload_sound = 'sound/weapons/guns/interact/tat36_reload.ogg'
	default_ammo_type = /obj/item/ammo_magazine/standard_atgun
	allowed_ammo_types = list(
		/obj/item/ammo_magazine/standard_atgun,
		/obj/item/ammo_magazine/standard_atgun/apcr,
		/obj/item/ammo_magazine/standard_atgun/he,
		/obj/item/ammo_magazine/standard_atgun/beehive,
		/obj/item/ammo_magazine/standard_atgun/incend,
	)
	attachable_offset = list("muzzle_x" = 45, "muzzle_y" = 20,"rail_x" = 18, "rail_y" = 22, "under_x" = 28, "under_y" = 13, "stock_x" = 0, "stock_y" = 0)
	starting_attachment_types = list(/obj/item/attachable/scope/unremovable/standard_atgun)
	attachable_allowed = list(/obj/item/attachable/scope/unremovable/standard_atgun)

	flags_item = IS_DEPLOYABLE|TWOHANDED|DEPLOYED_NO_PICKUP|DEPLOY_ON_INITIALIZE|DEPLOYED_NO_ROTATE_ANCHORED|DEPLOYED_ANCHORED_FIRING_ONLY
	flags_gun_features = GUN_AMMO_COUNTER|GUN_DEPLOYED_FIRE_ONLY|GUN_WIELDED_FIRING_ONLY|GUN_SMOKE_PARTICLES

	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO)
	actions_types = list(/datum/action/item_action/aim_mode)
	aim_time = 6 SECONDS
	reciever_flags = AMMO_RECIEVER_MAGAZINES|AMMO_RECIEVER_AUTO_EJECT
	soft_armor = list(MELEE = 60, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 50, BIO = 100, FIRE = 0, ACID = 0)

	scatter = 0
	recoil = 3
	fire_delay = 3 SECONDS
	burst_amount = 1
	undeploy_time = 2000 SECONDS
	max_integrity = 500
	deployable_item = /obj/machinery/deployable/mounted/moveable/atgun

/obj/machinery/deployable/mounted/moveable/atgun
	var/obj/item/storage/internal/ammo_rack/sponson = /obj/item/storage/internal/ammo_rack
	resistance_flags = XENO_DAMAGEABLE|UNACIDABLE
	coverage = 85 //has a shield
	anchor_time = 1 SECONDS

/obj/machinery/deployable/mounted/moveable/atgun/Destroy()
	if(sponson)
		QDEL_NULL(sponson)
	return ..()

/obj/item/storage/internal/ammo_rack
	storage_slots = 10
	max_storage_space = 40
	max_w_class = WEIGHT_CLASS_BULKY
	can_hold = list(/obj/item/ammo_magazine/standard_atgun)

/obj/machinery/deployable/mounted/moveable/atgun/Initialize(mapload)
	. = ..()
	sponson = new sponson(src)

/obj/machinery/deployable/mounted/moveable/atgun/attackby(obj/item/I, mob/user, params)
	var/obj/item/weapon/gun/standard_atgun/internal_gun = get_internal_item()
	if(user.interactee == src && (I.type in internal_gun?.allowed_ammo_types))
		balloon_alert(user, "Busy manning!")
		return

	return . = ..()

/obj/machinery/deployable/mounted/moveable/atgun/attack_hand_alternate(mob/living/user)
	return sponson.open(user)

/obj/item/storage/internal/ammo_rack/handle_mousedrop(mob/user, obj/over_object)
	if(!ishuman(user) || user.lying_angle || user.incapacitated())
		return FALSE

	if(over_object == user && Adjacent(user)) //This must come before the screen objects only block
		open(user)
		return FALSE

/obj/machinery/deployable/mounted/moveable/atgun/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			take_damage(800, BRUTE, BOMB)
		if(EXPLODE_HEAVY)
			take_damage(rand(150, 200), BRUTE, BOMB)
		if(EXPLODE_LIGHT)
			take_damage(rand(50, 100), BRUTE, BOMB)
		if(EXPLODE_WEAK)
			take_damage(rand(25, 50), BRUTE, BOMB)

//AGLS-37, or Automatic Grenade Launching System 37, a fully automatic mounted grenade launcher that fires fragmentation and HE shells, can't be turned.

/obj/item/weapon/gun/standard_agls
	name = "\improper AGLS-37 Kauser automatic grenade launcher"
	desc = "The AGLS-37 automatic grenade launching IFF capable system, it's too heavy to be wielded or operated without the tripod. On the back, it reads: \"The Explosions and Fragmentation from this weapon ARE NOT friendly fire capable. Kauser is not obligated to buy you new body parts for you or your friends if you lose them.\"\nCan be deployed with Crtl-Click. It CANNOT be turned once deployed, due to a lack of swivels, pick it up to move your cone of fire. Can be repaired with a blowtorch once deployed."
	w_class = WEIGHT_CLASS_HUGE
	flags_equip_slot = ITEM_SLOT_BACK
	caliber = CALIBER_40MM
	icon = 'icons/Marine/marine-hmg.dmi'
	icon_state = "ags"
	fire_sound = 'sound/weapons/guns/fire/ags.ogg'
	reload_sound = 'sound/weapons/guns/interact/minigun_cocked.ogg'
	default_ammo_type = /obj/item/ammo_magazine/standard_agls
	scatter = 0
	fire_delay = 1.1 SECONDS
	burst_amount = 0
	accuracy_mult = 1.2 //it's got a bipod
	flags_item = IS_DEPLOYABLE|TWOHANDED
	flags_gun_features = GUN_AMMO_COUNTER|GUN_DEPLOYED_FIRE_ONLY|GUN_WIELDED_FIRING_ONLY
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)

	attachable_allowed = list(
		/obj/item/attachable/scope/unremovable/standard_atgun,
	)

	starting_attachment_types = list(
		/obj/item/attachable/scope/unremovable/standard_atgun,
	)

	allowed_ammo_types = list(
		/obj/item/ammo_magazine/standard_agls,
		/obj/item/ammo_magazine/standard_agls/fragmentation,
		/obj/item/ammo_magazine/standard_agls/incendiary,
		/obj/item/ammo_magazine/standard_agls/flare,
		/obj/item/ammo_magazine/standard_agls/cloak,
		/obj/item/ammo_magazine/standard_agls/tanglefoot,
	)

	deploy_time = 6 SECONDS
	undeploy_time = 3 SECONDS
	deployable_item = /obj/machinery/deployable/mounted


	max_integrity = 300
	soft_armor = list(MELEE = 0, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 50, BIO = 100, FIRE = 0, ACID = 20)

/obj/item/weapon/gun/standard_agls/do_fire(obj/object_to_fire)
	. = ..()
	if(!.)
		return FALSE
	if(istype(in_chamber, /obj/item/ammo_magazine/standard_agls/incendiary))
		gun_user?.record_war_crime()


// Non-TGMC HMG

/obj/item/weapon/gun/icc_hmg
	name = "\improper KRD-61ES mounted heavy machinegun"
	desc = "The KRD-61ES machinegun is the export variant of the ML-91 HMG. It's too heavy to be wielded or operated without the tripod. No extra work required, just deploy it with Ctrl-Click. Can be repaired with a blowtorch once deployed."
	icon = 'icons/Marine/marine-mmg.dmi'
	icon_state = "kord"

	fire_sound = 'sound/weapons/guns/fire/hmg2.ogg'
	reload_sound = 'sound/weapons/guns/interact/minigun_cocked.ogg'

	w_class = WEIGHT_CLASS_HUGE
	flags_equip_slot = ITEM_SLOT_BACK

	scatter = 10
	deployed_scatter_change = -10
	accuracy_mult = 1.2 //it's got a bipod
	fire_delay = 0.25 SECONDS

	default_ammo_type = /obj/item/ammo_magazine/icc_hmg

	allowed_ammo_types = list(
		/obj/item/ammo_magazine/icc_hmg,
	)

	flags_item = IS_DEPLOYABLE|TWOHANDED
	flags_gun_features = GUN_AMMO_COUNTER|GUN_DEPLOYED_FIRE_ONLY|GUN_WIELDED_FIRING_ONLY|GUN_SMOKE_PARTICLES
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)
	actions_types = list(/datum/action/item_action/aim_mode)
	aim_fire_delay = 0.05 SECONDS
	aim_speed_modifier = 5

	attachable_allowed = list(
		/obj/item/attachable/scope/unremovable/tl102,
	)

	starting_attachment_types = list(
		/obj/item/attachable/scope/unremovable/tl102,
	)

	deploy_time = 1.5 SECONDS
	undeploy_time = 0.5 SECONDS
	deployable_item = /obj/machinery/deployable/mounted

	max_integrity = 200
	soft_armor = list(MELEE = 0, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 50, BIO = 100, FIRE = 0, ACID = 20)

	allowed_ammo_types = list(
		/obj/item/ammo_magazine/icc_hmg,
	)
