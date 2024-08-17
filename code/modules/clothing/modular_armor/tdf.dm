//tdf modular armour

/obj/item/clothing/suit/modular/tdf
	name = "\improper Knight class medium armor"
	desc = "The Rook medium combat armor is the standard issue armor given to TDF infantry. Provides good protection without minor impairment to the users mobility. Alt-Click to remove attached items. Use it to toggle the built-in flashlight."
	soft_armor = list(MELEE = 45, BULLET = 65, LASER = 60, ENERGY = 60, BOMB = 50, BIO = 50, FIRE = 55, ACID = 50)
	icon = 'icons/mob/modular/tdf_armor.dmi'
	worn_icon_list = list(
		slot_wear_suit_str = 'icons/mob/modular/tdf_armor.dmi',
		slot_l_hand_str = 'icons/mob/inhands/clothing/suits_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/clothing/suits_right.dmi',
	)
	icon_state = "tdf_medium"
	worn_icon_state = "tdf_medium"
	slowdown = SLOWDOWN_ARMOR_MEDIUM

	attachments_allowed = list(
		/obj/item/armor_module/module/better_shoulder_lamp,
		/obj/item/armor_module/module/valkyrie_autodoc,
		/obj/item/armor_module/module/fire_proof,
		/obj/item/armor_module/module/tyr_extra_armor,
		/obj/item/armor_module/module/mimir_environment_protection,
		/obj/item/armor_module/module/hlin_explosive_armor,
		/obj/item/armor_module/module/eshield,
		/obj/item/armor_module/module/eshield/overclocked,
		/obj/item/armor_module/storage/general,
		/obj/item/armor_module/storage/ammo_mag,
		/obj/item/armor_module/storage/engineering,
		/obj/item/armor_module/storage/medical,
		/obj/item/armor_module/storage/general,
		/obj/item/armor_module/storage/engineering,
		/obj/item/armor_module/storage/medical,
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
	starting_attachments = list(/obj/item/armor_module/storage/helmet)

/obj/item/clothing/suit/modular/tdf/hodgrenades
	starting_attachments = list(
		/obj/item/armor_module/module/ballistic_armor,
		/obj/item/armor_module/storage/grenade,
	)

/obj/item/clothing/suit/modular/tdf/engineer
	starting_attachments = list(
		/obj/item/armor_module/module/better_shoulder_lamp,
		/obj/item/armor_module/storage/engineering,
	)

/obj/item/clothing/suit/modular/tdf/lightmedical
	starting_attachments = list(
		/obj/item/armor_module/module/better_shoulder_lamp,
		/obj/item/armor_module/storage/medical,
	)

/obj/item/clothing/suit/modular/tdf/lightgeneral
	starting_attachments = list(
		/obj/item/armor_module/module/better_shoulder_lamp,
		/obj/item/armor_module/storage/general,
	)

/obj/item/clothing/suit/modular/tdf/mimir
	starting_attachments = list(
		/obj/item/armor_module/module/mimir_environment_protection/mark1,
		/obj/item/armor_module/storage/general,
	)

/obj/item/clothing/suit/modular/tdf/mimirinjector
	starting_attachments = list(
		/obj/item/armor_module/module/mimir_environment_protection/mark1,
		/obj/item/armor_module/storage/injector,
	)

/obj/item/clothing/suit/modular/tdf/shield
	starting_attachments = list(
		/obj/item/armor_module/module/eshield,
		/obj/item/armor_module/storage/medical,
	)

/obj/item/clothing/suit/modular/tdf/shield_overclocked
	starting_attachments = list(
		/obj/item/armor_module/module/eshield/overclocked,
		/obj/item/armor_module/storage/medical,
	)

/obj/item/clothing/suit/modular/tdf/shield_overclocked/medic
	starting_attachments = list(
		/obj/item/armor_module/module/eshield/overclocked,
		/obj/item/armor_module/storage/general,
	)

/obj/item/clothing/suit/modular/tdf/shield_overclocked/engineer
	starting_attachments = list(
		/obj/item/armor_module/module/eshield/overclocked,
		/obj/item/armor_module/storage/engineering,
	)

/obj/item/clothing/suit/modular/tdf/valk
	starting_attachments = list(
		/obj/item/armor_module/module/valkyrie_autodoc,
		/obj/item/armor_module/storage/medical,
	)

/obj/item/clothing/suit/modular/tdf/light
	name = "\improper Rook class light armor"
	desc = "The Rook light combat armor is the standard issue armor given to TDF recon units and assault units for their mobility. Provides good protection without minor impairment to the users mobility. Alt-Click to remove attached items. Use it to toggle the built-in flashlight."
	soft_armor = list(MELEE = 35, BULLET = 55, LASER = 50, ENERGY = 50, BOMB = 45, BIO = 45, FIRE = 50, ACID = 40)
	icon_state = "tdf_light"
	worn_icon_state = "tdf_light"
	slowdown = SLOWDOWN_ARMOR_LIGHT

/obj/item/clothing/suit/modular/tdf/light/shield
	starting_attachments = list(
		/obj/item/armor_module/module/eshield,
		/obj/item/armor_module/storage/medical,
	)

/obj/item/clothing/suit/modular/tdf/light/shield_overclocked
	starting_attachments = list(
		/obj/item/armor_module/module/eshield/overclocked,
		/obj/item/armor_module/storage/medical,
	)

/obj/item/clothing/suit/modular/tdf/light/shield_overclocked/medic
	starting_attachments = list(
		/obj/item/armor_module/module/eshield/overclocked,
		/obj/item/armor_module/storage/general,
	)

/obj/item/clothing/suit/modular/tdf/light/shield_overclocked/engineer
	starting_attachments = list(
		/obj/item/armor_module/module/eshield/overclocked,
		/obj/item/armor_module/storage/engineering,
	)

/obj/item/clothing/suit/modular/tdf/light/lightmedical
	starting_attachments = list(
		/obj/item/armor_module/module/better_shoulder_lamp,
		/obj/item/armor_module/storage/medical,
	)

/obj/item/clothing/suit/modular/tdf/heavy
	name = "\improper Bishop class heavy armor"
	desc = "A heavy piece of armor. Provides excellent protection however it does reduce mobility somewhat. Alt-Click to remove attached items. Use it to toggle the built-in flashlight."
	soft_armor = list(MELEE = 50, BULLET = 70, LASER = 65, ENERGY = 65, BOMB = 55, BIO = 55, FIRE = 60, ACID = 55)
	icon_state = "tdf_heavy"
	worn_icon_state = "tdf_heavy"
	slowdown = SLOWDOWN_ARMOR_HEAVY

/obj/item/clothing/suit/modular/tdf/heavy/mimirengi
	starting_attachments = list(
		/obj/item/armor_module/module/mimir_environment_protection/mark1,
		/obj/item/armor_module/storage/engineering,
	)

/obj/item/clothing/suit/modular/tdf/heavy/leader
	starting_attachments = list(
		/obj/item/armor_module/module/valkyrie_autodoc,
		/obj/item/armor_module/storage/medical,
	)

/obj/item/clothing/suit/modular/tdf/heavy/tyr_onegeneral
	starting_attachments = list(
		/obj/item/armor_module/module/tyr_extra_armor/mark1,
		/obj/item/armor_module/storage/general,
	)

/obj/item/clothing/suit/modular/tdf/heavy/tyr_one
	starting_attachments = list(
		/obj/item/armor_module/module/tyr_extra_armor/mark1,
		/obj/item/armor_module/storage/medical,
	)

/obj/item/clothing/suit/modular/tdf/heavy/tyr_two
	starting_attachments = list(
		/obj/item/armor_module/module/tyr_extra_armor,
		/obj/item/armor_module/storage/medical,
	)

/obj/item/clothing/suit/modular/tdf/heavy/tyr_two/corpsman
	starting_attachments = list(
		/obj/item/armor_module/module/tyr_extra_armor,
		/obj/item/armor_module/storage/general,
	)

/obj/item/clothing/suit/modular/tdf/heavy/tyr_two/engineer
	starting_attachments = list(
		/obj/item/armor_module/module/tyr_extra_armor,
		/obj/item/armor_module/storage/engineering,
	)

/obj/item/clothing/suit/modular/tdf/heavy/grenadier //Literally grenades
	starting_attachments = list(
		/obj/item/armor_module/module/ballistic_armor,
		/obj/item/armor_module/storage/grenade,
	)

/obj/item/clothing/suit/modular/tdf/heavy/surt
	starting_attachments = list(
		/obj/item/armor_module/module/fire_proof,
		/obj/item/armor_module/storage/medical,
	)

/obj/item/clothing/suit/modular/tdf/heavy/shield
	starting_attachments = list(
		/obj/item/armor_module/module/eshield,
		/obj/item/armor_module/storage/medical,
	)

/obj/item/clothing/suit/modular/tdf/heavy/shield_overclocked
	starting_attachments = list(
		/obj/item/armor_module/module/eshield/overclocked,
		/obj/item/armor_module/storage/medical,
	)

/obj/item/clothing/suit/modular/tdf/heavy/pyro
	slowdown = SLOWDOWN_ARMOR_HEAVY

/obj/item/clothing/suit/modular/tdf/leader
	name = "\improper Queen class leader armor"
	desc = "A heavy piece of armor. Provides excellent protection however it does reduce mobility somewhat. Alt-Click to remove attached items. Use it to toggle the built-in flashlight."
	soft_armor = list(MELEE = 50, BULLET = 70, LASER = 65, ENERGY = 65, BOMB = 55, BIO = 55, FIRE = 60, ACID = 55)
	icon_state = "tdf_leader"
	worn_icon_state = "tdf_leader"
	slowdown = SLOWDOWN_ARMOR_HEAVY

/obj/item/clothing/suit/modular/tdf/leader/shield
	starting_attachments = list(
		/obj/item/armor_module/module/eshield,
		/obj/item/armor_module/storage/medical,
	)

/obj/item/clothing/suit/modular/tdf/leader/shield_overclocked
	starting_attachments = list(
		/obj/item/armor_module/module/eshield/overclocked,
		/obj/item/armor_module/storage/medical,
	)

/obj/item/clothing/suit/modular/tdf/hardsuit
	name = "\improper Ace class hardsuit"
	desc = "The queen class is what would be called a light hardsuit, good mobility and good protection compared to the standard TDF battle armor but pales in comparison to the more advanced and heavier hardsuits out there and not as fancy, it's integrated SMES only provides enough power for its powered exoskeleton and the autodoc system to run for several hours. Provides excellent protection however it does reduce mobility somewhat. Alt-Click to remove attached items. Use it to toggle the built-in flashlight.\n Theres a famous piece of SOM propaganda with the tagline 'Overconfidence Comes At You Fast' showing a dead guy wearing one of these with a couple hundred holes in him.They get one thing right, overconfidence is what will get you in these suits, you feel badass and invincible with these things on.But also dont get me wrong this thing still is an impressive piece of gear. I would know, it has saved me from what would send a marine to the afterlife 3 times over and brought me back from the brink of death more than i could count, use it smartly and you will make it"
	soft_armor = list(MELEE = 75, BULLET = 80, LASER = 80, ENERGY = 85, BOMB = 85, BIO = 70, FIRE = 85, ACID = 70)
	slowdown = SLOWDOWN_ARMOR_MEDIUM

//helmet

/obj/item/clothing/head/modular/tdf
	name = "\improper Rook Class Helmet"
	desc = "The standard combat helmet worn by TDF combat troops. Made using advanced polymers to provide very effective protection without compromising visibility."
	icon = 'icons/mob/modular/tdf_helmets.dmi'
	worn_icon_list = list(
		slot_head_str = 'icons/mob/modular/tdf_helmets.dmi',
		slot_l_hand_str = 'icons/mob/inhands/clothing/hats_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/clothing/hats_right.dmi',
	)
	icon_state = "tdf_helmet"
	worn_icon_state = "tdf_helmet"
	soft_armor = list(MELEE = 45, BULLET = 65, LASER = 60, ENERGY = 60, BOMB = 50, BIO = 50, FIRE = 55, ACID = 50)
	inv_hide_flags = HIDEEARS|HIDEALLHAIR
	armor_protection_flags = HEAD|FACE|EYES
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

/obj/item/clothing/head/modular/tdf/hod
	starting_attachments = list(/obj/item/armor_module/storage/helmet, /obj/item/armor_module/module/hod_head)

/obj/item/clothing/head/modular/tdf/freyr
	starting_attachments = list(/obj/item/armor_module/storage/helmet, /obj/item/armor_module/module/artemis)

/obj/item/clothing/head/modular/tdf/antenna
	starting_attachments = list(/obj/item/armor_module/storage/helmet, /obj/item/armor_module/module/antenna)

/obj/item/clothing/head/modular/tdf/welding
	starting_attachments = list(/obj/item/armor_module/storage/helmet, /obj/item/armor_module/module/welding)

/obj/item/clothing/head/modular/tdf/superiorwelding
	starting_attachments = list(/obj/item/armor_module/storage/helmet, /obj/item/armor_module/module/welding/superior)

/obj/item/clothing/head/modular/tdf/mimir
	starting_attachments = list(/obj/item/armor_module/storage/helmet, /obj/item/armor_module/module/mimir_environment_protection/mimir_helmet/mark1)

/obj/item/clothing/head/modular/tdf/medium
	name = "\improper Knight Class Helmet"
	desc = "A bulky helmet paired with the 'Lorica' armor module, designed for outstanding protection at the cost of significant weight and reduced flexibility. Substantial additional armor improves protection against all damage."
	icon_state = "tdf_helmet_medium"
	worn_icon_state = "tdf_helmet_medium"
	soft_armor = list(MELEE = 60, BULLET = 80, LASER = 80, ENERGY = 80, BOMB = 65, BIO = 55, FIRE = 70, ACID = 60)
	attachments_allowed = list(
		/obj/item/armor_module/storage/helmet,
		/obj/item/armor_module/armor/badge,
	)

/obj/item/clothing/head/modular/tdf/heavy
	name = "\improper Bishop Class Helmet"
	desc = "A bulky helmet paired with the 'Lorica' armor module, designed for outstanding protection at the cost of significant weight and reduced flexibility. Substantial additional armor improves protection against all damage."
	icon_state = "tdf_helmet_heavy"
	worn_icon_state = "tdf_helmet_heavy"
	soft_armor = list(MELEE = 60, BULLET = 80, LASER = 80, ENERGY = 80, BOMB = 65, BIO = 55, FIRE = 70, ACID = 60)
	attachments_allowed = list(
		/obj/item/armor_module/storage/helmet,
		/obj/item/armor_module/armor/badge,
	)

/obj/item/clothing/head/modular/tdf/heavy/tyr
	starting_attachments = list(/obj/item/armor_module/storage/helmet, /obj/item/armor_module/module/tyr_head)

/obj/item/clothing/head/modular/tdf/leader
	name = "\improper Queen Class Helmet"
	desc = "A bulky helmet paired with the 'Lorica' armor module, designed for outstanding protection at the cost of significant weight and reduced flexibility. Substantial additional armor improves protection against all damage."
	icon_state = "tdf_helmet_leader"
	worn_icon_state = "tdf_helmet_leader"
	soft_armor = list(MELEE = 60, BULLET = 80, LASER = 80, ENERGY = 80, BOMB = 65, BIO = 55, FIRE = 70, ACID = 60)
	attachments_allowed = list(
		/obj/item/armor_module/storage/helmet,
		/obj/item/armor_module/armor/badge,
	)

/obj/item/clothing/head/modular/tdf/hardsuit
	name = "\improper Ace Class Hardsuit Helmet"
	desc = "A bulky helmet paired with the 'Lorica' armor module, designed for outstanding protection at the cost of significant weight and reduced flexibility. Substantial additional armor improves protection against all damage."
	soft_armor = list(MELEE = 75, BULLET = 80, LASER = 75, ENERGY = 65, BOMB = 70, BIO = 65, FIRE = 65, ACID = 65)
	anti_hug = 6

/obj/item/clothing/head/modular/tdf/pyro
	name = "\improper "
	desc = "A bulky helmet paired with the 'Lorica' armor module, designed for outstanding protection at the cost of significant weight and reduced flexibility. Substantial additional armor improves protection against all damage."
	icon_state = "tdf_helmet_pyro"
	worn_icon_state = "tdf_helmet_pyro"
	soft_armor = list(MELEE = 60, BULLET = 80, LASER = 80, ENERGY = 80, BOMB = 65, BIO = 55, FIRE = 70, ACID = 60)
	attachments_allowed = list(
		/obj/item/armor_module/storage/helmet,
		/obj/item/armor_module/armor/badge,
	)

/obj/item/clothing/head/modular/tdf/pyro/surt
	starting_attachments = list(/obj/item/armor_module/storage/helmet, /obj/item/armor_module/module/fire_proof_helmet)

/obj/item/clothing/head/modular/tdf/fcdr
	name = "\improper King Class Helmet"
	desc = "A bulky helmet paired with the 'Lorica' armor module, designed for outstanding protection at the cost of significant weight and reduced flexibility. Substantial additional armor improves protection against all damage."
	icon_state = "tdf_helmet_fc"
	worn_icon_state = "tdf_helmet_fc"
	soft_armor = list(MELEE = 60, BULLET = 80, LASER = 80, ENERGY = 80, BOMB = 65, BIO = 55, FIRE = 70, ACID = 60)
	attachments_allowed = list(
		/obj/item/armor_module/storage/helmet,
		/obj/item/armor_module/armor/badge,
	)

/obj/item/clothing/head/modular/tdf/sg
	name = "\improper Lorica Helmet System"
	desc = "A bulky helmet paired with the 'Lorica' armor module, designed for outstanding protection at the cost of significant weight and reduced flexibility. Substantial additional armor improves protection against all damage."
	icon_state = "tdf_helmet_sg"
	worn_icon_state = "tdf_helmet_sg"
	soft_armor = list(MELEE = 60, BULLET = 80, LASER = 80, ENERGY = 80, BOMB = 65, BIO = 55, FIRE = 70, ACID = 60)
	attachments_allowed = list(
		/obj/item/armor_module/storage/helmet,
		/obj/item/armor_module/armor/badge,
	)

/obj/item/clothing/head/modular/tdf/sg/tyr
	starting_attachments = list(/obj/item/armor_module/storage/helmet, /obj/item/armor_module/module/tyr_head)
