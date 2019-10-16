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


/obj/item/ammo_rcd
	name = "compressed matter cartridge"
	desc = "Highly compressed matter for the RCD."
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "rcd"
	item_state = "rcdammo"
	opacity = FALSE
	density = FALSE
	anchored = FALSE
	materials = list(/datum/material/metal = 30000, /datum/material/glass = 15000)
