//Basic two handed weapons without complicated extra behavior

/obj/item/weapon/twohanded/fireaxe
	name = "fire axe"
	desc = "Truly, the weapon of a madman. Who would think to fight fire with an axe?"
	icon_state = "fireaxe"
	worn_icon_state = "fireaxe"
	force = 35
	sharp = IS_SHARP_ITEM_BIG
	edge = TRUE
	equip_slot_flags = ITEM_SLOT_BELT|ITEM_SLOT_BACK
	atom_flags = CONDUCT
	item_flags = TWOHANDED
	force_activated = 80
	attack_verb = list("attacks", "chops", "cleaves", "tears", "cuts")

/obj/item/weapon/twohanded/fireaxe/wield(mob/user)
	. = ..()
	if(!.)
		return
	pry_capable = IS_PRY_CAPABLE_SIMPLE

/obj/item/weapon/twohanded/fireaxe/unwield(mob/user)
	. = ..()
	if(!.)
		return
	pry_capable = 0

/obj/item/weapon/twohanded/glaive
	name = "war glaive"
	icon_state = "glaive"
	worn_icon_state = "glaive"
	desc = "A huge, powerful blade on a metallic pole. Mysterious writing is carved into the weapon."
	force = 28
	equip_slot_flags = ITEM_SLOT_BACK
	force_activated = 90
	penetration = 20
	throwforce = 65
	throw_speed = 3
	edge = 1
	sharp = IS_SHARP_ITEM_BIG
	atom_flags = CONDUCT
	attack_verb = list("slices", "slashes", "jabs", "tears", "gores")
	resistance_flags = UNACIDABLE
	attack_speed = 16

/obj/item/weapon/twohanded/glaive/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	playsound(loc, 'sound/weapons/bladeslice.ogg', 25, 1)
	return ..()

/obj/item/weapon/twohanded/glaive/damaged
	name = "war glaive"
	desc = "A huge, powerful blade on a metallic pole. Mysterious writing is carved into the weapon. This one is ancient and has suffered serious acid damage, making it near-useless."
	force = 18
	force_activated = 28

/obj/item/weapon/twohanded/sledgehammer
	name = "sledge hammer"
	desc = "A heavy hammer that's good at smashing rocks, but would probably make a good weapon considering the circumstances."
	icon_state = "sledgehammer"
	worn_icon_state = "sledgehammer"
	force = 35
	equip_slot_flags = ITEM_SLOT_BACK
	atom_flags = CONDUCT
	item_flags = TWOHANDED
	force_activated = 95
	penetration = 10
	attack_speed = 20
	attack_verb = list("attacks", "wallops", "smashes", "shatters", "bashes")

/obj/item/weapon/twohanded/sledgehammer/wield(mob/user)
	. = ..()
	if(!.)
		return
	toggle_item_bump_attack(user, TRUE)

/obj/item/weapon/twohanded/sledgehammer/unwield(mob/user)
	. = ..()
	if(!.)
		return
	toggle_item_bump_attack(user, FALSE)
