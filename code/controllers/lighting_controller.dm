var/datum/controller/lighting/lighting_controller = new ()

datum/controller/lighting
	var/processing = 0
	var/processing_interval = 7	//setting this too low will probably kill the server. Don't be silly with it!
	var/process_cost = 0
	var/iteration = 0

	var/list/changed_lights = list()		//TODO: possibly implement this to reduce on overheads?
	var/list/changed_turfs = list()


datum/controller/lighting/New()
	if(lighting_controller != src)
		if(istype(lighting_controller,/datum/controller/lighting))
			Recover()	//if we are replacing an existing lighting_controller (due to a crash) we attempt to preserve as much as we can
			cdel(lighting_controller)
		lighting_controller = src


//Workhorse of lighting. It cycles through each light that needs updating. It updates their
//effects and then processes every turf in the queue, updating their lighting object's appearance
//Any light that returns 1 in check() deletes itself

datum/controller/lighting/proc/process()
	while(processing)
		iteration++
		var/started = world.timeofday
		lighting_processing()
		process_cost = (world.timeofday - started) / 10
		sleep(processing_interval)

datum/controller/lighting/proc/lighting_processing()

	for(var/thing in changed_lights)
		var/datum/light_source/L = thing
		if(L)
			L.check()

	changed_lights.Cut()

	for(var/thing in changed_turfs)
		var/turf/T = thing
		if(T)
			if(T.lighting_changed)
				T.redraw_lighting()

	changed_turfs.Cut()




//same as above except it attempts to shift ALL turfs in the world regardless of lighting_changed status
//Does not loop. Should be run prior to process() being called for the first time.
//Note: if we get additional z-levels at runtime (e.g. if the gateway thin ever gets finished) we can initialize specific
//z-levels with the z_level argument
datum/controller/lighting/proc/Initialize(var/z_level)
	processing = 0

	var/z_start = 1
	var/z_finish = world.maxz
	if(z_level)
		z_level = round(z_level,1)
		if(z_level > 0 && z_level <= world.maxz)
			z_start = z_level
			z_finish = z_level

	var/list/init_turfs = block(locate(1,1,z_start),locate(world.maxx,world.maxy,z_finish))

	for(var/X in init_turfs)
		var/turf/T = X
		T.init_lighting()

	processing = 1
	process() //Start the processor loop

//Used to strip valid information from an existing controller and transfer it to a replacement
//It works by using spawn(-1) to transfer the data, if there is a runtime the data does not get transfered but the loop
//does not crash
datum/controller/lighting/proc/Recover()
	if(!istype(lighting_controller.changed_turfs,/list))
		lighting_controller.changed_turfs = null
		lighting_controller.changed_turfs = list()
	if(!istype(lighting_controller.changed_lights,/list))
		lighting_controller.changed_lights = null
		lighting_controller.changed_lights = list()


/*
	for(var/thing in lighting_controller.changed_lights)
		var/datum/light_source/L = thing
		spawn(-1)			//so we don't crash the loop (inefficient)
			if(istype(L)
				L.check()

	for(var/thing in lighting_controller.changed_turfs)
		var/turf/T = thing
		if(istype(T) && T.lighting_changed)
			spawn(-1)
				T.shift_to_subarea()
*/
	lighting_controller.Initialize()

	var/msg = "## DEBUG: [time2text(world.timeofday)] lighting_controller restarted. Reports:\n"
	for(var/varname in lighting_controller.vars)
		switch(varname)
			if("tag","bestF","type","parent_type","vars")	continue
			else
				var/varval1 = lighting_controller.vars[varname]
				var/varval2 = vars[varname]
				if(istype(varval1,/list))
					varval1 = "/list([length(varval1)])"
					varval2 = "/list([length(varval2)])"
				msg += "\t [varname] = [varval1] -> [varval2]\n"
	world.log << msg

