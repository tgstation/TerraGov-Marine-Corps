//SOM modular armour

/obj/item/clothing/suit/modular/som
	name = "\improper SOM light battle armor"
	desc = "The M-21 battle armor is typically used by SOM light infantry, or other specialists that require more mobility at the cost of some protection. Provides good protection without minor impairment to the users mobility. Alt-Click to remove attached items. Use it to toggle the built-in flashlight."
	soft_armor = list(MELEE = 45, BULLET = 70, LASER = 60, ENERGY = 60, BOMB = 50, BIO = 50, FIRE = 50, ACID = 50)
	icon_state = "som_medium"
	item_state = "som_medium"
	slowdown = 0.5

	attachments_allowed = list(
		/obj/item/armor_module/module/better_shoulder_lamp,
		/obj/item/armor_module/module/valkyrie_autodoc,
		/obj/item/armor_module/module/fire_proof/som,
		/obj/item/armor_module/module/tyr_extra_armor/som,
		/obj/item/armor_module/module/mimir_environment_protection/som,
		/obj/item/armor_module/module/hlin_explosive_armor,
		/obj/item/armor_module/module/eshield/som,
		/obj/item/armor_module/storage/general,
		/obj/item/armor_module/storage/ammo_mag,
		/obj/item/armor_module/storage/engineering,
		/obj/item/armor_module/storage/medical,
		/obj/item/armor_module/storage/medical/basic,
		/obj/item/armor_module/storage/injector,
		/obj/item/armor_module/storage/grenade,
		/obj/item/armor_module/storage/integrated,
		/obj/item/armor_module/greyscale/badge,
	)

	icon_state_variants = list(
		"black",
	)
	current_variant = "black"

	allowed_uniform_type = /obj/item/clothing/under

/obj/item/clothing/suit/modular/som/engineer
	starting_attachments = list(/obj/item/armor_module/storage/engineering)

/obj/item/clothing/suit/modular/som/shield
	starting_attachments = list(/obj/item/armor_module/module/eshield/som)

/obj/item/clothing/suit/modular/som/light
	name = "\improper SOM scout armor"
	desc = "The M-11 scout armor is a lightweight suit that that allows for minimal encumberance while still providing reasonable protection. Often seen on scouts or other specialist units that aren't normally getting shot at. Alt-Click to remove attached items. Use it to toggle the built-in flashlight."
	soft_armor = list(MELEE = 40, BULLET = 65, LASER = 55, ENERGY = 55, BOMB = 45, BIO = 50, FIRE = 50, ACID = 45)
	icon_state = "som_light"
	item_state = "som_light"
	slowdown = 0.3

/obj/item/clothing/suit/modular/som/light/shield
	starting_attachments = list(/obj/item/armor_module/module/eshield/som)


/obj/item/clothing/suit/modular/som/heavy
	name = "\improper SOM heavy battle armor"
	desc = "A standard suit of M-31 heavy duty combat armor worn by SOM shock troops. Provides excellent protection however it does reduce mobility somewhat. Alt-Click to remove attached items. Use it to toggle the built-in flashlight."
	soft_armor = list(MELEE = 50, BULLET = 75, LASER = 65, ENERGY = 65, BOMB = 50, BIO = 50, FIRE = 60, ACID = 55)
	icon_state = "som_heavy"
	item_state = "som_heavy"
	slowdown = 0.7

/obj/item/clothing/suit/modular/som/heavy/pyro
	starting_attachments = list(
		/obj/item/armor_module/module/fire_proof/som,
		/obj/item/armor_module/storage/general,
	)

/obj/item/clothing/suit/modular/som/heavy/lorica
	starting_attachments = list(/obj/item/armor_module/module/tyr_extra_armor/som)

/obj/item/clothing/suit/modular/som/heavy/mithridatius
	starting_attachments = list(/obj/item/armor_module/module/mimir_environment_protection/som)

/obj/item/clothing/suit/modular/som/heavy/shield
	starting_attachments = list(/obj/item/armor_module/module/eshield/som)

