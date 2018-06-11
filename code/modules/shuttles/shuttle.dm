//These lists are populated in /datum/shuttle_controller/New()
//Shuttle controller is instantiated in master_controller.dm.

//shuttle moving state defines are in setup.dm

/datum/shuttle
	var/warmup_time = 0
	var/moving_status = SHUTTLE_IDLE
	var/move_scheduled = 0
	var/turf/target_turf = null
	var/target_rotation = 0
	var/list/shuttle_turfs = null

	var/docking_controller_tag	//tag of the controller used to coordinate docking
	var/datum/computer/file/embedded_program/docking/docking_controller	//the controller itself. (micro-controller, not game controller)

	var/arrive_time = 0	//the time at which the shuttle arrives when long jumping

	//Important note: Shuttle code is a mess, recharge vars will only work fully on ferry type shuttles, aka everything but specops snowflake
	var/recharge_time = SHUTTLE_RECHARGE //Default recharge time attached to the shuttle itself
	var/recharging = 0 //How long until the shuttle has recharged and is ready to move again. Now a countdown instead of a boolean. Do NOT set this to a decimal

	var/can_be_optimized = 0 //Can we optimize the flight of this ship ?
	var/transit_optimized = 0 //Has the transit itself been optimized ?
	var/can_do_gun_mission = 0
	var/transit_gun_mission = 0 //is the flight a gun mission? (launch and then land back where you started)

	var/iselevator = 0 //Used to remove some shuttle related procs and texts to make it compatible with elevators
	var/almayerelevator = 0 //elevators on the almayer without limitations

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

	moving_status = SHUTTLE_WARMUP
	if(transit_optimized)
		recharging = round(recharge_time * SHUTTLE_OPTIMIZE_FACTOR_RECHARGE) //Optimized flight plan means less recharge time
	else
		recharging = recharge_time //Prevent the shuttle from moving again until it finishes recharging
	spawn(warmup_time*10)
		if (moving_status == SHUTTLE_IDLE)
			recharging = 0
			return	//someone canceled the launch

		if(transit_optimized)
			arrive_time = world.time + travel_time * 10 * SHUTTLE_OPTIMIZE_FACTOR_TRAVEL
		else
			arrive_time = world.time + travel_time * 10
		moving_status = SHUTTLE_INTRANSIT
		move(departing, interim, direction)
		spawn(1)
			close_doors(interim)

		while (world.time < arrive_time)
			sleep(5)

		sleep(100)

		move(interim, destination, direction)
		spawn(1)
			open_doors(destination)
		moving_status = SHUTTLE_IDLE

		//Simple, cheap ticker
		if(recharge_time)
			while(recharging > 0)
				recharging--
				sleep(1)

		transit_optimized = 0 //De-optimize the flight plans

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

	if (iselevator)	// Super snowflake code
		for (var/obj/machinery/computer/shuttle_control/ice_colony/C in area)
			C.animate_on()

		for (var/turf/closed/shuttle/elevator/gears/G in area)
			G.start()

		for (var/obj/machinery/door/airlock/D in area)//For elevators
			spawn(0)
				if (!D.density)
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

	if (iselevator)	// Super snowflake code
		for (var/obj/machinery/computer/shuttle_control/ice_colony/C in area)
			C.animate_off()

		for (var/turf/closed/shuttle/elevator/gears/G in area)
			G.stop()

		for (var/obj/machinery/door/airlock/D in area)//For elevators
			if (D.locked)
				spawn(0)
					D.unlock()
			if (D.density)
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
			if(istype(O, /obj/effect/landmark))
				continue
			cdel(O)
		cdel(T)

	for(var/mob/living/carbon/bug in destination)
		bug.gib()

	for(var/mob/living/simple_animal/pest in destination)
		pest.gib()

	origin.move_contents_to(destination, direction=direction)

	for(var/mob/M in destination)
		if(M.client)
			spawn(0)
				if(M.buckled && !iselevator)
					M << "\red Sudden acceleration presses you into [M.buckled]!"
					shake_camera(M, 3, 1)
				else if (!M.buckled)
					M << "\red The floor lurches beneath you!"
					shake_camera(M, iselevator? 2 : 10, 1)
		if(istype(M, /mob/living/carbon) && !iselevator)
			if(!M.buckled)
				M.KnockDown(3)

	for(var/turf/T in origin) // WOW so hacky - who cares. Abby
		if(iselevator)
			if(istype(T,/turf/open/space))
				if(T.z == 3)
					new /turf/open/floor/almayer/empty(T)
				else
					new /turf/open/gm/empty(T)
		else if(istype(T,/turf/open/space))
			new /turf/open/floor/plating(T)

	return

//returns 1 if the shuttle has a valid arrive time
/datum/shuttle/proc/has_arrive_time()
	return (moving_status == SHUTTLE_INTRANSIT)

/*
/datum/shuttle/proc/play_engine_sound()
	for(var/obj/structure/engine_startup_sound/O in get_area(src))
		playsound(O.loc, 'sound/effects/engine_startup.ogg', 75, 1)
*/
