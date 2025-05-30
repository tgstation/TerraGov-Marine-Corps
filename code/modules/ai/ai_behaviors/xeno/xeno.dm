//Generic template for application to a xeno/ mob, contains specific obstacle dealing alongside targeting only humans, xenos of a different hive and sentry turrets

/datum/ai_behavior/xeno
	sidestep_prob = 25
	identifier = IDENTIFIER_XENO
	is_offered_on_creation = TRUE
	///List of abilities to consider doing every Process()
	var/list/ability_list = list()
	///If the mob parent can heal itself and so should flee
	var/can_heal = TRUE

/datum/ai_behavior/xeno/New(loc, mob/parent_to_assign, atom/escorted_atom)
	..()
	refresh_abilities()
	mob_parent.a_intent = INTENT_HARM //Killing time

/datum/ai_behavior/xeno/start_ai()
	RegisterSignal(mob_parent, COMSIG_OBSTRUCTED_MOVE, TYPE_PROC_REF(/datum/ai_behavior, deal_with_obstacle))
	RegisterSignals(mob_parent, list(ACTION_GIVEN, ACTION_REMOVED), PROC_REF(refresh_abilities))
	RegisterSignal(mob_parent, COMSIG_XENOMORPH_TAKING_DAMAGE, PROC_REF(check_for_critical_health))
	if(!escorted_atom)
		RegisterSignal(SSdcs, COMSIG_GLOB_AI_MINION_RALLY, PROC_REF(global_set_escorted_atom))
	return ..()

/datum/ai_behavior/xeno/clean_escorted_atom(find_new_escort = FALSE)
	if(!escorted_atom)
		return
	RegisterSignal(SSdcs, COMSIG_GLOB_AI_MINION_RALLY, PROC_REF(global_set_escorted_atom))
	return ..()

/datum/ai_behavior/xeno/set_escorted_atom(datum/source, atom/atom_to_escort, new_escort_is_weak)
	. = ..()
	if(!new_escort_is_weak)
		UnregisterSignal(SSdcs, COMSIG_GLOB_AI_MINION_RALLY)

/datum/ai_behavior/xeno/global_set_escorted_atom(datum/source, atom/atom_to_escort)
	if(!atom_to_escort || atom_to_escort.get_xeno_hivenumber() != mob_parent.get_xeno_hivenumber() || mob_parent.ckey)
		return
	return ..()

///Refresh abilities-to-consider list
/datum/ai_behavior/xeno/proc/refresh_abilities()
	SIGNAL_HANDLER
	ability_list = list()
	for(var/datum/action/action AS in mob_parent.actions)
		if(action.ai_should_start_consider())
			ability_list += action

/datum/ai_behavior/xeno/process()
	if(mob_parent.notransform)
		return ..()
	if(mob_parent.do_actions) //No activating more abilities if they're already in the progress of doing one
		return ..()
	if(should_hold())
		return ..()

	for(var/datum/action/action in ability_list)
		if(!action.ai_should_use(atom_to_walk_to))
			continue
		//xeno_action/activable is activated with a different proc for keybinded actions, so we gotta use the correct proc
		if(istype(action, /datum/action/ability/xeno_action))
			var/datum/action/ability/activable/xeno/xeno_action = action
			xeno_action.use_ability(atom_to_walk_to)
		else
			action.action_activate()
	return ..()

/datum/ai_behavior/xeno/state_process(next_target)
	var/mob/living/living_parent = mob_parent
	if(current_action != MOVING_TO_NODE && current_action != FOLLOWING_PATH)
		return
	if(can_heal && living_parent.health <= minimum_health * 2 * living_parent.maxHealth)
		try_to_heal() //If we have some damage, look for some healing
		return
	if(!goal_node) // We are randomly moving
		var/atom/xeno_to_follow = get_nearest_target(mob_parent, AI_ESCORTING_MAX_DISTANCE, TARGET_FRIENDLY_XENO, mob_parent.faction, mob_parent.get_xeno_hivenumber())
		if(xeno_to_follow)
			set_escorted_atom(null, xeno_to_follow, TRUE)

