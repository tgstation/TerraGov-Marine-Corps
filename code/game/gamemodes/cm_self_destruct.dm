/*
TODO
Look into animation screen not showing on self destruct and other weirdness
Intergrate distress into this controller.
Finish nanoui conversion for comm console.
Make sure people who get nuked and wake up from SSD don't live.
Add flashing lights to evac. //DEFERRED TO BETTER LIGHTING
Finish the game mode announcement thing.
Fix escape doors to work properly.
*/

#define SELF_DESTRUCT_ROD_STARTUP_TIME 12000

/*
How this works:

First: All of the linking is done automatically on world start, so nothing needs to be done on that end other than making
sure that objects are actually placed in the game world. If not, the game will error and let you know about it. But you
don't need to modify variables or worry about area placement. It's all done for you.
The rods, for example, configure the time per activation based on their number. Shuttles link their own machines via area.
Nothing in this controller is linked to game mode, so it's stand alone, more or less, but it's best used during a game mode.
Admins have a lot of tools in their disposal via the check antagonist panel, and devs can access the VV of this controller
through that panel.

Second: The communication console handles most of the IC triggers for activating these functions, the rest is handled elsewhere.
Check communications.dm for that. shuttle_controller.dm handles the set up for the escape pods. escape_pods.dm handles most of the
functions of the escape pods themselves. This file would likely need to be broken down into individual parts at some point in the
future.

Evacuation takes place when sufficient alert level is reaised and a distress beacon was launched. All of the evac pods come online
and open their doors to allow entry inside. Characters may then get inside of the cryo units to before the shuttles automatically launch.
If wanted, a nearby controller object may launch each individual shuttle early. Only three people may ride on a shuttle to escape,
otherwise the launch will fail and the shuttle will become inoperable.
Any launched shuttles are taken out of the game. If the evacuation is canceled, any persons inside of the cryo tubes will be ejected.
They may temporarily open the door to exit if they are stuck inside after evac is canceled.

When the self destruct is enabled, the console comes online. This usually happens during an evacuation. Once the console is
interacted with, it fires up the self-destruct sequence. Several rods rise and must be interacted with in order to arm the system.
Once that happens, the console must be interacted with again to trigger the self destruct. The self destruct may also be
canceled from the console.

The self destruct may also happen if a nuke is detonated on the ship's zlevel; if it is detonated elsewhere, the ship will not blow up.
Regardless of where it's detonated, or how, a successful detonation will end the round or automatically restart the game.

All of the necessary difines are stored under mode.dm in defines.
*/

var/global/datum/authority/branch/evacuation/EvacuationAuthority //This is initited elsewhere so that the world has a chance to load in.

/datum/authority/branch/evacuation
	name = "Evacuation Authority"
	var/evac_time	//Time the evacuation was initiated.
	var/evac_status = EVACUATION_STATUS_STANDING_BY //What it's doing now? It can be standing by, getting ready to launch, or finished.

	var/obj/machinery/self_destruct/console/dest_master //The main console that does the brunt of the work.
	var/dest_rods[] //Slave devices to make the explosion work.
	var/dest_cooldown //How long it takes between rods, determined by the amount of total rods present.
	var/dest_index = 1	//What rod the thing is currently on.
	var/dest_status = NUKE_EXPLOSION_INACTIVE

	var/flags_scuttle = NOFLAGS

	New()
		..()
		dest_master = locate()
		if(!dest_master)
			log_debug("ERROR CODE SD1: could not find master self-destruct console")
			world << "<span class='debuginfo'>ERROR CODE SD1: could not find master self-destruct console</span>"
			r_FAL
		dest_rods = new
		for(var/obj/machinery/self_destruct/rod/I in dest_master.loc.loc) dest_rods += I
		if(!dest_rods.len)
			log_debug("ERROR CODE SD2: could not find any self destruct rods")
			world << "<span class='debuginfo'>ERROR CODE SD2: could not find any self destruct rods</span>"
			cdel(dest_master)
			dest_master = null
			r_FAL
		dest_cooldown = SELF_DESTRUCT_ROD_STARTUP_TIME / dest_rods.len
		dest_master.desc = "The main operating panel for a self-destruct system. It requires very little user input, but the final safety mechanism is manually unlocked.\nAfter the initial start-up sequence, [dest_rods.len] control rods must be armed, followed by manually flipping the detonation switch."

