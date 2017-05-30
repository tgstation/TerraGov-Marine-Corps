
//Alium nests. Essentially beds with an unbuckle delay that only aliums can buckle mobs to.
/obj/structure/stool/bed/nest
	name = "alien nest"
	desc = "It's a gruesome pile of thick, sticky resin shaped like a nest."
	icon = 'icons/Xeno/Effects.dmi'
	icon_state = "nest"
	buckling_y = 6
	var/health = 100
	var/on_fire = 0
	var/resisting = 0
	var/resisting_ready = 0
	var/nest_resist_time = 1200
	layer = 2.9 //Just above weeds.

	New()
		..()
		if(!locate(/obj/effect/alien/weeds) in loc) new /obj/effect/alien/weeds(loc)

/obj/structure/stool/bed/nest/manual_unbuckle(mob/user as mob)
	if(buckled_mob)
		if(buckled_mob.buckled == src)
			if(buckled_mob != user)
				if(user.stat || user.is_mob_restrained())
					user << "<span class='warning'>Nice try.</span>"
					return
				buckled_mob.visible_message("<span class='notice'>\The [user] pulls \the [buckled_mob] free from \the [src]!</span>",\
				"<span class='notice'>\The [user] pulls you free from \the [src].</span>",\
				"<span class='notice'>You hear squelching.</span>")
				if(ishuman(buckled_mob))
					var/mob/living/carbon/human/H = buckled_mob
					H.start_nesting_cooldown()

				unbuckle()
			else
				if(buckled_mob.stat)
					buckled_mob << "<span class='warning'>You're a little too unconscious to try that.</span>"
					return
				if(resisting_ready && buckled_mob && buckled_mob.stat != DEAD && buckled_mob.loc == loc)
					buckled_mob.visible_message("<span class='danger'>\The [buckled_mob] breaks free from \the [src]!</span>",\
					"<span class='danger'>You pull yourself free from \the [src]!</span>",\
					"<span class='notice'>You hear squelching.</span>")
					unbuckle()
					resisting_ready = 0
				if(resisting)
					buckled_mob << "<span class='warning'>You're already trying to free yourself. Give it some time.</span>"
					return
				if(buckled_mob && buckled_mob.name)
					buckled_mob.visible_message("<span class='warning'>\The [buckled_mob] struggles to break free of \the [src].</span>",\
					"<span class='warning'>You struggle to break free from \the [src].</span>",\
					"<span class='notice'>You hear squelching.</span>")
				resisting = 1
				spawn(nest_resist_time)
					if(resisting && buckled_mob && buckled_mob.stat != DEAD && buckled_mob.loc == loc) //Must be alive and conscious
						resisting = 0
						resisting_ready = 1
						if(ishuman(usr))
							var/mob/living/carbon/human/H = usr
							if(H.handcuffed)
								buckled_mob << "<span class='danger'>You are ready to break free of the nest, but your limbs are still secured. Resist once more to pop up, then resist again to break your limbs free!</span>"
							else
								buckled_mob << "<span class='danger'>You are ready to break free! Resist once more to free yourself!</span>"
			src.add_fingerprint(user)

/mob/living/carbon/human/proc/start_nesting_cooldown()
	set waitfor = 0
	recently_unbuckled = 1
	sleep(300)
	recently_unbuckled = 0

/obj/structure/stool/bed/nest/buckle_mob(mob/M as mob, mob/user as mob)

	if(!ismob(M) || (get_dist(src, user) > 1) || (M.loc != src.loc) || user.is_mob_restrained() || usr.stat || M.buckled || !iscarbon(user))
		return

	if(buckled_mob)
		user << "<span class='warning'>There's already someone in that nest.</span>"
		return

	if(M.mob_size > MOB_SIZE_HUMAN)
		user << "<span class='warning'>\The [M] is too big to shove in the nest.</span>"
		return

	if(!isXeno(user))
		user << "<span class='warning'>Gross! You're not touching that stuff.</span>"
		return

	if(isYautja(M))
		user << "<span class='warning'>\The [M] seems to be wearing some kind of resin-resistant armor!</span>"
		return

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.recently_unbuckled)
			user << "<span class='warning'>[M] was recently unbuckled. Wait a bit.</span>"
			return

	if(M == user)
		return

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!H.lying) //Don't ask me why is has to be
			user << "<span class='warning'>[M] is resisting, tackle them first.</span>"
			return

	do_buckle(M, user)


/obj/structure/stool/bed/nest/send_buckling_message(mob/M, mob/user)
	M.visible_message("<span class='xenonotice'>[user] secretes a thick, vile resin, securing [M] into [src]!</span>", \
	"<span class='xenonotice'>[user] drenches you in a foul-smelling resin, trapping you in [src]!</span>", \
	"<span class='notice'>You hear squelching.</span>")

