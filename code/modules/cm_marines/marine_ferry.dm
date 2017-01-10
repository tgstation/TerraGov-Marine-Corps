//marine_ferry.dm
//by MadSnailDisease 12/29/16
//This is essentially a heavy rewrite of standard shuttle/ferry code that allows for the new backend system in shuttle_backend.dm
//Front-end this should look exactly the same, save for a minor timing difference (about 1-3 deciseconds)
//Some of this code is ported from the previous shuttle system and modified for these purposes.

/datum/shuttle/ferry/marine
	var/shuttle_tag

/datum/shuttle/ferry/marine/proc/launch_crash(var/user)
	if(!can_launch()) return //There's another computer trying to launch something

	in_use = user
	process_state = FORCE_CRASH

/*
	Please ensure that long_jump() and short_jump() are only called from here. This applies to subtypes as well.
	Doing so will ensure that multiple jumps cannot be initiated in parallel.
*/
/datum/shuttle/ferry/marine/process()

	switch(process_state)
		if (WAIT_LAUNCH)
			if (skip_docking_checks() || docking_controller.can_launch())

				//world << "shuttle/ferry/process: area_transition=[area_transition], travel_time=[travel_time]"
				if (move_time) long_jump()
				else short_jump()

				process_state = WAIT_ARRIVE

		if (FORCE_CRASH)
			if(move_time) long_jump_crash()
			else short_jump() //If there's no move time, we are doing this normally

			process_state = WAIT_ARRIVE

		if (FORCE_LAUNCH)
			if (move_time) long_jump()
			else short_jump()

			process_state = WAIT_ARRIVE

		if (WAIT_ARRIVE)
			if (moving_status == SHUTTLE_IDLE)
				dock()
				in_use = null	//release lock
				process_state = WAIT_FINISH

		if (WAIT_FINISH)
			if (skip_docking_checks() || docking_controller.docked() || world.time > last_dock_attempt_time + DOCK_ATTEMPT_TIMEOUT)
				process_state = IDLE_STATE
				arrived()