/datum/authority/branch/evacuation/proc/get_affected_zlevels() //This proc returns the ship's z level list (or whatever specified), when an evac/self destruct happens.
	if(dest_status < NUKE_EXPLOSION_IN_PROGRESS && evac_status == EVACUATION_STATUS_COMPLETE) //Nuke is not in progress and evacuation finished, end the round on ship and low orbit (dropships in transit) only.
		. = MAIN_SHIP_AND_DROPSHIPS_Z_LEVELS

#undef SELF_DESTRUCT_ROD_STARTUP_TIME
//=========================================================================================
//=========================================================================================
//=====================================EVACUATION==========================================
//=========================================================================================
//=========================================================================================


/datum/authority/branch/evacuation/proc/initiate_evacuation() //Begins the evacuation procedure.
	if(evac_status == EVACUATION_STATUS_STANDING_BY && !(flags_scuttle & FLAGS_EVACUATION_DENY))
		enter_allowed = 0 //No joining during evac.
		evac_time = world.time
		evac_status = EVACUATION_STATUS_INITIATING
		ai_system.Announce("Attention. Emergency. All personel must evacuate immediately. You have [round(EVACUATION_ESTIMATE_DEPARTURE/60,1)] minute\s until departure.", 'sound/AI/evacuate.ogg')
		xeno_message("A wave of adrenaline ripples through the hive. The fleshy creatures are trying to escape!")
		var/datum/shuttle/ferry/marine/evacuation_pod/P
		for(var/i = 1 to MAIN_SHIP_ESCAPE_POD_NUMBER)
			P = shuttle_controller.shuttles["[MAIN_SHIP_NAME] Evac [i]"]
			P.toggle_ready()
		process_evacuation()
		r_TRU

/datum/authority/branch/evacuation/proc/cancel_evacuation() //Cancels the evac procedure. Useful if admins do not want the marines leaving.
	if(evac_status == EVACUATION_STATUS_INITIATING)
		enter_allowed = 1
		evac_time = null
		evac_status = EVACUATION_STATUS_STANDING_BY
		ai_system.Announce("Evacuation has been cancelled.", 'sound/AI/evacuate_cancelled.ogg')
		var/datum/shuttle/ferry/marine/evacuation_pod/P
		for(var/i = 1 to MAIN_SHIP_ESCAPE_POD_NUMBER)
			P = shuttle_controller.shuttles["[MAIN_SHIP_NAME] Evac [i]"]
			P.toggle_ready()
		r_TRU

/datum/authority/branch/evacuation/proc/begin_launch() //Launches the pods.
	if(evac_status == EVACUATION_STATUS_INITIATING)
		evac_status = EVACUATION_STATUS_IN_PROGRESS //Cannot cancel at this point. All shuttles are off.
		spawn() //One of the few times spawn() is appropriate. No need for a new proc.
			ai_system.Announce("WARNING: Evacuation order confirmed. Launching escape pods.", 'sound/AI/evacuation_confirmed.ogg')
			var/datum/shuttle/ferry/marine/evacuation_pod/P
			var/L[] = new
			var/i
			for(i = 1 to MAIN_SHIP_ESCAPE_POD_NUMBER) L += i
			while(L.len)
				i = pick(L)
				P = shuttle_controller.shuttles["[MAIN_SHIP_NAME] Evac [i]"]
				P.prepare_for_launch() //May or may not launch, will do everything on its own.
				L -= i
				sleep(50) //Sleeps 5 seconds each launch.
			sleep(300) //Sleep 30 more seconds to make sure everyone had a chance to leave.
			ai_system.Announce("ATTENTION: Evacuation complete. Outbound lifesigns detected: [P.passengers ? P.passengers  : "none"].", 'sound/AI/evacuation_complete.ogg')
			evac_status = EVACUATION_STATUS_COMPLETE
		r_TRU

