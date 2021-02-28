<<<<<<< HEAD
/// Controls how many buckets should be kept, each representing a tick. Max is ten seconds, to have better perf.
#define BUCKET_LEN (world.fps * 10)
/// Helper for getting the correct bucket
#define BUCKET_POS(next_fire) (((round((next_fire - SSautomatedfire.head_offset) / world.tick_lag) + 1) % BUCKET_LEN) || BUCKET_LEN)
=======
/// Controls how many buckets should be kept, each representing a tick. Max is ten seconds, this system does not handle next fire of more than 100 ticks in order to have better perf
#define BUCKET_LEN (world.fps * 10)
/// Helper for getting the correct bucket
<<<<<<< HEAD
#define BUCKET_POS(next_fire) (((round((next_fire - SSautofire.head_offset) / world.tick_lag) + 1) % BUCKET_LEN) || BUCKET_LEN)
>>>>>>> 2aef6ac91 (rename the subsytem)
=======
#define BUCKET_POS(next_fire) (((round((next_fire - SSautomatedfire.head_offset) / world.tick_lag) + 1) % BUCKET_LEN) || BUCKET_LEN)
>>>>>>> bd5a1ac65 (xeno_turret up to code with autofire)

/**
 * # Autofire Subsystem
 *
 * Maintains a timer-like system to handle autofiring. Much of this code is modeled
 * after or adapted from the runechat subsytem.
 *
<<<<<<< HEAD
<<<<<<< HEAD
 * Note that this has the same structure for storing and queueing shooter component as the timer subsystem does
 * for handling timers: the bucket_list is a list of autofire component, each of which are the head
 * of a linked list. Any given index in bucket_list could be null, representing an empty bucket.
 * 
 * Doesn't support any event scheduled for more than 100 ticks in the future, as it has no secondary queue by design
 */
SUBSYSTEM_DEF(automatedfire)
	name = "Automated fire"
=======
 * Note that this has the same structure for storing and queueing messages as the timer subsystem does
 * for handling timers: the bucket_list is a list of autofire component, each of which are the head
 * of a circularly linked list. Any given index in bucket_list could be null, representing an empty bucket.
 */
SUBSYSTEM_DEF(autofire)
	name = "Autofire"
>>>>>>> 2aef6ac91 (rename the subsytem)
=======
 * Note that this has the same structure for storing and queueing shooter component as the timer subsystem does
 * for handling timers: the bucket_list is a list of autofire component, each of which are the head
 * of a linked list. Any given index in bucket_list could be null, representing an empty bucket.
 * 
 * Doesn't support any event scheduled for more than 100 ticks in the future, as it has no secondary queue by design
 */
SUBSYSTEM_DEF(automatedfire)
	name = "Automated fire"
>>>>>>> bd5a1ac65 (xeno_turret up to code with autofire)
	flags = SS_TICKER | SS_NO_INIT
	wait = 1
	priority = FIRE_PRIORITY_AUTOFIRE

	/// world.time of the first entry in the bucket list, effectively the 'start time' of the current buckets
	var/head_offset = 0
	/// Index of the first non-empty bucket
	var/practical_offset = 1
<<<<<<< HEAD
<<<<<<< HEAD
	///How many buckets for every frame of world.fps
	var/bucket_resolution = 0
	/// How many shooter are in the buckets
	var/shooter_count = 0
	/// List of buckets, each bucket holds every shooter that has to shoot this byond tick
	var/list/bucket_list = list()
	/// Reference to the next shooter before we clean shooter.next
	var/var/datum/component/automatedfire/next_shooter

/datum/controller/subsystem/automatedfire/PreInit()
=======
	/// world.tick_lag the bucket was designed for
=======
	///How many buckets exist for one tick
>>>>>>> 530afc288 (xeno turrets)
	var/bucket_resolution = 0
	/// How many shooter are in the buckets
	var/bucket_count = 0
	/// List of buckets, each bucket holds every shooter that has to shoot this byond tick
	var/list/bucket_list = list()
	/// Reference to the next shooter before we clean shooter.next
	var/var/datum/component/automatedfire/next_shooter

