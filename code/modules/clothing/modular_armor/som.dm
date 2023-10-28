//SOM modular armour

/obj/item/clothing/suit/modular/som
	name = "\improper SOM light battle armor"
	desc = "The M-21 battle armor is typically used by SOM light infantry, or other specialists that require more mobility at the cost of some protection. Provides good protection without minor impairment to the users mobility. Alt-Click to remove attached items. Use it to toggle the built-in flashlight."
	soft_armor = list(MELEE = 45, BULLET = 70, LASER = 60, ENERGY = 60, BOMB = 50, BIO = 50, FIRE = 55, ACID = 50)
	icon = 'icons/mob/modular/som_armor.dmi'
	item_icons = list(
		slot_wear_suit_str = 'icons/mob/modular/som_armor.dmi',
		slot_l_hand_str = 'icons/mob/inhands/clothing/suits_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/clothing/suits_right.dmi',
	)
	icon_state = "som_medium"
	item_state = "som_medium"
	slowdown = SLOWDOWN_ARMOR_MEDIUM

	attachments_allowed = list(
		/obj/item/armor_module/module/better_shoulder_lamp,
		/obj/item/armor_module/module/valkyrie_autodoc/som,
		/obj/item/armor_module/module/fire_proof/som,
		/obj/item/armor_module/module/tyr_extra_armor/som,
		/obj/item/armor_module/module/mimir_environment_protection/som,
		/obj/item/armor_module/module/hlin_explosive_armor,
		/obj/item/armor_module/module/eshield/som,
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

	icon_state_variants = list(
		"black",
	)
	current_variant = "black"

	allowed_uniform_type = /obj/item/clothing/under

/obj/item/clothing/suit/modular/som/engineer
	starting_attachments = list(
		/obj/item/armor_module/module/better_shoulder_lamp,
		/obj/item/armor_module/storage/engineering,
	)

/obj/item/clothing/suit/modular/som/medic
	starting_attachments = list(
		/obj/item/armor_module/module/better_shoulder_lamp,
		/obj/item/armor_module/storage/general/som,
	)

/obj/item/clothing/suit/modular/som/shield
	starting_attachments = list(
		/obj/item/armor_module/module/eshield/som,
		/obj/item/armor_module/storage/medical/som,
	)

/obj/item/clothing/suit/modular/som/light
	name = "\improper SOM scout armor"
	desc = "The M-11 scout armor is a lightweight suit that that allows for minimal encumberance while still providing reasonable protection. Often seen on scouts or other specialist units that aren't normally getting shot at. Alt-Click to remove attached items. Use it to toggle the built-in flashlight."
	soft_armor = list(MELEE = 35, BULLET = 60, LASER = 50, ENERGY = 50, BOMB = 45, BIO = 45, FIRE = 50, ACID = 40)
	icon_state = "som_light"
	item_state = "som_light"
	slowdown = SLOWDOWN_ARMOR_LIGHT

/obj/item/clothing/suit/modular/som/light/shield
	starting_attachments = list(
		/obj/item/armor_module/module/eshield/som,
		/obj/item/armor_module/storage/medical/som,
	)


/obj/item/clothing/suit/modular/som/heavy
	name = "\improper SOM heavy battle armor"
	desc = "A standard suit of M-31 heavy duty combat armor worn by SOM shock troops. Provides excellent protection however it does reduce mobility somewhat. Alt-Click to remove attached items. Use it to toggle the built-in flashlight."
	soft_armor = list(MELEE = 50, BULLET = 75, LASER = 65, ENERGY = 65, BOMB = 55, BIO = 55, FIRE = 60, ACID = 55)
	icon_state = "som_heavy"
	item_state = "som_heavy"
	slowdown = SLOWDOWN_ARMOR_HEAVY

/obj/item/clothing/suit/modular/som/heavy/pyro
	starting_attachments = list(
		/obj/item/armor_module/module/fire_proof/som,
		/obj/item/armor_module/storage/medical/som,
	)

/obj/item/clothing/suit/modular/som/heavy/lorica
	starting_attachments = list(
		/obj/item/armor_module/module/tyr_extra_armor/som,
		/obj/item/armor_module/storage/medical/som,
	)

/obj/item/clothing/suit/modular/som/heavy/mithridatius
	starting_attachments = list(
		/obj/item/armor_module/module/mimir_environment_protection/som,
		/obj/item/armor_module/storage/medical/som,
	)

/obj/item/clothing/suit/modular/som/heavy/shield
	starting_attachments = list(
		/obj/item/armor_module/module/eshield/som,
		/obj/item/armor_module/storage/medical/som,
	)

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
		/obj/item/armor_module/module/valkyrie_autodoc/som,
		/obj/item/armor_module/module/fire_proof/som,
		/obj/item/armor_module/module/mimir_environment_protection/som,
		/obj/item/armor_module/module/hlin_explosive_armor,
		/obj/item/armor_module/module/eshield/som,
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

/obj/item/clothing/suit/modular/som/heavy/leader/valk
	starting_attachments = list(
		/obj/item/armor_module/module/valkyrie_autodoc/som,
		/obj/item/armor_module/storage/medical/som,
	)

/obj/item/clothing/suit/modular/som/heavy/leader/officer
	desc = "A bulky suit of heavy combat armor, the M-35 'Gorgon' armor provides the user with superior protection without severely impacting mobility. The gold markings on this one signify it is worn by a high ranking field officer. You'll need serious firepower to punch through this. Alt-Click to remove attached items. Use it to toggle the built-in flashlight."
	icon_state = "som_officer"
	item_state = "som_officer"
	starting_attachments = list(
		/obj/item/armor_module/module/valkyrie_autodoc/som,
		/obj/item/armor_module/storage/medical/som,
	)

//helmet

/obj/item/clothing/head/modular/som
	name = "\improper SOM infantry helmet"
	desc = "The standard combat helmet worn by SOM combat troops. Made using advanced polymers to provide very effective protection without compromising visibility."
	icon = 'icons/mob/modular/som_helmets.dmi'
	item_icons = list(
		slot_head_str = 'icons/mob/modular/som_helmets.dmi',
		slot_l_hand_str = 'icons/mob/inhands/clothing/hats_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/clothing/hats_right.dmi',
	)
	icon_state = "som_helmet"
	item_state = "som_helmet"
	soft_armor = list(MELEE = 45, BULLET = 70, LASER = 60, ENERGY = 60, BOMB = 50, BIO = 50, FIRE = 55, ACID = 50)
	flags_inv_hide = HIDEEARS|HIDEALLHAIR
	flags_armor_protection = HEAD|FACE|EYES
	attachments_allowed = list(
		/obj/item/armor_module/module/binoculars,
		/obj/item/armor_module/module/binoculars/artemis_mark_two,
		/obj/item/armor_module/module/artemis,
		/obj/item/armor_module/module/antenna,
		/obj/item/armor_module/storage/helmet,
		/obj/item/armor_module/armor/badge,
	)
	greyscale_config = null
	starting_attachments = list(/obj/item/armor_module/storage/helmet)
	icon_state_variants = list(
		"black",
	)
	current_variant = "black"
	visorless_offset_y = 0

/obj/item/clothing/head/modular/som/engineer
	name = "\improper SOM engineering helmet"
	desc = "A specialised helmet designed for use by combat engineers. Its main feature being an integrated welding mask."
	icon_state = "som_helmet_engineer"
	item_state = "som_helmet_engineer"
	attachments_allowed = list(
		/obj/item/armor_module/storage/helmet,
		/obj/item/armor_module/armor/badge,
		/obj/item/armor_module/module/welding/som,
	)
	starting_attachments = list(/obj/item/armor_module/storage/helmet, /obj/item/armor_module/module/welding/som)

/obj/item/clothing/head/modular/som/bio
	name = "\improper SOM biohazard helmet"
	desc = "This specialised helmet is worn by SOM personel equipped to deal with dangerous chemical, radiological or otherwise hazard substances. Typical unleashed by the SOM themselves."
	icon_state = "som_helmet_bio"
	item_state = "som_helmet_bio"
	soft_armor = list(MELEE = 45, BULLET = 70, LASER = 60, ENERGY = 60, BOMB = 50, BIO = 75, FIRE = 50, ACID = 70)
	siemens_coefficient = 0.1
	permeability_coefficient = 0
	gas_transfer_coefficient = 0.1
	attachments_allowed = list(
		/obj/item/armor_module/storage/helmet,
		/obj/item/armor_module/armor/badge,
	)

/obj/item/clothing/head/modular/som/hades
	name = "\improper Hades Helmet System"
	desc = "A helmet paired with the 'Hades' armor module, designed for significantly improved protection from fire, without compromising normal durability."
	icon_state = "som_helmet_light"
	item_state = "som_helmet_light"
	soft_armor = list(MELEE = 45, BULLET = 70, LASER = 60, ENERGY = 60, BOMB = 50, BIO = 50, FIRE = 90, ACID = 50)
	attachments_allowed = list(
		/obj/item/armor_module/storage/helmet,
		/obj/item/armor_module/armor/badge,
	)

/obj/item/clothing/head/modular/som/veteran
	name = "\improper SOM veteran helmet"
	desc = "The standard combat helmet worn by SOM combat specialists. State of the art materials provides more protection for more valuable brains."
	soft_armor = list(MELEE = 50, BULLET = 75, LASER = 65, ENERGY = 65, BOMB = 55, BIO = 55, FIRE = 60, ACID = 55)

/obj/item/clothing/head/modular/som/lorica
	name = "\improper Lorica Helmet System"
	desc = "A bulky helmet paired with the 'Lorica' armor module, designed for outstanding protection at the cost of significant weight and reduced flexibility. Substantial additional armor improves protection against all damage."
	icon_state = "som_helmet_lorica"
	item_state = "som_helmet_lorica"
	soft_armor = list(MELEE = 60, BULLET = 85, LASER = 80, ENERGY = 80, BOMB = 65, BIO = 55, FIRE = 70, ACID = 60)
	attachments_allowed = list(
		/obj/item/armor_module/storage/helmet,
		/obj/item/armor_module/armor/badge,
	)

/obj/item/clothing/head/modular/som/leader
	name = "\improper SOM Gorgon pattern helmet"
	desc = "Made for use with Gorgon pattern assault armor, providing superior protection. Typically seen on SOM leaders or their most elite combat units."
	icon_state = "som_helmet_leader"
	item_state = "som_helmet_leader"
	soft_armor = list(MELEE = 60, BULLET = 80, LASER = 70, ENERGY = 70, BOMB = 60, BIO = 55, FIRE = 65, ACID = 55)
	attachments_allowed = list(
		/obj/item/armor_module/module/binoculars,
		/obj/item/armor_module/module/binoculars/artemis_mark_two,
		/obj/item/armor_module/module/artemis,
		/obj/item/armor_module/module/antenna,
		/obj/item/armor_module/storage/helmet,
		/obj/item/armor_module/armor/badge,
	)

/obj/item/clothing/head/modular/som/leader/officer
	desc = "Made for use with Gorgon pattern assault armor, providing superior protection. This one has gold markings indicating it belongs to a high ranking field officer."
	icon_state = "som_helmet_officer"
	item_state = "som_helmet_officer"