/datum/authority/branch/evacuation/proc/process_evacuation() //Process the timer.
	set background = 1

	spawn while(evac_status == EVACUATION_STATUS_INITIATING) //If it's not departing, no need to process.
		if(world.time >= evac_time + EVACUATION_AUTOMATIC_DEPARTURE) begin_launch()
		sleep(10) //One second.

/datum/authority/branch/evacuation/proc/get_status_panel_eta()
	switch(evac_status)
		if(EVACUATION_STATUS_INITIATING)
			var/eta = EVACUATION_ESTIMATE_DEPARTURE
			. = "[(eta / 60) % 60]:[add_zero(num2text(eta % 60), 2)]"
		if(EVACUATION_STATUS_IN_PROGRESS) . = "NOW"

//=========================================================================================
//=========================================================================================
//=====================================SELF DETRUCT========================================
//=========================================================================================
//=========================================================================================

#define SELF_DESTRUCT_MACHINE_INACTIVE 0
#define SELF_DESTRUCT_MACHINE_ACTIVE 1
#define SELF_DESTRUCT_MACHINE_ARMED 2

/datum/authority/branch/evacuation/proc/enable_self_destruct()
	if(dest_status == NUKE_EXPLOSION_INACTIVE && !(flags_scuttle & FLAGS_SELF_DESTRUCT_DENY))
		dest_status = NUKE_EXPLOSION_ACTIVE
		dest_master.lock_or_unlock()
		set_security_level(SEC_LEVEL_DELTA) //also activate Delta alert, to open the SD shutters.
		r_TRU

//Override is for admins bypassing normal player restrictions.
/datum/authority/branch/evacuation/proc/cancel_self_destruct(override)
	if(dest_status == NUKE_EXPLOSION_ACTIVE)
		var/obj/machinery/self_destruct/rod/I
		var/i
		for(i in EvacuationAuthority.dest_rods)
			I = i
			if(I.active_state == SELF_DESTRUCT_MACHINE_ARMED && !override)
				dest_master.state("<span class='warning'>WARNING: Unable to cancel detonation. Please disarm all control rods.</span>")
				r_FAL

		dest_status = NUKE_EXPLOSION_INACTIVE
		dest_master.in_progress = 1
		for(i in dest_rods)
			I = i
			if(I.active_state == SELF_DESTRUCT_MACHINE_ACTIVE || (I.active_state == SELF_DESTRUCT_MACHINE_ARMED && override)) I.lock_or_unlock(1)
		dest_master.lock_or_unlock(1)
		dest_index = 1
		ai_system.Announce("The emergency destruct system has been deactivated.", 'sound/AI/selfdestruct_deactivated.ogg')
		if(evac_status == EVACUATION_STATUS_STANDING_BY) //the evac has also been cancelled or was never started.
			set_security_level(SEC_LEVEL_RED, TRUE) //both SD and evac are inactive, lowering the security level.
		r_TRU

/datum/authority/branch/evacuation/proc/initiate_self_destruct(override)
	if(dest_status < NUKE_EXPLOSION_IN_PROGRESS)
		var/obj/machinery/self_destruct/rod/I
		var/i
		for(i in dest_rods)
			I = i
			if(I.active_state != SELF_DESTRUCT_MACHINE_ARMED && !override)
				dest_master.state("<span class='warning'>WARNING: Unable to trigger detonation. Please arm all control rods.</span>")
				r_FAL
		dest_master.in_progress = !dest_master.in_progress
		for(i in EvacuationAuthority.dest_rods)
			I = i
			I.in_progress = 1
		ai_system.Announce("DANGER. DANGER. Self destruct system activated. DANGER. DANGER. Self destruct in progress. DANGER. DANGER.")
		trigger_self_destruct(,,override)
		r_TRU

