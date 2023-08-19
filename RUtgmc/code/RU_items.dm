SUBSYSTEM_DEF(ru_items)
	name = "RU_items"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_RU_ITEMS
	runlevels = RUNLEVEL_INIT


	var/list/items = list(
		/obj/item/ammo_magazine/smg/vector = -1,
		/obj/item/ammo_magazine/packet/acp_smg = -1,
		/obj/item/weapon/gun/revolver/standard_revolver/coltrifle = -1,
		/obj/item/ammo_magazine/revolver/rifle = -1,
		/obj/item/ammo_magazine/packet/long_special = -1,
		/obj/item/ammo_magazine/revolver/t500 = -1,
		/obj/item/ammo_magazine/packet/t500 = -1,
		/obj/item/storage/belt/gun/revolver/t500 = -1,
		/obj/item/storage/box/t500case = 5,
		/obj/item/ammo_magazine/som_mg = 20,
		/obj/item/mortar_kit/knee = 2,
		/obj/item/mortal_shell/knee = 40,
		/obj/item/storage/belt/mortar_belt = -1,
	)

	var/list/items_val = list(
		/obj/item/weapon/gun/smg/vector = -1,
		/obj/item/ammo_magazine/smg/vector = -1,
		/obj/item/ammo_magazine/packet/acp_smg = -1,
		/obj/item/weapon/twohanded/glaive/harvester = -1,
		/obj/item/weapon/gun/revolver/standard_revolver/coltrifle = -1,
		/obj/item/ammo_magazine/revolver/rifle = -1,
		/obj/item/ammo_magazine/packet/long_special = -1,
		/obj/item/ammo_magazine/rifle/T25/extended = -1,
		/obj/item/clothing/head/helmet/marine/robot/advanced/acid = -1,
		/obj/item/clothing/suit/storage/marine/robot/advanced/acid = -1,
		/obj/item/clothing/head/helmet/marine/robot/advanced/physical = -1,
		/obj/item/clothing/suit/storage/marine/robot/advanced/physical = -1,
		/obj/item/clothing/head/helmet/marine/robot/advanced/bomb = -1,
		/obj/item/clothing/suit/storage/marine/robot/advanced/bomb = -1,
		/obj/item/clothing/head/helmet/marine/robot/advanced/fire = -1,
		/obj/item/clothing/suit/storage/marine/robot/advanced/fire = -1,
	)

	var/list/clothes = list(
		/obj/item/clothing/head/tgmcberet/squad/black = -1,
		/obj/item/clothing/head/tgmcberet/squad/black/bravo = -1,
		/obj/item/clothing/head/tgmcberet/squad/black/delta = -1,
		/obj/item/clothing/head/tgmcberet/squad/black/charlie = -1,
		/obj/item/clothing/under/marine/ru/black = -1,
		/obj/item/clothing/under/marine/ru/black/bravo = -1,
		/obj/item/clothing/under/marine/ru/black/delta = -1,
		/obj/item/clothing/under/marine/ru/black/charlie = -1,
		/obj/item/clothing/glasses/ru/orange = 1,
		/obj/item/storage/backpack/marine/scav = -1,
		/obj/item/clothing/under/marine/ru/slav = -1,
		/obj/item/clothing/under/marine/ru/camo = -1,
		/obj/item/clothing/shoes/marine/ru/headskin = -1,
		/obj/item/clothing/shoes/marine/coolcowboy = -1,
	)

// Override init of vendors
/obj/machinery/vending/Initialize(mapload, ...)
	build_ru_items()
	. = ..()


/obj/machinery/vending/proc/build_ru_items()
	return

/obj/machinery/vending/weapon/build_ru_items()
	products["Imports"] = SSru_items.items

/obj/machinery/vending/weapon/valhalla/build_ru_items()
	products["Imports"] = SSru_items.items_val

/obj/machinery/vending/uniform_supply/build_ru_items()
	products["Imports"] = SSru_items.clothes

//List all custom items here

///////////////////////////////////////////////////////////////////////
//////// Сoltrifle, based on Colt Model 1855 Revolving Rifle. /////////
///////////////////////////////////////////////////////////////////////

/obj/item/weapon/gun/revolver/standard_revolver/coltrifle
	name = "\improper M1855 Revolving Rifle"
	desc = "A revolver and carbine hybrid, designed and manufactured a long time ago by Crowford Armory Union. Popular back then, but completely obsolete today. Still used by some antiquity lovers."
	icon = 'icons/marine/gun64.dmi'
	icon_state = "coltrifle"
	item_state = "coltrifle"
	fire_animation = "coltrifle_fire"
	fire_sound = 'sound/weapons/guns/fire/mateba.ogg'
	gun_skill_category = SKILL_RIFLES
	flags_equip_slot = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	caliber = CALIBER_44LS
	max_chamber_items = 8
	default_ammo_type = /obj/item/ammo_magazine/revolver/rifle
	allowed_ammo_types = list(/obj/item/ammo_magazine/revolver/rifle)
	force = 20

	scatter = 3
	recoil = 3
	scatter_unwielded = 10
	recoil_unwielded = 6
	recoil_backtime_multiplier = 2
	recoil_deviation = 360 //real party

	fire_delay = 0.25 SECONDS
	aim_fire_delay = 0.25 SECONDS
	upper_akimbo_accuracy = 6
	lower_akimbo_accuracy = 3
	akimbo_additional_delay = 1
	aim_slowdown = 0.3

	attachable_allowed = list(
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/reddot,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
	)
	attachable_offset = list("muzzle_x" = 50, "muzzle_y" = 21,"rail_x" = 24, "rail_y" = 22)

/obj/item/ammo_magazine/revolver/rifle
	name = "\improper M1855 speed loader (.44LS)"
	desc = "A speed loader for the M1855, with special design to make it possible to speedload a rifle. Longer version of .44 Magnum, with uranium-neodimium core."
	default_ammo = /datum/ammo/bullet/revolver/rifle
	caliber = CALIBER_44LS
	max_rounds = 8
	icon_state = "44LS"

/obj/item/ammo_magazine/packet/long_special
	name = "box of .44 Long Special"
	desc = "A box containing 40 rounds of .44 Long Special."
	icon_state = "44LSbox"
	default_ammo = /datum/ammo/bullet/revolver/rifle
	caliber = CALIBER_44LS
	current_rounds = 40
	icon_state_mini = "44LSbox"
	max_rounds = 40

