var/list/robot_verbs_default = list(
	/mob/living/silicon/robot/proc/sensor_mode
)

#define CYBORG_POWER_USAGE_MULTIPLIER 2.5 // Multiplier for amount of power cyborgs use.

/mob/living/silicon/robot
	name = "Robot"
	real_name = "Robot"
	icon = 'icons/mob/robots.dmi'
	icon_state = "robot"
	maxHealth = 500
	health = 500

	var/lights_on = 0 // Is our integrated light on?
	var/used_power_this_tick = 0
	var/sight_mode = 0
	var/custom_name = ""
	var/crisis //Admin-settable for combat module use.
	var/crisis_override = 0
	var/integrated_light_power = 6

//Hud stuff

	var/obj/screen/cells = null
	var/obj/screen/inv1 = null
	var/obj/screen/inv2 = null
	var/obj/screen/inv3 = null

//3 Modules can be activated at any one time.
	var/obj/item/circuitboard/robot_module/module = null
	var/obj/module_active = null
	var/obj/module_state_1 = null
	var/obj/module_state_2 = null
	var/obj/module_state_3 = null

	var/obj/item/device/radio/borg/radio = null
	var/mob/living/silicon/ai/connected_ai = null
	var/obj/item/cell/cell = null
	var/obj/machinery/camera/camera = null

	// Components are basically robot organs.
	var/list/components = list()

	var/obj/item/device/mmi/mmi = null

	var/obj/item/device/pda/ai/rbPDA = null

	var/opened = 0
	var/emagged = 0
	var/wiresexposed = 0
	var/locked = 1
	var/has_power = 1
	var/list/req_access = list(ACCESS_MARINE_ENGINEERING, ACCESS_CIVILIAN_ENGINEERING)
	var/ident = 0
	//var/list/laws = list()
	var/viewalerts = 0
	var/modtype = "Default"
	var/lower_mod = 0
	var/jetpack = 0
	var/datum/effect_system/ion_trail_follow/ion_trail = null
	var/datum/effect_system/spark_spread/spark_system //So they can initialize sparks whenever/N
	var/jeton = 0
	var/borgwires = 31 // 0b11111
	var/killswitch = 0
	var/killswitch_time = 60
	var/weapon_lock = 0
	var/weaponlock_time = 120
	var/lawupdate = 1 //Cyborgs will sync their laws with their AI by default
	var/lawcheck[1] //For stating laws.
	var/ioncheck[1] //Ditto.
	var/lockcharge //Used when locking down a borg to preserve cell charge
	var/speed = 0 //Cause sec borgs gotta go fast //No they dont!
	var/scrambledcodes = 0 // Used to determine if a borg shows up on the robotics console.  Setting to one hides them.
	var/braintype = "Cyborg"

/mob/living/silicon/robot/New(loc,var/syndie = 0,var/unfinished = 0)
	spark_system = new /datum/effect_system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

	add_language("Robot Talk", 1)

	ident = rand(1, 999)
	updatename("Default")
	update_icons()

	if(syndie)
		if(!cell)
			cell = new /obj/item/cell(src)

		laws = new /datum/ai_laws/antimov()
		lawupdate = 0
		scrambledcodes = 1
		cell.maxcharge = 25000
		cell.charge = 25000
		module = new /obj/item/circuitboard/robot_module/syndicate(src)
		hands.icon_state = "standard"
		icon_state = "secborg"
		modtype = "Security"
	init()

	radio = new /obj/item/device/radio/borg(src)
	if(!scrambledcodes && !camera)
		camera = new /obj/machinery/camera(src)
		camera.c_tag = real_name
		camera.network = list("SS13","Robots")
		if(isWireCut(5)) // 5 = BORG CAMERA
			camera.status = 0

	initialize_components()
	//if(!unfinished)
	// Create all the robot parts.
	for(var/V in components) if(V != "power cell")
		var/datum/robot_component/C = components[V]
		C.installed = 1
		C.wrapped = new C.external_type

	if(!cell)
		cell = new /obj/item/cell(src)
		cell.maxcharge = 25000
		cell.charge = 25000

	..()

	if(cell)
		var/datum/robot_component/cell_component = components["power cell"]
		cell_component.wrapped = cell
		cell_component.installed = 1

	add_robot_verbs()

/mob/living/silicon/robot/proc/init()
	aiCamera = new/obj/item/device/camera/siliconcam/robot_camera(src)
	laws = new /datum/ai_laws/nanotrasen()
	connected_ai = select_active_ai_with_fewest_borgs()
	if(connected_ai)
		connected_ai.connected_robots += src
		lawsync()
		photosync()
		lawupdate = 1
	else
		lawupdate = 0

	// playsound(loc, 'sound/voice/liveagain.ogg', 75, 1)

// setup the PDA and its name
/mob/living/silicon/robot/proc/setup_PDA()
	if (!rbPDA)
		rbPDA = new/obj/item/device/pda/ai(src)
	rbPDA.set_name_and_job(custom_name,"[modtype] [braintype]")

