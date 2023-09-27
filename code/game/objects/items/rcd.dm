/obj/item/tool/rcd
	name = "rapid-construction-device (RCD)"
	desc = "A device used to rapidly build walls/floor."
	icon = 'icons/obj/items/tools.dmi'
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
	item_icons = list(
		slot_l_hand_str = 'icons/mob/inhands/equipment/tools_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/equipment/tools_right.dmi',
	)
	item_state = "rcdammo"
	opacity = FALSE
	density = FALSE
	anchored = FALSE
