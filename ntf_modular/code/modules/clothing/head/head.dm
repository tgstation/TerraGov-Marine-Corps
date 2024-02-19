/obj/item/clothing/head/frelancer/mothellian
	name = "\improper armored Mothellian helmet"
	desc = "A sturdy mothellian's helmet."
	icon = 'ntf_modular/icons/mob/clothing/headwear/ert_headwear.dmi'
	item_icons = list(
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
