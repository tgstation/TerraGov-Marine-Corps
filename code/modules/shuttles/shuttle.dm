//These lists are populated in /datum/shuttle_controller/New()
//Shuttle controller is instantiated in master_controller.dm.

//shuttle moving state defines are in setup.dm

/datum/shuttle
	var/warmup_time = 0
	var/moving_status = SHUTTLE_IDLE

	var/docking_controller_tag	//tag of the controller used to coordinate docking
	var/datum/computer/file/embedded_program/docking/docking_controller	//the controller itself. (micro-controller, not game controller)

	var/arrive_time = 0	//the time at which the shuttle arrives when long jumping

	var/recharging = 0
	var/iselevator = 0 //Used to remove some shuttle related procs and texts to make it compatible with elevators

/datum/shuttle/proc/short_jump(var/area/origin,var/area/destination)
	if(moving_status != SHUTTLE_IDLE) return

	//it would be cool to play a sound here
	moving_status = SHUTTLE_WARMUP
	spawn(warmup_time*10)
		if (moving_status == SHUTTLE_IDLE)
			return	//someone cancelled the launch

		moving_status = SHUTTLE_INTRANSIT //shouldn't matter but just to be safe
		move(origin, destination)
		moving_status = SHUTTLE_IDLE

/datum/shuttle/proc/long_jump(var/area/departing, var/area/destination, var/area/interim, var/travel_time, var/direction)
	//world << "shuttle/long_jump: departing=[departing], destination=[destination], interim=[interim], travel_time=[travel_time]"
	if(moving_status != SHUTTLE_IDLE) return

	for(var/obj/structure/enginesound/O in departing)
		playsound(O.loc, 'sound/effects/engine_startup.ogg', 100, 0, 10, -100)

	moving_status = SHUTTLE_WARMUP
	recharging = 1 // Prevent the shuttle from moving again until it finishes recharging
	spawn(warmup_time*10)
		if (moving_status == SHUTTLE_IDLE)
			return	//someone canceled the launch

		arrive_time = world.time + travel_time*10
		moving_status = SHUTTLE_INTRANSIT
		move(departing, interim, direction)
		spawn(1)
			close_doors(interim)

		while (world.time < arrive_time)
			sleep(5)

		move(interim, destination, direction)
		spawn(1)
			open_doors(destination)
		moving_status = SHUTTLE_IDLE


		spawn(600) // 1 minute in deciseconds
			recharging = 0

/* Pseudo-code. Auto-bolt shuttle airlocks when in motion.
/datum/shuttle/proc/toggle_doors(var/close_doors, var/bolt_doors, var/area/whatArea)
	if(!whatArea) return <-- logic checks!
  		for(all doors in whatArea)
  			if(door.id is the same as src.id)
				if(close_doors)
			    	toggle dat shit
			   	if(bolt_doors)
			   		bolt dat shit
*/

//Actual code. lel
/datum/shuttle/proc/close_doors(var/area/area)
	if(!area || !istype(area)) //somehow
		return

	for(var/obj/machinery/door/unpowered/D in area)
		if(!D.density && !D.locked)
			spawn(0)
				D.close()

	for(var/obj/machinery/door/poddoor/shutters/P in area)
		if(!P.density)
			spawn(0)
				P.close()

	for(var/obj/machinery/door/airlock/D in area)//For elevators
		if (iselevator)
			spawn(0)
				if(!D.density)
					D.close()
					D.lock()
				else
					D.lock()

/datum/shuttle/proc/open_doors(var/area/area)
	if(!area || !istype(area)) //somehow
		return

	for(var/obj/machinery/door/unpowered/D in area)
		if(D.density && !D.locked)
			spawn(0)
				D.open()

	for(var/obj/machinery/door/poddoor/shutters/P in area)
		if(P.density)
			spawn(0)
				P.open()

	for(var/obj/machinery/door/airlock/D in area)//For elevators
		if (iselevator)
			if(D.locked)
				spawn(0)
					D.unlock()
			if(D.density)
				spawn(0)
					D.open()

/datum/shuttle/proc/dock()
	if (!docking_controller)
		return

	var/dock_target = current_dock_target()
	if (!dock_target)
		return

	docking_controller.initiate_docking(dock_target)

/datum/shuttle/proc/undock()
	if (!docking_controller)
		return
	docking_controller.initiate_undocking()

/datum/shuttle/proc/current_dock_target()
	return null

/datum/shuttle/proc/skip_docking_checks()
	if (!docking_controller || !current_dock_target())
		return 1	//shuttles without docking controllers or at locations without docking ports act like old-style shuttles
	return 0

//just moves the shuttle from A to B, if it can be moved
//A note to anyone overriding move in a subtype. move() must absolutely not, under any circumstances, fail to move the shuttle.
//If you want to conditionally cancel shuttle launches, that logic must go in short_jump() or long_jump()
/datum/shuttle/proc/move(var/area/origin, var/area/destination, var/direction=null)

	//world << "move_shuttle() called for [shuttle_tag] leaving [origin] en route to [destination]."

	//world << "area_coming_from: [origin]"
	//world << "destination: [destination]"

	if(origin == destination)
		//world << "cancelling move, shuttle will overlap."
		return

	if (docking_controller && !docking_controller.undocked())
		docking_controller.force_undock()

	for(var/turf/T in destination)
		for(var/obj/O in T)
			del(O)
		if(istype(T, /turf/simulated))
			del(T)

	for(var/mob/living/carbon/bug in destination)
		bug.gib()

	for(var/mob/living/simple_animal/pest in destination)
		pest.gib()

	origin.move_contents_to(destination, direction=direction)

	for(var/mob/M in destination)
		if(M.client)
			spawn(0)
				if(M.buckled && !iselevator)
					M << "\red Sudden acceleration presses you into your chair!"
					shake_camera(M, 3, 1)
				else if (!M.buckled)
					M << "\red The floor lurches beneath you!"
					shake_camera(M, iselevator? 2 : 10, 1)
		if(istype(M, /mob/living/carbon) && !iselevator)
			if(!M.buckled)
				M.Weaken(3)

	for(var/turf/T in origin) // WOW so hacky - who cares. Abby
		if(iselevator)
			if(istype(T,/turf/space))
				new /turf/simulated/floor/gm/empty(T)
		else if(istype(T,/turf/space))
			new /turf/simulated/floor/plating(T)

	return

//returns 1 if the shuttle has a valid arrive time
/datum/shuttle/proc/has_arrive_time()
	return (moving_status == SHUTTLE_INTRANSIT)

/*
/datum/shuttle/proc/play_engine_sound()
	for(var/obj/structure/enginesound/O in get_area(src))
		playsound(O.loc, 'sound/effects/engine_startup.ogg', 100, 1)
*/