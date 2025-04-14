/obj/item/clothing/underwear/bra
	name = "bra"
	desc = "Just a regular bra."
	icon_state = "bra"
	equip_slot_flags = ITEM_SLOT_BRA

/obj/item/clothing/underwear/bra/update_clothing_icon()
	var/mob/M = loc
	if(istype(M))
		M.update_inv_bra()

/obj/item/clothing/underwear/bra/update_greyscale(list/colors, update)
	. = ..()
	if(!greyscale_config)
		return
	worn_icon_list = list(slot_bra_str = icon)

/obj/item/clothing/underwear/bra/bra
	name = "bra"
	icon_state = "bra"
	greyscale_config = /datum/greyscale_config/bra
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/bra/bra_alt
	name = "bra (alt)"
	icon_state = "bra_alt"
	greyscale_config = /datum/greyscale_config/bra
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/bra/bra_thin
	name = "bra - thin"
	icon_state = "bra_thin"
	greyscale_config = /datum/greyscale_config/bra
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/bra/bra_strapless
	name = "bra - strapless"
	icon_state = "bra_strapless"
	greyscale_config = /datum/greyscale_config/bra
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/bra/bra_strapless_alt
	name = "bra - strapless (alt)"
	icon_state = "bra_strapless_alt"
	greyscale_config = /datum/greyscale_config/bra
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/bra/bikini_bra
	name = "bra - bikini"
	icon_state = "bikini_bra"
	greyscale_config = /datum/greyscale_config/bra
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/bra/strapless_biki_bra
	name = "bra - bikini (strapless)"
	icon_state = "strapless_biki_bra"
	greyscale_config = /datum/greyscale_config/bra
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/bra/halterneck_bra
	name = "bra - halterneck"
	icon_state = "halterneck_bra"
	greyscale_config = /datum/greyscale_config/bra
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/bra/halterneck_bra_alt
	name = "bra - halterneck (alt)"
	icon_state = "halterneck_bra_alt"
	greyscale_config = /datum/greyscale_config/bra
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/bra/bra_neko
	name = "bra - neko"
	icon_state = "bra_neko"
	greyscale_config = /datum/greyscale_config/bra
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/bra/binder
	name = "binder"
	icon_state = "binder"
	greyscale_config = /datum/greyscale_config/bra
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/bra/binder_strapless
	name = "binder - strapless"
	icon_state = "binder_strapless"
	greyscale_config = /datum/greyscale_config/bra
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/bra/bandages
	name = "bandages"
	icon_state = "bandages"
	greyscale_config = /datum/greyscale_config/bra
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/bra/striped_bra
	name = "bra - striped"
	icon_state = "striped_bra"
	greyscale_config = /datum/greyscale_config/bra
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/bra/lizared
	name = "LIZARED top"
	icon_state = "lizared_top"

/obj/item/clothing/underwear/bra/bra_kinky
	name = "bra - kinky"
	icon_state = "bra_kinky"

/obj/item/clothing/underwear/bra/bra_commie
	name = "bra - soviet"
	icon_state = "bra_commie"

/obj/item/clothing/underwear/bra/bra_assblastusa
	name = "bra - freedom"
	icon_state = "bra_assblastusa"

/obj/item/clothing/underwear/bra/bra_uk
	name = "bra - tea"
	icon_state = "bra_uk"

/obj/item/clothing/underwear/bra/bra_bee_kini
	name = "bra - bee kini"
	icon_state = "bra_bee-kini"

/obj/item/clothing/underwear/bra/bra_cow
	name = "bra - cow"
	icon_state = "bra_cow"

/obj/item/clothing/underwear/bra/hi_vis_bra
	name = "bra - hi vis"
	icon_state = "hi_vis_bra"

/obj/item/clothing/underwear/bra/fishnet_sleeves
	name = "fishnet sleeves"
	icon_state = "fishnet_sleeves"

/obj/item/clothing/underwear/bra/fishnet_base
	name = "fishnet sleeveless"
	icon_state = "fishnet_body"

/obj/item/clothing/underwear/bra/fishnet_sleeves_alt
	name = "fishnet sleeves (greyscale)"
	icon_state = "fishnet_sleeves_alt"
	greyscale_config = /datum/greyscale_config/bra
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/bra/fishnet_base_alt
	name = "fishnet sleeveless (greyscale)"
	icon_state = "fishnet_body_alt"
	greyscale_config = /datum/greyscale_config/bra
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/bra/latex
	name = "bra - latex"
	icon_state = "bra_latex"

/obj/item/clothing/underwear/bra/chastbra
	name = "bra - chastity"
	icon_state = "chastbra"

/obj/item/clothing/underwear/bra/pasties
	name = "pasties"
	icon_state = "pasties"
	greyscale_config = /datum/greyscale_config/bra
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/bra/pasties_alt
	name = "cross pasties"
	icon_state = "pasties_alt"
	greyscale_config = /datum/greyscale_config/bra
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/bra/shibari
	name = "shibari"
	icon_state = "shibari"
	greyscale_config = /datum/greyscale_config/bra
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/bra/shibari_sleeves
	name = "shibari - sleeves"
	icon_state = "shibari_sleeves"
	greyscale_config = /datum/greyscale_config/bra
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/bra/sports
	name = "bra - sports"
	icon_state = "sports_bra"
	greyscale_config = /datum/greyscale_config/bra
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/bra/sports_alt
	name = "bra - sports (alt)"
	icon_state = "sports_bra_alt"
	greyscale_config = /datum/greyscale_config/bra
	colorable_allowed = COLOR_WHEEL_ALLOWED

/datum/greyscale_config/bra
	icon_file = 'ntf_modular/modules/underwear/underwear/underwear.dmi'
	json_config = 'ntf_modular/modules/underwear/underwear/bras.json'
	greyscale_flags = HYPERSCALE_ALLOW_GREYSCALE

