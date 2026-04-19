/obj/structure
	icon = 'icons/obj/structures/structures.dmi'
	var/barrier_flags = NONE
	var/broken = FALSE //similar to machinery's stat BROKEN
	obj_flags = CAN_BE_HIT
	anchored = TRUE
	allow_pass_flags = PASSABLE
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
		if(EXPLODE_WEAK)
			return

/obj/structure/Initialize(mapload)
	. = ..()
	if(smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
		QUEUE_SMOOTH(src)
		QUEUE_SMOOTH_NEIGHBORS(src)
		icon_state = ""
		if(smoothing_flags & SMOOTH_CORNERS)
			icon_state = ""

/obj/structure/proc/structure_shaken()

	for(var/mob/living/M in get_turf(src))

		if(M.lying_angle)
			return //No spamming this on people.

		M.Paralyze(2 SECONDS)
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

/obj/structure/get_acid_delay()
	return 4 SECONDS

/// For when a mob comes flying through the window, smash it and damage the mob
/obj/structure/proc/smash_and_injure(mob/living/flying_mob, atom/oldloc, direction)
	flying_mob.balloon_alert_to_viewers("smashed through!")
	flying_mob.apply_damage(damage = rand(5, 15), damagetype = BRUTE)
	new /obj/effect/decal/cleanable/glass(get_step(flying_mob, flying_mob.dir))
	deconstruct(disassembled = FALSE)