/datum/ai_behavior/xeno/look_for_new_state(next_target)
	if(current_action == ESCORTING_ATOM)
		if(get_dist(escorted_atom, mob_parent) > AI_ESCORTING_MAX_DISTANCE)
			look_for_next_node()
			return
	if(current_action == MOVING_TO_ATOM)
		if(!weak_escort && escorted_atom && get_dist(escorted_atom, mob_parent) > target_distance)
			change_action(ESCORTING_ATOM, escorted_atom)
			return
		if(!next_target)//We didn't find a target
			cleanup_current_action()
			late_initialize()
			return
		if(next_target == atom_to_walk_to)//We didn't find a better target
			return
	if(current_action == MOVING_TO_SAFETY)
		if(!next_target)
			target_distance = initial(target_distance)
			cleanup_current_action()
			late_initialize()
			RegisterSignal(mob_parent, COMSIG_XENOMORPH_TAKING_DAMAGE, PROC_REF(check_for_critical_health))
			return
		if(next_target != atom_to_walk_to)
			change_action(null, next_target, list(INFINITY))

	if(next_target)
		change_action(MOVING_TO_ATOM, next_target)
		return

/datum/ai_behavior/xeno/deal_with_obstacle(datum/source, direction)
	var/turf/obstacle_turf = get_step(mob_parent, direction)
	if(obstacle_turf.atom_flags & AI_BLOCKED)
		return
	for(var/thing in obstacle_turf.contents)
		if(istype(thing, /obj/structure/window_frame))
			LAZYINCREMENT(mob_parent.do_actions, obstacle_turf)
			addtimer(CALLBACK(src, PROC_REF(climb_window_frame), obstacle_turf), 2 SECONDS)
			return COMSIG_OBSTACLE_DEALT_WITH
		if(istype(thing, /obj/structure/closet))
			var/obj/structure/closet/closet = thing
			if(closet.open(mob_parent))
				return COMSIG_OBSTACLE_DEALT_WITH
			return
		if(isstructure(thing))
			var/obj/structure/obstacle = thing
			if(obstacle.resistance_flags & XENO_DAMAGEABLE)
				INVOKE_ASYNC(src, PROC_REF(attack_target), null, obstacle)
				return COMSIG_OBSTACLE_DEALT_WITH
		else if(istype(thing, /obj/machinery/door/airlock))
			var/obj/machinery/door/airlock/lock = thing
			if(!lock.density) //Airlock is already open no need to force it open again
				continue
			if(lock.operating) //Airlock already doing something
				continue
			if(lock.welded || lock.locked) //It's welded or locked, can't force that open
				INVOKE_ASYNC(src, PROC_REF(attack_target), null, thing) //ai is cheating
				continue
			lock.open(TRUE)
			return COMSIG_OBSTACLE_DEALT_WITH
		if(istype(thing, /obj/vehicle))
			INVOKE_ASYNC(src, PROC_REF(attack_target), null, thing)
			return COMSIG_OBSTACLE_DEALT_WITH
	if(ISDIAGONALDIR(direction) && ((deal_with_obstacle(null, turn(direction, -45)) & COMSIG_OBSTACLE_DEALT_WITH) || (deal_with_obstacle(null, turn(direction, 45)) & COMSIG_OBSTACLE_DEALT_WITH)))
		return COMSIG_OBSTACLE_DEALT_WITH
	//Ok we found nothing, yet we are still blocked. Check for blockers on our current turf
	obstacle_turf = get_turf(mob_parent)
	for(var/obj/structure/obstacle in obstacle_turf.contents)
		if(obstacle.dir & direction && obstacle.resistance_flags & XENO_DAMAGEABLE)
			INVOKE_ASYNC(src, PROC_REF(attack_target), null, obstacle)
			return COMSIG_OBSTACLE_DEALT_WITH

/datum/ai_behavior/xeno/cleanup_current_action(next_action)
	. = ..()
	if(next_action == MOVING_TO_NODE)
		return
	if(!isxeno(mob_parent))
		return
	var/mob/living/living_mob = mob_parent
	if(can_heal && living_mob.resting)
		SEND_SIGNAL(mob_parent, COMSIG_XENOABILITY_REST)
		UnregisterSignal(mob_parent, COMSIG_XENOMORPH_HEALTH_REGEN)

/datum/ai_behavior/xeno/cleanup_signals()
	. = ..()
	UnregisterSignal(mob_parent, COMSIG_OBSTRUCTED_MOVE)
	UnregisterSignal(mob_parent, list(ACTION_GIVEN, ACTION_REMOVED))
	UnregisterSignal(mob_parent, COMSIG_XENOMORPH_TAKING_DAMAGE)
	UnregisterSignal(SSdcs, COMSIG_GLOB_AI_MINION_RALLY)

