/datum/ai_behavior/human
	sidestep_prob = 25
	identifier = IDENTIFIER_HUMAN
	base_action = ESCORTING_ATOM
	upper_maintain_dist = 1
	lower_maintain_dist = 1
	target_distance = 9
	minimum_health = 0.3
	///Flags that dictate this AI's behavior
	var/human_ai_behavior_flags = HUMAN_AI_SELF_HEAL|HUMAN_AI_USE_WEAPONS|HUMAN_AI_NO_FF|HUMAN_AI_AVOID_HAZARDS
	///Flags about what the AI is current doing or wanting
	var/human_ai_state_flags = HUMAN_AI_NEED_WEAPONS
	///To what level they will handle healing others
	var/medical_rating = AI_MED_STANDARD
	///List of abilities to consider doing every Process()
	var/list/ability_list = list()
	///Inventory datum so the mob_parent can manage its inventory
	var/datum/managed_inventory/mob_inventory
	///Chat lines when moving to a new target
	var/list/new_move_chat = list("Moving.", "On the way.", "Moving out.", "On the move.", "Changing position.", "Watch your spacing!", "Let's move.", "Move out!", "Go go go!!", "moving.", "Mobilising.", "Hoofing it.")
	///Chat lines when following a new target
	var/list/new_follow_chat = list("Following.", "Following you.", "I got your back!", "Take the lead.", "Let's move!", "Let's go!", "Group up!.", "In formation.", "Where to?",)
	///Chat lines when engaging a new target
	var/list/new_target_chat = list("Get some!!", "Engaging!", "You're mine!", "Bring it on!", "Hostiles!", "Take them out!", "Kill 'em!", "Lets rock!", "Go go go!!", "Waste 'em!", "Intercepting.", "Weapons free!", "Fuck you!!", "Moving in!")
	///Chat lines for retreating on low health
	var/list/retreating_chat = list("Falling back!", "Cover me, I'm hit!", "I'm hit!", "Cover me!", "Disengaging!", "Help me!", "Need a little help here!", "Tactical withdrawal.", "Repositioning.", "Taking fire!", "Taking heavy fire!", "Run for it!")
	///Cooldown on chat lines, to reduce spam
	COOLDOWN_DECLARE(ai_chat_cooldown)
	///Cooldown on running, so we can recover stam and make the most of it
	COOLDOWN_DECLARE(ai_run_cooldown)
	///Cooldown on taking any damage (this could include DOT etc)
	COOLDOWN_DECLARE(ai_damage_cooldown)
	///Cooldown on being attacked by something with a source, so we don't try heal right next to enemies
	COOLDOWN_DECLARE(ai_heal_after_dam_cooldown)
	///Cooldown on retreating, so we don't get stuck running forever if pursued
	COOLDOWN_DECLARE(ai_retreat_cooldown)

/datum/ai_behavior/human/New(loc, mob/parent_to_assign, atom/escorted_atom)
	..()
	refresh_abilities()
	mob_parent.a_intent = INTENT_HARM
	mob_inventory = new(mob_parent)

/datum/ai_behavior/human/Destroy(force, ...)
	gun = null
	melee_weapon = null
	hazard_list = null
	heal_list = null
	QDEL_NULL(mob_inventory)
	return ..()