//If there's an MMI in the robot, have it ejected when the mob goes away. --NEO
//Improved /N
/mob/living/silicon/robot/Dispose()
	if(mmi)//Safety for when a cyborg gets dust()ed. Or there is no MMI inside.
		var/turf/T = get_turf(loc)//To hopefully prevent run time errors.
		if(T)	mmi.loc = T
		if(mind)	mind.transfer_to(mmi.brainmob)
		mmi = null
	. = ..()

/mob/living/silicon/robot/proc/pick_module()
	if(module)
		return
	var/list/modules = list("Standard", "Engineering", "Surgeon", "Medic", "Janitor", "Service", "Security")
	modtype = input("Please, select a module!", "Robot", null, null) in modules

	var/module_sprites[0] //Used to store the associations between sprite names and sprite index.

	if(module)
		return

	switch(modtype)
		if("Standard")
			module = new /obj/item/circuitboard/robot_module/standard(src)
			module.channels = list("Command" = 1, "MP" = 0, "Alpha" = 0, "Bravo" = 0, "Charlie" = 0, "Delta" = 0, "Engi" = 0, "MedSci" = 0, "Req" = 0 )
			module_sprites["Default"] = "robot"
			module_sprites["Droid"] = "droid"
			module_sprites["Drone"] = "drone-standard"

		if("Service")
			module = new /obj/item/circuitboard/robot_module/butler(src)
			module.channels = list("Command" = 1, "MP" = 0, "Alpha" = 0, "Bravo" = 0, "Charlie" = 0, "Delta" = 0, "Engi" = 0, "MedSci" = 0, "Req" = 0 )
			module_sprites["Default"] = "Service2"
			module_sprites["Rich"] = "maximillion"
			module_sprites["Drone"] = "drone-service"

		if("Medic")
			module = new /obj/item/circuitboard/robot_module/medic(src)
			module.channels = list("Command" = 1, "MP" = 0, "Alpha" = 0, "Bravo" = 0, "Charlie" = 0, "Delta" = 0, "Engi" = 0, "MedSci" = 1, "Req" = 0 )
			if(camera && "Robots" in camera.network)
				camera.network.Add("Medical")
			module_sprites["Standard"] = "surgeon"
			module_sprites["Advanced Droid"] = "droid-medical"
			module_sprites["Needles"] = "medicalrobot"
			module_sprites["Drone"] = "drone-medical"

		if("Surgeon")
			module = new /obj/item/circuitboard/robot_module/surgeon(src)
			module.channels = list("Command" = 1, "MP" = 0, "Alpha" = 0, "Bravo" = 0, "Charlie" = 0, "Delta" = 0, "Engi" = 0, "MedSci" = 1, "Req" = 0 )
			if(camera && "Robots" in camera.network)
				camera.network.Add("Medical")
			module_sprites["Standard"] = "surgeon"
			module_sprites["Advanced Droid"] = "droid-medical"
			module_sprites["Needles"] = "medicalrobot"
			module_sprites["Drone"] = "drone-medical"

		if("Security")
			module = new /obj/item/circuitboard/robot_module/security(src)
			module.channels = list("Command" = 1, "MP" = 1, "Alpha" = 0, "Bravo" = 0, "Charlie" = 0, "Delta" = 0, "Engi" = 0, "MedSci" = 0, "Req" = 0 )
			module_sprites["Bloodhound"] = "bloodhound"
			module_sprites["Bloodhound - Treaded"] = "secborg+tread"
			module_sprites["Drone"] = "drone-sec"

		if("Engineering")
			module = new /obj/item/circuitboard/robot_module/engineering(src)
			module.channels = list("Command" = 1, "MP" = 0, "Alpha" = 0, "Bravo" = 0, "Charlie" = 0, "Delta" = 0, "Engi" = 1, "MedSci" = 0, "Req" = 0 )
			if(camera && "Robots" in camera.network)
				camera.network.Add("Engineering")
			module_sprites["Landmate"] = "landmate"
			module_sprites["Landmate - Treaded"] = "engiborg+tread"
			module_sprites["Drone"] = "drone-engineer"

		if("Janitor")
			module = new /obj/item/circuitboard/robot_module/janitor(src)
			module.channels = list("Command" = 1, "MP" = 0, "Alpha" = 0, "Bravo" = 0, "Charlie" = 0, "Delta" = 0, "Engi" = 0, "MedSci" = 0, "Req" = 0 )
			module_sprites["Mop Gear Rex"] = "mopgearrex"
			module_sprites["Drone"] = "drone-janitor"

	//languages
	module.add_languages(src)

	hands.icon_state = lowertext(modtype)
	feedback_inc("cyborg_[lowertext(modtype)]",1)
	updatename()

	if(modtype == "Medic" || modtype == "Security" || modtype == "Surgeon")
		status_flags &= ~CANPUSH

	choose_icon(6,module_sprites)
	radio.config(module.channels)

