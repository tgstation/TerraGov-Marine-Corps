/obj/item/rcd
	name = "rapid-construction-device (RCD)"
	desc = "A device used to rapidly build walls/floor."
	icon_state = "rcd"
	opacity = FALSE
	density = FALSE
	anchored = FALSE
	flags_atom = CONDUCT
	force = 10
	throwforce = 10
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	matter = list("metal" = 50000)
	origin_tech = "engineering=4;materials=2"


/obj/item/ammo_rcd
	name = "compressed matter cartridge"
	desc = "Highly compressed matter for the RCD."
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "rcd"
	item_state = "rcdammo"
	opacity = FALSE
	density = FALSE
	anchored = FALSE
	origin_tech = "materials=2"
	matter = list("metal" = 30000, "glass" = 15000)