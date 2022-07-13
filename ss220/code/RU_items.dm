SUBSYSTEM_DEF(ru_items)
	name = "RU_items"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_RU_ITEMS
	runlevels = RUNLEVEL_INIT


	var/list/items = list(
		/obj/item/ammo_magazine/smg/vector = -1,
		/obj/item/ammo_magazine/packet/acp_smg = -1,
	)

	var/list/items_val = list(
		/obj/item/weapon/gun/smg/vector = -1,
		/obj/item/ammo_magazine/smg/vector = -1,
		/obj/item/ammo_magazine/packet/acp_smg = -1,
		/obj/item/weapon/twohanded/glaive/harvester = -1,
		/obj/item/clothing/head/helmet/marine/robot/advanced/acid = -1,
		/obj/item/clothing/suit/storage/marine/robot/advanced/acid = -1,
		/obj/item/clothing/head/helmet/marine/robot/advanced/physical = -1,
		/obj/item/clothing/suit/storage/marine/robot/advanced/physical = -1,
		/obj/item/clothing/head/helmet/marine/robot/advanced/bomb = -1,
		/obj/item/clothing/suit/storage/marine/robot/advanced/bomb = -1,
		/obj/item/clothing/head/helmet/marine/robot/advanced/fire = -1,
		/obj/item/clothing/suit/storage/marine/robot/advanced/fire = -1,
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


//List all custom items here

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
	cost = 20


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
	cost = 40



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
	icon = 'ss220/icons/item/Roboarmor.dmi'
	item_icons = list(
		slot_head_str = 'ss220/icons/item/Roboarmor.dmi',
	)

/obj/item/clothing/suit/storage/marine/robot/advanced
	flags_item_map_variant = 0
	icon = 'ss220/icons/item/Roboarmor.dmi'
	item_icons = list(
		slot_wear_suit_str = 'ss220/icons/item/Roboarmor.dmi',
	)
	pockets = /obj/item/storage/internal/modular/general

/obj/item/clothing/head/helmet/marine/robot/advanced/acid
	name = "\improper Exidobate upper armor plating"
	desc = "Heavy armor plating designed for self mounting on the upper half of TerraGov combat robotics. It has self-sealing bolts for mounting on robotic owners inside. It was created for the survival of robots in places with high acid concentration. Uses the already known technology of nickel-gold plates to protect important modules in the upper part of the robot"
	soft_armor = list("melee" = 50, "bullet" = 60, "laser" = 65, "energy" = 65, "bomb" = 50, "bio" = 65, "rad" = 50, "fire" = 40, "acid" = 75)

	icon_state = "robo_helm_acid"
	item_state = "robo_helm_acid"

/obj/item/clothing/suit/storage/marine/robot/advanced/acid
	name = "\improper Exidobate armor plating"
	desc = "Heavy armor plating designed for self mounting on TerraGov combat robotics. It has self-sealing bolts for mounting on robotic owners inside. It was created for the survival of robots in places with high acid concentration. Armor uses nickel and golden plate technology for perfect protection against acids."
	soft_armor = list("melee" = 50, "bullet" = 70, "laser" = 80, "energy" = 80, "bomb" = 50, "bio" = 80, "rad" = 50, "fire" = 60, "acid" = 75)
	slowdown = 0.7

	icon_state = "robo_armor_acid"
	item_state = "robo_armor_acid"

/obj/item/clothing/head/helmet/marine/robot/advanced/physical
	name = "\improper Cingulata upper armor plating"
	desc = "Heavy armor plating designed for self mounting on the upper half of TerraGov combat robotics. It has self-sealing bolts for mounting on robotic owners inside. It was based on the Colonial Police Special Forces helmet and redesigned by engineers for robots. The helmet received a reinforced lining as well as a base, which added protection from aggressive fauna and firearms."
	soft_armor = list("melee" = 75, "bullet" = 80, "laser" = 50, "energy" = 50, "bomb" = 50, "bio" = 50, "rad" = 50, "fire" = 20, "acid" = 50)

	icon_state = "robo_helm_physical"
	item_state = "robo_helm_physical"

/obj/item/clothing/suit/storage/marine/robot/advanced/physical
	name = "\improper Cingulata armor plating"
	desc = "Heavy armor plating designed for self mounting on TerraGov combat robotics. It has self-sealing bolts for mounting on robotic owners inside. Originally it was created as a police plate armor for robots  anti-terrorist operations, but later the chief engineers remade it for the needs of the TGMC. The armor received additional plates to protect against aggressive fauna and firearms."
	soft_armor = list("melee" = 75, "bullet" = 85, "laser" = 70, "energy" = 70, "bomb" = 50, "bio" = 50, "rad" = 50, "fire" = 50, "acid" = 60)
	slowdown = 0.7

	icon_state = "robo_armor_physical"
	item_state = "robo_armor_physical"

/obj/item/clothing/head/helmet/marine/robot/advanced/bomb
	name = "\improper Tardigrada upper armor plating"
	desc = "Heavy armor plating designed for self mounting on the upper half of TerraGov combat robotics. It has self-sealing bolts for mounting on robotic owners inside.The upper part of the armor was specially designed for robots, as cases of head loss in robots due to mine and grenade explosions have become more frequent. Helmet  has a reinforced attachment to the main part, which, according to scientists, will lead to a decrease in cases of loss of important modules. It has increased protection against shock waves and explosions."
	soft_armor = list("melee" = 60, "bullet" = 60, "laser" = 50, "energy" = 50, "bomb" = 90, "bio" = 50, "rad" = 50, "fire" = 20, "acid" = 50)

	icon_state = "robo_helm_bomb"
	item_state = "robo_helm_bomb"

/obj/item/clothing/suit/storage/marine/robot/advanced/bomb
	name = "\improper Tardigrada armor plating"
	desc = "Heavy armor plating designed for self mounting on TerraGov combat robotics. It has self-sealing bolts for mounting on robotic owners inside. This armor was specially designed to work with explosives and mines. Often it was installed on old robots of sappers and engineers to increase their survival rate. The armor is equipped with reinforced protection against shock waves and explosions."
	soft_armor = list("melee" = 60, "bullet" = 70, "laser" = 70, "energy" = 70, "bomb" = 90, "bio" = 50, "rad" = 50, "fire" = 50, "acid" = 60)
	slowdown = 0.7

	icon_state = "robo_armor_bomb"
	item_state = "robo_armor_bomb"

/obj/item/clothing/head/helmet/marine/robot/advanced/fire
	name = "\improper Urodela upper armor plating"
	desc = "Heavy armor plating designed for self mounting on the upper half of TerraGov combat robotics. It has self-sealing bolts for mounting on robotic owners inside.The top armor made from fireproof glass-like material. This is done in order not to reduce the effectiveness of the robot's tracking modules. The glass itself can withstand high temperatures and a short stay in lava."
	soft_armor = list("melee" = 50, "bullet" = 50, "laser" = 80, "energy" = 50, "bomb" = 50, "bio" = 50, "rad" = 50, "fire" = 100, "acid" = 50)
	hard_armor = list("fire" = 200)

	icon_state = "robo_helm_fire"
	item_state = "robo_helm_fire"

/obj/item/clothing/suit/storage/marine/robot/advanced/fire
	name = "\improper Urodela armor plating"
	desc = "Heavy armor plating designed for self mounting on TerraGov combat robotics. It has self-sealing bolts for mounting on robotic owners inside. The armor is inspired by the mining exosuits used on lava planets. Upgraded by TeraGova engineers for robots that use a flamethrower and work in an environment of elevated temperatures. Armor protects important modules and wiring from fire and lava, which gives robots high survivability in fire."
	soft_armor = list("melee" = 50, "bullet" = 60, "laser" = 80, "energy" = 70, "bomb" = 50, "bio" = 50, "rad" = 50, "fire" = 100, "acid" = 60)
	hard_armor = list("fire" = 200)
	slowdown = 0.5

	icon_state = "robo_armor_fire"
	item_state = "robo_armor_fire"

/datum/supply_packs/armor/robot/advanced/acid
	name = "Exidobate acid protection armor set"
	contains = list(
		/obj/item/clothing/head/helmet/marine/robot/advanced/acid,
		/obj/item/clothing/suit/storage/marine/robot/advanced/acid,
	)
	cost = 60
	available_against_xeno_only = TRUE

/datum/supply_packs/armor/robot/advanced/physical
	name = "Cingulata physical protection armor set"
	contains = list(
		/obj/item/clothing/head/helmet/marine/robot/advanced/physical,
		/obj/item/clothing/suit/storage/marine/robot/advanced/physical,
	)
	cost = 60
	available_against_xeno_only = TRUE

/datum/supply_packs/armor/robot/advanced/bomb
	name = "Tardigrada bomb protection armor set"
	contains = list(
		/obj/item/clothing/head/helmet/marine/robot/advanced/bomb,
		/obj/item/clothing/suit/storage/marine/robot/advanced/bomb,
	)
	cost = 60
	available_against_xeno_only = TRUE

/datum/supply_packs/armor/robot/advanced/fire
	name = "Urodela fire protection armor set"
	contains = list(
		/obj/item/clothing/head/helmet/marine/robot/advanced/fire,
		/obj/item/clothing/suit/storage/marine/robot/advanced/fire,
	)
	cost = 60
	available_against_xeno_only = TRUE