/obj/item/clothing/suit/modular/som/heavy/leader
	name = "\improper SOM Gorgon pattern assault armor"
	desc = "A bulky suit of heavy combat armor, the M-35 'Gorgon' armor provides the user with superior protection without severely impacting mobility. Typically seen on SOM leaders or their most elite combat units due to the significant construction and maintenance requirements. You'll need serious firepower to punch through this. Alt-Click to remove attached items. Use it to toggle the built-in flashlight."
	soft_armor = list(MELEE = 60, BULLET = 80, LASER = 70, ENERGY = 70, BOMB = 60, BIO = 55, FIRE = 65, ACID = 55)
	icon_state = "som_leader"
	item_state = "som_leader"

	siemens_coefficient = 0.4
	permeability_coefficient = 0.5
	gas_transfer_coefficient = 0.5
	attachments_allowed = list(
		/obj/item/armor_module/module/better_shoulder_lamp,
		/obj/item/armor_module/module/valkyrie_autodoc,
		/obj/item/armor_module/module/fire_proof/som,
		/obj/item/armor_module/module/mimir_environment_protection/som,
		/obj/item/armor_module/module/hlin_explosive_armor,
		/obj/item/armor_module/module/eshield/som,
		/obj/item/armor_module/storage/general,
		/obj/item/armor_module/storage/ammo_mag,
		/obj/item/armor_module/storage/engineering,
		/obj/item/armor_module/storage/medical,
		/obj/item/armor_module/storage/medical/basic,
		/obj/item/armor_module/storage/injector,
		/obj/item/armor_module/storage/grenade,
		/obj/item/armor_module/storage/integrated,
		/obj/item/armor_module/greyscale/badge,
	)

/obj/item/clothing/suit/modular/som/heavy/leader/valk
	starting_attachments = list(
		/obj/item/armor_module/module/valkyrie_autodoc,
		/obj/item/armor_module/storage/medical/basic,
	)

//helmet

/obj/item/clothing/head/modular/som
	name = "\improper SOM infantry helmet"
	desc = "The standard combat helmet worn by SOM combat troops. Made using advanced polymers to provide very effective protection without compromising visibility."
	icon = 'icons/mob/modular/m10.dmi'
	item_icons = list(
		slot_head_str = 'icons/mob/modular/m10.dmi',
		slot_l_hand_str = 'icons/mob/items_lefthand_1.dmi',
		slot_r_hand_str = 'icons/mob/items_righthand_1.dmi',)
	icon_state = "som_helmet"
	item_state = "som_helmet"
	soft_armor = list(MELEE = 45, BULLET = 70, LASER = 60, ENERGY = 60, BOMB = 50, BIO = 50, FIRE = 50, ACID = 50)
	flags_inv_hide = HIDEEARS|HIDEALLHAIR
	flags_armor_protection = HEAD|FACE|EYES
	attachments_allowed = list(
		/obj/item/armor_module/module/tyr_head/som,
		/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet/som,
		/obj/item/armor_module/module/welding,
		/obj/item/armor_module/module/welding/superior,
		/obj/item/armor_module/module/binoculars,
		/obj/item/armor_module/module/antenna,
		/obj/item/armor_module/storage/helmet,
		/obj/item/armor_module/greyscale/badge,
	)

	starting_attachments = list(/obj/item/armor_module/storage/helmet)
	icon_state_variants = list(
		"black",
	)
	current_variant = "black"

/obj/item/clothing/head/modular/som/welder
	starting_attachments = list(/obj/item/armor_module/storage/helmet, /obj/item/armor_module/module/welding)

/obj/item/clothing/head/modular/som/mithridatius
	starting_attachments = list(/obj/item/armor_module/storage/helmet, /obj/item/armor_module/module/mimir_environment_protection/mimir_helmet/som)

/obj/item/clothing/head/modular/som/veteran
	name = "\improper SOM veteran helmet"
	desc = "The standard combat helmet worn by SOM combat specialists. State of the art materials provides more protection for more valuable brains."
	soft_armor = list(MELEE = 50, BULLET = 75, LASER = 65, ENERGY = 65, BOMB = 50, BIO = 50, FIRE = 60, ACID = 55)

/obj/item/clothing/head/modular/som/veteran/lorica
	starting_attachments = list(/obj/item/armor_module/storage/helmet, /obj/item/armor_module/module/tyr_head/som)

/obj/item/clothing/head/modular/som/leader
	name = "\improper SOM Gorgon pattern helmet"
	desc = "Made for use with Gorgon pattern assault armor, providing superior protection. Typically seen on SOM leaders or their most elite combat units."
	icon_state = "som_helmet_leader"
	item_state = "som_helmet_leader"
	soft_armor = list(MELEE = 60, BULLET = 80, LASER = 70, ENERGY = 70, BOMB = 60, BIO = 55, FIRE = 65, ACID = 55)
	attachments_allowed = list(
		/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet/som,
		/obj/item/armor_module/module/welding,
		/obj/item/armor_module/module/welding/superior,
		/obj/item/armor_module/module/binoculars,
		/obj/item/armor_module/module/antenna,
		/obj/item/armor_module/storage/helmet,
		/obj/item/armor_module/greyscale/badge,
	)
