/obj/structure/bed/stool
	name = "stool"
	desc = "Apply butt."
	icon_state = "stool"
	anchored = TRUE
	buckle_flags = NONE
	foldabletype = /obj/item/stool


/obj/item/stool
	name = "stool"
	desc = "Uh-hoh, bar is heating up."
	icon = 'icons/obj/objects.dmi'
	icon_state = "stool"
	force = 15
	throwforce = 12
	w_class = WEIGHT_CLASS_HUGE
	var/obj/structure/bed/stool/origin = null

/obj/item/stool/alt
	icon_state = "stool_alt"

/obj/item/stool/proc/deploy(mob/user)

	if(!origin)
		user.temporarilyRemoveItemFromInventory(src)
		qdel(src)
		return

	if(user)
		origin.loc = get_turf(user)
		user.temporarilyRemoveItemFromInventory(src)
		user.visible_message(span_notice(" [user] puts [src] down."), span_notice(" You put [src] down."))
		qdel(src)

/obj/item/stool/attack_self(mob/user as mob)
	..()
	deploy(user)

/obj/item/stool/attack(mob/M as mob, mob/user as mob)
	if (prob(25) && istype(M,/mob/living))
		user.visible_message(span_warning(" [user] breaks [src] over [M]'s back!"))
		user.temporarilyRemoveItemFromInventory(src)
		var/obj/item/stack/sheet/metal/m = new/obj/item/stack/sheet/metal
		m.loc = get_turf(src)
		var/mob/living/T = M
		if(istype(T) && !isxeno(T))
			T.Paralyze(20 SECONDS)
		T.apply_damage(20)
		UPDATEHEALTH(T)
		qdel(src)
		return
	..()