/datum/ai_behavior/human/start_ai()
	RegisterSignal(mob_parent, COMSIG_OBSTRUCTED_MOVE, TYPE_PROC_REF(/datum/ai_behavior, deal_with_obstacle))
	RegisterSignals(mob_parent, list(ACTION_GIVEN, ACTION_REMOVED), PROC_REF(refresh_abilities))
	RegisterSignal(mob_parent, COMSIG_HUMAN_DAMAGE_TAKEN, PROC_REF(on_take_damage))
	RegisterSignal(mob_parent, COMSIG_AI_HEALING_MOB, PROC_REF(parent_being_healed))
	RegisterSignal(mob_parent, COMSIG_MOB_TOGGLEMOVEINTENT, PROC_REF(on_move_toggle))
	RegisterSignal(SSdcs, COMSIG_GLOB_MOB_ON_CRIT, PROC_REF(on_other_mob_crit))
	if(mob_parent?.skills?.getRating(SKILL_MEDICAL) >= SKILL_MEDICAL_PRACTICED) //placeholder setter. Some jobs have high med but aren't medics...
		medical_rating = AI_MED_MEDIC
		RegisterSignals(SSdcs, list(COMSIG_GLOB_AI_NEED_HEAL, COMSIG_GLOB_MOB_CALL_MEDIC), PROC_REF(mob_need_heal))
	if(human_ai_behavior_flags & HUMAN_AI_AVOID_HAZARDS)
		RegisterSignal(SSdcs, COMSIG_GLOB_AI_HAZARD_NOTIFIED, PROC_REF(add_hazard))
		RegisterSignal(mob_parent, COMSIG_MOVABLE_Z_CHANGED, (PROC_REF(on_change_z)))
	if(human_ai_behavior_flags & HUMAN_AI_USE_WEAPONS)
		RegisterSignals(mob_inventory, list(COMSIG_INVENTORY_DAT_GUN_ADDED, COMSIG_INVENTORY_DAT_MELEE_ADDED), PROC_REF(equip_weaponry))
		RegisterSignal(mob_parent, COMSIG_LIVING_SET_LYING_ANGLE, PROC_REF(equip_weaponry))
		equip_weaponry()
	if(human_ai_behavior_flags & HUMAN_AI_AUDIBLE_CONTROL)
		RegisterSignal(mob_parent, COMSIG_MOVABLE_HEAR, PROC_REF(recieve_message))
	return ..()

/datum/ai_behavior/human/cleanup_signals()
	UnregisterSignal(mob_parent, list(
		COMSIG_OBSTRUCTED_MOVE,
		ACTION_GIVEN,
		ACTION_REMOVED,
		COMSIG_HUMAN_DAMAGE_TAKEN,
		COMSIG_LIVING_SET_LYING_ANGLE,
		COMSIG_MOVABLE_Z_CHANGED,
		COMSIG_MOVABLE_HEAR,
		COMSIG_AI_HEALING_MOB,
		COMSIG_MOB_TOGGLEMOVEINTENT,
	))
	UnregisterSignal(mob_inventory, list(COMSIG_INVENTORY_DAT_GUN_ADDED, COMSIG_INVENTORY_DAT_MELEE_ADDED))
	UnregisterSignal(SSdcs, list(COMSIG_GLOB_AI_HAZARD_NOTIFIED, COMSIG_GLOB_MOB_ON_CRIT, COMSIG_GLOB_AI_NEED_HEAL, COMSIG_GLOB_MOB_CALL_MEDIC))
	return ..()

/datum/ai_behavior/human/process()
	if(should_hold())
		return
	if(mob_parent.notransform)
		return ..()

	var/mob/living/carbon/human/human_parent = mob_parent
	if(human_parent.lying_angle)
		INVOKE_ASYNC(human_parent, TYPE_PROC_REF(/mob/living/carbon/human, get_up))
		return

	if((medical_rating >= AI_MED_MEDIC) && medic_process())
		return

	if((human_parent.nutrition <= NUTRITION_HUNGRY) && length(mob_inventory.food_list) && (human_parent.nutrition + (37.5 * human_parent.reagents.get_reagent_amount(/datum/reagent/consumable/nutriment)) < NUTRITION_WELLFED))
		for(var/obj/item/reagent_containers/food/food AS in mob_inventory.food_list)
			if(!food.ai_should_use(human_parent))
				continue
			food.ai_use(human_parent, human_parent)
			break

	if(mob_parent.buckled && !mob_parent.buckled.ai_should_stay_buckled(mob_parent))
		mob_parent.buckled.unbuckle_mob(mob_parent)

	. = ..()

	for(var/datum/action/action in ability_list)
		if(!action.ai_should_use(atom_to_walk_to)) //todo: some of these probably should be aimmed at combat_target somehow...
			continue
		if(istype(action, /datum/action/ability/activable))
			var/datum/action/ability/activable/activable_action = action
			activable_action.use_ability(atom_to_walk_to)
		else
			action.action_activate()

	if(human_ai_behavior_flags & HUMAN_AI_USE_WEAPONS)
		if(grenade_process())
			return
		weapon_process()

/datum/ai_behavior/human/should_hold()
	if(human_ai_state_flags & HUMAN_AI_ANY_HEALING)
		return TRUE
	if(HAS_TRAIT(mob_parent, TRAIT_IS_RELOADING))
		return TRUE
	if(HAS_TRAIT(mob_parent, TRAIT_IS_CLIMBING))
		return TRUE
	if(mob_parent.pulledby?.faction == mob_parent.faction)
		return TRUE //lets players wrangle NPC's
	return FALSE

