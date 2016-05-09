/mob/living/carbon/human/movement_delay()

	if(turret_control)
		src << "\blue You stop controlling the turret."
		turret_control.visible_message("\icon[src] \blue [turret_control] buzzes: Manual control halted. AI control re-initiated.")
		turret_control.gunner = null
		turret_control.manual_override = 0
		turret_control = null

	var/tally = 0

	if(species.slowdown)
		tally = species.slowdown

	if (istype(loc, /turf/space)) return -1 // It's hard to be slowed down in space by... anything

	if(embedded_flag)
		handle_embedded_objects() //Moving with objects stuck in you can cause bad times.

	if(reagents.has_reagent("hyperzine"))
		tally -= 1.5

	if(reagents.has_reagent("nuka_cola")) return -1

	var/health_deficiency = (100 - health)
	if(health_deficiency >= 40) tally += round(health_deficiency / 25)

	if (!(species && (species.flags & NO_PAIN)))
		if(halloss >= 10) tally += round(halloss / 15) //halloss shouldn't slow you down if you can't even feel it

	var/hungry = (500 - nutrition)/5 // So overeat would be 100 and default level would be 80
	if (hungry >= 70) tally += hungry/50

	if(wear_suit)
		tally += wear_suit.slowdown

	if(isturf(src.loc))
		if(locate(/obj/effect/alien/resin/sticky) in src.loc) //Sticky resin slows you down
			tally += 8

		if(locate(/obj/effect/alien/weeds) in src.loc) //Weeds slow you down
			tally += 1

		if(istype(src.loc,/turf/unsimulated/floor/snow)) //Snow slows you down
			var/turf/unsimulated/floor/snow/S = src.loc
			if(S && istype(S) && S.slayer > 0)
				tally += 1.25 * S.slayer
				if(S.slayer && prob(2))
					src << "\red Moving through [S] slows you down."
				if(S.slayer == 3 && prob(2))
					src << "\red You got stuck in [S] for a moment!"
					tally += 12

		if(istype(src.loc,/turf/unsimulated/floor/gm/river)) //Ditto walking through a river
			tally += 1.75
			var/turf/unsimulated/floor/gm/river/T = src.loc
			T.cleanup(src)
			if(gloves && rand(0,100) < 60)
				if(istype(src.gloves,/obj/item/clothing/gloves/yautja))
					var/obj/item/clothing/gloves/yautja/Y = src.gloves
					if(Y && istype(Y) && Y.cloaked)
						src << "\red Your bracers hiss and spark as they short out!"
						Y.decloak(src)

	if(istype(buckled, /obj/structure/stool/bed/chair/wheelchair))
		for(var/organ_name in list("l_hand","r_hand","l_arm","r_arm"))
			var/datum/organ/external/E = get_organ(organ_name)
			if(!E || (E.status & ORGAN_DESTROYED))
				tally += 4
			if(E.status & ORGAN_SPLINTED)
				tally += 0.5
			else if(E.status & ORGAN_BROKEN)
				tally += 1.5
	else
		if(shoes)
			tally += shoes.slowdown

		for(var/organ_name in list("l_foot","r_foot","l_leg","r_leg"))
			var/datum/organ/external/E = get_organ(organ_name)
			if(!E || (E.status & ORGAN_DESTROYED))
				tally += 4
			if(E.status & ORGAN_SPLINTED)
				tally += 0.5
			else if(E.status & ORGAN_BROKEN)
				tally += 1.5

	if(shock_stage >= 10 && !isYautja(src)) tally += 3

	if(FAT in src.mutations)
		tally += 1.5
	if (bodytemperature < 283.222 && !isYautja(src))
		tally += (283.222 - bodytemperature) / 10 * 1.75

	if(mRun in mutations)
		tally = 0

	return (tally+config.human_delay)

/mob/living/carbon/human/Process_Spacemove(var/check_drift = 0)
	//Can we act
	if(restrained())	return 0

	//Do we have a working jetpack
	if(istype(back, /obj/item/weapon/tank/jetpack))
		var/obj/item/weapon/tank/jetpack/J = back
		if(((!check_drift) || (check_drift && J.stabilization_on)) && (!lying) && (J.allow_thrust(0.01, src)))
			inertia_dir = 0
			return 1
//		if(!check_drift && J.allow_thrust(0.01, src))
//			return 1

	//If no working jetpack then use the other checks
	if(..())	return 1
	return 0


/mob/living/carbon/human/Process_Spaceslipping(var/prob_slip = 5)
	//If knocked out we might just hit it and stop.  This makes it possible to get dead bodies and such.

	if(species.flags & NO_SLIP)
		return

	if(stat)
		prob_slip = 0 // Changing this to zero to make it line up with the comment, and also, make more sense.

	//Do we have magboots or such on if so no slip
	if(istype(shoes, /obj/item/clothing/shoes/magboots) && (shoes.flags & NOSLIP))
		prob_slip = 0

	//Check hands and mod slip
	if(!l_hand)	prob_slip -= 2
	else if(l_hand.w_class <= 2)	prob_slip -= 1
	if (!r_hand)	prob_slip -= 2
	else if(r_hand.w_class <= 2)	prob_slip -= 1

	prob_slip = round(prob_slip)
	return(prob_slip)
