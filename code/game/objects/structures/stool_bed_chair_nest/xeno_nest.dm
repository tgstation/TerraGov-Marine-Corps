#define NEST_RESIST_TIME 1 MINUTES
#define NEST_UNBUCKLED_COOLDOWN 5 SECONDS

//Alium nests. Essentially beds with an unbuckle delay that only aliums can buckle mobs to.
/obj/structure/bed/nest
	name = "alien nest"
	desc = "It's a gruesome pile of thick, sticky resin shaped like a nest."
	icon = 'icons/Xeno/Effects.dmi'
	icon_state = "nest"
	hit_sound = "alien_resin_break"
	buckling_y = 6
	buildstacktype = null //can't be disassembled and doesn't drop anything when destroyed
	resistance_flags = UNACIDABLE|XENO_DAMAGEABLE
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


/obj/structure/bed/nest/attack_alien(mob/living/carbon/xenomorph/X)
	if(X.a_intent != INTENT_HARM)
		return attack_hand(X)
	return ..()


/obj/structure/bed/nest/user_buckle_mob(mob/living/buckling_mob, mob/user, check_loc = TRUE, silent)
	if(user.incapacitated() || !in_range(user, src) || buckling_mob.buckled)
		return FALSE
	if(!isxeno(user))
		to_chat(user, "<span class='warning'>Gross! You're not touching that stuff.</span>")
		return FALSE
	if(LAZYLEN(buckled_mobs))
		to_chat(user, "<span class='warning'>There's already someone in [src].</span>")
		return FALSE
	if(ishuman(buckling_mob))
		var/mob/living/carbon/human/H = buckling_mob
		if(COOLDOWN_CHECK(H, COOLDOWN_NEST))
			to_chat(user, "<span class='warning'>[H] was recently unbuckled. Wait a bit.</span>")
			return FALSE
		if(!H.lying_angle)
			to_chat(user, "<span class='warning'>[H] is resisting, ground [H.p_them()].</span>")
			return FALSE

	user.visible_message("<span class='warning'>[user] pins [buckling_mob] into [src], preparing the securing resin.</span>",
	"<span class='warning'>[user] pins [buckling_mob] into [src], preparing the securing resin.</span>")
	
	if(!do_mob(user, buckling_mob, 1.5 SECONDS, BUSY_ICON_HOSTILE))
		return FALSE
	if(QDELETED(src))
		return FALSE
	if(LAZYLEN(buckled_mobs))
		to_chat(user, "<span class='warning'>There's already someone in [src].</span>")
		return FALSE
	if(ishuman(buckling_mob) && !buckling_mob.lying_angle) //Improperly stunned Marines won't be nested
		to_chat(user, "<span class='warning'>[buckling_mob] is resisting, ground [buckling_mob.p_them()].</span>")
		return FALSE

	buckling_mob.visible_message("<span class='xenonotice'>[user] secretes a thick, vile resin, securing [buckling_mob] into [src]!</span>",
		"<span class='xenonotice'>[user] drenches you in a foul-smelling resin, trapping you in [src]!</span>",
		"<span class='notice'>You hear squelching.</span>")
	playsound(loc, "alien_resin_move", 50)

	silent = TRUE
	return ..()


/obj/structure/bed/nest/user_unbuckle_mob(mob/living/buckled_mob, mob/user, silent)
	if(buckled_mob != user)
		if(user.incapacitated())
			return FALSE
		buckled_mob.visible_message("<span class='notice'>\The [user] pulls \the [buckled_mob] free from \the [src]!</span>",
			"<span class='notice'>\The [user] pulls you free from \the [src].</span>",
			"<span class='notice'>You hear squelching.</span>")
		playsound(loc, "alien_resin_move", 50)
		COOLDOWN_START(user, COOLDOWN_NEST, NEST_UNBUCKLED_COOLDOWN)
		silent = TRUE
		return ..()

	if(buckled_mob.incapacitated(TRUE))
		to_chat(buckled_mob, "<span class='warning'>You're currently unable to try that.</span>")
		return FALSE
	if(!resisting_time)
		resisting_time = world.time
		buckled_mob.visible_message("<span class='warning'>\The [buckled_mob] struggles to break free of \the [src].</span>",
			"<span class='warning'>You struggle to break free from \the [src].</span>",
			"<span class='notice'>You hear squelching.</span>")
		addtimer(CALLBACK(src, .proc/unbuckle_time_message, user), NEST_RESIST_TIME)
		return FALSE
	if(resisting_time + NEST_RESIST_TIME > world.time)
		to_chat(buckled_mob, "<span class='warning'>You're already trying to free yourself. Give it some time.</span>")
		return FALSE
	buckled_mob.visible_message("<span class='danger'>\The [buckled_mob] breaks free from \the [src]!</span>",
		"<span class='danger'>You pull yourself free from \the [src]!</span>",
		"<span class='notice'>You hear squelching.</span>")
	silent = TRUE
	return ..()


/obj/structure/bed/nest/proc/unbuckle_time_message(mob/living/user)
	if(QDELETED(user) || !(user in buckled_mobs))
		return //Time has passed, conditions may have changed.
	if(resisting_time + NEST_RESIST_TIME > world.time)
		return //We've been freed and re-nested.
	to_chat(user, "<span class='danger'>You are ready to break free! Resist once more to free yourself!</span>")


/obj/structure/bed/nest/post_buckle_mob(mob/living/buckling_mob)
	. = ..()
	ENABLE_BITFIELD(buckling_mob.restrained_flags, RESTRAINED_XENO_NEST)
	buckling_mob.pulledby?.stop_pulling()

/obj/structure/bed/nest/post_unbuckle_mob(mob/living/buckled_mob)
	. = ..()
	resisting_time = 0 //Reset it to keep track on if someone is actively resisting.
	if(QDELETED(buckled_mob))
		return
	DISABLE_BITFIELD(buckled_mob.restrained_flags, RESTRAINED_XENO_NEST)


/obj/structure/bed/nest/update_icon()
	overlays.Cut()
	if(on_fire)
		overlays += "alien_fire"
	if(LAZYLEN(buckled_mobs))
		overlays += image("icon_state" = "nest_overlay", "layer" = LYING_MOB_LAYER + 0.1)


/obj/structure/bed/nest/flamer_fire_act()
	take_damage(50, BURN, "fire")

/obj/structure/bed/nest/fire_act()
	take_damage(50, BURN, "fire")

/obj/structure/bed/nest/attack_alien(mob/living/carbon/xenomorph/M)
	SEND_SIGNAL(M, COMSIG_XENOMORPH_ATTACK_NEST)
	return ..()


#undef NEST_RESIST_TIME
#undef NEST_UNBUCKLED_COOLDOWN
