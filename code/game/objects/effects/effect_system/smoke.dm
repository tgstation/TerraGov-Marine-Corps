
/////////////////////////////////////////////
//// SMOKE SYSTEMS
/////////////////////////////////////////////

/obj/effect/particle_effect/smoke
	name = "smoke"
	icon_state = "smoke"
	opacity = TRUE
	anchored = TRUE
	mouse_opacity = 0
	var/amount = 3
	var/spread_speed = 1 //time in decisecond for a smoke to spread one tile.
	var/lifetime = 5
	var/expansion_speed = 1
	var/smoke_traits = NONE
	var/strength = 1 // Effects scale with the emitter's bomb_strength upgrades.
	var/bio_protection = 1 // how unefficient its effects are against protected target from 0 to 1.
	var/datum/effect_system/smoke_spread/cloud // for associated chemical smokes.
	var/fraction = 0.2

	//Remove this bit to use the old smoke
	icon = 'icons/effects/96x96.dmi'
	pixel_x = -32
	pixel_y = -32

/obj/effect/particle_effect/smoke/Initialize(mapload, range, smoketime, smokecloud)
	. = ..()
	if(smokecloud)
		cloud = smokecloud
		LAZYADD(cloud.smokes, src)
	if(smoketime)
		lifetime = smoketime
		fraction = INVERSE(smoketime)
	if(range)
		amount = range
		addtimer(CALLBACK(src, /obj/effect/particle_effect/smoke.proc/spread_smoke), expansion_speed)
	create_reagents(500)
	START_PROCESSING(SSobj, src)

/obj/effect/particle_effect/smoke/Destroy()
	if(lifetime && CHECK_BITFIELD(smoke_traits, SMOKE_CAMO))
		apply_smoke_effect(get_turf(src))
	if(CHECK_BITFIELD(smoke_traits, SMOKE_CHEM) && LAZYLEN(cloud?.smoked_mobs)) //so the whole cloud won't stop working somehow
		var/obj/effect/particle_effect/smoke/neighbor = pick(cloud.smokes - src)
		neighbor.chemical_effect()
	STOP_PROCESSING(SSobj, src)
	if(cloud)
		LAZYREMOVE(cloud.smokes, src)
		if(cloud.single_use && !LAZYLEN(cloud.smokes))
			qdel(cloud)
	return ..()

/obj/effect/particle_effect/smoke/proc/kill_smoke()
	if(CHECK_BITFIELD(smoke_traits, SMOKE_CAMO))
		apply_smoke_effect(get_turf(src))
	LAZYCLEARLIST(cloud?.smoked_mobs)
	STOP_PROCESSING(SSobj, src)
	INVOKE_ASYNC(src, .proc/fade_out)

/obj/effect/particle_effect/smoke/proc/fade_out(frames = 16)
	if(alpha == 0) //Handle already transparent case
		return
	if(frames == 0)
		frames = 1 //We will just assume that by 0 frames, the coder meant "during one frame".
	var/step = alpha / frames
	for(var/i in 1 to frames)
		alpha -= step
		if(alpha < 160)
			SetOpacity(FALSE) //if we were blocking view, we aren't now because we're fading out
		stoplag()
	qdel(src)

/obj/effect/particle_effect/smoke/process()
	lifetime--
	if(lifetime < 1)
		kill_smoke()
		return FALSE
	apply_smoke_effect(get_turf(src))
	return TRUE

/obj/effect/particle_effect/smoke/Crossed(atom/movable/O)
	. = ..()
	if(CHECK_BITFIELD(smoke_traits, SMOKE_CAMO) && isliving(O))
		O.effect_smoke(src)
	if(CHECK_BITFIELD(smoke_traits, SMOKE_NERF_BEAM) && istype(O, /obj/item/projectile))
		O.effect_smoke(src)

/obj/effect/particle_effect/smoke/Uncrossed(mob/living/M)
	. = ..()
	if(CHECK_BITFIELD(smoke_traits, SMOKE_CAMO) && istype(M))
		var/obj/effect/particle_effect/smoke/S = locate() in get_turf(M)
		if(!CHECK_BITFIELD(S?.smoke_traits, SMOKE_CAMO))
			M.smokecloak_off()

/obj/effect/particle_effect/smoke/proc/apply_smoke_effect(turf/T)
	T.effect_smoke(src)
	for(var/V in T)
		var/atom/A = V
		A.effect_smoke(src)

/obj/effect/particle_effect/smoke/proc/pre_chem_effect(mob/living/carbon/C)
	if(!cloud || !reagents)
		return
	if(!LAZYLEN(cloud.smoked_mobs))
		addtimer(CALLBACK(src, .proc/chemical_effect), 4)
	LAZYADD(cloud.smoked_mobs, C)

