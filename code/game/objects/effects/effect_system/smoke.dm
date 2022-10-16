
/////////////////////////////////////////////
//// SMOKE SYSTEMS
/////////////////////////////////////////////

/obj/effect/particle_effect/smoke
	name = "smoke"
	icon_state = "smoke"
	opacity = TRUE
	anchored = TRUE
	layer = FLY_LAYER
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
	var/smoke_can_spread_through = FALSE
	///Delay in ticks before this smoke can affect a given mob again, applied in living's effect_smoke
	var/minimum_effect_delay = 1 SECONDS

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
	var/static/list/connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_cross,
		COMSIG_ATOM_EXITED = .proc/on_exited
	)
	AddElement(/datum/element/connect_loc, connections)

/obj/effect/particle_effect/smoke/Destroy()
	if(lifetime && CHECK_BITFIELD(smoke_traits, SMOKE_CAMO))
		apply_smoke_effect(get_turf(src))
		LAZYCLEARLIST(cloud?.smoked_mobs)
		INVOKE_ASYNC(src, .proc/fade_out)
	if(CHECK_BITFIELD(smoke_traits, SMOKE_CHEM) && LAZYLEN(cloud?.smoked_mobs)) //so the whole cloud won't stop working somehow
		var/obj/effect/particle_effect/smoke/neighbor = pick(cloud.smokes - src)
		neighbor.chemical_effect()
	STOP_PROCESSING(SSobj, src)
	if(cloud)
		LAZYREMOVE(cloud.smokes, src)
		if(cloud.single_use && !LAZYLEN(cloud.smokes))
			qdel(cloud)
	return ..()

/obj/effect/particle_effect/smoke/proc/fade_out(frames = 16)
	if(alpha == 0) //Handle already transparent case
		return
	if(frames == 0)
		frames = 1 //We will just assume that by 0 frames, the coder meant "during one frame".
	var/step = alpha / frames
	for(var/i in 1 to frames)
		alpha -= step
		if(alpha < 160)
			set_opacity(FALSE) //if we were blocking view, we aren't now because we're fading out
		stoplag()

/obj/effect/particle_effect/smoke/process()
	lifetime--
	if(lifetime < 1)
		qdel(src)
		return FALSE
	apply_smoke_effect(get_turf(src))
	return TRUE

/obj/effect/particle_effect/smoke/proc/on_cross(datum/source, atom/movable/O, oldloc, oldlocs)
	SIGNAL_HANDLER
	if(isliving(O))
		O.effect_smoke(src)
		return
	if(CHECK_BITFIELD(smoke_traits, SMOKE_NERF_BEAM) && istype(O, /obj/projectile))
		O.effect_smoke(src)

/obj/effect/particle_effect/smoke/proc/on_exited(datum/source, mob/living/M, direction)
	SIGNAL_HANDLER
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
		S.setDir(pick(GLOB.cardinals))
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
	for(var/obj/effect/particle_effect/smoke/foundsmoke in T)
		if(istype(foundsmoke, src) || !foundsmoke?.smoke_can_spread_through) //Don't spread smoke through itself or, unless specified, through other smokes.
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
	if(!QDELETED(holder))
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
	alpha = 40
	opacity = FALSE
	smoke_traits = SMOKE_CAMO

/////////////////////////////////////////////
// Sleep smoke
/////////////////////////////////////////////

/obj/effect/particle_effect/smoke/sleepy
	smoke_traits = SMOKE_COUGH|SMOKE_SLEEP|SMOKE_OXYLOSS

/////////////////////////////////////////////
// Phosphorus Gas
/////////////////////////////////////////////

/obj/effect/particle_effect/smoke/phosphorus
	alpha = 145
	opacity = FALSE
	color = "#DBCBB9"
	smoke_traits = SMOKE_GASP|SMOKE_BLISTERING|SMOKE_OXYLOSS|SMOKE_PLASMALOSS|SMOKE_FOUL

///////////////////////////////////////////
// Plasma draining smoke
//////////////////////////////////////////

/obj/effect/particle_effect/smoke/plasmaloss
	alpha = 90
	opacity = FALSE
	color = "#791697"
	smoke_traits = SMOKE_PLASMALOSS

//////////////////////////////////////
// FLASHBANG SMOKE
////////////////////////////////////

/obj/effect/particle_effect/smoke/flashbang
	name = "illumination"
	lifetime = 2
	opacity = FALSE
	icon_state = "sparks"
	icon = 'icons/effects/effects.dmi'

//SOM nerve agent smoke
/obj/effect/particle_effect/smoke/satrapine
	color = "#b02828"
	lifetime = 6
	spread_speed = 7
	expansion_speed = 3
	strength = 1.5
	smoke_traits = SMOKE_SATRAPINE|SMOKE_GASP|SMOKE_COUGH

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
	lifetime = 6
	color = "#86B028" //Mostly green?
	smoke_traits = SMOKE_XENO|SMOKE_XENO_ACID|SMOKE_GASP|SMOKE_COUGH|SMOKE_HUGGER_PACIFY

//Xeno light acid smoke.for acid huggers
/obj/effect/particle_effect/smoke/xeno/burn/light
	lifetime = 4 //Lasts for less time
	alpha = 60
	opacity = FALSE
	smoke_traits = SMOKE_XENO|SMOKE_XENO_ACID|SMOKE_GASP|SMOKE_COUGH