/datum/authority/branch/evacuation/proc/trigger_self_destruct(list/z_levels = list(MAIN_SHIP_Z_LEVEL), origin = dest_master, override)
	set waitfor = 0
	if(dest_status < NUKE_EXPLOSION_IN_PROGRESS) //One more check for good measure, in case it's triggered through a bomb instead of the destruct mechanism/admin panel.
		enter_allowed = 0 //Do not want baldies spawning in as everything is exploding.
		dest_status = NUKE_EXPLOSION_IN_PROGRESS
		playsound(origin, 'sound/machines/Alarm.ogg', 75, 0, 30)
		world << pick('sound/theme/nuclear_detonation1.ogg','sound/theme/nuclear_detonation2.ogg')

		var/ship_status = 1
		for(var/i in z_levels)
			if(i == MAIN_SHIP_Z_LEVEL)
				ship_status = 0 //Destroyed.
			break

		var/L1[] = new //Everyone who will be destroyed on the zlevel(s).
		var/L2[] = new //Everyone who only needs to see the cinematic.
		var/mob/M
		var/turf/T
		for(M in player_list) //This only does something cool for the people about to die, but should prove pretty interesting.
			if(!M || !M.loc) continue //In case something changes when we sleep().
			T = get_turf(M)
			if(T.z in z_levels)
				if(M.stat == DEAD)
					L2 |= M
				else
					L1 |= M
					shake_camera(M, 110, 4)


		sleep(100)
		/*Hardcoded for now, since this was never really used for anything else.
		Would ideally use a better system for showing cutscenes.*/
		var/obj/screen/cinematic/explosion/C = new

		for(M in L1 + L2)
			if(M && M.loc && M.client)
				M.client.screen |= C //They may have disconnected in the mean time.

		sleep(15) //Extra 1.5 seconds to look at the ship.
		flick(override ? "intro_override" : "intro_nuke", C)
		sleep(35)
		for(M in L1)
			if(M && M.loc) //Who knows, maybe they escaped, or don't exist anymore.
				T = get_turf(M)
				if(T.z in z_levels)
					M.death()
				else
					M.client.screen -= C //those who managed to escape the z level at last second shouldn't have their view obstructed.
		flick(ship_status ? "ship_spared" : "ship_destroyed", C)
		world << sound('sound/effects/explosionfar.ogg')
		C.icon_state = ship_status ? "summary_spared" : "summary_destroyed"

		dest_status = NUKE_EXPLOSION_FINISHED

		if(!ticker || !ticker.mode) //Just a safety, just in case a mode isn't running, somehow.
			world << "<span class='round_body'>Resetting in 30 seconds!</span>"
			sleep(300)
			log_game("Rebooting due to nuclear detonation.")
			world.Reboot()
		r_TRU

/datum/authority/branch/evacuation/proc/process_self_destruct()
	set background = 1

	spawn while(dest_master && dest_master.loc && dest_master.active_state == SELF_DESTRUCT_MACHINE_ARMED && dest_status == NUKE_EXPLOSION_ACTIVE && dest_index <= dest_rods.len)
		var/obj/machinery/self_destruct/rod/I = dest_rods[dest_index]
		if(world.time >= dest_cooldown + I.activate_time)
			I.lock_or_unlock() //Unlock it.
			if(++dest_index <= dest_rods.len)
				I = dest_rods[dest_index]//Start the next sequence.
				I.activate_time = world.time
		sleep(10) //Checks every second. Could integrate into another controller for better tracking.

//Generic parent base for the self_destruct items.
/obj/machinery/self_destruct
	icon = 'icons/obj/machines/self_destruct.dmi'
	use_power = 0 //Runs unpowered, may need to change later.
	density = 0
	anchored = 1 //So it doesn't go anywhere.
	unacidable = 1 //Cannot C4 it either.
	mouse_opacity = 0 //No need to click or interact with this initially.
	var/in_progress = 0 //Cannot interact with while it's doing something, like an animation.
	var/active_state = SELF_DESTRUCT_MACHINE_INACTIVE //What step of the process it's on.

	New()
		..()
		icon_state += "_1"

	Dispose()
		. = ..()
		machines -= src
		operator = null

	ex_act(severity) r_FAL

	attack_hand()
		if(..() || in_progress) r_FAL //This check is backward, ugh.
		r_TRU

//Add sounds.
/obj/machinery/self_destruct/proc/lock_or_unlock(lock)
	set waitfor = 0
	in_progress = 1
	flick(initial(icon_state) + (lock? "_5" : "_2"),src)
	sleep(9)
	mouse_opacity = !mouse_opacity
	icon_state = initial(icon_state) + (lock? "_1" : "_3")
	in_progress = 0
	active_state = active_state > SELF_DESTRUCT_MACHINE_INACTIVE ? SELF_DESTRUCT_MACHINE_INACTIVE : SELF_DESTRUCT_MACHINE_ACTIVE