/datum/ai_behavior/human/scheduled_move()
	if(human_ai_state_flags & HUMAN_AI_ANY_HEALING)
		registered_for_move = FALSE
		return
	return ..()

/datum/ai_behavior/human/register_action_signals(action_type)
	switch(action_type)
		if(MOVING_TO_ATOM)
			RegisterSignal(mob_parent, COMSIG_STATE_MAINTAINED_DISTANCE, PROC_REF(melee_interact))
	return ..()

/datum/ai_behavior/human/change_action(next_action, atom/next_target, list/special_distance_to_maintain)
	. = ..()
	if(!.)
		return
	if(human_ai_state_flags & HUMAN_AI_ANY_HEALING)
		mob_parent.a_intent = INTENT_HELP

/datum/ai_behavior/human/look_for_new_state(atom/next_target)
	if(human_ai_state_flags & HUMAN_AI_ANY_HEALING)
		return
	if(!combat_target || ((get_dist(mob_parent, combat_target) > AI_COMBAT_TARGET_BLIND_DISTANCE) && !line_of_sight(mob_parent, combat_target, target_distance)))
		if(combat_target)
			do_unset_target(combat_target, need_new_state = FALSE)
		if(next_target) //standing orders, kill hostiles on sight.
			set_combat_target(next_target)
			if(current_action != MOVING_TO_SAFETY)
				change_action(MOVING_TO_ATOM, next_target)
			return

	switch(current_action)
		if(MOVING_TO_ATOM)
			if(!atom_to_walk_to)
				change_action(ESCORTING_ATOM, escorted_atom)
			if(escorted_atom && (atom_to_walk_to != escorted_atom) && get_dist(mob_parent, escorted_atom) > AI_ESCORTING_MAX_DISTANCE)
				change_action(ESCORTING_ATOM, escorted_atom)
		if(ESCORTING_ATOM)
			if(get_dist(escorted_atom, mob_parent) > AI_ESCORTING_MAX_DISTANCE)
				look_for_next_node(FALSE)
		if(MOVING_TO_SAFETY)
			if((COOLDOWN_FINISHED(src, ai_retreat_cooldown) || !combat_target)) //we retreat until we cant see hostiles or we max out the timer
				target_distance = initial(target_distance)
				change_action(ESCORTING_ATOM, escorted_atom)

/datum/ai_behavior/human/state_process(atom/next_target)
	if(human_ai_state_flags & HUMAN_AI_ANY_HEALING)
		return
	if((current_action == MOVING_TO_ATOM) && (atom_to_walk_to == combat_target))
		return //we generally want to keep fighting
	var/mob/living/living_parent = mob_parent
	if((human_ai_behavior_flags & HUMAN_AI_SELF_HEAL) && (living_parent.health <= minimum_health * 2 * living_parent.maxHealth) && check_hazards())
		INVOKE_ASYNC(src, PROC_REF(try_heal))

