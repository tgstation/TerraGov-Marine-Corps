SUBSYSTEM_DEF(mobs)
	name = "Mobs"
	priority = FIRE_PRIORITY_MOBS
	flags = SS_KEEP_TIMING | SS_NO_INIT
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	wait = 5

	var/list/processing = list()

	var/list/currentrun = list()
	var/static/list/clients_by_zlevel[][]
	var/static/list/dead_players_by_zlevel[][] = list(list()) // Needs to support zlevel 1 here, MaxZChanged only happens when z2 is created and new_players can login before that.
	var/static/list/cubemonkeys = list()

	var/list/list/crates = list(list(), list(), list(), list())
	var/crate = 1

/datum/controller/subsystem/mobs/stat_entry(msg)
	msg = "P:[length(GLOB.mob_living_list)]"
	return ..()

/datum/controller/subsystem/mobs/proc/stop_processing(mob/living/L)
	if(!CHECK_BITFIELD(L.datum_flags, DF_ISPROCESSING))
		return
	L.ExtinguishMob()
	for(var/i in crates)
		i -= L
	STOP_PROCESSING(src, L)

/datum/controller/subsystem/mobs/proc/start_processing(mob/living/L)
	if(CHECK_BITFIELD(L.datum_flags, DF_ISPROCESSING))
		return
	crates[1] += L
	START_PROCESSING(src, L)

/datum/controller/subsystem/mobs/proc/MaxZChanged()
	if (!islist(clients_by_zlevel))
		clients_by_zlevel = new /list(world.maxz,0)
		dead_players_by_zlevel = new /list(world.maxz,0)
	while (length(clients_by_zlevel) < world.maxz)
		clients_by_zlevel.len++
		clients_by_zlevel[length(clients_by_zlevel)] = list()
		dead_players_by_zlevel.len++
		dead_players_by_zlevel[length(dead_players_by_zlevel)] = list()

/datum/controller/subsystem/mobs/fire(resumed = 0)
	if (!resumed)
		if(crate == 1)
			var/most = -1
			var/least = 999999
			var/most_idx = 1
			var/least_idx = 1
			for(var/i in 1 to 4)
				if(length(crates[i]) > most)
					most = length(crates[i])
					most_idx = i
				if(length(crates[i]) < least)
					least = length(crates[i])
					least_idx = i
			if(least_idx != most_idx)
				for(var/i in 1 to ((most-least)/2))
					var/mob/living/L = pick_n_take(crates[most_idx])
					crates[WRAP(most_idx+1, 1, 5)] += L

		src.currentrun = crates[crate].Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	var/times_fired = src.times_fired
	var/seconds_per_tick = wait / (1 SECONDS) * SS_MOBS_BUCKET_DELAY
	while(length(currentrun))
		var/mob/living/L = currentrun[length(currentrun)]
		currentrun.len--
		if(L)
			L.Life(seconds_per_tick, times_fired)
		else
			processing.Remove(L)
		if (MC_TICK_CHECK)
			return
	crate = WRAP(crate+1, 1, 5)
