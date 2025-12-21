/obj/item/clothing/suit/modular/goon
	name = "\improper NTC G0-0N combat exoskeleton"
	desc = "Designed to be less constricting while being able to mount a variety of modular armor components and support systems. It comes installed with light-plating and a shoulder lamp. Mount armor pieces to it by clicking on the frame with the components. Use Alt-Click to remove any attached items."
	icon = 'ntf_modular/icons/mob/modular/modular_armor.dmi'
	worn_icon_list = list(slot_wear_suit_str = 'ntf_modular/icons/mob/modular/modular_armor.dmi')

/obj/item/clothing/suit/modular/xenonauten/light/bikini
	name = "\improper NTC-B bikini armor"
	desc = "A NTC-B vest, a set... of extra-light bikini armor? with modular attachments made to work in many enviroments. This one seems to be a bikini variant. Alt-Click to remove attached items. Use it to toggle the built-in flashlight."
	greyscale_config = /datum/greyscale_config/xenonaut/bikini
	slowdown = SLOWDOWN_ARMOR_VERY_LIGHT
	soft_armor = list(MELEE = 35, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 40, BIO = 40, FIRE = 50, ACID = 40)
	shows_bottom_genital = TRUE

/obj/item/clothing/suit/modular/xenonauten/light/bikini/som
	name = "\improper SOM M-69 Bikini-pattern light armor"
	desc = "An unusal armor made by the " + FACTION_SOM + ", apparently based on an NTC design. Extra-light bikini armor with modular attachments made to work in many enviroments. Alt-Click to remove attached items. Use it to toggle the built-in flashlight."
	attachments_allowed = list(
		/obj/item/armor_module/module/better_shoulder_lamp,
		/obj/item/armor_module/module/valkyrie_autodoc/som,
		/obj/item/armor_module/module/fire_proof/som,
		/obj/item/armor_module/module/tyr_extra_armor/som,
		/obj/item/armor_module/module/knight/som,
		/obj/item/armor_module/module/mimir_environment_protection/som,
		/obj/item/armor_module/module/hlin_explosive_armor,
		/obj/item/armor_module/module/chemsystem,
		/obj/item/armor_module/module/eshield/som,
		/obj/item/armor_module/module/eshield/som/overclocked,
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

/obj/item/clothing/suit/modular/xenonauten/light/bikini/neutral
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

		/obj/item/armor_module/module/valkyrie_autodoc/som,
		/obj/item/armor_module/module/fire_proof/som,
		/obj/item/armor_module/module/tyr_extra_armor/som,
		/obj/item/armor_module/module/knight/som,
		/obj/item/armor_module/module/mimir_environment_protection/som,
		/obj/item/armor_module/module/eshield/som,
		/obj/item/armor_module/module/eshield/som/overclocked,
	)

/obj/item/clothing/suit/modular/xenonauten/light/bikini/neutral/vsd
	name = "\improper Crasher MT-B/69 bikini armor"
	desc = "An unusal armor made by the " + FACTION_VSD + ", apparently based on an NTC design. Extra-light bikini armor with modular attachments made to work in many enviroments. Alt-Click to remove attached items. Use it to toggle the built-in flashlight."

/obj/item/clothing/suit/modular/xenonauten/light/bikini/neutral/icc
	name = "\improper Modelle/69 'Bikini' combat armor"
	desc = "An unusal armor made by the " + FACTION_ICC + ", apparently based on an NTC design. Extra-light bikini armor with modular attachments made to work in many enviroments. Alt-Click to remove attached items. Use it to toggle the built-in flashlight."

/obj/item/clothing/suit/modular/xenonauten/bulletresistant
	name = "\improper NTC bullet-resistant armor"
	desc = "A lightweight set of armor that excels in protecting the wearer against high-velocity solid projectiles. This one has bullet resistant padding on the limbs aswell."
	blood_overlay_type = "armor"
	soft_armor = list(MELEE = 35, BULLET = 55, LASER = 35, ENERGY = 30, BOMB = 45, BIO = 45, FIRE = 45, ACID = 45)
	hard_armor = list(MELEE = 0, BULLET = 20, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 5)
	slowdown = 0

	greyscale_config = /datum/greyscale_config/xenonaut/bulletproof

/obj/item/clothing/suit/modular/xenonauten/bulletresistant/bikini
	name = "\improper NTC bullet-resistant bikini armor"
	desc = "A lightweight set of armor that excels in protecting the wearer against high-velocity solid projectiles. This one has bullet resistant padding on the limbs aswell, how does it work? don't ask."

	greyscale_config = /datum/greyscale_config/xenonaut/bikini

/obj/item/clothing/suit/modular/xenonauten/ablative
	name = "\improper NTC ablative armor"
	desc = "A lightweight set of armor that excels in protecting the wearer against laser and energy attacks thanks to it's reflective plating."
	blood_overlay_type = "armor"
	soft_armor = list(MELEE = 35, BULLET = 35, LASER = 55, ENERGY = 50, BOMB = 45, BIO = 45, FIRE = 45, ACID = 45)
	hard_armor = list(MELEE = 0, BULLET = 0, LASER = 15, ENERGY = 10, BOMB = 0, BIO = 0, FIRE = 0, ACID = 5)
	slowdown = 0

	greyscale_config = /datum/greyscale_config/xenonaut/ablative

/obj/item/clothing/suit/modular/xenonauten/ablative
	name = "\improper NTC ablative bikini armor"
	desc = "A lightweight set of armor that excels in protecting the wearer against laser and energy attacks thanks to it's reflective plating, how does it work? don't ask."
	greyscale_config = /datum/greyscale_config/xenonaut/ablative
