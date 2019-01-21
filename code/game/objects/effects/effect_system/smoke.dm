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
	var/amount = 3
	var/spread_speed = 1 //time in decisecond for a smoke to spread one tile.
	var/lifetime = 5
	var/opaque = TRUE //whether the smoke can block the view when in enough amount
	var/obj/chemholder // for chemical smokes.

	//Remove this bit to use the old smoke
	icon = 'icons/effects/96x96.dmi'
	pixel_x = -32
	pixel_y = -32

/obj/effect/particle_effect/smoke/New(loc)
	. = ..()
	lifetime += rand(-1,1)
	START_PROCESSING(SSobj, src)

/obj/effect/particle_effect/smoke/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/particle_effect/smoke/proc/kill_smoke()
	STOP_PROCESSING(SSobj, src)
	INVOKE_ASYNC(src, .proc/fade_out)
	QDEL_NULL(chemholder)
	QDEL_IN(src, 10)

/obj/effect/particle_effect/smoke/proc/fade_out(frames = 16)
	if(alpha == 0) //Handle already transparent case
		return
	if(frames == 0)
		frames = 1 //We will just assume that by 0 frames, the coder meant "during one frame".
	var/step = alpha / frames
	for(var/i in 1 to frames)
		alpha -= step
		if(alpha < 160)
			SetOpacity(0) //if we were blocking view, we aren't now because we're fading out
		stoplag()

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


/obj/effect/particle_effect/smoke/proc/spread_smoke()
	var/turf/t_loc = get_turf(src)
	if(!t_loc)
		return
	var/list/newsmokes = list()
	for(var/turf/T in cardinal)
		if(check_airblock(T)) //smoke can't spread that way
			continue
		apply_smoke_effect(T)
		var/obj/effect/particle_effect/smoke/S = new type(T)
		S.chemholder = chemholder
		S.dir = pick(cardinal)
		S.amount = amount-1
		S.lifetime = lifetime
		if(S.amount > 0)
			if(opaque)
				S.SetOpacity(TRUE)
			newsmokes.Add(S)

	if(newsmokes.len)
		spawn(1) //the smoke spreads rapidly but not instantly
			for(var/obj/effect/particle_effect/smoke/SM in newsmokes)
				SM.spread_smoke()

//proc to check if smoke can expand to another turf
/obj/effect/particle_effect/smoke/proc/check_airblock(turf/T)
	if(T.density)
		return TRUE
	var/obj/effect/particle_effect/smoke/foundsmoke = locate() in T //Don't spread smoke where there's already smoke!
	if(foundsmoke)
		return TRUE
	for(var/atom/movable/M in T)
		if(!M.CanPass(src, T))
			return TRUE
	return FALSE

/obj/effect/particle_effect/smoke/proc/smoke_mob(mob/living/carbon/C)
	if(!istype(C) || lifetime < 1)
		return
	if(C.smoke_delay)
		return
	C.smoke_delay = TRUE
	addtimer(CALLBACK(src, .proc/remove_smoke_delay, C), 10)
	effect_contact(C)
	if(!C.internal || !C.has_smoke_protection())
		effect_inhale(C)

/obj/effect/particle_effect/smoke/proc/remove_smoke_delay(mob/living/carbon/C)
	C?.smoke_delay = FALSE

/obj/effect/particle_effect/smoke/proc/effect_inhale(mob/living/carbon/C)
	return

/obj/effect/particle_effect/smoke/proc/effect_contact(mob/living/carbon/C)
	return

/////////////////////////////////////////////
// Smoke spread
/////////////////////////////////////////////

/datum/effect_system/smoke_spread
	var/range = 3
	var/smoke_type = /obj/effect/particle_effect/smoke
	var/lifetime

/datum/effect_system/smoke_spread/set_up(radius = 2, loca, smoke_time)
	if(isturf(loca))
		location = loca
	else
		location = get_turf(loca)
	range = radius
	if(smoke_time)
		lifetime = smoke_time

/datum/effect_system/smoke_spread/start()
	if(holder)
		location = get_turf(holder)
	var/obj/effect/particle_effect/smoke/S = new smoke_type(location)
	if(lifetime)
		S.lifetime = lifetime
	S.amount = range
	if(S.amount)
		S.spread_smoke()

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
	addtimer(CALLBACK(src, .proc/remove_smoke_delay, C), 10)
	effect_contact(C)
	if(!C.internal && !C.has_smoke_protection())
		effect_inhale(C)
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
// Smoke spreads
/////////////////////////////////////////////

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