/mob/living/silicon/robot/proc/updatename(var/prefix as text)
	if(prefix)
		modtype = prefix
	if(mmi)
		braintype = "Cyborg"
	else
		braintype = "Robot"

	var/changed_name = ""
	if(custom_name)
		changed_name = custom_name
	else
		changed_name = "[modtype] [braintype]-[num2text(ident)]"
	real_name = changed_name
	name = real_name
	if(mind)
		mind.name = changed_name

	// if we've changed our name, we also need to update the display name for our PDA
	setup_PDA()

	//We also need to update name of internal camera.
	if (camera)
		camera.c_tag = changed_name


/mob/living/silicon/robot/verb/Namepick()
	set category = "Robot Commands"
	if(custom_name)
		return 0

	spawn(0)
		var/newname
		newname = input(src,"You are a robot. Enter a name, or leave blank for the default name.", "Name change","") as text
		if (newname != "")
			custom_name = newname

		updatename()
		update_icons()

/mob/living/silicon/robot/verb/cmd_robot_alerts()
	set category = "Robot Commands"
	set name = "Show Alerts"
	robot_alerts()

// this verb lets cyborgs see the stations manifest
/mob/living/silicon/robot/verb/cmd_station_manifest()
	set category = "Robot Commands"
	set name = "Show Crew Manifest"
	show_station_manifest()


/mob/living/silicon/robot/proc/robot_alerts()
	var/dat = "<HEAD><TITLE>Current Station Alerts</TITLE><META HTTP-EQUIV='Refresh' CONTENT='10'></HEAD><BODY>\n"
	dat += "<A HREF='?src=\ref[src];mach_close=robotalerts'>Close</A><BR><BR>"
	for (var/cat in alarms)
		dat += text("<B>[cat]</B><BR>\n")
		var/list/alarmlist = alarms[cat]
		if (alarmlist.len)
			for (var/area_name in alarmlist)
				var/datum/alarm/alarm = alarmlist[area_name]
				dat += "<NOBR>"
				dat += text("-- [area_name]")
				if (alarm.sources.len > 1)
					dat += text("- [alarm.sources.len] sources")
				dat += "</NOBR><BR>\n"
		else
			dat += "-- All Systems Nominal<BR>\n"
		dat += "<BR>\n"

	viewalerts = 1
	src << browse(dat, "window=robotalerts&can_close=0")

/mob/living/silicon/robot/proc/self_diagnosis()
	if(!is_component_functioning("diagnosis unit"))
		return null

	var/dat = "<HEAD><TITLE>[src.name] Self-Diagnosis Report</TITLE></HEAD><BODY>\n"
	for (var/V in components)
		var/datum/robot_component/C = components[V]
		dat += "<b>[C.name]</b><br><table><tr><td>Brute Damage:</td><td>[C.brute_damage]</td></tr><tr><td>Electronics Damage:</td><td>[C.electronics_damage]</td></tr><tr><td>Powered:</td><td>[(!C.idle_usage || C.is_powered()) ? "Yes" : "No"]</td></tr><tr><td>Toggled:</td><td>[ C.toggled ? "Yes" : "No"]</td></table><br>"

	return dat

/mob/living/silicon/robot/verb/toggle_lights()
	set category = "Robot Commands"
	set name = "Toggle Lights"

	lights_on = !lights_on
	usr << "You [lights_on ? "enable" : "disable"] your integrated light."
	if(lights_on)
		SetLuminosity(integrated_light_power) // 1.5x luminosity of flashlight
	else
		SetLuminosity(0)

/mob/living/silicon/robot/verb/self_diagnosis_verb()
	set category = "Robot Commands"
	set name = "Self Diagnosis"

	if(!is_component_functioning("diagnosis unit"))
		src << "\red Your self-diagnosis component isn't functioning."

	var/datum/robot_component/CO = get_component("diagnosis unit")
	if (!cell_use_power(CO.active_usage))
		src << "\red Low Power."
	var/dat = self_diagnosis()
	src << browse(dat, "window=robotdiagnosis")


/mob/living/silicon/robot/verb/toggle_component()
	set category = "Robot Commands"
	set name = "Toggle Component"
	set desc = "Toggle a component, conserving power."

	var/list/installed_components = list()
	for(var/V in components)
		if(V == "power cell") continue
		var/datum/robot_component/C = components[V]
		if(C.installed)
			installed_components += V

	var/toggle = input(src, "Which component do you want to toggle?", "Toggle Component") as null|anything in installed_components
	if(!toggle)
		return

	var/datum/robot_component/C = components[toggle]
	if(C.toggled)
		C.toggled = 0
		src << "\red You disable [C.name]."
	else
		C.toggled = 1
		src << "\red You enable [C.name]."

// this function displays jetpack pressure in the stat panel
/mob/living/silicon/robot/proc/show_jetpack_pressure()
	// if you have a jetpack, show the internal tank pressure
	var/obj/item/tank/jetpack/current_jetpack = installed_jetpack()
	if (current_jetpack)
		stat("Internal Atmosphere Info", current_jetpack.name)
		stat("Tank Pressure", current_jetpack.return_pressure())