<<<<<<< HEAD
/datum/controller/subsystem/autofire/PreInit()
>>>>>>> 2aef6ac91 (rename the subsytem)
=======
/datum/controller/subsystem/automatedfire/PreInit()
>>>>>>> bd5a1ac65 (xeno_turret up to code with autofire)
	bucket_list.len = BUCKET_LEN
	head_offset = world.time
	bucket_resolution = world.tick_lag

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
/datum/controller/subsystem/automatedfire/stat_entry(msg = "ActShooters:[shooter_count]")
	return ..()

/datum/controller/subsystem/automatedfire/fire(resumed = FALSE)
=======
/datum/controller/subsystem/autofire/stat_entry(msg)
=======
/datum/controller/subsystem/automatedfire/stat_entry(msg)
>>>>>>> bd5a1ac65 (xeno_turret up to code with autofire)
	..("ActShooters:[bucket_count]")

/datum/controller/subsystem/automatedfire/fire(resumed = FALSE)

	if (MC_TICK_CHECK)
		return

>>>>>>> 2aef6ac91 (rename the subsytem)
=======
/datum/controller/subsystem/automatedfire/stat_entry(msg = "ActShooters:[bucket_count]")
	return ..()

/datum/controller/subsystem/automatedfire/fire(resumed = FALSE)
>>>>>>> 530afc288 (xeno turrets)
	// Check for when we need to loop the buckets, this occurs when
	// the head_offset is approaching BUCKET_LEN ticks in the past
	if (practical_offset > BUCKET_LEN)
		head_offset += TICKS2DS(BUCKET_LEN)
		practical_offset = 1
		resumed = FALSE

<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> 530afc288 (xeno turrets)
	// Check for when we have to reset buckets, typically from auto-reset
	if ((length(bucket_list) != BUCKET_LEN) || (world.tick_lag != bucket_resolution))
		reset_buckets()
		bucket_list = src.bucket_list
		resumed = FALSE

	// Store a reference to the 'working' shooter so that we can resume if the MC
	// has us stop mid-way through processing
	var/static/datum/component/automatedfire/shooter
=======
	// Store a reference to the 'working' shooter so that we can resume if the MC
	// has us stop mid-way through processing
<<<<<<< HEAD
	var/static/datum/component/autofire/shooter
>>>>>>> 2aef6ac91 (rename the subsytem)
=======
	var/static/datum/component/automatedfire/shooter
>>>>>>> bd5a1ac65 (xeno_turret up to code with autofire)
	if (!resumed)
		shooter = null

	// Iterate through each bucket starting from the practical offset
<<<<<<< HEAD
<<<<<<< HEAD
	while (practical_offset <= BUCKET_LEN && head_offset + ((practical_offset - 1) * world.tick_lag) <= world.time)	
		if(!shooter)
			shooter =  bucket_list[practical_offset]
			bucket_list[practical_offset] = null

		while (shooter)
			next_shooter = shooter.next
			INVOKE_ASYNC(shooter, /datum/component/automatedfire/proc/process_shot)

			SSautomatedfire.shooter_count--
			shooter = next_shooter
			if (MC_TICK_CHECK)
				return

		// Move to the next bucket
		practical_offset++

/datum/controller/subsystem/automatedfire/Recover()
	bucket_list |= SSautomatedfire.bucket_list

///In the event of a change of world.tick_lag, we refresh the size of the bucket and the bucket resolution
/datum/controller/subsystem/automatedfire/proc/reset_buckets()
	bucket_list.len = BUCKET_LEN
	head_offset = world.time
	bucket_resolution = world.tick_lag

/datum/component/automatedfire
=======
	while (practical_offset <= BUCKET_LEN && head_offset + ((practical_offset - 1) * world.tick_lag) <= world.time)
		var/datum/component/automatedfire/bucket_head = bucket_list[practical_offset]
=======
	while (practical_offset <= BUCKET_LEN && head_offset + ((practical_offset - 1) * world.tick_lag) <= world.time)	
>>>>>>> 530afc288 (xeno turrets)
		if(!shooter)
			shooter =  bucket_list[practical_offset]
			bucket_list[practical_offset] = null

		while (shooter)
			next_shooter = shooter.next
			INVOKE_ASYNC(shooter, /datum/component/automatedfire/proc/process_shot)

			SSautomatedfire.bucket_count--
			shooter = next_shooter
			if (MC_TICK_CHECK)
				return

		// Empty the bucket
		practical_offset++

/datum/controller/subsystem/automatedfire/Recover()
	bucket_list |= SSautomatedfire.bucket_list

