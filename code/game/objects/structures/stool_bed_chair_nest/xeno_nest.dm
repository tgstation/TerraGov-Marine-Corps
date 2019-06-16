#define NEST_RESIST_TIME 1 MINUTES
#define NEST_UNBUCKLED_COOLDOWN 5 SECONDS

//Alium nests. Essentially beds with an unbuckle delay that only aliums can buckle mobs to.
/obj/structure/bed/nest
	name = "alien nest"
	desc = "It's a gruesome pile of thick, sticky resin shaped like a nest."
	icon = 'icons/Xeno/Effects.dmi'
	icon_state = "nest"
	buckling_y = 6
	buildstacktype = null //can't be disassembled and doesn't drop anything when destroyed
	resistance_flags = UNACIDABLE
	max_integrity = 100
	var/on_fire = 0
	var/resisting_time = 0
	layer = RESIN_STRUCTURE_LAYER

/obj/structure/bed/nest/Initialize(mapload)
	. = ..()
	if(!locate(/obj/effect/alien/weeds) in loc) 
		new /obj/effect/alien/weeds(loc)

/obj/structure/bed/nest/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/grab))
		var/obj/item/grab/G = I
		if(!ismob(G.grabbed_thing))
			return
		var/mob/M = G.grabbed_thing
		to_chat(user, "<span class='notice'>You place [M] on [src].</span>")
		M.forceMove(loc)

	else if(I.flags_item & NOBLUDGEON) 
		return

	obj_integrity = max(0, obj_integrity - I.force)
	playsound(loc, "alien_resin_break", 25)
	user.visible_message("<span class='warning'>\The [user] hits \the [src] with \the [I]!</span>", \
	"<span class='warning'>You hit \the [src] with \the [I]!</span>")
	healthcheck()


/obj/structure/bed/nest/manual_unbuckle(mob/living/user)
	if(!buckled_mob || buckled_mob.buckled != src)
		return


	if(buckled_mob != user)
		if(user.incapacitated())
			return
		buckled_mob.visible_message("<span class='notice'>\The [user] pulls \the [buckled_mob] free from \the [src]!</span>",\
		"<span class='notice'>\The [user] pulls you free from \the [src].</span>",\
		"<span class='notice'>You hear squelching.</span>")
		playsound(loc, "alien_resin_move", 50)
		if(ishuman(buckled_mob))
			var/mob/living/carbon/human/H = buckled_mob
			H.last_unbuckled = world.time
		unbuckle()
		return

	if(buckled_mob.incapacitated(TRUE))
		to_chat(buckled_mob, "<span class='warning'>You're currently unable to try that.</span>")
		return
	if(!resisting_time)
		resisting_time = world.time
		buckled_mob.visible_message("<span class='warning'>\The [buckled_mob] struggles to break free of \the [src].</span>",\
		"<span class='warning'>You struggle to break free from \the [src].</span>",\
		"<span class='notice'>You hear squelching.</span>")
		addtimer(CALLBACK(src, .proc/unbuckle_time_message, user), NEST_RESIST_TIME)
		return
	if(resisting_time + NEST_RESIST_TIME > world.time)
		to_chat(buckled_mob, "<span class='warning'>You're already trying to free yourself. Give it some time.</span>")
		return
	buckled_mob.visible_message("<span class='danger'>\The [buckled_mob] breaks free from \the [src]!</span>",\
	"<span class='danger'>You pull yourself free from \the [src]!</span>",\
	"<span class='notice'>You hear squelching.</span>")
	unbuckle()


/obj/structure/bed/nest/proc/unbuckle_time_message(mob/living/user)
	if(QDELETED(user) || user != buckled_mob)
		return //Time has passed, conditions may have changed.
	if(resisting_time + NEST_RESIST_TIME > world.time)
		return //We've been freed and re-nested.
	to_chat(buckled_mob, "<span class='danger'>You are ready to break free! Resist once more to free yourself!</span>")


