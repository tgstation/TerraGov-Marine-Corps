/obj/item/clothing/suit/ru
	name = "ru suit"
	desc = "ru suit."
	icon = 'modular_RUtgmc/icons/obj/clothing/uniform.dmi'
	item_icons = list(
		slot_wear_suit_str = 'modular_RUtgmc/icons/mob/clothing/uniforms/marine_uniforms.dmi')

/obj/item/clothing/suit/ru/fartumasti
	name = "Military cook apron"
	desc = "Pretty apron. Looks like some emblem teared off from it."
	icon_state = "fartumasti"
	item_state = "fartumasti"
	allowed = list(
		/obj/item/weapon/gun,
		/obj/item/storage/holster/blade,
		/obj/item/weapon/claymore/harvester,
		/obj/item/storage/belt/knifepouch,
		/obj/item/weapon/twohanded,
	)
	flags_armor_protection = CHEST
	soft_armor = list(MELEE = 20, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)
