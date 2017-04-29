//marine_ferry.dm
//by MadSnailDisease 12/29/16
//This is essentially a heavy rewrite of standard shuttle/ferry code that allows for the new backend system in shuttle_backend.dm
//Front-end this should look exactly the same, save for a minor timing difference (about 1-3 deciseconds)
//Some of this code is ported from the previous shuttle system and modified for these purposes.


/*
/client/verb/TestAlmayerEvac()
	set name = "Test Almayer Evac"

	for(var/datum/shuttle/ferry/marine/M in shuttle_controller.process_shuttles)
		if(M.info_tag == "Almayer Evac" || M.info_tag == "Alt Almayer Evac")
			spawn(1)
				M.short_jump()
				world << "LAUNCHED THING WITH TAG [M.shuttle_tag]"
		else if(M.info_tag == "Almayer Dropship")
			spawn(1)
				M.short_jump()
				world << "LAUNCHED THING WITH TAG [M.shuttle_tag]"
		else world << "did not launch thing with tag [M.shuttle_tag]"
*/

/datum/shuttle/ferry/marine
	var/shuttle_tag //Unique ID for finding which landmarks to use
	var/info_tag //Identifies which coord datums to copy
	var/list/info_datums = list()
	//For now it's just one location all around, but that can be adjusted.
	var/locs_dock = list()
	var/locs_move = list()
	var/locs_land = list()
	//Could be a list, but I don't see a reason considering shuttles aren't bloated with variables.
	var/sound_target = 136//Where the sound will originate from. Must be a list index, usually the center bottom (engines).
	var/sound/sound_takeoff	= 'sound/effects/engine_startup.ogg'//Takeoff sounds.
	var/sound/sound_landing = 'sound/effects/engine_landing.ogg'//Landing sounds.
	var/sound/sound_moving //Movement sounds, usually not applicable.
	var/sound/sound_misc //Anything else, like escape pods.

/datum/shuttle/ferry/marine/proc/load_datums()
	if(!(info_tag in s_info))
		message_admins("<span class=warning>Error with shuttles: Shuttle tag does not exist. Code: MSD10.\n WARNING: DROPSHIP LAUNCH WILL PROBABLY FAIL</span>")
		log_admin("Error with shuttles: Shuttle tag does not exist. Code: MSD10.")

	var/list/L = s_info[info_tag]
	info_datums = L.Copy()

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

	//Simple pick() process for now, but this should be changed later.
	var/turf/T_src = pick(locs_dock)
	var/src_rot = locs_dock[T_src]
	var/turf/T_int = pick(locs_move)//int stands for interim
	var/int_rot = locs_move[T_int]
	var/turf/T_trg = pick(locs_land)
	var/trg_rot = locs_land[T_trg]

	if(!istype(T_src) || !istype(T_int) || !istype(T_trg))
		message_admins("<span class=warning>Error with shuttles: Reference turfs not correctly instantiated. Code: MSD02.\n <font size=10>WARNING: DROPSHIP LAUNCH WILL FAIL</font></span>")
		log_admin("Error with shuttles: Reference turfs not correctly instantiated. Code: MSD02.")

	//Switch the landmarks so we can do this again
	locs_dock -= T_src
	locs_land -= T_trg
	locs_dock |= T_trg
	locs_land |= T_src

