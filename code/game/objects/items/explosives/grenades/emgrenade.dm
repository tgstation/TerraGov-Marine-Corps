/obj/item/explosive/grenade/emp
	name = "\improper EMP grenade"
	desc = "A compact device that releases a strong electromagnetic pulse on activation. Is capable of damaging or degrading various electronic system. Capable of being loaded in the any grenade launcher, or thrown by hand."
	icon_state = "emp"
	worn_icon_state = "emp"


/obj/item/explosive/grenade/emp/prime()
	empulse(src, 0, 2, 5)
	qdel(src)

