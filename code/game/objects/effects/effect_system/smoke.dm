


/////////////////////////////////////////////
//// SMOKE SYSTEMS
// direct can be optinally added when set_up, to make the smoke always travel in one direction
// in case you wanted a vent to always smoke north for example
/////////////////////////////////////////////


/obj/effect/particle_effect/smoke
	name = "smoke"
	icon_state = "smoke"
	opacity = 1
	anchored = 1
	mouse_opacity = 0
	var/amount = 2
	var/spread_speed = 1 //time in decisecond for a smoke to spread one tile.
	var/time_to_live = 4


	//Remove this bit to use the old smoke
	icon = 'icons/effects/96x96.dmi'
	pixel_x = -32
	pixel_y = -32

/obj/effect/particle_effect/smoke/New(loc, oldamount)
	..()
	if(oldamount)
		amount = oldamount - 1
	apply_smoke_effect(loc)
	time_to_live += rand(-1,1)
	processing_objects.Add(src)


/obj/effect/particle_effect/smoke/Dispose()
	. =..()
	processing_objects.Remove(src)

/obj/effect/particle_effect/smoke/process()
	time_to_live--
	if(time_to_live <= 0)
		opacity = 0
		if(isturf(loc))
			var/turf/T = loc
			T.UpdateAffectingLights()
		cdel(src)
	else if(time_to_live == 1)
		alpha = 180
		amount = 0
		opacity = 0


/obj/effect/particle_effect/smoke/CanPass(atom/movable/mover, turf/target, height = 0, air_group = 0)
	if(air_group || (height == 0)) return 1
	if(istype(mover, /obj/item/projectile/beam))
		var/obj/item/projectile/beam/B = mover
		B.damage = (B.damage/2)
	return 1

/obj/effect/particle_effect/smoke/Crossed(mob/living/carbon/M as mob )
	..()
	if(istype(M))
		affect(M)

/obj/effect/particle_effect/smoke/proc/apply_smoke_effect(turf/T)
	for(var/mob/living/L in T)
		affect(L)

/obj/effect/particle_effect/smoke/proc/spread_smoke(direction)
	set waitfor = 0
	sleep(spread_speed)
	if(disposed) return
	var/turf/U = get_turf(src)
	if(!U) return
	for(var/i in cardinal)
		if(direction && i != direction)
			continue
		var/turf/T = get_step(U, i)
		if(T.c_airblock(U)) //smoke can't spread that way
			continue
		var/obj/effect/particle_effect/smoke/foundsmoke = locate() in T //Don't spread smoke where there's already smoke!
		if(foundsmoke)
			continue
		var/obj/effect/particle_effect/smoke/S = new type(T, amount)
		S.dir = pick(cardinal)
		S.time_to_live = time_to_live
		if(S.amount>0)
			S.spread_smoke()

/obj/effect/particle_effect/smoke/proc/affect(var/mob/living/carbon/M)
	if (istype(M))
		return 0
	return 1

/////////////////////////////////////////////
// Bad smoke
/////////////////////////////////////////////

/obj/effect/particle_effect/smoke/bad
	time_to_live = 5

/obj/effect/particle_effect/smoke/bad/Move()
	..()
	for(var/mob/living/carbon/M in get_turf(src))
		affect(M)

/obj/effect/particle_effect/smoke/bad/affect(var/mob/living/carbon/M)
	..()
	if (M.internal != null && M.wear_mask && (M.wear_mask.flags_inventory & ALLOWINTERNALS))
		return
	else
		if (prob(20))
			M.drop_held_item()
		M.adjustOxyLoss(1)
		if (M.coughedtime != 1)
			M.coughedtime = 1
			M.emote("cough")
			spawn ( 20 )
				M.coughedtime = 0


/////////////////////////////////////////////
// Sleep smoke
/////////////////////////////////////////////

/obj/effect/particle_effect/smoke/sleepy

/obj/effect/particle_effect/smoke/sleepy/Move()
	..()
	for(var/mob/living/carbon/M in get_turf(src))
		affect(M)

/obj/effect/particle_effect/smoke/sleepy/affect(mob/living/carbon/M as mob )
	if (!..())
		return 0

	M.drop_held_item()
	M:sleeping += 1
	if (M.coughedtime != 1)
		M.coughedtime = 1
		M.emote("cough")
		spawn ( 20 )
			M.coughedtime = 0
/////////////////////////////////////////////
// Mustard Gas
/////////////////////////////////////////////


/obj/effect/particle_effect/smoke/mustard
	name = "mustard gas"
	icon_state = "mustard"

/obj/effect/particle_effect/smoke/mustard/Move()
	..()
	for(var/mob/living/carbon/human/R in get_turf(src))
		affect(R)

/obj/effect/particle_effect/smoke/mustard/affect(var/mob/living/carbon/human/R)
	..()
	R.burn_skin(0.75)
	if (R.coughedtime != 1)
		R.coughedtime = 1
		R.emote("gasp")
		spawn (20)
			R.coughedtime = 0
	R.updatehealth()
	return

/////////////////////////////////////////////
// Phosphorus Gas
/////////////////////////////////////////////

/obj/effect/particle_effect/smoke/phosphorus
	time_to_live = 5

/obj/effect/particle_effect/smoke/phosphorus/Move()
	..()
	for(var/mob/living/carbon/M in get_turf(src))
		affect(M)

