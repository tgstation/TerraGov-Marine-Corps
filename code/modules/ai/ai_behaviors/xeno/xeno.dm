//Generic template for application to a xeno/ mob, contains specific obstacle dealing alongside targeting only humans, xenos of a different hive and sentry turrets

/datum/ai_behavior/xeno
	sidestep_prob = 25
	identifier = IDENTIFIER_XENO
	///List of abilities to consider doing every Process()
	var/list/ability_list = list()

/datum/ai_behavior/xeno/New(loc, parent_to_assign, escorted_atom)
	..()
	RegisterSignal(mob_parent, COMSIG_OBSTRUCTED_MOVE, /datum/ai_behavior.proc/deal_with_obstacle)
	RegisterSignal(mob_parent, list(ACTION_GIVEN, ACTION_REMOVED), .proc/refresh_abilities)
	refresh_abilities()
	mob_parent.a_intent = INTENT_HARM //Killing time

///Refresh abilities-to-consider list
/datum/ai_behavior/xeno/proc/refresh_abilities()
	SIGNAL_HANDLER
	ability_list = list()
	for(var/datum/action/action AS in mob_parent.actions)
		if(action.ai_should_start_consider())
			ability_list += action

/datum/ai_behavior/xeno/process()
	if(mob_parent.do_actions) //No activating more abilities if they're already in the progress of doing one
		return ..()

	for(var/datum/action/action in ability_list)
		if(!action.ai_should_use(atom_to_walk_to))
			continue
		//xeno_action/activable is activated with a different proc for keybinded actions, so we gotta use the correct proc
		if(istype(action, /datum/action/xeno_action/activable))
			var/datum/action/xeno_action/activable/xeno_action = action
			xeno_action.use_ability(atom_to_walk_to)
		else
			action.action_activate()
	return ..()

/datum/ai_behavior/xeno/look_for_new_state()
	switch(current_action)
		if(ESCORTING_ATOM, MOVING_TO_NODE)
			var/atom/next_target = get_nearest_target(escorted_atom, target_distance, TARGET_ALL, null, mob_parent.get_xeno_hivenumber())
			if(!next_target)
				return
			change_action(MOVING_TO_ATOM, next_target)
		if(MOVING_TO_ATOM)
			if(escorted_atom && get_dist(escorted_atom, mob_parent) > target_distance)
				change_action(ESCORTING_ATOM, escorted_atom)
				return
			var/atom/next_target = get_nearest_target(escorted_atom, target_distance, TARGET_ALL, null, mob_parent.get_xeno_hivenumber())
			if(!next_target)//We didn't find a target
				cleanup_current_action()
				late_initialize()
				return
			if(next_target == atom_to_walk_to)//We didn't find a better target
				return
			change_action(null, next_target)//We found a better target, change course!

/datum/ai_behavior/xeno/deal_with_obstacle(datum/source, direction)
	var/turf/obstacle_turf = get_step(mob_parent, direction)
	for(var/thing in obstacle_turf.contents)
		if(isstructure(thing))
			if(istype(thing, /obj/structure/window_frame))
				mob_parent.loc = obstacle_turf
				return COMSIG_OBSTACLE_DEALT_WITH
			if(istype(thing, /obj/structure/closet))
				var/obj/structure/closet/closet = thing
				if(closet.open(mob_parent))
					return COMSIG_OBSTACLE_DEALT_WITH
				return
			var/obj/structure/obstacle = thing
			if(obstacle.resistance_flags & XENO_DAMAGEABLE)
				mob_parent.face_atom(obstacle)
				INVOKE_ASYNC(src, .proc/attack_target, null, obstacle)
				return COMSIG_OBSTACLE_DEALT_WITH
		else if(istype(thing, /obj/machinery/door/airlock))
			var/obj/machinery/door/airlock/lock = thing
			if(!lock.density) //Airlock is already open no need to force it open again
				continue
			if(lock.operating) //Airlock already doing something
				continue
			if(lock.welded) //It's welded, can't force that open
				continue
			lock.open(TRUE)
			return COMSIG_OBSTACLE_DEALT_WITH
	if(ISDIAGONALDIR(direction))
		return deal_with_obstacle(null, turn(direction, -45)) || deal_with_obstacle(null, turn(direction, 45))

///Signal handler to try to attack our target
/datum/ai_behavior/xeno/proc/attack_target(datum/soure, atom/attacked)
	SIGNAL_HANDLER
	if(world.time < mob_parent.next_move)
		return
	if(!attacked)
		attacked = atom_to_walk_to
	if(get_dist(attacked, mob_parent) > 1)
		return
	mob_parent.face_atom(attacked)
	if(isobj(attacked) && !(attacked.resistance_flags & XENO_DAMAGEABLE))
		stack_trace("A xenomorph tried to attack a [attacked.name] that isn't considered XENO_DAMAGABLE according to resistance flags.")
		return
	var/mob/living/carbon/xenomorph/xeno = mob_parent
	attacked.attack_alien(xeno, xeno.xeno_caste.melee_damage * xeno.xeno_melee_damage_modifier)
	xeno.changeNext_move(xeno.xeno_caste.attack_delay)

/datum/ai_behavior/xeno/register_action_signals(action_type)
	switch(action_type)
		if(MOVING_TO_ATOM)
			RegisterSignal(mob_parent, COMSIG_STATE_MAINTAINED_DISTANCE, .proc/attack_target)
			if(ishuman(atom_to_walk_to))
				RegisterSignal(atom_to_walk_to, COMSIG_MOB_DEATH, /datum/ai_behavior.proc/look_for_new_state)
				return
			if(ismachinery(atom_to_walk_to))
				RegisterSignal(atom_to_walk_to, COMSIG_PARENT_PREQDELETED, /datum/ai_behavior.proc/look_for_new_state)
				return

	return ..()

/datum/ai_behavior/xeno/unregister_action_signals(action_type)
	switch(action_type)
		if(MOVING_TO_ATOM)
			UnregisterSignal(mob_parent, COMSIG_STATE_MAINTAINED_DISTANCE)
			if(ishuman(atom_to_walk_to))
				UnregisterSignal(atom_to_walk_to, COMSIG_MOB_DEATH)
				return
			if(ismachinery(atom_to_walk_to))
				UnregisterSignal(atom_to_walk_to, COMSIG_PARENT_PREQDELETED)
				return

	return ..()
