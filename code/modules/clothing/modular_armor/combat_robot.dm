//Robot armour
/obj/item/clothing/suit/modular/robot
	name = "XR-1 armor plating"
	desc = "Medium armor plating designed for self mounting on TerraGov combat robotics. It has self-sealing bolts for mounting on robotic owners inside."
	icon = 'icons/mob/modular/robot_armor.dmi'
	item_icons = list(slot_wear_suit_str = 'icons/mob/modular/robot_armor.dmi')
	icon_state = "robot_medium"
	item_state = "robot_medium"
	species_exception = list(/datum/species/robot)
	soft_armor = list(MELEE = 45, BULLET = 65, LASER = 65, ENERGY = 55, BOMB = 50, BIO = 50, FIRE = 50, ACID = 55)
	slowdown = SLOWDOWN_ARMOR_MEDIUM

	attachments_allowed = list(
		/obj/item/armor_module/module/better_shoulder_lamp,
		/obj/item/armor_module/module/fire_proof,
		/obj/item/armor_module/module/tyr_extra_armor,
		/obj/item/armor_module/module/tyr_extra_armor/mark1,
		/obj/item/armor_module/module/hlin_explosive_armor,
		/obj/item/armor_module/module/ballistic_armor,
		/obj/item/armor_module/module/eshield,

		/obj/item/armor_module/storage/general,
		/obj/item/armor_module/storage/ammo_mag,
		/obj/item/armor_module/storage/engineering,
		/obj/item/armor_module/storage/medical,
		/obj/item/armor_module/storage/general/som,
		/obj/item/armor_module/storage/engineering/som,
		/obj/item/armor_module/storage/medical/som,
		/obj/item/armor_module/storage/injector,
		/obj/item/armor_module/storage/grenade,
		/obj/item/armor_module/storage/integrated,
		/obj/item/armor_module/greyscale/badge,
	)

	allowed_uniform_type = /obj/item/clothing/under/marine/robotic

	flags_item_map_variant = ITEM_JUNGLE_VARIANT|ITEM_ICE_VARIANT|ITEM_DESERT_VARIANT
	icon_state_variants = list(
		"black",
		"jungle",
		"desert",
		"snow",
		"alpha",
		"bravo",
		"charlie",
		"delta",
	)

	current_variant = "black"

/obj/item/clothing/suit/modular/robot/mob_can_equip(mob/M, slot, warning, override_nodrop)
	. = ..()
	if(!isrobot(M))
		to_chat(M, span_warning("You can't equip this as it requires mounting bolts on your body!"))
		return FALSE

/obj/item/clothing/suit/modular/robot/light
	name = "XR-1-L armor plating"
	desc = "Light armor plating designed for self mounting on TerraGov combat robotics. It has self-sealing bolts for mounting on robotic owners inside."
	icon_state = "robot_light"
	item_state = "robot_light"
	soft_armor = list(MELEE = 40, BULLET = 60, LASER = 60, ENERGY = 55, BOMB = 50, BIO = 50, FIRE = 50, ACID = 50)
	slowdown = SLOWDOWN_ARMOR_LIGHT

/obj/item/clothing/suit/modular/robot/heavy
	name = "XR-1-H armor plating"
	desc = "Heavy armor plating designed for self mounting on TerraGov combat robotics. It has self-sealing bolts for mounting on robotic owners inside."
	icon_state = "robot_heavy"
	item_state = "robot_heavy"
	soft_armor = list(MELEE = 50, BULLET = 70, LASER = 70, ENERGY = 55, BOMB = 50, BIO = 50, FIRE = 50, ACID = 60)
	slowdown = SLOWDOWN_ARMOR_HEAVY

//robot hats
/obj/item/clothing/head/modular/robot
	name = "XN-1 upper armor plating"
	desc = "Medium armor plating designed for self mounting on the upper half of TerraGov combat robotics. It has self-sealing bolts for mounting on robotic owners inside."
	icon = 'icons/mob/modular/robot_helmets.dmi'
	item_icons = list(
		slot_head_str = 'icons/mob/modular/robot_helmets.dmi',
		slot_l_hand_str = 'icons/mob/items_lefthand_1.dmi',
		slot_r_hand_str = 'icons/mob/items_righthand_1.dmi',
	)
	icon_state = "robot_medium"
	item_state = "robot_medium"
	species_exception = list(/datum/species/robot)
	flags_item_map_variant = (ITEM_JUNGLE_VARIANT|ITEM_ICE_VARIANT|ITEM_PRISON_VARIANT)
	soft_armor = list(MELEE = 50, BULLET = 70, LASER = 70, ENERGY = 60, BOMB = 50, BIO = 50, FIRE = 50, ACID = 60)

	attachments_allowed = list(
		/obj/item/armor_module/module/tyr_head,
		/obj/item/armor_module/module/hod_head,
		/obj/item/armor_module/module/binoculars,
		/obj/item/armor_module/module/binoculars/artemis_mark_two,
		/obj/item/armor_module/module/artemis,
		/obj/item/armor_module/module/antenna,
		/obj/item/armor_module/storage/helmet,
		/obj/item/armor_module/greyscale/badge,
		/obj/item/armor_module/greyscale/visor/robot,
		/obj/item/armor_module/greyscale/visor/robot/light,
		/obj/item/armor_module/greyscale/visor/robot/heavy,
	)
	starting_attachments = list(/obj/item/armor_module/storage/helmet, /obj/item/armor_module/greyscale/visor/robot)
	flags_item_map_variant = ITEM_JUNGLE_VARIANT|ITEM_ICE_VARIANT|ITEM_DESERT_VARIANT

	icon_state_variants = list(
		"black",
		"jungle",
		"desert",
		"snow",
		"alpha",
		"bravo",
		"charlie",
		"delta",
	)

	current_variant = "black"

/obj/item/clothing/head/modular/robot/mob_can_equip(mob/M, slot, warning, override_nodrop)
	. = ..()
	if(!isrobot(M))
		to_chat(M, span_warning("You can't equip this as it requires mounting bolts on your body!"))
		return FALSE

/obj/item/clothing/head/modular/robot/light
	name = "XN-1-L upper armor plating"
	desc = "Light armor plating designed for self mounting on the upper half of TerraGov combat robotics. It has self-sealing bolts for mounting on robotic owners inside."
	icon_state = "robot_light"
	item_state = "robot_light"
	starting_attachments = list(/obj/item/armor_module/storage/helmet, /obj/item/armor_module/greyscale/visor/robot/light)

/obj/item/clothing/head/modular/robot/heavy
	name = "XN-1-H upper armor plating"
	desc = "Heavy armor plating designed for self mounting on the upper half of TerraGov combat robotics. It has self-sealing bolts for mounting on robotic owners inside."
	icon_state = "robot_heavy"
	item_state = "robot_heavy"
	starting_attachments = list(/obj/item/armor_module/storage/helmet, /obj/item/armor_module/greyscale/visor/robot/heavy)