/obj/effect/particle_effect/smoke/phosphorus/affect(var/mob/living/carbon/M)
	..()
	if (M.internal != null && M.wear_mask && (M.wear_mask.flags_inventory & ALLOWINTERNALS))
		return
	else
		if (prob(20))
			M.drop_held_item()
		M.adjustOxyLoss(1)
		M.updatehealth()
		if (M.coughedtime != 1)
			M.coughedtime = 1
			M.emote("cough")
			spawn (20)
				M.coughedtime = 0
	//if (M.wear_suit != null && !istype(M.wear_suit, /obj/item/clothing/suit/storage/labcoat) && !istype(M.wear_suit, /obj/item/clothing/suit/straight_jacket) && !istype(M.wear_suit, /obj/item/clothing/suit/straight_jacket && !istype(M.wear_suit, /obj/item/clothing/suit/armor)))
		//return
	M.burn_skin(0.75)
	M.updatehealth()



//////////////////////////////////////
// FLASHBANG SMOKE
////////////////////////////////////

/obj/effect/particle_effect/smoke/flashbang
	name = "illumination"
	time_to_live = 2
	opacity = 0
	icon_state = "sparks"



/////////////////////////////////////////
// BOILER SMOKES
/////////////////////////////////////////


//Xeno acid smoke.
/obj/effect/particle_effect/smoke/xeno_burn
	time_to_live = 6
	color = "#86B028" //Mostly green?
	anchored = 1
	spread_speed = 10

/obj/effect/particle_effect/smoke/xeno_burn/apply_smoke_effect(turf/T)
	for(var/mob/living/L in T)
		if(istype(L.buckled, /obj/structure/bed/nest) && L.status_flags & XENO_HOST)
			continue //nested infected hosts are not hurt by acid smoke
		affect(L)
	for(var/obj/structure/barricade/B in T)
		B.acid_smoke_damage(src)

/obj/effect/particle_effect/smoke/xeno_burn/affect(var/mob/living/carbon/M)
	..()
	if(isXeno(M))
		return
	if(isYautja(M) && prob(75))
		return

	if(M.internal != null && M.wear_mask && (M.wear_mask.flags_inventory & ALLOWINTERNALS) && prob(40))
		M << "<span class='danger'>Your gas mask protects you!</span>"
	else
		if(prob(20))
			M.drop_held_item()
		M.adjustOxyLoss(5)
		M.adjustFireLoss(rand(5,15))
		M.updatehealth()
		if(M.coughedtime != 1 && !M.stat)
			M.coughedtime = 1
			if(prob(50))
				M.emote("cough")
			else
				M.emote("gasp")
			spawn(15)
				M.coughedtime = 0
	M << "<span class='danger'>Your skin feels like it is melting away!</span>"
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.take_overall_damage(0, (amount+1)*rand(10, 15)) //Burn damage, randomizes between various parts //Magic number
	else
		M.burn_skin(5)
	M.updatehealth()
	return


//Xeno neurotox smoke.
/obj/effect/particle_effect/smoke/xeno_weak
	time_to_live = 6
	color = "#ffbf58" //Mustard orange?
	spread_speed = 10

/obj/effect/particle_effect/smoke/xeno_weak/affect(var/mob/living/carbon/M)
	..()
	if(isXeno(M))
		return
	if(isYautja(M) && prob(75))
		return

	if(M.stat)
		return

	if(M.internal != null && M.wear_mask && (M.wear_mask.flags_inventory & ALLOWINTERNALS) && prob(75))
		M << "<span class='danger'>Your gas mask protects you!</span>"
		return
	else
		if(M.coughedtime != 1)
			M.coughedtime = 1
			M.emote("gasp")
			M.adjustOxyLoss(1)
			spawn(15)
				M.coughedtime = 0
		var/effect_amt = 8 + amount*2
		//M.KnockDown(effect_amt)
		//M.Stun(effect_amt+2)
		if(!M.eye_blind)
			M << "<span class='danger'>Your eyes sting. You can't see!</span>"
		M.eye_blurry = max(M.eye_blurry, effect_amt*2)
		M.eye_blind = max(M.eye_blind, round(effect_amt))














/////////////////////////////////////////////
// Smoke spread
/////////////////////////////////////////////

/datum/effect_system/smoke_spread
	var/amount = 3
	var/smoke_type = /obj/effect/particle_effect/smoke
	var/direction
	var/lifetime

/datum/effect_system/smoke_spread/set_up(radius = 2, c = 0, loca, direct, smoke_time)
	if(isturf(loca))
		location = loca
	else
		location = get_turf(loca)
	if(direct)
		direction = direct
	if(lifetime)
		lifetime = smoke_time
	radius = min(radius, 10)
	amount = radius

/datum/effect_system/smoke_spread/start()
	if(holder)
		location = get_turf(holder)
	var/obj/effect/particle_effect/smoke/S = new smoke_type(location, amount+1)
	if(lifetime)
		S.time_to_live = lifetime
	if(S.amount)
		S.spread_smoke(direction)


/datum/effect_system/smoke_spread/bad
	smoke_type = /obj/effect/particle_effect/smoke/bad

/datum/effect_system/smoke_spread/sleepy
	smoke_type = /obj/effect/particle_effect/smoke/sleepy


/datum/effect_system/smoke_spread/mustard
	smoke_type = /obj/effect/particle_effect/smoke/mustard

/datum/effect_system/smoke_spread/phosphorus
	smoke_type = /obj/effect/particle_effect/smoke/phosphorus


/datum/effect_system/smoke_spread/xeno_acid
	smoke_type = /obj/effect/particle_effect/smoke/xeno_burn

/datum/effect_system/smoke_spread/xeno_weaken
	smoke_type = /obj/effect/particle_effect/smoke/xeno_weak
