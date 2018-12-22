/////////////////////////////////////////////
//// SMOKE SYSTEMS
// direct can be optinally added when set_up, to make the smoke always travel in one direction
// in case you wanted a vent to always smoke north for example
/////////////////////////////////////////////

/obj/effect/particle_effect/smoke
	name = "smoke"
	icon_state = "smoke"
	opacity = FALSE
	anchored = TRUE
	mouse_opacity = 0
	var/amount = 2
	var/spread_speed = 1 //time in decisecond for a smoke to spread one tile.
	var/lifetime = 5
	var/opaque = TRUE //whether the smoke can block the view when in enough amount


	//Remove this bit to use the old smoke
	icon = 'icons/effects/96x96.dmi'
	pixel_x = -32
	pixel_y = -32

/obj/effect/particle_effect/smoke/New(loc)
	. = ..()
	lifetime += rand(-1,1)
	create_reagents(500)
	START_PROCESSING(SSobj, src)

/obj/effect/particle_effect/smoke/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/particle_effect/smoke/proc/kill_smoke()
	STOP_PROCESSING(SSobj, src)
	fade_out()
	qdel(src)

/obj/effect/particle_effect/smoke/proc/fade_out(frames = 16)
	if(!alpha) //Handle already transparent case
		return
	if(frames <= 0)
		frames = 1 //We will just assume that by no frames, the coder meant "during one frame".
	var/step = alpha / frames
	for(var/i in 1 to frames)
		alpha -= step
		if(alpha < 160 && opaque)
			SetOpacity(0) //if we were blocking view, we aren't now because we're fading out
		sleep(world.tick_lag)
	return

/obj/effect/particle_effect/smoke/process()
	lifetime--
	if(lifetime < 1)
		kill_smoke()
		return FALSE
	apply_smoke_effect(get_turf(src))
	return TRUE

/obj/effect/particle_effect/smoke/proc/apply_smoke_effect(turf/T)
	for(var/mob/living/L in T)
		smoke_mob(L)

/*
/obj/effect/particle_effect/smoke/proc/spread_smoke(direction)
	var/turf/t_loc = get_turf(src)
	if(!t_loc)
		return
	var/list/newsmokes = list()
	for(var/turf/dir in cardinal)
		if(direction && i != direction)
			continue
		var/turf/T = get_step(t_loc, dir)
		if(check_airblock(T)) //smoke can't spread that way
			continue
		var/obj/effect/particle_effect/smoke/foundsmoke = locate() in T //Don't spread smoke where there's already smoke!
		if(foundsmoke)
			continue
		apply_smoke_effect(t_loc)
		var/obj/effect/particle_effect/smoke/S = new smoke_type(T)
		reagents.copy_to(S, reagents.total_volume)
		S.dir = pick(cardinal)
		S.amount = amount-1
		S.lifetime = lifetime
		if(S.amount>0)
			if(opaque)
				S.set_opacity(TRUE)
			newsmokes.Add(S)

	if(newsmokes.len)
		spawn(1) //the smoke spreads rapidly but not instantly
			for(var/obj/effect/particle_effect/smoke/SM in newsmokes)
				SM.spread_smoke()

//proc to check if smoke can expand to another turf
/obj/effect/particle_effect/smoke/proc/check_airblock(turf/T)
	if(T.density)
		return TRUE
	for(var/atom/movable/M in T)
		if(!M.CanPass(src, T))
			return TRUE
*/

/obj/effect/particle_effect/smoke/proc/smoke_mob(mob/living/carbon/C)
	if(!istype(C) || lifetime < 1)
		return FALSE
	if(!C.smoke_delay)
		return FALSE
	C.smoke_delay = TRUE
	spawn(10)
		if(C)
			C.smoke_delay = FALSE
	if(!C.internal || !C.has_smoke_protection())
		effect_inhale(C)
	effect_contact(C)
	return TRUE

/obj/effect/particle_effect/smoke/proc/effect_inhale(mob/living/carbon/C)
	return

/obj/effect/particle_effect/smoke/proc/effect_contact(mob/living/carbon/C)
	return

/////////////////////////////////////////////
// Bad smoke
/////////////////////////////////////////////

