/obj/item/disk/nuclear/crash
	name = "generic crash nuclear authentication disk"
	desc = "Better keep this safe."
	icon_state = "datadisk0"
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = UNACIDABLE|INDESTRUCTIBLE

/obj/item/disk/nuclear/crash/Initialize()
	. = ..()
	GLOB.gamemode_key_items += src

/obj/item/disk/nuclear/crash/Destroy()
	GLOB.gamemode_key_items -= src
	return ..()


/obj/item/disk/nuclear/crash/red
	name = "red nuclear authentication disk"
	icon_state = "datadisk0"


/obj/item/disk/nuclear/crash/green
	name = "green nuclear authentication disk"
	icon_state = "datadisk3"


/obj/item/disk/nuclear/crash/blue
	name = "blue nuclear authentication disk"
	icon_state = "datadisk1"
