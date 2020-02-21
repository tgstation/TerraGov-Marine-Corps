//A generic mind for a carbon; currently has attacking, obstacle dealing and ability activation capabilities

/datum/element/ai_behavior/carbon

	var/list/attack_ranges = list() //How far away we gotta be before considering an attack
	var/list/ability_lists = list() //List of abilities to consider doing

/datum/element/ai_behavior/carbon/New()
	. = ..()
	START_PROCESSING(SSobj, src) //Probably every two seconds

/datum/element/ai_behavior/carbon/Attach(datum/target, distance_to_maintain = 1, sidestep_prob = 0, attack_range = 1)
	. = ..()
	RegisterSignal(target, COMSIG_OBSTRUCTED_MOVE, .proc/deal_with_obstacle)
	RegisterSignal(target, list(ACTION_GIVEN, ACTION_REMOVED), .proc/refresh_abilities)
	attack_ranges[target] = attack_range
	refresh_abilities(target)

/datum/element/ai_behavior/carbon/process()
	for(var/mob/mob in ability_lists)
		for(var/datum/action/action in ability_lists[mob])
			if(!action.ai_should_use(atoms_to_walk_to[mob]))
				continue
			//xeno_action/activable is activated with a different proc for keybinded actions, so we gotta use the correct proc
			if(istype(action, /datum/action/xeno_action/activable))
				var/datum/action/xeno_action/activable/xeno_action = action
				xeno_action.use_ability(atoms_to_walk_to[mob])
			else
				action.action_activate()

//Refresh ability list
/datum/element/ai_behavior/carbon/proc/refresh_abilities(datum/source)
	ability_lists[source] = list()
	var/mob/the_mob = source
	for(var/datum/action/action in the_mob.actions)
		if(action.ai_should_start_consider())
			ability_lists[the_mob] += action

//Returns a list of things we preferably want to attack
/datum/element/ai_behavior/carbon/proc/get_targets()

//Generic attack proc, unique procs to call for xenos, humans and other species as they all have different ways of executing an attack
/datum/element/ai_behavior/carbon/proc/attack_target()

//Attempt to deal with a obstacle
/datum/element/ai_behavior/carbon/proc/deal_with_obstacle()

//Signal wrappers; this can apply to both humans, xenos and other carbons that attack

/datum/element/ai_behavior/carbon/proc/reason_target_killed()
	change_state(REASON_TARGET_KILLED)