/datum/shuttle/ferry/marine/long_jump()
	set waitfor = 0

	if(moving_status != SHUTTLE_IDLE) return

	moving_status = SHUTTLE_WARMUP
	if(transit_optimized)
		recharging = round(recharge_time*0.75) //Optimized flight plan means less recharge time
	else
		recharging = recharge_time //Prevent the shuttle from moving again until it finishes recharging

	//START: Heavy lifting backend

	var/i //iterator
	var/turf/T_src
	var/turf/T_int //int stands for interim
	var/turf/T_trg
	var/obj/effect/landmark/shuttle_loc/marine_src/S
	var/obj/effect/landmark/shuttle_loc/marine_int/I
	var/obj/effect/landmark/shuttle_loc/marine_trg/T

	//Find source turf
	for(i in shuttlemarks)
		S = i
		if(!istype(S)) continue
		if(S.name == shuttle_tag)
			T_src = S.loc
			break

	//Find interim turf
	for(i in shuttlemarks)
		I = i
		if(!istype(I)) continue
		if(I.name == shuttle_tag)
			T_int = I.loc
			break

	//Find target turf
	for(i in shuttlemarks)
		T = i
		if(!istype(T)) continue
		if(T.name == shuttle_tag)
			T_trg = T.loc
			break

	//Switch the landmarks so we can do this again
	if(istype(S) || istype(T))
		S.loc = T_trg
		T.loc = T_src

	if(!istype(T_src) || !istype(T_int) || !istype(T_trg))
		message_admins("<span class=warning>Error with shuttles: Reference turfs not correctly instantiated. Code: MSD02.\n <font size=10>WARNING: DROPSHIP LAUNCH WILL FAIL</font></span>")
		log_admin("Error with shuttles: Reference turfs not correctly instantiated. Code: MSD02.")

	if(!istype(S) || !istype(I) || !istype(T))
		message_admins("<span class=warning>Error with shuttles: Landmarks not found. Code MSD03.\n <font size=10>WARNING: DROPSHIPS MAY NO LONGER BE OPERABLE</font></span>")
		log_admin("Error with shuttles: Landmarks not found. Code MSD03.")

	//END: Heavy lifting backend

	if (moving_status == SHUTTLE_IDLE)
		recharging = 0
		return	//someone canceled the launch

	var/travel_time = 0
	if(transit_optimized)
		travel_time = move_time*10*0.5
	else
		travel_time = move_time*10

	moving_status = SHUTTLE_INTRANSIT

	//START: Heavy lifting backend

	var/list/turfs_src = get_shuttle_turfs(T_src, shuttle_tag) //Which turfs are we moving?

	for(var/turf/A in turfs_src) //Lets play the startup sound in all of them
		for(var/obj/structure/engine_startup_sound/B in A)
			if(istype(B))
				playsound(B.loc, 'sound/effects/engine_startup.ogg', 100, 0, 10, -100)
				break //One sound thing per tile, just in case

	sleep(warmup_time*10) //Warming up

	close_doors(turfs_src) //Close the doors

	move_shuttle_to(T_int, null, turfs_src) //Get the turfs we arrived at
	var/list/turfs_int = get_shuttle_turfs(T_int, shuttle_tag) //Interim turfs
	var/list/turfs_trg = get_shuttle_turfs(T_trg, shuttle_tag) //Final destination turfs <insert bad jokey reference here>

	sleep(travel_time) //Wait while we fly

	var/turf/A
	for(i in turfs_trg) //Play the sounds on the ground
		A = i
		if(!istype(A)) continue
		for(var/obj/structure/engine_landing_sound/B in A)
			if(istype(B))
				playsound(B.loc, 'sound/effects/engine_landing.ogg', 100, 0, 10, -100)
				break

	for(i in turfs_int) //And in the air
		A = i
		if(!istype(A)) continue
		for(var/obj/structure/engine_inside_sound/B in A)
			if(istype(B))
				playsound(B.loc, 'sound/effects/engine_landing.ogg', 100, 0, 10, -100)
				break

	sleep(100) //Wait for it to finish

	move_shuttle_to(T_trg, null, turfs_int) //Not neccesary, but a little safer. This shouldn't actually change the variable

	//We have to get these again so we can close the doors
	//We didn't need to do it before since the hadn't moved yet
	turfs_trg = get_shuttle_turfs(T_trg, shuttle_tag)

	open_doors(turfs_trg) //And now open the doors

	//END: Heavy lifting backend

	moving_status = SHUTTLE_IDLE

	location = !location

	//Simple, cheap ticker
	if(recharge_time)
		while(--recharging) sleep(1)

	transit_optimized = 0 //De-optimize the flight plans

