/obj/item/weapon/shiv
	name = "glass shiv"
	icon = 'icons/obj/items/weapons/knives.dmi'
	icon_state = "shiv"
	desc = "A makeshift glass shiv."
	attack_verb = list("shanks", "shivs", "slashes", "stabs", "cuts", "rips")
	hitsound = 'sound/weapons/slash.ogg'
	atom_flags = CONDUCT
	sharp = IS_SHARP_ITEM_ACCURATE
	edge = TRUE
	force = 25
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 6
	throw_speed = 3
	throw_range = 6

/obj/item/weapon/shiv/Initialize(mapload)
	. = ..()
	force += rand(-10, 10)

/obj/item/weapon/shiv/plasma
	icon_state = "plasmashiv"
	desc = "A makeshift plasma glass shiv."

/obj/item/weapon/shiv/titanium
	icon_state = "titaniumshiv"
	desc = "A makeshift titanium shiv."

/obj/item/weapon/shiv/plastitanium
	icon_state = "plastitaniumshiv"
	desc = "A makeshift plastitanium glass shiv."