/obj/effect/particle_effect/smoke/proc/chemical_effect()
	if(!(cloud?.smoked_mobs))
		return
	for(var/mob/living/carbon/C in cloud.smoked_mobs)
		reagents.reaction(C, INGEST, fraction / LAZYLEN(cloud.smoked_mobs))
		reagents.copy_to(C, reagents.total_volume, fraction / LAZYLEN(cloud.smoked_mobs))
	LAZYCLEARLIST(cloud.smoked_mobs)

/obj/effect/particle_effect/smoke/proc/spread_smoke()
	var/turf/t_loc = get_turf(src)
	if(!t_loc)
		return
	var/list/newsmokes = list()
	for(var/a in get_adjacent_open_turfs(src))
		var/turf/T = a
		if(check_airblock(T)) //smoke can't spread that way
			continue
		apply_smoke_effect(T)
		var/obj/effect/particle_effect/smoke/S = new type(T, null, null, cloud)
		reagents.copy_to(S, reagents.total_volume)
		S.copy_stats(src)
		S.setDir(pick(cardinal))
		if(S.amount > 0)
			newsmokes.Add(S)
		else
			S.lifetime += rand(-1,1)
	lifetime += rand(-1,1)

	if(newsmokes.len)
		addtimer(CALLBACK(src, .proc/spawn_smoke, newsmokes), expansion_speed) //the smoke spreads rapidly but not instantly

/obj/effect/particle_effect/smoke/proc/copy_stats(obj/effect/particle_effect/smoke/parent)
	amount = parent.amount-1
	lifetime = parent.lifetime
	strength = parent.strength
	if(lifetime)
		fraction = INVERSE(lifetime)

/obj/effect/particle_effect/smoke/proc/spawn_smoke(list/newsmokes)
	for(var/obj/effect/particle_effect/smoke/SM in newsmokes)
		SM.spread_smoke()

//proc to check if smoke can expand to another turf
/obj/effect/particle_effect/smoke/proc/check_airblock(turf/T)
	var/obj/effect/particle_effect/smoke/foundsmoke = locate() in T //Don't spread smoke where there's already smoke!
	if(foundsmoke)
		return TRUE
	for(var/atom/movable/M in T)
		if(!M.CanPass(src, T))
			return TRUE
	return FALSE

/////////////////////////////////////////////
// Smoke spread
////
/////////////////////////////////////////////

/datum/effect_system/smoke_spread
	var/range = 3
	var/smoke_type = /obj/effect/particle_effect/smoke
	var/lifetime
	var/list/smokes
	var/list/smoked_mobs
	var/single_use = TRUE

//When adding a smoke_spread var which is possibly
//going to be used multiple times to an atom,
//be sure to set the only_once argument FALSE.
/datum/effect_system/smoke_spread/New(atom/atom, only_once = TRUE)
	. = ..()
	single_use = only_once

//it's good practice to delete bound variables datum upon deletion, but doing so while active may foul things up.
/datum/effect_system/smoke_spread/Destroy()
	if(LAZYLEN(smokes))
		single_use = TRUE
		return QDEL_HINT_LETMELIVE
	return ..()

/datum/effect_system/smoke_spread/set_up(radius = 2, loca, smoke_time)
	if(isturf(loca))
		location = loca
	else
		location = get_turf(loca)
	range = radius
	if(smoke_time)
		lifetime = smoke_time

/datum/effect_system/smoke_spread/start()
	if(QDELETED(location) && !QDELETED(holder))
		location = get_turf(holder)
	new smoke_type(location, range, lifetime, src)

/////////////////////////////////////////////
// Bad smoke
/////////////////////////////////////////////

/obj/effect/particle_effect/smoke/bad
	lifetime = 8
	smoke_traits = SMOKE_NERF_BEAM|SMOKE_FOUL|SMOKE_COUGH|SMOKE_OXYLOSS

/////////////////////////////////////////////
// Cloak Smoke
/////////////////////////////////////////////

/obj/effect/particle_effect/smoke/tactical
	alpha = 145
	opacity = FALSE
	smoke_traits = SMOKE_CAMO

/////////////////////////////////////////////
// Sleep smoke
/////////////////////////////////////////////

/obj/effect/particle_effect/smoke/sleepy
	smoke_traits = SMOKE_COUGH|SMOKE_SLEEP|SMOKE_OXYLOSS

/////////////////////////////////////////////
// Mustard Gas
/////////////////////////////////////////////

