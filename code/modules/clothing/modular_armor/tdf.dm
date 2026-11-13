//tdf modular armour

/obj/item/clothing/suit/modular/tdf
	name = "\improper Knight class medium armor"
	desc = "The Knight medium combat armor is the standard issue armor given to TDF infantry. Provides good protection without minor impairment to the users mobility. Alt-Click to remove attached items. Use it to toggle the built-in flashlight."
	soft_armor = MARINE_ARMOR_MEDIUM
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
		/obj/item/armor_module/module/tyr_extra_armor/mark1,
		/obj/item/armor_module/module/mimir_environment_protection,
		/obj/item/armor_module/module/mimir_environment_protection/mark1,
		/obj/item/armor_module/module/hlin_explosive_armor,
		/obj/item/armor_module/module/eshield,
		/obj/item/armor_module/module/eshield/overclocked,
		/obj/item/armor_module/module/mirage,
		/obj/item/armor_module/module/armorlock,
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
	name = "\improper Pawn class light armor"
	desc = "The Pawn light combat armor is the standard issue armor given to TDF recon units and assault units for their mobility. Provides good protection without minor impairment to the users mobility. Alt-Click to remove attached items. Use it to toggle the built-in flashlight."
	soft_armor = MARINE_ARMOR_LIGHT
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
	soft_armor = MARINE_ARMOR_HEAVY
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

/obj/item/clothing/suit/modular/tdf/heavy/leader
	name = "\improper Queen class leader armor"
	desc = "A heavy piece of armor. Provides excellent protection however it does reduce mobility somewhat. Alt-Click to remove attached items. Use it to toggle the built-in flashlight."
	icon_state = "tdf_leader"
	worn_icon_state = "tdf_leader"

/obj/item/clothing/suit/modular/tdf/heavy/leader/shield
	starting_attachments = list(
		/obj/item/armor_module/module/eshield,
		/obj/item/armor_module/storage/medical,
	)

/obj/item/clothing/suit/modular/tdf/heavy/leader/shield_overclocked
	starting_attachments = list(
		/obj/item/armor_module/module/eshield/overclocked,
		/obj/item/armor_module/storage/medical,
	)

/obj/item/clothing/suit/modular/tdf/robot
	name = "\improper Clubs class heavy chassis"
	desc = "Heavy armor plating designed for self mounting on TDF combat robotics. It has self-sealing bolts for mounting on robotic owners inside. Alt-Click to remove attached items. Use it to toggle the built-in flashlight."
	species_exception = list(/datum/species/robot)
	icon_state = "tdf_robot"
	worn_icon_state = "tdf_robot"
	soft_armor = MARINE_ARMOR_HEAVY
	slowdown = SLOWDOWN_ARMOR_MEDIUM

/obj/item/clothing/suit/modular/tdf/robot/mob_can_equip(mob/user, slot, warning = TRUE, override_nodrop = FALSE, bitslot = FALSE)
	. = ..()
	if(!isrobot(user))
		to_chat(user, span_warning("You can't equip this as it requires mounting bolts on your body!"))
		return FALSE

/obj/item/clothing/suit/modular/tdf/robot/shield_overclocked
	starting_attachments = list(
		/obj/item/armor_module/module/eshield/overclocked,
		/obj/item/armor_module/storage/engineering,
	)

/obj/item/clothing/suit/modular/tdf/robot/tyr_two
	starting_attachments = list(
		/obj/item/armor_module/module/tyr_extra_armor,
		/obj/item/armor_module/storage/engineering,
	)


//helmet

/obj/item/clothing/head/modular/tdf
	name = "\improper Pawn Class Helmet"
	desc = "The standard combat helmet worn by TDF combat troops. Comes with an integrated hud and AR to provide situational awareness to the wearer."
	icon = 'icons/mob/modular/tdf_helmets.dmi'
	worn_icon_list = list(
		slot_head_str = 'icons/mob/modular/tdf_helmets.dmi',
		slot_l_hand_str = 'icons/mob/inhands/clothing/hats_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/clothing/hats_right.dmi',
	)
	icon_state = "tdf_helmet"
	worn_icon_state = "tdf_helmet"
	soft_armor = MARINE_ARMOR_MEDIUM
	inv_hide_flags = HIDEEARS|HIDEALLHAIR
	armor_protection_flags = HEAD|FACE|EYES
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
		/obj/item/armor_module/module/night_vision,
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
	icon_state = "tdf_helmet_medium"
	worn_icon_state = "tdf_helmet_medium"
	soft_armor = MARINE_ARMOR_HEAVY

