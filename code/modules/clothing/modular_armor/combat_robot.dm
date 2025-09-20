//Robot armour
/obj/item/clothing/suit/modular/robot
	name = "\improper XR-1 armor plating"
	desc = "Medium armor plating designed for self mounting on TerraGov combat robotics. It has self-sealing bolts for mounting on robotic owners inside."

	worn_icon_list = list(slot_wear_suit_str = 'icons/mob/modular/robot_armor.dmi')
	icon_state = "chest"
	worn_icon_state = "chest"
	species_exception = list(/datum/species/robot)
	soft_armor = MARINE_ARMOR_MEDIUM
	slowdown = SLOWDOWN_ARMOR_MEDIUM

	colorable_colors = LEGACY_ARMOR_PALETTES_LIST
	colorable_allowed = PRESET_COLORS_ALLOWED
	greyscale_config = /datum/greyscale_config/robot
	greyscale_colors = ARMOR_PALETTE_BLACK

	attachments_allowed = list(
		/obj/item/armor_module/module/better_shoulder_lamp,
		/obj/item/armor_module/module/fire_proof,
		/obj/item/armor_module/module/tyr_extra_armor,
		/obj/item/armor_module/module/tyr_extra_armor/mark1,
		/obj/item/armor_module/module/mimir_environment_protection,
		/obj/item/armor_module/module/mimir_environment_protection/mark1,
		/obj/item/armor_module/module/hlin_explosive_armor,
		/obj/item/armor_module/module/ballistic_armor,
		/obj/item/armor_module/module/eshield,
		/obj/item/armor_module/module/mirage,
		/obj/item/armor_module/module/armorlock,

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
		/obj/item/armor_module/armor/badge,
	)

	allowed_uniform_type = /obj/item/clothing/under/marine/robotic

	item_map_variant_flags = ITEM_JUNGLE_VARIANT|ITEM_ICE_VARIANT|ITEM_DESERT_VARIANT

/obj/item/clothing/suit/modular/robot/mob_can_equip(mob/user, slot, warning = TRUE, override_nodrop = FALSE, bitslot = FALSE)
	. = ..()
	if(!isrobot(user))
		to_chat(user, span_warning("You can't equip this as it requires mounting bolts on your body!"))
		return FALSE

//---- Medium armor with attachments
/obj/item/clothing/suit/modular/robot/hodgrenades
	starting_attachments = list(
		/obj/item/armor_module/module/ballistic_armor,
		/obj/item/armor_module/storage/grenade,
	)

/obj/item/clothing/suit/modular/robot/lightgeneral
	starting_attachments = list(
		/obj/item/armor_module/module/better_shoulder_lamp,
		/obj/item/armor_module/storage/general,
	)

/obj/item/clothing/suit/modular/robot/lightengineer
	starting_attachments = list(
		/obj/item/armor_module/module/better_shoulder_lamp,
		/obj/item/armor_module/storage/engineering,
	)

/obj/item/clothing/suit/modular/robot/lightinjector
	starting_attachments = list(
		/obj/item/armor_module/module/better_shoulder_lamp,
		/obj/item/armor_module/storage/injector,
	)

/obj/item/clothing/suit/modular/robot/light
	name = "\improper XR-1-L armor plating"
	desc = "Light armor plating designed for self mounting on TerraGov combat robotics. It has self-sealing bolts for mounting on robotic owners inside."
	soft_armor = MARINE_ARMOR_LIGHT
	slowdown = SLOWDOWN_ARMOR_LIGHT
	greyscale_config = /datum/greyscale_config/robot/light

//---- Light armor with attachments
/obj/item/clothing/suit/modular/robot/light/lightmedical
	starting_attachments = list(
		/obj/item/armor_module/module/better_shoulder_lamp,
		/obj/item/armor_module/storage/medical,
	)


/obj/item/clothing/suit/modular/robot/heavy
	name = "\improper XR-1-H armor plating"
	desc = "Heavy armor plating designed for self mounting on TerraGov combat robotics. It has self-sealing bolts for mounting on robotic owners inside."
	soft_armor = MARINE_ARMOR_HEAVY
	slowdown = SLOWDOWN_ARMOR_HEAVY
	greyscale_config = /datum/greyscale_config/robot/heavy

//---- Heavy armor with attachments
/obj/item/clothing/suit/modular/robot/heavy/tyr_onegeneral
	starting_attachments = list(
		/obj/item/armor_module/module/tyr_extra_armor/mark1,
		/obj/item/armor_module/storage/general,
	)

