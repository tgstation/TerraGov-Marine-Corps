/obj/item/clothing/underwear/shirt
	name = "shirt"
	desc = "A shirt."
	icon_state = "undershirt"
	equip_slot_flags = ITEM_SLOT_SHIRT

/obj/item/clothing/underwear/shirt/update_clothing_icon()
	var/mob/M = loc
	if(istype(M))
		M.update_inv_undershirt()

/obj/item/clothing/underwear/shirt/update_greyscale(list/colors, update)
	. = ..()
	if(!greyscale_config)
		return
	worn_icon_list = list(slot_shirt_str = icon)

/obj/item/clothing/underwear/shirt/polo
	name = "Polo Shirt"
	icon_state = "polo"
	greyscale_config = /datum/greyscale_config/bra
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/shirt/normal
	name = "Shirt"
	icon_state = "shirt_white"
	greyscale_config = /datum/greyscale_config/shirt
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/shirt/longsleeve
	name = "Long-Sleeved Shirt"
	icon_state = "shirt_white_long"
	greyscale_config = /datum/greyscale_config/shirt
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/shirt/tanktop_midriff
	name = "Tank Top - Midriff"
	icon_state = "tank_midriff"
	greyscale_config = /datum/greyscale_config/shirt
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/shirt/tanktop_midriff_alt
	name = "Tank Top - Midriff (alt)"
	icon_state = "tank_midriff_alt"
	greyscale_config = /datum/greyscale_config/shirt
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/shirt/whiteshortsleeve
	name = "Short-Sleeved Shirt"
	icon_state = "whiteshortsleeve"
	greyscale_config = /datum/greyscale_config/shirt
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/shirt/tank_top
	name = "Tank Top"
	icon_state = "tank_white"
	greyscale_config = /datum/greyscale_config/shirt
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/shirt/tank_top_alt
	name = "Tank Top (alt)"
	icon_state = "whitetop"
	greyscale_config = /datum/greyscale_config/shirt
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/shirt/striped
	name = "Long-Sleeved Shirt - Black Stripes"
	icon_state = "longstripe"
	greyscale_config = /datum/greyscale_config/shirt
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/shirt/striped_blue
	name = "Long-Sleeved Shirt - Blue Stripes"
	icon_state = "longstripe_blue"

/obj/item/clothing/underwear/shirt/offshoulder
	name = "Shirt - Off-Shoulder"
	icon_state = "one_arm"
	greyscale_config = /datum/greyscale_config/shirt
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/shirt/turtleneck
	name = "Sweater - Turtleneck"
	icon_state = "turtleneck"
	greyscale_config = /datum/greyscale_config/shirt
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/shirt/turtleneck_smooth
	name = "Sweater - Smooth Turtleneck"
	icon_state = "turtleneck_smooth"
	greyscale_config = /datum/greyscale_config/shirt
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/shirt/turtleneck_sleeveless
	name = "Sweater - Sleeveless Turtleneck"
	icon_state = "turtleneck_sleeveless"
	greyscale_config = /datum/greyscale_config/shirt
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/shirt/leotard_turtleneck
	name = "Shirt - Turtleneck Leotard"
	icon_state = "leotard_turtleneck"
	greyscale_config = /datum/greyscale_config/shirt
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/shirt/leotard_turtleneck_sleeveless
	name = "Shirt - Turtleneck Leotard Sleeveless"
	icon_state = "leotard_turtleneck_sleeveless"
	greyscale_config = /datum/greyscale_config/shirt
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/shirt/buttondown
	name = "Shirt - Buttondown"
	icon_state = "buttondown"
	greyscale_config = /datum/greyscale_config/shirt
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/shirt/buttondown_short_sleeve
	name = "Shirt - Short Sleeved Buttondown"
	icon_state = "buttondown_short"
	greyscale_config = /datum/greyscale_config/shirt
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/shirt/babydoll
	name = "Babydoll"
	icon_state = "babydoll"
	greyscale_config = /datum/greyscale_config/shirt
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/clothing/underwear/shirt/tank_top_rainbow
	name = "Tank Top - Rainbow"
	icon_state = "tank_rainbow"

/obj/item/clothing/underwear/shirt/tank_top_sun
	name = "Tank Top - Sun"
	icon_state = "tank_sun"

/obj/item/clothing/underwear/shirt/bee_shirt
	name = "Shirt - Bee"
	icon_state = "bee_shirt"

/obj/item/clothing/underwear/shirt/bulletclub
	name = "Shirt - Black Skull"
	icon_state = "shirt_bc"