///Signal handler to try to attack our target
/datum/ai_behavior/xeno/proc/attack_target(datum/source, atom/attacked)
	SIGNAL_HANDLER
	if(world.time < mob_parent.next_move)
		return
	if(!attacked)
		attacked = get_atom_on_turf(atom_to_walk_to)
	if(get_dist(attacked, mob_parent) > 1)
		return
	mob_parent.face_atom(attacked)
	mob_parent.UnarmedAttack(attacked, TRUE)

/datum/ai_behavior/xeno/register_action_signals(action_type)
	switch(action_type)
		if(MOVING_TO_ATOM)
			RegisterSignal(mob_parent, COMSIG_STATE_MAINTAINED_DISTANCE, PROC_REF(attack_target))
			return
	return ..()

///Will try finding and resting on weeds
/datum/ai_behavior/xeno/proc/try_to_heal()
	var/mob/living/carbon/xenomorph/living_mob = mob_parent
	if(!living_mob.loc_weeds_type)
		if(living_mob.resting)//We are resting on no weeds
			SEND_SIGNAL(mob_parent, COMSIG_XENOABILITY_REST)
			UnregisterSignal(mob_parent, list(COMSIG_XENOMORPH_HEALTH_REGEN, COMSIG_XENOMORPH_PLASMA_REGEN))
		return FALSE
	if(living_mob.resting)//Already resting
		if(living_mob.on_fire)
			living_mob.do_resist()
		return TRUE
	SEND_SIGNAL(mob_parent, COMSIG_XENOABILITY_REST)
	RegisterSignal(mob_parent, COMSIG_XENOMORPH_HEALTH_REGEN, PROC_REF(check_for_health), TRUE) //resting can occasionally fail, if you're stunned etc
	RegisterSignal(mob_parent, COMSIG_XENOMORPH_PLASMA_REGEN, PROC_REF(check_for_plasma), TRUE)
	return TRUE

///Wait for the xeno to be full life and plasma to unrest
/datum/ai_behavior/xeno/proc/check_for_health(mob/living/carbon/xenomorph/healing, list/heal_data)
	SIGNAL_HANDLER
	if(healing.health + heal_data[1] >= healing.maxHealth && healing.plasma_stored >= healing.xeno_caste.plasma_max * healing.xeno_caste.plasma_regen_limit)
		SEND_SIGNAL(mob_parent, COMSIG_XENOABILITY_REST)
		UnregisterSignal(mob_parent, list(COMSIG_XENOMORPH_HEALTH_REGEN, COMSIG_XENOMORPH_PLASMA_REGEN))

///Wait for the xeno to be full life and plasma to unrest
/datum/ai_behavior/xeno/proc/check_for_plasma(mob/living/carbon/xenomorph/healing, list/plasma_data)
	SIGNAL_HANDLER
	if(healing.health >= healing.maxHealth && healing.plasma_stored + plasma_data[1] >= healing.xeno_caste.plasma_max * healing.xeno_caste.plasma_regen_limit)
		SEND_SIGNAL(mob_parent, COMSIG_XENOABILITY_REST)
		UnregisterSignal(mob_parent, list(COMSIG_XENOMORPH_HEALTH_REGEN, COMSIG_XENOMORPH_PLASMA_REGEN))

///Called each time the ai takes damage; if we are below a certain health threshold, try to retreat
/datum/ai_behavior/xeno/proc/check_for_critical_health(datum/source, damage)
	SIGNAL_HANDLER
	var/mob/living/living_mob = mob_parent
	if(!can_heal || living_mob.health - damage > minimum_health * living_mob.maxHealth)
		return
	var/atom/next_target = get_nearest_target(mob_parent, target_distance, TARGET_HOSTILE, mob_parent.faction, mob_parent.get_xeno_hivenumber())
	if(!next_target)
		return
	target_distance = 15
	change_action(MOVING_TO_SAFETY, next_target, list(INFINITY))
	UnregisterSignal(mob_parent, COMSIG_XENOMORPH_TAKING_DAMAGE)

///Move the ai mob on top of the window_frame
/datum/ai_behavior/xeno/proc/climb_window_frame(turf/window_turf)
	mob_parent.forceMove(window_turf)
	mob_parent.last_move_time = world.time
	LAZYDECREMENT(mob_parent.do_actions, window_turf)

/datum/ai_behavior/xeno/ranged
	upper_maintain_dist = 5
	lower_maintain_dist = 5
	minimum_health = 0.3

/datum/ai_behavior/xeno/suicidal
	minimum_health = 0