/obj/structure/bed/nest/buckle_mob(mob/living/L, mob/living/user)

	if(user.incapacitated() || (get_dist(src, user) > 1) || (L.loc != loc) || L.buckled)
		return
	if(!isxeno(user))
		to_chat(user, "<span class='warning'>Gross! You're not touching that stuff.</span>")
		return
	if(buckled_mob)
		to_chat(user, "<span class='warning'>There's already someone in [src].</span>")
		return
	if(L.mob_size > MOB_SIZE_HUMAN)
		to_chat(user, "<span class='warning'>\The [L] is too big to fit in [src].</span>")
		return
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		if(H.last_unbuckled + NEST_UNBUCKLED_COOLDOWN > world.time)
			to_chat(user, "<span class='warning'>[H] was recently unbuckled. Wait a bit.</span>")
			return
		if(!H.lying)
			to_chat(user, "<span class='warning'>[H] is resisting, ground [H.p_them()].</span>")
			return

	user.visible_message("<span class='warning'>[user] pins [L] into [src], preparing the securing resin.</span>",
	"<span class='warning'>[user] pins [L] into [src], preparing the securing resin.</span>")
	if(!do_after(user, 15, TRUE, L, BUSY_ICON_HOSTILE))
		return
	if(QDELETED(src))
		return
	if(buckled_mob)
		to_chat(user, "<span class='warning'>There's already someone in [src].</span>")
		return
	if(ishuman(L) && !L.lying) //Improperly stunned Marines won't be nested
		to_chat(user, "<span class='warning'>[L] is resisting, ground [L.p_them()].</span>")
		return

	do_buckle(L, user)


/obj/structure/bed/nest/send_buckling_message(mob/M, mob/user)
	M.visible_message("<span class='xenonotice'>[user] secretes a thick, vile resin, securing [M] into [src]!</span>", \
	"<span class='xenonotice'>[user] drenches you in a foul-smelling resin, trapping you in [src]!</span>", \
	"<span class='notice'>You hear squelching.</span>")
	playsound(loc, "alien_resin_move", 50)


/obj/structure/bed/nest/afterbuckle(mob/M)
	. = ..()
	if(!.)
		return
	M.pulledby?.stop_pulling()


/obj/structure/bed/nest/unbuckle(mob/user)
	if(!buckled_mob)
		return
	resisting_time = 0 //Reset it to keep track on if someone is actively resisting.
	buckled_mob.pixel_y = 0
	buckled_mob.old_y = 0
	return ..()


/obj/structure/bed/nest/update_icon()
	overlays.Cut()
	if(on_fire)
		overlays += "alien_fire"
	if(buckled_mob)
		overlays += image("icon_state"="nest_overlay","layer"=LYING_MOB_LAYER + 0.1)


/obj/structure/bed/nest/proc/healthcheck()
	if(obj_integrity <= 0)
		density = 0
		qdel(src)

/obj/structure/bed/nest/flamer_fire_act()
	obj_integrity -= 50
	healthcheck()

/obj/structure/bed/nest/fire_act()
	obj_integrity -= 50
	healthcheck()

/obj/structure/bed/nest/attack_alien(mob/living/carbon/xenomorph/M)
	if(isxenolarva(M)) //Larvae can't do shit
		return
	if(M.a_intent == INTENT_HARM)
		M.visible_message("<span class='danger'>\The [M] claws at \the [src]!</span>", \
		"<span class='danger'>You claw at \the [src].</span>")
		playsound(loc, "alien_resin_break", 25)
		obj_integrity -= (M.melee_damage_upper + 25) //Beef up the damage a bit
		healthcheck()
		SEND_SIGNAL(M, COMSIG_XENOMORPH_ATTACK_NEST)
	else
		attack_hand(M)

/obj/structure/bed/nest/attack_animal(mob/living/L)
	L.visible_message("<span class='danger'>\The [L] tears at \the [src]!", \
	"<span class='danger'>You tear at \the [src].")
	playsound(loc, "alien_resin_break", 25)
	obj_integrity -= 40
	healthcheck()


#undef NEST_RESIST_TIME
#undef NEST_UNBUCKLED_COOLDOWN