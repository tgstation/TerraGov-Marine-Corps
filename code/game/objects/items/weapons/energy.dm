/obj/item/weapon/energy
	var/active = 0
	flags_atom = FPRINT|NOBLOODY

	suicide_act(mob/user)
		viewers(user) << pick("\red <b>[user] is slitting \his stomach open with the [src.name]! It looks like \he's trying to commit seppuku.</b>", \
							"\red <b>[user] is falling on the [src.name]! It looks like \he's trying to commit suicide.</b>")
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
	flags_atom = FPRINT|CONDUCT|NOBLOODY
	flags_item = NOSHIELD
	origin_tech = "combat=3"
	attack_verb = list("attacked", "chopped", "cleaved", "torn", "cut")
	sharp = IS_SHARP_ITEM_BIG
	edge = 1

/obj/item/weapon/energy/axe/suicide_act(mob/user)
	viewers(user) << "\red <b>[user] swings the [src.name] towards /his head! It looks like \he's trying to commit suicide.</b>"
	return (BRUTELOSS|FIRELOSS)

/obj/item/weapon/energy/axe/attack_self(mob/user)
	active = !active
	if(active)
		user << "\blue The axe is now energised."
		force = 150
		icon_state = "axe1"
		w_class = 5
		heat_source = 3500
	else
		user << "\blue The axe can now be concealed."
		force = 40
		icon_state = "axe0"
		w_class = 5
		heat_source = 0
	add_fingerprint(user)



/obj/item/weapon/energy/sword
	name = "energy sword"
	desc = "May the force be within you."
	icon_state = "sword0"
	force = 3.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = 2.0
	flags_atom = FPRINT|NOBLOODY
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
	if ((CLUMSY in user.mutations) && prob(50))
		user << "\red You accidentally cut yourself with [src]."
		user.take_limb_damage(5,5)
	active = !active
	if (active)
		force = 30
		heat_source = 3500
		if(base_sword_icon != "sword")
			icon_state = "[base_sword_icon]1"
		else
			icon_state = "sword[sword_color]"
		w_class = 4
		playsound(user, 'sound/weapons/saberon.ogg', 25, 1)
		user << "\blue [src] is now active."

	else
		force = 3
		heat_source = 0
		icon_state = "[base_sword_icon]0"
		w_class = 2
		playsound(user, 'sound/weapons/saberoff.ogg', 25, 1)
		user << "\blue [src] can now be concealed."

	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		H.update_inv_l_hand(0)
		H.update_inv_r_hand()

	add_fingerprint(user)
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




