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
	var/medical_rating = AI_MED_DEFAULT
	///To what level they will handle engineering tasks like repairs
	var/engineer_rating = AI_ENGIE_DEFAULT
	///List of things the NPC will try to interact with, such as gear to pick up
	var/list/atom/atoms_of_interest = list()
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
	///General acknowledgement of receiving an order
	var/receive_order_chat = list("Understood.", "Moving.", "Moving out", "Got it.", "Right away.", "Roger", "You got it.", "On the move.", "Acknowledged.", "Affirmative.", "Who put you in charge?", "Ok.", "I got it sorted.", "On the double.",)
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
	. = ..()
	mob_inventory = new(mob_parent)
	RegisterSignal(mob_parent, COMSIG_MOB_DROPPING_ITEM, PROC_REF(on_item_unequip)) //we do this on New because we want to know about items lost when dead

/datum/ai_behavior/human/Destroy(force, ...)
	gun = null
	melee_weapon = null
	hazard_list = null
	heal_list = null
	atoms_of_interest = null
	QDEL_NULL(mob_inventory)
	return ..()

/datum/ai_behavior/human/register_action_signals(action_type)
	. = ..()
	switch(action_type)
		if(MOVING_TO_SAFETY)
			RegisterSignal(mob_parent, COMSIG_STATE_MAINTAINED_DISTANCE, PROC_REF(melee_interact))

/datum/ai_behavior/human/start_ai()
	. = ..()
	RegisterSignal(mob_parent, COMSIG_HUMAN_DAMAGE_TAKEN, PROC_REF(on_take_damage))
	RegisterSignal(mob_parent, COMSIG_AI_HEALING_MOB, PROC_REF(parent_being_healed))
	RegisterSignal(mob_parent, COMSIG_MOB_TOGGLEMOVEINTENT, PROC_REF(on_move_toggle))
	RegisterSignal(mob_parent, COMSIG_MOB_INTERACTION_DESIGNATED, PROC_REF(interaction_designated))

	RegisterSignal(SSdcs, COMSIG_GLOB_DESIGNATED_TARGET_SET, PROC_REF(interaction_designated))
	RegisterSignal(SSdcs, COMSIG_GLOB_MOB_ON_CRIT, PROC_REF(on_other_mob_crit))

	if(mob_parent?.skills?.getRating(SKILL_MEDICAL) >= SKILL_MEDICAL_PRACTICED) //placeholder setter. Some jobs have high med but aren't medics...
		medical_rating = AI_MED_MEDIC
		RegisterSignals(SSdcs, list(COMSIG_GLOB_AI_NEED_HEAL, COMSIG_GLOB_MOB_CALL_MEDIC), PROC_REF(mob_need_heal))
	if(mob_parent?.skills?.getRating(SKILL_CONSTRUCTION) >= SKILL_CONSTRUCTION_PLASTEEL) //placeholder setter. Some jobs have high construction but aren't engineers...
		engineer_rating = AI_ENGIE_STANDARD
		RegisterSignal(SSdcs, COMSIG_GLOB_HOLO_BUILD_INITIALIZED, PROC_REF(on_holo_build_init))
	if(human_ai_behavior_flags & HUMAN_AI_AVOID_HAZARDS)
		RegisterSignal(SSdcs, COMSIG_GLOB_AI_HAZARD_NOTIFIED, PROC_REF(add_hazard))
		RegisterSignal(mob_parent, COMSIG_MOVABLE_Z_CHANGED, (PROC_REF(on_change_z)))
	if(human_ai_behavior_flags & HUMAN_AI_USE_WEAPONS)
		RegisterSignals(mob_inventory, list(COMSIG_INVENTORY_DAT_GUN_ADDED, COMSIG_INVENTORY_DAT_MELEE_ADDED), PROC_REF(equip_weaponry))
		RegisterSignal(mob_parent, COMSIG_LIVING_SET_LYING_ANGLE, PROC_REF(equip_weaponry))
	if(human_ai_behavior_flags & HUMAN_AI_AUDIBLE_CONTROL)
		RegisterSignal(mob_parent, COMSIG_MOVABLE_HEAR, PROC_REF(recieve_message))

