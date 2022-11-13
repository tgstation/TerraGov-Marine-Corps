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

/obj/item/weapon/classic_baton/attack(mob/living/M, mob/living/user)
	. = ..()
	if(!.)
		return

	M.set_timed_status_effect(16 SECONDS, /datum/status_effect/speech/stutter, only_if_higher = TRUE)
	visible_message(span_danger("[M] has been beaten with \the [src] by [user]!"), null, span_warning(" You hear someone fall"), 2)

//Telescopic baton
/obj/item/weapon/telebaton
	name = "telescopic baton"
	desc = "A compact yet rebalanced personal defense weapon. Can be concealed when folded."
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "telebaton_0"
	item_state = "telebaton_0"
	flags_equip_slot = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	force = 3
	var/on = 0


/obj/item/weapon/telebaton/attack_self(mob/user as mob)
	on = !on
	if(on)
		user.visible_message(span_warning(" With a flick of their wrist, [user] extends their telescopic baton."),\
		span_warning(" You extend the baton."),\
		"You hear an ominous click.")
		icon_state = "telebaton_1"
		item_state = "telebaton_1"
		w_class = WEIGHT_CLASS_NORMAL
		force = 10
		attack_verb = list("smacked", "struck", "slapped")
	else
		user.visible_message(span_notice(" [user] collapses their telescopic baton."),\
		span_notice(" You collapse the baton."),\
		"You hear a click.")
		icon_state = "telebaton_0"
		item_state = "telebaton_0"
		w_class = WEIGHT_CLASS_SMALL
		force = 3//not so robust now
		attack_verb = list("hit", "punched")

	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		H.update_inv_l_hand(0)
		H.update_inv_r_hand()

	playsound(src.loc, 'sound/weapons/guns/fire/empty.ogg', 15, 1)

	if(blood_overlay) //updates blood overlay, if any
		overlays.Cut()//this might delete other item overlays as well but eeeeeeeh

		var/icon/I = new /icon(src.icon, src.icon_state)
		I.Blend(new /icon('icons/effects/blood.dmi', rgb(255,255,255)),ICON_ADD)
		I.Blend(new /icon('icons/effects/blood.dmi', "itemblood"),ICON_MULTIPLY)
		blood_overlay = I

		overlays += blood_overlay


/obj/item/weapon/telebaton/attack(mob/target as mob, mob/living/user as mob)
	if(on)
		if(..())
			//playsound(src.loc, "swing_hit", 25, 1, 6)
			return
	else
		return ..()
