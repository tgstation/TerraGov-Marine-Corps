SUBSYSTEM_DEF(pathfinder)
	name = "Pathfinder"
	flags = SS_NO_INIT
	priority = FIRE_PRIORITY_PATHFINDING
	wait = 2
	///List of all pathfinding datum with information on the mob and the target
	var/list/datum/pathfinding_datum/pathfinding_datums_list = list()
	///The current run list
	var/list/datum/pathfinding_datum/currentrun = list()

/datum/controller/subsystem/pathfinder/fire(resumed = FALSE)
	if(!resumed)
		src.currentrun = pathfinding_datums_list.Copy()

	var/list/currentrun = src.currentrun

	for(var/datum/pathfinding_datum/pathfinding_datum AS in currentrun)
		var/mob/mob_to_process = pathfinding_datum.mob_parent
		if(!mob_to_process?.canmove || mob_to_process.do_actions)
			continue

		//Okay it can actually physically move, but has it moved too recently?
		if(world.time <= (mob_to_process.last_move_time + mob_to_process.cached_multiplicative_slowdown + mob_to_process.next_move_slowdown))
			continue
		mob_to_process.next_move_slowdown = 0
		var/step_dir
		if(get_dist(mob_to_process, pathfinding_datum.atom_to_walk_to) == pathfinding_datum.distance_to_maintain)
			if(SEND_SIGNAL(mob_to_process, COMSIG_STATE_MAINTAINED_DISTANCE) & COMSIG_MAINTAIN_POSITION)
				continue
			if(!get_dir(mob_to_process, pathfinding_datum.atom_to_walk_to)) //We're right on top, move out of it
				step_dir = pick(CARDINAL_ALL_DIRS)
				var/turf/next_turf = get_step(mob_to_process, step_dir)
				if(!(next_turf.flags_atom & AI_BLOCKED) && !mob_to_process.Move(get_step(mob_to_process, step_dir), step_dir))
					SEND_SIGNAL(mob_to_process, COMSIG_OBSTRUCTED_MOVE, step_dir)
				else if(ISDIAGONALDIR(step_dir))
					mob_to_process.next_move_slowdown += (DIAG_MOVEMENT_ADDED_DELAY_MULTIPLIER - 1) * mob_to_process.cached_multiplicative_slowdown //Not perfect but good enough
				continue
			if(prob(pathfinding_datum.stutter_step_prob))
				step_dir = pick(LeftAndRightOfDir(get_dir(mob_to_process, pathfinding_datum.atom_to_walk_to)))
				var/turf/next_turf = get_step(mob_to_process, step_dir)
				if(!(next_turf.flags_atom & AI_BLOCKED) && !mob_to_process.Move(get_step(mob_to_process, step_dir), step_dir))
					SEND_SIGNAL(mob_to_process, COMSIG_OBSTRUCTED_MOVE, step_dir)
				else if(ISDIAGONALDIR(step_dir))
					mob_to_process.next_move_slowdown += (DIAG_MOVEMENT_ADDED_DELAY_MULTIPLIER - 1) * mob_to_process.cached_multiplicative_slowdown
			continue
		if(get_dist(mob_to_process, pathfinding_datum.atom_to_walk_to) < pathfinding_datum.distance_to_maintain) //We're too close, back it up
			step_dir = get_dir(pathfinding_datum.atom_to_walk_to, mob_to_process)
		else
			step_dir = get_dir(mob_to_process, pathfinding_datum.atom_to_walk_to)
		var/turf/next_turf = get_step(mob_to_process, step_dir)
		if(next_turf.flags_atom & AI_BLOCKED || (!mob_to_process.Move(next_turf, step_dir) && !(SEND_SIGNAL(mob_to_process, COMSIG_OBSTRUCTED_MOVE, step_dir) & COMSIG_OBSTACLE_DEALT_WITH)))
			if(world.time == mob_to_process.last_move_time)
				continue
			step_dir = pick(LeftAndRightOfDir(step_dir))
			next_turf = get_step(mob_to_process, step_dir)
			if(next_turf.flags_atom & AI_BLOCKED)
				continue
			if(mob_to_process.Move(get_step(mob_to_process, step_dir), step_dir) && ISDIAGONALDIR(step_dir))
				mob_to_process.next_move_slowdown += (DIAG_MOVEMENT_ADDED_DELAY_MULTIPLIER - 1) * mob_to_process.cached_multiplicative_slowdown
		else if(ISDIAGONALDIR(step_dir))
			mob_to_process.next_move_slowdown += (DIAG_MOVEMENT_ADDED_DELAY_MULTIPLIER - 1) * mob_to_process.cached_multiplicative_slowdown

/datum/controller/subsystem/pathfinder/stat_entry()
	..("Mob with pathfinder : [length(pathfinding_datums_list)]")

///Add a target mob to the pathfinding system
/datum/controller/subsystem/pathfinder/proc/add_to_pathfinding(mob/target, atom/atom_to_walk_to, distance_to_maintain = 0, stutter_step = 0)
	if(QDELETED(target) || !ismob(target) || !atom_to_walk_to)
		return
	pathfinding_datums_list += new /datum/pathfinding_datum(target, atom_to_walk_to, distance_to_maintain, stutter_step)
	RegisterSignal(target, COMSIG_PATHFINDER_SET_ATOM_TO_WALK_TO, .proc/change_target)

///Signal handler to change the target's atom_to_walk_to
/datum/controller/subsystem/pathfinder/proc/change_target(mob/target, atom/atom_to_walk_to)
	SIGNAL_HANDLER
	for(var/datum/pathfinding_datum/pathfinding_datum AS in pathfinding_datums_list)
		if(pathfinding_datum.mob_parent == target)
			pathfinding_datum.atom_to_walk_to = atom_to_walk_to
			return

///Remove a target mob from the pathfinding system
/datum/controller/subsystem/pathfinder/proc/remove_from_pathfinding(mob/target)
	UnregisterSignal(target, COMSIG_PATHFINDER_SET_ATOM_TO_WALK_TO)
	var/index = 1
	for(var/datum/pathfinding_datum/pathfinding_datum AS in pathfinding_datums_list)
		if(pathfinding_datum.mob_parent == target) //We don't break here, to ensure there is no duplicate being left
			pathfinding_datums_list.Cut(index, index + 1)
		index++

/datum/pathfinding_datum
	///The mob that is controlled by the pathfinder
	var/mob/mob_parent
	///The target of the mob_parent
	var/atom/atom_to_walk_to
	///How far should we approach the target atom
	var/distance_to_maintain
	///The probabity of stutter stepping (not going straight)
	var/stutter_step_prob

/datum/pathfinding_datum/New(mob/mob_parent, atom/atom_to_walk_to, distance_to_maintain, stutter_step_prob)
	src.mob_parent = mob_parent
	src.atom_to_walk_to = atom_to_walk_to
	src.distance_to_maintain = distance_to_maintain
	src.stutter_step_prob = stutter_step_prob