/obj/effect/particle_effect/smoke/bad
	lifetime = 8

/obj/effect/particle_effect/smoke/bad/effect_inhale(mob/living/carbon/C)
	if(prob(30))
		C.drop_held_item()
	C.adjustOxyLoss(1)
	C.emote("cough")

/obj/effect/particle_effect/smoke/bad/CanPass(atom/movable/mover, turf/target)
	if(istype(mover, /obj/item/projectile/beam))
		var/obj/item/projectile/beam/B = mover
		B.damage = (B.damage/2)
	return TRUE

/////////////////////////////////////////////
// Cloak Smoke
/////////////////////////////////////////////
/obj/effect/particle_effect/smoke/tactical
	alpha = 145
	opaque = FALSE

/obj/effect/particle_effect/smoke/tactical/Move()
	. = ..()
	apply_smoke_effect(get_turf(src))

/obj/effect/particle_effect/smoke/tactical/Destroy()
	apply_smoke_effect(get_turf(src))
	return ..()

/obj/effect/particle_effect/smoke/tactical/smoke_mob(mob/living/M)
	if(istype(M))
		if(lifetime)
			cloak_smoke_act(M)
		else
			M.smokecloak_off()

/obj/effect/particle_effect/smoke/tactical/Crossed(mob/living/M)
	. = ..()
	if(istype(M))
		smoke_mob(M)

/obj/effect/particle_effect/smoke/tactical/Uncrossed(mob/living/M)
	. = ..()
	if(istype(M))
		M.smokecloak_off()

