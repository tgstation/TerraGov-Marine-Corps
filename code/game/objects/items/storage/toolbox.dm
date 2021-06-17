/obj/item/storage/toolbox
	name = "toolbox"
	desc = "Danger. Very robust."
	icon_state = "red"
	item_state = "toolbox_red"
	flags_atom = CONDUCT
	force = 5
	throwforce = 10
	throw_speed = 1
	throw_range = 7
	w_class = WEIGHT_CLASS_BULKY
	attack_verb = list("robusted")

/obj/item/storage/toolbox/emergency
	name = "emergency toolbox"
	icon_state = "red"
	item_state = "toolbox_red"
	spawns_with = list(
		/obj/item/tool/crowbar/red,
		/obj/item/tool/extinguisher/mini,
		/obj/item/flashlight/flare,
		/obj/item/radio,
	)

/obj/item/storage/toolbox/mechanical
	name = "mechanical toolbox"
	icon_state = "blue"
	item_state = "toolbox_blue"
	spawns_with = list(
		/obj/item/tool/screwdriver,
		/obj/item/tool/wrench,
		/obj/item/tool/weldingtool,
		/obj/item/tool/crowbar,
		/obj/item/analyzer,
		/obj/item/tool/wirecutters,
	)

/obj/item/storage/toolbox/electrical
	name = "electrical toolbox"
	icon_state = "yellow"
	item_state = "toolbox_yellow"
	spawns_with = list(
		/obj/item/tool/screwdriver,
		/obj/item/tool/wirecutters,
		/obj/item/t_scanner,
		/obj/item/tool/crowbar,
	)
	spawns_prob = list(list(5, /obj/item/clothing/gloves/yellow))

/obj/item/storage/toolbox/electrical/PopulateContents()
	. = ..()
	new /obj/item/stack/cable_coil(src, 30)
	new /obj/item/stack/cable_coil(src, 30)

/obj/item/storage/toolbox/syndicate
	name = "suspicious looking toolbox"
	icon_state = "syndicate"
	item_state = "toolbox_syndi"
	force = 7
	spawns_with = list(
		/obj/item/tool/screwdriver,
		/obj/item/tool/wrench,
		/obj/item/tool/weldingtool,
		/obj/item/tool/crowbar,
		/obj/item/tool/wirecutters,
		/obj/item/multitool,
	)

/obj/item/storage/toolbox/syndicate/PopulateContents()
	. = ..()
	new /obj/item/stack/cable_coil(src, 30)