/datum/ammo/bullet/revolver/rifle
	name = ".44 Long Special bullet"
	hud_state = "revolver_impact"
	handful_amount = 8
	damage = 60
	penetration = 30
	sundering = 3
	damage_falloff = 0
	shell_speed = 3.5

/datum/ammo/bullet/revolver/highimpact/on_hit_mob(mob/M,obj/projectile/P)
	staggerstun(M, P, knockback = 2)

///////////////////////////////////////////////////////////////////////
////////////////////////  T25, old version .///////////////////////////
///////////////////////////////////////////////////////////////////////

/obj/item/weapon/gun/rifle/T25
	name = "\improper T-25 smartrifle"
	desc = "The T-25 is the TGMC's current standard IFF-capable rifle. It's known for its ability to lay down quick fire support very well. Requires special training and it cannot turn off IFF. It uses 10x26mm ammunition."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "T25"
	item_state = "T25"
	caliber = CALIBER_10x26_CASELESS //codex
	max_shells = 80 //codex
	force = 20
	aim_slowdown = 0.5
	wield_delay = 0.9 SECONDS
	fire_sound = "gun_smartgun"
	dry_fire_sound = 'sound/weapons/guns/fire/m41a_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/T42_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/T42_reload.ogg'
	default_ammo_type = /obj/item/ammo_magazine/rifle/T25
	allowed_ammo_types = list(/obj/item/ammo_magazine/rifle/T25, /obj/item/ammo_magazine/rifle/T25/extended)
	attachable_allowed = list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/foldable/bipod,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/suppressor,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/compensator,
		/obj/item/weapon/gun/pistol/plasma_pistol,
		/obj/item/weapon/gun/flamer/mini_flamer,
		/obj/item/attachable/motiondetector,
	)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_WIELDED_FIRING_ONLY|GUN_IFF
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_AUTOMATIC)
	gun_skill_category = SKILL_SMARTGUN //Uses SG skill for the penalties.
	attachable_offset = list("muzzle_x" = 42, "muzzle_y" = 17,"rail_x" = 15, "rail_y" = 21, "under_x" = 24, "under_y" = 14, "stock_x" = 12, "stock_y" = 13)

	fire_delay = 0.2 SECONDS
	burst_amount = 0
	accuracy_mult_unwielded = 0.5
	accuracy_mult = 1.2
	scatter = -5
	scatter_unwielded = 60

/obj/item/ammo_magazine/rifle/T25
	name = "\improper T-25 magazine (10x26mm)"
	desc = "A 10mm assault rifle magazine."
	caliber = CALIBER_10x26_CASELESS
	icon_state = "T25"
	w_class = WEIGHT_CLASS_NORMAL
	default_ammo = /datum/ammo/bullet/rifle/T25
	max_rounds = 80
	icon_state_mini = "mag_rifle_big"

/datum/ammo/bullet/rifle/T25
	name = "smartmachinegun bullet"
	bullet_color = COLOR_SOFT_RED //Red bullets to indicate friendly fire restriction
	hud_state = "smartgun"
	hud_state_empty = "smartgun_empty"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING
	accurate_range = 20
	damage = 20
	penetration = 10
	sundering = 1.5

/obj/item/ammo_magazine/packet/T25_rifle
	name = "box of 10x26mm high-pressure"
	desc = "A box containing 300 rounds of 10x26mm 'HP' caseless tuned for a smartgun."
	icon_state = "box_t25"
	default_ammo = /datum/ammo/bullet/rifle/T25
	caliber = CALIBER_10x26_CASELESS
	current_rounds = 300
	max_rounds = 300

/datum/supply_packs/weapons/rifle/T25
	name = "T25 smartrifle"
	contains = list(/obj/item/weapon/gun/rifle/T25)
	cost = 400

/datum/supply_packs/weapons/ammo_magazine/rifle/T25
	name = "T25 smartrifle magazine"
	contains = list(/obj/item/ammo_magazine/rifle/T25)
	cost = 20

/datum/supply_packs/weapons/ammo_magazine/packet/T25_rifle
	name = "T25 smartrifle ammo box"
	contains = list(/obj/item/ammo_magazine/packet/T25_rifle)
	cost = 60

///////////////////////////////////////////////////////////////////////
////////////// Vector, based on KRISS Vector 45ACP. ///////////////////
///////////////////////////////////////////////////////////////////////
/obj/item/weapon/gun/smg/vector
	name = "\improper Vector storm submachinegun"
	desc = "The Vector is the TerraGov Marine Corps depelopment to increase assault capability of marines. Lightweight and simple to use. It features delayed blowback system, heavily reducing recoil even with its high ROF. A highly-customizable platform, it is reliable and versatile. Ideal weapon for quick assaults. Uses extended .45 ACP HP magazines"
	fire_sound = 'sound/weapons/guns/fire/tp23.ogg'
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "v45"
	item_state = "v45"
	caliber = CALIBER_45ACP //codex
	max_shells = 25 //codex
	flags_equip_slot = ITEM_SLOT_BACK
	force = 20
	type_of_casings = null
	default_ammo_type = /obj/item/ammo_magazine/smg/vector
	allowed_ammo_types = list(
		/obj/item/ammo_magazine/smg/vector
	)
	attachable_allowed = list(
		/obj/item/attachable/suppressor,
		/obj/item/attachable/reddot,
		/obj/item/attachable/compensator,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/flashlight/under,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/motiondetector,
		/obj/item/attachable/buildasentry,
		/obj/item/attachable/shoulder_mount,
		/obj/item/weapon/gun/pistol/plasma_pistol,
		/obj/item/weapon/gun/shotgun/combat/masterkey,
		/obj/item/weapon/gun/flamer/mini_flamer,
		/obj/item/weapon/gun/grenade_launcher/underslung,
	)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 16, "rail_x" = 22, "rail_y" = 19, "under_x" = 26, "under_y" = 14, "stock_x" = 24, "stock_y" = 10)
	actions_types = list(/datum/action/item_action/aim_mode)

	fire_delay = 0.1 SECONDS
	damage_mult = 1
	recoil = -5  // Recoil blowback system
	recoil_unwielded = -2
	wield_delay = 0.3 SECONDS

	akimbo_additional_delay = 0.5
	aim_fire_delay = 0.1 SECONDS
	aim_speed_modifier = 0 //no slowdown
	aim_slowdown = 0

	accuracy_mult = 1
	accuracy_mult_unwielded = 0.75 //moving or akimbo yield lower acc
	scatter = -2
	scatter_unwielded = 6 // Not exactly small weapon, and recoil blowback is only for vertical recoil

	movement_acc_penalty_mult = 0.1
	upper_akimbo_accuracy = 5
	lower_akimbo_accuracy = 5


