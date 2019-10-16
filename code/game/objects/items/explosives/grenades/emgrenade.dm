/obj/item/explosive/grenade/empgrenade
	name = "classic emp grenade"
	icon_state = "emp"
	item_state = "emp"


/obj/item/explosive/grenade/empgrenade/prime()
	..()
	if(empulse(src, 4, 10))
		qdel(src)
	return

