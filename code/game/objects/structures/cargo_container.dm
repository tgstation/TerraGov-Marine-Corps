/obj/structure/cargo_container
	name = "Cargo Container"
	desc = "A huge industrial shipping container."
	icon = 'icons/contain.dmi'
	icon_state = "blue"
	bound_width = 32
	bound_height = 64
	density = 1
	var/health = 200
	opacity = 1
	anchored = 1

/obj/structure/cargo_container/attack_hand(mob/user as mob)

	playsound(loc, 'sound/effects/clang.ogg', 25, 1)

	var/damage_dealt
	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		if(H.species.can_shred(H))

			user.visible_message("<span class='warning'>[user] smashes [src] to no avail.</span>", \
					 "<span class='warning'>You beat against [src] to no effect</span>", \
					 "You hear twisting metal.")

	if(!damage_dealt)
		user.visible_message("<span class='warning'>[user] beats against the [src] to no avail.</span>", \
						 "<span class='warning'>[user] beats against the [src].</span>", \
						 "You hear twisting metal.")

/obj/structure/cargo_container/horizontal
	name = "Cargo Container"
	desc = "A huge industrial shipping container,"
	icon = 'icons/containHorizont.dmi'
	icon_state = "blue"
	bound_width = 64
	bound_height = 32
	density = 1
	health = 200
	opacity = 1