/obj/effect/particle_effect/smoke/tactical/proc/cloak_smoke_act(mob/living/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/clothing/gloves/yautja/Y = H.gloves
		var/obj/item/storage/backpack/marine/satchel/scout_cloak/S = H.back
		if(istype(H.back, S))
			if(S.camo_active)
				return
		if(istype(H.gloves, Y))
			if(Y.cloaked)
				return
	M.smokecloak_on()

/////////////////////////////////////////////
// Sleep smoke
/////////////////////////////////////////////

/obj/effect/particle_effect/smoke/sleepy

/obj/effect/particle_effect/smoke/sleepy/effect_inhale(mob/living/carbon/C)
	C.Sleeping(1)
	C.adjustOxyLoss(1)
	if(prob(30))
		C.emote("cough")

/////////////////////////////////////////////
// Mustard Gas
/////////////////////////////////////////////

/obj/effect/particle_effect/smoke/mustard
	name = "mustard gas"
	icon_state = "mustard"

/obj/effect/particle_effect/smoke/mustard/effect_inhale(var/mob/living/carbon/human/C)
	C.emote("gasp")
	var/protection = min(C.get_permeability_protection(), 0.75)
	C.burn_skin(0.75 - protection)

/////////////////////////////////////////////
// Phosphorus Gas
/////////////////////////////////////////////

/obj/effect/particle_effect/smoke/bad/phosphorus

/obj/effect/particle_effect/smoke/bad/phosphorus/effect_contact(mob/living/carbon/C)
	var/protection = min(C.get_permeability_protection(), 0.75)
	C.burn_skin(0.75 - protection)

//////////////////////////////////////
// FLASHBANG SMOKE
////////////////////////////////////

/obj/effect/particle_effect/smoke/flashbang
	name = "illumination"
	lifetime = 2
	opacity = 0
	icon_state = "sparks"
	icon = 'icons/effects/effects.dmi'

/////////////////////////////////////////
// BOILER SMOKES
/////////////////////////////////////////

//Xeno acid smoke.
/obj/effect/particle_effect/smoke/xeno
	lifetime = 6
	spread_speed = 7
	var/strength = 1 // Effects scale with Boiler upgrades.

/obj/effect/particle_effect/smoke/xeno/smoke_mob(mob/living/carbon/C)
	if(lifetime < 1 || !istype(C))
		return FALSE
	if(C.stat == DEAD)
		return FALSE
	if(isXeno(C) || (isYautja(C) && prob(75)))
		return FALSE
	if(istype(C.buckled, /obj/structure/bed/nest) && C.status_flags & XENO_HOST)
		return FALSE
	if(C.smoke_delay)
		return FALSE
	C.smoke_delay = TRUE
	spawn(10)
		if(C)
			C.smoke_delay = FALSE
	if(!C.internal && !C.has_smoke_protection())
		effect_inhale(C)
	effect_contact(C)
	return TRUE

//Xeno acid smoke.
/obj/effect/particle_effect/smoke/xeno/burn
	color = "#86B028" //Mostly green?

/obj/effect/particle_effect/smoke/xeno/burn/effect_inhale(mob/living/carbon/C)
	C.adjustOxyLoss(5)
	C.adjustFireLoss(strength*rand(10, 15))
	if(!C.stat)
		if(prob(50))
			C.emote("cough")
		else
			C.emote("gasp")

/obj/effect/particle_effect/smoke/xeno/burn/apply_smoke_effect(turf/T)
	for(var/mob/living/carbon/C in get_turf(src))
		smoke_mob(C)
	for(var/obj/structure/barricade/B in get_turf(src))
		B.acid_smoke_damage(src)
	for(var/obj/structure/razorwire/R in get_turf(src))
		R.acid_smoke_damage(src)
	for(var/obj/vehicle/multitile/hitbox/cm_armored/H in get_turf(src))
		var/obj/vehicle/multitile/root/cm_armored/R = H.root
		if(!R)
			continue
		R.take_damage_type(30, "acid")


/obj/effect/particle_effect/smoke/xeno/burn/effect_contact(mob/living/carbon/C)
	var/protection = 1 - min(C.get_permeability_protection(), 0.75)
	if(prob(50) * protection)
		to_chat(C, "<span class='danger'>Your skin feels like it is melting away!</span>")
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		H.adjustFireLoss(strength*rand(15, 20)*protection) //Burn damage, randomizes between various parts //strength corresponds to upgrade level, 1 to 2.5
	else
		C.burn_skin(5* protection) //Failsafe for non-humans

//Xeno neurotox smoke.
/obj/effect/particle_effect/smoke/xeno/neuro
	color = "#ffbf58" //Mustard orange?

/obj/effect/particle_effect/smoke/xeno/neuro/effect_inhale(mob/living/carbon/C)
	if(!is_blind(C) && C.has_eyes())
		to_chat(C, "<span class='danger'>Your eyes sting. You can't see!</span>")
	C.blur_eyes(4)
	C.blind_eyes(2)
	if(prob(50))
		C.emote("cough")
	else
		C.emote("gasp")

/obj/effect/particle_effect/smoke/xeno/neuro/effect_contact(mob/living/carbon/C)
	var/reagent_amount = rand(4,10) + rand(4,10) //Gaussian. Target number 7.
	var/gas_protect = (C.internal || C.has_smoke_protection()) ? 0.5 : 1
	C.reagents.add_reagent("xeno_toxin", reagent_amount * gas_protect)
	//Topical damage (neurotoxin on exposed skin)
	var/protection = min(C.get_permeability_protection(), 0.75)
	if(prob(round(reagent_amount*5)*protection)) //Likely to momentarily freeze up/fall due to arms/hands seizing up
		if(prob(50))
			to_chat(C, "<span class='danger'>Your body is going numb, almost as if paralyzed!</span>")
		C.AdjustKnockeddown(0.5)

/////////////////////////////////////////////
// Smoke spread
/////////////////////////////////////////////

/datum/effect_system/smoke_spread
	var/range = 3
	var/smoke_type = /obj/effect/particle_effect/smoke
	var/lifetime
	var/list/targetTurfs = list()
/*
/datum/effect_system/smoke_spread/set_up(radius = 2, loca, smoke_time)
	if(isturf(loca))
		location = loca
	else
		location = get_turf(loca)
	amount = radius
	if(smoke_time)
		lifetime = smoke_time

/datum/effect_system/smoke_spread/start()
	if(holder)
		location = get_turf(holder)
	var/obj/effect/particle_effect/smoke/S = new smoke_type(location)
	if(lifetime)
		S.lifetime = lifetime
	if(S.amount)
		S.spread_smoke()
*/

/datum/effect_system/smoke_spread/bad
	smoke_type = /obj/effect/particle_effect/smoke/bad

datum/effect_system/smoke_spread/tactical
	smoke_type = /obj/effect/particle_effect/smoke/tactical

/datum/effect_system/smoke_spread/sleepy
	smoke_type = /obj/effect/particle_effect/smoke/sleepy

/datum/effect_system/smoke_spread/mustard
	smoke_type = /obj/effect/particle_effect/smoke/mustard

/datum/effect_system/smoke_spread/phosphorus
	smoke_type = /obj/effect/particle_effect/smoke/bad/phosphorus

/datum/effect_system/smoke_spread/xeno
	smoke_type = /obj/effect/particle_effect/smoke/xeno
	var/strength = 1 // see smoke_type

/datum/effect_system/smoke_spread/xeno/acid
	smoke_type = /obj/effect/particle_effect/smoke/xeno/burn

/datum/effect_system/smoke_spread/xeno/neuro
	smoke_type = /obj/effect/particle_effect/smoke/xeno/neuro


/datum/effect_system/smoke_spread/set_up(radius = 2, loca, smoke_time)
	if(isturf(loca))
		location = loca
	else
		location = get_turf(loca)
	range = radius
	var/pyt_range = radius * 0.3
	if(smoke_time)
		lifetime = smoke_time

	for(var/turf/T in range(radius, location))
		var/foundsmoke = locate(/obj/effect/particle_effect/smoke) in T //Don't spread smoke where there's already smoke!
		if(cheap_pythag(T.x - location.x, T.y - location.y) <= pyt_range && !foundsmoke)
			targetTurfs += T

	check_flow(location, targetTurfs)

/datum/effect_system/smoke_spread/proc/check_flow()

	var/list/pending = new()
	var/list/complete = new()

	pending += location

	while(pending.len)
		for(var/turf/current in pending)
			for(var/turf/T in cardinal)
				if(T in (pending || complete || !targetTurfs))
					continue
				if(check_airblock(T)) //smoke can't spread that way
					continue
				pending += T

			pending -= current
			complete += current

	targetTurfs = complete
	return

/datum/effect_system/smoke_spread/proc/check_airblock(turf/T)
	if(T.density)
		return TRUE
	for(var/atom/movable/M in T)
		if(!M.CanPass(smoke_type, T))
			return TRUE

/datum/effect_system/smoke_spread/start()

	//distance between each smoke cloud
	var/const/arcLength = 2.3559

	var/turf/t_loc = get_turf(src)
	var/list/smokelist = list()

	//calculate positions for smoke coverage - then spawn smoke
	var/offset = ISINTEGER(range) ? 0 : 45 //degrees
	var/points = round((range * 2 * PI) / arcLength)
	var/angle = round(TODEGREES(arcLength / range))

	for(var/j in 1 to points)
		var/a = (angle * j) + offset
		var/turf/target = get_turf_in_angle(a, t_loc, range)
		for(var/turf/T in getline(t_loc, target))
			if(T in (targetTurfs && !smokelist))
				smokelist.Add(T)

	if(smokelist.len)
		spawn(1) //the smoke spreads rapidly but not instantly
			for(var/turf/T in smokelist)
				spawn_smoke(T)

/datum/effect_system/smoke_spread/proc/spawn_smoke(turf/T)
	var/obj/effect/particle_effect/smoke/S = new smoke_type(location)
	if(lifetime)
		S.lifetime = lifetime
	S.spread_smoke(T)

/obj/effect/particle_effect/smoke/proc/spread_smoke(turf/T, icon/I)
	if(opaque)
		SetOpacity(TRUE)
	dir = pick(cardinal)
	pixel_x = -32 + rand(-8,8)
	pixel_y = -32 + rand(-8,8)
	walk_to(src, T)
	apply_smoke_effect(get_turf(src))

/datum/effect_system/smoke_spread/xeno/spawn_smoke(turf/T)
	var/obj/effect/particle_effect/smoke/xeno/S = new smoke_type(location)
	if(lifetime)
		S.lifetime = lifetime
	S.strength = strength
	S.spread_smoke(T)