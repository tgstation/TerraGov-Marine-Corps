/obj/item/locator
	name = "locator"
	desc = "Used to track those with locater implants."
	icon_state = "locator"
	flags_atom = CONDUCT
	w_class = WEIGHT_CLASS_SMALL
	item_state = "electronic"
	throw_speed = 4
	throw_range = 20
	matter = list("metal" = 400)
	origin_tech = "magnets=1"


/obj/item/hand_tele
	name = "hand tele"
	desc = "A portable item using blue-space technology."
	icon_state = "hand_tele"
	item_state = "electronic"
	throwforce = 5
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 5
	matter = list("metal" = 10000)
	origin_tech = "magnets=1;bluespace=3"