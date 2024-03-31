/obj/projectile/bullet/reusable
	name = "reusable bullet"
	desc = ""
	ammo_type = /obj/item/ammo_casing/caseless
	impact_effect_type = null

/obj/projectile/bullet/reusable/handle_drop()
	if(dropped)
		dropped.forceMove(get_turf(dropped))
	else
		var/turf/T = get_turf(src)
		dropped = new ammo_type(T)

/obj/projectile/bullet/reusable/on_hit()
	dropped = new ammo_type(src)
	..()

/obj/projectile/bullet/reusable/on_range()
	handle_drop()
	..()
