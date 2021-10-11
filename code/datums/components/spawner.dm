#define MAX_SPAWNABLE_MOB_PER_PLAYER 0.3 //So for 50 players, each spawner can generate 15 mobs
#define SPAWN_RATE_PER_PLAYER 24 //For each player, the time between two consecutive spawns is reduced by 24 ticks. So for 50 players, it's one mob every minute

/datum/component/spawner
	///What type of mobs are spawned here
	var/list/mob_type_list_to_spawn = list()
	////How many mob were spawned
	var/mobs_spawned_count = 0
	///The relative spawning potential of this spawner. 1 is default, 0.5 to spawn half as often and half as much
	var/spawning_potential = 1
	///The timer to spawn the next mob
	var/spawn_timer

/datum/component/spawner/Initialize(list/list_to_spawn, spawning_potential = 1)
	. = ..()
	if(!length(list_to_spawn))
		stack_trace("A spawner component tried to init without a list_to_spawn")
		return COMPONENT_INCOMPATIBLE
	mob_type_list_to_spawn = list_to_spawn
	addtimer(CALLBACK(src, .proc/spawn_mob), 1 MINUTES)

///Spawn a mob from the mob_type_to_spawn list
/datum/component/spawner/proc/spawn_mob()
	if(mobs_spawned_count >= max(2 * spawning_potential, MAX_SPAWNABLE_MOB_PER_PLAYER * SSmonitor.maximum_connected_players_count * spawning_potential))
		spawn_timer = null
		return
	var/mob_type_to_spawn = pick(mob_type_list_to_spawn)
	var/mob/mob_spawned = new mob_type_to_spawn(get_turf(parent))
	RegisterSignal(mob_spawned, list(COMSIG_PARENT_QDELETING, COMSIG_MOB_DEATH), .proc/clean_mob_spawned)
	mobs_spawned_count++
	spawn_timer = addtimer(CALLBACK(src, .proc/spawn_mob), spawning_potential * min(45 SECONDS, 3 MINUTES - SSmonitor.maximum_connected_players_count * SPAWN_RATE_PER_PLAYER))

///Account for the death of on of the spawned mob
/datum/component/spawner/proc/clean_mob_spawned(datum/source)
	UnregisterSignal(source, list(COMSIG_PARENT_QDELETING, COMSIG_MOB_DEATH))
	mobs_spawned_count--
	if(!spawn_timer)
		spawn_timer = addtimer(CALLBACK(src, .proc/spawn_mob), spawning_potential * min(45 SECONDS, 3 MINUTES - SSmonitor.maximum_connected_players_count * SPAWN_RATE_PER_PLAYER))
