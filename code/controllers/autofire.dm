/// Controls how many buckets should be kept, each representing a tick. Max is ten seconds, this system does not handle next fire of more than 100 ticks in order to have better perf
#define BUCKET_LEN (world.fps * 10)
/// Helper for getting the correct bucket
#define BUCKET_POS(next_fire) (((round((next_fire - SSautomatedfire.head_offset) / world.tick_lag) + 1) % BUCKET_LEN) || BUCKET_LEN)

/**
 * # Autofire Subsystem
 *
 * Maintains a timer-like system to handle autofiring. Much of this code is modeled
 * after or adapted from the runechat subsytem.
 *
 * Note that this has the same structure for storing and queueing shooter component as the timer subsystem does
 * for handling timers: the bucket_list is a list of autofire component, each of which are the head
 * of a circularly linked list. Any given index in bucket_list could be null, representing an empty bucket.
 */
SUBSYSTEM_DEF(automatedfire)
	name = "Automated fire"
	flags = SS_TICKER | SS_NO_INIT
	wait = 1
	priority = FIRE_PRIORITY_AUTOFIRE

	/// world.time of the first entry in the bucket list, effectively the 'start time' of the current buckets
	var/head_offset = 0
	/// Index of the first non-empty bucket
	var/practical_offset = 1
	/// world.tick_lag the bucket was designed for
	var/bucket_resolution = 0
	/// How many shooter are in the buckets
	var/bucket_count = 0
	/// List of buckets, each bucket holds every shooter that has to shoot this byond tick
	var/list/bucket_list = list()

/datum/controller/subsystem/automatedfire/PreInit()
	bucket_list.len = BUCKET_LEN
	head_offset = world.time
	bucket_resolution = world.tick_lag

/datum/controller/subsystem/automatedfire/stat_entry(msg)
	..("ActShooters:[bucket_count]")

/datum/controller/subsystem/automatedfire/fire(resumed = FALSE)

	if (MC_TICK_CHECK)
		return

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
	var/static/datum/component/automatedfire/shooter
	if (!resumed)
		shooter = null

	// Iterate through each bucket starting from the practical offset
	while (practical_offset <= BUCKET_LEN && head_offset + ((practical_offset - 1) * world.tick_lag) <= world.time)
		var/datum/component/automatedfire/bucket_head = bucket_list[practical_offset]
		if(!shooter)
			shooter = bucket_head

		while (shooter)

			if(shooter.process_shot())//If we are still shooting, we reschedule the shooter to the next_fire
				shooter.schedule_shot()

			SSautomatedfire.bucket_count--
			
			if (MC_TICK_CHECK)
				return

			// Break once we've processed the entire bucket
			shooter = shooter.next
		
		// Empty the bucket
		bucket_list[practical_offset++] = null

/datum/controller/subsystem/automatedfire/Recover()
	bucket_list |= SSautomatedfire.bucket_list

/datum/controller/subsystem/automatedfire/proc/reset_buckets()
	bucket_list.len = BUCKET_LEN
	head_offset = world.time
	bucket_resolution = world.tick_lag

/datum/component/automatedfire
	///The owner of this component
	var/atom/shooter
	/// Contains the scheduled fire time, used for scheduling EOL
	var/next_fire
	/// Contains the reference to the next component in the bucket, used by autofire subsystem
	var/datum/component/automatedfire/next
	/// Contains the reference to the previous component in the bucket, used by autofire subsystem
	var/datum/component/automatedfire/prev

/**
 * Schedule the shooter into the system, inserting it into the next fire queue
 *
 * This will also account for a shooter already being registered, and in which case
 * the position will be updated to remove it from the previous location if necessary
 *
 * Arguments:
 * * new_next_fire Optional, when provided is used to update an existing shooter with the new specified time
 *
 */
/datum/component/automatedfire/proc/schedule_shot(new_next_fire = 0)
	var/list/bucket_list = SSautomatedfire.bucket_list

	// Ensure the next_fire time is properly bound to avoid missing a scheduled event
	next_fire = max(CEILING(next_fire, world.tick_lag), world.time + world.tick_lag)

	// Get bucket position and a local reference to the datum var, it's faster to access this way
	var/bucket_pos = BUCKET_POS(next_fire)
	
	message_admins("rescheduling [shooter.name] to [bucket_pos]")

	// Get the bucket head for that bucket, increment the bucket count
	var/datum/component/automatedfire/bucket_head = bucket_list[bucket_pos]
	SSautomatedfire.bucket_count++

	// If there is no existing head of this bucket, we can set this shooter to be that head
	if (!bucket_head)
		bucket_list[bucket_pos] = src
		return

	// Otherwise it's a simple insertion into the circularly doubly-linked list
	if (bucket_head.next)
		next = bucket_head.next
		next.prev = src
	bucket_head.next = src
	prev = bucket_head
	if(prev == src || next == src)
		CRASH("Loop")