<<<<<<< HEAD
<<<<<<< HEAD
/datum/component/autofire
>>>>>>> 2aef6ac91 (rename the subsytem)
=======
=======
///In the event of a change of world.tick_lag, we refresh the size of the bucket and the bucket resolution
/datum/controller/subsystem/automatedfire/proc/reset_buckets()
	bucket_list.len = BUCKET_LEN
	head_offset = world.time
	bucket_resolution = world.tick_lag

>>>>>>> 530afc288 (xeno turrets)
/datum/component/automatedfire
>>>>>>> bd5a1ac65 (xeno_turret up to code with autofire)
	///The owner of this component
	var/atom/shooter
	/// Contains the scheduled fire time, used for scheduling EOL
	var/next_fire
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> bd5a1ac65 (xeno_turret up to code with autofire)
	/// Contains the reference to the next component in the bucket, used by autofire subsystem
	var/datum/component/automatedfire/next
	/// Contains the reference to the previous component in the bucket, used by autofire subsystem
	var/datum/component/automatedfire/prev
<<<<<<< HEAD


/// schedule the shooter into the system, inserting it into the next fire queue
/datum/component/automatedfire/proc/schedule_shot()
	//We move to another bucket, so we clean the reference from the former linked list
	next = null
	prev = null	
	var/list/bucket_list = SSautomatedfire.bucket_list
=======
	/// Contains the reference to the next chatmessage in the bucket, used by runechat subsystem
	var/datum/component/autofire/next
	/// Contains the reference to the previous chatmessage in the bucket, used by runechat subsystem
	var/datum/component/autofire/prev
=======
>>>>>>> bd5a1ac65 (xeno_turret up to code with autofire)


<<<<<<< HEAD
	// When necessary, de-list the shooter from its previous position
	if (new_next_fire)
		SSautomatedfire.bucket_count--
		var/bucket_pos = BUCKET_POS(next_fire)
		if (bucket_pos > 0)
			var/datum/component/automatedfire/bucket_head = bucket_list[bucket_pos]
			if (bucket_head == src)
				bucket_list[bucket_pos] = next
		if (prev != next)
			prev.next = next
			next.prev = prev
		else
			prev?.next = null
			next?.prev = null
		prev = next = null
		next_fire = new_next_fire
>>>>>>> 2aef6ac91 (rename the subsytem)
=======
/// chedule the shooter into the system, inserting it into the next fire queue
/datum/component/automatedfire/proc/schedule_shot()
	//We move to another bucket, so we clean the reference from the former linked list
	next = null
	prev = null	
	var/list/bucket_list = SSautomatedfire.bucket_list
>>>>>>> 530afc288 (xeno turrets)

	// Ensure the next_fire time is properly bound to avoid missing a scheduled event
	next_fire = max(CEILING(next_fire, world.tick_lag), world.time + world.tick_lag)

	// Get bucket position and a local reference to the datum var, it's faster to access this way
	var/bucket_pos = BUCKET_POS(next_fire)

	// Get the bucket head for that bucket, increment the bucket count
<<<<<<< HEAD
<<<<<<< HEAD
	var/datum/component/automatedfire/bucket_head = bucket_list[bucket_pos]
	SSautomatedfire.shooter_count++
=======
	var/datum/component/autofire/bucket_head = bucket_list[bucket_pos]
	SSautofire.bucket_count++
>>>>>>> 2aef6ac91 (rename the subsytem)
=======
	var/datum/component/automatedfire/bucket_head = bucket_list[bucket_pos]
	SSautomatedfire.bucket_count++
>>>>>>> bd5a1ac65 (xeno_turret up to code with autofire)

	// If there is no existing head of this bucket, we can set this shooter to be that head
	if (!bucket_head)
		bucket_list[bucket_pos] = src
		return

<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> 530afc288 (xeno turrets)
	// Otherwise it's a simple insertion into the double-linked list
	if (bucket_head.next)
		next = bucket_head.next
		next.prev = src
<<<<<<< HEAD

	bucket_head.next = src
	prev = bucket_head

	//Something went wrong, probably a lag spike or something. To prevent infinite loops, we reschedule it to a another next fire
	if(prev == src)
		next_fire += 1
		schedule_shot()

