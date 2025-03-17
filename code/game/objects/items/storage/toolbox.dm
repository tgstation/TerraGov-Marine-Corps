/obj/item/storage/toolbox
	name = "toolbox"
	desc = "Danger. Very robust."
	icon_state = "red"
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/equipment/toolboxes_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/equipment/toolboxes_right.dmi',
	)
	worn_icon_state = "toolbox_red"
	atom_flags = CONDUCT
	force = 5
	throwforce = 10
	throw_speed = 1
	throw_range = 7
	w_class = WEIGHT_CLASS_BULKY
	attack_verb = list("robusts")


/obj/item/storage/toolbox/emergency
	name = "emergency toolbox"
	icon_state = "red"
	worn_icon_state = "toolbox_red"

/obj/item/storage/toolbox/emergency/PopulateContents()
	new /obj/item/tool/crowbar/red(src)
	new /obj/item/tool/extinguisher/mini(src)
	if(prob(50))
		new /obj/item/flashlight(src)
	else
		new /obj/item/explosive/grenade/flare/civilian(src)

/obj/item/storage/toolbox/mechanical
	name = "mechanical toolbox"
	icon_state = "blue"
	worn_icon_state = "toolbox_blue"

/obj/item/storage/toolbox/mechanical/PopulateContents()
	new /obj/item/tool/screwdriver(src)
	new /obj/item/tool/wrench(src)
	new /obj/item/tool/weldingtool(src)
	new /obj/item/tool/crowbar(src)
	new /obj/item/tool/analyzer(src)
	new /obj/item/tool/wirecutters(src)

/obj/item/storage/toolbox/electrical
	name = "electrical toolbox"
	icon_state = "yellow"
	worn_icon_state = "toolbox_yellow"

/obj/item/storage/toolbox/electrical/PopulateContents()
	var/color = pick("red", "yellow", "green", "blue", "pink", "orange", "cyan", "white")
	new /obj/item/tool/screwdriver(src)
	new /obj/item/tool/wirecutters(src)
	new /obj/item/t_scanner(src)
	new /obj/item/tool/crowbar(src)
	new /obj/item/stack/cable_coil(src, 30, color)
	new /obj/item/stack/cable_coil(src, 30, color)
	if(prob(5))
		new /obj/item/clothing/gloves/insulated(src)
	else
		new /obj/item/stack/cable_coil(src, 30, color)

/obj/item/storage/toolbox/syndicate
	name = "suspicious looking toolbox"
	icon_state = "syndicate"
	worn_icon_state = "toolbox_syndi"
	force = 7

/obj/item/storage/toolbox/syndicate/PopulateContents()
	var/color = pick("red", "yellow", "green", "blue", "pink", "orange", "cyan", "white")
	new /obj/item/tool/screwdriver(src)
	new /obj/item/tool/wrench(src)
	new /obj/item/tool/weldingtool(src)
	new /obj/item/tool/crowbar(src)
	new /obj/item/stack/cable_coil(src, 30, color)
	new /obj/item/tool/wirecutters(src)
	new /obj/item/tool/multitool(src)
