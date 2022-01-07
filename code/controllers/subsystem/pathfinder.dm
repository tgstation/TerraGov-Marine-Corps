/// Controls how many buckets should be kept, each representing a tick. Max is ten seconds, to have better perf.
#define BUCKET_LEN (world.fps * 10)
/// Helper for getting the correct bucket
#define BUCKET_POS(next_fire) (((round((next_fire - SSpathfinder.head_offset) / world.tick_lag) + 1) % BUCKET_LEN) || BUCKET_LEN)

SUBSYSTEM_DEF(pathfinder)
	name = "Pathfinder"
	flags = SS_TICKER | SS_NO_INIT
	priority = FIRE_PRIORITY_PATHFINDING
	wait = 1
	/// world.time of the first entry in the bucket list, effectively the 'start time' of the current buckets
	var/head_offset = 0
	/// Index of the first non-empty bucket
	var/practical_offset = 1
	///How many buckets for every frame of world.fps
	var/bucket_resolution = 0
	///How many pathfinding datum are in the buckets
	var/pathfinding_datums_count = 0
	/// List of buckets, each bucket holds every pathfinding datum that has to move this byond tick
	var/list/bucket_list = list()
	/// Reference to the pathfinding datum before we clean shooter.next
	var/datum/pathfinding_datum/next_pathfinding_datum

/datum/controller/subsystem/pathfinder/PreInit()
	bucket_list.len = BUCKET_LEN
	head_offset = world.time
	bucket_resolution = world.tick_lag

/datum/controller/subsystem/pathfinder/stat_entry()
	..("Mob with pathfinder : [pathfinding_datums_count]")

/datum/controller/subsystem/pathfinder/fire(resumed = FALSE)
	// Check for when we need to loop the buckets, this occurs when
	// the head_offset is approaching BUCKET_LEN ticks in the past
	if (practical_offset > BUCKET_LEN)
		head_offset += TICKS2DS(BUCKET_LEN)
		practical_offset = 1
		resumed = FALSE

	// Check for when we have to reset buckets, typically from auto-reset
	if ((length(bucket_list) != BUCKET_LEN) || (world.tick_lag != bucket_resolution))
		reset_buckets()
		bucket_list = src.bucket_list
		resumed = FALSE

	// Store a reference to the 'working' shooter so that we can resume if the MC
	// has us stop mid-way through processing
	var/static/datum/pathfinding_datum/pathfinding_datum
	if (!resumed)
		pathfinding_datum = null

	// Iterate through each bucket starting from the practical offset
	while (practical_offset <= BUCKET_LEN && head_offset + ((practical_offset - 1) * world.tick_lag) <= world.time)
		if(!pathfinding_datum)
			pathfinding_datum =  bucket_list[practical_offset]
			bucket_list[practical_offset] = null

		while (pathfinding_datum)
			next_pathfinding_datum = pathfinding_datum.next
			INVOKE_ASYNC(pathfinding_datum, /datum/pathfinding_datum/proc/process_move)

			pathfinding_datums_count--
			pathfinding_datum = next_pathfinding_datum
			if (MC_TICK_CHECK)
				return

		// Move to the next bucket
		practical_offset++

/datum/controller/subsystem/pathfinder/Recover()
	bucket_list |= SSautomatedfire.bucket_list

///In the event of a change of world.tick_lag, we refresh the size of the bucket and the bucket resolution
/datum/controller/subsystem/pathfinder/proc/reset_buckets()
	bucket_list.len = BUCKET_LEN
	head_offset = world.time
	bucket_resolution = world.tick_lag

/datum/pathfinding_datum
	///The next pathfinding_datum in the subsytem
	var/datum/pathfinding_datum/next
	///The previous pathfinding_datum in the subsytem
	var/datum/pathfinding_datum/prev
	/// Contains the scheduled fire time, used for scheduling EOL
	var/next_move_time
	///The mob that is controlled by the pathfinder
	var/mob/mob_parent
	///The target of the mob_parent
	var/atom/atom_to_walk_to
	///How far should we approach the target atom
	var/distance_to_maintain = 1
	///The probabity of stutter stepping (not going straight)
	var/stutter_step_prob = 25

/datum/pathfinding_datum/New(mob/mob_parent)
	src.mob_parent = mob_parent

