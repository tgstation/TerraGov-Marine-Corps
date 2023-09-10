/obj/item/toy/plush/pig
	name = "pig toy"
	desc = "Captain Dementy! Bring the pigs! Marines demand pigs!."
	icon = 'modular_RUtgmc/icons/obj/items/toy.dmi'
	icon_state = "pig"
	item_state = "pig"
	attack_verb = list("oinks", "grunts")

/obj/item/toy/plush/pig/attack_self(mob/user)
	if(world.time > last_hug_time)
		user.visible_message(span_notice("[user] presses [src]! Oink! "), \
							span_notice("You press [src]. Oink! "))
		last_hug_time = world.time + 50 //5 second cooldown

// /obj/item/toy/plush/pig/Initialize()
// 	. = ..()
// 	AddComponent(/datum/component/squeak, 'sound/items/khryu.ogg', 50)

/obj/structure/bed/namaz
	name = "Prayer rug"
	desc = "Very halal prayer rug."
	icon = 'modular_RUtgmc/icons/obj/items/priest.dmi'
	icon_state = "namaz"
	buckle_flags = CAN_BUCKLE|BUCKLE_PREVENTS_PULL
	buckle_lying = 0
	buckling_y = 6
	dir = NORTH
	foldabletype = /obj/item/namaz
	accepts_bodybag = FALSE
	base_bed_icon = "namaz"

/obj/item/namaz
	name = "Prayer rug"
	desc = "Very halal prayer rug."
	icon = 'modular_RUtgmc/icons/obj/items/priest.dmi'
	icon_state = "rolled_namaz"
	w_class = WEIGHT_CLASS_SMALL
	var/rollertype = /obj/structure/bed/namaz

/obj/item/namaz/attack_self(mob/user)
	deploy_roller(user, user.loc)

/obj/item/namaz/afterattack(obj/target, mob/user , proximity)
	if(!proximity)
		return
	if(isturf(target))
		var/turf/T = target
		if(!T.density)
			deploy_roller(user, target)

/obj/item/namaz/attackby(obj/item/I, mob/user, params)
	. = ..()

/obj/item/namaz/proc/deploy_roller(mob/user, atom/location)
	var/obj/structure/bed/namaz/R = new rollertype(location) // R is not need here, but i dont know how to delete this shit
	user.temporarilyRemoveItemFromInventory(src)
	user.visible_message(span_notice(" [user] puts [R] down."), span_notice(" You put [R] down."))
	qdel(src)
