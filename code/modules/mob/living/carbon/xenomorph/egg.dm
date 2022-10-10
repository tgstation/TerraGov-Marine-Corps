/obj/alien/egg
	name = "theoretical egg"
	density = FALSE
	flags_atom = CRITICAL_ATOM
	max_integrity = 80
	integrity_failure = 20
	///What maturity stage are we in
	var/maturity_stage = 1
	///Time between two maturity stages
	var/maturity_time = 0
	///Number of the last maturity stage before bursting
	var/stage_ready_to_burst = 0
	///Which hive it belongs to
	var/hivenumber = XENO_HIVE_NORMAL
	///How far will targets trigger the burst
	var/trigger_size = 0

/obj/alien/egg/Initialize(mapload, hivenumber)
	. = ..()
	src.hivenumber = hivenumber
	advance_maturity(maturity_stage)

/obj/alien/egg/update_icon_state()
	icon_state = initial(icon_state) + "[maturity_stage]"

/obj/alien/egg/obj_break(damage_flag)
	burst(TRUE)
	return ..()

///Advance the maturity state by one, or set it to maturity
/obj/alien/egg/proc/advance_maturity(maturity)
	maturity_stage = maturity ? maturity : maturity_stage + 1
	update_icon()
	if(maturity_stage < stage_ready_to_burst)
		addtimer(CALLBACK(src, .proc/advance_maturity), maturity_time)
		return
	if(maturity_stage != stage_ready_to_burst)
		return
	for(var/turf/turf_to_watch AS in filled_turfs(src, trigger_size, "circle", FALSE))
		RegisterSignal(turf_to_watch, COMSIG_ATOM_ENTERED, .proc/enemy_crossed)

///Bursts the egg. Return TRUE if it bursts successfully, FALSE if it fails for any reason.
/obj/alien/egg/proc/burst(via_damage)
	SHOULD_CALL_PARENT(TRUE)
	if(maturity_stage != stage_ready_to_burst) //already popped, or not ready yet
		return FALSE
	if(via_damage)
		advance_maturity(stage_ready_to_burst + 2)
	else
		advance_maturity(stage_ready_to_burst + 1)
	for(var/turf/turf_to_watch AS in filled_turfs(src, trigger_size, "circle", FALSE))
		UnregisterSignal(turf_to_watch, COMSIG_ATOM_ENTERED)
	return TRUE

///Signal handler to check if the atom moving nearby is an enemy
/obj/alien/egg/proc/enemy_crossed(datum/source, atom/movable/entered)
	SIGNAL_HANDLER
	if(!iscarbon(entered))
		return
	if(!should_proc_burst(entered))
		return
	burst()

/obj/alien/egg/proc/should_proc_burst(mob/living/carbon/carbon_mover)
	if(issamexenohive(carbon_mover))
		return FALSE
	if(carbon_mover.stat == DEAD)
		return FALSE
	return TRUE

/obj/alien/egg/flamer_fire_act(burnlevel)
	burst(TRUE)

/obj/alien/egg/fire_act()
	burst(TRUE)

/obj/alien/egg/ex_act(severity)
	burst(TRUE)

/obj/alien/egg/hugger
	desc = "It looks like a weird egg"
	name = "hugger egg"
	icon_state = "egg_hugger"
	density = FALSE
	flags_atom = CRITICAL_ATOM
	max_integrity = 80
	maturity_time = 15 SECONDS
	stage_ready_to_burst = 2
	trigger_size = 2
	///What type of hugger are produced here
	var/hugger_type = /obj/item/clothing/mask/facehugger

/obj/alien/egg/hugger/update_icon_state()
	. = ..()
	overlays.Cut()
	if(on_fire)
		overlays += "alienegg_fire"
	if(hivenumber != XENO_HIVE_NORMAL && GLOB.hive_datums[hivenumber])
		var/datum/hive_status/hive = GLOB.hive_datums[hivenumber]
		color = hive.color
		return
	color = null

/obj/alien/egg/hugger/burst(via_damage)
	. = ..()
	if(!.)
		return
	if(via_damage)
		hugger_type = null
		playsound(loc, "sound/effects/alien_egg_burst.ogg", 30)
		flick("egg exploding", src)
		return
	playsound(src.loc, "sound/effects/alien_egg_move.ogg", 25)
	flick("egg opening", src)
	var/obj/item/clothing/mask/facehugger/hugger = new hugger_type()
	hugger_type = null
	addtimer(CALLBACK(hugger, /atom/movable.proc/forceMove, loc), 1 SECONDS)
	hugger.go_active()