//Starts out exactly the same as long_jump()
//Differs in the target selection and later things enough to merit it's own proc
//The backend for landmarks should be in it's own proc, but I use too many vars resulting from the backend to save much space
/datum/shuttle/ferry/marine/proc/long_jump_crash()
	set waitfor = 0

	if(moving_status != SHUTTLE_IDLE) return

	moving_status = SHUTTLE_WARMUP
	if(transit_optimized)
		recharging = round(recharge_time*0.75) //Optimized flight plan means less recharge time
	else
		recharging = recharge_time //Prevent the shuttle from moving again until it finishes recharging

	//START: Heavy lifting backend

	var/i //iterator
	var/turf/T_src
	var/turf/T_int //int stands for interim
	var/turf/T_trg
	var/obj/effect/landmark/shuttle_loc/marine_src/S
	var/obj/effect/landmark/shuttle_loc/marine_int/I
	var/obj/effect/landmark/shuttle_loc/marine_crs/C

	//Find source turf
	for(i in shuttlemarks)
		S = i
		if(!istype(S)) continue
		if(S.name == shuttle_tag)
			T_src = S.loc
			break

	//Find interim turf
	for(i in shuttlemarks)
		I = i
		if(!istype(I)) continue
		if(I.name == shuttle_tag)
			T_int = I.loc
			break

	var/list/crash_turfs = list()
	//Find target turf
	for(i in shuttlemarks)
		C = i
		if(!istype(C)) continue
		if(C.name == shuttle_tag)
			crash_turfs.Add(C.loc)

	T_trg = pick(crash_turfs)

	if(!istype(T_src) || !istype(T_int) || !istype(T_trg))
		message_admins("<span class=warning>Error with shuttles: Reference turfs not correctly instantiated. Code: MSD04.\n WARNING: DROPSHIP LAUNCH WILL FAIL</span>")
		log_admin("Error with shuttles: Reference turfs not correctly instantiated. Code: MSD04.")

	if(!istype(S) || !istype(I))
		message_admins("<span class=warning>Error with shuttles: Landmarks not found. Code MSD05.\n WARNING: DROPSHIPS MAY NO LONGER BE OPERABLE</span>")
		log_admin("Error with shuttles: Landmarks not found. Code MSD05.")

	//END: Heavy lifting backend

	if (moving_status == SHUTTLE_IDLE)
		recharging = 0
		return	//someone canceled the launch

	var/travel_time = 0
	if(transit_optimized)
		travel_time = move_time*10*0.5
	else
		travel_time = move_time*10

	moving_status = SHUTTLE_INTRANSIT

	//START: Heavy lifting backend

	var/list/turfs_src = get_shuttle_turfs(T_src, shuttle_tag) //Which turfs are we moving?

	for(var/turf/A in turfs_src) //Lets play the startup sound in all of them
		for(var/obj/structure/engine_startup_sound/B in A)
			if(istype(B))
				playsound(B.loc, 'sound/effects/engine_startup.ogg', 100, 0, 10, -100)
				break //One sound thing per tile, just in case

	sleep(warmup_time*10) //Warming up

	close_doors(turfs_src) //Close the doors

	move_shuttle_to(T_int, null, turfs_src)
	var/list/turfs_int = get_shuttle_turfs(T_int, shuttle_tag) //Interim turfs

	sleep(travel_time) //Wait while we fly, but give extra time for crashing announcements etc

	//This is where things change and shit gets real

	command_announcement.Announce("WARNING: DROPSHIP ON COLLISION COURSE WITH THE SULACO. CRASH IMMINENT. ABORT DOCKING ATTEMPT IMMEDIATELY." , "Dropship Alert", new_sound='sound/misc/queen_alarm.ogg')

	var/turf/A
	for(i in turfs_int) //Play the landing sound in the shuttle
		A = i
		if(!istype(A)) continue
		for(var/obj/structure/engine_inside_sound/B in A)
			if(istype(B))
				playsound(B.loc, 'sound/effects/engine_landing.ogg', 100, 0, 10, -100)
				break

	sleep(85)

	var/turf/sploded
	for(var/j=0; j<5; j++)
		sploded = locate(T_trg.x + rand(-5, 10), T_trg.y + rand(-5, 10), T_trg.z)
		//Fucking. Kaboom.
		explosion(sploded, 0, 2, 5, 0)
		sleep(3)

	var/list/turfs_trg = get_shuttle_turfs(T_trg, shuttle_tag) //Final destination turfs <insert bad jokey reference here>

	move_shuttle_to(T_trg, null, turfs_int)

	//We have to get these again so we can close the doors
	//We didn't need to do it before since the hadn't moved yet
	turfs_trg = get_shuttle_turfs(T_trg, shuttle_tag)

	open_doors_crashed(turfs_trg) //And now open the doors

	//Stolen from events.dm. WARNING: This code is old as hell
	for (var/obj/machinery/power/apc/APC in machines)
		if(APC.z == 3 || APC.z == 4)
			APC.ion_act()
	for (var/obj/machinery/power/smes/SMES in machines)
		if(SMES.z == 3 || SMES.z == 4)
			SMES.ion_act()

	//END: Heavy lifting backend

	//And now that we've crashed, we are never flying again
	sleep(100)
	//But first lets make sure all of our procs elsewhere are fixed
	del(src)


