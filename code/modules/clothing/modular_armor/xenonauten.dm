// Xenonauten suits

/obj/item/clothing/suit/modular/xenonauten
	name = "\improper Xenonauten-M pattern armored vest"
	desc = "A XN-M vest, also known as Xenonauten, a set vest with modular attachments made to work in many enviroments. This one seems to be a medium variant. Alt-Click to remove attached items. Use it to toggle the built-in flashlight."
	soft_armor = MARINE_ARMOR_MEDIUM
	icon_state = "chest"
	worn_icon_state = "chest"
	icon = null
	worn_icon_list = list(slot_wear_suit_str = 'icons/mob/modular/modular_armor.dmi')
	slowdown = SLOWDOWN_ARMOR_MEDIUM
	shows_bottom_genital = TRUE

	attachments_allowed = list(
		/obj/item/armor_module/module/better_shoulder_lamp,
		/obj/item/armor_module/module/valkyrie_autodoc,
		/obj/item/armor_module/module/fire_proof,
		/obj/item/armor_module/module/tyr_extra_armor,
		/obj/item/armor_module/module/tyr_extra_armor/mark1,
		/obj/item/armor_module/module/mimir_environment_protection,
		/obj/item/armor_module/module/mimir_environment_protection/mark1,
		/obj/item/armor_module/module/hlin_explosive_armor,
		/obj/item/armor_module/module/ballistic_armor,
		/obj/item/armor_module/module/chemsystem,
		/obj/item/armor_module/module/knight,
		/obj/item/armor_module/module/eshield,
		/obj/item/armor_module/module/eshield/absorbant/energy,
		/obj/item/armor_module/module/eshield/absorbant/ballistic,
		/obj/item/armor_module/module/eshield/overclocked,
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

	item_map_variant_flags = ITEM_JUNGLE_VARIANT|ITEM_ICE_VARIANT|ITEM_DESERT_VARIANT
	greyscale_config = /datum/greyscale_config/xenonaut
	colorable_allowed = PRESET_COLORS_ALLOWED
	colorable_colors = LEGACY_ARMOR_PALETTES_LIST
	greyscale_colors = ARMOR_PALETTE_BLACK

	allowed_uniform_type = /obj/item/clothing/under

/obj/item/clothing/suit/modular/xenonauten/hodgrenades
	starting_attachments = list(
		/obj/item/armor_module/module/ballistic_armor,
		/obj/item/armor_module/storage/grenade,
	)

/obj/item/clothing/suit/modular/xenonauten/engineer
	starting_attachments = list(
		/obj/item/armor_module/module/better_shoulder_lamp,
		/obj/item/armor_module/storage/engineering,
	)

/obj/item/clothing/suit/modular/xenonauten/mirage_engineer
	starting_attachments =  list(
		/obj/item/armor_module/module/mirage,
		/obj/item/armor_module/storage/engineering,
	)

/obj/item/clothing/suit/modular/xenonauten/lightmedical
	starting_attachments = list(
		/obj/item/armor_module/module/better_shoulder_lamp,
		/obj/item/armor_module/storage/medical,
	)

/obj/item/clothing/suit/modular/xenonauten/lightgeneral
	starting_attachments = list(
		/obj/item/armor_module/module/better_shoulder_lamp,
		/obj/item/armor_module/storage/general,
	)

/obj/item/clothing/suit/modular/xenonauten/mimir
	starting_attachments = list(
		/obj/item/armor_module/module/mimir_environment_protection/mark1,
		/obj/item/armor_module/storage/general,
	)

/obj/item/clothing/suit/modular/xenonauten/mimirinjector
	starting_attachments = list(
		/obj/item/armor_module/module/mimir_environment_protection/mark1,
		/obj/item/armor_module/storage/injector,
	)

/obj/item/clothing/suit/modular/xenonauten/shield
	starting_attachments = list(
		/obj/item/armor_module/module/eshield,
		/obj/item/armor_module/storage/medical,
	)

/obj/item/clothing/suit/modular/xenonauten/shield_overclocked
	starting_attachments = list(
		/obj/item/armor_module/module/eshield/overclocked,
		/obj/item/armor_module/storage/medical,
	)

/obj/item/clothing/suit/modular/xenonauten/shield_overclocked/medic
	starting_attachments = list(
		/obj/item/armor_module/module/eshield/overclocked,
		/obj/item/armor_module/storage/general,
	)

/obj/item/clothing/suit/modular/xenonauten/shield_overclocked/engineer
	starting_attachments = list(
		/obj/item/armor_module/module/eshield/overclocked,
		/obj/item/armor_module/storage/engineering,
	)

/obj/item/clothing/suit/modular/xenonauten/valk
	starting_attachments = list(
		/obj/item/armor_module/module/valkyrie_autodoc,
		/obj/item/armor_module/storage/medical,
	)

/obj/item/clothing/suit/modular/xenonauten/light
	name = "\improper Xenonauten-L pattern armored vest"
	desc = "A XN-L vest, also known as Xenonauten, a set vest with modular attachments made to work in many enviroments. This one seems to be a light variant. Alt-Click to remove attached items. Use it to toggle the built-in flashlight."
	soft_armor = MARINE_ARMOR_LIGHT
	slowdown = SLOWDOWN_ARMOR_LIGHT
	greyscale_config = /datum/greyscale_config/xenonaut/light

/obj/item/clothing/suit/modular/xenonauten/light/shield
	starting_attachments = list(
		/obj/item/armor_module/module/eshield,
		/obj/item/armor_module/storage/medical,
	)

/obj/item/clothing/suit/modular/xenonauten/light/shield_overclocked
	starting_attachments = list(
		/obj/item/armor_module/module/eshield/overclocked,
		/obj/item/armor_module/storage/medical,
	)

/obj/item/clothing/suit/modular/xenonauten/light/shield_overclocked/medic
	starting_attachments = list(
		/obj/item/armor_module/module/eshield/overclocked,
		/obj/item/armor_module/storage/general,
	)

/obj/item/clothing/suit/modular/xenonauten/light/shield_overclocked/engineer
	starting_attachments = list(
		/obj/item/armor_module/module/eshield/overclocked,
		/obj/item/armor_module/storage/engineering,
	)

/obj/item/clothing/suit/modular/xenonauten/light/lightmedical
	starting_attachments = list(
		/obj/item/armor_module/module/better_shoulder_lamp,
		/obj/item/armor_module/storage/medical,
	)

/obj/item/clothing/suit/modular/xenonauten/heavy
	name = "\improper Xenonauten-H pattern armored vest"
	desc = "A XN-H vest, also known as Xenonauten, a set vest with modular attachments made to work in many enviroments. This one seems to be a heavy variant. Alt-Click to remove attached items. Use it to toggle the built-in flashlight."
	soft_armor = MARINE_ARMOR_HEAVY
	slowdown = SLOWDOWN_ARMOR_HEAVY
	greyscale_config = /datum/greyscale_config/xenonaut/heavy

/obj/item/clothing/suit/modular/xenonauten/heavy/mimirengi
	starting_attachments = list(
		/obj/item/armor_module/module/mimir_environment_protection/mark1,
		/obj/item/armor_module/storage/engineering,
	)

/obj/item/clothing/suit/modular/xenonauten/heavy/leader
	starting_attachments = list(
		/obj/item/armor_module/module/valkyrie_autodoc,
		/obj/item/armor_module/storage/medical,
	)

/obj/item/clothing/suit/modular/xenonauten/heavy/tyr_onegeneral
	starting_attachments = list(
		/obj/item/armor_module/module/tyr_extra_armor/mark1,
		/obj/item/armor_module/storage/general,
	)

/obj/item/clothing/suit/modular/xenonauten/heavy/tyr_one
	starting_attachments = list(
		/obj/item/armor_module/module/tyr_extra_armor/mark1,
		/obj/item/armor_module/storage/medical,
	)

/obj/item/clothing/suit/modular/xenonauten/heavy/tyr_two
	starting_attachments = list(
		/obj/item/armor_module/module/tyr_extra_armor,
		/obj/item/armor_module/storage/medical,
	)

/obj/item/clothing/suit/modular/xenonauten/heavy/tyr_two/corpsman
	starting_attachments = list(
		/obj/item/armor_module/module/tyr_extra_armor,
		/obj/item/armor_module/storage/general,
	)

/obj/item/clothing/suit/modular/xenonauten/heavy/tyr_two/engineer
	starting_attachments = list(
		/obj/item/armor_module/module/tyr_extra_armor,
		/obj/item/armor_module/storage/engineering,
	)

/obj/item/clothing/suit/modular/xenonauten/heavy/grenadier //Literally grenades
	starting_attachments = list(
		/obj/item/armor_module/module/ballistic_armor,
		/obj/item/armor_module/storage/grenade,
	)

/obj/item/clothing/suit/modular/xenonauten/heavy/surt
	starting_attachments = list(
		/obj/item/armor_module/module/fire_proof,
		/obj/item/armor_module/storage/medical,
	)

/obj/item/clothing/suit/modular/xenonauten/heavy/shield
	starting_attachments = list(
		/obj/item/armor_module/module/eshield,
		/obj/item/armor_module/storage/medical,
	)

/obj/item/clothing/suit/modular/xenonauten/heavy/shield_overclocked
	starting_attachments = list(
		/obj/item/armor_module/module/eshield/overclocked,
		/obj/item/armor_module/storage/medical,
	)

/obj/item/clothing/suit/modular/xenonauten/heavy/npc_medic
	starting_attachments = list(
		/obj/item/armor_module/module/mimir_environment_protection/mark1,
		/obj/item/armor_module/storage/grenade,
	)

/obj/item/clothing/suit/modular/xenonauten/pilot
	name = "\improper NTC standard flak jacket"
	desc = "A flak jacket used by dropship pilots to protect themselves while flying in the cockpit. Excels in protecting the wearer against high-velocity solid projectiles."
	item_flags = NONE
	soft_armor = list(MELEE = 40, BULLET = 50, LASER = 50, ENERGY = 25, BOMB = 30, BIO = 5, FIRE = 25, ACID = 30)
	slowdown = 0.25

	greyscale_config = /datum/greyscale_config/xenonaut/pilot

	attachments_allowed = list()


	allowed = list(
		/obj/item/weapon/gun,
		/obj/item/tank/emergency_oxygen,
		/obj/item/flashlight,
		/obj/item/ammo_magazine,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/tool/lighter,
		/obj/item/weapon/baton,
		/obj/item/restraints/handcuffs,
		/obj/item/explosive/grenade,
		/obj/item/binoculars,
		/obj/item/weapon/combat_knife,
		/obj/item/attachable/bayonet,
		/obj/item/storage/belt/sparepouch,
		/obj/item/storage/holster/blade,
		/obj/item/storage/holster/belt,
		/obj/item/weapon/energy/sword,
	)

/obj/item/clothing/suit/storage/marine/ballistic
	name = "\improper Crasher multi-threat ballistic armor"
	desc = "A reused design of a old body armor system from the 21st century."
	soft_armor = list(MELEE = 40, BULLET = 50, LASER = 50, ENERGY = 25, BOMB = 30, BIO = 5, FIRE = 25, ACID = 30)
	slowdown = 0.25
	armor_protection_flags = CHEST|GROIN|ARMS|LEGS|FEET|HANDS
	icon = 'icons/mob/clothing/suits/marine_armor.dmi'
	icon_state = "ballistic_vest"
	worn_icon_list = list(
		slot_wear_suit_str = 'icons/mob/clothing/suits/marine_armor.dmi'
	)
	equip_delay_self = 2 SECONDS
	unequip_delay_self = 0 SECONDS
	armor_features_flags = NONE

	icon_state_variants = list(
		"urban",
		"jungle",
		"desert",
		"snow",
	)
	colorable_allowed = ICON_STATE_VARIANTS_ALLOWED
	current_variant = "urban"

	allowed = list(
		/obj/item/weapon/gun,
		/obj/item/tank/emergency_oxygen,
		/obj/item/flashlight,
		/obj/item/ammo_magazine,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/tool/lighter,
		/obj/item/weapon/baton,
		/obj/item/restraints/handcuffs,
		/obj/item/explosive/grenade,
		/obj/item/binoculars,
		/obj/item/weapon/combat_knife,
		/obj/item/attachable/bayonet,
		/obj/item/storage/belt/sparepouch,
		/obj/item/storage/holster/blade,
		/obj/item/storage/holster/belt,
		/obj/item/weapon/energy/sword,
	)

/obj/item/clothing/suit/storage/marine/vsd_two
	name = "Crasher multi-threat light ballistic armor"
	desc = "The Kaizoku Corporation's main body armor. Protects the user from most bullet calibers."
	icon = 'icons/mob/clothing/suits/marine_armor.dmi'
	worn_icon_list = list(
		slot_wear_suit_str = 'icons/mob/clothing/suits/marine_armor.dmi',
	)
	icon_state = "vsd_vest"
	worn_icon_state = "vsd_vest"
	slowdown = SLOWDOWN_ARMOR_LIGHT
	soft_armor = list(MELEE = 35, BULLET = 50, LASER = 20, ENERGY = 15, BOMB = 30, BIO = 10, FIRE = 25, ACID = 30)
	item_map_variant_flags = NONE
	armor_features_flags = NONE

	icon_state_variants = list(
		"urban",
		"jungle",
		"desert",
		"snow",
	)
	colorable_allowed = ICON_STATE_VARIANTS_ALLOWED
	current_variant = "urban"

/obj/item/clothing/suit/storage/marine/vsd_two/plate_carrier
	name = "Crasher multi-threat light plate carrier"
	icon_state = "vsd_plate_carrier"
	worn_icon_state = "vsd_plate_carrier"

/obj/item/clothing/suit/storage/marine/vsd_two/marmor
	name = "Crasher multi-threat medium-set ballistic armor"
	desc = "Kaizoku Corporation's uncommon use body armor, used usually by engineers. Protects the user from most bullet calibers."
	icon_state = "vsd_marmor"
	worn_icon_state = "vsd_marmor"
	soft_armor = list(MELEE = 40, BULLET = 70, LASER = 20, ENERGY = 15, BOMB = 40, BIO = 10, FIRE = 25, ACID = 30)

/obj/item/clothing/suit/storage/marine/vsd_two/harmor
	name = "Crasher multi-threat heavy-set ballistic armor"
	desc = "The Kaizoku Corporation's leader set of armor, rarely given to the grunts. Protects the user from most bullet calibers."
	icon_state = "vsd_harmor"
	worn_icon_state = "vsd_harmor"
	soft_armor = list(MELEE = 45, BULLET = 75, LASER = 20, ENERGY = 15, BOMB = 45, BIO = 10, FIRE = 25, ACID = 30)

/obj/item/clothing/suit/storage/marine/usl_squad
	name = "UL5 personal armor"
	desc = "Standard body armor of the USL operatives, the UL5 (United Light MK5) is a set of light body armor, roughly on par with the venerable Xenonauten in service with the NTC."
	icon = 'icons/mob/clothing/suits/marine_armor.dmi'
	worn_icon_list = list(
		slot_wear_suit_str = 'icons/mob/clothing/suits/marine_armor.dmi',
	)
	slowdown = SLOWDOWN_ARMOR_LIGHT
	icon_state = "main_vest"
	worn_icon_state = "main_vest"
	soft_armor = list(MELEE = 55, BULLET = 60, LASER = 60, ENERGY = 60, BOMB = 55, BIO = 10, FIRE = 60, ACID = 60)
	item_map_variant_flags = NONE
	armor_features_flags = NONE

	icon_state_variants = list(
		"USL",
		"urban",
		"jungle",
		"desert",
		"snow",
	)
	colorable_allowed = ICON_STATE_VARIANTS_ALLOWED
	current_variant = "USL"

/obj/item/clothing/suit/storage/marine/usl_squad/larmor_two
	name = "UL5 stealth armor"
	desc = "A modification of the UL5, designed for stealth operations."
	icon_state = "secondary_vest"
	worn_icon_state = "secondary_vest"
	slowdown = SLOWDOWN_ARMOR_VERY_LIGHT

/obj/item/clothing/suit/storage/marine/usl_squad/marmor
	name = "UM6 gunner armor"
	desc = "A heavy duty set of body armor in service with the USL operatives, the UM6 (United Medium MK6) is known for being a rugged set of armor, capable of taking immesnse punishment."
	icon_state = "marmor_vest"
	worn_icon_state = "marmor_vest"
	slowdown = SLOWDOWN_ARMOR_MEDIUM
	soft_armor = list(MELEE = 60, BULLET = 65, LASER = 60, ENERGY = 60, BOMB = 60, BIO = 10, FIRE = 60, ACID = 60)

/obj/item/clothing/suit/storage/marine/usl_squad/harmor
	name = "UH7 heavy plated armor"
	desc = "An extremely heavy-duty set of body armor in service with the USL military, the UH7 (Union Heavy MK7) is known for having powerful ballistic protection, alongside a noticeable neck guard, fortified in order to allow the wearer to endure the stresses of the bulky helmet."
	icon_state = "harmor_vest"
	worn_icon_state = "harmor_vest"
	slowdown = SLOWDOWN_ARMOR_HEAVY
	soft_armor = list(MELEE = 65, BULLET = 65, LASER = 65, ENERGY = 60, BOMB = 60, BIO = 10, FIRE = 60, ACID = 60)

//Xenonauten helmets
/obj/item/clothing/head/modular/m10x
	name = "\improper M10X pattern marine helmet"
	desc = "A standard M10 Pattern Helmet with attach points. It reads on the label, 'The difference between an open-casket and closed-casket funeral. Wear on head for best results.'."

	item_state_worn = TRUE
	soft_armor = MARINE_ARMOR_HEAVY
	attachments_allowed = list(
		/obj/item/armor_module/module/tyr_head,
		/obj/item/armor_module/module/fire_proof_helmet,
		/obj/item/armor_module/module/hod_head,
		/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet,
		/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet/mark1,
		/obj/item/armor_module/module/welding,
		/obj/item/armor_module/module/welding/superior,
		/obj/item/armor_module/module/binoculars,
		/obj/item/armor_module/module/binoculars/artemis_mark_two,
		/obj/item/armor_module/module/artemis,
		/obj/item/armor_module/module/antenna,
		/obj/item/armor_module/storage/helmet,
		/obj/item/armor_module/module/night_vision,
		/obj/item/armor_module/armor/badge,
	)
	starting_attachments = list(/obj/item/armor_module/storage/helmet)
	item_map_variant_flags = ITEM_JUNGLE_VARIANT|ITEM_ICE_VARIANT|ITEM_DESERT_VARIANT

	greyscale_config = /datum/greyscale_config/xenonaut/helm
	greyscale_colors = ARMOR_PALETTE_BLACK

	visorless_offset_y = 0

/obj/item/clothing/head/modular/m10x/hod
	starting_attachments = list(/obj/item/armor_module/storage/helmet, /obj/item/armor_module/module/hod_head)

/obj/item/clothing/head/modular/m10x/freyr
	starting_attachments = list(/obj/item/armor_module/storage/helmet, /obj/item/armor_module/module/artemis)

/obj/item/clothing/head/modular/m10x/antenna
	starting_attachments = list(/obj/item/armor_module/storage/helmet, /obj/item/armor_module/module/antenna)

/obj/item/clothing/head/modular/m10x/welding
	starting_attachments = list(/obj/item/armor_module/storage/helmet, /obj/item/armor_module/module/welding)

/obj/item/clothing/head/modular/m10x/superiorwelding
	starting_attachments = list(/obj/item/armor_module/storage/helmet, /obj/item/armor_module/module/welding/superior)

/obj/item/clothing/head/modular/m10x/mimir
	starting_attachments = list(/obj/item/armor_module/storage/helmet, /obj/item/armor_module/module/mimir_environment_protection/mimir_helmet/mark1)

/obj/item/clothing/head/modular/m10x/tyr
	starting_attachments = list(/obj/item/armor_module/storage/helmet, /obj/item/armor_module/module/tyr_head)

/obj/item/clothing/head/modular/m10x/surt
	starting_attachments = list(/obj/item/armor_module/storage/helmet, /obj/item/armor_module/module/fire_proof_helmet)

/obj/item/clothing/head/modular/m10x/heavy
	name = "\improper M10XE pattern marine helmet"
	desc = "A standard M10XE Pattern Helmet. This is a modified version of the M10X helmet, offering an enclosed visor apparatus."
	worn_icon_state = "helm"
	greyscale_config = /datum/greyscale_config/xenonaut/helm/heavy
	starting_attachments = list(/obj/item/armor_module/armor/visor/marine/xenonaut, /obj/item/armor_module/storage/helmet)
	attachments_allowed = list(
		/obj/item/armor_module/module/tyr_head,
		/obj/item/armor_module/module/fire_proof_helmet,
		/obj/item/armor_module/module/hod_head,
		/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet,
		/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet/mark1,
		/obj/item/armor_module/module/welding,
		/obj/item/armor_module/module/welding/superior,
		/obj/item/armor_module/module/binoculars,
		/obj/item/armor_module/module/binoculars/artemis_mark_two,
		/obj/item/armor_module/module/artemis,
		/obj/item/armor_module/module/antenna,
		/obj/item/armor_module/storage/helmet,
		/obj/item/armor_module/armor/badge,
		/obj/item/armor_module/armor/visor/marine/xenonaut,
	)

/obj/item/clothing/head/modular/m10x/stolen
	name = "\improper stolen M10X pattern helmet"
	desc = "A stolen modular M10X pattern marine helmet. It has been painted a dark red & repurposed for use by the Sons of Mars."
	color = COLOR_PALE_RED_GRAY // dark green * grey-pink = Dark red

/obj/item/clothing/head/modular/m10x/leader
	name = "\improper M11X pattern leader helmet"
	desc = "A slightly fancier helmet for marine leaders. This one has cushioning to project your fragile brain."
	soft_armor = list(MELEE = 75, BULLET = 75, LASER = 75, ENERGY = 65, BOMB = 55, BIO = 55, FIRE = 55, ACID = 60)

/obj/item/clothing/head/modular/m10x/leader/antenna
	starting_attachments = list(/obj/item/armor_module/storage/helmet, /obj/item/armor_module/module/antenna)
