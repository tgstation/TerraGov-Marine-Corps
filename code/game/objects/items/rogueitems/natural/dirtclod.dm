/obj/item/natural/dirtclod
	name = "clod"
	desc = ""
	icon_state = "clod1"
	dropshrink = 0
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY

/obj/item/natural/dirtclod/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/rogueweapon/shovel))
		var/obj/item/rogueweapon/shovel/S = W
		if(!S.heldclod && user.used_intent.type == /datum/intent/shovelscoop)
			playsound(loc,'sound/items/dig_shovel.ogg', 100, TRUE)
			src.forceMove(S)
			S.heldclod = src
			W.update_icon()
			return
	..()

/obj/item/natural/dirtclod/Moved(oldLoc, dir)
	..()
	if(isturf(loc))
		var/turf/T = loc
		for(var/obj/structure/fluff/clodpile/C in T)
			C.dirtamt = min(C.dirtamt+1, 5)
			qdel(src)
			return
		var/dirtcount = 1
		var/list/dirts = list()
		for(var/obj/item/natural/dirtclod/D in T)
			dirtcount++
			dirts += D
		if(dirtcount >=5)
			for(var/obj/item/I in dirts)
				qdel(I)
			qdel(src)
			new /obj/structure/fluff/clodpile(T)

/obj/item/natural/dirtclod/attack_self(mob/living/user)
	user.visible_message("<span class='warning'>[user] scatters [src].</span>")
	qdel(src)

/obj/item/natural/dirtclod/Initialize()
	icon_state = "clod[rand(1,2)]"
	..()

/obj/structure/fluff/clodpile
	name = "dirt pile"
	desc = ""
	icon_state = "clodpile"
	var/dirtamt = 5
	icon = 'icons/roguetown/items/natural.dmi'
	climbable = FALSE
	density = FALSE
	climb_offset = 10

/obj/structure/fluff/clodpile/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/rogueweapon/shovel))
		var/obj/item/rogueweapon/shovel/S = W
		if(user.used_intent.type == /datum/intent/shovelscoop)
			if(!S.heldclod)
				playsound(loc,'sound/items/dig_shovel.ogg', 100, TRUE)
				var/obj/item/J = new /obj/item/natural/dirtclod(S)
				S.heldclod = J
				W.update_icon()
				dirtamt--
				if(dirtamt <= 0)
					qdel(src)
				return
			else
				playsound(loc,'sound/items/empty_shovel.ogg', 100, TRUE)
				var/obj/item/I = S.heldclod
				S.heldclod = null
				qdel(I)
				W.update_icon()
				dirtamt++
				if(dirtamt > 5)
					dirtamt = 5
				return
	..()

/obj/structure/fluff/clodpile/Initialize()
	dir = pick(GLOB.cardinals)
	..()