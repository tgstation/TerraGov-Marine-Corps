/obj/item/explosive/grenade/flashbang
	name = "flashbang"
	icon_state = "flashbang2"
	item_state = "flashbang"
	arm_sound = 'sound/weapons/armbombpin.ogg'
	var/banglet = 0


/obj/item/explosive/grenade/flashbang/attack_self(mob/user)
	if(user.skills.getRating("police") < SKILL_POLICE_MP)
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



	new/obj/effect/particle_effect/smoke/flashbang(T)
	qdel(src)

/obj/item/explosive/grenade/flashbang/proc/bang(turf/T , mob/living/carbon/M)						// Added a new proc called 'bang' that takes a location and a person to be banged.
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

//Flashing everyone
	if(M.flash_act())
		M.Stun(40)
		M.Paralyze(20 SECONDS)



//Now applying sound
	if((get_dist(M, T) <= 2 || src.loc == M.loc || src.loc == M))
		if(ear_safety > 0)
			M.Stun(40)
			M.Paralyze(20)
		else
			M.Stun(20 SECONDS)
			M.Paralyze(60)
			if ((prob(14) || (M == src.loc && prob(70))))
				M.adjust_ear_damage(rand(1, 10))
			else
				M.adjust_ear_damage(rand(0, 5), 15)

	else if(get_dist(M, T) <= 5)
		if(!ear_safety)
			M.Stun(16 SECONDS)
			M.adjust_ear_damage(rand(0, 3), 10)

	else if(!ear_safety)
		M.Stun(80)
		M.adjust_ear_damage(rand(0, 1), 5)

//This really should be in mob not every check
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/datum/internal_organ/eyes/E = H.internal_organs_by_name["eyes"]
		if (E && E.damage >= E.min_bruised_damage)
			to_chat(M, span_warning("Your eyes start to burn badly!"))
			if(!banglet && !(istype(src , /obj/item/explosive/grenade/flashbang/clusterbang)))
				if (E.damage >= E.min_broken_damage)
					to_chat(M, span_warning("You can't see anything!"))
	if (M.ear_damage >= 15)
		to_chat(M, span_warning("Your ears start to ring badly!"))
		if(!banglet && !(istype(src , /obj/item/explosive/grenade/flashbang/clusterbang)))
			if (prob(M.ear_damage - 10 + 5))
				to_chat(M, span_warning("You can't hear anything!"))
				M.disabilities |= DEAF
	else
		if (M.ear_damage >= 5)
			to_chat(M, span_warning("Your ears start to ring!"))


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
