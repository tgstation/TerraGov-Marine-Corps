/obj/item/tool/extinguisher
	name = "fire extinguisher"
	desc = "A traditional red fire extinguisher."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "fire_extinguisher0"
	item_state = "fire_extinguisher"
	hitsound = 'sound/weapons/smash.ogg'
	flags_atom = CONDUCT
	throwforce = 10
	w_class = 3.0
	throw_speed = 2
	throw_range = 10
	force = 10.0
	matter = list("metal" = 90)
	attack_verb = list("slammed", "whacked", "bashed", "thunked", "battered", "bludgeoned", "thrashed")
	var/max_water = 50
	var/last_use = 1.0
	var/safety = 1
	var/sprite_name = "fire_extinguisher"

/obj/item/tool/extinguisher/Initialize(mapload)
	. = ..()
	create_reagents(max_water, AMOUNT_VISIBLE, list("water" = max_water))

/obj/item/tool/extinguisher/mini
	name = "fire extinguisher"
	desc = "A light and compact fibreglass-framed model fire extinguisher."
	icon_state = "miniFE0"
	item_state = "miniFE"
	hitsound = null	//it is much lighter, after all.
	throwforce = 2
	w_class = 2.0
	force = 3.0
	max_water = 30
	sprite_name = "miniFE"

/obj/item/tool/extinguisher/examine(mob/user)
	..()
	to_chat(user, "The safety is [safety ? "on" : "off"].")

/obj/item/tool/extinguisher/attack_self(mob/user as mob)
	safety = !safety
	icon_state = "[sprite_name][!safety]"
	to_chat(user, "The safety is [safety ? "on" : "off"].")
	return

/obj/item/tool/extinguisher/afterattack(atom/target, mob/user, flag)
	//TODO; Add support for reagents in water.

	if( istype(target, /obj/structure/reagent_dispensers/watertank) && get_dist(src,target) <= 1)
		var/obj/o = target
		o.reagents.trans_to(src, 50)
		to_chat(user, "<span class='notice'>\The [src] is now refilled</span>")
		playsound(src.loc, 'sound/effects/refill.ogg', 25, 1, 3)
		return

	if (safety)
		return ..()
	if (world.time < last_use + 20)
		return
	extinguish(target, user)
	last_use = world.time

	return