//	if(!istype(S) || !istype(I) || !istype(T))
//		message_admins("<span class=warning>Error with shuttles: Landmarks not found. Code MSD03.\n <font size=10>WARNING: DROPSHIPS MAY NO LONGER BE OPERABLE</font></span>")
//		log_admin("Error with shuttles: Landmarks not found. Code MSD03.")

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

	var/list/turfs_src = get_shuttle_turfs(T_src, info_datums) //Which turfs are we moving?

	playsound(turfs_src[sound_target], sound_takeoff, 100, 0, 10, -100)

	sleep(warmup_time*10) //Warming up

	close_doors(turfs_src) //Close the doors

	move_shuttle_to(T_int, null, turfs_src, 0 , int_rot, src) //Rotate by the angle at the destination, not the source
	var/list/turfs_int = get_shuttle_turfs(T_int, info_datums) //Interim turfs
	var/list/turfs_trg = get_shuttle_turfs(T_trg, info_datums) //Final destination turfs <insert bad jokey reference here>

	sleep(travel_time) //Wait while we fly
	playsound(turfs_int[sound_target], sound_landing, 100, 0, 10, -100)
	playsound(turfs_trg[sound_target], sound_landing, 100, 0, 10, -100)

	sleep(100) //Wait for it to finish

	move_shuttle_to(T_trg, null, turfs_int, 0, trg_rot, src)

	//Now that we've landed, assuming some rotation including 0, we need to make sure it doesn't fuck up when we go back
	locs_move[T_int] = -1*trg_rot
	locs_dock[T_trg] = src_rot
	locs_land[T_src] = trg_rot

	//We have to get these again so we can close the doors
	//We didn't need to do it before since they hadn't moved yet
	turfs_trg = get_shuttle_turfs(T_trg, info_datums)

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
	var/turf/T_src = pick(locs_dock)
	var/src_rot = locs_dock[T_src]
	var/turf/T_int = pick(locs_move)//int stands for interim
	var/turf/T_trg = pick(shuttle_controller.locs_crash)

	if(!istype(T_src) || !istype(T_int) || !istype(T_trg))
		message_admins("<span class=warning>Error with shuttles: Reference turfs not correctly instantiated. Code: MSD04.\n WARNING: DROPSHIP LAUNCH WILL FAIL</span>")
		log_admin("Error with shuttles: Reference turfs not correctly instantiated. Code: MSD04.")

	shuttle_controller.locs_crash -= T_trg

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

	var/list/turfs_src = get_shuttle_turfs(T_src, info_datums) //Which turfs are we moving?
	playsound(turfs_src[sound_target], sound_takeoff, 100, 0, 10, -100)

	sleep(warmup_time*10) //Warming up

	close_doors(turfs_src) //Close the doors

	move_shuttle_to(T_int, null, turfs_src, , , src)
	var/list/turfs_int = get_shuttle_turfs(T_int, info_datums) //Interim turfs

	sleep(travel_time) //Wait while we fly, but give extra time for crashing announcements etc

	//This is where things change and shit gets real

	command_announcement.Announce("WARNING: DROPSHIP ON COLLISION COURSE WITH THE SULACO. CRASH IMMINENT. ABORT DOCKING ATTEMPT IMMEDIATELY." , "Dropship Alert", new_sound='sound/misc/queen_alarm.ogg')

	playsound(turfs_int[sound_target], sound_landing, 100, 0, 10, -100)

	sleep(85)

	shake_cameras(turfs_int) //shake for 1.5 seconds before crash, 0.5 after

	var/turf/sploded
	for(var/j=0; j<5; j++)
		sploded = locate(T_trg.x + rand(-5, 10), T_trg.y + rand(-5, 10), T_trg.z)
		//Fucking. Kaboom.
		explosion(sploded, 0, 0, 6, 0)
		sleep(3)

	var/list/turfs_trg = get_shuttle_turfs(T_trg, info_datums) //Final destination turfs <insert bad jokey reference here>

	move_shuttle_to(T_trg, null, turfs_int, 0, src_rot, src)

	//We have to get these again so we can close the doors
	//We didn't need to do it before since the hadn't moved yet
	turfs_trg = get_shuttle_turfs(T_trg, info_datums)

	open_doors_crashed(turfs_trg) //And now open the doors

	//Stolen from events.dm. WARNING: This code is old as hell
	for (var/obj/machinery/power/apc/APC in machines)
		if(APC.z == 3 || APC.z == 4)
			APC.ion_act()
	for (var/obj/machinery/power/smes/SMES in machines)
		if(SMES.z == 3 || SMES.z == 4)
			SMES.ion_act()

	//END: Heavy lifting backend

	sleep(100)
	moving_status = SHUTTLE_CRASHED

/datum/shuttle/ferry/marine/short_jump()

	if(moving_status != SHUTTLE_IDLE) return

	//START: Heavy lifting backend

	var/turf/T_src = pick(locs_dock)
	var/turf/T_trg = pick(locs_land)
	var/trg_rot = locs_land[T_trg]

	//Switch the landmarks so we can do this again
	if(!istype(T_src) || !istype(T_trg))
		message_admins("<span class=warning>Error with shuttles: Ref turfs are null. Code: MSD15.\n WARNING: DROPSHIPS MAY NO LONGER BE OPERABLE</span>")
		log_admin("Error with shuttles: Ref turfs are null. Code: MSD15.")
		r_FAL

	locs_dock -= T_src
	locs_land -= T_trg
	locs_dock |= T_trg
	locs_land |= T_src

	//END: Heavy lifting backend

	moving_status = SHUTTLE_WARMUP
	sleep(warmup_time*10)

	if (moving_status == SHUTTLE_IDLE)
		return	//someone cancelled the launch

	moving_status = SHUTTLE_INTRANSIT //shouldn't matter but just to be safe

	var/list/turfs_src = get_shuttle_turfs(T_src, info_datums)
	move_shuttle_to(T_trg, null, turfs_src, 0, trg_rot, src)

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

/datum/shuttle/ferry/marine/proc/shake_cameras(var/list/L)

	var/i //iterator
	var/j
	var/turf/T
	var/mob/M

	for(i in L)
		T = i
		if(!istype(T)) continue

		for(j in T)
			M = j
			if(!istype(M)) continue
			shake_camera(M, 20, 1)

/client/proc/force_shuttle()
	set name = "Force Dropship"
	set desc = "Force a dropship to launch"
	set category = "Admin"

	var/tag = input("Which dropship should be forced?", "Select a dropship:") in list("Dropship 1", "Dropship 2")
	var/crash = 0
	switch(alert("Would you like to force a crash?", , "Yes", "No", "Cancel"))
		if("Yes") crash = 1
		if("No") crash = 0
		if("Cancel") return

	var/datum/shuttle/ferry/marine/dropship = shuttle_controller.shuttles[tag]
	if(!dropship)
		src << "<span class='danger'>Error: Attempted to force a dropship launch but the shuttle datum was null. Code: MSD_FSV_DIN</span>"
		log_admin("Error: Attempted to force a dropship launch but the shuttle datum was null. Code: MSD_FSV_DIN")

	if(crash && dropship.location != 1)
		switch(alert("Error: Shuttle is on the ground. Proceed with standard launch anyways?", , "Yes", "No"))
			if("Yes")
				dropship.process_state = WAIT_LAUNCH
				log_admin("[usr] ([usr.key]) forced a [dropship.iselevator? "elevator" : "shuttle"] using the Force Dropship verb")
			if("No")
				src << "<span class='warning'>Aborting shuttle launch.</span>"
				return
	else if(crash)
		dropship.process_state = FORCE_CRASH
	else
		dropship.process_state = WAIT_LAUNCH