/datum/ai_behavior/human/cleanup_signals()
	UnregisterSignal(mob_parent, list(
		COMSIG_HUMAN_DAMAGE_TAKEN,
		COMSIG_LIVING_SET_LYING_ANGLE,
		COMSIG_MOVABLE_Z_CHANGED,
		COMSIG_MOVABLE_HEAR,
		COMSIG_AI_HEALING_MOB,
		COMSIG_MOB_TOGGLEMOVEINTENT,
		COMSIG_MOB_INTERACTION_DESIGNATED,
	))
	UnregisterSignal(mob_inventory, list(COMSIG_INVENTORY_DAT_GUN_ADDED, COMSIG_INVENTORY_DAT_MELEE_ADDED))
	UnregisterSignal(SSdcs, list(COMSIG_GLOB_AI_HAZARD_NOTIFIED, COMSIG_GLOB_MOB_ON_CRIT, COMSIG_GLOB_AI_NEED_HEAL, COMSIG_GLOB_MOB_CALL_MEDIC, COMSIG_GLOB_DESIGNATED_TARGET_SET, COMSIG_GLOB_HOLO_BUILD_INITIALIZED))
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

	if((engineer_rating >= AI_ENGIE_STANDARD) && engineer_process())
		return

	if((human_parent.nutrition <= NUTRITION_HUNGRY) && length(mob_inventory.food_list))
		var/datum/reagent/consumable/nutriment/mob_nutriment = human_parent.reagents.get_reagent(/datum/reagent/consumable/nutriment)
		if(!mob_nutriment || (human_parent.nutrition + mob_nutriment.get_nutrition_gain()) < NUTRITION_OVERFED)
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
		if(!grenade_process())
			weapon_process()

	if(!combat_target && !interact_target && length(atoms_to_interact) && isturf(atoms_to_interact[1].loc))
		for(var/atom/atom AS in atoms_to_interact)
			if(atom.z != mob_parent.z)
				continue
			if(!isturf(atoms_to_interact[1].loc))
				return
			if(get_dist(mob_parent, atom) > AI_ESCORTING_BREAK_DISTANCE)
				continue
			set_interact_target(atom)

/datum/ai_behavior/human/should_hold()
	if(human_ai_state_flags & HUMAN_AI_BUSY_ACTION && COOLDOWN_FINISHED(src, ai_heal_after_dam_cooldown)) //Don't just stand there when taking damage
		return TRUE
	if(HAS_TRAIT(mob_parent, TRAIT_IS_RELOADING))
		return TRUE
	if(HAS_TRAIT(mob_parent, TRAIT_IS_CLIMBING))
		return TRUE
	if(HAS_TRAIT(mob_parent, TRAIT_IS_SHRAP_REMOVING))
		return TRUE
	if(HAS_TRAIT(mob_parent, TRAIT_IS_EQUIPPING_ITEM))
		return TRUE
	if(mob_parent.pulledby?.faction == mob_parent.faction)
		return TRUE //lets players wrangle NPC's
	return FALSE

/datum/ai_behavior/human/scheduled_move()
	if(human_ai_state_flags & HUMAN_AI_BUSY_ACTION)
		registered_for_move = FALSE
		return
	return ..()

/datum/ai_behavior/human/change_action(next_action, atom/next_target, list/special_distance_to_maintain)
	. = ..()
	if(!.)
		return
	if(human_ai_state_flags & HUMAN_AI_BUSY_ACTION)
		mob_parent.a_intent = INTENT_HELP

/datum/ai_behavior/human/look_for_new_state(atom/next_target)
	if(human_ai_state_flags & HUMAN_AI_BUSY_ACTION)
		return
	. = ..()
	if(current_action == MOVING_TO_ATOM && escorted_atom && (atom_to_walk_to != escorted_atom) && get_dist(mob_parent, escorted_atom) > AI_ESCORTING_MAX_DISTANCE)
		change_action(ESCORTING_ATOM, escorted_atom)
		return
	if(current_action == MOVING_TO_SAFETY && (COOLDOWN_FINISHED(src, ai_retreat_cooldown) || !combat_target)) //we retreat until we cant see hostiles or we max out the timer
		target_distance = initial(target_distance)
		change_action(ESCORTING_ATOM, escorted_atom)

