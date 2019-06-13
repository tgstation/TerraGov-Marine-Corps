/obj/item/weapon/energy
	var/active = 0
	flags_atom = NOBLOODY

/obj/item/weapon/energy/suicide_act(mob/user)
	user.visible_message(pick("<span class='danger'>[user] is slitting [user.p_their()] stomach open with the [name]! It looks like [user.p_theyre()] trying to commit seppuku.</span>", \
						"<span class='danger'>[user] is falling on the [name]! It looks like [user.p_theyre()] trying to commit suicide.</span>"))
	return (BRUTELOSS|FIRELOSS)



/obj/item/weapon/energy/axe
	name = "energy axe"
	desc = "An energised battle axe."
	icon_state = "axe0"
	force = 40.0
	throwforce = 25.0
	throw_speed = 1
	throw_range = 5
	w_class = 3.0
	flags_atom = CONDUCT|NOBLOODY
	flags_item = NOSHIELD
	origin_tech = "combat=3"
	attack_verb = list("attacked", "chopped", "cleaved", "torn", "cut")
	sharp = IS_SHARP_ITEM_BIG
	edge = 1

/obj/item/weapon/energy/axe/suicide_act(mob/user)
	user.visible_message("<span class='danger'>[user] swings the [name] towards [user.p_their()] head! It looks like [user.p_theyre()] trying to commit suicide.</span>")
	return (BRUTELOSS|FIRELOSS)

/obj/item/weapon/energy/axe/attack_self(mob/user)
	active = !active
	if(active)
		to_chat(user, "<span class='notice'>The axe is now energised.</span>")
		force = 150
		icon_state = "axe1"
		w_class = 5
		heat = 3500
	else
		to_chat(user, "<span class='notice'>The axe can now be concealed.</span>")
		force = 40
		icon_state = "axe0"
		w_class = 5
		heat = 0



/obj/item/weapon/energy/sword
	name = "energy sword"
	desc = "May the force be within you."
	icon_state = "sword0"
	force = 3.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = 2.0
	flags_atom = NOBLOODY
	flags_item = NOSHIELD
	origin_tech = "magnets=3;syndicate=4"
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	sharp = IS_SHARP_ITEM_BIG
	edge = 1
	var/base_sword_icon = "sword"
	var/sword_color

/obj/item/weapon/energy/sword/IsShield()
	if(active)
		return 1
	return 0

/obj/item/weapon/energy/sword/New()
	if(!sword_color)
		sword_color = pick("red","blue","green","purple")

/obj/item/weapon/energy/sword/attack_self(mob/living/user as mob)
	active = !active
	if (active)
		force = 30
		heat = 3500
		if(base_sword_icon != "sword")
			icon_state = "[base_sword_icon]1"
		else
			icon_state = "sword[sword_color]"
		w_class = 4
		playsound(user, 'sound/weapons/saberon.ogg', 25, 1)
		to_chat(user, "<span class='notice'>[src] is now active.</span>")

	else
		force = 3
		heat = 0
		icon_state = "[base_sword_icon]0"
		w_class = 2
		playsound(user, 'sound/weapons/saberoff.ogg', 25, 1)
		to_chat(user, "<span class='notice'>[src] can now be concealed.</span>")

	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		H.update_inv_l_hand(0)
		H.update_inv_r_hand()

	return


/obj/item/weapon/energy/sword/pirate
	name = "energy cutlass"
	desc = "Arrrr matey."
	icon_state = "cutlass0"
	base_sword_icon = "cutlass"

/obj/item/weapon/energy/sword/green
	sword_color = "green"


/obj/item/weapon/energy/sword/green/attack_self()
	..()
	force = active ? 80 : 3

/obj/item/weapon/energy/sword/red
	sword_color = "red"




