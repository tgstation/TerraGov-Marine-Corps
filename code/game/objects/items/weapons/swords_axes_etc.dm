/* Weapons
 * Contains:
 *		Banhammer
 *		Classic Baton
 *		Energy Shield
 */

/*
 * Banhammer
 */
/obj/item/weapon/banhammer/attack(mob/M as mob, mob/user as mob)
	M << "<font color='red'><b> You have been banned FOR NO REISIN by [user]<b></font>"
	user << "<font color='red'> You have <b>BANNED</b> [M]</font>"


/*
 * Classic Baton
 */
/obj/item/weapon/classic_baton
	name = "police baton"
	desc = "A wooden truncheon for beating criminal scum."
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "baton"
	item_state = "classic_baton"
	flags_equip_slot = SLOT_WAIST
	force = 10

/obj/item/weapon/classic_baton/attack(mob/M as mob, mob/living/user as mob)
	if ((CLUMSY in user.mutations) && prob(50))
		user << "\red You club yourself over the head."
		user.KnockDown(3 * force)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.apply_damage(2*force, BRUTE, "head")
		else
			user.take_limb_damage(2*force)
		return
/*this is already called in ..()
	src.add_fingerprint(user)
	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been attacked with [src.name] by [user.name] ([user.ckey])</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to attack [M.name] ([M.ckey])</font>")

	log_attack("<font color='red'>[user.name] ([user.ckey]) attacked [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>")
*/

	if(!..()) return
	//playsound(src.loc, "swing_hit", 25, 1, -1)
	if (M.stuttering < 8 && (!(HULK in M.mutations))  /*&& (!istype(H:wear_suit, /obj/item/clothing/suit/judgerobe))*/)
		M.stuttering = 8
	for(var/mob/O in viewers(M))
		if (O.client)	O.show_message("\red <B>[M] has been beaten with \the [src] by [user]!</B>", 1, "\red You hear someone fall", 2)

//Telescopic baton
/obj/item/weapon/telebaton
	name = "telescopic baton"
	desc = "A compact yet rebalanced personal defense weapon. Can be concealed when folded."
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "telebaton_0"
	item_state = "telebaton_0"
	flags_equip_slot = SLOT_WAIST
	w_class = 2
	force = 3
	var/on = 0


/obj/item/weapon/telebaton/attack_self(mob/user as mob)
	on = !on
	if(on)
		user.visible_message("\red With a flick of their wrist, [user] extends their telescopic baton.",\
		"\red You extend the baton.",\
		"You hear an ominous click.")
		icon_state = "telebaton_1"
		item_state = "telebaton_1"
		w_class = 3
		force = 50//Super Robust - Probably shouldn't give it to anyone who isn't staff unless you want BEATINGS
		attack_verb = list("smacked", "struck", "slapped")
	else
		user.visible_message("\blue [user] collapses their telescopic baton.",\
		"\blue You collapse the baton.",\
		"You hear a click.")
		icon_state = "telebaton_0"
		item_state = "telebaton_0"
		w_class = 2
		force = 3//not so robust now
		attack_verb = list("hit", "punched")

	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		H.update_inv_l_hand(0)
		H.update_inv_r_hand()

	playsound(src.loc, 'sound/weapons/gun_empty.ogg', 15, 1)
	add_fingerprint(user)

	if(blood_overlay && blood_DNA && (blood_DNA.len >= 1)) //updates blood overlay, if any
		overlays.Cut()//this might delete other item overlays as well but eeeeeeeh

		var/icon/I = new /icon(src.icon, src.icon_state)
		I.Blend(new /icon('icons/effects/blood.dmi', rgb(255,255,255)),ICON_ADD)
		I.Blend(new /icon('icons/effects/blood.dmi', "itemblood"),ICON_MULTIPLY)
		blood_overlay = I

		overlays += blood_overlay

	return

/obj/item/weapon/telebaton/attack(mob/target as mob, mob/living/user as mob)
	if(on)
		if ((CLUMSY in user.mutations) && prob(50))
			user << "\red You club yourself over the head."
			user.KnockDown(3 * force)
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				H.apply_damage(2*force, BRUTE, "head")
			else
				user.take_limb_damage(2*force)
			return
		if(..())
			//playsound(src.loc, "swing_hit", 25, 1, 6)
			return
	else
		return ..()



/*
 * Energy Shield
 */
/obj/item/weapon/shield/energy/IsShield()
	if(active)
		return 1
	else
		return 0

/obj/item/weapon/shield/energy/attack_self(mob/living/user as mob)
	if ((CLUMSY in user.mutations) && prob(50))
		user << "\red You beat yourself in the head with [src]."
		user.take_limb_damage(5)
	active = !active
	if (active)
		force = 10
		icon_state = "eshield[active]"
		w_class = 4
		playsound(user, 'sound/weapons/saberon.ogg', 25, 1)
		user << "\blue [src] is now active."

	else
		force = 3
		icon_state = "eshield[active]"
		w_class = 1
		playsound(user, 'sound/weapons/saberoff.ogg', 25, 1)
		user << "\blue [src] can now be concealed."

	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		H.update_inv_l_hand(0)
		H.update_inv_r_hand()

	add_fingerprint(user)
	return
