/obj/item/explosive/grenade/mirage
	name = "mirage grenade"
	desc = "A special device that, when activated, produces a pair of holographic copies of the user."
	icon_state = "delivery"
	worn_icon_state = "delivery"
	dangerous = FALSE
	///the parent to be copied
	var/mob/living/current_user
	///How long the illusory fakes last
	var/illusion_lifespan = 15 SECONDS
	///Number of illusions we make
	var/mirage_quantity = 2

/obj/item/explosive/grenade/mirage/activate(mob/user)
	. = ..()
	current_user = user
	icon_state = "delivery_active"

/obj/item/explosive/grenade/mirage/prime()
	if(current_user)
		for(var/i = 1 to mirage_quantity)
			new /mob/illusion/mirage_nade(get_turf(src), current_user, null, illusion_lifespan)
	qdel(src)

/obj/item/explosive/grenade/mirage/Destroy()
	current_user = null
	return ..()
