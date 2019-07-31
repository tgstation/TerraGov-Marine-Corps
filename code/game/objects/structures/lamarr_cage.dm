/obj/structure/lamarr
	name = "Lab Cage"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "labcage1"
	desc = "A glass lab container for storing interesting creatures."
	density = TRUE
	anchored = TRUE
	resistance_flags = UNACIDABLE
	max_integrity = 30
	var/occupied = 1
	var/destroyed = 0

/obj/structure/lamarr/destroyed
	icon_state = "labcageb0"
	density = FALSE
	destroyed = TRUE
	occupied = FALSE

/obj/structure/lamarr/ex_act(severity)
	switch(severity)
		if (1)
			new /obj/item/shard( src.loc )
			Break()
			qdel(src)
		if (2)
			if (prob(50))
				src.obj_integrity -= 15
				src.healthcheck()
		if (3)
			if (prob(50))
				src.obj_integrity -= 5
				src.healthcheck()


/obj/structure/lamarr/bullet_act(obj/item/projectile/Proj)
	obj_integrity -= Proj.damage
	..()
	src.healthcheck()
	return 1

/obj/structure/lamarr/proc/healthcheck()
	if (src.obj_integrity <= 0)
		if (!( src.destroyed ))
			src.density = FALSE
			src.destroyed = 1
			new /obj/item/shard( src.loc )
			playsound(src, "shatter", 25, 1)
			Break()
	else
		playsound(src.loc, 'sound/effects/Glasshit.ogg', 25, 1)
	return

/obj/structure/lamarr/update_icon()
	if(src.destroyed)
		src.icon_state = "labcageb[src.occupied]"
	else
		src.icon_state = "labcage[src.occupied]"
	return


/obj/structure/lamarr/attackby(obj/item/I, mob/user, params)
	. = ..()

	obj_integrity -= I.force
	healthcheck()


/obj/structure/lamarr/attack_paw(mob/living/carbon/monkey/user)
	return src.attack_hand(user)

/obj/structure/lamarr/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if (src.destroyed)
		return
	else
		to_chat(usr, text("<span class='notice'> You kick the lab cage.</span>"))
		for(var/mob/O in oviewers())
			if ((O.client && !( is_blind(O) )))
				to_chat(O, text("<span class='warning'> [] kicks the lab cage.</span>", usr))
		src.obj_integrity -= 2
		healthcheck()
		return

/obj/structure/lamarr/proc/Break()
	if(occupied)
		new /obj/item/clothing/mask/facehugger/lamarr(src.loc)
		occupied = 0
	update_icon()
	return

/obj/item/clothing/mask/facehugger/lamarr
	name = "Lamarr"
	desc = "The worst she might do is attempt to... couple with your head."//hope we don't get sued over a harmless reference, rite?
	sterile = TRUE
	gender = FEMALE
	stat = DEAD


/obj/item/clothing/mask/facehugger/lamarr/update_icon()
	return
