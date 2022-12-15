/datum/element/resin_building
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2

	var/list/mob/living/carbon/xenomorph/builders = list()

/datum/element/resin_building/Attach(mob/living/carbon/xenomorph/target)
	. = ..()
	if(!isxeno(target))
		return ELEMENT_INCOMPATIBLE
	builders += target
	var/datum/action/act = new /datum/action/xeno_action/activable/resin_build()
	builders[target] = act
	act.give_action(target)

/datum/element/resin_building/proc/GameStarted()
	for(var/mob/living/carbon/xenomorph/xeno in builders)
		Detach(xeno, TRUE)
	UnregisterSignal(SSdcs, list(COMSIG_GLOB_OPEN_TIMED_SHUTTERS_LATE, COMSIG_GLOB_OPEN_TIMED_SHUTTERS_XENO_HIVEMIND, COMSIG_GLOB_OPEN_SHUTTERS_EARLY))

/datum/element/resin_building/New()
	RegisterSignal(SSdcs, list(COMSIG_GLOB_OPEN_TIMED_SHUTTERS_LATE, COMSIG_GLOB_OPEN_TIMED_SHUTTERS_XENO_HIVEMIND, COMSIG_GLOB_OPEN_SHUTTERS_EARLY), .proc/GameStarted)
	return ..()

/obj/effect/xeno/raising_structure
	icon_state = "sparks"
	var/buildable_typepath = /turf/closed/wall/resin/regenerating
	var/timer_id

/obj/effect/xeno/raising_structure/Click(location, control, params)
	if(!..())
		return FALSE
	if(isadmin(usr))
		cancel_build()
		log_admin("[usr] has cancelled a xeno structure as an admin ")
		return TRUE
	if(!isxeno(usr))
		return
	var/mob/living/carbon/xenomorph/the_antibuilder = usr
	if(!CHECK_BITFIELD(the_antibuilder.xeno_caste.caste_flags, CASTE_IS_BUILDER))
		to_chat(the_antibuilder, span_notice("You are not capable of cancelling resin build-ups as a non-builder!"))
	else
		to_chat(the_antibuilder, span_notice("You cancel the building of the resin structure"))
		log_admin("[usr] has cancelled a xeno structure build-up as a xenomorph")
		cancel_build()

/obj/effect/xeno/raising_structure/proc/cancel_build()
	deltimer(timer_id)
	qdel(src)

/obj/effect/xeno/raising_structure/proc/do_build()
	var/turf/T = get_turf(src)
	if(!T)
		return FALSE
	if(buildable_typepath == /obj/structure/mineral_door/resin)
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
			return FALSE
	if(ispath(buildable_typepath, /turf)) // We should change turfs, not spawn them in directly
		var/list/baseturfs = islist(T.baseturfs) ? T.baseturfs : list(T.baseturfs)
		baseturfs |= T.type
		T.ChangeTurf(buildable_typepath, baseturfs)
	else
		new buildable_typepath(T)
	qdel(src)

/obj/effect/xeno/raising_structure/New(loc,building_typepath, delay)
	..()
	if(!building_typepath)
		return FALSE
	buildable_typepath = building_typepath
	if(delay <= 0.5)
		do_build()
		return TRUE

	alpha = 128
	timer_id = addtimer(CALLBACK(src, .proc/do_build), delay, TIMER_STOPPABLE)

/datum/action/xeno_action/activable/resin_build
	plasma_cost = 50
	mechanics_text = "Click on a turf to build the desired structure using weeds" //codex. If you are going to add an explanation for an ability. don't use stats, give a very brief explanation of how to use it.
	use_state_flags = XACT_USE_LYING // bypass use limitations checked by can_use_action()
	target_flags = XABB_TURF_TARGET
	cooldown_timer = 0.2 SECONDS
	ability_name = "Resin shaping"
	/// flags to restrict a xeno ability to certain gamemode
	gamemode_flags = ABILITY_DISTRESS
	action_type = ACTION_TOGGLE

/datum/action/xeno_action/activable/resin_build/use_ability(turf/T)
	var/mob/living/carbon/xenomorph/X = owner
	var/mob/living/carbon/xenomorph/blocker = locate() in T
	if(blocker && blocker != X && blocker.stat != DEAD)
		to_chat(X, span_warning("Can't do that with [blocker] in the way!"))
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

	if(locate(/obj/effect/xeno/raising_structure) in T)
		to_chat(X,span_warning("There is already something being built there!"))
		return fail_activate()

	new /obj/effect/xeno/raising_structure(T, X.selected_resin, 3 SECONDS)

/datum/element/resin_building/Detach(mob/living/carbon/xenomorph/source, force)
	. = ..()
	var/datum/action/act = builders[source]
	act.remove_action(source)
	builders[source] = null
	qdel(act)
	builders -= source
