
//Alium nests. Essentially beds with an unbuckle delay that only aliums can buckle mobs to.
/obj/structure/bed/nest
	name = "alien nest"
	desc = "It's a gruesome pile of thick, sticky resin shaped like a nest."
	icon = 'icons/Xeno/Effects.dmi'
	icon_state = "nest"
	buckling_y = 6
	buildstacktype = null //can't be disassembled and doesn't drop anything when destroyed
	unacidable = TRUE
	var/health = 100
	var/on_fire = 0
	var/resisting = 0
	var/resisting_ready = 0
	var/nest_resist_time = 1200
	layer = RESIN_STRUCTURE_LAYER

/obj/structure/bed/nest/New()
	..()
	if(!locate(/obj/effect/alien/weeds) in loc) new /obj/effect/alien/weeds(loc)

/obj/structure/bed/nest/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/grab))
		var/obj/item/grab/G = W
		if(ismob(G.grabbed_thing))
			var/mob/M = G.grabbed_thing
			to_chat(user, "<span class='notice'>You place [M] on [src].</span>")
			M.forceMove(loc)
		return TRUE
	else
		if(W.flags_item & NOBLUDGEON) return
		var/aforce = W.force
		health = max(0, health - aforce)
		playsound(loc, "alien_resin_break", 25)
		user.visible_message("<span class='warning'>\The [user] hits \the [src] with \the [W]!</span>", \
		"<span class='warning'>You hit \the [src] with \the [W]!</span>")
		healthcheck()

/obj/structure/bed/nest/manual_unbuckle(mob/user)
	if(buckled_mob)
		if(buckled_mob.buckled == src)
			if(buckled_mob != user)
				if(user.stat || user.lying || user.is_mob_restrained())
					return
				buckled_mob.visible_message("<span class='notice'>\The [user] pulls \the [buckled_mob] free from \the [src]!</span>",\
				"<span class='notice'>\The [user] pulls you free from \the [src].</span>",\
				"<span class='notice'>You hear squelching.</span>")
				playsound(loc, "alien_resin_move", 50)
				if(ishuman(buckled_mob))
					var/mob/living/carbon/human/H = buckled_mob
					H.start_nesting_cooldown()
				unbuckle()
			else
				if(buckled_mob.stat)
					to_chat(buckled_mob, "<span class='warning'>You're a little too unconscious to try that.</span>")
					return
				if(resisting_ready && buckled_mob == user && buckled_mob.stat != DEAD)
					buckled_mob.visible_message("<span class='danger'>\The [buckled_mob] breaks free from \the [src]!</span>",\
					"<span class='danger'>You pull yourself free from \the [src]!</span>",\
					"<span class='notice'>You hear squelching.</span>")
					unbuckle()
					return
				if(resisting)
					to_chat(buckled_mob, "<span class='warning'>You're already trying to free yourself. Give it some time.</span>")
					return
				if(buckled_mob && buckled_mob.name)
					buckled_mob.visible_message("<span class='warning'>\The [buckled_mob] struggles to break free of \the [src].</span>",\
					"<span class='warning'>You struggle to break free from \the [src].</span>",\
					"<span class='notice'>You hear squelching.</span>")
				resisting = 1
				var/mob/oldbuckled = buckled_mob
				spawn(nest_resist_time)
					if(resisting && buckled_mob == oldbuckled && buckled_mob.stat != DEAD) //Must be alive and conscious
						resisting = 0
						resisting_ready = 1
						if(ishuman(usr))
							var/mob/living/carbon/human/H = usr
							if(H.handcuffed)
								to_chat(buckled_mob, "<span class='danger'>You are ready to break free of the nest, but your limbs are still secured. Resist once more to pop up, then resist again to break your limbs free!</span>")
							else
								to_chat(buckled_mob, "<span class='danger'>You are ready to break free! Resist once more to free yourself!</span>")
			add_fingerprint(user)

/mob/living/carbon/human/proc/start_nesting_cooldown()
	set waitfor = 0
	recently_unbuckled = 1
	sleep(50)
	recently_unbuckled = 0

