//Alium nests. Essentially beds with an unbuckle delay that only aliums can buckle mobs to.
#define NEST_RESIST_TIME 1200

/obj/structure/stool/bed/nest
	name = "alien nest"
	desc = "It's a gruesome pile of thick, sticky resin shaped like a nest."
	icon = 'icons/Xeno/Effects.dmi'
	icon_state = "nest"
	var/health = 100
	var/on_fire = 0
	var/resisting = 0


/obj/structure/stool/bed/nest/manual_unbuckle(mob/user as mob)
	if(buckled_mob)
		if(buckled_mob.buckled == src)
			if(buckled_mob != user)
				if(user.stat || user.restrained())
					user << "Nice try."
					return
				buckled_mob.visible_message(\
					"<span class='notice'>[user.name] pulls [buckled_mob.name] free from the sticky nest!</span>",\
					"<span class='notice'>[user.name] pulls you free from the gelatinous resin.</span>",\
					"<span class='notice'>You hear squelching...</span>")
				if(istype(buckled_mob,/mob/living/carbon/human))
					var/mob/living/carbon/human/H = buckled_mob
					H.recently_unbuckled = 1
					spawn(120)
						if(H) //Make sure the mob reference still exists.
							H.recently_unbuckled = 0

				unbuckle()
			else
				if(buckled_mob.stat)
					buckled_mob << "You're a little too unconscious to try that."
					return
				if(resisting)
					buckled_mob << "You're already trying to free yourself. Give it some time."
					return
				buckled_mob.visible_message(\
					"<span class='warning'>[buckled_mob.name] struggles to break free of the gelatinous resin...</span>",\
					"<span class='warning'>You struggle to break free from the gelatinous resin...</span>",\
					"<span class='notice'>You hear squelching...</span>")
				resisting = 1
				spawn(NEST_RESIST_TIME)
					if(buckled_mob && buckled_mob.stat != DEAD && buckled_mob.loc == loc) //Must be alive and conscious
						buckled_mob.visible_message(\
						"<span class='warning'>[buckled_mob.name] breaks free from the nest!</span>",\
						"<span class='warning'>You pull yourself free from the nest!</span>",\
						"<span class='notice'>You hear squelching...</span>")
						unbuckle()
			src.add_fingerprint(user)
	return

/obj/structure/stool/bed/nest/buckle_mob(mob/M as mob, mob/user as mob)

	if ( !ismob(M) || (get_dist(src, user) > 1) || (M.loc != src.loc) || user.restrained() || usr.stat || M.buckled || istype(user, /mob/living/silicon/pai) )
		return

	unbuckle()

	if (istype(M, /mob/living/carbon/Xenomorph))
		user << "The [M] is too big to shove in the nest."
		return

	if (!istype(user, /mob/living/carbon/Xenomorph))
		user << "Gross! You're not touching that stuff."
		return

	if(buckled_mob)
		user << "There's someone already in that nest."
		return

	if(istype(M,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		if(H.recently_unbuckled)
			user << "[M] was recently recently unbuckled. Wait a bit."
			return

	if(M == usr)
		return
	else
		M.visible_message(\
			"<span class='notice'>[user.name] secretes a thick vile goo, securing [M.name] into [src]!</span>",\
			"<span class='warning'>[user.name] drenches you in a foul-smelling resin, trapping you in the [src]!</span>",\
			"<span class='notice'>You hear squelching...</span>")
	M.buckled = src
	M.loc = src.loc
	M.dir = src.dir
	M.update_canmove()
	M.pixel_y = 6
	M.old_y = 6
	resisting = 0
	src.buckled_mob = M
	src.add_fingerprint(user)
	return

/obj/structure/stool/bed/nest/attackby(obj/item/weapon/W as obj, mob/user as mob)
	var/aforce = W.force
	health = max(0, health - aforce)
	playsound(loc, 'sound/effects/attackblob.ogg', 100, 1)
	for(var/mob/M in viewers(src, 7))
		M.show_message("<span class='warning'>[user] hits [src] with [W]!</span>", 1)
	healthcheck()

/obj/structure/stool/bed/nest/proc/healthcheck()
	if(health <=0)
		density = 0
		del(src)
	return

/obj/structure/stool/bed/nest/update_icon()
	overlays.Cut()
	if(on_fire)
		overlays += "alien_fire"

/obj/structure/stool/bed/nest/fire_act()
	on_fire = 1
	if(on_fire)
		update_icon()
		spawn(rand(225,400))
			del(src)

/obj/structure/stool/bed/nest/unbuckle(mob/user as mob)
	if(!buckled_mob) return
	resisting = 0
	buckled_mob.pixel_y = 0
	buckled_mob.old_y = 0
	..()