/datum/effect_system/smoke_spread/xeno/start()
	if(holder)
		location = get_turf(holder)
	var/obj/effect/particle_effect/smoke/xeno/S = new smoke_type(location)
	S.strength = strength
	if(lifetime)
		S.lifetime = lifetime
	if(S.amount)
		S.spread_smoke()

/datum/effect_system/smoke_spread/xeno/acid
	smoke_type = /obj/effect/particle_effect/smoke/xeno/burn

/datum/effect_system/smoke_spread/xeno/neuro
	smoke_type = /obj/effect/particle_effect/smoke/xeno/neuro

/////////////////////////////////////////////
// Chem smoke
/////////////////////////////////////////////
/obj/effect/particle_effect/smoke/chem
	lifetime = 10
	var/fraction

/obj/effect/particle_effect/smoke/chem/New()
	. = ..()
	fraction = INVERSE(lifetime)

/obj/effect/particle_effect/smoke/chem/apply_smoke_effect(turf/T)
	if(chemholder?.reagents)
		chemholder.reagents.reaction(T, TOUCH, fraction * chemholder.reagents.total_volume)
	return ..()

/obj/effect/particle_effect/smoke/chem/effect_contact(mob/living/carbon/C)
	if(chemholder?.reagents)
		chemholder.reagents.reaction(C, TOUCH, fraction * chemholder.reagents.total_volume)

/obj/effect/particle_effect/smoke/chem/effect_inhale(mob/living/carbon/C)
	if(chemholder?.reagents)
		chemholder.reagents.reaction(C, INGEST, fraction * chemholder.reagents.total_volume)
		chemholder.reagents.trans_to(C, fraction * chemholder.reagents.total_volume)

/datum/effect_system/smoke_spread/chem
	var/obj/chemholder
	smoke_type = /obj/effect/particle_effect/smoke/chem

/datum/effect_system/smoke_spread/chem/New()
	. = ..()
	chemholder = new /obj()
	chemholder.create_reagents(500)

/datum/effect_system/smoke_spread/chem/set_up(datum/reagents/carry = null, radius = 1, loca, smoke_time, silent = FALSE)
	. = ..()

	carry.copy_to(chemholder, carry.total_volume)

	if(!silent)
		var/contained = ""
		for(var/reagent in carry.reagent_list)
			contained += " [reagent] "
		if(contained)
			contained = "\[[contained]\]"
		var/area/A = get_area(location)

		var/where = "[A.name]|[location.x], [location.y]"
		var/whereLink = "<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[location.x];Y=[location.y];Z=[location.z]'>[where]</a>"

		if(carry.my_atom.fingerprintslast)
			var/mob/M = get_mob_by_key(carry.my_atom.fingerprintslast)
			var/more = ""
			if(M)
				more = "(<A HREF='?_src_=holder;adminmoreinfo=\ref[M]'>?</a>)"
			message_admins("A chemical smoke reaction has taken place in ([whereLink])[contained]. Last associated key is [carry.my_atom.fingerprintslast][more].", 0, 1)
			log_game("A chemical smoke reaction has taken place in ([where])[contained]. Last associated key is [carry.my_atom.fingerprintslast].")
		else
			message_admins("A chemical smoke reaction has taken place in ([whereLink]). No associated key.", 0, 1)
			log_game("A chemical smoke reaction has taken place in ([where])[contained]. No associated key.")


/datum/effect_system/smoke_spread/chem/start()
	if(holder)
		location = get_turf(holder)
	var/obj/effect/particle_effect/smoke/chem/S = new smoke_type(location)

	if(chemholder.reagents.total_volume > 1) // can't split 1 very well
		S.chemholder = chemholder

	var/color = mix_color_from_reagents(chemholder.reagents.reagent_list)
	if(color)
		S.icon = icon('icons/effects/chemsmoke.dmi')
		S.icon += color

	if(lifetime)
		S.lifetime = lifetime
	S.amount = range
	if(S.amount)
		S.spread_smoke()
