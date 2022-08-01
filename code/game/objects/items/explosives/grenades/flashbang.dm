/obj/item/explosive/grenade/flashbang
	name = "flashbang"
	desc = "A grenade sometimes used by police, civilian or military, to stun targets with a flash, then a bang. May cause hearing loss, and induce feelings of overwhelming rage in victims."
	icon_state = "flashbang2"
	item_state = "flashbang"
	arm_sound = 'sound/weapons/armbombpin.ogg'
	///This is a cluster weapon, or part of one
	var/banglet = FALSE
	///The range where the maximum effects are applied
	var/inner_range = 2
	///The range where the moderate effects are applied
	var/outer_range = 5
	///Whether this grenade requires skill to use
	var/mp_only = TRUE

/obj/item/explosive/grenade/flashbang/attack_self(mob/user)
	if(mp_only && (user.skills.getRating("police") < SKILL_POLICE_MP))
		to_chat(user, span_warning("You don't seem to know how to use [src]..."))
		return
	..()


/obj/item/explosive/grenade/flashbang/prime()
	var/turf/T = get_turf(src)
	for(var/obj/structure/closet/L in get_hear(7, T))
		if(locate(/mob/living/carbon/, L))
			for(var/mob/living/carbon/M in L)
				bang(get_turf(src), M)


	for(var/mob/living/carbon/M in get_hear(7, T))
		if(!HAS_TRAIT(M, TRAIT_FLASHBANGIMMUNE))
			bang(T, M)

	new/atom/movable/effect/particle_effect/smoke/flashbang(T)
	qdel(src)

/// Added a new proc called 'bang' that takes a location and a person to be banged.
/obj/item/explosive/grenade/flashbang/proc/bang(turf/T , mob/living/carbon/M)
	to_chat(M, span_danger("BANG"))
	playsound(src.loc, 'sound/effects/bang.ogg', 50, 1)

//Checking for protections
	var/ear_safety = 0
	if(iscarbon(M))
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(istype(H.wear_ear, /obj/item/clothing/ears/earmuffs))
				ear_safety += 2
			if(istype(H.head, /obj/item/clothing/head/helmet/riot))
				ear_safety += 2

	if(get_dist(M, T) <= inner_range) //do we need these loc checks?
		inner_effect(T,M,ear_safety)
	else if(get_dist(M, T) <= outer_range)
		outer_effect(T,M,ear_safety)
	else
		max_range_effect(T,M,ear_safety)

	base_effect(T,M,ear_safety) //done afterwards as it contains the eye/ear damage checks

///The effects applied to all mobs in range
/obj/item/explosive/grenade/flashbang/proc/base_effect(turf/T , mob/living/carbon/M, ear_safety)
	if(M.flash_act())
		M.Stun(40)
		M.Paralyze(20 SECONDS)

	if(M.ear_damage >= 15)
		to_chat(M, span_warning("Your ears start to ring badly!"))
		if(!banglet)
			if (prob(M.ear_damage - 10 + 5))
				to_chat(M, span_warning("You can't hear anything!"))
				M.disabilities |= DEAF
	else
		if(M.ear_damage >= 5)
			to_chat(M, span_warning("Your ears start to ring!"))

///The effects applied to mobs in the inner_range
/obj/item/explosive/grenade/flashbang/proc/inner_effect(turf/T , mob/living/carbon/M, ear_safety)
	if(ear_safety > 0)
		M.Stun(40)
		M.Paralyze(20)
	else
		M.Stun(20 SECONDS)
		M.Paralyze(60)
		if((prob(14) || (M == src.loc && prob(70))))
			M.adjust_ear_damage(rand(1, 10),15)
		else
			M.adjust_ear_damage(rand(0, 5),10)

///The effects applied to mobs in the outer_range
/obj/item/explosive/grenade/flashbang/proc/outer_effect(turf/T , mob/living/carbon/M, ear_safety)
	if(!ear_safety)
		M.Stun(16 SECONDS)
		M.adjust_ear_damage(rand(0, 3),8)

///The effects applied to mobs outside of outer_range
/obj/item/explosive/grenade/flashbang/proc/max_range_effect(turf/T , mob/living/carbon/M, ear_safety)
	if(!ear_safety)
		M.Stun(80)
		M.adjust_ear_damage(rand(0, 1),6)


/obj/item/explosive/grenade/flashbang/clusterbang//Created by Polymorph, fixed by Sieve
	desc = "Use of this weapon may constiute a war crime in your area, consult your local captain."
	name = "clusterbang"
	icon_state = "clusterbang"

