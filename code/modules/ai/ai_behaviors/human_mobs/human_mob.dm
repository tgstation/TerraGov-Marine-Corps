//Generic template for application to a xeno/ mob, contains specific obstacle dealing alongside targeting only humans, xenos of a different hive and sentry turrets
/*
*TODO: INVENTORY DATUM TO MAKE SORTED LIST OF WEAPONS, AMMO, MEDS, ETC.
		UPDATE SUBLISTS ONLY AS NEEDED
		I.E. REG NEW SIGS TO THEM WHEN ADDED TO LIST, TO CHECK ON MOVE/DESTROY/ETC

*TODO:	MAKE FACTIONS (and/or IFF) ATOM LEVEL, AND MAKE THEM BITFLAGS
		I.E. FACTION_SOM|FACTION_ICC
		I.E. FACTION_TGMC|FACTION_NT|FACTION_NEUTRAL
		I.E. FACTION_ICC|FACTION_SOM|FACTION_CLF
*/

/datum/ai_behavior/human
	sidestep_prob = 25
	identifier = IDENTIFIER_HUMAN
	base_action = ESCORTING_ATOM
	target_distance = 9
	minimum_health = 0.3 //placeholder value
	//is_offered_on_creation = FALSE
	///List of abilities to consider doing every Process()
	var/list/ability_list = list()
	///If the mob parent can heal itself and so should flee
	var/can_heal = TRUE //TURN OFF FOR CARP ETC

	var/uses_weapons = TRUE //test, this base type will be useful for mobs like carp, where this will be false

	var/datum/inventory/mob_inventory

/datum/ai_behavior/human/New(loc, parent_to_assign, escorted_atom, can_heal = TRUE)
	..()
	refresh_abilities()
	mob_parent.a_intent = INTENT_HARM //Killing time
	src.can_heal = can_heal

	mob_inventory = new(mob_parent)
	if(uses_weapons)
		RegisterSignals(mob_inventory, list(COMSIG_INVENTORY_DAT_GUN_ADDED, COMSIG_INVENTORY_DAT_MELEE_ADDED), PROC_REF(equip_weaponry)) //todo: this will spam if ai mobs are given loadouts instead of the other way around... but avoid that
		equip_weaponry()

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
	if(mob_parent.notransform)
		return ..()
	if(mob_parent.do_actions)
		return ..()

	for(var/datum/action/action in ability_list)
		if(!action.ai_should_use(atom_to_walk_to))
			continue
		//activable is activated with a different proc for keybinded actions, so we gotta use the correct proc
		if(istype(action, /datum/action/ability/activable))
			var/datum/action/ability/activable/activable_action = action
			activable_action.use_ability(atom_to_walk_to)
		else
			action.action_activate()

	if(uses_weapons)
		weapon_process()

	return ..()

/datum/ai_behavior/human/look_for_new_state()
	var/mob/living/living_parent = mob_parent
	switch(current_action)
		if(MOB_HEALING)
			return
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
					INVOKE_ASYNC(src, PROC_REF(try_heal))
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
		if(MOVING_TO_SAFETY) //todo: look at this and unfuck some of this behavior
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
	for(var/mob/mob_blocker in obstacle_turf.contents)
		if(!mob_blocker.density)
			continue
		//todo: passflag stuff etc
		return

	var/should_jump = FALSE
	var/mob/living/living_parent = mob_parent
	var/can_jump = living_parent.can_jump()
	for(var/obj/object in obstacle_turf.contents)
		if(!object.density)
			continue
		if(can_jump && object.is_jumpable(mob_parent))
			should_jump = TRUE
			continue
		if(isstructure(object))
			var/obj/structure/structure = object
			if(structure.climbable)
				INVOKE_ASYNC(structure, TYPE_PROC_REF(/obj/structure, do_climb), mob_parent)
				return COMSIG_OBSTACLE_DEALT_WITH
		if(istype(object, /obj/machinery/door/airlock))
			var/obj/machinery/door/airlock/lock = object
			if(lock.operating) //Airlock already doing something
				continue
			if(lock.welded || lock.locked) //It's welded or locked, can't force that open
				INVOKE_ASYNC(src, PROC_REF(attack_target), null, object) //ai is cheating
				return COMSIG_OBSTACLE_DEALT_WITH
			lock.open(TRUE)
			return COMSIG_OBSTACLE_DEALT_WITH
		if(!(object.resistance_flags & INDESTRUCTIBLE))
			INVOKE_ASYNC(src, PROC_REF(attack_target), null, object)
			return COMSIG_OBSTACLE_DEALT_WITH

	if(should_jump)
		SEND_SIGNAL(mob_parent, COMSIG_AI_JUMP)
		INVOKE_ASYNC(src, PROC_REF(ai_complete_move), direction, FALSE)
		return COMSIG_OBSTACLE_DEALT_WITH

	if(ISDIAGONALDIR(direction) && ((deal_with_obstacle(null, turn(direction, -45)) & COMSIG_OBSTACLE_DEALT_WITH) || (deal_with_obstacle(null, turn(direction, 45)) & COMSIG_OBSTACLE_DEALT_WITH)))
		return COMSIG_OBSTACLE_DEALT_WITH
	//Ok we found nothing, yet we are still blocked. Check for blockers on our current turf
	obstacle_turf = get_turf(mob_parent)
	for(var/obj/structure/obstacle in obstacle_turf.contents)
		if(!obstacle.density)
			continue
		if(!((obstacle.atom_flags & ON_BORDER) && (obstacle.dir & direction)))
			continue
		if(obstacle.is_jumpable(mob_parent))
			should_jump = TRUE
			continue
		if(!(obstacle.resistance_flags & INDESTRUCTIBLE)) //todo: do we need to check for obj_flags & CAN_BE_HIT ?
			INVOKE_ASYNC(src, PROC_REF(attack_target), null, obstacle)
			return COMSIG_OBSTACLE_DEALT_WITH

	//shitty dup code here for now
	if(should_jump)
		SEND_SIGNAL(mob_parent, COMSIG_AI_JUMP)
		INVOKE_ASYNC(src, PROC_REF(ai_complete_move), direction, FALSE)
		return COMSIG_OBSTACLE_DEALT_WITH

