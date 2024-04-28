/obj/item/disk
	name = "disk"
	icon = 'icons/obj/items/disk.dmi'
	icon_state = "datadisk0"
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/equipment/id_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/equipment/id_right.dmi',
	)
	worn_icon_state = "card-id"


/obj/item/disk/nuclear
	name = "nuclear authentication disk"
	desc = "Better keep this safe."
	icon_state = "nucleardisk"
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = RESIST_ALL

/obj/item/disk/nuclear/Initialize(mapload)
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
