/obj/item/grenade/empgrenade
	name = "classic EMP grenade"
	desc = ""
	icon_state = "emp"
	item_state = "emp"

/obj/item/grenade/empgrenade/prime()
	update_mob()
	empulse(src, 4, 10)
	qdel(src)
