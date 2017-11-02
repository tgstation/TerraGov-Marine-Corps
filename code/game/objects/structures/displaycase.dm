/obj/structure/displaycase
	name = "display case"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "glassbox1"
	desc = "A display case for prized possessions. It taunts you to kick it."
	density = 1
	anchored = 1
	unacidable = 1//Dissolving the case would also delete the gun.
	var/health = 30
	var/occupied = 1
	var/destroyed = 0

/obj/structure/displaycase/ex_act(severity)
	switch(severity)
		if (1)
			new /obj/item/shard( src.loc )
			if (occupied)
				occupied = 0
			cdel(src)
		if (2)
			if (prob(50))
				src.health -= 15
				src.healthcheck()
		if (3)
			if (prob(50))
				src.health -= 5
				src.healthcheck()


/obj/structure/displaycase/bullet_act(var/obj/item/projectile/Proj)
	health -= Proj.ammo.damage
	..()
	src.healthcheck()
	return 1

/obj/structure/displaycase/proc/healthcheck()
	if (src.health <= 0)
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


/obj/structure/displaycase/attackby(obj/item/W as obj, mob/user as mob)
	src.health -= W.force
	src.healthcheck()
	..()
	return

/obj/structure/displaycase/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/structure/displaycase/attack_hand(mob/user as mob)
	if (src.destroyed && src.occupied)
		user << "\b You deactivate the hover field built into the case."
		src.occupied = 0
		src.add_fingerprint(user)
		update_icon()
		return
	else
		usr << text("\blue You kick the display case.")
		for(var/mob/O in oviewers())
			if ((O.client && !( O.blinded )))
				O << text("\red [] kicks the display case.", usr)
		src.health -= 2
		healthcheck()
		return

//Quick destroyed case.
/obj/structure/displaycase/destroyed
	icon_state = "glassboxb0"
	health = 0
	occupied = 0
	destroyed = 1