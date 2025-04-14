/obj/item/clothing/underwear/socks
	name = "socks"
	desc = "A pair of socks."
	icon_state = "socks"
	equip_slot_flags = ITEM_SLOT_SOCKS

/obj/item/clothing/underwear/socks/update_clothing_icon()
	var/mob/M = loc
	if(istype(M))
		M.update_inv_socks()

/obj/item/clothing/underwear/socks/update_greyscale(list/colors, update)
	. = ..()
	if(!greyscale_config)
		return
	worn_icon_list = list(slot_socks_str = icon)

/obj/item/clothing/underwear/socks/white
	name = "Socks - White"
	icon_state = "white_norm"
	greyscale_config = /datum/greyscale_config/socks
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/socks/white_short
	name = "Socks - White (short)"
	icon_state = "white_short"
	greyscale_config = /datum/greyscale_config/socks
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/socks/white_knee
	name = "Socks - White (knee high)"
	icon_state = "white_knee"
	greyscale_config = /datum/greyscale_config/socks
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/socks/white_thigh
	name = "Socks - White (thigh high)"
	icon_state = "white_thigh"
	greyscale_config = /datum/greyscale_config/socks
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/socks/black
	name = "Socks - Black"
	icon_state = "black_norm"

/obj/item/clothing/underwear/socks/black_short
	name = "Socks - Black (short)"
	icon_state = "black_short"

/obj/item/clothing/underwear/socks/black_knee
	name = "Socks - Black (knee high)"
	icon_state = "black_knee"

/obj/item/clothing/underwear/socks/black_thigh
	name = "Socks - Black (thigh high)"
	icon_state = "black_thigh"

/obj/item/clothing/underwear/socks/thin_knee
	name = "Socks - Thin (knee high)"
	icon_state = "thin_knee"

/obj/item/clothing/underwear/socks/thin_thigh
	name = "Socks - Thin (thigh high)"
	icon_state = "thin_thigh"

/obj/item/clothing/underwear/socks/pantyhose
	name = "Pantyhose"
	icon_state = "pantyhose"

/obj/item/clothing/underwear/socks/stockings_ripped
	name = "ripped stockings"
	desc = "A pair of ripped stockings."
	icon_state = "stockings_ripped"
	greyscale_config = /datum/greyscale_config/socks
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/socks/thigh_high_ripped
	name = "ripped thigh highs"
	desc = "A pair of ripped thigh highs."
	icon_state = "thigh_high_ripped"

/obj/item/clothing/underwear/socks/leggins
	name = "leggings"
	desc = "A pair of leggings."
	icon_state = "leggings"
	greyscale_config = /datum/greyscale_config/socks
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/socks/leggins_stir
	name = "leggings stirrups"
	desc = "A pair of leggings stirrups."
	icon_state = "leggings-stir"
	greyscale_config = /datum/greyscale_config/socks
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/socks/pantyhose_stir
	name = "pantyhose stirrups"
	desc = "A pair of pantyhose stirrups."
	icon_state = "pantyhose-stir"
	greyscale_config = /datum/greyscale_config/socks
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/socks/pantyhose_ripped
	name = "ripped pantyhose"
	desc = "A pair of ripped pantyhose."
	icon_state = "pantyhose_ripped"
	greyscale_config = /datum/greyscale_config/socks
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/socks/pantyhose_ripped_stir
	name = "ripped pantyhose stirrups"
	desc = "A pair of ripped pantyhose stirrups."
	icon_state = "pantyhose_ripped-stir"
	greyscale_config = /datum/greyscale_config/socks
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/socks/rainbow_thigh_stir
	name = "thigh-high rainbow stirrups"
	desc = "A pair of thigh-high rainbow stirrups."
	icon_state = "rainbow_thigh-stir"

/obj/item/clothing/underwear/socks/rainbow_knee_stir
	name = "knee-high rainbow stirrups"
	desc = "A pair of knee-high rainbow stirrups."
	icon_state = "rainbow_knee-stir"

/obj/item/clothing/underwear/socks/bee_knee
	name = "bee knee socks"
	desc = "Bee socks."
	icon_state = "bee_knee_old"

/obj/item/clothing/underwear/socks/bee_thigh
	name = "bee thigh high socks"
	desc = "Bee socks."
	icon_state = "bee_thigh_old"

/obj/item/clothing/underwear/socks/striped_thigh_stir
	name = "thigh-high striped stirrups"
	desc = "A pair of thigh-high striped stirrups."
	icon_state = "striped_thigh-stir"

/obj/item/clothing/underwear/socks/leggings_black
	name = "black leggings"
	desc = "A pair of black leggings."
	icon_state = "leggings_black"

/obj/item/clothing/underwear/socks/leggings_black_stir
	name = "black leggings stirrups"
	desc = "A pair of black leggings."
	icon_state = "leggings_black-stir"

/obj/item/clothing/underwear/socks/socks_thigh_stir
	name = "thigh-high Stirrups (Greyscale)"
	desc = "A pair of thigh-high stirrups."
	icon_state = "socks_thigh-stir"
	greyscale_config = /datum/greyscale_config/socks
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/socks/socks_thigh_m
	name = "thigh-high socks - shaded"
	desc = "A pair of thigh-high socks."
	icon_state = "socks_thigh_m"
	greyscale_config = /datum/greyscale_config/socks
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/socks/socks_knee_stir
	name = "knee-high Stirrups"
	desc = "A pair of knee-high stirrups."
	icon_state = "socks_knee-stir"
	greyscale_config = /datum/greyscale_config/socks
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/socks/socks_knee_m
	name = "knee high socks - shaded"
	desc = "A pair of knee-high socks."
	icon_state = "socks_knee_m"
	greyscale_config = /datum/greyscale_config/socks
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/socks/socks_norm_stir
	name = "normal stirrups (Greyscale)"
	icon_state = "socks_norm-stir"
	greyscale_config = /datum/greyscale_config/socks
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/socks/socks_latex
	name = "latex socks"
	icon_state = "socks_latex"

/obj/item/clothing/underwear/socks/fishnet
	name = "thigh-high - fishnet"
	icon_state = "fishnet"

/obj/item/clothing/underwear/socks/fishnet_gags
	name = "thigh-high - fishnet (greyscale)"
	icon_state = "fishnet_alt"
	greyscale_config = /datum/greyscale_config/socks
	colorable_allowed = COLOR_WHEEL_ALLOWED

/datum/greyscale_config/socks
	icon_file = 'ntf_modular/modules/underwear/underwear/underwear.dmi'
	json_config = 'ntf_modular/modules/underwear/underwear/socks.json'
	greyscale_flags = HYPERSCALE_ALLOW_GREYSCALE
