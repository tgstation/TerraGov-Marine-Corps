/obj/item/melee/baton/cattleprod/teleprod
	name = "teleprod"
	desc = ""
	w_class = WEIGHT_CLASS_NORMAL
	icon_state = "teleprod"
	item_state = "teleprod"
	slot_flags = null

/obj/item/melee/baton/cattleprod/teleprod/attack(mob/living/carbon/M, mob/living/carbon/user)//handles making things teleport when hit
	..()
	if(status && HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
		user.visible_message("<span class='danger'>[user] accidentally hits [user.p_them()]self with [src]!</span>", \
							"<span class='danger'>I accidentally hit myself with [src]!</span>")
		if(do_teleport(user, get_turf(user), 50, channel = TELEPORT_CHANNEL_BLUESPACE))//honk honk
			SEND_SIGNAL(user, COMSIG_LIVING_MINOR_SHOCK)
			user.Paralyze(stunforce*3)
			deductcharge(hitcost)
		else
			SEND_SIGNAL(user, COMSIG_LIVING_MINOR_SHOCK)
			user.Paralyze(stunforce*3)
			deductcharge(hitcost/4)
		return
	else
		if(status)
			if(!istype(M) && M.anchored)
				return .
			else
				SEND_SIGNAL(M, COMSIG_LIVING_MINOR_SHOCK)
				do_teleport(M, get_turf(M), 15, channel = TELEPORT_CHANNEL_BLUESPACE)

/obj/item/melee/baton/cattleprod/attackby(obj/item/I, mob/user, params)//handles sticking a crystal onto a stunprod to make a teleprod
	if(istype(I, /obj/item/stack/ore/bluespace_crystal))
		if(!cell)
			var/obj/item/stack/ore/bluespace_crystal/BSC = I
			var/obj/item/melee/baton/cattleprod/teleprod/S = new /obj/item/melee/baton/cattleprod/teleprod
			remove_item_from_storage(user)
			qdel(src)
			BSC.use(1)
			user.put_in_hands(S)
			to_chat(user, "<span class='notice'>I place the bluespace crystal firmly into the igniter.</span>")
		else
			user.visible_message("<span class='warning'>I can't put the crystal onto the stunprod while it has a power cell installed!</span>")
	else
		return ..()