/obj/effect/particle_effect/smoke/mustard
	name = "mustard gas"
	icon_state = "mustard"
	smoke_traits = SMOKE_GASP|SMOKE_BLISTERING|SMOKE_OXYLOSS

/////////////////////////////////////////////
// Phosphorus Gas
/////////////////////////////////////////////

/obj/effect/particle_effect/smoke/bad/phosphorus
	smoke_traits = SMOKE_BLISTERING

//////////////////////////////////////
// FLASHBANG SMOKE
////////////////////////////////////

/obj/effect/particle_effect/smoke/flashbang
	name = "illumination"
	lifetime = 2
	opacity = FALSE
	icon_state = "sparks"
	icon = 'icons/effects/effects.dmi'

/////////////////////////////////////////
// BOILER SMOKES
/////////////////////////////////////////

//Xeno acid smoke.
/obj/effect/particle_effect/smoke/xeno
	lifetime = 6
	spread_speed = 7
	expansion_speed = 3
	smoke_traits = SMOKE_XENO

//Xeno acid smoke.
/obj/effect/particle_effect/smoke/xeno/burn
	lifetime = 9
	color = "#86B028" //Mostly green?
	smoke_traits = SMOKE_XENO|SMOKE_XENO_ACID|SMOKE_GASP|SMOKE_COUGH

//Xeno neurotox smoke.
/obj/effect/particle_effect/smoke/xeno/neuro
	color = "#ffbf58" //Mustard orange?
	smoke_traits = SMOKE_XENO|SMOKE_XENO_NEURO|SMOKE_GASP|SMOKE_COUGH

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
	var/strength = 1

/datum/effect_system/smoke_spread/xeno/start()
	if(QDELETED(location) && !QDELETED(holder))
		location = get_turf(holder)
	var/obj/effect/particle_effect/smoke/xeno/S = new smoke_type(location, range, lifetime, src)
	S.strength = strength

/datum/effect_system/smoke_spread/xeno/acid
	smoke_type = /obj/effect/particle_effect/smoke/xeno/burn

/datum/effect_system/smoke_spread/xeno/neuro
	smoke_type = /obj/effect/particle_effect/smoke/xeno/neuro

/////////////////////////////////////////////
// Chem smoke
/////////////////////////////////////////////
/obj/effect/particle_effect/smoke/chem
	lifetime = 10
	smoke_traits = SMOKE_CHEM

/obj/effect/particle_effect/smoke/chem/copy_stats(obj/effect/particle_effect/smoke/parent)
	icon = parent.icon
	return ..()

/datum/effect_system/smoke_spread/chem
	var/obj/chemholder
	smoke_type = /obj/effect/particle_effect/smoke/chem

/datum/effect_system/smoke_spread/chem/New()
	. = ..()
	chemholder = new()
	chemholder.create_reagents(500)

/datum/effect_system/smoke_spread/chem/set_up(datum/reagents/carry, radius = 1, loca, smoke_time, silent = FALSE)
	if(isturf(loca))
		location = loca
	else
		location = get_turf(loca)
	range = radius
	if(smoke_time)
		lifetime = smoke_time

	carry.copy_to(chemholder, carry.total_volume)

	if(!silent)
		var/contained = ""
		for(var/reagent in carry.reagent_list)
			contained += " [reagent] "
		if(contained)
			contained = "\[[contained]\]"

		var/where = "[AREACOORD(location)]"
		if(carry.my_atom.fingerprintslast)
			var/mob/M = get_mob_by_key(carry.my_atom.fingerprintslast)
			message_admins("Smoke: ([ADMIN_VERBOSEJMP(location)])[contained]. Last associated key: [M ? ADMIN_TPMONTY(M) : carry.my_atom.fingerprintslast].")
			log_game("A chemical smoke reaction has taken place in ([where])[contained]. Last touched by [carry.my_atom.fingerprintslast].")
		else
			message_admins("Smoke: ([ADMIN_VERBOSEJMP(location)])[contained]. No associated key.")
			log_game("A chemical smoke reaction has taken place in ([where])[contained]. No associated key.")

/datum/effect_system/smoke_spread/chem/start()
	var/mixcolor = mix_color_from_reagents(chemholder.reagents.reagent_list)
	if(QDELETED(location) && !QDELETED(holder))
		location = get_turf(holder)
	var/obj/effect/particle_effect/smoke/chem/S = new smoke_type(location, range, lifetime, src)

	if(chemholder.reagents.total_volume > 1) // can't split 1 very well
		chemholder.reagents.copy_to(S, chemholder.reagents.total_volume)

	if(mixcolor)
		S.icon = icon('icons/effects/chemsmoke.dmi')
		S.icon += mixcolor
