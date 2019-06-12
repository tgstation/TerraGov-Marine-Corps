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
	to_chat(M, "<font color='red'><b> You have been banned FOR NO REISIN by [user]<b></font>")
	to_chat(user, "<font color='red'> You have <b>BANNED</b> [M]</font>")


/*
 * Classic Baton
 */
/obj/item/weapon/classic_baton
	name = "police baton"
	desc = "A wooden truncheon for beating criminal scum."
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "baton"
	item_state = "classic_baton"
	flags_equip_slot = ITEM_SLOT_BELT
	force = 10

/obj/item/weapon/classic_baton/attack(mob/living/M as mob, mob/living/user as mob)
	. = ..()
	if(!.) 
		return

	if (M.stuttering < 8)
		M.stuttering = 8
	visible_message("<span class='danger'>[M] has been beaten with \the [src] by [user]!</span>", null, "<span class='warning'> You hear someone fall</span>", 2)

//Telescopic baton
/obj/item/weapon/telebaton
	name = "telescopic baton"
	desc = "A compact yet rebalanced personal defense weapon. Can be concealed when folded."
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "telebaton_0"
	item_state = "telebaton_0"
	flags_equip_slot = ITEM_SLOT_BELT
	w_class = 2
	force = 3
	var/on = 0


/obj/item/weapon/telebaton/attack_self(mob/user as mob)
	on = !on
	if(on)
		user.visible_message("<span class='warning'> With a flick of their wrist, [user] extends their telescopic baton.</span>",\
		"<span class='warning'> You extend the baton.</span>",\
		"You hear an ominous click.")
		icon_state = "telebaton_1"
		item_state = "telebaton_1"
		w_class = 3
		force = 10
		attack_verb = list("smacked", "struck", "slapped")
	else
		user.visible_message("<span class='notice'> [user] collapses their telescopic baton.</span>",\
		"<span class='notice'> You collapse the baton.</span>",\
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

	if(blood_overlay) //updates blood overlay, if any
		overlays.Cut()//this might delete other item overlays as well but eeeeeeeh

		var/icon/I = new /icon(src.icon, src.icon_state)
		I.Blend(new /icon('icons/effects/blood.dmi', rgb(255,255,255)),ICON_ADD)
		I.Blend(new /icon('icons/effects/blood.dmi', "itemblood"),ICON_MULTIPLY)
		blood_overlay = I

		overlays += blood_overlay

	return

/obj/item/weapon/telebaton/attack(mob/target as mob, mob/living/user as mob)
	if(on)
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
	active = !active
	if (active)
		force = 10
		icon_state = "eshield[active]"
		w_class = 4
		playsound(user, 'sound/weapons/saberon.ogg', 25, 1)
		to_chat(user, "<span class='notice'>[src] is now active.</span>")

	else
		force = 3
		icon_state = "eshield[active]"
		w_class = 1
		playsound(user, 'sound/weapons/saberoff.ogg', 25, 1)
		to_chat(user, "<span class='notice'>[src] can now be concealed.</span>")

	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		H.update_inv_l_hand(0)
		H.update_inv_r_hand()

	return