/datum/ai_behavior/human/cleanup_current_action(next_action)
	. = ..()
	if(next_action == MOVING_TO_NODE)
		return

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
	if(melee_weapon)
		INVOKE_ASYNC(melee_weapon, TYPE_PROC_REF(/obj/item, melee_attack_chain), mob_parent, attacked)
		return
	mob_parent.UnarmedAttack(attacked, TRUE)

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

/datum/ai_behavior/human/ranged
	distance_to_maintain = 5
	minimum_health = 0.3

/datum/ai_behavior/human/suicidal
	minimum_health = 0

//test stuff
/mob/living/proc/add_test_ai()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/human)

/mob/living/proc/add_test_ai_all()
	for(var/mob/living/carbon/human/human_mob AS in GLOB.alive_human_list)
		human_mob.AddComponent(/datum/component/ai_controller, /datum/ai_behavior/human)

/mob/living/carbon/human/ai/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/human)

/mob/living/simple_animal/hostile/carp/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/human)

//todo: move these

///Can this be jumped over
/atom/movable/proc/is_jumpable(mob/living/jumper)
	if(allow_pass_flags & (PASS_LOW_STRUCTURE|PASS_TANK))
		return TRUE

///Checks if this mob can jump
/mob/living/proc/can_jump()
	return SEND_SIGNAL(src, COMSIG_LIVING_CAN_JUMP)

//simple mob junk
/*
/mob/living/simple_animal/hostile/proc/MoveToTarget(list/possible_targets)//Step 5, handle movement between us and our target
	stop_automated_movement = TRUE
	if(!target || !CanAttack(target))
		LoseTarget()
		return FALSE
	if(target in possible_targets)
		var/turf/T = get_turf(src)
		if(target.z != T.z)
			LoseTarget()
			return FALSE
		var/target_distance = get_dist(targets_from,target)
		if(ranged) //We ranged? Shoot at em
			if(!target.Adjacent(targets_from) && ranged_cooldown <= world.time) //But make sure they're not in range for a melee attack and our range attack is off cooldown
				OpenFire(target)
		if(!Process_Spacemove()) //Drifting
			walk(src, 0)
			return TRUE
		if(retreat_distance != null) //If we have a retreat distance, check if we need to run from our target
			if(target_distance <= retreat_distance) //If target's closer than our retreat distance, run
				walk_away(src,target,retreat_distance,move_to_delay)
			else
				Goto(target,move_to_delay,minimum_distance) //Otherwise, get to our minimum distance so we chase them
		else
			Goto(target,move_to_delay,minimum_distance)
		if(target)
			if(targets_from && isturf(targets_from.loc) && target.Adjacent(targets_from)) //If they're next to us, attack
				MeleeAction()
			else
				if(rapid_melee > 1 && target_distance <= melee_queue_distance)
					MeleeAction(FALSE)
				in_melee = FALSE //If we're just preparing to strike do not enter sidestep mode
			return TRUE
		return FALSE

	if(wall_smash)
		if(target.loc != null && get_dist(targets_from, target.loc) <= vision_range) //We can't see our target, but he's in our vision range still
			if(ranged_ignores_vision && ranged_cooldown <= world.time) //we can't see our target... but we can fire at them!
				OpenFire(target)
				Goto(target,move_to_delay,minimum_distance)
				FindHidden()
				return TRUE
			else
				if(FindHidden())
					return TRUE
	LoseTarget()
	return FALSE

/mob/living/simple_animal/hostile/proc/OpenFire(atom/A)
	if(CheckFriendlyFire(A))
		return
	visible_message(span_danger("<b>[src]</b> [ranged_message] at [A]!"))


	if(rapid > 1)
		var/datum/callback/cb = CALLBACK(src, PROC_REF(Shoot), A)
		for(var/i in 1 to rapid)
			addtimer(cb, (i - 1)*rapid_fire_delay)
	else
		Shoot(A)
	ranged_cooldown = world.time + ranged_cooldown_time


/mob/living/simple_animal/hostile/proc/Shoot(atom/targeted_atom)
	if(QDELETED(targeted_atom) || targeted_atom == targets_from.loc || targeted_atom == targets_from)
		return
	var/turf/startloc = get_turf(targets_from)
	new casingtype(startloc)
	playsound(src, projectilesound, 100, 1)
	var/obj/projectile/P = new(startloc)
	playsound(src, projectilesound, 100, 1)
	P.generate_bullet(GLOB.ammo_list[ammotype])
	P.fire_at(targeted_atom, src, src)
*/

/*
for(var/mob/mob in turf)
	if(some_condition)
		return
for(var/obj/object in turf)
	if(some_other_condition)
		return
*/
