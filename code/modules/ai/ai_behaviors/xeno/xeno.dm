//Generic template for application to a xeno/ mob, contains specific obstacle dealing alongside targeting only humans, xenos of a different hive and sentry turrets

/datum/ai_behavior/xeno
	sidestep_prob = 25
	identifier = IDENTIFIER_XENO
	is_offered_on_creation = TRUE
	///If the mob parent can heal itself and so should flee
	var/can_heal = TRUE

/datum/ai_behavior/xeno/start_ai()
	RegisterSignal(mob_parent, COMSIG_XENOMORPH_TAKING_DAMAGE, PROC_REF(check_for_critical_health))
	RegisterSignal(SSdcs, COMSIG_GLOB_AI_MINION_RALLY, PROC_REF(global_set_escorted_atom))
	return ..()

///Change atom to walk to if the order comes from a corresponding commander
/datum/ai_behavior/xeno/proc/global_set_escorted_atom(datum/source, atom/atom_to_escort)
	SIGNAL_HANDLER
	if(QDELETED(atom_to_escort) || atom_to_escort.get_xeno_hivenumber() != mob_parent.get_xeno_hivenumber() || mob_parent.ckey)
		return
	if(get_dist(atom_to_escort, mob_parent) > target_distance)
		return
	set_escorted_atom(source, atom_to_escort)

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
		if(istype(action, /datum/action/ability/activable/xeno))
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

/datum/ai_behavior/xeno/look_for_new_state(atom/next_target)
	. = ..()
	if(current_action == MOVING_TO_ATOM)
		if(!combat_target)
			if(escorted_atom)
				change_action(ESCORTING_ATOM, escorted_atom)
				return
			cleanup_current_action()
			late_initialize()
	if(current_action == MOVING_TO_SAFETY)
		if(!combat_target)
			target_distance = initial(target_distance)
			cleanup_current_action()
			late_initialize()
			RegisterSignal(mob_parent, COMSIG_XENOMORPH_TAKING_DAMAGE, PROC_REF(check_for_critical_health))
			return
		if(combat_target != atom_to_walk_to)
			change_action(null, combat_target, list(INFINITY))

/datum/ai_behavior/xeno/need_new_combat_target()
	. = ..()
	if(.)
		return
	if(get_dist(mob_parent, combat_target) > target_distance)
		return TRUE

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
	UnregisterSignal(mob_parent, COMSIG_XENOMORPH_TAKING_DAMAGE)
	UnregisterSignal(SSdcs, COMSIG_GLOB_AI_MINION_RALLY)

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

/datum/ai_behavior/xeno/ranged
	upper_maintain_dist = 5
	lower_maintain_dist = 5
	minimum_health = 0.3

/datum/ai_behavior/xeno/suicidal
	minimum_health = 0