/obj/item/explosive/grenade/flashbang/clusterbang/prime()
	var/clusters = rand(4,8)
	var/segments = 0
	var/randomness = clusters
	while(randomness-- > 0)
		if(prob(35))
			segments++
			clusters--

	while(clusters-- > 0)
		new /obj/item/explosive/grenade/flashbang/cluster(loc)//Launches flashbangs

	while(segments-- > 0)
		new /obj/item/explosive/grenade/flashbang/clusterbang/segment(loc)//Creates a 'segment' that launches a few more flashbangs

	qdel(src)

/obj/item/explosive/grenade/flashbang/clusterbang/segment
	desc = "A smaller segment of a clusterbang. Better run."
	name = "clusterbang segment"
	icon_state = "clusterbang_segment"

/obj/item/explosive/grenade/flashbang/clusterbang/segment/Initialize() //Segments should never exist except part of the clusterbang, since these immediately 'do their thing' and asplode
	. = ..()
	playsound(loc, 'sound/weapons/armbomb.ogg', 25, TRUE, 6)
	icon_state = "clusterbang_segment_active"
	active = TRUE
	banglet = TRUE
	var/stepdist = rand(1,4)//How far to step
	var/temploc = loc//Saves the current location to know where to step away from
	walk_away(src,temploc,stepdist)//I must go, my people need me
	addtimer(CALLBACK(src, .proc/prime), rand(1.5,6) SECONDS)

/obj/item/explosive/grenade/flashbang/clusterbang/segment/prime()
	var/clusters = rand(4,8)
	var/randomness = clusters
	while(randomness-- > 0)
		if(prob(35))
			clusters--

	while(clusters-- > 0)
		new /obj/item/explosive/grenade/flashbang/cluster(loc)

	qdel(src)

/obj/item/explosive/grenade/flashbang/cluster/Initialize()//Same concept as the segments, so that all of the parts don't become reliant on the clusterbang
	. = ..()
	playsound(loc, 'sound/weapons/armbomb.ogg', 25, TRUE, 6)
	icon_state = "flashbang_active"
	active = TRUE
	banglet = TRUE
	var/stepdist = rand(1,3)
	var/temploc = loc
	walk_away(src,temploc,stepdist)
	addtimer(CALLBACK(src, .proc/prime), rand(1.5,6) SECONDS)


//Slows and staggers instead of hardstunning, balanced for HvH
/obj/item/explosive/grenade/flashbang/stun
	name = "\improper stun grenade"
	desc = "A grenade designed to disorientate the senses of anyone caught in the blast radius with a blinding flash of light and viciously loud noise. Repeated use can cause deafness."
	icon_state = "flashbang2"
	item_state = "flashbang"
	arm_sound = 'sound/weapons/armbombpin.ogg'
	inner_range = 3
	mp_only = FALSE

/obj/item/explosive/grenade/flashbang/stun/base_effect(turf/T , mob/living/carbon/M, ear_safety)
	if(M.ear_damage >= 15)
		to_chat(M, span_warning("Your ears start to ring badly!"))
		if(prob(M.ear_damage - 15)) //You have to eat a lot of stun grenades to risk permanently deafening you
			to_chat(M, span_warning("You can't hear anything!"))
			M.disabilities |= DEAF
	else
		if(M.ear_damage >= 5)
			to_chat(M, span_warning("Your ears start to ring!"))

/obj/item/explosive/grenade/flashbang/stun/inner_effect(turf/T , mob/living/carbon/M, ear_safety)
	if(M.flash_act(duration = 10))
		M.blur_eyes(7)

	if(ear_safety > 0)
		M.adjust_stagger(3)
		M.add_slowdown(3)
	else
		M.adjust_stagger(6)
		M.add_slowdown(6)
		if((prob(14) || (M == src.loc && prob(70))))
			M.adjust_ear_damage(rand(1, 10),15)
		else
			M.adjust_ear_damage(rand(0, 5),10)

/obj/item/explosive/grenade/flashbang/stun/outer_effect(turf/T , mob/living/carbon/M, ear_safety)
	if(M.flash_act(duration = 10))
		M.blur_eyes(6)

	if(!ear_safety)
		M.adjust_stagger(4)
		M.add_slowdown(4)
		M.adjust_ear_damage(rand(0, 3),8)

/obj/item/explosive/grenade/flashbang/stun/max_range_effect(turf/T , mob/living/carbon/M, ear_safety)
	if(M.flash_act(duration = 5))
		M.blur_eyes(4)

	if(!ear_safety)
		M.adjust_stagger(2)
		M.add_slowdown(2)
		M.adjust_ear_damage(rand(0, 1),6)
