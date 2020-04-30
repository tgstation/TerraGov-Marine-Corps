//A generic mind for a carbon; currently has attacking, obstacle dealing and ability activation capabilities

/datum/ai_behavior/carbon
	var/attack_range = 1 //How far away we gotta be before considering an attack
	var/list/ability_list = list() //List of abilities to consider doing every Process()

/datum/ai_behavior/carbon/late_initialize()
	RegisterSignal(mob_parent, COMSIG_OBSTRUCTED_MOVE, .proc/deal_with_obstacle)
	RegisterSignal(mob_parent, list(ACTION_GIVEN, ACTION_REMOVED), .proc/refresh_abilities)
	refresh_abilities()
	..() //Start random node movement

//Refresh abilities-to-consider list
/datum/ai_behavior/carbon/proc/refresh_abilities()
	ability_list = list()
	for(var/datum/action/action in mob_parent.actions)
		if(action.ai_should_start_consider())
			ability_list += action

//Returns a list of things we preferably want to attack
/datum/ai_behavior/carbon/proc/get_targets()

//Generic attack proc, unique procs to call for xenos, humans and other species as they all have different ways of executing an attack
/datum/ai_behavior/carbon/proc/attack_target()

//Attempt to deal with a obstacle
/datum/ai_behavior/carbon/proc/deal_with_obstacle()

//Signal wrappers; this can apply to both humans, xenos and other carbons that attack

/datum/ai_behavior/carbon/proc/reason_target_killed()
	change_state(REASON_TARGET_KILLED)

//Processing; this is for abilities so we don't need to make endless xeno types to code specifically for what abilities they spawn with
/datum/ai_behavior/carbon/process()
	if(mob_parent.action_busy) //No activating more abilities if they're already in the progress of doing one
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