/datum/shuttle/ferry/marine/short_jump()

	if(moving_status != SHUTTLE_IDLE) return

	//START: Heavy lifting backend

	var/i //iterator
	var/turf/T_src
	var/turf/T_trg
	var/obj/effect/landmark/shuttle_loc/marine_src/S
	var/obj/effect/landmark/shuttle_loc/marine_trg/T

	//Find our target turf
	for(i in shuttlemarks)
		S = i
		if(!istype(S)) continue
		if(S.name == shuttle_tag)
			T_src = S.loc
			break

	//Find our source turf
	for(i in shuttlemarks)
		T = i
		if(!istype(T)) continue
		if(T.name == shuttle_tag)
			T_trg = T.loc
			break

	//Switch the landmarks so we can do this again
	if(istype(S) || istype(T))
		S.loc = T_trg
		T.loc = T_src
	else
		message_admins("<span class=warning>Error with shuttles: Landmarks not found. Code: MSD01.\n <font size=10>WARNING: DROPSHIPS MAY NO LONGER BE OPERABLE</font></span>")
		log_admin("Error with shuttles: Landmarks not found. Code: MSD01.")
		message_admins("[istype(S) ? "T" : "S"] is null")

	//END: Heavy lifting backend

	moving_status = SHUTTLE_WARMUP
	sleep(warmup_time*10)

	if (moving_status == SHUTTLE_IDLE)
		return	//someone cancelled the launch

	moving_status = SHUTTLE_INTRANSIT //shouldn't matter but just to be safe

	var/list/turfs_src = get_shuttle_turfs(T_src, shuttle_tag)
	move_shuttle_to(T_trg, null, turfs_src)

	moving_status = SHUTTLE_IDLE

	location = !location

/obj/machinery/door/poddoor/shutters/transit
	name = "Transit shutters"
	desc = "Safety shutters to prevent dangerous depressurization during flight"
	unacidable = 1

/datum/shuttle/ferry/marine/close_doors(var/list/L)

	var/i //iterator
	var/turf/T

	for(i in L)
		T = i
		if(!istype(T)) continue

		//I know an iterator is faster, but this broke for some reason when I used it so I won't argue
		for(var/obj/machinery/door/poddoor/shutters/transit/ST in T)
			if(!istype(ST)) continue
			if(!ST.density)
				//"But MadSnailDisease!", you say, "Don't use spawn! Use sleep() and waitfor instead!
				//Well you would be right if close() were different, but alas it is not.
				//Without spawn(), it closes each door one at a time.
				//"Well then why not change the proc itself?"
				//Excellent question!
				//Because when you open doors by Bumped() it would have you fly through before the animation is complete
				spawn(0)
					ST.close()
					ST.update_nearby_tiles(1)
				break

		//Elevators
		for(var/obj/machinery/door/airlock/A in T)
			if(!istype(A)) continue
			if (iselevator)
				if(!A.density)
					spawn(0)
						A.close()
						A.lock()
						A.update_nearby_tiles(1)
				else
					A.lock() //We need this here since it's important to lock and update AFTER its closed
					A.update_nearby_tiles(1)
				break

/datum/shuttle/ferry/marine/open_doors(var/list/L)

	var/i //iterator
	var/turf/T

	for(i in L)
		T = i
		if(!istype(T)) continue

		//Just so marines can't land with shutters down and turtle the rasputin
		for(var/obj/machinery/door/poddoor/shutters/P in T)
			if(!istype(P)) continue
			if(P.density)
				spawn(0)
					P.open()
					P.update_nearby_tiles(1)
				//No break since transit shutters are the same parent type

		for(var/obj/machinery/door/airlock/A in T)
			if(!istype(A)) continue
			if (iselevator)
				if(A.locked)
					A.unlock()
				if(A.density)
					spawn(0)
						A.open()
						A.update_nearby_tiles(1)
				break

/datum/shuttle/ferry/marine/proc/open_doors_crashed(var/list/L)

	var/i //iterator
	var/turf/T

	for(i in L)
		T = i
		if(!istype(T)) continue

		if(istype(T, /turf/simulated/wall))
			var/turf/simulated/wall/W = T
			if(prob(20)) W.thermitemelt()
			else if(prob(25)) W.take_damage(W.damage_cap) //It should leave a girder
			continue

		//Just so marines can't land with shutters down and turtle the rasputin
		for(var/obj/machinery/door/poddoor/shutters/P in T)
			if(!istype(P)) continue
			if(P.density)
				spawn(0)
					P.open()
					P.update_nearby_tiles(1)
				//No break since transit shutters are the same parent type

		for(var/obj/structure/mineral_door/resin/R in T)
			if(istype(R))
				del(R) //This is all that it's dismantle() does so this is okay
				break