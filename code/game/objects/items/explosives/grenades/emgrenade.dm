/obj/item/explosive/grenade/empgrenade
	name = "classic emp grenade"
	icon = 'icons/obj/device.dmi'
	icon_state = "emp"
	worn_icon_state = "emp"


/obj/item/explosive/grenade/empgrenade/prime()
	empulse(src, 0, 2, 5)
	qdel(src)