/datum/ai_behavior/human/need_new_combat_target()
	. = ..()
	if(.)
		return
	if(non_aggressive)
		return FALSE
	if(get_dist(mob_parent, combat_target) <= AI_COMBAT_TARGET_BLIND_DISTANCE)
		return FALSE
	if(!line_of_sight(mob_parent, combat_target, target_distance))
		return TRUE

/datum/ai_behavior/human/state_process(atom/next_target)
	if(human_ai_state_flags & HUMAN_AI_BUSY_ACTION)
		return
	if((current_action == MOVING_TO_ATOM) && (atom_to_walk_to == combat_target))
		return //we generally want to keep fighting
	if((human_ai_behavior_flags & HUMAN_AI_SELF_HEAL) && !next_target && (mob_parent.health <= minimum_health * 2 * mob_parent.maxHealth) && check_hazards())
		INVOKE_ASYNC(src, PROC_REF(try_heal))

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
	INVOKE_ASYNC(src, PROC_REF(weapon_process))

/datum/ai_behavior/human/do_unset_target(atom/old_target, need_new_state = TRUE, need_new_escort = TRUE)
	if(combat_target == old_target && (human_ai_state_flags & HUMAN_AI_FIRING))
		stop_fire()
	remove_atom_of_interest(old_target)

	if(QDELETED(old_target)) //if they're deleted we need to ensure engineering and medical stuff is cleaned up properly
		if(human_ai_state_flags & HUMAN_AI_HEALING)
			on_heal_end(old_target)
		else
			remove_from_heal_list(old_target)
		if(human_ai_state_flags & HUMAN_AI_BUILDING)
			on_engineering_end(old_target)
		else
			remove_from_engineering_list(old_target)
		return ..()

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

///Says an audible message
/datum/ai_behavior/human/proc/try_speak(message, cooldown = 2 SECONDS)
	if(mob_parent.incapacitated())
		return
	if(!COOLDOWN_FINISHED(src, ai_chat_cooldown))
		return
	//maybe radio arg in the future for some things
	INVOKE_ASYNC(mob_parent, TYPE_PROC_REF(/atom/movable, say), message)
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
		if((human_ai_state_flags & HUMAN_AI_BUSY_ACTION)) //dont just stand there
			human_ai_state_flags &= ~(HUMAN_AI_BUSY_ACTION)
			late_initialize()
		if(((current_action == MOVING_TO_SAFETY) || !combat_target) && (attacker.faction != mob_parent.faction))
			set_combat_target(attacker)
			return

	//if we are fighting, but at low health and with no other urgent priorities, we run for it.

	if(!(human_ai_behavior_flags & HUMAN_AI_SELF_HEAL))
		return
	if((human_ai_state_flags & HUMAN_AI_BUSY_ACTION))
		return

	if(mob_parent.health - damage > minimum_health * mob_parent.maxHealth)
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

/**
 * Does all the setup to equip and use a tool by an NPC
 * new_tool can either be the tool itself, or a tool define to find a type of tool in the NPC's inventory
 */

/datum/ai_behavior/human/proc/equip_tool(new_tool)
	var/obj/item/equip_tool
	if(isitem(new_tool))
		equip_tool = new_tool
	else
		equip_tool = mob_inventory.find_tool(new_tool)
	if(!equip_tool)
		return
	pick_up_item(equip_tool)
	equip_tool.ai_use(user = mob_parent)
	mob_parent.a_intent = INTENT_HELP
	return equip_tool

///Stores a tool and resets intent
/datum/ai_behavior/human/proc/store_tool(old_tool)
	mob_parent.a_intent = INTENT_HARM
	if(iswelder(old_tool))
		var/obj/item/tool/weldingtool/welder = old_tool
		if(welder.isOn())
			welder.toggle()
		var/mob/living/carbon/human/human_owner = mob_parent
		if(welder.get_fuel() < welder.max_fuel && human_owner?.back?.reagents?.get_reagent_amount(/datum/reagent/fuel))
			human_owner.back.attackby(welder, human_owner)
	try_store_item(old_tool)

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

/datum/ai_behavior/human/monkey
	human_ai_behavior_flags = HUMAN_AI_NO_FF|HUMAN_AI_AVOID_HAZARDS
	///Flags about what the AI is current doing or wanting
	human_ai_state_flags = 0
	///To what level they will handle healing others
	medical_rating = AI_MED_SELFISH
	non_aggressive = TRUE