/obj/item/ammo_magazine/smg/vector
	name = "\improper Vector drum magazine (.45ACP)"
	desc = "A .45ACP HP caliber drum magazine for the Vector, with even more dakka."
	default_ammo = /datum/ammo/bullet/smg/acp
	w_class = WEIGHT_CLASS_SMALL
	caliber = CALIBER_45ACP
	icon_state = "ppsh_ext"
	max_rounds = 40 // HI-Point .45 ACP Drum mag


/datum/ammo/bullet/smg/acp
	name = "submachinegun ACP bullet"
	hud_state = "smg"
	hud_state_empty = "smg_empty"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING
	accuracy_var_low = 7
	accuracy_var_high = 7
	damage = 20
	accurate_range = 4
	damage_falloff = 1
	sundering = 0.4
	penetration = 0
	shrapnel_chance = 25


/obj/item/ammo_magazine/packet/acp_smg
	name = "box of .45 ACP HP"
	desc = "A box containing common .45 ACP hollow-point rounds."
	icon_state = "box_45acp"
	default_ammo = /datum/ammo/bullet/smg/acp
	w_class = WEIGHT_CLASS_SMALL
	caliber = CALIBER_45ACP
	current_rounds = 120
	max_rounds = 120


/datum/supply_packs/weapons/vector
	name = "Vector"
	contains = list(/obj/item/weapon/gun/smg/vector)
	cost = 200


///////////////////////////////////////////////////////////////////////
////////////////// VAL-HAL-A, the Vali Halberd ////////////////////////
///////////////////////////////////////////////////////////////////////

/obj/item/weapon/twohanded/glaive/harvester
	name = "\improper VAL-HAL-A halberd harvester"
	desc = "TerraGov Marine Corps' cutting-edge 'Harvester' halberd, with experimental plasma regulator. An advanced weapon that combines sheer force with the ability to apply a variety of debilitating effects when loaded with certain reagents, but should be used with both hands. Activate after loading to prime a single use of an effect. It also harvests substances from alien lifeforms it strikes when connected to the Vali system."
	icon_state = "VAL-HAL-A"
	item_state = "VAL-HAL-A"
	force = 40
	force_wielded = 95 //Reminder: putting trama inside deals 60% additional damage
	flags_item = DRAINS_XENO | TWOHANDED
	resistance_flags = 0 //override glavie
	attack_speed = 10 //Default is 7, this has slower attack
	reach = 2 //like spear
	slowdown = 0 //Slowdown in back slot
	var/wielded_slowdown = 0.5 //Slowdown in hands, wielded
	var/wield_delay = 0.8 SECONDS

/obj/item/weapon/twohanded/glaive/harvester/Initialize()
	. = ..()
	AddComponent(/datum/component/harvester)

/datum/supply_packs/weapons/valihalberd
	name = "VAL-HAL-A"
	contains = list(/obj/item/weapon/twohanded/glaive/harvester)
	cost = 600



// Stuff which should ideally be in /twohanded code
///////////////////////////////////////////////////

#define MOVESPEED_ID_WIELDED_SLOWDOWN "WIELDED_SLOWDOWN"

/obj/item/weapon/twohanded/glaive/harvester/unwield(mob/user)
	. = ..()
	user.remove_movespeed_modifier(MOVESPEED_ID_WIELDED_SLOWDOWN)


/obj/item/weapon/twohanded/glaive/harvester/wield(mob/user)
	. = ..()

	if (!(flags_item & WIELDED))
		return

	if(wield_delay > 0)
		if (!do_mob(user, user, wield_delay, BUSY_ICON_HOSTILE, null, PROGRESS_CLOCK, ignore_flags = IGNORE_LOC_CHANGE))
			unwield(user)
			return

	user.add_movespeed_modifier(MOVESPEED_ID_WIELDED_SLOWDOWN, TRUE, 0, NONE, TRUE, wielded_slowdown)


///////////////////////////////////////////////////////////////////////
///////////////////////// Robotic armor ///////////////////////////////
///////////////////////////////////////////////////////////////////////

/obj/item/clothing/head/helmet/marine/robot/advanced
	flags_item_map_variant = 0
	icon = 'RUtgmc/icons/item/Roboarmor.dmi'
	item_icons = list(
		slot_head_str = 'RUtgmc/icons/item/Roboarmor.dmi',
	)

/obj/item/clothing/suit/storage/marine/robot/advanced
	flags_item_map_variant = 0
	icon = 'RUtgmc/icons/item/Roboarmor.dmi'
	item_icons = list(
		slot_wear_suit_str = 'RUtgmc/icons/item/Roboarmor.dmi',
	)
	pockets = /obj/item/storage/internal/modular/general

/obj/item/clothing/head/helmet/marine/robot/advanced/acid
	name = "\improper Exidobate upper armor plating"
	desc = "Heavy armor plating designed for self mounting on the upper half of TerraGov combat robotics. It has self-sealing bolts for mounting on robotic owners inside. It was created for the survival of robots in places with high acid concentration. Uses the already known technology of nickel-gold plates to protect important modules in the upper part of the robot"
	soft_armor = list(MELEE = 50, BULLET = 60, LASER = 65, ENERGY = 65, BOMB = 50, BIO = 65, FIRE = 40, ACID = 75)
	icon_state = "robo_helm_acid"
	item_state = "robo_helm_acid"

/obj/item/clothing/suit/storage/marine/robot/advanced/acid
	name = "\improper Exidobate armor plating"
	desc = "Heavy armor plating designed for self mounting on TerraGov combat robotics. It has self-sealing bolts for mounting on robotic owners inside. It was created for the survival of robots in places with high acid concentration. Armor uses nickel and golden plate technology for perfect protection against acids."
	soft_armor = list(MELEE = 50, BULLET = 70, LASER = 80, ENERGY = 80, BOMB = 50, BIO = 80, FIRE = 60, ACID = 75)
	slowdown = 0.7

	icon_state = "robo_armor_acid"
	item_state = "robo_armor_acid"