// this function returns the robots jetpack, if one is installed
/mob/living/silicon/robot/proc/installed_jetpack()
	if(module)
		return (locate(/obj/item/tank/jetpack) in module.modules)
	return 0


// this function displays the cyborgs current cell charge in the stat panel
/mob/living/silicon/robot/proc/show_cell_power()
	if(cell)
		stat(null, text("Charge Left: [round(cell.percent())]%"))
		stat(null, text("Cell Rating: [round(cell.maxcharge)]")) // Round just in case we somehow get crazy values
		stat(null, text("Power Cell Load: [round(used_power_this_tick)]W"))
	else
		stat(null, text("No Cell Inserted!"))


// update the status screen display
/mob/living/silicon/robot/Stat()
	if (!..())
		return 0

	show_cell_power()
	show_jetpack_pressure()
	stat(null, text("Lights: [lights_on ? "ON" : "OFF"]"))
	return 1

/mob/living/silicon/robot/is_mob_restrained()
	return 0

/mob/living/silicon/robot/bullet_act(var/obj/item/projectile/Proj)
	..(Proj)
	if(prob(75) && Proj.damage > 0) spark_system.start()
	return 2

/mob/living/silicon/robot/Bump(atom/movable/AM as mob|obj, yes)
	..()
	if (istype(AM, /obj/machinery/recharge_station))
		var/obj/machinery/recharge_station/F = AM
		F.move_inside()
		return


/mob/living/silicon/robot/triggerAlarm(var/class, area/A, list/cameralist, var/source)
	if (stat == 2)
		return 1

	..()

	queueAlarm(text("--- [class] alarm detected in [A.name]!"), class)


/mob/living/silicon/robot/cancelAlarm(var/class, area/A as area, obj/origin)
	var/has_alarm = ..()

	if (!has_alarm)
		queueAlarm(text("--- [class] alarm in [A.name] has been cleared."), class, 0)
//		if (viewalerts) robot_alerts()
	return has_alarm


