//How many controlelrs do you need, four?

//Handles tile by tile movement, meant for experimental reasons

SUBSYSTEM_DEF(ai_movement)
	name = "ai movement handler"
	priority = FIRE_PRIORITY_DEFAULT
	flags = SS_KEEP_TIMING | SS_NO_INIT
	runlevels = RUNLEVEL_GAME
	wait = 1

	//A list of all AI datums that are going to move in the future, not in order by what time their going to move in sadly
	var/list/toprocess = list()

	//A list of ai datums to check; if they aren't allowed to move yet, we readd them to the list above
	var/list/currentrun = list()

/datum/controller/subsystem/ai_movement/fire(resumed = 0)
	if (!resumed)
		src.currentrun = toprocess.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while(currentrun.len)
		var/datum/ai_behavior/ai = currentrun[currentrun.len]
		currentrun.len--
		if(ai.move_delay < world.time)
			ai.ProcessMove()

		if (MC_TICK_CHECK)
			return