/obj/item/clothing/head/helmet/marine/robot/advanced/physical
	name = "\improper Cingulata upper armor plating"
	desc = "Heavy armor plating designed for self mounting on the upper half of TerraGov combat robotics. It has self-sealing bolts for mounting on robotic owners inside. It was based on the Colonial Police Special Forces helmet and redesigned by engineers for robots. The helmet received a reinforced lining as well as a base, which added protection from aggressive fauna and firearms."
	soft_armor = list(MELEE = 75, BULLET = 80, LASER = 50, ENERGY = 50, BOMB = 50, BIO = 50, FIRE = 20, ACID = 50)

	icon_state = "robo_helm_physical"
	item_state = "robo_helm_physical"

/obj/item/clothing/suit/storage/marine/robot/advanced/physical
	name = "\improper Cingulata armor plating"
	desc = "Heavy armor plating designed for self mounting on TerraGov combat robotics. It has self-sealing bolts for mounting on robotic owners inside. Originally it was created as a police plate armor for robots  anti-terrorist operations, but later the chief engineers remade it for the needs of the TGMC. The armor received additional plates to protect against aggressive fauna and firearms."
	soft_armor = list(MELEE = 75, BULLET = 85, LASER = 70, ENERGY = 70, BOMB = 50, BIO = 50, FIRE = 50, ACID = 60)
	slowdown = 0.7

	icon_state = "robo_armor_physical"
	item_state = "robo_armor_physical"

/obj/item/clothing/head/helmet/marine/robot/advanced/bomb
	name = "\improper Tardigrada upper armor plating"
	desc = "Heavy armor plating designed for self mounting on the upper half of TerraGov combat robotics. It has self-sealing bolts for mounting on robotic owners inside.The upper part of the armor was specially designed for robots, as cases of head loss in robots due to mine and grenade explosions have become more frequent. Helmet  has a reinforced attachment to the main part, which, according to scientists, will lead to a decrease in cases of loss of important modules. It has increased protection against shock waves and explosions."
	soft_armor = list(MELEE = 60, BULLET = 60, LASER = 50, ENERGY = 50, BOMB = 90, BIO = 50, FIRE = 20, ACID = 50)

	icon_state = "robo_helm_bomb"
	item_state = "robo_helm_bomb"

/obj/item/clothing/suit/storage/marine/robot/advanced/bomb
	name = "\improper Tardigrada armor plating"
	desc = "Heavy armor plating designed for self mounting on TerraGov combat robotics. It has self-sealing bolts for mounting on robotic owners inside. This armor was specially designed to work with explosives and mines. Often it was installed on old robots of sappers and engineers to increase their survival rate. The armor is equipped with reinforced protection against shock waves and explosions."
	soft_armor = list(MELEE = 60, BULLET = 70, LASER = 70, ENERGY = 70, BOMB = 90, BIO = 50, FIRE = 50, ACID = 60)
	slowdown = 0.7

	icon_state = "robo_armor_bomb"
	item_state = "robo_armor_bomb"

/obj/item/clothing/head/helmet/marine/robot/advanced/fire
	name = "\improper Urodela upper armor plating"
	desc = "Heavy armor plating designed for self mounting on the upper half of TerraGov combat robotics. It has self-sealing bolts for mounting on robotic owners inside.The top armor made from fireproof glass-like material. This is done in order not to reduce the effectiveness of the robot's tracking modules. The glass itself can withstand high temperatures and a short stay in lava."
	soft_armor = list(MELEE = 50, BULLET = 50, LASER = 80, ENERGY = 50, BOMB = 50, BIO = 50, FIRE = 100, ACID = 50)
	hard_armor = list("fire" = 200)

	icon_state = "robo_helm_fire"
	item_state = "robo_helm_fire"

/obj/item/clothing/suit/storage/marine/robot/advanced/fire
	name = "\improper Urodela armor plating"
	desc = "Heavy armor plating designed for self mounting on TerraGov combat robotics. It has self-sealing bolts for mounting on robotic owners inside. The armor is inspired by the mining exosuits used on lava planets. Upgraded by TeraGova engineers for robots that use a flamethrower and work in an environment of elevated temperatures. Armor protects important modules and wiring from fire and lava, which gives robots high survivability in fire."
	soft_armor = list(MELEE = 50, BULLET = 60, LASER = 80, ENERGY = 70, BOMB = 50, BIO = 50, FIRE = 100, ACID = 60)
	hard_armor = list(FIRE = 200)
	slowdown = 0.5

	icon_state = "robo_armor_fire"
	item_state = "robo_armor_fire"

/datum/supply_packs/armor/robot/advanced/acid
	name = "Exidobate acid protection armor set"
	contains = list(
		/obj/item/clothing/head/helmet/marine/robot/advanced/acid,
		/obj/item/clothing/suit/storage/marine/robot/advanced/acid,
	)
	cost = 600
	available_against_xeno_only = TRUE

/datum/supply_packs/armor/robot/advanced/physical
	name = "Cingulata physical protection armor set"
	contains = list(
		/obj/item/clothing/head/helmet/marine/robot/advanced/physical,
		/obj/item/clothing/suit/storage/marine/robot/advanced/physical,
	)
	cost = 600
	available_against_xeno_only = TRUE

/datum/supply_packs/armor/robot/advanced/bomb
	name = "Tardigrada bomb protection armor set"
	contains = list(
		/obj/item/clothing/head/helmet/marine/robot/advanced/bomb,
		/obj/item/clothing/suit/storage/marine/robot/advanced/bomb,
	)
	cost = 600
	available_against_xeno_only = TRUE

/datum/supply_packs/armor/robot/advanced/fire
	name = "Urodela fire protection armor set"
	contains = list(
		/obj/item/clothing/head/helmet/marine/robot/advanced/fire,
		/obj/item/clothing/suit/storage/marine/robot/advanced/fire,
	)
	cost = 600
	available_against_xeno_only = TRUE

/obj/item/toy/plush/pig
	name = "pig toy"
	desc = "Captain Dementy! Bring the pigs! Marines demand pigs!."
	icon = 'icons/obj/items/pig.dmi'
	item_icons = list(
		slot_l_hand_str = 'icons/mob/pig_lefthand.dmi',
		slot_r_hand_str = 'icons/mob/pig_righthand.dmi',)
	icon_state = "pig"
	item_state = "pig"
	attack_verb = list("oinks", "grunts")

/obj/item/toy/plush/pig/attack_self(mob/user)
	if(world.time > last_hug_time)
		user.visible_message(span_notice("[user] presses [src]! Oink! "), \
							span_notice("You press [src]. Oink! "))
		last_hug_time = world.time + 50 //5 second cooldown