/mob/living/silicon/robot/attackby(obj/item/W as obj, mob/user as mob)
	if (istype(W, /obj/item/handcuffs)) // fuck i don't even know why isrobot() in handcuff code isn't working so this will have to do
		return

	if(opened) // Are they trying to insert something?
		for(var/V in components)
			var/datum/robot_component/C = components[V]
			if(!C.installed && istype(W, C.external_type))
				C.installed = 1
				C.wrapped = W
				C.install()
				if(user.drop_held_item())
					W.loc = null
					var/obj/item/robot_parts/robot_component/WC = W
					if(istype(WC))
						C.brute_damage = WC.brute
						C.electronics_damage = WC.burn

					usr << "\blue You install the [W.name]."

				return

	if (istype(W, /obj/item/tool/weldingtool))
		if (src == user)
			user << "<span class='warning'>You lack the reach to be able to repair yourself.</span>"
			return

		if (!getBruteLoss())
			user << "Nothing to fix here!"
			return
		var/obj/item/tool/weldingtool/WT = W
		if (WT.remove_fuel(0))
			adjustBruteLoss(-30)
			updatehealth()
			add_fingerprint(user)
			for(var/mob/O in viewers(user, null))
				O.show_message(text("\red [user] has fixed some of the dents on [src]!"), 1)
		else
			user << "Need more welding fuel!"
			return

	else if(istype(W, /obj/item/stack/cable_coil) && (wiresexposed || istype(src,/mob/living/silicon/robot/drone)))
		if (!getFireLoss())
			user << "Nothing to fix here!"
			return
		var/obj/item/stack/cable_coil/coil = W
		if (coil.use(1))
			adjustFireLoss(-30)
			updatehealth()
			for(var/mob/O in viewers(user, null))
				O.show_message(text("\red [user] has fixed some of the burnt wires on [src]!"), 1)

	else if (istype(W, /obj/item/tool/crowbar))	// crowbar means open or close the cover
		if(opened)
			if(cell)
				user << "You close the cover."
				opened = 0
				update_icons()
			else if(wiresexposed && isWireCut(1) && isWireCut(2) && isWireCut(3) && isWireCut(4) && isWireCut(5))
				//Cell is out, wires are exposed, remove MMI, produce damaged chassis, baleet original mob.
				if(!mmi)
					user << "\The [src] has no brain to remove."
					return

				user << "You jam the crowbar into the robot and begin levering [mmi]."
				sleep(30)
				user << "You damage some parts of the chassis, but eventually manage to rip out [mmi]!"
				var/obj/item/robot_parts/robot_suit/C = new/obj/item/robot_parts/robot_suit(loc)
				C.l_leg = new/obj/item/robot_parts/l_leg(C)
				C.r_leg = new/obj/item/robot_parts/r_leg(C)
				C.l_arm = new/obj/item/robot_parts/l_arm(C)
				C.r_arm = new/obj/item/robot_parts/r_arm(C)
				C.updateicon()
				new/obj/item/robot_parts/chest(loc)
				cdel(src)
			else
				// Okay we're not removing the cell or an MMI, but maybe something else?
				var/list/removable_components = list()
				for(var/V in components)
					if(V == "power cell") continue
					var/datum/robot_component/C = components[V]
					if(C.installed == 1 || C.installed == -1)
						removable_components += V

				var/remove = input(user, "Which component do you want to pry out?", "Remove Component") as null|anything in removable_components
				if(!remove)
					return
				var/datum/robot_component/C = components[remove]
				var/obj/item/robot_parts/robot_component/I = C.wrapped
				user << "You remove \the [I]."
				if(istype(I))
					I.brute = C.brute_damage
					I.burn = C.electronics_damage

				I.loc = src.loc

				if(C.installed == 1)
					C.uninstall()
				C.installed = 0

		else
			if(locked)
				user << "The cover is locked and cannot be opened."
			else
				user << "You open the cover."
				opened = 1
				update_icons()

	else if (istype(W, /obj/item/cell) && opened)	// trying to put a cell inside
		var/datum/robot_component/C = components["power cell"]
		if(wiresexposed)
			user << "Secure the wiring with a screwdriver first."
		else if(cell)
			user << "There is a power cell already installed."
		else
			if(user.drop_inv_item_to_loc(W, src))
				cell = W
				user << "You insert the power cell."

			C.installed = 1
			C.wrapped = W
			C.install()
			//This will mean that removing and replacing a power cell will repair the mount, but I don't care at this point. ~Z
			C.brute_damage = 0
			C.electronics_damage = 0

	else if (istype(W, /obj/item/tool/wirecutters) || istype(W, /obj/item/device/multitool))
		if (wiresexposed)
			interact(user)
		else
			user << "You can't reach the wiring."

	else if(istype(W, /obj/item/tool/screwdriver) && opened && !cell)	// haxing
		wiresexposed = !wiresexposed
		user << "The wires have been [wiresexposed ? "exposed" : "unexposed"]"
		update_icons()

	else if(istype(W, /obj/item/tool/screwdriver) && opened && cell)	// radio
		if(radio)
			radio.attackby(W,user)//Push it to the radio to let it handle everything
		else
			user << "Unable to locate a radio."
		update_icons()

	else if(istype(W, /obj/item/device/encryptionkey/) && opened)
		if(radio)//sanityyyyyy
			radio.attackby(W,user)//GTFO, you have your own procs
		else
			user << "Unable to locate a radio."

	else if (istype(W, /obj/item/card/id)||istype(W, /obj/item/device/pda))			// trying to unlock the interface with an ID card
		if(emagged)//still allow them to open the cover
			user << "The interface seems slightly damaged"
		if(opened)
			user << "You must close the cover to swipe an ID card."
		else
			if(allowed(usr))
				locked = !locked
				user << "You [ locked ? "lock" : "unlock"] [src]'s interface."
				update_icons()
			else
				user << "\red Access denied."

	else if(istype(W, /obj/item/card/emag))		// trying to unlock with an emag card
		if(!opened)//Cover is closed
			if(locked)
				if(prob(90))
					var/obj/item/card/emag/emag = W
					emag.uses--
					user << "You emag the cover lock."
					locked = 0
				else
					user << "You fail to emag the cover lock."
					src << "Hack attempt detected."
			else
				user << "The cover is already unlocked."
			return

		if(opened)//Cover is open
			if(emagged)	return//Prevents the X has hit Y with Z message also you cant emag them twice
			if(wiresexposed)
				user << "You must close the panel first"
				return
			else
				sleep(6)
				if(prob(50))
					emagged = 1
					lawupdate = 0
					connected_ai = null
					user << "You emag [src]'s interface."
					message_admins("[key_name_admin(user)] emagged cyborg [key_name_admin(src)].  Laws overridden.")
					log_game("[key_name(user)] emagged cyborg [key_name(src)].  Laws overridden.")
					clear_supplied_laws()
					clear_inherent_laws()
					laws = new /datum/ai_laws/syndicate_override
					var/time = time2text(world.realtime,"hh:mm:ss")
					lawchanges.Add("[time] <B>:</B> [user.name]([user.key]) emagged [name]([key])")
					set_zeroth_law("Only [user.real_name] and people he designates as being such are Syndicate Agents.")
					src << "\red ALERT: Foreign software detected."
					sleep(5)
					src << "\red Initiating diagnostics..."
					sleep(20)
					src << "\red SynBorg v1.7.1 loaded."
					sleep(5)
					src << "\red LAW SYNCHRONISATION ERROR"
					sleep(5)
					src << "\red Would you like to send a report to NanoTraSoft? Y/N"
					sleep(10)
					src << "\red > N"
					sleep(20)
					src << "\red ERRORERRORERROR"
					src << "<b>Obey these laws:</b>"
					laws.show_laws(src)
					src << "\red \b ALERT: [user.real_name] is your new master. Obey your new laws and his commands."
					update_icons()
				else
					user << "You fail to hack [src]'s interface."
					src << "Hack attempt detected."
			return

	else if(istype(W, /obj/item/robot/upgrade/))
		var/obj/item/robot/upgrade/U = W
		if(!opened)
			usr << "You must access the borgs internals!"
		else if(!src.module && U.require_module)
			usr << "The borg must choose a module before he can be upgraded!"
		else if(U.locked)
			usr << "The upgrade is locked and cannot be used yet!"
		else
			if(U.action(src))
				usr << "You apply the upgrade to [src]!"
				if(usr.drop_held_item())
					U.forceMove(src)
			else
				usr << "Upgrade error!"


	else
		if( !(istype(W, /obj/item/device/robotanalyzer) || istype(W, /obj/item/device/healthanalyzer)) )
			spark_system.start()
		return ..()

