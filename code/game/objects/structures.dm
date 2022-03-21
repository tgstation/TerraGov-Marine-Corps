/obj/structure
	icon = 'icons/obj/structures/structures.dmi'
	var/climbable = FALSE
	var/climb_delay = 50
	var/flags_barrier = 0
	var/broken = FALSE //similar to machinery's stat BROKEN
	obj_flags = CAN_BE_HIT
	anchored = TRUE
	throwpass = TRUE
	destroy_sound = 'sound/effects/meteorimpact.ogg'

/obj/structure/proc/handle_barrier_chance(mob/living/M)
	return FALSE


/obj/structure/ex_act(severity)
	if(CHECK_BITFIELD(resistance_flags, INDESTRUCTIBLE))
		return
	switch(severity)
		if(EXPLODE_DEVASTATE)
			qdel(src)
			return
		if(EXPLODE_HEAVY)
			if(prob(50))
				qdel(src)
				return
		if(EXPLODE_LIGHT)
			return

/obj/structure/Initialize()
	. = ..()
	if(climbable)
		verbs += /obj/structure/proc/climb_on

/obj/structure/proc/climb_on()

	set name = "Climb structure"
	set desc = "Climbs onto a structure."
	set category = "Object"
	set src in oview(1)

	do_climb(usr)

/obj/structure/specialclick(mob/living/carbon/user)
	. = ..()
	do_climb(user)

/obj/structure/MouseDrop_T(mob/target, mob/user)
	. = ..()
	var/mob/living/H = user
	if(!istype(H) || target != user) //No making other people climb onto tables.
		return

	do_climb(target)

/obj/structure/proc/can_climb(mob/living/user)
	if(!climbable || !can_interact(user))
		return FALSE

	var/turf/T = src.loc
	var/turf/U = get_turf(user)
	if(!istype(T) || !istype(U))
		return FALSE
	if(T.density)
		return FALSE //src is on top of a dense turf.
	if(!user.Adjacent(src))
		return FALSE //this catches border objects that don't let you throw things over them, but not barricades

	for(var/obj/O in T.contents)
		if(istype(O, /obj/structure))
			var/obj/structure/S = O
			if(S.climbable)
				continue

		//dense obstacles (border or not) on the structure's tile
		if(O.density && (!(O.flags_atom & ON_BORDER) || O.dir & get_dir(src,user)))
			to_chat(user, span_warning("There's \a [O.name] in the way."))
			return FALSE

	for(var/obj/O in U.contents)
		if(istype(O, /obj/structure))
			var/obj/structure/S = O
			if(S.climbable)
				continue
		//dense border obstacles on our tile
		if(O.density && (O.flags_atom & ON_BORDER) && O.dir & get_dir(user, src))
			to_chat(user, span_warning("There's \a [O.name] in the way."))
			return FALSE

	if((flags_atom & ON_BORDER))
		if(user.loc != loc && user.loc != get_step(T, dir))
			to_chat(user, span_warning("You need to be up against [src] to leap over."))
			return
		if(user.loc == loc)
			var/turf/target = get_step(T, dir)
			if(target.density) //Turf is dense, not gonna work
				to_chat(user, span_warning("You cannot leap this way."))
				return
			for(var/atom/movable/A in target)
				if(A && A.density && !(A.flags_atom & ON_BORDER))
					if(istype(A, /obj/structure))
						var/obj/structure/S = A
						if(!S.climbable) //Transfer onto climbable surface
							to_chat(user, span_warning("You cannot leap this way."))
							return
					else
						to_chat(user, span_warning("You cannot leap this way."))
						return
	return TRUE

/obj/structure/proc/do_climb(mob/living/user)
	if(!can_climb(user))
		return

	user.visible_message(span_warning("[user] starts [flags_atom & ON_BORDER ? "leaping over":"climbing onto"] \the [src]!"))

	if(!do_after(user, climb_delay, FALSE, src, BUSY_ICON_GENERIC, extra_checks = CALLBACK(src, .proc/can_climb, user)))
		return

	for(var/m in user.buckled_mobs)
		user.unbuckle_mob(m)

	if(!(flags_atom & ON_BORDER)) //If not a border structure or we are not on its tile, assume default behavior
		user.forceMove(get_turf(src))

		if(get_turf(user) == get_turf(src))
			user.visible_message(span_warning("[user] climbs onto \the [src]!"))
	else //If border structure, assume complex behavior
		var/turf/target = get_step(get_turf(src), dir)
		if(user.loc == target)
			user.forceMove(get_turf(src))
			user.visible_message(span_warning("[user] leaps over \the [src]!"))
		else
			if(target.density) //Turf is dense, not gonna work
				to_chat(user, span_warning("You cannot leap this way."))
				return
			for(var/atom/movable/A in target)
				if(A && A.density && !(A.flags_atom & ON_BORDER))
					if(istype(A, /obj/structure))
						var/obj/structure/S = A
						if(!S.climbable) //Transfer onto climbable surface
							to_chat(user, span_warning("You cannot leap this way."))
							return
					else
						to_chat(user, span_warning("You cannot leap this way."))
						return
			user.forceMove(get_turf(target)) //One more move, we "leap" over the border structure

			if(get_turf(user) == get_turf(target))
				user.visible_message(span_warning("[user] leaps over \the [src]!"))

/obj/structure/proc/structure_shaken()

	for(var/mob/living/M in get_turf(src))

		if(M.lying_angle)
			return //No spamming this on people.

		M.Paralyze(10 SECONDS)
		to_chat(M, span_warning("You topple as \the [src] moves under you!"))

		if(prob(25))

			var/damage = rand(15,30)
			if(!ishuman(M))
				to_chat(M, span_danger("You land heavily!"))
				M.apply_damage(damage, BRUTE)
				UPDATEHEALTH(M)
				return

			var/mob/living/carbon/human/H = M
			var/datum/limb/affecting

			switch(pick(list("ankle","wrist","head","knee","elbow")))
				if("ankle")
					affecting = H.get_limb(pick("l_foot", "r_foot"))
				if("knee")
					affecting = H.get_limb(pick("l_leg", "r_leg"))
				if("wrist")
					affecting = H.get_limb(pick("l_hand", "r_hand"))
				if("elbow")
					affecting = H.get_limb(pick("l_arm", "r_arm"))
				if("head")
					affecting = H.get_limb("head")

			if(affecting)
				to_chat(M, span_danger("You land heavily on your [affecting.display_name]!"))
				affecting.take_damage_limb(damage)
			else
				to_chat(H, span_danger("You land heavily!"))
				H.apply_damage(damage, BRUTE)

			UPDATEHEALTH(H)
			H.UpdateDamageIcon()


/obj/structure/can_interact(mob/user)
	. = ..()
	if(!.)
		return FALSE

	if(!user.CanReach(src))
		return FALSE

	return TRUE


/obj/structure/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return

	if(!can_interact(user))
		return

	return interact(user)