/obj/structure/bed/nest/buckle_mob(mob/M as mob, mob/user as mob)

	if(!ismob(M) || (get_dist(src, user) > 1) || (M.loc != loc) || user.is_mob_restrained() || user.stat || user.lying || M.buckled || !iscarbon(user))
		return

	if(buckled_mob)
		to_chat(user, "<span class='warning'>There's already someone in [src].</span>")
		return

	if(M.mob_size > MOB_SIZE_HUMAN)
		to_chat(user, "<span class='warning'>\The [M] is too big to fit in [src].</span>")
		return

	if(!isXeno(user))
		to_chat(user, "<span class='warning'>Gross! You're not touching that stuff.</span>")
		return

	if(isYautja(M))
		to_chat(user, "<span class='warning'>\The [M] seems to be wearing some kind of resin-resistant armor!</span>")
		return

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.recently_unbuckled)
			to_chat(user, "<span class='warning'>[M] was recently unbuckled. Wait a bit.</span>")
			return

	if(M == user)
		return

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!H.lying) //Don't ask me why is has to be
			to_chat(user, "<span class='warning'>[M] is resisting, ground them.</span>")
			return

	user.visible_message("<span class='warning'>[user] pins [M] into [src], preparing the securing resin.</span>",
	"<span class='warning'>[user] pins [M] into [src], preparing the securing resin.</span>")
	var/M_loc = M.loc
	if(do_after(user, 15, TRUE, 5, BUSY_ICON_HOSTILE))
		if(M.loc != M_loc) return
		if(buckled_mob) //Just in case
			to_chat(user, "<span class='warning'>There's already someone in [src].</span>")
			return
		if(ishuman(M)) //Improperly stunned Marines won't be nested
			var/mob/living/carbon/human/H = M
			if(!H.lying) //Don't ask me why is has to be
				to_chat(user, "<span class='warning'>[M] is resisting, ground them.</span>")
				return
		do_buckle(M, user)

/obj/structure/bed/nest/send_buckling_message(mob/M, mob/user)
	M.visible_message("<span class='xenonotice'>[user] secretes a thick, vile resin, securing [M] into [src]!</span>", \
	"<span class='xenonotice'>[user] drenches you in a foul-smelling resin, trapping you in [src]!</span>", \
	"<span class='notice'>You hear squelching.</span>")
	playsound(loc, "alien_resin_move", 50)

/obj/structure/bed/nest/afterbuckle(mob/M)
	. = ..()
	if(. && M.pulledby)
		M.pulledby.stop_pulling()
		resisting = 0 //just in case
		resisting_ready = 0
	update_icon()

/obj/structure/bed/nest/unbuckle(mob/user as mob)
	if(!buckled_mob)
		return
	resisting = 0
	resisting_ready = 0
	buckled_mob.pixel_y = 0
	buckled_mob.old_y = 0
	..()


/obj/structure/bed/nest/update_icon()
	overlays.Cut()
	if(on_fire)
		overlays += "alien_fire"
	if(buckled_mob)
		overlays += image("icon_state"="nest_overlay","layer"=LYING_MOB_LAYER + 0.1)


/obj/structure/bed/nest/proc/healthcheck()
	if(health <= 0)
		density = 0
		cdel(src)

/obj/structure/bed/nest/fire_act()
	on_fire = 1
	if(on_fire)
		update_icon()
		spawn(rand(225, 400))
			cdel(src)


/obj/structure/bed/nest/attack_alien(mob/living/carbon/Xenomorph/M)
	if(isXenoLarva(M)) //Larvae can't do shit
		return
	if(M.a_intent == "hurt")
		M.visible_message("<span class='danger'>\The [M] claws at \the [src]!</span>", \
		"<span class='danger'>You claw at \the [src].</span>")
		playsound(loc, "alien_resin_break", 25)
		health -= (M.melee_damage_upper + 25) //Beef up the damage a bit
		healthcheck()
	else
		attack_hand(M)

/obj/structure/bed/nest/attack_animal(mob/living/M as mob)
	M.visible_message("<span class='danger'>\The [M] tears at \the [src]!", \
	"<span class='danger'>You tear at \the [src].")
	playsound(loc, "alien_resin_break", 25)
	health -= 40
	healthcheck()

/obj/structure/bed/nest/flamer_fire_act()
	cdel(src)
