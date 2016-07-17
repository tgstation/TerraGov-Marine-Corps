	/*##################################################################
	Much improved now. Leaving the overall item procs here since they're
	easier to find that way. Theoretically any item may be twohanded,
	but only these items and guns benefit from it. ~N
	####################################################################*/

/obj/item/weapon/twohanded
	var/force_wielded 	= 0
	var/wieldsound 		= null
	var/unwieldsound 	= null
	flags = TWOHANDED

	update_icon()
		return

	mob_can_equip(mob/user)
		unwield(user)
		return ..()

	dropped(mob/user)
		..()
		unwield(user)

	pickup(mob/user)
		unwield(user)

/obj/item/proc/wield(var/mob/user)
	if( !(flags & TWOHANDED) || (flags & WIELDED) ) return
	if(user && user.get_inactive_hand())
		user << "<span class='warning'>You need your other hand to be empty!</span>"
		return
	flags 			^= WIELDED
	var/item_name 	 = initial(name)
	name 			 = "[item_name] (Wielded)"
	place_offhand(user,item_name)
	return 1

/obj/item/proc/unwield(mob/user)
	if( !(flags & TWOHANDED) || !(flags & WIELDED) ) return //If we're not actually carrying it with both hands or it's a one handed weapon.
	flags 	   ^= WIELDED
	name 	 	= initial(name)
	item_state 	= initial(item_state)
	remove_offhand(user)
	return 1

/obj/item/proc/place_offhand(var/mob/user,item_name)
	if(user && ismob(user))
		user << "<span class='notice'>You grab \the [item_name] with both hands.</span>"
		var/obj/item/weapon/twohanded/offhand/offhand = rnew(/obj/item/weapon/twohanded/offhand, user)
		offhand.name = "[item_name] - offhand"
		offhand.desc = "Your second grip on the [item_name]"
		user.put_in_inactive_hand(offhand)
		user.update_inv_l_hand(0)
		user.update_inv_r_hand()

/obj/item/proc/remove_offhand(var/mob/user)
	if(user && ismob(user))
		user << "<span class='notice'>You are now carrying \the [name] with one hand.</span>"
		var/obj/item/weapon/twohanded/offhand/offhand = user.get_inactive_hand()
		if(istype(offhand)) offhand.unwield(user)
		user.update_inv_l_hand(0)
		user.update_inv_r_hand()

/obj/item/weapon/twohanded/wield(mob/user)
	if(!..()) return
	if(wieldsound) playsound(user, wieldsound, 50, 1)
	force 			 = force_wielded
	item_state 		 = initial(item_state) + "-w"
	update_icon()

/obj/item/weapon/twohanded/unwield(mob/user)
	if(!..()) return
	if(unwieldsound) playsound(user, unwieldsound, 50, 1)
	force 	 	= initial(force)
	update_icon()

/obj/item/weapon/twohanded/attack_self(mob/user)
	if(ismonkey(user))
		user << "<span class='warning'>It's too heavy for you to wield fully!</span>"
		return

	if(flags & WIELDED) unwield(user)
	else 				wield(user)

///////////OFFHAND///////////////
/obj/item/weapon/twohanded/offhand
	w_class = 5.0
	icon_state = "offhand"
	name = "offhand"
	flags = TWOHANDED | WIELDED

	unwield(var/mob/user)
		if(user) user.remove_from_mob(src)
		cdel(src)

	wield()
		cdel(src) //This shouldn't even happen.

	Dispose()
		..()
		return TA_REVIVE_ME //So we can recycle this garbage.

	Recycle()
		var/blacklist[] = list("name","w_class","desc","flags","icon_state")
		. = ..() + blacklist

	dropped()
		cdel(src)

	throw_at() //It will run dropped with throw_at, but we're just making sure location will be nulled.
		loc = null
/*
 * Fireaxe
 */
/obj/item/weapon/twohanded/fireaxe
	icon_state = "fireaxe0"
	name = "fire axe"
	desc = "Truly, the weapon of a madman. Who would think to fight fire with an axe?"
	force = 10
	sharp = 1
	edge = 1
	w_class = 4.0
	slot_flags = SLOT_BACK
	flags = FPRINT | TABLEPASS | CONDUCT | TWOHANDED
	force_wielded = 40
	attack_verb = list("attacked", "chopped", "cleaved", "torn", "cut")

/obj/item/weapon/twohanded/fireaxe/update_icon()  //Currently only here to fuck with the on-mob icons.
	var/wielded = (flags & WIELDED) ? 1 : 0
	icon_state = "fireaxe[wielded]"
	item_state = "fireaxe[wielded]"
	return

/obj/item/weapon/twohanded/fireaxe/afterattack(atom/A as mob|obj|turf|area, mob/user as mob, proximity)
	if(!proximity) return
	..()
	if(A && (flags & WIELDED) && istype(A,/obj/structure/grille)) //destroys grilles in one hit
		del(A)


/*
 * Double-Bladed Energy Swords - Cheridan
 */
/obj/item/weapon/twohanded/dualsaber
	icon_state = "dualsaber0"
	name = "double-bladed energy sword"
	desc = "Handle with care."
	force = 3
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = 2.0
	force_wielded = 30
	wieldsound = 'sound/weapons/saberon.ogg'
	unwieldsound = 'sound/weapons/saberoff.ogg'
	flags = FPRINT | TABLEPASS | NOSHIELD | TWOHANDED
	origin_tech = "magnets=3;syndicate=4"
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	sharp = 1
	edge = 1

/obj/item/weapon/twohanded/dualsaber/update_icon()
	var/wielded = (flags & WIELDED) ? 1 : 0
	icon_state = "dualsaber[wielded]"
	item_state = "dualsaber[wielded]"
	return

/obj/item/weapon/twohanded/dualsaber/attack(target as mob, mob/living/user as mob)
	..()
	if((CLUMSY in user.mutations) && (flags & WIELDED) &&prob(40))
		user << "<span class='highdanger'>You twirl around a bit before losing your balance and impaling yourself on the [src].</span>"
		user.take_organ_damage(20,25)
		return
	if((flags & WIELDED) && prob(50))
		spawn(0)
			for(var/i in list(1,2,4,8,4,2,1,2,4,8,4,2))
				user.dir = i
				sleep(1)

/obj/item/weapon/twohanded/dualsaber/IsShield()
	if(flags & WIELDED) return 1

//spears, bay edition
/obj/item/weapon/twohanded/spear
	icon_state = "spearglass0"
	name = "spear"
	desc = "A haphazardly-constructed yet still deadly weapon of ancient design."
	force = 14
	w_class = 4.0
	slot_flags = SLOT_BACK
	force_wielded = 24
	throwforce = 30
	throw_speed = 3
	edge = 1
	sharp = 1
	flags = FPRINT | TABLEPASS | NOSHIELD | TWOHANDED
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "poked", "jabbed", "torn", "gored")

/obj/item/weapon/twohanded/spear/update_icon()
	var/wielded = (flags & WIELDED) ? 1 : 0
	item_state = "spearglass[wielded]"
	return

