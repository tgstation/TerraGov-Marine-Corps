//separate dm since hydro is getting bloated already

/obj/structure/glowshroom
	name = "kneestingers"
	desc = ""
	anchored = TRUE
	opacity = 0
	density = FALSE
	icon = 'icons/roguetown/misc/foliage.dmi'
	icon_state = "glowshroom1" //replaced in New
	layer = ABOVE_NORMAL_TURF_LAYER
	max_integrity = 30
	blade_dulling = DULLING_CUT
	resistance_flags = FLAMMABLE
	var/delay = 1200
	var/floor = 0
	var/generation = 1
	var/spreadIntoAdjacentChance = 60
	var/obj/item/seeds/myseed = /obj/item/seeds/glowshroom
	var/static/list/blacklisted_glowshroom_turfs = typecacheof(list(
	/turf/open/lava,
	/turf/open/floor/plating/beach/water))

/obj/structure/glowshroom/fire_act(added, maxstacks)
	visible_message("<span class='warning'>[src] catches fire!</span>")
	var/turf/T = get_turf(src)
	qdel(src)
	new /obj/effect/hotspot(T)

/obj/structure/glowshroom/CanPass(atom/movable/mover, turf/target)
	if(isliving(mover) && mover.z == z)
//		var/throwdir = get_dir(src, mover)
		var/mob/living/L = mover
		if(L.electrocute_act(30, src))
			L.consider_ambush()
			if(L.throwing)
				L.throwing.finalize(FALSE)
//			if(mover.loc != loc && L.stat == CONSCIOUS)
//				L.throw_at(get_step(L, throwdir), 1, 1, L, spin = FALSE)
			return FALSE
	. = ..()

/obj/structure/glowshroom/Crossed(AM as mob|obj)
	if(isliving(AM))
		var/mob/living/L = AM
		if(L.z == z)
			if(L.electrocute_act(30, src))
				L.emote("painscream")
				L.consider_ambush()
	. = ..()

/obj/structure/glowshroom/attackby(obj/item/W, mob/user, params)
	if(isliving(user) && W && user.z == z)
		if(W.flags_1 & CONDUCT_1)
			var/mob/living/L = user
			if(L.electrocute_act(30, src))
				L.emote("painscream")
				L.consider_ambush()
				if(L.throwing)
					L.throwing.finalize(FALSE)
				return FALSE
	..()

/obj/structure/glowshroom/glowcap
	name = "glowcap"
	desc = ""
	icon_state = "glowcap"
	myseed = /obj/item/seeds/glowshroom/glowcap

/obj/structure/glowshroom/shadowshroom
	name = "shadowshroom"
	desc = ""
	icon_state = "shadowshroom"
	myseed = /obj/item/seeds/glowshroom/shadowshroom

/obj/structure/glowshroom/single/Spread()
	return

/obj/structure/glowshroom/examine(mob/user)
	. = ..()
//	. += "This is a [generation]\th generation [name]!"

/obj/structure/glowshroom/Destroy()
	if(myseed)
		QDEL_NULL(myseed)
	return ..()

/obj/structure/glowshroom/New(loc, obj/item/seeds/newseed, mutate_stats)
	..()
	if(newseed)
		myseed = newseed.Copy()
		myseed.forceMove(src)
	else
		myseed = new myseed(src)
	if(mutate_stats) //baby mushrooms have different stats :3
		myseed.adjust_potency(rand(-3,6))
		myseed.adjust_yield(rand(-1,2))
		myseed.adjust_production(rand(-3,6))
		myseed.adjust_endurance(rand(-3,6))
	delay = delay - myseed.production * 100 //So the delay goes DOWN with better stats instead of up. :I
	obj_integrity = myseed.endurance
	max_integrity = myseed.endurance
	var/datum/plant_gene/trait/glow/G = myseed.get_gene(/datum/plant_gene/trait/glow)
	if(ispath(G)) // Seeds were ported to initialize so their genes are still typepaths here, luckily their initializer is smart enough to handle us doing this
		myseed.genes -= G
		G = new G
		myseed.genes += G
	set_light(G.glow_range(myseed), G.glow_power(myseed), G.glow_color)
