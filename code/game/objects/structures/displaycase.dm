/obj/structure/displaycase
	name = "display case"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "glassbox1"
	desc = "A display case for prized possessions. It taunts you to kick it."
	density = TRUE
	anchored = TRUE
	resistance_flags = UNACIDABLE
	max_integrity = 30
	var/occupied = 1
	var/destroyed = 0

/obj/structure/displaycase/ex_act(severity)
	switch(severity)
		if (1)
			new /obj/item/shard( src.loc )
			if (occupied)
				occupied = 0
			qdel(src)
		if (2)
			if (prob(50))
				src.obj_integrity -= 15
				src.healthcheck()
		if (3)
			if (prob(50))
				src.obj_integrity -= 5
				src.healthcheck()


/obj/structure/displaycase/bullet_act(var/obj/item/projectile/Proj)
	obj_integrity -= Proj.ammo.damage
	..()
	src.healthcheck()
	return 1

/obj/structure/displaycase/proc/healthcheck()
	if (src.obj_integrity <= 0)
		if (!( src.destroyed ))
			src.density = 0
			src.destroyed = 1
			new /obj/item/shard( src.loc )
			playsound(src, "shatter", 25, 1)
			update_icon()
	else
		playsound(src.loc, 'sound/effects/Glasshit.ogg', 25, 1)
	return

/obj/structure/displaycase/update_icon()
	if(src.destroyed)
		src.icon_state = "glassboxb[src.occupied]"
	else
		src.icon_state = "glassbox[src.occupied]"
	return


/obj/structure/displaycase/attackby(obj/item/I, mob/user, params)
	. = ..()

	obj_integrity -= I.force
	healthcheck()


/obj/structure/displaycase/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/structure/displaycase/attack_hand(mob/user as mob)
	if (src.destroyed && src.occupied)
		to_chat(user, "\b You deactivate the hover field built into the case.")
		src.occupied = 0
		update_icon()
		return
	else
		to_chat(usr, text("<span class='notice'> You kick the display case.</span>"))
		for(var/mob/O in oviewers())
			if ((O.client && !( is_blind(O) )))
				to_chat(O, text("<span class='warning'> [] kicks the display case.</span>", usr))
		src.obj_integrity -= 2
		healthcheck()
		return

//Quick destroyed case.
/obj/structure/displaycase/destroyed
	icon_state = "glassboxb0"
	max_integrity = 0
	occupied = 0
	destroyed = 1