/obj/item/toy/plush/pig/Initialize()
	. = ..()
	AddComponent(/datum/component/squeak, 'sound/items/khryu.ogg', 50)

/datum/supply_packs/supplies/pigs
	name = "Pig toys crate"
	contains = list(/obj/item/toy/plush/pig, /obj/item/toy/plush/pig, /obj/item/toy/plush/pig, /obj/item/toy/plush/pig, /obj/item/toy/plush/pig)
	cost = 100
	available_against_xeno_only = TRUE
	containertype = /obj/structure/closet/crate/supply

/obj/item/clothing/head/squadhb
	name = "\improper Alpha squad headband"
	desc = "Headband made from ultra-thin special cloth. Cloth thickness provides more than just a stylish fluttering of headband. You can tie around headband onto a helmet. This squad version of a headband has secret unique features created by the cloth coloring component. "
	icon = 'icons/obj/clothing/squad_hb.dmi'
	item_icons = list(
		slot_head_str = 'icons/mob/squadhb.dmi')
	icon_state = "asquadhb"
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)
	slowdown = -0.1
	w_class = WEIGHT_CLASS_TINY
	species_exception = list(/datum/species/robot, /datum/species/synthetic, /datum/species/human, /datum/species/early_synthetic, /datum/species/zombie)

/obj/item/clothing/head/squadhb/b
	name = "\improper Bravo squad headband"
	icon_state = "bsquadhb"

/obj/item/clothing/head/squadhb/c
	name = "\improper Charlie squad headband"
	icon_state = "csquadhb"

/obj/item/clothing/head/squadhb/d
	name = "\improper Delta squad headband"
	icon_state = "dsquadhb"

/obj/item/clothing/head/tgmcberet/squad
	name = "\improper Charlie squad beret"
	icon_state = "csberet"
	desc = "Military beret with TGMC marine squad insignia. This one belongs to the Charlie Squad."
	icon = 'icons/obj/clothing/squad_hb.dmi'
	item_icons = list(
		slot_head_str = 'icons/mob/squadhb.dmi')

/obj/item/clothing/head/tgmcberet/squad/delta
	name = "\improper Delta Squad beret"
	desc = "Military beret with TGMC marine squad insignia. This one belongs to the Delta Squad."
	icon_state = "dsberet"

/obj/item/clothing/head/tgmcberet/squad/alpha
	name = "\improper Alpha Squad beret"
	desc = "Military beret with TGMC marine squad insignia. This one belongs to the Alpha Squad."
	icon_state = "asberet"

/obj/item/clothing/head/tgmcberet/squad/bravo
	name = "\improper Bravo Squad beret"
	desc = "Military beret with TGMC marine squad insignia. This one belongs to the Bravo Squad."
	icon_state = "bsberet"

/obj/item/clothing/head/tgmcberet/commando
	name = "\improper Marines Commando beret"
	desc = "Dark Green beret with an old TGMC insignia on it."
	icon_state = "marcommandoberet"
	icon = 'icons/obj/clothing/squad_hb.dmi'
	item_icons = list(
		slot_head_str = 'icons/mob/squadhb.dmi')

/obj/item/clothing/head/tgmcberet/vdv
	name = "\improper Airborne beret"
	desc = "Blue badged beret that smells like ethanol and fountain water for some reason."
	icon_state = "russobluecamohat"
	icon = 'icons/obj/clothing/squad_hb.dmi'
	item_icons = list(
		slot_head_str = 'icons/mob/squadhb.dmi')

/obj/item/clothing/head/tgmcberet/medical
	name = "\improper Medical beret"
	desc = "A white beret with a green cross finely threaded into it. It has that sterile smell about it."
	icon_state = "medberet"
	icon = 'icons/obj/clothing/squad_hb.dmi'
	item_icons = list(
		slot_head_str = 'icons/mob/squadhb.dmi')

/obj/item/clothing/head/tgmcberet/hijab
	name = "\improper Black hijab"
	desc = "Encompassing cloth headwear worn by some human cultures and religions."
	icon = 'icons/obj/clothing/squad_hb.dmi'
	item_icons = list(
		slot_head_str = 'icons/mob/squadhb.dmi')
	icon_state = "hijab_black"
	flags_inv_hide = HIDEEARS|HIDETOPHAIR

/obj/item/clothing/head/tgmcberet/hijab/grey
	name = "\improper Grey hijab"
	icon_state = "hijab_grey"

/obj/item/clothing/head/tgmcberet/hijab/red
	name = "\improper Red hijab"
	icon_state = "hijab_red"

/obj/item/clothing/head/tgmcberet/hijab/blue
	name = "\improper Blue hijab"
	icon_state = "hijab_blue"

/obj/item/clothing/head/tgmcberet/hijab/brown
	name = "\improper Brown hijab"
	icon_state = "hijab_brown"

/obj/item/clothing/head/tgmcberet/hijab/white
	name = "\improper White hijab"
	icon_state = "hijab_white"

/obj/item/clothing/head/tgmcberet/hijab/turban
	name = "\improper White turban"
	desc = "A sturdy cloth, worn around the head."
	icon_state = "turban_black"

/obj/item/clothing/head/tgmcberet/hijab/turban/white
	name = "\improper White turban"
	icon_state = "turban_white"

/obj/item/clothing/head/tgmcberet/hijab/turban/red
	name = "\improper Red turban"
	icon_state = "turban_red"

/obj/item/clothing/head/tgmcberet/hijab/turban/blue
	name = "\improper Blue turban"
	icon_state = "turban_blue"