/mob/living/silicon/robot/verb/unlock_own_cover()
	set category = "Robot Commands"
	set name = "Toggle Cover"
	set desc = "Toggle your cover open and closed."
	if(stat == DEAD)
		return //won't work if dead
	if(!opened)
		opened = 1
		usr << "You open your cover."
	else
		opened = 0
		usr << "You close your cover."

/mob/living/silicon/robot/attack_animal(mob/living/M as mob)
	if(M.melee_damage_upper == 0)
		M.emote("[M.friendly] [src]")
	else
		if(M.attack_sound)
			playsound(loc, M.attack_sound, 25, 1)
		for(var/mob/O in viewers(src, null))
			O.show_message("\red <B>[M]</B> [M.attacktext] [src]!", 1)
		M.attack_log += text("\[[time_stamp()]\] <font color='red'>attacked [src.name] ([src.ckey])</font>")
		src.attack_log += text("\[[time_stamp()]\] <font color='orange'>was attacked by [M.name] ([M.ckey])</font>")
		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		adjustBruteLoss(damage)
		updatehealth()


/mob/living/silicon/robot/attack_hand(mob/user)

	add_fingerprint(user)

	if(opened && !wiresexposed && (!istype(user, /mob/living/silicon)))
		var/datum/robot_component/cell_component = components["power cell"]
		if(cell)
			cell.updateicon()
			cell.add_fingerprint(user)
			user.put_in_active_hand(cell)
			user << "You remove \the [cell]."
			cell = null
			cell_component.wrapped = null
			cell_component.installed = 0
			update_icons()
		else if(cell_component.installed == -1)
			cell_component.installed = 0
			var/obj/item/broken_device = cell_component.wrapped
			user << "You remove \the [broken_device]."
			user.put_in_active_hand(broken_device)

/mob/living/silicon/robot/proc/allowed(mob/M)
	//check if it doesn't require any access at all
	if(check_access(null))
		return 1
	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		//if they are holding or wearing a card that has access, that works
		if(check_access(H.get_active_hand()) || check_access(H.wear_id))
			return 1
	else if(istype(M, /mob/living/carbon/monkey))
		var/mob/living/carbon/monkey/george = M
		//they can only hold things :(
		if(george.get_active_hand() && istype(george.get_active_hand(), /obj/item/card/id) && check_access(george.get_active_hand()))
			return 1
	return 0

/mob/living/silicon/robot/proc/check_access(obj/item/card/id/I)
	if(!istype(req_access, /list)) //something's very wrong
		return 1

	var/list/L = req_access
	if(!L.len) //no requirements
		return 1
	if(!I || !istype(I, /obj/item/card/id) || !I.access) //not ID or no access
		return 0
	for(var/req in req_access)
		if(req in I.access) //have one of the required accesses
			return 1
	return 0

/mob/living/silicon/robot/update_icons()

	overlays.Cut()
	if(stat == 0)
		overlays += "eyes"
		overlays.Cut()
		overlays += "eyes-[icon_state]"
	else
		overlays -= "eyes"

	if(opened)
		if(wiresexposed)
			overlays += "ov-openpanel +w"
		else if(cell)
			overlays += "ov-openpanel +c"
		else
			overlays += "ov-openpanel -c"

//Call when target overlay should be added/removed
/mob/living/silicon/robot/update_targeted()
	if(!targeted_by && target_locked)
		cdel(target_locked)
		target_locked = null
	update_icons()
	if (targeted_by && target_locked)
		overlays += target_locked

