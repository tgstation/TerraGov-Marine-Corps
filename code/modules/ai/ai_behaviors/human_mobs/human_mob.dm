//Generic template for application to a xeno/ mob, contains specific obstacle dealing alongside targeting only humans, xenos of a different hive and sentry turrets

/datum/ai_behavior/human
	sidestep_prob = 25
	identifier = IDENTIFIER_HUMAN
	base_action = ESCORTING_ATOM
	target_distance = 9
	minimum_health = 0 //test only
	//is_offered_on_creation = FALSE
	///List of abilities to consider doing every Process()
	var/list/ability_list = list()
	///If the mob parent can heal itself and so should flee
	var/can_heal = FALSE //for now

	var/obj/item/weapon/gun/gun

	var/obj/item/weapon/melee_weapon

	var/gun_firing = FALSE

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
	if(!gun)
		if(istype(mob_parent.r_hand, /obj/item/weapon/gun))
			gun = mob_parent.r_hand
		else if(istype(mob_parent.l_hand, /obj/item/weapon/gun))
			gun = mob_parent.l_hand
		else
			equip_weapon() //hacky, but works for now
		gun?.attack_self(mob_parent) //to wield. Surely this won't break anything???
	if(gun)
		//do gun stuff
		distance_to_maintain = 5
		check_gun_fire(atom_to_walk_to)
	else
		distance_to_maintain = 1 //maybe placeholder


	if(mob_parent.notransform) //todo: whydis?
		return ..()
	if(mob_parent.do_actions) //No activating more abilities if they're already in the progress of doing one
		return ..()

	for(var/datum/action/action in ability_list)
		if(!action.ai_should_use(atom_to_walk_to))
			continue
		//xeno_action/activable is activated with a different proc for keybinded actions, so we gotta use the correct proc
		if(istype(action, /datum/action/ability/activable)) //todo, for normal activatable actions
			var/datum/action/ability/activable/activable_action = action
			activable_action.use_ability(atom_to_walk_to)
		else
			action.action_activate()
	return ..()

/datum/ai_behavior/human/proc/equip_weapon() //unsafe atm, need to reg sigs for it being moved etc.
	var/obj/item/new_weapon = locate(/obj/item/weapon/gun) in mob_parent
	if(!new_weapon)
		new_weapon = locate(/obj/item/weapon) in mob_parent
	if(!new_weapon)
		return FALSE
	if((mob_parent.l_hand == new_weapon) || (mob_parent.r_hand == new_weapon))
		return TRUE
	if(!mob_parent.put_in_any_hand_if_possible(new_weapon))
		return FALSE
	if(istype(new_weapon, /obj/item/weapon/gun))
		gun = new_weapon
	else
		melee_weapon = new_weapon
	new_weapon.attack_self(mob_parent) //toggle on/wield/etc
	return TRUE


/datum/ai_behavior/human/proc/check_gun_fire(atom/target)
	if((gun.loc != mob_parent) || ((mob_parent.l_hand != gun) && (mob_parent.r_hand != gun)))
		gun = null
		gun_firing = FALSE
		return

	if(gun_firing)
		var/mob/living/living_target = target
		if(!target || (istype(living_target) && living_target.stat == DEAD))
			if(prob(75))
				mob_parent.say(pick("Target down.", "Hostile down.", "Scratch one.", "I got one!", "Down for the count.", "Kill confirmed."))
			stop_fire()
			return
		if(!length(gun.chamber_items) || !gun.get_current_rounds(gun.chamber_items[gun.current_chamber_position]))
			stop_fire()
			reload_gun()
			return
		if(get_dist(target, mob_parent) > (target_distance + 2))
			if(prob(50))
				mob_parent.say(pick("Target out of range.", "Out of range.", "I lost them.", "Where'd they go?", "They're running!"))
			stop_fire()
			return
		if(!line_of_sight(mob_parent, target))
			if(prob(50))
				mob_parent.say(pick("Target lost!", "Where'd they go?", "I lost sight of them!", "Where'd they go?", "They're running!", "Stop hiding!"))
			stop_fire()
			return
		return

	if(!target)
		//reload if low?
		return
	if(!isliving(target)) //placeholder
		return
	if(!length(gun.chamber_items) || !gun.get_current_rounds(gun.chamber_items[gun.current_chamber_position]))
		reload_gun()
		return
	if(get_dist(target, mob_parent) > target_distance) //placeholder range, will offscreen
		return
	//ammo_check?
	if(!line_of_sight(mob_parent, target))
		return
	if(prob(90))
		mob_parent.say(pick("Get some!!", "Engaging!", "Open fire!", "Firing!", "Hostiles!", "Take them out!", "Kill 'em!", "Lets rock!", "Fire!!", "Gun them down!", "Shooting!", "Weapons free!", "Fuck you!!"))
	gun.start_fire(mob_parent, target, get_turf(target))
	gun_firing = TRUE
	//gun.start_fire(datum/source, atom/object, turf/location, control, params, bypass_checks = FALSE)

/datum/ai_behavior/human/proc/stop_fire()
	gun.stop_fire()
	gun_firing = FALSE

/datum/ai_behavior/human/proc/reload_gun()
	if(prob(90))
		mob_parent.say(pick("Reloading!", "Cover me, reloading!", "Changing mag!", "Out of ammo!"))
	var/new_ammo = gun.default_ammo_type ? gun.default_ammo_type : gun.allowed_ammo_types[1]
	gun.reload(new new_ammo, mob_parent) //maybe add force = TRUE, if needed

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
	if(melee_weapon) //unsafe atm, need sigs for if its dropped
		INVOKE_ASYNC(item_in_hand, TYPE_PROC_REF(/obj/item, melee_attack_chain), mob_parent, attacked)
		return
	mob_parent.UnarmedAttack(attacked, TRUE)


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
	if(prob(50))
		mob_parent.say(pick("Healing, cover me!", "Healing over here.", "Where's the damn medic?", "Medic!", "Treating wounds.", "It's just a flesh wound.", "Need a little help here!", "Cover me!."))
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
	if(prob(50))
		mob_parent.say(pick("Falling back!", "Cover me, I'm hit!", "I'm hit!", "Medic!", "Disengaging!", "Help me!", "Need a little help here!", "Tactical withdrawal.", "Repositioning."))
	target_distance = 15
	change_action(MOVING_TO_SAFETY, next_target, INFINITY)
	UnregisterSignal(mob_parent, COMSIG_HUMAN_DAMAGE_TAKEN)

///Move the ai mob on top of the window_frame
/datum/ai_behavior/human/proc/climb_window_frame(turf/window_turf) //todo: add funny jump stuff
	mob_parent.loc = window_turf
	mob_parent.last_move_time = world.time
	LAZYDECREMENT(mob_parent.do_actions, window_turf)

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
