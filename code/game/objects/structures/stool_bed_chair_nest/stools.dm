/obj/structure/bed/stool
	name = "stool"
	desc = "Apply butt."
	icon_state = "stool"
	anchored = TRUE
	can_buckle = FALSE
	foldabletype = /obj/item/stool



/obj/item/stool
	name = "stool"
	desc = "Uh-hoh, bar is heating up."
	icon = 'icons/obj/objects.dmi'
	icon_state = "stool"
	force = 15
	throwforce = 12
	w_class = 5.0
	var/obj/structure/bed/stool/origin = null

/obj/item/stool/proc/deploy(mob/user)

	if(!origin)
		user.temporarilyRemoveItemFromInventory(src)
		qdel(src)
		return

	if(user)
		origin.loc = get_turf(user)
		user.temporarilyRemoveItemFromInventory(src)
		user.visible_message("<span class='notice'> [user] puts [src] down.</span>", "<span class='notice'> You put [src] down.</span>")
		qdel(src)

/obj/item/stool/attack_self(mob/user as mob)
	..()
	deploy(user)

/obj/item/stool/attack(mob/M as mob, mob/user as mob)
	if (prob(25) && istype(M,/mob/living))
		user.visible_message("<span class='warning'> [user] breaks [src] over [M]'s back!</span>")
		user.temporarilyRemoveItemFromInventory(src)
		var/obj/item/stack/sheet/metal/m = new/obj/item/stack/sheet/metal
		m.loc = get_turf(src)
		var/mob/living/T = M
		if(istype(T) && !isxeno(T))
			T.KnockDown(10)
		T.apply_damage(20)
		qdel(src)
		return
	..()
