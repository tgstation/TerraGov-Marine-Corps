/obj/item/clothing/head/frelancer/mothellian
	name = "\improper armored Mothellian helmet"
	desc = "A sturdy mothellian's helmet."
	icon = 'ntf_modular/icons/mob/clothing/headwear/ert_headwear.dmi'
	worn_icon_list =list(
		slot_head_str = 'ntf_modular/icons/mob/clothing/headwear/ert_headwear.dmi')

/obj/item/clothing/head/frelancer/mothellian/base
	icon_state = "mothellian_base"
	attachments_allowed = list(/obj/item/armor_module/storage/helmet,)
	starting_attachments = list(/obj/item/armor_module/storage/helmet,)

/obj/item/clothing/head/frelancer/mothellian/medic
	icon_state = "mothellian_medic"

/obj/item/clothing/head/frelancer/mothellian/engineer
	icon_state = "mothellian_base"
	attachments_allowed = list(
		/obj/item/armor_module/module/welding,
		/obj/item/armor_module/storage/helmet,
	)
	starting_attachments = list(
		/obj/item/armor_module/module/welding,
		/obj/item/armor_module/storage/helmet,
	)

/obj/item/clothing/head/frelancer/mothellian/veteran
	name = "\improper armored Mothellian helmet"
	icon_state = "mothellian_vet"

/obj/item/clothing/head/frelancer/mothellian/beret
	name = "\improper armored Mothellian beret"
	desc = "A sturdy mothellian's beret."
	icon_state = "mothellian_beret"
	attachments_allowed = list(
		/obj/item/armor_module/storage/helmet,
	)
	starting_attachments = list(
		/obj/item/armor_module/storage/helmet,
	)
	soft_armor = list(MELEE = 50, BULLET = 70, LASER = 70, ENERGY = 60, BOMB = 55, BIO = 55, FIRE = 55, ACID = 60)

/obj/item/clothing/head/rabbitears
	name = "rabbit ears"
	desc = "Wearing these makes you looks useless, and only good for your sex appeal."
	icon_state = "bunny"
	armor_protection_flags = NONE
	worn_icon_list = list(
		slot_head_str = 'icons/mob/head_0.dmi',
		slot_l_hand_str = 'icons/mob/inhands/clothing/hats_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/clothing/hats_right.dmi',
	)

/obj/item/clothing/head/helmet/marine/som/pilot
	name = "\improper S36 combat pilot helmet"
	desc = "The S18 combat pilot helmet has a specialized visor displaying pilot tactical data. Its origins come from modifications to the M30 Tactical Helmet."
	icon_state = "som_helmet_pilot"
	worn_icon_state = "som_helmet_pilot"
	icon = 'ntf_modular/icons/obj/clothing/headwear/ert_headwear.dmi'
	worn_icon_list = list(
		slot_head_str = 'ntf_modular/icons/mob/clothing/headwear/ert_headwear.dmi',
		slot_l_hand_str = 'icons/mob/inhands/items/items_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/items/items_right.dmi',
	)
	soft_armor = list(MELEE = 50, BULLET = 70, LASER = 50, ENERGY = 50, BOMB = 50, BIO = 40, FIRE = 50, ACID = 40)
	min_cold_protection_temperature = ICE_PLANET_MIN_COLD_PROTECTION_TEMPERATURE
	inventory_flags = BLOCKSHARPOBJ
	inv_hide_flags = HIDEEARS|HIDETOPHAIR