/obj/item/clothing/head/modular/tdf/heavy
	name = "\improper Bishop Class Helmet"
	desc = "A bulky helmet paired with the 'Tyr' armor module, for added on additional protection at the cost of significant weight and reduced flexibility."
	icon_state = "tdf_helmet_heavy"
	worn_icon_state = "tdf_helmet_heavy"
	soft_armor = list(MELEE = 55, BULLET = 75, LASER = 75, ENERGY = 75, BOMB = 60, BIO = 60, FIRE = 55, ACID = 70)

/obj/item/clothing/head/modular/tdf/heavy/tyr
	soft_armor = list(MELEE = 60, BULLET = 80, LASER = 80, ENERGY = 75, BOMB = 60, BIO = 60, FIRE = 55, ACID = 75)

/obj/item/clothing/head/modular/tdf/pyro
	name = "\improper Jester Class Helmet"
	desc = "A bulky helmet with an integrated gas mask and a 'Surt' armor module for fireproofing, fielded to TDF flamethrower operators."
	icon_state = "tdf_helmet_pyro"
	worn_icon_state = "tdf_helmet_pyro"
	soft_armor = list(MELEE = 45, BULLET = 65, LASER = 60, ENERGY = 60, BOMB = 50, BIO = 50, FIRE = 100, ACID = 50)

/obj/item/clothing/head/modular/tdf/leader
	name = "\improper Queen Class Helmet"
	desc = "A helmet with additional protection and comfort, designed for TDF squad leaders and other command units."
	icon_state = "tdf_helmet_leader"
	worn_icon_state = "tdf_helmet_leader"
	soft_armor = list(MELEE = 75, BULLET = 75, LASER = 75, ENERGY = 65, BOMB = 55, BIO = 55, FIRE = 55, ACID = 60)

/obj/item/clothing/head/modular/tdf/leader/fcdr
	name = "\improper King Class Helmet"
	icon_state = "tdf_helmet_fc"
	worn_icon_state = "tdf_helmet_fc"

/obj/item/clothing/head/modular/tdf/sg
	name = "\improper Spade Class Helmet"
	desc = "A helmet loaded with sensors and targeting computers to assist the smartgun at shooting things."
	icon_state = "tdf_helmet_sg"
	worn_icon_state = "tdf_helmet_sg"

/obj/item/clothing/head/modular/tdf/sg/tyr
	soft_armor = list(MELEE = 60, BULLET = 80, LASER = 80, ENERGY = 75, BOMB = 60, BIO = 60, FIRE = 55, ACID = 75)

/obj/item/clothing/head/modular/tdf/medic
	name = "\improper Heart Class Helmet"
	desc = "A distinct helmet paired with the 'Mimir' armor module for additional protection against biological attacks, helps indicate your a medic and also helps indicate you as a priority target."
	icon_state = "tdf_helmet_medic"
	worn_icon_state = "tdf_helmet_medic"
	soft_armor = list(MELEE = 45, BULLET = 65, LASER = 60, ENERGY = 60, BOMB = 50, BIO = 75, FIRE = 50, ACID = 70)

/obj/item/clothing/head/modular/tdf/engi
	name = "\improper Rook Class Helmet"
	desc = "A helmet specialized for engineers paired with a welding flash protection system integrated within."
	icon_state = "tdf_helmet_engi"
	worn_icon_state = "tdf_helmet_engi"

/obj/item/clothing/head/modular/tdf/engi/welding
	starting_attachments = list(/obj/item/armor_module/storage/helmet, /obj/item/armor_module/module/welding)

/obj/item/clothing/head/modular/tdf/robot
	name = "\improper Clubs Class Helmet"
	desc = "Heavy armor plating designed for self mounting on the upper half of TDF combat robotics. It has self-sealing bolts for mounting on robotic owners inside."
	species_exception = list(/datum/species/robot)
	icon_state = "tdf_helmet_robot"
	worn_icon_state = "tdf_helmet_robot"
	soft_armor = list(MELEE = 60, BULLET = 80, LASER = 80, ENERGY = 80, BOMB = 60, BIO = 60, FIRE = 70, ACID = 70)

/obj/item/clothing/head/modular/tdf/robot/mob_can_equip(mob/user, slot, warning = TRUE, override_nodrop = FALSE, bitslot = FALSE)
	. = ..()
	if(!isrobot(user))
		to_chat(user, span_warning("You can't equip this as it requires mounting bolts on your body!"))
		return FALSE