/obj/item/clothing/suit/modular/robot/heavy/lightengineer
	starting_attachments = list(
		/obj/item/armor_module/module/better_shoulder_lamp,
		/obj/item/armor_module/storage/engineering,
	)

/obj/item/clothing/suit/modular/robot/heavy/tyr
	starting_attachments = list(
		/obj/item/armor_module/module/tyr_extra_armor,
		/obj/item/armor_module/storage/engineering,
	)

/obj/item/clothing/suit/modular/robot/heavy/shield
	starting_attachments = list(
		/obj/item/armor_module/module/eshield,
		/obj/item/armor_module/storage/engineering,
	)

//robot hats
/obj/item/clothing/head/modular/robot
	name = "\improper XN-1 upper armor plating"
	desc = "Medium armor plating designed for self mounting on the upper half of TerraGov combat robotics. It has self-sealing bolts for mounting on robotic owners inside."
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/items/items_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/items/items_right.dmi',
	)
	icon_state = "helmet"
	worn_icon_state = "helmet"
	species_exception = list(/datum/species/robot)
	item_map_variant_flags = (ITEM_JUNGLE_VARIANT|ITEM_ICE_VARIANT|ITEM_PRISON_VARIANT)
	soft_armor = MARINE_ARMOR_HEAVY

	colorable_colors = LEGACY_ARMOR_PALETTES_LIST
	colorable_allowed = PRESET_COLORS_ALLOWED
	greyscale_config = /datum/greyscale_config/robot
	greyscale_colors = ARMOR_PALETTE_BLACK

	attachments_allowed = list(
		/obj/item/armor_module/module/tyr_head,
		/obj/item/armor_module/module/fire_proof_helmet,
		/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet,
		/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet/mark1,
		/obj/item/armor_module/module/hod_head,
		/obj/item/armor_module/module/binoculars,
		/obj/item/armor_module/module/binoculars/artemis_mark_two,
		/obj/item/armor_module/module/artemis,
		/obj/item/armor_module/module/antenna,
		/obj/item/armor_module/module/night_vision,
		/obj/item/armor_module/storage/helmet,
		/obj/item/armor_module/armor/badge,
		/obj/item/armor_module/armor/visor/marine/robot,
		/obj/item/armor_module/armor/visor/marine/robot/light,
		/obj/item/armor_module/armor/visor/marine/robot/heavy,
	)
	starting_attachments = list(/obj/item/armor_module/storage/helmet, /obj/item/armor_module/armor/visor/marine/robot)
	item_map_variant_flags = ITEM_JUNGLE_VARIANT|ITEM_ICE_VARIANT|ITEM_DESERT_VARIANT


/obj/item/clothing/head/modular/robot/mob_can_equip(mob/user, slot, warning = TRUE, override_nodrop = FALSE, bitslot = FALSE)
	. = ..()
	if(!isrobot(user))
		to_chat(user, span_warning("You can't equip this as it requires mounting bolts on your body!"))
		return FALSE

//---- Medium helmets with attachments
/obj/item/clothing/head/modular/robot/hod
	starting_attachments = list(/obj/item/armor_module/storage/helmet, /obj/item/armor_module/armor/visor/marine/robot, /obj/item/armor_module/module/hod_head)

/obj/item/clothing/head/modular/robot/light
	name = "\improper XN-1-L upper armor plating"
	desc = "Light armor plating designed for self mounting on the upper half of TerraGov combat robotics. It has self-sealing bolts for mounting on robotic owners inside."
	starting_attachments = list(/obj/item/armor_module/storage/helmet, /obj/item/armor_module/armor/visor/marine/robot/light)
	greyscale_config = /datum/greyscale_config/robot/light

/obj/item/clothing/head/modular/robot/heavy
	name = "\improper XN-1-H upper armor plating"
	desc = "Heavy armor plating designed for self mounting on the upper half of TerraGov combat robotics. It has self-sealing bolts for mounting on robotic owners inside."
	starting_attachments = list(/obj/item/armor_module/storage/helmet, /obj/item/armor_module/armor/visor/marine/robot/heavy)
	greyscale_config = /datum/greyscale_config/robot/heavy

/obj/item/clothing/head/modular/robot/heavy/tyr
	starting_attachments = list(/obj/item/armor_module/storage/helmet, /obj/item/armor_module/armor/visor/marine/robot/heavy, /obj/item/armor_module/module/tyr_head)

/obj/item/clothing/head/modular/robot/antenna
	starting_attachments = list(/obj/item/armor_module/storage/helmet, /obj/item/armor_module/armor/visor/marine/robot/heavy, /obj/item/armor_module/module/antenna)
