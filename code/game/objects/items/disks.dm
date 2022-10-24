/obj/item/disk
	name = "disk"
	icon = 'icons/obj/items/disk.dmi'
	icon_state = "datadisk0"
	item_state = "card-id"


/obj/item/disk/nuclear
	name = "nuclear authentication disk"
	desc = "Better keep this safe."
	icon_state = "nucleardisk"
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = RESIST_ALL

/obj/item/disk/nuclear/Initialize()
	. = ..()
	GLOB.nuke_disk_list += src

/obj/item/disk/nuclear/Destroy()
	GLOB.nuke_disk_list -= src
	return ..()


/obj/item/disk/nuclear/red
	name = "red nuclear authentication disk"
	icon_state = "datadisk7"


/obj/item/disk/nuclear/green
	name = "green nuclear authentication disk"
	icon_state = "botanydisk"


/obj/item/disk/nuclear/blue
	name = "blue nuclear authentication disk"
	icon_state = "datadisk0"
