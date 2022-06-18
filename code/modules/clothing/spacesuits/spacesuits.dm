//Spacesuit
//Note: Everything in modules/clothing/spacesuits should have the entire suit grouped together.
//      Meaning the the suit is defined directly after the corrisponding helmet. Just like below!
/obj/item/clothing/head/helmet/space
	name = "Space helmet"
	icon_state = "space"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment."
	item_state = "space"
	permeability_coefficient = 0.01
	soft_armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 50, "fire" = 0, "acid" = 0)
	flags_inventory = COVEREYES|COVERMOUTH|NOPRESSUREDMAGE|BLOCKSHARPOBJ
	flags_inv_hide = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEALLHAIR
	flags_armor_protection = HEAD|FACE|EYES
	flags_cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELMET_MIN_COLD_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.9
	eye_protection = 2

/obj/item/clothing/suit/space
	name = "Space suit"
	desc = "A suit that protects against low pressure environments."
	icon_state = "space"
	item_state = "s_suit"
	w_class = WEIGHT_CLASS_BULKY//bulky item
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.02
	flags_armor_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	allowed = list(/obj/item/flashlight,/obj/item/tank/emergency_oxygen,/obj/item/suit_cooling_unit)
	slowdown = 3
	soft_armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 50, "fire" = 0, "acid" = 0)
	flags_inventory = BLOCKSHARPOBJ|NOPRESSUREDMAGE
	flags_inv_hide = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	flags_cold_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.9
