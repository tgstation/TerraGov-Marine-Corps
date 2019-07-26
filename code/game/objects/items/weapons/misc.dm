/obj/item/weapon/chainofcommand
	name = "chain of command"
	desc = "A tool used by great men to placate the frothing masses."
	icon_state = "chain"
	item_state = "chain"
	flags_atom = CONDUCT
	flags_equip_slot = ITEM_SLOT_BELT
	force = 10
	throwforce = 7
	w_class = WEIGHT_CLASS_NORMAL
	origin_tech = "combat=4"
	attack_verb = list("flogged", "whipped", "lashed", "disciplined")

/obj/item/weapon/chainofcommand/suicide_act(mob/user)
	user.visible_message("<span class='danger'>[user] is strangling [p_them()]self with the [src.name]! It looks like [user.p_theyre()] trying to commit suicide.</span>")
	return (OXYLOSS)


/obj/item/weapon/broken_bottle
	name = "Broken Bottle"
	desc = "A bottle with a sharp broken bottom."
	icon = 'icons/obj/items/drinks.dmi'
	icon_state = "broken_bottle"
	force = 9.0
	throwforce = 5.0
	throw_speed = 3
	throw_range = 5
	item_state = "broken_beer"
	attack_verb = list("stabbed", "slashed", "attacked")
	sharp = IS_SHARP_ITEM_SIMPLE
	edge = 0
	var/icon/broken_outline = icon('icons/obj/items/drinks.dmi', "broken")

/obj/item/weapon/broken_bottle/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	playsound(loc, 'sound/weapons/bladeslice.ogg', 25, 1)
	return ..()
