


/////////////////////////////////////////////
//// SMOKE SYSTEMS
// direct can be optinally added when set_up, to make the smoke always travel in one direction
// in case you wanted a vent to always smoke north for example
/////////////////////////////////////////////


/obj/effect/particle_effect/smoke
	name = "smoke"
	icon_state = "smoke"
	opacity = 1
	anchored = 0.0
	mouse_opacity = 0
	var/amount = 6.0
	var/time_to_live = 100
	var/datum/effect_system/smoke_spread/linked_system
	anchored = 1

	//Remove this bit to use the old smoke
	icon = 'icons/effects/96x96.dmi'
	pixel_x = -32
	pixel_y = -32

/obj/effect/particle_effect/smoke/New(loc, datum/effect_system/smoke_spread/owner)
	..()
	if(owner)
		linked_system = owner
		linked_system.total_smoke++
		time_to_live = time_to_live*0.75+rand(10,30)
	spawn (time_to_live)
		cdel(src)


/obj/effect/particle_effect/smoke/Dispose()
	. =..()
	if(linked_system)
		linked_system.total_smoke--
		linked_system = null


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

/obj/effect/particle_effect/smoke/proc/affect(var/mob/living/carbon/M)
	if (istype(M))
		return 0
	return 1

/////////////////////////////////////////////
// Bad smoke
/////////////////////////////////////////////

/obj/effect/particle_effect/smoke/bad
	time_to_live = 200

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
// Phosporus Gas
/////////////////////////////////////////////

/obj/effect/particle_effect/smoke/phosphorus
	time_to_live = 200

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
	time_to_live = 10
	opacity = 0
	icon_state = "sparks"




/////////////////////////////////////////////
// Smoke spread
/////////////////////////////////////////////

/datum/effect_system/smoke_spread
	var/total_smoke = 0 // To stop it being spammed and lagging!
	var/direction
	var/smoke_type = /obj/effect/particle_effect/smoke

/datum/effect_system/smoke_spread/set_up(n = 5, c = 0, loca, direct)
	if(n > 10)
		n = 10
	number = n
	cardinals = c
	if(istype(loca, /turf/))
		location = loca
	else
		location = get_turf(loca)
	if(direct)
		direction = direct

/datum/effect_system/smoke_spread/start()
	var/i = 0
	for(i=0, i<src.number, i++)
		if(src.total_smoke > 20)
			return
		spawn(0)
			if(holder)
				src.location = get_turf(holder)
			var/obj/effect/particle_effect/smoke/smoke = new smoke_type(location, src)
			var/direction = src.direction
			if(!direction)
				if(cardinals)
					direction = pick(cardinal)
				else
					direction = pick(alldirs)
			for(i=0, i<pick(0,1,1,1,2,2,2,3), i++)
				sleep(10)
				if(smoke && smoke.loc)
					step(smoke,direction)


/datum/effect_system/smoke_spread/bad
	smoke_type = /obj/effect/particle_effect/smoke/bad

/datum/effect_system/smoke_spread/sleepy
	smoke_type = /obj/effect/particle_effect/smoke/sleepy


/datum/effect_system/smoke_spread/mustard
	smoke_type = /obj/effect/particle_effect/smoke/mustard

/datum/effect_system/smoke_spread/phosphorus
	smoke_type = /obj/effect/particle_effect/smoke/phosphorus
