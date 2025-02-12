//Generic template for application to a xeno/ mob, contains specific obstacle dealing alongside targeting only humans, xenos of a different hive and sentry turrets

/datum/ai_behavior/human
	sidestep_prob = 25
	identifier = IDENTIFIER_HUMAN
	base_action = ESCORTING_ATOM
	target_distance = 9
	//is_offered_on_creation = FALSE
	///List of abilities to consider doing every Process()
	var/list/ability_list = list()
	///If the mob parent can heal itself and so should flee
	var/can_heal = FALSE //for now

/datum/ai_behavior/human/New(loc, parent_to_assign, escorted_atom, can_heal = TRUE)
	..()
	refresh_abilities()
	mob_parent.a_intent = INTENT_HARM //Killing time
	src.can_heal = can_heal

/datum/ai_behavior/human/start_ai()
	RegisterSignal(mob_parent, COMSIG_OBSTRUCTED_MOVE, TYPE_PROC_REF(/datum/ai_behavior, deal_with_obstacle))
	RegisterSignals(mob_parent, list(ACTION_GIVEN, ACTION_REMOVED), PROC_REF(refresh_abilities))
	RegisterSignal(mob_parent, COMSIG_HUMAN_DAMAGE_TAKEN, PROC_REF(check_for_critical_health)) //todo: this is specific at the species level, so only works for humans
	return ..()

///Refresh abilities-to-consider list
/datum/ai_behavior/human/proc/refresh_abilities()
	SIGNAL_HANDLER
	ability_list = list()
	for(var/datum/action/action AS in mob_parent.actions)
		if(action.ai_should_start_consider())
			ability_list += action

/datum/ai_behavior/human/process()
	if(mob_parent.notransform) //todo: whydis?
		return ..()
	if(mob_parent.do_actions) //No activating more abilities if they're already in the progress of doing one
		return ..()

	for(var/datum/action/action in ability_list)
		if(!action.ai_should_use(atom_to_walk_to))
			continue
		//xeno_action/activable is activated with a different proc for keybinded actions, so we gotta use the correct proc
		if(istype(action, /datum/action/ability/activable/xeno)) //todo
			var/datum/action/ability/activable/xeno/xeno_action = action
			xeno_action.use_ability(atom_to_walk_to)
		else
			action.action_activate()
	return ..()

/datum/ai_behavior/human/look_for_new_state()
	var/mob/living/living_parent = mob_parent
	switch(current_action)
		if(ESCORTING_ATOM)
			if(get_dist(escorted_atom, mob_parent) > AI_ESCORTING_MAX_DISTANCE)
				look_for_next_node()
				return
			var/atom/next_target = get_nearest_target(escorted_atom, target_distance, TARGET_HOSTILE, mob_parent.faction)
			if(!next_target)
				return
			change_action(MOVING_TO_ATOM, next_target)
		if(MOVING_TO_NODE, FOLLOWING_PATH)
			var/atom/next_target = get_nearest_target(mob_parent, target_distance, TARGET_HOSTILE, mob_parent.faction)
			if(!next_target)
				if(can_heal && living_parent.health <= minimum_health * 2 * living_parent.maxHealth)
					try_to_heal() //If we have some damage, look for some healing
					return
				if(!goal_node) // We are randomly moving
					var/atom/mob_to_follow = get_nearest_target(mob_parent, AI_ESCORTING_MAX_DISTANCE, TARGET_FRIENDLY_MOB, mob_parent.faction)
					if(mob_to_follow)
						set_escorted_atom(null, mob_to_follow, TRUE)
						return
				return
			change_action(MOVING_TO_ATOM, next_target)
		if(MOVING_TO_ATOM)
			if(!weak_escort && escorted_atom && get_dist(escorted_atom, mob_parent) > target_distance)
				change_action(ESCORTING_ATOM, escorted_atom)
				return
			var/atom/next_target = get_nearest_target(mob_parent, target_distance, TARGET_HOSTILE, mob_parent.faction)
			if(!next_target)//We didn't find a target
				cleanup_current_action()
				late_initialize()
				return
			if(next_target == atom_to_walk_to)//We didn't find a better target
				return
			change_action(null, next_target)//We found a better target, change course!
		if(MOVING_TO_SAFETY)
			var/atom/next_target = get_nearest_target(escorted_atom, target_distance, TARGET_HOSTILE, mob_parent.faction)
			if(!next_target)//We are safe, try to find some weeds
				target_distance = initial(target_distance)
				cleanup_current_action()
				late_initialize()
				RegisterSignal(mob_parent, COMSIG_HUMAN_DAMAGE_TAKEN, PROC_REF(check_for_critical_health))
				return
			if(next_target == atom_to_walk_to)
				return
			change_action(null, next_target, INFINITY)
		if(IDLE)
			var/atom/next_target = get_nearest_target(escorted_atom, target_distance, TARGET_HOSTILE, mob_parent.faction)
			if(!next_target)
				return
			change_action(MOVING_TO_ATOM, next_target)

/datum/ai_behavior/human/deal_with_obstacle(datum/source, direction)
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
			if(!(obstacle.resistance_flags & INDESTRUCTIBLE)) //todo: do we need to check for obj_flags & CAN_BE_HIT ?
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
		if(obstacle.dir & direction && !(obstacle.resistance_flags & INDESTRUCTIBLE)) //todo: do we need to check for obj_flags & CAN_BE_HIT ?
			INVOKE_ASYNC(src, PROC_REF(attack_target), null, obstacle)
			return COMSIG_OBSTACLE_DEALT_WITH