/mob/living/silicon/robot/proc/installed_modules()
	if(weapon_lock)
		src << "\red Weapon lock active, unable to use modules! Count:[weaponlock_time]"
		return

	if(!module)
		pick_module()
		return
	var/dat = "<HEAD><TITLE>Modules</TITLE></HEAD><BODY>\n"
	dat += {"
	<B>Activated Modules</B>
	<BR>
	Module 1: [module_state_1 ? "<A HREF=?src=\ref[src];mod=\ref[module_state_1]>[module_state_1]<A>" : "No Module"]<BR>
	Module 2: [module_state_2 ? "<A HREF=?src=\ref[src];mod=\ref[module_state_2]>[module_state_2]<A>" : "No Module"]<BR>
	Module 3: [module_state_3 ? "<A HREF=?src=\ref[src];mod=\ref[module_state_3]>[module_state_3]<A>" : "No Module"]<BR>
	<BR>
	<B>Installed Modules</B><BR><BR>"}


	for (var/obj in module.modules)
		if (!obj)
			dat += text("<B>Resource depleted</B><BR>")
		else if(activated(obj))
			dat += text("[obj]: <B>Activated</B><BR>")
		else
			dat += text("[obj]: <A HREF=?src=\ref[src];act=\ref[obj]>Activate</A><BR>")
	if (emagged)
		if(activated(module.emag))
			dat += text("[module.emag]: <B>Activated</B><BR>")
		else
			dat += text("[module.emag]: <A HREF=?src=\ref[src];act=\ref[module.emag]>Activate</A><BR>")
/*
		if(activated(obj))
			dat += text("[obj]: \[<B>Activated</B>|<A HREF=?src=\ref[src];deact=\ref[obj]>Deactivate</A>\]<BR>")
		else
			dat += text("[obj]: \[<A HREF=?src=\ref[src];act=\ref[obj]>Activate</A>|<B>Deactivated</B>\]<BR>")
*/
	src << browse(dat, "window=robotmod")


/mob/living/silicon/robot/Topic(href, href_list)
	..()

	if(usr != src)
		return

	if (href_list["showalerts"])
		robot_alerts()
		return

	if (href_list["mod"])
		var/obj/item/O = locate(href_list["mod"])
		if (istype(O) && (O.loc == src))
			O.attack_self(src)

	if (href_list["act"])
		var/obj/item/O = locate(href_list["act"])
		if (!istype(O))
			return

		if(!((O in src.module.modules) || (O == src.module.emag)))
			return

		if(activated(O))
			src << "Already activated"
			return
		if(!module_state_1)
			module_state_1 = O
			O.layer = ABOVE_HUD_LAYER
			contents += O
			if(istype(module_state_1,/obj/item/robot/sight))
				sight_mode |= module_state_1:sight_mode
		else if(!module_state_2)
			module_state_2 = O
			O.layer = ABOVE_HUD_LAYER
			contents += O
			if(istype(module_state_2,/obj/item/robot/sight))
				sight_mode |= module_state_2:sight_mode
		else if(!module_state_3)
			module_state_3 = O
			O.layer = ABOVE_HUD_LAYER
			contents += O
			if(istype(module_state_3,/obj/item/robot/sight))
				sight_mode |= module_state_3:sight_mode
		else
			src << "You need to disable a module first!"
		installed_modules()

	if (href_list["deact"])
		var/obj/item/O = locate(href_list["deact"])
		if(activated(O))
			if(module_state_1 == O)
				module_state_1 = null
				contents -= O
			else if(module_state_2 == O)
				module_state_2 = null
				contents -= O
			else if(module_state_3 == O)
				module_state_3 = null
				contents -= O
			else
				src << "Module isn't activated."
		else
			src << "Module isn't activated"
		installed_modules()

	if (href_list["lawc"]) // Toggling whether or not a law gets stated by the State Laws verb --NeoFite
		var/L = text2num(href_list["lawc"])
		switch(lawcheck[L+1])
			if ("Yes") lawcheck[L+1] = "No"
			if ("No") lawcheck[L+1] = "Yes"
//		src << text ("Switching Law [L]'s report status to []", lawcheck[L+1])
		checklaws()

	if (href_list["lawi"]) // Toggling whether or not a law gets stated by the State Laws verb --NeoFite
		var/L = text2num(href_list["lawi"])
		switch(ioncheck[L])
			if ("Yes") ioncheck[L] = "No"
			if ("No") ioncheck[L] = "Yes"
//		src << text ("Switching Law [L]'s report status to []", lawcheck[L+1])
		checklaws()

	if (href_list["laws"]) // With how my law selection code works, I changed statelaws from a verb to a proc, and call it through my law selection panel. --NeoFite
		statelaws()
	return

/mob/living/silicon/robot/proc/radio_menu()
	radio.interact(src)//Just use the radio's Topic() instead of bullshit special-snowflake code


/mob/living/silicon/robot/Move(a, b, flag)
	if (!is_component_functioning("actuator"))
		return 0

	var/datum/robot_component/actuator/AC = get_component("actuator")
	if (!cell_use_power(AC.active_usage))
		return 0

	. = ..()

	if(module)
		if(module.type == /obj/item/circuitboard/robot_module/janitor)
			var/turf/tile = loc
			if(isturf(tile))
				tile.clean_blood()
				for(var/A in tile)
					if(istype(A, /obj/effect))
						if(istype(A, /obj/effect/rune) || istype(A, /obj/effect/decal/cleanable) || istype(A, /obj/effect/overlay))
							cdel(A)
					else if(istype(A, /obj/item))
						var/obj/item/cleaned_item = A
						cleaned_item.clean_blood()
					else if(istype(A, /mob/living/carbon/human))
						var/mob/living/carbon/human/cleaned_human = A
						if(cleaned_human.lying)
							if(cleaned_human.head)
								cleaned_human.head.clean_blood()
								cleaned_human.update_inv_head(0)
							if(cleaned_human.wear_suit)
								cleaned_human.wear_suit.clean_blood()
								cleaned_human.update_inv_wear_suit(0)
							else if(cleaned_human.w_uniform)
								cleaned_human.w_uniform.clean_blood()
								cleaned_human.update_inv_w_uniform(0)
							if(cleaned_human.shoes)
								cleaned_human.shoes.clean_blood()
								cleaned_human.update_inv_shoes(0)
							cleaned_human.clean_blood(1)
							cleaned_human << "\red [src] cleans your face!"
		return

/mob/living/silicon/robot/proc/self_destruct()
	robogibs()
	return

/mob/living/silicon/robot/proc/UnlinkSelf()
	if (src.connected_ai)
		src.connected_ai = null
	lawupdate = 0
	lockcharge = 0
	canmove = 1
	scrambledcodes = 1
	//Disconnect it's camera so it's not so easily tracked.
	if(src.camera)
		src.camera.network = list()
		cameranet.removeCamera(src.camera)


/mob/living/silicon/robot/proc/ResetSecurityCodes()
	set category = "Robot Commands"
	set name = "Reset Identity Codes"
	set desc = "Scrambles your security and identification codes and resets your current buffers.  Unlocks you and but permenantly severs you from your AI and the robotics console and will deactivate your camera system."

	var/mob/living/silicon/robot/R = src

	if(R)
		R.UnlinkSelf()
		R << "Buffers flushed and reset. Camera system shutdown.  All systems operational."
		src.verbs -= /mob/living/silicon/robot/proc/ResetSecurityCodes

/mob/living/silicon/robot/mode()
	set name = "Activate Held Object"
	set category = "IC"
	set src = usr

	var/obj/item/W = get_active_hand()
	if (W)
		W.attack_self(src)

	return

/mob/living/silicon/robot/proc/choose_icon(var/triesleft, var/list/module_sprites)

	if(triesleft<1 || !module_sprites.len)
		return
	else
		triesleft--

	var/icontype = input("Select an icon! [triesleft ? "You have [triesleft] more chances." : "This is your last try."]", "Robot", null, null) in module_sprites

	if(icontype)
		icon_state = module_sprites[icontype]
	else
		src << "Something is badly wrong with the sprite selection. Harass a coder."
		icon_state = module_sprites[1]
		return

	overlays -= "eyes"
	update_icons()

	if (triesleft >= 1)
		var/choice = input("Look at your icon - is this what you want?") in list("Yes","No")
		if(choice=="No")
			choose_icon(triesleft, module_sprites)
		else
			triesleft = 0
			return
	else
		src << "Your icon has been set. You now require a module reset to change it."

/mob/living/silicon/robot/proc/sensor_mode() //Medical/Security HUD controller for borgs
	set name = "Set Sensor Augmentation"
	set category = "Robot Commands"
	set desc = "Augment visual feed with internal sensor overlays."
	toggle_sensor_mode()

/mob/living/silicon/robot/proc/add_robot_verbs()
	src.verbs |= robot_verbs_default

/mob/living/silicon/robot/proc/remove_robot_verbs()
	src.verbs -= robot_verbs_default

// Uses power from cyborg's cell. Returns 1 on success or 0 on failure.
// Properly converts using CELLRATE now! Amount is in Joules.
/mob/living/silicon/robot/proc/cell_use_power(var/amount = 0)
	// No cell inserted
	if(!cell)
		return 0

	// Power cell is empty.
	if(cell.charge == 0)
		return 0

	if(cell.use(amount * CELLRATE * CYBORG_POWER_USAGE_MULTIPLIER))
		used_power_this_tick += amount * CYBORG_POWER_USAGE_MULTIPLIER
		return 1
	return 0

/mob/living/silicon/robot/binarycheck()
	if(is_component_functioning("comms"))
		var/datum/robot_component/RC = get_component("comms")
		use_power(RC.active_usage)
		return 1
	return 0






/mob/living/silicon/robot/update_sight()
	if (stat == DEAD || XRAY in mutations || sight_mode & BORGXRAY)
		sight |= SEE_TURFS
		sight |= SEE_MOBS
		sight |= SEE_OBJS
		see_in_dark = 8
		see_invisible = SEE_INVISIBLE_MINIMUM
	else if (sight_mode & BORGMESON && sight_mode & BORGTHERM)
		sight |= SEE_TURFS
		sight |= SEE_MOBS
		see_in_dark = 8
		see_invisible = SEE_INVISIBLE_MINIMUM
	else if (sight_mode & BORGMESON)
		sight |= SEE_TURFS
		see_in_dark = 8
		see_invisible = SEE_INVISIBLE_MINIMUM
	else if (sight_mode & BORGTHERM)
		sight |= SEE_MOBS
		see_in_dark = 8
		see_invisible = SEE_INVISIBLE_LEVEL_TWO
	else if (stat != DEAD)
		sight &= ~SEE_MOBS
		sight &= ~SEE_TURFS
		sight &= ~SEE_OBJS
		see_in_dark = 8
		see_invisible = SEE_INVISIBLE_LEVEL_TWO