/datum/ai_behavior/human/deal_with_obstacle(datum/source, direction)
	var/turf/obstacle_turf = get_step(mob_parent, direction)

	for(var/mob/mob_blocker in obstacle_turf.contents)
		if(!mob_blocker.density)
			continue
		//todo: passflag stuff etc
		return

	var/should_jump = FALSE
	for(var/obj/object in obstacle_turf)
		if(!object.density)
			continue
		var/obstacle_reaction = object.ai_handle_obstacle(mob_parent, direction)
		if(obstacle_reaction == AI_OBSTACLE_RESOLVED)
			return COMSIG_OBSTACLE_DEALT_WITH //we've dealt with it on the obstacle side
		if(obstacle_reaction == AI_OBSTACLE_JUMP)
			should_jump = TRUE //we will try jump if the only obstacles are all jumpable
			continue
		if(obstacle_reaction == AI_OBSTACLE_ATTACK)
			INVOKE_ASYNC(src, PROC_REF(melee_interact), null, object)
			return COMSIG_OBSTACLE_DEALT_WITH //we gotta hit it


	if(should_jump)
		SEND_SIGNAL(mob_parent, COMSIG_AI_JUMP)
		INVOKE_ASYNC(src, PROC_REF(ai_complete_move), direction, FALSE)
		return COMSIG_OBSTACLE_DEALT_WITH

	if(ISDIAGONALDIR(direction) && ((deal_with_obstacle(null, turn(direction, -45)) & COMSIG_OBSTACLE_DEALT_WITH) || (deal_with_obstacle(null, turn(direction, 45)) & COMSIG_OBSTACLE_DEALT_WITH)))
		return COMSIG_OBSTACLE_DEALT_WITH

	//Ok we found nothing, yet we are still blocked. Check for blockers on our current turf
	for(var/obj/obstacle in get_turf(mob_parent))
		if(!obstacle.density)
			continue
		var/obstacle_reaction = obstacle.ai_handle_obstacle(mob_parent, direction)
		if(obstacle_reaction == AI_OBSTACLE_RESOLVED)
			return COMSIG_OBSTACLE_DEALT_WITH
		if(obstacle_reaction == AI_OBSTACLE_JUMP)
			should_jump = TRUE
			continue
		if(obstacle_reaction == AI_OBSTACLE_ATTACK)
			INVOKE_ASYNC(src, PROC_REF(melee_interact), null, obstacle)
			return COMSIG_OBSTACLE_DEALT_WITH

	if(should_jump)
		SEND_SIGNAL(mob_parent, COMSIG_AI_JUMP)
		INVOKE_ASYNC(src, PROC_REF(ai_complete_move), direction, FALSE)
		return COMSIG_OBSTACLE_DEALT_WITH

	//We do this last because there could be other stuff blocking us from even reaching the turf
	if(istype(obstacle_turf, /turf/closed/wall/resin))
		INVOKE_ASYNC(src, PROC_REF(melee_interact), null, obstacle_turf)
		return COMSIG_OBSTACLE_DEALT_WITH

/datum/ai_behavior/human/set_goal_node(datum/source, obj/effect/ai_node/new_goal_node)
	. = ..()
	if(!.)
		return
	if(prob(50))
		try_speak(pick(new_move_chat))
	set_run()

/datum/ai_behavior/human/set_escorted_atom(datum/source, atom/atom_to_escort, new_escort_is_weak)
	. = ..()
	if(!.)
		return
	if(prob(50) && isliving(escorted_atom))
		try_speak(pick(new_follow_chat))
	set_run()

/datum/ai_behavior/human/set_combat_target(atom/new_target)
	. = ..()
	if(!.)
		return
	if(prob(50))
		try_speak(pick(new_target_chat))
	set_run()
	if(gun)
		INVOKE_ASYNC(src, PROC_REF(weapon_process), combat_target)

/datum/ai_behavior/human/do_unset_target(atom/old_target, need_new_state = TRUE)
	if(combat_target == old_target && (human_ai_state_flags & HUMAN_AI_FIRING))
		stop_fire()
	var/revive_target = FALSE
	if((medical_rating >= AI_MED_MEDIC) && (old_target in heal_list))
		var/mob/living/living_target = old_target
		if(living_target.stat == DEAD) //medics keep them on the list
			revive_target = TRUE
		else
			remove_from_heal_list(old_target)
	else
		remove_from_heal_list(old_target)
	if((human_ai_state_flags & HUMAN_AI_HEALING) && !revive_target)
		on_heal_end(old_target)
	return ..()

///Sets run move intent if able
/datum/ai_behavior/human/proc/set_run(forced = FALSE)
	if(!forced && !COOLDOWN_FINISHED(src, ai_run_cooldown))
		return
	mob_parent.toggle_move_intent(MOVE_INTENT_RUN)

///Sets behavior on move toggle
/datum/ai_behavior/human/proc/on_move_toggle(datum/source, m_intent)
	SIGNAL_HANDLER
	if(m_intent == MOVE_INTENT_WALK)
		COOLDOWN_START(src, ai_run_cooldown, 10 SECONDS) //give time for stam to regen

///Refresh abilities-to-consider list
/datum/ai_behavior/human/proc/refresh_abilities()
	SIGNAL_HANDLER
	ability_list = list()
	for(var/datum/action/action AS in mob_parent.actions)
		if(action.ai_should_start_consider())
			ability_list += action

