
SUBSYSTEM_DEF(mobs)
	name = "Mobs"
	priority = FIRE_PRIORITY_MOBS
	flags = SS_KEEP_TIMING | SS_NO_INIT
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	var/list/currentrun = list()
	var/static/list/clients_by_zlevel[][]
	var/static/list/dead_players_by_zlevel[][] = list(list()) // Needs to support zlevel 1 here, MaxZChanged only happens when z2 is created and new_players can login before that.
	var/static/list/cubemonkeys = list()
	var/list/dead_mobs = list()
	var/amt2process = 5


/datum/controller/subsystem/mobs/stat_entry()
	..("P:[GLOB.mob_living_list.len]")

/datum/controller/subsystem/mobs/proc/MaxZChanged()
	if (!islist(clients_by_zlevel))
		clients_by_zlevel = new /list(world.maxz,0)
		dead_players_by_zlevel = new /list(world.maxz,0)
	while (clients_by_zlevel.len < world.maxz)
		clients_by_zlevel.len++
		clients_by_zlevel[clients_by_zlevel.len] = list()
		dead_players_by_zlevel.len++
		dead_players_by_zlevel[dead_players_by_zlevel.len] = list()

/datum/controller/subsystem/mobs/proc/MaxZDec()
	if (!islist(clients_by_zlevel))
		clients_by_zlevel = new /list(world.maxz,0)
		dead_players_by_zlevel = new /list(world.maxz,0)
	while (clients_by_zlevel.len > world.maxz)
		clients_by_zlevel.len--
//		clients_by_zlevel[clients_by_zlevel.len] = list()
		dead_players_by_zlevel.len--
//		dead_players_by_zlevel[dead_players_by_zlevel.len] = list()


/datum/controller/subsystem/mobs/fire(resumed = 0)
	var/seconds = wait * 0.1
	if (!resumed)
		src.currentrun = GLOB.mob_living_list.Copy()

	var/createnewdm = FALSE
	if(!dead_mobs.len)
		createnewdm = TRUE

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	var/times_fired = src.times_fired
	while(currentrun.len)
		var/mob/living/L = currentrun[currentrun.len]
		currentrun.len--
		if(!L || QDELETED(L))
			GLOB.mob_living_list.Remove(L)
			continue
		if(L.stat == DEAD)
			if(createnewdm)
				dead_mobs |= L
		else
			L.Life(seconds, times_fired)
		if (MC_TICK_CHECK)
			return

	var/ye = 0
	while(dead_mobs.len)
		if(ye > amt2process)
			return
		ye++
		var/mob/living/L = dead_mobs[dead_mobs.len]
		dead_mobs.len--
		if(!L || QDELETED(L))
			continue
		L.DeadLife()
		if (MC_TICK_CHECK)
			return