/datum/ai_behavior/human/cleanup_current_action(next_action)
	. = ..()
	if(next_action == MOVING_TO_NODE)
		return
	if(!isxeno(mob_parent)) //todo
		return
	var/mob/living/living_mob = mob_parent
	if(can_heal && living_mob.resting)
		SEND_SIGNAL(mob_parent, COMSIG_XENOABILITY_REST)
		UnregisterSignal(mob_parent, COMSIG_XENOMORPH_HEALTH_REGEN)

/datum/ai_behavior/human/cleanup_signals()
	. = ..()
	UnregisterSignal(mob_parent, COMSIG_OBSTRUCTED_MOVE)
	UnregisterSignal(mob_parent, list(ACTION_GIVEN, ACTION_REMOVED))
	UnregisterSignal(mob_parent, COMSIG_HUMAN_DAMAGE_TAKEN)

///Signal handler to try to attack our target
/datum/ai_behavior/human/proc/attack_target(datum/source, atom/attacked)
	SIGNAL_HANDLER
	if(world.time < mob_parent.next_move)
		return
	if(!attacked)
		attacked = atom_to_walk_to
	if(get_dist(attacked, mob_parent) > 1)
		return
	mob_parent.face_atom(attacked)
	var/obj/item/item_in_hand = mob_parent.r_hand
	if(!item_in_hand || istype(item_in_hand, /obj/item/weapon/twohanded/offhand)) //todo:we can make this better
		item_in_hand = mob_parent.l_hand
	if(!item_in_hand)
		mob_parent.UnarmedAttack(attacked, TRUE)
		return
	INVOKE_ASYNC(item_in_hand, TYPE_PROC_REF(/obj/item, melee_attack_chain), mob_parent, attacked)

/datum/ai_behavior/human/register_action_signals(action_type)
	switch(action_type)
		if(MOVING_TO_ATOM)
			RegisterSignal(mob_parent, COMSIG_STATE_MAINTAINED_DISTANCE, PROC_REF(attack_target))
			if(ishuman(atom_to_walk_to))
				RegisterSignal(atom_to_walk_to, COMSIG_MOB_DEATH, TYPE_PROC_REF(/datum/ai_behavior, look_for_new_state))
				return
			if(ismachinery(atom_to_walk_to))
				RegisterSignal(atom_to_walk_to, COMSIG_PREQDELETED, TYPE_PROC_REF(/datum/ai_behavior, look_for_new_state))
				return

	return ..()

/datum/ai_behavior/human/unregister_action_signals(action_type)
	switch(action_type)
		if(MOVING_TO_ATOM)
			UnregisterSignal(mob_parent, COMSIG_STATE_MAINTAINED_DISTANCE)
			if(ishuman(atom_to_walk_to))
				UnregisterSignal(atom_to_walk_to, COMSIG_MOB_DEATH)
				return
			if(ismachinery(atom_to_walk_to))
				UnregisterSignal(atom_to_walk_to, COMSIG_PREQDELETED)
				return

	return ..()

///Will try finding and resting on weeds
/datum/ai_behavior/human/proc/try_to_heal()
	//var/mob/living/living_mob = mob_parent
	//todo: add some kitting/chem behavior or something
	//SEND_SIGNAL(mob_parent, COMSIG_XENOABILITY_REST)
	//RegisterSignal(mob_parent, COMSIG_XENOMORPH_HEALTH_REGEN, PROC_REF(check_for_health))
	//RegisterSignal(mob_parent, COMSIG_XENOMORPH_PLASMA_REGEN, PROC_REF(check_for_plasma))
	return TRUE

///Wait for the xeno to be full life and plasma to unrest
/datum/ai_behavior/human/proc/check_for_health(mob/living/carbon/xenomorph/healing, list/heal_data) //todo
	SIGNAL_HANDLER
	//insert health check stuff here
	//if(healing.health + heal_data[1] >= healing.maxHealth && healing.plasma_stored >= healing.xeno_caste.plasma_max * healing.xeno_caste.plasma_regen_limit)
	//	SEND_SIGNAL(mob_parent, COMSIG_XENOABILITY_REST)
	//	UnregisterSignal(mob_parent, list(COMSIG_XENOMORPH_HEALTH_REGEN, COMSIG_XENOMORPH_PLASMA_REGEN))

///Called each time the ai takes damage; if we are below a certain health threshold, try to retreat
/datum/ai_behavior/human/proc/check_for_critical_health(datum/source, damage)
	SIGNAL_HANDLER
	var/mob/living/living_mob = mob_parent
	if(!can_heal || living_mob.health - damage > minimum_health * living_mob.maxHealth)
		return
	var/atom/next_target = get_nearest_target(mob_parent, target_distance, TARGET_HOSTILE, mob_parent.faction)
	if(!next_target)
		return
	target_distance = 15
	change_action(MOVING_TO_SAFETY, next_target, INFINITY)
	UnregisterSignal(mob_parent, COMSIG_HUMAN_DAMAGE_TAKEN)

///Move the ai mob on top of the window_frame
/datum/ai_behavior/human/proc/climb_window_frame(turf/window_turf) //todo: add funny jump stuff
	mob_parent.loc = window_turf
	mob_parent.last_move_time = world.time
	LAZYDECREMENT(mob_parent.do_actions, window_turf)

/datum/ai_behavior/human/proc/fire_gun()
	///obj/item/weapon/gun/proc/start_fire

/datum/ai_behavior/human/ranged
	distance_to_maintain = 5
	minimum_health = 0.3

/datum/ai_behavior/human/suicidal
	minimum_health = 0

/mob/living/carbon/human/ai/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/human)

/mob/living/simple_animal/hostile/carp/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/human)
