

/obj/item/weapon/banhammer
	desc = "A banhammer"
	name = "banhammer"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "toyhammer"
	flags_equip_slot = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 7
	throw_range = 15
	attack_verb = list("banned")

/obj/item/weapon/banhammer/suicide_act(mob/user)
	user.visible_message(span_danger("[user] is hitting [p_them()]self with the [name]! It looks like [user.p_theyre()] trying to ban [p_them()]self from life."))
	return (BRUTELOSS|FIRELOSS|TOXLOSS|OXYLOSS)

/obj/item/weapon/nullrod
	name = "null rod"
	desc = "A rod of pure obsidian, its very presence disrupts and dampens the powers of paranormal phenomenae."
	icon_state = "nullrod"
	item_state = "nullrod"
	flags_equip_slot = ITEM_SLOT_BELT
	force = 15
	throw_speed = 1
	throw_range = 4
	throwforce = 10
	w_class = WEIGHT_CLASS_SMALL

/obj/item/weapon/nullrod/suicide_act(mob/user)
	user.visible_message(span_danger("[user] is impaling [p_them()]self with the [name]! It looks like [user.p_theyre()] trying to commit suicide."))
	return (BRUTELOSS|FIRELOSS)

/obj/item/weapon/harpoon
	name = "harpoon"
	sharp = IS_SHARP_ITEM_SIMPLE
	edge = 0
	desc = "Tharr she blows!"
	icon_state = "harpoon"
	item_state = "harpoon"
	force = 20
	throwforce = 15
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("jabbed","stabbed","ripped")

/obj/item/weapon/baseballbat
	name = "\improper wooden baseball bat"
	desc = "A large wooden baseball bat. Commonly used in colony recreation, but also used as a means of self defense. Often carried by thugs and ruffians."
	icon_state = "woodbat"
	item_state = "woodbat"
	sharp = 0
	edge = 0
	w_class = WEIGHT_CLASS_NORMAL
	force = 20
	throw_speed = 3
	throw_range = 7
	throwforce = 7
	attack_verb = list("smashed", "beaten", "slammed", "struck", "smashed", "battered", "cracked")
	hitsound = 'sound/weapons/genhit3.ogg'


/obj/item/weapon/baseballbat/metal
	name = "\improper metal baseball bat"
	desc = "A large metal baseball bat. Compared to its wooden cousin, the metal bat offers a bit more more force. Often carried by thugs and ruffians."
	icon_state = "metalbat"
	item_state = "metalbat"
	force = 25
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/weapon/butterfly
	name = "butterfly knife"
	desc = "A basic metal blade concealed in a lightweight plasteel grip. Small enough when folded to fit in a pocket."
	icon_state = "butterflyknife"
	item_state = null
	hitsound = null
	w_class = WEIGHT_CLASS_TINY
	force = 8
	sharp = 0
	edge = 0
	throw_speed = 3
	throw_range = 4
	throwforce = 7
	attack_verb = list("patted", "tapped")
	attack_speed = 4


/obj/item/weapon/butterfly/attack_self(mob/user)
	active = !active
	if(active)
		to_chat(user, span_notice("You flip out your [src]."))
		playsound(user, 'sound/weapons/flipblade.ogg', 15, 1)
		force = 15
		throwforce = 12
		edge = TRUE
		sharp = IS_SHARP_ITEM_ACCURATE
		hitsound = 'sound/weapons/bladeslice.ogg'
		icon_state += "_open"
		w_class = WEIGHT_CLASS_NORMAL
		attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
		return
	to_chat(user, span_notice("The [src] can now be concealed."))
	force = initial(force)
	edge = FALSE
	sharp = IS_NOT_SHARP_ITEM
	hitsound = initial(hitsound)
	icon_state = initial(icon_state)
	w_class = initial(w_class)
	attack_verb = initial(attack_verb)

/obj/item/weapon/butterfly/switchblade
	name = "switchblade"
	desc = "A classic switchblade with gold engraving. Just holding it makes you feel like a gangster."
	icon_state = "switchblade"


/obj/item/weapon/wirerod
	name = "wired rod"
	desc = "A rod with some wire wrapped around the top. It'd be easy to attach something to the top bit."
	icon_state = "wiredrod"
	item_state = "rods"
	flags_atom = CONDUCT
	force = 8
	throwforce = 10
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("hit", "bludgeoned", "whacked", "bonked")


/obj/item/weapon/wirerod/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/shard))
		var/obj/item/weapon/twohanded/spear/S = new

		user.put_in_hands(S)
		to_chat(user, span_notice("You fasten the glass shard to the top of the rod with the cable."))
		qdel(I)
		qdel(src)
		update_icon(user)
