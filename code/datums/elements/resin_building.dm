/datum/element/resin_building
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2

	///the multiplier of plasma gained via receiving damage.
	var/plasma_use_multiplier = 0.5
	var/list/mob/living/carbon/xenomorph/builders = list()

/obj/effect/xeno/raising_structure
	var/buildable_typepath = /turf/closed/wall/resin/regenerating
	var/timer_id

/obj/effect/xeno/raising_structure/Click(location, control, params)
	if(!..())
		return FALSE
	if(isadmin(usr))
		cancel_build()
		log_admin("[usr] has cancelled a xeno structure build-up at [get_turf(src).x] [get_turf(src).y] as an admin ")
		return TRUE
	if(!isxeno(usr))
		return
	var/mob/living/carbon/xenomorph/the_antibuilder = usr
	if(!CHECK_BITFIELD(the_antibuilder.caste_flags, CASTE_IS_BUILDER))
		to_chat(the_antibuilder, span_notice("You are not capable of cancelling resin build-ups as a non-builder!"))
	else
		to_chat(the_antibuilder, span_notice("You cancel the building of the resin structure"))
		log_admin("[usr] has cancelled a xeno structure build-up at [get_turf(src).x] [get_turf(src).y] as a xenomorph")
		cancel_build()

/obj/effect/xeno/raising_structure/proc/cancel_build()
	deltimer(timer_id)
	qdel(src)

/obj/effect/xeno/raising_structure/proc/do_build()
	var/atom/new_resin
	var/turf/T = get_turf(src)
	if(!T)
		return FALSE
	if(X.selected_resin == /obj/structure/mineral_door/resin)
		var/wall_support = FALSE
		for(var/D in GLOB.cardinals)
			var/turf/TS = get_step(T,D)
			if(TS)
				if(TS.density)
					wall_support = TRUE
					break
				else if(locate(/obj/structure/mineral_door/resin) in TS)
					wall_support = TRUE
					break
	if(ispath(X.selected_resin, /turf)) // We should change turfs, not spawn them in directly
		var/list/baseturfs = islist(T.baseturfs) ? T.baseturfs : list(T.baseturfs)
		baseturfs |= T.type
		T.ChangeTurf(X.selected_resin, baseturfs)
		new_resin = T
	else
		new_resin = new X.selected_resin(T)
	qdel(src)

/obj/effect/xeno_raising_structure(turf/building_typepath, delay)
	if(!building_typepath)
		return FALSE
	buildable_typepath = building_typepath
	if(delay < 0)
		do_build()
		return TRUE
	timer_id = addtimer(CALLBACK(src, .proc/do_build), delay, TIMER_STOPPABLE)



/datum/action/xeno_action/resin_build
	plasma_cost = 50
	mechanics_text = "Click on a turf to build the desired structure using weeds" //codex. If you are going to add an explanation for an ability. don't use stats, give a very brief explanation of how to use it.
	use_state_flags = XACT_USE_LYING // bypass use limitations checked by can_use_action()
	target_flags = XABB_TURF_TARGET
	cooldown_timer = 0.5 SECONDS
	ability_name = "Resin shaping"
	/// flags to restrict a xeno ability to certain gamemode
	gamemode_flags = ABILITY_DISTRESS
	action_type = ACTION_TOGGLE

/datum/action/xeno_action/resin_build/use_ability(turf/target)
	var/mob/living/carbon/xenomorph/X = owner
	var/mob/living/carbon/xenomorph/blocker = locate() in T
	if(blocker && blocker != X && blocker.stat != DEAD)
		to_chat(X, span_warning("Can't do that with [blocker] in the way!"))
		return fail_activate()

	if(!T.is_weedable())
		to_chat(X, span_warning("We can't do that here."))
		return fail_activate()

	var/obj/alien/weeds/alien_weeds = locate() in T


	if(!alien_weeds)
		to_chat(X, span_warning("We can only shape on weeds. We must find some resin before we start building!"))
		return fail_activate()

	if(!T.check_alien_construction(X, planned_building = X.selected_resin) || !T.check_disallow_alien_fortification(X))
		return fail_activate()

	if(X.selected_resin == /obj/structure/mineral_door/resin)
		var/wall_support = FALSE
		for(var/D in GLOB.cardinals)
			var/turf/TS = get_step(T,D)
			if(TS)
				if(TS.density)
					wall_support = TRUE
					break
				else if(locate(/obj/structure/mineral_door/resin) in TS)
					wall_support = TRUE
					break
		if(!wall_support)
			to_chat(X, span_warning("Resin doors need a wall or resin door next to them to stand up."))
			return fail_activate()

	if(!can_use_ability(T))
		return fail_activate()

	var/atom/AM = X.selected_resin
	X.visible_message(span_xenowarning("\The [X] regurgitates a thick substance and shapes it into \a [initial(AM.name)]!"), \
	span_xenonotice("We regurgitate some resin and shape it into \a [initial(AM.name)]."), null, 5)
	playsound(owner.loc, "alien_resin_build", 25)

	var/atom/new_resin

	if(ispath(X.selected_resin, /turf)) // We should change turfs, not spawn them in directly
		var/list/baseturfs = islist(T.baseturfs) ? T.baseturfs : list(T.baseturfs)
		baseturfs |= T.type
		T.ChangeTurf(X.selected_resin, baseturfs)
		new_resin = T
	else
		new_resin = new X.selected_resin(T)

	switch(X.selected_resin)
		if(/obj/alien/resin/sticky)
			plasma_cost = initial(plasma_cost) / 3

	if(new_resin)
		add_cooldown(SSmonitor.gamestate == SHUTTERS_CLOSED ? get_cooldown()/2 : get_cooldown())
		succeed_activate(SSmonitor.gamestate == SHUTTERS_CLOSED ? plasma_cost/2 : plasma_cost)

	plasma_cost = initial(plasma_cost) //Reset the plasma cost



/datum/element/plasma_on_attacked/Attach(datum/target, plasma_use_multiplier)
	. = ..()
	if(!isxeno(target))
		return ELEMENT_INCOMPATIBLE
	builders += target
	target.give_action()
	RegisterSignal(target, COMSIG_XENOMORPH_TAKING_DAMAGE, .proc/damage_suffered)
	src.damage_plasma_multiplier = damage_plasma_multiplier

/datum/element/plasma_on_attacked/Detach(datum/source, force)
	. = ..()
	UnregisterSignal(source, COMSIG_XENOMORPH_TAKING_DAMAGE)


/datum/element/plasma_on_attacked/proc/damage_suffered(datum/source, damage)
	SIGNAL_HANDLER
	var/mob/living/carbon/xenomorph/furious = source
	furious.gain_plasma(damage * damage_plasma_multiplier)