//////////////////////////////////////////////////////////////////////////
/////////////////////////// t500 revolver ////////////////////////////////
//////////////////////////////////////////////////////////////////////////
/obj/item/weapon/gun/revolver/t500
	name = "\improper R-500 BF revolver"
	desc = "The R-500 BF revolver, chambered in .500 Nigro Express. Hard to use, but hits as hard as it’s kicks your hand. This handgun made by BMSS, designed to be deadly, unholy force to stop everything what moves, so in exchange for it, revolver lacking recoil control and have tight cocking system. Because of its specific, handcanon niche, was produced in small numbers. Black & Metzer special attachments system can turn extremely powerful handgun to fullscale rifle, making it a weapon to surpass Metal Gear."
	icon = 'icons/Marine/t500.dmi'
	icon_state = "t500"
	item_icons = list(
		slot_l_hand_str = 'icons/mob/BFR_left.dmi',
		slot_r_hand_str = 'icons/mob/BFR_right.dmi',)
	item_state = "t500"
	caliber =  CALIBER_500 //codex
	max_chamber_items = 5 //codex
	default_ammo_type = /obj/item/ammo_magazine/revolver/t500
	allowed_ammo_types = list(/obj/item/ammo_magazine/revolver/t500, /datum/ammo/bullet/revolver/t500/qk)
	force = 20
	actions_types = null
	attachable_allowed = list(
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/stock/t500stock,
		/obj/item/attachable/t500barrelshort,
		/obj/item/attachable/t500barrel,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/flashlight/under,
		/obj/item/attachable/lace/t500,
	)
	attachable_offset = list("muzzle_x" = 0, "muzzle_y" = 0,"rail_x" = 0, "rail_y" = 0, "under_x" = 19, "under_y" = 13, "stock_x" = -19, "stock_y" = 0)
	windup_delay = 0.8 SECONDS
	windup_sound = 'sound/weapons/guns/fire/t500_start.ogg'
	fire_sound = 'sound/weapons/guns/fire/t500.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/t500_empty.ogg'
	fire_animation = "t500_fire"
	fire_delay = 0.8 SECONDS
	akimbo_additional_delay = 0.6
	accuracy_mult_unwielded = 0.9
	accuracy_mult = 1
	scatter_unwielded = 5
	scatter = -1
	recoil = 2
	recoil_unwielded = 3

//ammo
/obj/item/ammo_magazine/revolver/t500
	name = "\improper R-500 speed loader (.500)"
	icon_state = "t500"
	desc = "A R-500 BF revolver speed loader."
	default_ammo = /datum/ammo/bullet/revolver/t500
	flags_equip_slot = NONE
	caliber = CALIBER_500
	w_class = WEIGHT_CLASS_SMALL
	max_rounds = 5

/obj/item/ammo_magazine/packet/t500
	name = "packet of .500 Nigro Express"
	icon_state = "boxt500"
	default_ammo = /datum/ammo/bullet/revolver/t500
	caliber = CALIBER_500
	current_rounds = 50
	max_rounds = 50
	w_class = WEIGHT_CLASS_SMALL
	used_casings = 5

/obj/item/ammo_magazine/packet/t500/attack_hand_alternate(mob/living/user)
	if(current_rounds <= 0)
		to_chat(user, span_notice("[src] is empty. There is nothing to grab."))
		return
	create_handful(user)

/obj/item/ammo_magazine/packet/t500/qk
	name = "packet of .500 'Queen Killer'"
	icon_state = "boxt500_qk"
	default_ammo = /datum/ammo/bullet/revolver/t500/qk
	caliber = CALIBER_500
	current_rounds = 50
	max_rounds = 50
	w_class = WEIGHT_CLASS_SMALL
	used_casings = 5

/datum/ammo/bullet/revolver/t500
	name = ".500 Nigro Express revolver bullet"
	handful_icon_state = "nigro"
	handful_amount = 5
	damage = 100
	penetration = 40
	sundering = 0.5

/datum/ammo/bullet/revolver/t500/on_hit_mob(mob/M,obj/projectile/P)
	staggerstun(M, P, stagger = 0, slowdown = 0, knockback = 1)

/datum/ammo/bullet/revolver/t500/qk
	name = ".500 'Queen Killer' revolver bullet"
	handful_icon_state = "nigro_qk"
	handful_amount = 5
	damage = 100
	penetration = 40
	sundering = 0

/datum/ammo/bullet/revolver/t500/qk/on_hit_mob(mob/M,obj/projectile/P)
	if(isxenoqueen(M))
		var/mob/living/carbon/xenomorph/X = M
		X.apply_damage(30)
		staggerstun(M, P, stagger = 0, slowdown = 0, knockback = 0)
		to_chat(X, span_highdanger("Something burn inside you!"))
		return
	staggerstun(M, P, stagger = 0, slowdown = 0, knockback = 1)

// attachable
/obj/item/attachable/stock/t500stock
	name = "R-500 stock"
	desc = "Cool stock for cool revolver."
	flags_attach_features = ATTACH_REMOVABLE
	wield_delay_mod = 0.2 SECONDS
	delay_mod = -0.4 SECONDS
	icon = 'icons/Marine/t500.dmi'
	icon_state = "stock"
	size_mod = 1
	accuracy_mod = 0.15
	recoil_mod = -1
	recoil_unwielded_mod = 1
	scatter_mod = -2
	scatter_unwielded_mod = 5
	melee_mod = 10
	pixel_shift_x = 0
	pixel_shift_y = 0

/obj/item/attachable/t500barrel
	name = "R-500 extended barrel"
	desc = "Cool barrel for cool revolver"
	slot = ATTACHMENT_SLOT_MUZZLE
	delay_mod = -0.4 SECONDS
	icon = 'icons/Marine/t500.dmi'
	icon_state = "barrel"
	attach_shell_speed_mod = 1
	accuracy_mod = 0.15
	accuracy_unwielded_mod = 0.1
	scatter_mod = -3
	scatter_unwielded_mod = 3
	recoil_unwielded_mod = 1
	size_mod = 1
	pixel_shift_x = 0
	pixel_shift_y = 0

/obj/item/attachable/t500barrelshort
	name = "R-500 compensator"
	desc = "Cool compensator for cool revolver"
	slot = ATTACHMENT_SLOT_MUZZLE
	delay_mod = -0.2 SECONDS
	icon = 'icons/Marine/t500.dmi'
	icon_state = "shortbarrel"
	scatter_mod = -2
	recoil_mod = -0.5
	scatter_unwielded_mod = -5
	recoil_unwielded_mod = -1
	accuracy_unwielded_mod = 0.15
	size_mod = 0.5
	pixel_shift_x = 0
	pixel_shift_y = 0

/obj/item/attachable/lace/t500
	name = "R-500 lace"
	icon = 'icons/Marine/t500.dmi'
	slot = ATTACHMENT_SLOT_STOCK
	pixel_shift_x = 0
	pixel_shift_y = 0

// storage
/obj/item/storage/belt/gun/revolver/t500
	name = "\improper BM500 pattern BF revolver holster rig"
	desc = "The BM500 is the special modular belt for R-500 BF revolver."
	icon = 'icons/Marine/t500_belt.dmi'
	icon_state = "belt"
	max_w_class = 3.5
	can_hold = list(
		/obj/item/weapon/gun/revolver/t500,
		/obj/item/ammo_magazine/revolver/t500,
		/obj/item/ammo_magazine/packet/t500,
	)

