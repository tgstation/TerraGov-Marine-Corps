/obj/structure/bed/stool
	name = "stool"
	desc = "Apply butt."
	icon_state = "stool"
	anchored = 1
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

/obj/item/stool/proc/deploy(var/mob/user)

	if(!origin)
		user.temp_drop_inv_item(src)
		cdel(src)
		return

	if(user)
		origin.loc = get_turf(user)
		user.temp_drop_inv_item(src)
		user.visible_message("\blue [user] puts [src] down.", "\blue You put [src] down.")
		cdel(src)

/obj/item/stool/attack_self(mob/user as mob)
	..()
	deploy(user)

/obj/item/stool/attack(mob/M as mob, mob/user as mob)
	if (prob(25) && istype(M,/mob/living))
		user.visible_message("\red [user] breaks [src] over [M]'s back!")
		user.temp_drop_inv_item(src)
		var/obj/item/stack/sheet/metal/m = new/obj/item/stack/sheet/metal
		m.loc = get_turf(src)
		var/mob/living/T = M
		if(istype(T) && !isXeno(T))
			T.KnockDown(10)
		T.apply_damage(20)
		cdel(src)
		return
	..()