/obj/alien/egg/hugger/attack_alien(mob/living/carbon/xenomorph/xenomorph, damage_amount = xenomorph.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	if(xenomorph.status_flags & INCORPOREAL)
		return FALSE

	if(!istype(xenomorph))
		return attack_hand(xenomorph)

	if(!issamexenohive(xenomorph))
		xenomorph.do_attack_animation(src, ATTACK_EFFECT_SMASH)
		xenomorph.visible_message("<span class='xenowarning'>[xenomorph] crushes \the [src].","<span class='xenowarning'>We crush \the [src].")
		burst(FALSE)
		return

	switch(maturity_stage)
		if(1)
			to_chat(xenomorph, span_xenowarning("The child is not developed yet."))
		if(2)
			to_chat(xenomorph, span_xenonotice("We retrieve the child."))
			burst()
		if(3, 4)
			xenomorph.visible_message(span_xenonotice("\The [xenomorph] clears the hatched egg."), \
			span_xenonotice("We clear the hatched egg."))
			playsound(loc, "alien_resin_break", 25)
			qdel(src)

/obj/alien/egg/hugger/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(!istype(I, /obj/item/clothing/mask/facehugger))
		return FALSE
	return insert_new_hugger(I, user)

///Try to insert a new hugger into the egg
/obj/alien/egg/hugger/proc/insert_new_hugger(obj/item/clothing/mask/facehugger/facehugger, mob/user)
	if(facehugger.stat == DEAD)
		if(user)
			to_chat(user, span_xenowarning("This child is dead."))
		return FALSE

	if(maturity_stage != stage_ready_to_burst + 1)
		if(user)
			to_chat(user, span_xenowarning("This egg is not usable."))
		return FALSE

	if(hugger_type)
		if(user)
			to_chat(user, span_xenowarning("This one is occupied with a child."))
		return FALSE
	if(user)
		user.visible_message(span_xenowarning("[user] slides [facehugger] back into [src]."),span_xenonotice("You place the child into [src]."))
	hugger_type = facehugger.type
	qdel(facehugger)
	advance_maturity(stage_ready_to_burst)
	return TRUE

/obj/alien/egg/gas
	desc = "It looks like a weird egg"
	name = "hugger egg"
	icon_state = "egg_hugger"
	integrity_failure = 75 //Highly responsive to poking
	maturity_time = 15 SECONDS
	maturity_stage = 2
	stage_ready_to_burst = 2
	trigger_size = 2
	///Holds a typepath for the gas particle to create
	var/gas_type = /datum/effect_system/smoke_spread/xeno/neuro/medium
	///Bonus size for certain gasses
	var/gas_size_bonus = 0

/obj/alien/egg/gas/burst(via_damage)
	. = ..()
	if(!.)
		return
	var/spread = EGG_GAS_DEFAULT_SPREAD
	if(via_damage) // More violent destruction, more gas.
		playsound(loc, "sound/effects/alien_egg_burst.ogg", 30)
		flick("egg exploding", src)
		spread = EGG_GAS_KILL_SPREAD
	else
		playsound(src.loc, "sound/effects/alien_egg_move.ogg", 25)
		flick("egg opening", src)
	spread += gas_size_bonus

	var/datum/effect_system/smoke_spread/xeno/NS = new gas_type(src)
	NS.set_up(spread, get_turf(src))
	NS.start()

/obj/alien/egg/gas/attack_alien(mob/living/carbon/xenomorph/xenomorph, damage_amount = xenomorph.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	if(maturity_stage > stage_ready_to_burst)
		xenomorph.visible_message(span_xenonotice("\The [xenomorph] clears the hatched egg."), \
		span_xenonotice("We clear the broken egg."))
		playsound(loc, "alien_resin_break", 25)
		qdel(src)

	if(!issamexenohive(xenomorph) || xenomorph.a_intent != INTENT_HELP)
		xenomorph.do_attack_animation(src, ATTACK_EFFECT_SMASH)
		xenomorph.visible_message(span_xenowarning("[xenomorph] crushes \the [src]."), span_xenowarning("We crush \the [src]."))
		burst(TRUE)
		return

	to_chat(xenomorph, span_warning("That egg is filled with gas and has no child to retrieve."))

