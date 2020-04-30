/obj/item/weapon/claymore
	name = "claymore"
	desc = "What are you standing around staring at this for? Get to killing!"
	icon_state = "claymore"
	item_state = "claymore"
	flags_atom = CONDUCT
	flags_equip_slot = ITEM_SLOT_BELT
	force = 40
	throwforce = 10
	sharp = IS_SHARP_ITEM_BIG
	edge = 1
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

/obj/item/weapon/claymore/suicide_act(mob/user)
	user.visible_message("<span class='danger'>[user] is falling on the [src.name]! It looks like [user.p_theyre()] trying to commit suicide.</span>")
	return(BRUTELOSS)

/obj/item/weapon/claymore/mercsword
	name = "combat sword"
	desc = "A dusty sword commonly seen in historical museums. Where you got this is a mystery, for sure. Only a mercenary would be nuts enough to carry one of these. Sharpened to deal massive damage."
	icon_state = "mercsword"
	item_state = "machete"
	force = 39


/obj/item/weapon/claymore/mercsword/captain
	name = "Ceremonial Sword"
	desc = "A fancy ceremonial sword passed down from generation to generation. Despite this, it has been very well cared for, and is in top condition."
	icon_state = "mercsword"
	item_state = "machete"
	force = 48

/obj/item/weapon/claymore/mercsword/machete
	name = "\improper M2132 machete"
	desc = "Latest issue of the TGMC Machete. Great for clearing out jungle or brush on outlying colonies. Found commonly in the hands of scouts and trackers, but difficult to carry with the usual kit."
	icon_state = "machete"
	force = 60
	attack_speed = 12
	w_class = WEIGHT_CLASS_BULKY

/obj/item/weapon/claymore/mercsword/commissar_sword
	name = "\improper commissars sword"
	desc = "The pride of an imperial commissar, held high as they charge into battle."
	icon_state = "comsword"
	item_state = "comsword"
	force = 80
	attack_speed = 10
	w_class = WEIGHT_CLASS_BULKY

/obj/item/weapon/claymore/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	playsound(loc, 'sound/weapons/bladeslice.ogg', 25, 1)
	return ..()

/obj/item/weapon/katana
	name = "katana"
	desc = "A finely made Japanese sword, with a well sharpened blade. The blade has been filed to a molecular edge, and is extremely deadly. Commonly found in the hands of mercenaries and yakuza."
	icon_state = "katana"
	flags_atom = CONDUCT
	force = 50
	throwforce = 10
	sharp = IS_SHARP_ITEM_BIG
	edge = 1
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

/obj/item/weapon/katana/suicide_act(mob/user)
	user.visible_message("<span class='danger'>[user] is slitting [user.p_their()] stomach open with the [name]! It looks like [user.p_theyre()] trying to commit seppuku.</span>")
	return(BRUTELOSS)

//To do: replace the toys.
/obj/item/weapon/katana/replica
	name = "replica katana"
	desc = "A cheap knock-off commonly found in regular knife stores. Can still do some damage."
	force = 27
	throwforce = 7

/obj/item/weapon/katana/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	playsound(loc, 'sound/weapons/bladeslice.ogg', 25, 1)
	return ..()

/obj/item/weapon/combat_knife
	name = "\improper M5 'Night Raider' survival knife"
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "combat_knife"
	item_state = "combat_knife"
	desc = "The standard issue survival knife issued to TerraGov Marine Corps soldiers. You can slide this knife into your boots, and can be field-modified to attach to the end of a rifle."
	flags_atom = CONDUCT
	sharp = IS_SHARP_ITEM_ACCURATE
	materials = list(/datum/material/metal = 200)
	force = 25
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 20
	throw_speed = 3
	throw_range = 6
	attack_speed = 7
	hitsound = 'sound/weapons/slash.ogg'
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")


	attackby(obj/item/I as obj, mob/user as mob)
		if(istype(I,/obj/item/stack/cable_coil))
			var/obj/item/stack/cable_coil/CC = I
			if (CC.use(5))
				to_chat(user, "You wrap some cable around the bayonet. It can now be attached to a gun.")
				if(loc == user)
					user.temporarilyRemoveItemFromInventory(src)
				var/obj/item/attachable/bayonet/F = new(src.loc)
				user.put_in_hands(F) //This proc tries right, left, then drops it all-in-one.
				if(F.loc != user) //It ended up on the floor, put it whereever the old flashlight is.
					F.loc = get_turf(src)
				qdel(src) //Delete da old knife
			else
				to_chat(user, "<span class='notice'>You don't have enough cable for that.</span>")
				return
		else
			..()

/obj/item/weapon/combat_knife/suicide_act(mob/user)
	user.visible_message(pick("<span class='danger'>[user] is slitting [user.p_their()] wrists with the [name]! It looks like [user.p_theyre()] trying to commit suicide.</span>", \
							"<span class='danger'>[user] is slitting [user.p_their()] throat with the [name]! It looks like [user.p_theyre()] trying to commit suicide.</span>", \
							"<span class='danger'>[user] is slitting [user.p_their()] stomach open with the [name]! It looks like [user.p_theyre()] trying to commit seppuku.</span>"))
	return (BRUTELOSS)

/obj/item/weapon/combat_knife/upp
	name = "\improper Type 30 survival knife"
	icon_state = "upp_knife"
	item_state = "knife"
	desc = "The standard issue survival knife of the UPP forces, the Type 30 is effective, but humble. It is small enough to be non-cumbersome, but lethal none-the-less."
	force = 20
	throwforce = 10
	throw_speed = 2
	throw_range = 8


/obj/item/weapon/throwing_knife
	name ="\improper M11 throwing knife"
	icon='icons/obj/items/weapons.dmi'
	icon_state = "throwing_knife"
	desc="A military knife designed to be thrown at the enemy. Much quieter than a firearm, but requires a steady hand to be used effectively."
	flags_atom = CONDUCT
	sharp = IS_SHARP_ITEM_ACCURATE
	force = 10
	w_class = WEIGHT_CLASS_TINY
	throwforce = 35
	throw_speed = 4
	throw_range = 7
	hitsound = 'sound/weapons/slash.ogg'
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	flags_equip_slot = ITEM_SLOT_POCKET



/obj/item/weapon/unathiknife
	name = "duelling knife"
	desc = "A length of leather-bound wood studded with razor-sharp teeth. How crude."
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "unathiknife"
	attack_verb = list("ripped", "torn", "cut")

/obj/item/weapon/unathiknife/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	playsound(loc, 'sound/weapons/bladeslice.ogg', 25, 1)
	return ..()