///Move the mob_parent and schedule the next move
/datum/pathfinding_datum/proc/process_move()
	if(!mob_parent?.canmove || mob_parent.do_actions)
		schedule_move(world.tick_lag)
		return
	//Duplication check
	if(world.time <= (mob_parent.last_move_time + mob_parent.cached_multiplicative_slowdown + mob_parent.next_move_slowdown))
		schedule_move()
		return
	mob_parent.next_move_slowdown = 0
	var/step_dir
	if(get_dist(mob_parent, atom_to_walk_to) == distance_to_maintain)
		if(SEND_SIGNAL(mob_parent, COMSIG_STATE_MAINTAINED_DISTANCE) & COMSIG_MAINTAIN_POSITION)
			return
		if(!get_dir(mob_parent, atom_to_walk_to)) //We're right on top, move out of it
			step_dir = pick(CARDINAL_ALL_DIRS)
			var/turf/next_turf = get_step(mob_parent, step_dir)
			if(!(next_turf.flags_atom & AI_BLOCKED) && !mob_parent.Move(get_step(mob_parent, step_dir), step_dir))
				SEND_SIGNAL(mob_parent, COMSIG_OBSTRUCTED_MOVE, step_dir)
			else if(ISDIAGONALDIR(step_dir))
				mob_parent.next_move_slowdown += (DIAG_MOVEMENT_ADDED_DELAY_MULTIPLIER - 1) * mob_parent.cached_multiplicative_slowdown //Not perfect but good enough
			schedule_move()
			return
		if(prob(stutter_step_prob))
			step_dir = pick(LeftAndRightOfDir(get_dir(mob_parent, atom_to_walk_to)))
			var/turf/next_turf = get_step(mob_parent, step_dir)
			if(!(next_turf.flags_atom & AI_BLOCKED) && !mob_parent.Move(get_step(mob_parent, step_dir), step_dir))
				SEND_SIGNAL(mob_parent, COMSIG_OBSTRUCTED_MOVE, step_dir)
			else if(ISDIAGONALDIR(step_dir))
				mob_parent.next_move_slowdown += (DIAG_MOVEMENT_ADDED_DELAY_MULTIPLIER - 1) * mob_parent.cached_multiplicative_slowdown
			schedule_move()
			return
	if(get_dist(mob_parent, atom_to_walk_to) < distance_to_maintain) //We're too close, back it up
		step_dir = get_dir(atom_to_walk_to, mob_parent)
	else
		step_dir = get_dir(mob_parent, atom_to_walk_to)
	var/turf/next_turf = get_step(mob_parent, step_dir)
	if(next_turf.flags_atom & AI_BLOCKED || (!mob_parent.Move(next_turf, step_dir) && !(SEND_SIGNAL(mob_parent, COMSIG_OBSTRUCTED_MOVE, step_dir) & COMSIG_OBSTACLE_DEALT_WITH)))
		step_dir = pick(LeftAndRightOfDir(step_dir))
		next_turf = get_step(mob_parent, step_dir)
		if(next_turf.flags_atom & AI_BLOCKED)
			schedule_move()
			return
		if(mob_parent.Move(get_step(mob_parent, step_dir), step_dir) && ISDIAGONALDIR(step_dir))
			mob_parent.next_move_slowdown += (DIAG_MOVEMENT_ADDED_DELAY_MULTIPLIER - 1) * mob_parent.cached_multiplicative_slowdown
	else if(ISDIAGONALDIR(step_dir))
		mob_parent.next_move_slowdown += (DIAG_MOVEMENT_ADDED_DELAY_MULTIPLIER - 1) * mob_parent.cached_multiplicative_slowdown
	schedule_move()

///Put the pathfinding datum into the bucket list
/datum/pathfinding_datum/proc/schedule_move(next_move_time = mob_parent.next_move_slowdown + mob_parent.cached_multiplicative_slowdown)
	if(src.next_move_time > world.time)
		return
	//We move to another bucket, so we clean the reference from the former linked list
	next = null
	prev = null
	var/list/bucket_list = SSpathfinder.bucket_list

	// Ensure the next_fire time is properly bound to avoid missing a scheduled event
	next_move_time += world.time
	next_move_time = max(CEILING(next_move_time, world.tick_lag), world.time + world.tick_lag)
	src.next_move_time = next_move_time
	// Get bucket position and a local reference to the datum var, it's faster to access this way
	var/bucket_pos = BUCKET_POS(next_move_time)

	// Get the bucket head for that bucket, increment the bucket count
	var/datum/component/automatedfire/bucket_head = bucket_list[bucket_pos]
	SSpathfinder.pathfinding_datums_count++

	// If there is no existing head of this bucket, we can set this shooter to be that head
	if (!bucket_head)
		bucket_list[bucket_pos] = src
		return

	// Otherwise it's a simple insertion into the double-linked list
	if (bucket_head.next)
		next = bucket_head.next
		next.prev = src

	bucket_head.next = src
	prev = bucket_head

/datum/pathfinding_datum/proc/remove_from_pathfinding()
	if(next_move_time < world.time + world.tick_lag)
		return
	var/bucket_pos = BUCKET_POS(next_move_time)
	var/datum/component/automatedfire/bucket_head = SSpathfinder.bucket_list[bucket_pos]
	while(bucket_head != src && bucket_head != null)
		bucket_head = bucket_head.next
	if(bucket_head != src)
		return
	SSpathfinder.bucket_list[bucket_pos] = next
	next?.prev = prev
	SSpathfinder.pathfinding_datums_count--
	next_move_time = 0
	
#undef BUCKET_LEN
#undef BUCKET_POS

/datum/pathfinding_datum/ranged 
	distance_to_maintain = 5

/datum/pathfinding_datum/zombie
	stutter_step_prob = 10
