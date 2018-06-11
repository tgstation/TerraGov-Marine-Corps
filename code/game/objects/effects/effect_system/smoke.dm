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
	time_to_live += rand(-1,1)
	processing_objects.Add(src)

/obj/effect/particle_effect/smoke/Dispose()
	if(opacity)
		SetOpacity(0)
	processing_objects.Remove(src)
	. =..()


/obj/effect/particle_effect/smoke/process()
	time_to_live--
	if(time_to_live <= 0)
		cdel(src)
	else if(time_to_live == 1)
		alpha = 180
		amount = 0
		SetOpacity(0)


/obj/effect/particle_effect/smoke/Crossed(atom/movable/M)
	..()
	if(istype(M, /obj/item/projectile/beam))
		var/obj/item/projectile/beam/B = M
		B.damage = (B.damage/2)
	if(iscarbon(M))
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
		if(check_airblock(U,T)) //smoke can't spread that way
			continue
		var/obj/effect/particle_effect/smoke/foundsmoke = locate() in T //Don't spread smoke where there's already smoke!
		if(foundsmoke)
			continue
		var/obj/effect/particle_effect/smoke/S = new type(T, amount)
		S.dir = pick(cardinal)
		S.time_to_live = time_to_live
		if(S.amount>0)
			S.spread_smoke()


//proc to check if smoke can expand to another turf
/obj/effect/particle_effect/smoke/proc/check_airblock(turf/U, turf/T)
	if(T.density)
		return TRUE
	for(var/atom/movable/M in T)
		if(!M.CanPass(src, T))
			return TRUE


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
		if(prob(20))
			M.drop_held_item()
		M.adjustOxyLoss(1)
		if(M.coughedtime != 1)
			M.coughedtime = 1
			if(ishuman(M)) //Humans only to avoid issues
				M.emote("cough")
			spawn(20)
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
	if(M.coughedtime != 1)
		M.coughedtime = 1
		if(ishuman(M)) //Humans only to avoid issues
			M.emote("cough")
		spawn(20)
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
	if(R.coughedtime != 1)
		R.coughedtime = 1
		if(ishuman(R)) //Humans only to avoid issues
			R.emote("gasp")
		spawn(20)
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
		if(prob(20))
			M.drop_held_item()
		M.adjustOxyLoss(1)
		M.updatehealth()
		if(M.coughedtime != 1)
			M.coughedtime = 1
			if(ishuman(M)) //Humans only to avoid issues
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
	icon = 'icons/effects/effects.dmi'

/////////////////////////////////////////
// BOILER SMOKES
/////////////////////////////////////////

//Xeno acid smoke.
/obj/effect/particle_effect/smoke/xeno_burn
	time_to_live = 6
	color = "#86B028" //Mostly green?
	anchored = 1
	spread_speed = 7
	amount = 1 //Amount depends on Boiler upgrade!

/obj/effect/particle_effect/smoke/xeno_burn/apply_smoke_effect(turf/T)
	for(var/mob/living/L in T)
		affect(L)
	for(var/obj/structure/barricade/B in T)
		B.acid_smoke_damage(src)
	for(var/obj/vehicle/multitile/hitbox/cm_armored/H in T)
		var/obj/vehicle/multitile/root/cm_armored/R = H.root
		if(!R) continue
		R.take_damage_type(30, "acid")

//No effect when merely entering the smoke turf, for balance reasons
/obj/effect/particle_effect/smoke/xeno_burn/Crossed(mob/living/carbon/M as mob)
	return

/obj/effect/particle_effect/smoke/xeno_burn/affect(var/mob/living/carbon/M)
	..()
	if(isXeno(M))
		return
	if(isYautja(M) && prob(75))
		return
	if(M.stat == DEAD)
		return
	if(istype(M.buckled, /obj/structure/bed/nest) && M.status_flags & XENO_HOST)
		return

	//Gas masks protect from inhalation and face contact effects, even without internals. Breath masks don't for balance reasons
	if(!istype(M.wear_mask, /obj/item/clothing/mask/gas))
		M.adjustOxyLoss(5) //Basic oxyloss from "can't breathe"
		M.adjustFireLoss(amount*rand(10, 15)) //Inhalation damage
		if(M.coughedtime != 1 && !M.stat) //Coughing/gasping
			M.coughedtime = 1
			if(prob(50))
				M.emote("cough")
			else
				M.emote("gasp")
			spawn(15)
				M.coughedtime = 0

	//Topical damage (acid on exposed skin)
	M << "<span class='danger'>Your skin feels like it is melting away!</span>"
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.adjustFireLoss(amount*rand(15, 20)) //Burn damage, randomizes between various parts //Amount corresponds to upgrade level, 1 to 2.5
	else
		M.burn_skin(5) //Failsafe for non-humans
	M.updatehealth()

//Xeno neurotox smoke.
/obj/effect/particle_effect/smoke/xeno_weak
	time_to_live = 6
	color = "#ffbf58" //Mustard orange?
	spread_speed = 7
	amount = 1 //Amount depends on Boiler upgrade!

//No effect when merely entering the smoke turf, for balance reasons
/obj/effect/particle_effect/smoke/xeno_weak/Crossed(mob/living/carbon/M as mob)
	return

/obj/effect/particle_effect/smoke/xeno_weak/affect(var/mob/living/carbon/M)
	..()
	if(isXeno(M))
		return
	if(isYautja(M) && prob(75))
		return
	if(M.stat == DEAD)
		return
	if(istype(M.buckled, /obj/structure/bed/nest) && M.status_flags & XENO_HOST)
		return

	var/effect_amt = round(6 + amount*6)

	//Gas masks protect from inhalation and face contact effects, even without internals. Breath masks don't for balance reasons
	if(!istype(M.wear_mask, /obj/item/clothing/mask/gas))
		M.adjustOxyLoss(15) //Causes even more oxyloss damage due to neurotoxin locking up respiratory system
		M.ear_deaf = max(M.ear_deaf, round(effect_amt*1.5)) //Paralysis of hearing system, aka deafness
		if(!M.eye_blind) //Eye exposure damage
			M << "<span class='danger'>Your eyes sting. You can't see!</span>"
		M.eye_blurry = max(M.eye_blurry, effect_amt*2)
		M.eye_blind = max(M.eye_blind, round(effect_amt))
		if(M.coughedtime != 1 && !M.stat) //Coughing/gasping
			M.coughedtime = 1
			if(prob(50))
				M.emote("cough")
			else
				M.emote("gasp")
			spawn(15)
				M.coughedtime = 0

	//Topical damage (neurotoxin on exposed skin)
	M << "<span class='danger'>Your body is going numb, almost as if paralyzed!</span>"
	if(prob(40 + round(amount*15))) //Highly likely to drop items due to arms/hands seizing up
		M.drop_held_item()
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.temporary_slowdown = max(H.temporary_slowdown, round(effect_amt*1.5)) //One tick every two second



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