/**
 * Removes this autofire component from the autofire subsystem
 */
/datum/component/automatedfire/proc/unschedule_shot() //This is probably not needed
	// Attempt to find the bucket that contains this component
	var/bucket_pos = BUCKET_POS(next_fire)

	// Get local references to the subsystem's vars, faster than accessing on the datum
	var/list/bucket_list = SSautomatedfire.bucket_list

	// Attempt to get the head of the bucket
	var/datum/component/automatedfire/bucket_head
	if (bucket_pos > 0)
		bucket_head = bucket_list[bucket_pos]

	//Replace the bucket head if needed
	if(bucket_head == src)
		bucket_list[bucket_pos] = next
	SSautomatedfire.bucket_count--
	// Remove the shooter from the bucket, ensuring to maintain
	// the integrity of the bucket's list if relevant
	if(prev != next)
		prev.next = next
		next.prev = prev
	else
		prev?.next = null
		next?.prev = null
	prev = next = null

///Handle the firing of the autofire component
/datum/component/automatedfire/proc/process_shot()
	return

#undef BUCKET_LEN
#undef BUCKET_POS

/obj/structure/turret_debug
	name = "debug turret"
	///What kind of ammo it uses
	var/datum/ammo/ammo
	///Its target
	var/atom/target 
	///At wich rate it fires in ticks
	var/firerate = 5

/obj/structure/turret_debug/fast
	name = "debug turret fast"
	firerate = 1

/obj/structure/turret_debug/slow
	name = "debug turret slow"
	firerate = 25

/obj/structure/turret_debug/Initialize()
	. = ..()
	ammo = GLOB.ammo_list[/datum/ammo/xeno/acid]
	target = locate(x+5, y, z)
	AddComponent(/datum/component/automatedfire/automatic_shoot_at, firerate, ammo)
	SEND_SIGNAL(src, COMSIG_AUTOMATIC_SHOOTER_START_SHOOTING_AT, target)
	var/static/number = 1
	name = "[name] [number]"
	number++

/datum/component/automatedfire/automatic_shoot_at
	///The target we are shooting at
	var/atom/target
	///The ammo we are shooting
	var/datum/ammo/ammo
	///The delay between each shot in ticks
	var/shot_delay = 5
	///If we are shooting
	var/shooting = FALSE
	///For debug
	var/last_fire 

/datum/component/automatedfire/automatic_shoot_at/Initialize(_shot_delay, _ammo)
	. = ..()
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	shooter = parent
	shot_delay = _shot_delay
	ammo = _ammo
	RegisterSignal(parent, COMSIG_AUTOMATIC_SHOOTER_START_SHOOTING_AT, .proc/start_shooting)
	RegisterSignal(parent, COMSIG_AUTOMATIC_SHOOTER_STOP_SHOOTING_AT, .proc/stop_shooting)

///Signal handler for starting the autoshooting at something
/datum/component/automatedfire/automatic_shoot_at/proc/start_shooting(datum/source, _target)
	SIGNAL_HANDLER
	target = _target
	next_fire = world.time
	last_fire = world.time
	if(!shooting)
		shooting = TRUE
		schedule_shot()


///Signal handler for stoping the shooting
/datum/component/automatedfire/automatic_shoot_at/proc/stop_shooting(datum/source)
	SIGNAL_HANDLER
	target = null
	shooting = FALSE

/datum/component/automatedfire/automatic_shoot_at/process_shot()
	if(!shooting)
		return AUTOFIRE_STOPPED_SHOOTING
	var/obj/projectile/newshot = new(shooter.loc)
	newshot.generate_bullet(ammo)
	newshot.permutated += shooter
	newshot.fire_at(target, shooter, null, ammo.max_range, ammo.shell_speed)
	SEND_SIGNAL(shooter, COMSIG_AUTOMATIC_SHOOTER_SHOT_FIRED)
	next_fire = world.time + shot_delay
	var/time_between_shoot = world.time - last_fire
	last_fire = world.time
	if(time_between_shoot == 0)
		CRASH("time between shoot = 0")
	message_admins("<span class='debuginfo'>last fired [time_between_shoot] ticks ago</span>")
	return AUTOFIRE_STILL_SHOOTING
