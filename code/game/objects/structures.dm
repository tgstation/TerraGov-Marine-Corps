/obj/structure
	icon = 'icons/obj/structures/structures.dmi'
	var/climbable = FALSE
	var/climb_delay = 50
	var/flags_barrier = 0
	var/broken = FALSE //similar to machinery's stat BROKEN
	obj_flags = CAN_BE_HIT
	anchored = TRUE
	destroy_sound = 'sound/effects/meteorimpact.ogg'

/obj/structure/proc/handle_barrier_chance(mob/living/M)
	return FALSE


/obj/structure/ex_act(severity)
	if(CHECK_BITFIELD(resistance_flags, INDESTRUCTIBLE))
		return
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if(prob(50))
				qdel(src)
				return
		if(3.0)
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

/obj/structure/MouseDrop_T(mob/target, mob/user)
	. = ..()
	var/mob/living/H = user
	if(!istype(H) || target != user) //No making other people climb onto tables.
		return

	do_climb(target)

/obj/structure/proc/can_climb(mob/living/user)
	if(!climbable || !can_touch(user))
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
			to_chat(user, "<span class='warning'>There's \a [O.name] in the way.</span>")
			return FALSE

	for(var/obj/O in U.contents)
		if(istype(O, /obj/structure))
			var/obj/structure/S = O
			if(S.climbable)
				continue
		//dense border obstacles on our tile
		if(O.density && (O.flags_atom & ON_BORDER) && O.dir & get_dir(user, src))
			to_chat(user, "<span class='warning'>There's \a [O.name] in the way.</span>")
			return FALSE

	if((flags_atom & ON_BORDER))
		if(user.loc != loc && user.loc != get_step(T, dir))
			to_chat(user, "<span class='warning'>You need to be up against [src] to leap over.</span>")
			return
		if(user.loc == loc)
			var/turf/target = get_step(T, dir)
			if(target.density) //Turf is dense, not gonna work
				to_chat(user, "<span class='warning'>You cannot leap this way.</span>")
				return
			for(var/atom/movable/A in target)
				if(A && A.density && !(A.flags_atom & ON_BORDER))
					if(istype(A, /obj/structure))
						var/obj/structure/S = A
						if(!S.climbable) //Transfer onto climbable surface
							to_chat(user, "<span class='warning'>You cannot leap this way.</span>")
							return
					else
						to_chat(user, "<span class='warning'>You cannot leap this way.</span>")
						return
	return TRUE

/obj/structure/proc/do_climb(mob/living/user)
	if(!can_climb(user))
		return

	user.visible_message("<span class='warning'>[user] starts [flags_atom & ON_BORDER ? "leaping over":"climbing onto"] \the [src]!</span>")

	if(!do_after(user, climb_delay, FALSE, src, BUSY_ICON_GENERIC, extra_checks = CALLBACK(src, .proc/can_climb, user)))
		return

	if(!(flags_atom & ON_BORDER)) //If not a border structure or we are not on its tile, assume default behavior
		user.forceMove(get_turf(src))

		if(get_turf(user) == get_turf(src))
			user.visible_message("<span class='warning'>[user] climbs onto \the [src]!</span>")
	else //If border structure, assume complex behavior
		var/turf/target = get_step(get_turf(src), dir)
		if(user.loc == target)
			user.forceMove(get_turf(src))
			user.visible_message("<span class='warning'>[user] leaps over \the [src]!</span>")
		else
			if(target.density) //Turf is dense, not gonna work
				to_chat(user, "<span class='warning'>You cannot leap this way.</span>")
				return
			for(var/atom/movable/A in target)
				if(A && A.density && !(A.flags_atom & ON_BORDER))
					if(istype(A, /obj/structure))
						var/obj/structure/S = A
						if(!S.climbable) //Transfer onto climbable surface
							to_chat(user, "<span class='warning'>You cannot leap this way.</span>")
							return
					else
						to_chat(user, "<span class='warning'>You cannot leap this way.</span>")
						return
			user.forceMove(get_turf(target)) //One more move, we "leap" over the border structure

			if(get_turf(user) == get_turf(target))
				user.visible_message("<span class='warning'>[user] leaps over \the [src]!</span>")

/obj/structure/proc/structure_shaken()

	for(var/mob/living/M in get_turf(src))

		if(M.lying)
			return //No spamming this on people.

		M.knock_down(5)
		to_chat(M, "<span class='warning'>You topple as \the [src] moves under you!</span>")

		if(prob(25))

			var/damage = rand(15,30)
			var/mob/living/carbon/human/H = M
			if(!istype(H))
				to_chat(H, "<span class='danger'>You land heavily!</span>")
				M.apply_damage(damage, BRUTE)
				return

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
				to_chat(M, "<span class='danger'>You land heavily on your [affecting.display_name]!</span>")
				affecting.take_damage_limb(damage)
			else
				to_chat(H, "<span class='danger'>You land heavily!</span>")
				H.apply_damage(damage, BRUTE)

			H.UpdateDamageIcon()
			H.updatehealth()
	return

/obj/structure/proc/can_touch(mob/user)
	if(!user)
		return FALSE
	if(!Adjacent(user) || !isturf(user.loc))
		return FALSE
	if(user.restrained() || user.buckled)
		to_chat(user, "<span class='notice'>You need your hands and legs free for this.</span>")
		return FALSE
	if(user.incapacitated(TRUE) || user.lying)
		return FALSE
	if(issilicon(user))
		to_chat(user, "<span class='notice'>You need hands for this.</span>")
		return FALSE
	return TRUE
