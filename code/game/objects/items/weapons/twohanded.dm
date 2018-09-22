	/*##################################################################
	Much improved now. Leaving the overall item procs here since they're
	easier to find that way. Theoretically any item may be twohanded,
	but only these items and guns benefit from it. ~N
	####################################################################*/

/obj/item/weapon/twohanded
	var/force_wielded 	= 0
	var/wieldsound 		= null
	var/unwieldsound 	= null
	flags_item = TWOHANDED

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
	if( !(flags_item & TWOHANDED) || flags_item & WIELDED ) return

	if(user.get_inactive_hand())
		to_chat(user, "<span class='warning'>You need your other hand to be empty!</span>")
		return

	if(ishuman(user))
		var/check_hand = user.r_hand == src ? "l_hand" : "r_hand"
		var/mob/living/carbon/human/wielder = user
		var/datum/limb/hand = wielder.get_limb(check_hand)
		if( !istype(hand) || !hand.is_usable() )
			to_chat(user, "<span class='warning'>Your other hand can't hold [src]!</span>")
			return

	flags_item 	   ^= WIELDED
	name 	   += " (Wielded)"
	item_state += "_w"
	place_offhand(user,initial(name))
	return 1

/obj/item/proc/unwield(mob/user)
	if( (flags_item|TWOHANDED|WIELDED) != flags_item) return //Have to be actually a twohander and wielded.
	flags_item ^= WIELDED
	name 	    = copytext(name,1,-10)
	item_state  = copytext(item_state,1,-2)
	remove_offhand(user)
	return 1

/obj/item/proc/place_offhand(var/mob/user,item_name)
	to_chat(user, "<span class='notice'>You grab [item_name] with both hands.</span>")
	var/obj/item/weapon/twohanded/offhand/offhand = rnew(/obj/item/weapon/twohanded/offhand, user)
	offhand.name = "[item_name] - offhand"
	offhand.desc = "Your second grip on the [item_name]."
	offhand.flags_item |= WIELDED
	user.put_in_inactive_hand(offhand)
	user.update_inv_l_hand(0)
	user.update_inv_r_hand()

/obj/item/proc/remove_offhand(var/mob/user)
	to_chat(user, "<span class='notice'>You are now carrying [name] with one hand.</span>")
	var/obj/item/weapon/twohanded/offhand/offhand = user.get_inactive_hand()
	if(istype(offhand)) offhand.unwield(user)
	user.update_inv_l_hand(0)
	user.update_inv_r_hand()

/obj/item/weapon/twohanded/wield(mob/user)
	. = ..()
	if(!.) return
	if(wieldsound) playsound(user, wieldsound, 15, 1)
	force 		= force_wielded

/obj/item/weapon/twohanded/unwield(mob/user)
	. = ..()
	if(!.) return
	if(unwieldsound) playsound(user, unwieldsound, 15, 1)
	force 	 	= initial(force)

/obj/item/weapon/twohanded/attack_self(mob/user)
	..()
	if(ismonkey(user))
		to_chat(user, "<span class='warning'>It's too heavy for you to wield fully!</span>")
		return

	if(flags_item & WIELDED) unwield(user)
	else 				wield(user)

///////////OFFHAND///////////////
/obj/item/weapon/twohanded/offhand
	w_class = 5.0
	icon_state = "offhand"
	name = "offhand"
	flags_item = DELONDROP|TWOHANDED|WIELDED

	unwield(var/mob/user)
		if(flags_item & WIELDED)
			flags_item &= ~WIELDED
			user.temp_drop_inv_item(src)
			cdel(src)

	wield()
		cdel(src) //This shouldn't even happen.

	Dispose()
		..()
		return TA_REVIVE_ME //So we can recycle this garbage.

	Recycle()
		var/blacklist[] = list("name","w_class","desc","flags","icon_state")
		. = ..() + blacklist

	dropped(mob/user)
		..()
		//This hand should be holding the main weapon. If everything worked correctly, it should not be wielded.
		//If it is, looks like we got our hand torn off or something.
		var/obj/item/main_hand = user.get_active_hand()
		if(main_hand) main_hand.unwield(user)

/*
 * Fireaxe
 */