/obj/item/storage/box/t500case
	name = "\improper R-500 special case"
	desc = "High-tech case made by BMSS for delivery their special weapons. Label on this case says: 'This is the greatest handgun ever made. Five bullets. More than enough to kill anything that moves'."
	icon = 'icons/Marine/t500.dmi'
	icon_state = "case"
	w_class = WEIGHT_CLASS_NORMAL
	max_w_class = 1
	storage_slots = 5
	max_storage_space = 1
	can_hold = list(
		/obj/item/attachable/stock/t500stock,
		/obj/item/attachable/lace/t500,
		/obj/item/attachable/t500barrelshort,
		/obj/item/attachable/t500barrel,
		/obj/item/weapon/gun/revolver/t500,
	)
	bypass_w_limit = list(
		/obj/item/attachable/stock/t500stock,
		/obj/item/attachable/lace/t500,
		/obj/item/attachable/t500barrelshort,
		/obj/item/attachable/t500barrel,
		/obj/item/weapon/gun/revolver/t500,
	)

/obj/item/storage/box/t500case/Initialize()
	. = ..()
	new /obj/item/attachable/stock/t500stock(src)
	new /obj/item/attachable/lace/t500(src)
	new /obj/item/attachable/t500barrelshort(src)
	new /obj/item/attachable/t500barrel(src)
	new /obj/item/weapon/gun/revolver/t500(src)

/datum/supply_packs/weapons/t500case
	name = "R-500 bundle"
	contains = list(/obj/item/storage/box/t500case)
	cost = 50

///////////////////////////////////////////////////////////////////////
/////////////////////////  BASED ITEMS  ///////////////////////////////
///////////////////////////////////////////////////////////////////////

// anime headband

/obj/item/clothing/head/hachimaki
	name = "\improper Ancient pilot headband and scarf kit"
	desc = "Ancient pilot kit of scarf that protects neck from cold wind and headband that protects face from sweat"
	icon = 'icons/obj/items/Banzai.dmi'
	item_icons = list(
		slot_head_str = 'icons/mob/Banzai.dmi')
	icon_state = "Banzai"
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)
	w_class = WEIGHT_CLASS_SMALL

	var/list/armor_overlays
	actions_types = list(/datum/action/item_action/toggle)
	flags_armor_features = ARMOR_LAMP_OVERLAY|ARMOR_NO_DECAP
	flags_item = SYNTH_RESTRICTED

/obj/item/clothing/head/hachimaki/attack_self(mob/user)
	var/mob/living/carbon/human/activator = user
	if(TIMER_COOLDOWN_CHECK(user, "Banzai"))
		user.balloon_alert(user, "You used that emote too recently")
		return
	TIMER_COOLDOWN_START(user, "Banzai", 7200 SECONDS)
	if(user.gender == FEMALE)
		user.balloon_alert(user, "Women can't use that")
	else
		activator.say("Tenno Heika Banzai!!")
		playsound(get_turf(user), 'sound/voice/banzai1.ogg', 30)

// namazlyk

/obj/structure/bed/namaz
	name = "Prayer rug"
	desc = "Very halal prayer rug."
	icon = 'icons/obj/items/priest.dmi'
	icon_state = "namaz"
	buckle_flags = CAN_BUCKLE|BUCKLE_PREVENTS_PULL
	buckle_lying = 0
	buckling_y = 6
	dir = NORTH
	foldabletype = /obj/item/namaz
	accepts_bodybag = FALSE
	base_bed_icon = "namaz"

/obj/item/namaz
	name = "Prayer rug"
	desc = "Very halal prayer rug."
	icon = 'icons/obj/items/priest.dmi'
	icon_state = "rolled_namaz"
	w_class = WEIGHT_CLASS_SMALL
	var/rollertype = /obj/structure/bed/namaz

/obj/item/namaz/attack_self(mob/user)
	deploy_roller(user, user.loc)

/obj/item/namaz/afterattack(obj/target, mob/user , proximity)
	if(!proximity)
		return
	if(isturf(target))
		var/turf/T = target
		if(!T.density)
			deploy_roller(user, target)

/obj/item/namaz/attackby(obj/item/I, mob/user, params)
	. = ..()

/obj/item/namaz/proc/deploy_roller(mob/user, atom/location)
	var/obj/structure/bed/namaz/R = new rollertype(location) // R is not need here, but i dont know how to delete this shit
	user.temporarilyRemoveItemFromInventory(src)
	user.visible_message(span_notice(" [user] puts [R] down."), span_notice(" You put [R] down."))
	qdel(src)


// ext mags

/obj/item/ammo_magazine/rifle/standard_skirmishrifle/extended
	name = "\improper AR-21 extended skirmish rifle magazine"
	desc = "A extended magazine filled with 10x25mm rifle rounds for the AR-21."
	icon_state = "t21_ext"
	max_rounds = 50
	icon_state_mini = "mag_rifle_big_yellow"
	bonus_overlay = "t21_ext"

/obj/item/ammo_magazine/rifle/T25/extended
	name = "\improper T-25 extended magazine (10x26mm)"
	desc = "A 10mm extended assault rifle magazine."
	icon_state = "T25_ext"
	max_rounds = 120
	icon_state_mini = "mag_rifle_big_yellow"
	bonus_overlay = "T25_ext"

/datum/supply_packs/weapons/T25_extended_mag
	name = "T25 extended magazine"
	contains = list(/obj/item/ammo_magazine/rifle/T25/extended)
	cost = 200
	containertype = /obj/structure/closet/crate/ammo

/datum/supply_packs/weapons/t21_extended_mag
	name = "AR-21 extended magazines pack"
	contains = list(/obj/item/ammo_magazine/rifle/standard_skirmishrifle/extended, /obj/item/ammo_magazine/rifle/standard_skirmishrifle/extended, /obj/item/ammo_magazine/rifle/standard_skirmishrifle/extended, /obj/item/ammo_magazine/rifle/standard_skirmishrifle/extended, /obj/item/ammo_magazine/rifle/standard_skirmishrifle/extended, /obj/item/ammo_magazine/rifle/standard_skirmishrifle/extended,/obj/item/ammo_magazine/rifle/standard_skirmishrifle/extended)
	cost = 350
	containertype = /obj/structure/closet/crate/ammo

/datum/supply_packs/weapons/t21_ap
	name = "AR-21 armor piercing magazine"
	contains = list(/obj/item/ammo_magazine/rifle/standard_skirmishrifle/ap)
	cost = 53 //30 rounds
	containertype = /obj/structure/closet/crate/ammo

