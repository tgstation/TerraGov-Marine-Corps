/obj/item/clothing/underwear/undies
	name = "undies"
	desc = "A pair of undies."
	icon_state = "undies"
	equip_slot_flags = ITEM_SLOT_UNDERWEAR

/obj/item/clothing/underwear/undies/update_clothing_icon()
	var/mob/M = loc
	if(istype(M))
		M.update_inv_underwear()

/obj/item/clothing/underwear/undies/update_greyscale(list/colors, update)
	. = ..()
	if(!greyscale_config)
		return
	worn_icon_list = list(slot_underwear_str = icon)

/obj/item/clothing/underwear/undies/male_briefs
	name = "briefs"
	icon_state = "male_briefs"
	greyscale_config = /datum/greyscale_config/undies
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/undies/male_boxers
	name = "boxers"
	icon_state = "male_boxers"
	greyscale_config = /datum/greyscale_config/undies
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/undies/male_stripe
	name = "striped boxers"
	icon_state = "male_stripe"
	greyscale_config = /datum/greyscale_config/undies
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/undies/male_midway
	name = "midway boxers"
	icon_state = "male_midway"
	greyscale_config = /datum/greyscale_config/undies
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/undies/male_longjohns
	name = "long johns"
	icon_state = "male_longjohns"
	greyscale_config = /datum/greyscale_config/undies
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/undies/male_kinky
	name = "jockstrap"
	icon_state = "male_kinky"
	greyscale_config = /datum/greyscale_config/undies
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/undies/male_mankini
	name = "mankini"
	icon_state = "male_mankini"
	greyscale_config = /datum/greyscale_config/undies
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/undies/male_hearts
	name = "hearts boxers"
	icon_state = "male_hearts"

/obj/item/clothing/underwear/undies/male_commie
	name = "commie boxers"
	icon_state = "male_commie"

/obj/item/clothing/underwear/undies/male_usastripe
	name = "freedom boxers"
	icon_state = "male_assblastusa"

/obj/item/clothing/underwear/undies/male_uk
	name = "tea boxers"
	icon_state = "male_uk"

/obj/item/clothing/underwear/undies/male_bee
	name = "bee shorts"
	icon_state = "male_bee"

/obj/item/clothing/underwear/undies/boyshorts
	name = "boyshorts"
	icon_state = "boyshorts"
	greyscale_config = /datum/greyscale_config/undies
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/undies/boyshorts_alt
	name = "boyshorts (alt)"
	icon_state = "boyshorts"
	greyscale_config = /datum/greyscale_config/undies
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/undies/panties_basic
	name = "panties"
	icon_state = "panties"
	greyscale_config = /datum/greyscale_config/undies
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/undies/panties_slim
	name = "panties - slim"
	icon_state = "panties_slim"
	greyscale_config = /datum/greyscale_config/undies
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/undies/panties_thin
	name = "panties - thin"
	icon_state = "panties_thin"
	greyscale_config = /datum/greyscale_config/undies
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/undies/thong
	name = "thong"
	icon_state = "thong"
	greyscale_config = /datum/greyscale_config/undies
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/undies/thong_babydoll
	name = "thong (alt)"
	icon_state = "thong_babydoll"
	greyscale_config = /datum/greyscale_config/undies
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/undies/panties_swimsuit
	name = "panties - swimsuit"
	icon_state = "panties_swimming"
	greyscale_config = /datum/greyscale_config/undies
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/undies/panties_neko
	name = "panties - neko"
	icon_state = "panties_neko"
	greyscale_config = /datum/greyscale_config/undies
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/undies/striped_panties
	name = "panties - striped"
	icon_state = "striped_panties"

/obj/item/clothing/underwear/undies/lizared
	name = "lizared underwear"
	icon_state = "lizared"

/obj/item/clothing/underwear/undies/female_kinky
	name = "panties - lingerie"
	icon_state = "panties_kinky"

/obj/item/clothing/underwear/undies/panties_commie
	name = "panties - soviet"
	icon_state = "panties_commie"

/obj/item/clothing/underwear/undies/panties_usa
	name = "freedom panties"
	icon_state = "panties_assblastusa"

/obj/item/clothing/underwear/undies/panties_uk
	name = "tea panties"
	icon_state = "panties_uk"

/obj/item/clothing/underwear/undies/panties_cow
	name = "cow panties"
	icon_state = "panties_cow"

/obj/item/clothing/underwear/undies/panties_fisnhet
	name = "panties - fishnet"
	icon_state = "fishnet_lower"

/obj/item/clothing/underwear/undies/panties_fisnhet_alt
	name = "panties - fishnet (greyscale)"
	icon_state = "fishnet_lower_alt"

/obj/item/clothing/underwear/undies/panties_latex
	name = "panties - latex"
	icon_state = "panties_latex"

/obj/item/clothing/underwear/undies/panties_chastbelt
	name = "panties - chastbelt"
	icon_state = "chastbelt"

/obj/item/clothing/underwear/undies/panties_chastcage
	name = "panties - chastcage"
	icon_state = "chastcage"

/obj/item/clothing/underwear/undies/loincloth
	name = "loincloth"
	icon_state = "loincloth"
	greyscale_config = /datum/greyscale_config/undies
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/undies/loincloth_alt
	name = "shorter loincloth"
	icon_state = "loincloth_alt"
	greyscale_config = /datum/greyscale_config/undies
	colorable_allowed = COLOR_WHEEL_ALLOWED

/datum/greyscale_config/undies
	icon_file = 'ntf_modular/modules/underwear/underwear/underwear.dmi'
	json_config = 'ntf_modular/modules/underwear/underwear/socks.json'
	greyscale_flags = HYPERSCALE_ALLOW_GREYSCALE