//Xeno neurotox smoke.
/obj/effect/particle_effect/smoke/xeno/neuro
	color = "#ffbf58" //Mustard orange?
	smoke_traits = SMOKE_XENO|SMOKE_XENO_NEURO|SMOKE_GASP|SMOKE_COUGH|SMOKE_EXTINGUISH|SMOKE_HUGGER_PACIFY

///Xeno neurotox smoke for Defilers; doesn't extinguish
/obj/effect/particle_effect/smoke/xeno/neuro/medium
	color = "#ffbf58" //Mustard orange?
	smoke_traits = SMOKE_XENO|SMOKE_XENO_NEURO|SMOKE_GASP|SMOKE_COUGH

///Xeno neurotox smoke for neurospit; doesn't extinguish or blind
/obj/effect/particle_effect/smoke/xeno/neuro/light
	alpha = 60
	opacity = FALSE
	smoke_can_spread_through = TRUE
	smoke_traits = SMOKE_XENO|SMOKE_XENO_NEURO|SMOKE_GASP|SMOKE_COUGH|SMOKE_NEURO_LIGHT //Light neuro smoke doesn't extinguish

//Xeno corrosive//
/obj/effect/particle_effect/smoke/xeno/corrosive
	alpha = 60
	opacity = FALSE
	color = "#7be844"
	smoke_can_spread_through = TRUE
	smoke_traits = SMOKE_XENO|SMOKE_XENO_ACID|SMOKE_GASP|SMOKE_COUGH|SMOKE_CORROSIVE

/obj/effect/particle_effect/smoke/xeno/hemodile
	smoke_can_spread_through = TRUE
	color = "#0287A1"
	smoke_traits = SMOKE_XENO|SMOKE_XENO_HEMODILE|SMOKE_GASP

/obj/effect/particle_effect/smoke/xeno/transvitox
	smoke_can_spread_through = TRUE
	color = "#abf775"
	smoke_traits = SMOKE_XENO|SMOKE_XENO_TRANSVITOX|SMOKE_COUGH

//Toxic smoke when the Defiler successfully uses Defile
/obj/effect/particle_effect/smoke/xeno/sanguinal
	color = "#bb0a1e" //Blood red
	smoke_can_spread_through = TRUE
	smoke_traits = SMOKE_XENO|SMOKE_XENO_SANGUINAL|SMOKE_GASP|SMOKE_COUGH

///Xeno ozelomelyn in smoke form for Defiler.
/obj/effect/particle_effect/smoke/xeno/ozelomelyn
	color = "#f1ddcf" //A pinkish for now.
	smoke_traits = SMOKE_XENO|SMOKE_XENO_OZELOMELYN|SMOKE_GASP|SMOKE_COUGH

/////////////////////////////////////////////
// Smoke spreads
/////////////////////////////////////////////

/datum/effect_system/smoke_spread/bad
	smoke_type = /obj/effect/particle_effect/smoke/bad

datum/effect_system/smoke_spread/tactical
	smoke_type = /obj/effect/particle_effect/smoke/tactical

/datum/effect_system/smoke_spread/sleepy
	smoke_type = /obj/effect/particle_effect/smoke/sleepy

/datum/effect_system/smoke_spread/phosphorus
	smoke_type = /obj/effect/particle_effect/smoke/phosphorus

/datum/effect_system/smoke_spread/plasmaloss
	smoke_type = /obj/effect/particle_effect/smoke/plasmaloss

/datum/effect_system/smoke_spread/satrapine
	smoke_type = /obj/effect/particle_effect/smoke/satrapine

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

/datum/effect_system/smoke_spread/xeno/acid/light
	smoke_type = /obj/effect/particle_effect/smoke/xeno/burn/light

/datum/effect_system/smoke_spread/xeno/neuro
	smoke_type = /obj/effect/particle_effect/smoke/xeno/neuro

/datum/effect_system/smoke_spread/xeno/neuro/medium
	smoke_type = /obj/effect/particle_effect/smoke/xeno/neuro/medium

/datum/effect_system/smoke_spread/xeno/neuro/light
	smoke_type = /obj/effect/particle_effect/smoke/xeno/neuro/light

/datum/effect_system/smoke_spread/xeno/corrosive
	smoke_type = /obj/effect/particle_effect/smoke/xeno/corrosive

/datum/effect_system/smoke_spread/xeno/hemodile
	smoke_type = /obj/effect/particle_effect/smoke/xeno/hemodile

/datum/effect_system/smoke_spread/xeno/transvitox
	smoke_type = /obj/effect/particle_effect/smoke/xeno/transvitox

/datum/effect_system/smoke_spread/xeno/sanguinal
	smoke_type = /obj/effect/particle_effect/smoke/xeno/sanguinal

/datum/effect_system/smoke_spread/xeno/ozelomelyn
	smoke_type = /obj/effect/particle_effect/smoke/xeno/ozelomelyn

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

		message_admins("Smoke: ([ADMIN_VERBOSEJMP(location)])[contained].")
		log_game("A chemical smoke reaction has taken place in ([AREACOORD(location)])[contained].")

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