/obj/item/clothing/underwear/shirt/corset
	name = "Corset"
	icon_state = "corset"

/obj/item/clothing/underwear/shirt/shirt_black
	name = "Black Shirt"
	icon_state = "shirt_black"

/obj/item/clothing/underwear/shirt/blackshortsleeve
	name = "Black Short Sleeved Shirt"
	icon_state = "blackshortsleeve"

/obj/item/clothing/underwear/shirt/tank_black
	name = "Black Tank Top"
	icon_state = "tank_black"

/obj/item/clothing/underwear/shirt/shirt_grey
	name = "Grey Shirt"
	icon_state = "shirt_grey"

/obj/item/clothing/underwear/shirt/tank_grey
	name = "Grey Tank Top"
	icon_state = "tank_grey"

/obj/item/clothing/underwear/shirt/ian
	name = "Shirt - Ian"
	icon_state = "ian"

/obj/item/clothing/underwear/shirt/commie
	name = "Shirt - USSR"
	icon_state = "shirt_commie"

/obj/item/clothing/underwear/shirt/shirt_assblastusa
	name = "Shirt - Freedom"
	icon_state = "shirt_assblastusa"

/obj/item/clothing/underwear/shirt/shirt_tea
	name = "Shirt - Tea"
	icon_state = "uk"

/obj/item/clothing/underwear/shirt/shirt_nano
	name = "Shirt - NTC"
	icon_state = "shirt_nano"

/obj/item/clothing/underwear/shirt/iloventc
	name = "Shirt - I Love NTC"
	icon_state = "ilovent"

/obj/item/clothing/underwear/shirt/lover
	name = "Shirt - Heart"
	icon_state = "lover"

/obj/item/clothing/underwear/shirt/peace
	name = "Shirt - Peace"
	icon_state = "peace"

/obj/item/clothing/underwear/shirt/band
	name = "Shirt - Band"
	icon_state = "band"

/obj/item/clothing/underwear/shirt/pogoman
	name = "Shirt - pogoman"
	icon_state = "pogoman"

/obj/item/clothing/underwear/shirt/shirt_question
	name = "Shirt - Question"
	icon_state = "shirt_question"

/obj/item/clothing/underwear/shirt/tank_fire
	name = "Tank Top - Fire"
	icon_state = "tank_fire"

/obj/item/clothing/underwear/shirt/skull
	name = "Shirt - Skull"
	icon_state = "shirt_skull"

/obj/item/clothing/underwear/shirt/alien
	name = "Shirt - Alien"
	icon_state = "shirt_alien"

/obj/item/clothing/underwear/shirt/dye
	name = "Shirt - Dye Stripes"
	icon_state = "shirt_tiedye"

/obj/item/clothing/underwear/shirt/matroska
	name = "Shirt - Blue Stripes"
	icon_state = "shirt_stripes"

/obj/item/clothing/underwear/shirt/tank_top_matroska
	name = "Tank Top - Blue Stripes"
	icon_state = "shirt_stripes"

/obj/item/clothing/underwear/shirt/redpolo
	name = "Polo - Red"
	icon_state = "redpolo"

/obj/item/clothing/underwear/shirt/bluepolo
	name = "Polo - Blue"
	icon_state = "bluepolo"

/obj/item/clothing/underwear/shirt/grayyellowpolo
	name = "Polo - Yellow"
	icon_state = "grayyellowpolo"

/obj/item/clothing/underwear/shirt/whitepolo
	name = "Polo - White (Greyscale)"
	icon_state = "whitepolo"

/obj/item/clothing/underwear/shirt/greenshirtsport
	name = "Sport Shirt - Green"
	icon_state = "greenshirtsport"

/obj/item/clothing/underwear/shirt/redshirtsport
	name = "Sport Shirt - Red"
	icon_state = "redshirtsport"

/obj/item/clothing/underwear/shirt/blueshirtsport
	name = "Sport Shirt - Blue"
	icon_state = "blueshirtsport"

/obj/item/clothing/underwear/shirt/jersey_red
	name = "Jersey - Red"
	icon_state = "shirt_redjersey"

/obj/item/clothing/underwear/shirt/jersey_blue
	name = "Jersey - Blue"
	icon_state = "shirt_bluejersey"

/datum/greyscale_config/shirt
	icon_file = 'ntf_modular/modules/underwear/underwear/underwear.dmi'
	json_config = 'ntf_modular/modules/underwear/underwear/shirt.json'
	greyscale_flags = HYPERSCALE_ALLOW_GREYSCALE