///Sig handler for physical interactions, like attacks
/datum/ai_behavior/human/proc/melee_interact(datum/source, atom/interactee)
	SIGNAL_HANDLER
	if(mob_parent.next_move > world.time)
		return
	if(!interactee)
		interactee = atom_to_walk_to //this seems like it should be combat_target, but the only time this should come up is if combat_target IS atom_to_walk_to
	if(!mob_parent.CanReach(interactee, melee_weapon)) //todo: copy this for beno code, lots of other stuff too.
		return

	mob_parent.face_atom(interactee)

	if(interactee == interact_target)
		unset_target(interactee)
		if(isturf(interactee.loc)) //no pickpocketing
			. = try_interact(interactee)
		return

	if(melee_weapon)
		INVOKE_ASYNC(melee_weapon, TYPE_PROC_REF(/obj/item, melee_attack_chain), mob_parent, interactee)
		return TRUE
	mob_parent.UnarmedAttack(interactee, TRUE)
	return TRUE

///Tries to interact with something, usually nonharmfully
/datum/ai_behavior/human/proc/try_interact(atom/interactee)
	if(ishuman(interactee))
		var/mob/living/carbon/human/human = interactee
		if(mob_parent.faction != human.faction)
			return
		INVOKE_ASYNC(src, PROC_REF(try_heal_other), human)
		return TRUE
	interactee.do_ai_interact(mob_parent)
	return TRUE

///Says an audible message
/datum/ai_behavior/human/proc/try_speak(message, cooldown = 2 SECONDS)
	if(mob_parent.incapacitated())
		return
	if(!COOLDOWN_FINISHED(src, ai_chat_cooldown))
		return
	//maybe radio arg in the future for some things
	mob_parent.say(message)
	COOLDOWN_START(src, ai_chat_cooldown, cooldown)

///Reacts if the mob is below the min health threshold
/datum/ai_behavior/human/proc/on_take_damage(datum/source, damage, mob/attacker)
	SIGNAL_HANDLER
	if(damage < 5) //Don't want chip damage causing a retreat
		return
	if(!COOLDOWN_FINISHED(src, ai_damage_cooldown)) //sanity check since damage can occur very frequently, and makes the NPC less likely to instantly run when they get low
		return
	COOLDOWN_START(src, ai_damage_cooldown, 1 SECONDS)

	if(attacker) //if there is an attacker, our main priority is to react to it
		COOLDOWN_START(src, ai_heal_after_dam_cooldown, 4 SECONDS)
		if((human_ai_state_flags & HUMAN_AI_ANY_HEALING)) //dont just stand there
			human_ai_state_flags &= ~(HUMAN_AI_ANY_HEALING)
			late_initialize()
		if(((current_action == MOVING_TO_SAFETY) || !combat_target) && (attacker.faction != mob_parent.faction))
			set_combat_target(attacker)
			return

	//if we are fighting, but at low health and with no other urgent priorities, we run for it.

	if(!(human_ai_behavior_flags & HUMAN_AI_SELF_HEAL))
		return
	if((human_ai_state_flags & HUMAN_AI_ANY_HEALING))
		return

	var/mob/living/living_mob = mob_parent
	if(living_mob.health - damage > minimum_health * living_mob.maxHealth)
		return
	if(mob_parent.incapacitated() || mob_parent.lying_angle)
		return
	if(!check_hazards())
		return

	var/atom/next_target = combat_target ? combat_target : get_nearest_target(mob_parent, target_distance, TARGET_HOSTILE, mob_parent.faction, need_los = TRUE)
	if(!next_target)
		return

	if(prob(50))
		try_speak(pick(retreating_chat))
	set_run(TRUE)
	target_distance = 12
	COOLDOWN_START(src, ai_retreat_cooldown, 8 SECONDS)
	change_action(MOVING_TO_SAFETY, next_target, list(INFINITY)) //fallback

///Tries to store an item
/datum/ai_behavior/human/proc/try_store_item(obj/item/item)
	if(istype(item, /obj/item/weapon/twohanded/offhand))
		qdel(item)
		return FALSE
	if(!mob_parent.equip_to_appropriate_slot(item))
		return FALSE
	return TRUE

///Tries to store any items in hand
/datum/ai_behavior/human/proc/store_hands()
	if(mob_parent.l_hand)
		try_store_item(mob_parent.l_hand)
	if(mob_parent.r_hand)
		try_store_item(mob_parent.r_hand)

///Reacts to a heard message
/datum/ai_behavior/human/proc/recieve_message(atom/source, message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, message_mode)
	SIGNAL_HANDLER
	//todo: audible commands, gooooo
	return

/datum/ai_behavior/human/suicidal
	minimum_health = 0