/obj/item/weapon/twohanded/fireaxe
	name = "fire axe"
	desc = "Truly, the weapon of a madman. Who would think to fight fire with an axe?"
	icon_state = "fireaxe"
	item_state = "fireaxe"
	force = 20
	sharp = IS_SHARP_ITEM_BIG
	edge = 1
	w_class = 4.0
	flags_equip_slot = SLOT_BACK
	flags_atom = CONDUCT
	flags_item = TWOHANDED
	force_wielded = 45
	attack_verb = list("attacked", "chopped", "cleaved", "torn", "cut")

/obj/item/weapon/twohanded/fireaxe/wield(mob/user)
	. = ..()
	if(!.) return
	pry_capable = IS_PRY_CAPABLE_SIMPLE

/obj/item/weapon/twohanded/fireaxe/unwield(mob/user)
	. = ..()
	if(!.) return
	pry_capable = 0

/obj/item/weapon/twohanded/fireaxe/afterattack(atom/A as mob|obj|turf|area, mob/user as mob, proximity)
	if(!proximity) return
	..()
	if(A && (flags_item & WIELDED) && istype(A,/obj/structure/grille)) //destroys grilles in one hit
		cdel(A)

/*
 * Double-Bladed Energy Swords - Cheridan
 */
/obj/item/weapon/twohanded/dualsaber
	name = "double-bladed energy sword"
	desc = "Handle with care."
	icon_state = "dualsaber"
	item_state = "dualsaber"
	force = 3
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = 2.0
	force_wielded = 70
	wieldsound = 'sound/weapons/saberon.ogg'
	unwieldsound = 'sound/weapons/saberoff.ogg'
	flags_atom = NOBLOODY
	flags_item = NOSHIELD|TWOHANDED
	origin_tech = "magnets=3;syndicate=4"
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	sharp = IS_SHARP_ITEM_BIG
	edge = 1

/obj/item/weapon/twohanded/dualsaber/attack(target as mob, mob/living/user as mob)
	..()
	if((CLUMSY in user.mutations) && (flags_item & WIELDED) &&prob(40))
		to_chat(user, "<span class='highdanger'>You twirl around a bit before losing your balance and impaling yourself on [src].</span>")
		user.take_limb_damage(20,25)
		return
	if((flags_item & WIELDED) && prob(50))
		spawn(0)
			for(var/i in list(1,2,4,8,4,2,1,2,4,8,4,2))
				user.dir = i
				sleep(1)

/obj/item/weapon/twohanded/dualsaber/IsShield()
	if(flags_item & WIELDED) return 1

/obj/item/weapon/twohanded/dualsaber/wield(mob/user)
	. = ..()
	if(!.) return
	icon_state += "_w"

/obj/item/weapon/twohanded/dualsaber/unwield(mob/user)
	. = ..()
	if(!.) return
	icon_state 	= copytext(icon_state,1,-2)

/obj/item/weapon/twohanded/spear
	name = "spear"
	desc = "A haphazardly-constructed yet still deadly weapon of ancient design."
	icon_state = "spearglass"
	item_state = "spearglass"
	force = 14
	w_class = 4.0
	flags_equip_slot = SLOT_BACK
	force_wielded = 24
	throwforce = 30
	throw_speed = 3
	edge = 1
	sharp = IS_SHARP_ITEM_SIMPLE
	flags_item = NOSHIELD|TWOHANDED
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "stabbed", "jabbed", "torn", "gored")



/obj/item/weapon/twohanded/glaive
	name = "war glaive"
	icon = 'icons/obj/items/predator.dmi'
	icon_state = "glaive"
	item_state = "glaive"
	desc = "A huge, powerful blade on a metallic pole. Mysterious writing is carved into the weapon."
	force = 28
	w_class = 4.0
	flags_equip_slot = SLOT_BACK
	force_wielded = 60
	throwforce = 50
	throw_speed = 3
	edge = 1
	sharp = IS_SHARP_ITEM_BIG
	flags_atom = CONDUCT
	flags_item = NOSHIELD|TWOHANDED
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("sliced", "slashed", "jabbed", "torn", "gored")
	unacidable = 1
	attack_speed = 12 //Default is 7.

/obj/item/weapon/twohanded/glaive/damaged
	name = "war glaive"
	desc = "A huge, powerful blade on a metallic pole. Mysterious writing is carved into the weapon. This one is ancient and has suffered serious acid damage, making it near-useless."
	force = 18
	force_wielded = 28