/obj/machinery/self_destruct/console
	name = "self destruct control panel"
	icon_state = "console"

	Dispose()
		. = ..()
		EvacuationAuthority.dest_master = null
		EvacuationAuthority.dest_rods = null

	lock_or_unlock(lock)
		playsound(src, 'sound/machines/hydraulics_1.ogg', 25, 1)
		..()

	//TODO: Add sounds.
	attack_hand(mob/user)
		. = ..()
		if(.) ui_interact(user)

	Topic(href, href_list)
		if(..()) r_TRU
		switch(href_list["command"])
			if("dest_start")
				usr << "<span class='notice'>You press a few keys on the panel.</span>"
				usr << "<span class='notice'>The system must be booting up the self-destruct sequence now.</span>"
				ai_system.Announce("Danger. The emergency destruct system is now activated. The ship will detonate in T-minus 20 minutes. Automatic detonation is unavailable. Manual detonation is required.", 'sound/AI/selfdestruct.ogg')
				active_state = SELF_DESTRUCT_MACHINE_ARMED //Arm it here so the process can execute it later.
				var/obj/machinery/self_destruct/rod/I = EvacuationAuthority.dest_rods[EvacuationAuthority.dest_index]
				I.activate_time = world.time
				EvacuationAuthority.process_self_destruct()
				var/data[] = list(
					"dest_status" = active_state
				)
				nanomanager.try_update_ui(usr, src, "main",, data)
			if("dest_trigger")
				if(EvacuationAuthority.initiate_self_destruct()) nanomanager.close_user_uis(usr, src, "main")
			if("dest_cancel")
				var/list/allowed_officers = list("Commander", "Executive Officer", "Staff Officer", "Chief MP","Chief Medical Officer","Chief Engineer")
				if(!usr.mind || !allowed_officers.Find(usr.mind.assigned_role))
					usr << "<span class='notice'>You don't have the necessary clearance to cancel the emergency destruct system.</span>"
					return
				if(EvacuationAuthority.cancel_self_destruct()) nanomanager.close_user_uis(usr, src, "main")

	ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
		var/data[] = list(
			"dest_status" = active_state
		)

		ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)

		if(!ui)
			ui = new(user, src, ui_key, "self_destruct_console.tmpl", "OMICRON6 PAYLOAD", 470, 290)
			ui.set_initial_data(data)
			ui.open()

/obj/machinery/self_destruct/rod
	name = "self destruct control rod"
	desc = "It is part of a complicated self-destruct sequence, but relatively simple to operate. Twist to arm or disarm."
	icon_state = "rod"
	layer = BELOW_OBJ_LAYER
	var/activate_time

	Dispose()
		. = ..()
		EvacuationAuthority.dest_rods -= src

	lock_or_unlock(lock)
		playsound(src, 'sound/machines/hydraulics_2.ogg', 25, 1)
		..()
		if(lock)
			activate_time = null
			density = FALSE
			layer = initial(layer)
		else
			density = TRUE
			layer = ABOVE_OBJ_LAYER

	attack_hand(mob/user)
		if(..())
			switch(active_state)
				if(SELF_DESTRUCT_MACHINE_ACTIVE)
					user << "<span class='notice'>You twist and release the control rod, arming it.</span>"
					playsound(src, 'sound/machines/switch.ogg', 25, 1)
					icon_state = "rod_4"
					active_state = SELF_DESTRUCT_MACHINE_ARMED
				if(SELF_DESTRUCT_MACHINE_ARMED)
					user << "<span class='notice'>You twist and release the control rod, disarming it.</span>"
					playsound(src, 'sound/machines/switch.ogg', 25, 1)
					icon_state = "rod_3"
					active_state = SELF_DESTRUCT_MACHINE_ACTIVE
				else user << "<span class='warning'>The control rod is not ready.</span>"


#undef SELF_DESTRUCT_MACHINE_INACTIVE
#undef SELF_DESTRUCT_MACHINE_ACTIVE
#undef SELF_DESTRUCT_MACHINE_ARMED
