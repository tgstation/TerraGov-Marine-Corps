/obj/item/clothing/mask/muzzle
	name = "muzzle"
	desc = "To stop that awful noise."
	icon_state = "muzzle"
	worn_icon_state = "muzzle"
	inventory_flags = COVERMOUTH
	armor_protection_flags = NONE
	w_class = WEIGHT_CLASS_SMALL
	gas_transfer_coefficient = 0.90

/obj/item/clothing/mask/surgical
	name = "sterile mask"
	desc = "A sterile mask designed to help prevent the spread of diseases."
	icon_state = "sterile"
	worn_icon_state = "sterile"
	w_class = WEIGHT_CLASS_SMALL
	inventory_flags = COVERMOUTH
	armor_protection_flags = NONE
	gas_transfer_coefficient = 0.90
	permeability_coefficient = 0.01
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 25, FIRE = 0, ACID = 0)

/obj/item/clothing/mask/fakemoustache
	name = "fake moustache"
	desc = "Warning: moustache is fake."
	icon_state = "fake-moustache"
	inv_hide_flags = HIDEFACE
	armor_protection_flags = NONE

/obj/item/clothing/mask/snorkel
	name = "Snorkel"
	desc = "For the Swimming Savant."
	icon_state = "snorkel"
	inv_hide_flags = HIDEFACE
	armor_protection_flags = NONE

//scarves (fit in in mask slot)

/obj/item/clothing/mask/bluescarf
	name = "blue neck scarf"
	desc = "A blue neck scarf."
	icon_state = "blueneckscarf"
	worn_icon_state = "blueneckscarf"
	inventory_flags = COVERMOUTH
	w_class = WEIGHT_CLASS_SMALL
	gas_transfer_coefficient = 0.90

/obj/item/clothing/mask/redscarf
	name = "red scarf"
	desc = "A red and white checkered neck scarf."
	icon_state = "redwhite_scarf"
	worn_icon_state = "redwhite_scarf"
	inventory_flags = COVERMOUTH
	w_class = WEIGHT_CLASS_SMALL
	gas_transfer_coefficient = 0.90

/obj/item/clothing/mask/greenscarf
	name = "green scarf"
	desc = "A green neck scarf."
	icon_state = "green_scarf"
	worn_icon_state = "green_scarf"
	inventory_flags = COVERMOUTH
	w_class = WEIGHT_CLASS_SMALL
	gas_transfer_coefficient = 0.90

/obj/item/clothing/mask/ninjascarf
	name = "ninja scarf"
	desc = "A stealthy, dark scarf."
	icon_state = "ninja_scarf"
	worn_icon_state = "ninja_scarf"
	inventory_flags = COVERMOUTH
	w_class = WEIGHT_CLASS_SMALL
	gas_transfer_coefficient = 0.90
	siemens_coefficient = 0

/obj/item/clothing/mask/pig
	name = "pig mask"
	desc = "A rubber pig mask."
	icon_state = "pig"
	worn_icon_state = "pig"
	inventory_flags = COVERMOUTH|COVEREYES
	inv_hide_flags = HIDEFACE|HIDEALLHAIR|HIDEEYES|HIDEEARS
	w_class = WEIGHT_CLASS_SMALL
	siemens_coefficient = 0.9
	armor_protection_flags = HEAD|FACE|EYES

/obj/item/clothing/mask/horsehead
	name = "horse head mask"
	desc = "A mask made of soft vinyl and latex, representing the head of a horse."
	icon_state = "horsehead"
	worn_icon_state = "horsehead"
	inventory_flags = COVERMOUTH|COVEREYES
	inv_hide_flags = HIDEFACE|HIDEALLHAIR|HIDEEYES|HIDEEARS
	armor_protection_flags = HEAD|FACE|EYES
	w_class = WEIGHT_CLASS_SMALL
	var/voicechange = 0
	siemens_coefficient = 0.9


/obj/item/clothing/mask/balaclava
	name = "balaclava"
	desc = "LOADSAMONEY"
	icon_state = "balaclava"
	worn_icon_state = "balaclava"
	inv_hide_flags = HIDEFACE|HIDEALLHAIR
	armor_protection_flags = FACE
	w_class = WEIGHT_CLASS_SMALL

/obj/item/clothing/mask/balaclava/tactical
	name = "green balaclava"
	desc = "Designed to both hide identities and keep your face comfy and warm."
	icon_state = "swatclava"
	worn_icon_state = "balaclava"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/clothing/mask/luchador
	name = "Luchador Mask"
	desc = "Worn by robust fighters, flying high to defeat their foes!"
	icon_state = "luchag"
	worn_icon_state = "luchag"
	inv_hide_flags = HIDEFACE|HIDEALLHAIR
	cold_protection_flags = HEAD
	min_cold_protection_temperature = ICE_PLANET_MIN_COLD_PROTECTION_TEMPERATURE
	armor_protection_flags = HEAD|FACE
	inventory_flags = COVERMOUTH
	w_class = WEIGHT_CLASS_SMALL
	siemens_coefficient = 3

/obj/item/clothing/mask/luchador/tecnicos
	name = "Tecnicos Mask"
	desc = "Worn by robust fighters who uphold justice and fight honorably."
	icon_state = "luchador"
	worn_icon_state = "luchador"

/obj/item/clothing/mask/luchador/rudos
	name = "Rudos Mask"
	desc = "Worn by robust fighters who are willing to do anything to win."
	icon_state = "luchar"
	worn_icon_state = "luchar"
