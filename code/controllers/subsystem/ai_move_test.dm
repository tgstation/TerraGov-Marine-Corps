//Potential implementation of a tile by tile movement via subsystem

SUBSYSTEM_DEF(ai_movement)
	name = "ai tile by tile"
	priority = FIRE_PRIORITY_DEFAULT
	flags = SS_KEEP_TIMING
	init_order = INIT_ORDER_AI_MOVE
	wait = 0.5
	var/current_deci_second = 1 //What deci second we're at; 1 is 0.1, 2 is 0.2 ETC.

	//AI datums to process, split into 20 lists, 1 for each 0.5 decisecond
	var/list/list_of_lists = list()

	//Current AI datums being processed
	var/list/currentrun = list()

/datum/controller/subsystem/ai_movement/Initialize()
	for(var/i in 1 to 20)
		list_of_lists += list(list())

/datum/controller/subsystem/ai_movement/fire(resumed = 0)

	if(!resumed)
		src.currentrun = list_of_lists[current_deci_second]

	current_deci_second += 1
	if(current_deci_second > 20)
		current_deci_second = 1
	if(list_of_lists[current_deci_second].len)
		if(!currentrun.len)
			currentrun = list_of_lists[current_deci_second]

		while(currentrun.len)
			//If there's a datum in the list we process it and add it to a certain list according to move delay math
			var/datum/ai_behavior/ai = currentrun[currentrun.len]
			currentrun.len--
			var/next_index = current_deci_second + round(ai.ProcessMove(), 0.5) + 3
			if(next_index == current_deci_second)
				next_index += 1
			while(next_index > 20)
				next_index -= 20
			if(next_index < 1)
				next_index = 1
			list_of_lists[next_index] += ai