//	setDir(CalcDir())

	icon_state = "glowshroom[rand(1,3)]"

	pixel_x = rand(-4, 4)
	pixel_y = rand(0,5)

/*
	var/base_icon_state = initial(icon_state)
	if(!floor)
		switch(dir) //offset to make it be on the wall rather than on the floor
			if(NORTH)
				pixel_y = 32
			if(SOUTH)
				pixel_y = -32
			if(EAST)
				pixel_x = 32
			if(WEST)
				pixel_x = -32
		icon_state = "[base_icon_state][rand(1,3)]"
	else //if on the floor, glowshroom on-floor sprite
		icon_state = base_icon_state
*/
//	addtimer(CALLBACK(src, .proc/Spread), delay)

/obj/structure/glowshroom/proc/Spread()
	var/turf/ownturf = get_turf(src)
	var/shrooms_planted = 0
	for(var/i in 1 to myseed.yield)
		if(prob(1/(generation * generation) * 100))//This formula gives you diminishing returns based on generation. 100% with 1st gen, decreasing to 25%, 11%, 6, 4, 2...
			var/list/possibleLocs = list()
			var/spreadsIntoAdjacent = FALSE

			if(prob(spreadIntoAdjacentChance))
				spreadsIntoAdjacent = TRUE

			for(var/turf/open/floor/earth in view(3,src))
				if(is_type_in_typecache(earth, blacklisted_glowshroom_turfs))
					continue
				if(!ownturf.CanAtmosPass(earth))
					continue
				if(spreadsIntoAdjacent || !locate(/obj/structure/glowshroom) in view(1,earth))
					possibleLocs += earth
				CHECK_TICK

			if(!possibleLocs.len)
				break

			var/turf/newLoc = pick(possibleLocs)

			var/shroomCount = 0 //hacky
			var/placeCount = 1
			for(var/obj/structure/glowshroom/shroom in newLoc)
				shroomCount++
			for(var/wallDir in GLOB.cardinals)
				var/turf/isWall = get_step(newLoc,wallDir)
				if(isWall.density)
					placeCount++
			if(shroomCount >= placeCount)
				continue

			var/obj/structure/glowshroom/child = new type(newLoc, myseed, TRUE)
			child.generation = generation + 1
			shrooms_planted++

			CHECK_TICK
		else
			shrooms_planted++ //if we failed due to generation, don't try to plant one later
	if(shrooms_planted < myseed.yield) //if we didn't get all possible shrooms planted, try again later
		myseed.yield -= shrooms_planted
		addtimer(CALLBACK(src, .proc/Spread), delay)

/obj/structure/glowshroom/proc/CalcDir(turf/location = loc)
	var/direction = 16

	for(var/wallDir in GLOB.cardinals)
		var/turf/newTurf = get_step(location,wallDir)
		if(newTurf.density)
			direction |= wallDir

	for(var/obj/structure/glowshroom/shroom in location)
		if(shroom == src)
			continue
		if(shroom.floor) //special
			direction &= ~16
		else
			direction &= ~shroom.dir

	var/list/dirList = list()

	for(var/i=1,i<=16,i <<= 1)
		if(direction & i)
			dirList += i

	if(dirList.len)
		var/newDir = pick(dirList)
		if(newDir == 16)
			floor = 1
			newDir = 1
		return newDir

	floor = 1
	return 1

/obj/structure/glowshroom/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	if(damage_type == BURN && damage_amount)
		playsound(src.loc, 'sound/blank.ogg', 100, TRUE)

/obj/structure/glowshroom/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		take_damage(5, BURN, 0, 0)

/obj/structure/glowshroom/acid_act(acidpwr, acid_volume)
	. = 1
	visible_message("<span class='danger'>[src] melts away!</span>")
	var/obj/effect/decal/cleanable/molten_object/I = new (get_turf(src))
	I.desc = ""
	qdel(src)