/datum/supply_packs/weapons/t18_ap
	name = "AR-18 armor piercing magazine"
	contains = list(/obj/item/ammo_magazine/rifle/standard_carbine/ap)
	cost = 60 //36 rounds
	containertype = /obj/structure/closet/crate/ammo

/datum/supply_packs/weapons/t12_ap
	name = "AR-12 armor piercing magazine"
	contains = list(/obj/item/ammo_magazine/rifle/standard_assaultrifle/ap)
	cost = 80 //50 rounds
	containertype = /obj/structure/closet/crate/ammo

/datum/supply_packs/weapons/br64_ap
	name = "BR-64 armor piercing magazine"
	contains = list(/obj/item/ammo_magazine/rifle/standard_br/ap)
	cost = 60 //36 rounds
	containertype = /obj/structure/closet/crate/ammo

/datum/supply_packs/weapons/smg25_ap
	name = "SMG-25 armor piercing magazine"
	contains = list(/obj/item/ammo_magazine/smg/m25/ap)
	cost = 90 //60 rounds
	containertype = /obj/structure/closet/crate/ammo

/datum/supply_packs/weapons/box_10x24mm_ap
	name = "10x24mm armor piercing ammo box"
	contains = list(/obj/item/ammo_magazine/packet/p10x24mm/ap)
	cost = 240 //150 rounds
	containertype = /obj/structure/closet/crate/ammo

/datum/supply_packs/weapons/box_10x25mm_ap
	name = "10x25mm armor piercing ammo box"
	contains = list(/obj/item/ammo_magazine/packet/p10x25mm/ap)
	cost = 220 //125 rounds
	containertype = /obj/structure/closet/crate/ammo

/datum/supply_packs/weapons/box_10x265mm_ap
	name = "10x26.5mm armor piercing ammo box"
	contains = list(/obj/item/ammo_magazine/packet/p10x265mm/ap)
	cost = 160 //100 rounds
	containertype = /obj/structure/closet/crate/ammo

/datum/supply_packs/weapons/box_10x20mm_ap
	name = "10x20mm armor piercing ammo box"
	contains = list(/obj/item/ammo_magazine/packet/p10x20mm/ap)
	cost = 225 //150 rounds
	containertype = /obj/structure/closet/crate/ammo

// finka nkvd
/obj/item/weapon/combat_knife/nkvd
	name = "\improper Finka NKVD"
	icon_state = "upp_knife"
	item_state = "knife"
	desc = "Legendary Finka NKVD model 1934 with a 10-year warranty and delivery from 2 days."
	force = 40
	throwforce = 50
	throw_speed = 2
	throw_range = 8


/obj/effect/vendor_bundle/gorka_engineer
	gear_to_spawn = list(
		/obj/item/clothing/under/marine/ru/gorka_eng,
		/obj/item/clothing/shoes/marine/full,
		/obj/item/storage/box/MRE,
	)

/obj/effect/vendor_bundle/gorka_medic
	gear_to_spawn = list(
		/obj/item/clothing/under/marine/ru/gorka_med,
		/obj/item/clothing/shoes/marine/full,
		/obj/item/storage/box/MRE,
	)

// Knee mortar
/obj/item/mortar_kit/knee
	name = "\improper TA-10 knee mortar"
	desc = "A manual, crew-operated mortar system intended to rain down 50mm shells on anything it's aimed at, typically best known as a 'Knee' mortar. Cannot be actually fired from your kneecaps, so it needs to be set down first to fire. Has a light payload, but an extremely high rate of fire."
	icon = 'RUtgmc/icons/item/kneemortar.dmi'
	icon_state = "knee_mortar"
	max_integrity = 250
	w_class = WEIGHT_CLASS_NORMAL
	deployable_item = /obj/machinery/deployable/mortar/knee

/obj/machinery/deployable/mortar/knee
	offset_per_turfs = 12
	fire_sound = 'sound/weapons/guns/fire/kneemortar_fire.ogg'
	fall_sound = 'sound/weapons/guns/misc/kneemortar_whistle.ogg'
	minimum_range = 5
	allowed_shells = list(
		/obj/item/mortal_shell/knee,
		/obj/item/mortal_shell/flare,
	)

	cool_off_time = 4 SECONDS
	reload_time = 0.5 SECONDS
	fire_delay = 0.5 SECONDS
	max_spread = 6


/obj/item/mortal_shell/knee
	name = "\improper 50mm high explosive mortar shell"
	desc = "An 50mm mortar shell, loaded with a high explosive charge."
	icon = 'RUtgmc/icons/item/kneemortar.dmi'
	icon_state = "knee_mortar_he"
	w_class = WEIGHT_CLASS_TINY
	ammo_type = /datum/ammo/mortar/knee

/datum/ammo/mortar/knee
	name = "50mm shell"
	icon_state = "howi"
	shell_speed = 0.75

/datum/ammo/mortar/knee/drop_nade(turf/T)
	explosion(T, 0, 1, 4, 2)


/obj/item/storage/belt/mortar_belt
	name = "TA-10 mortar belt"
	desc = "A belt that holds a TA-10 50mm Mortar, rangefinder and a lot of ammo for it."
	icon = 'RUtgmc/icons/item/kneemortar.dmi'
	icon_state = "kneemortar_holster"
	item_state = "m4a3_holster"
	use_sound = null
	w_class = WEIGHT_CLASS_BULKY
	storage_type_limits = list(
		/obj/item/mortar_kit/knee = 1,
		/obj/item/binoculars = 1,
		/obj/item/compass = 1,
	)
	storage_slots = 24
	max_storage_space = 49
	max_w_class = 3

	can_hold = list(
		/obj/item/mortar_kit/knee,
		/obj/item/mortal_shell/knee,
		/obj/item/compass,
		/obj/item/binoculars,
	)

/obj/item/storage/belt/mortar_belt/full/Initialize()
	. = ..()
	new /obj/item/mortar_kit/knee(src)
	new /obj/item/binoculars/tactical/range(src)


/datum/supply_packs/explosives/knee_mortar
	name = "T-10K Knee Mortar"
	contains = list(/obj/item/mortar_kit/knee)
	cost = 125

/datum/supply_packs/explosives/knee_mortar_ammo
	name = "TA-10K knee mortar HE shell"
	contains = list(/obj/item/mortal_shell/knee, /obj/item/mortal_shell/knee)
	cost = 5
	available_against_xeno_only = TRUE