///Handle the firing of the autofire component
/datum/component/automatedfire/proc/process_shot()
=======
	// Otherwise it's a simple insertion into the circularly doubly-linked list
	if (!bucket_head.prev)
		bucket_head.prev = bucket_head
	next = bucket_head
	prev = bucket_head.prev
	next.prev = src
	prev.next = src
=======
>>>>>>> 530afc288 (xeno turrets)

	bucket_head.next = src
	prev = bucket_head

	//Something went wrong, probably a lag spike or something. To prevent infinite loops, we reschedule it to a another next fire
	if(prev == src)
		next_fire = next_fire += 1
		schedule_shot()

///Handle the firing of the autofire component
<<<<<<< HEAD
/datum/component/autofire/proc/process_shot()
>>>>>>> 2aef6ac91 (rename the subsytem)
=======
/datum/component/automatedfire/proc/process_shot()
>>>>>>> bd5a1ac65 (xeno_turret up to code with autofire)
	return

#undef BUCKET_LEN
#undef BUCKET_POS
<<<<<<< HEAD
<<<<<<< HEAD

<<<<<<< HEAD
=======

>>>>>>> 530afc288 (xeno turrets)
/obj/structure/turret_debug
	name = "debug turret"
	///What kind of ammo it uses
	var/datum/ammo/ammo
	///Its target
	var/atom/target 
	///At wich rate it fires in ticks
	var/firerate = 5.5

/obj/structure/turret_debug/fast
	name = "debug turret fast"
	firerate = 1

/obj/structure/turret_debug/super_fast
	name = "debug turret super fast"
	firerate = 0.5

/obj/structure/turret_debug/slow
	name = "debug turret slow"
	firerate = 25

/obj/structure/turret_debug/Initialize()
	. = ..()
	ammo = GLOB.ammo_list[/datum/ammo/xeno/acid]
	target = locate(x+5, y, z)
	AddComponent(/datum/component/automatedfire/xeno_turret_autofire, firerate)
	RegisterSignal(src, COMSIG_AUTOMATIC_SHOOTER_SHOOT, .proc/shoot)
	SEND_SIGNAL(src, COMSIG_AUTOMATIC_SHOOTER_START_SHOOTING_AT)
	var/static/number = 1
	name = "[name] [number]"
	number++

///Create the projectile
/obj/structure/turret_debug/proc/shoot()
	SIGNAL_HANDLER
	var/obj/projectile/newshot = new(loc)
	newshot.generate_bullet(ammo)
	newshot.permutated += src
	newshot.fire_at(target, src, null, ammo.max_range, ammo.shell_speed)

/datum/component/automatedfire/xeno_turret_autofire
	///Delay between two shots
	var/shot_delay
	///If we must shoot
	var/shooting = FALSE

/datum/component/automatedfire/xeno_turret_autofire/Initialize(_shot_delay)
	. = ..()
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	shot_delay = _shot_delay
	RegisterSignal(parent, COMSIG_AUTOMATIC_SHOOTER_START_SHOOTING_AT, .proc/start_shooting)
	RegisterSignal(parent, COMSIG_AUTOMATIC_SHOOTER_STOP_SHOOTING_AT, .proc/stop_shooting)

///Signal handler for starting the autoshooting at something
/datum/component/automatedfire/xeno_turret_autofire/proc/start_shooting(datum/source)
	SIGNAL_HANDLER
	if(!shooting)
		shooting = TRUE
		INVOKE_ASYNC(src, .proc/process_shot)
<<<<<<< HEAD
=======
		next_fire = world.time + shot_delay
		schedule_shot()
>>>>>>> 530afc288 (xeno turrets)


///Signal handler for stoping the shooting
/datum/component/automatedfire/xeno_turret_autofire/proc/stop_shooting(datum/source)
	SIGNAL_HANDLER
	shooting = FALSE

/datum/component/automatedfire/xeno_turret_autofire/process_shot()
	if(!shooting)
		return
	SEND_SIGNAL(parent, COMSIG_AUTOMATIC_SHOOTER_SHOOT)
	next_fire = world.time + shot_delay
	schedule_shot()
<<<<<<< HEAD
=======

>>>>>>> 2aef6ac91 (rename the subsytem)
=======
>>>>>>> bd5a1ac65 (xeno_turret up to code with autofire)
=======
>>>>>>> 530afc288 (xeno turrets)
