//Spacesuit
//Note: Everything in modules/clothing/spacesuits should have the entire suit grouped together.
//      Meaning the the suit is defined directly after the corrisponding helmet. Just like below!
/obj/item/clothing/head/helmet/space
	name = "Space helmet"
	icon = 'icons/obj/clothing/headwear/space_suit_helmets.dmi'
	worn_icon_list = list(slot_head_str = 'icons/mob/clothing/headwear/space_suit_helmets.dmi')
	icon_state = "space_helm"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment."
	permeability_coefficient = 0.01
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 100, FIRE = 0, ACID = 0)
	inventory_flags = COVEREYES|COVERMOUTH|NOPRESSUREDMAGE|BLOCKSHARPOBJ
	inv_hide_flags = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEALLHAIR
	armor_protection_flags = HEAD|FACE|EYES
	cold_protection_flags = HEAD
	min_cold_protection_temperature = SPACE_HELMET_MIN_COLD_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.9
	eye_protection = 2

/obj/item/clothing/suit/space
	name = "Space suit"
	desc = "A suit that protects against low pressure environments."
	icon = 'icons/obj/clothing/suits/space_suits.dmi'
	worn_icon_list = list(slot_wear_suit_str = 'icons/mob/clothing/suits/space_suits.dmi')
	icon_state = "space"
	w_class = WEIGHT_CLASS_BULKY
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.02
	armor_protection_flags = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	allowed = list(/obj/item/flashlight,/obj/item/tank/emergency_oxygen,/obj/item/suit_cooling_unit)
	slowdown = 3
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 100, FIRE = 0, ACID = 0)
	inventory_flags = BLOCKSHARPOBJ|NOPRESSUREDMAGE
	inv_hide_flags = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	cold_protection_flags = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.9
