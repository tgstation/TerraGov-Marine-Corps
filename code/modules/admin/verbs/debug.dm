/client/proc/Debug2()
	set category = "Debug"
	set name = "Debugging Mode"
	if(!check_rights(R_DEBUG))	return

	if(Debug2)
		Debug2 = 0
		message_admins("[key_name(src)] toggled debugging off.")
		log_admin("[key_name(src)] toggled debugging off.")
	else
		Debug2 = 1
		message_admins("[key_name(src)] toggled debugging on.")
		log_admin("[key_name(src)] toggled debugging on.")

	feedback_add_details("admin_verb","DG2") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!



/* 21st Sept 2010
Updated by Skie -- Still not perfect but better!
Stuff you can't do:
Call proc /mob/proc/make_dizzy() for some player
Because if you select a player mob as owner it tries to do the proc for
/mob/living/carbon/human/ instead. And that gives a run-time error.
But you can call procs that are of type /mob/living/carbon/human/proc/ for that player.
*/

/client/proc/callproc()
	set category = "Debug"
	set name = "Advanced ProcCall"
	set waitfor = 0

	if(!check_rights(R_DEBUG)) return
	if(config.debugparanoid && !check_rights(R_ADMIN)) return

	var/target = null
	var/targetselected = 0
	var/lst[] // List reference
	lst = new/list() // Make the list
	var/returnval = null
	var/class = null

	switch(alert("Proc owned by something?",,"Yes","No"))
		if("Yes")
			targetselected = 1
			class = input("Proc owned by...","Owner",null) as null|anything in list("Obj","Mob","Area or Turf","Client")
			switch(class)
				if("Obj")
					target = input("Enter target:","Target",usr) as obj in object_list
				if("Mob")
					target = input("Enter target:","Target",usr) as mob in mob_list
				if("Area or Turf")
					target = input("Enter target:","Target",usr.loc) as area|turf in world
				if("Client")
					var/list/keys = list()
					for(var/client/C)
						keys += C
					target = input("Please, select a player!", "Selection", null, null) as null|anything in keys
				else
					return
		if("No")
			target = null
			targetselected = 0

	var/procname = input("Proc path, eg: /proc/fake_blood","Path:", null) as text|null
	if(!procname)	return

	var/argnum = input("Number of arguments","Number:",0) as num|null
	if(!argnum && (argnum!=0))	return

	lst.len = argnum // Expand to right length
	//TODO: make a list to store whether each argument was initialised as null.
	//Reason: So we can abort the proccall if say, one of our arguments was a mob which no longer exists
	//this will protect us from a fair few errors ~Carn

	var/i
	for(i=1, i<argnum+1, i++) // Lists indexed from 1 forwards in byond

		// Make a list with each index containing one variable, to be given to the proc
		class = input("What kind of variable?","Variable Type") in list("text","num","type","reference","mob reference","icon","file","client","mob's area","CANCEL")
		switch(class)
			if("CANCEL")
				return

			if("text")
				lst[i] = input("Enter new text:","Text",null) as text

			if("num")
				lst[i] = input("Enter new number:","Num",0) as num

			if("type")
				lst[i] = input("Enter type:","Type") in typesof(/obj,/mob,/area,/turf)

			if("reference")
				lst[i] = input("Select reference:","Reference",src) as mob|obj|turf|area in world

			if("mob reference")
				lst[i] = input("Select reference:","Reference",usr) as mob in mob_list

			if("file")
				lst[i] = input("Pick file:","File") as file

			if("icon")
				lst[i] = input("Pick icon:","Icon") as icon

			if("client")
				var/list/keys = list()
				for(var/mob/M in player_list)
					keys += M.client
				lst[i] = input("Please, select a player!", "Selection", null, null) as null|anything in keys

			if("mob's area")
				var/mob/temp = input("Select mob", "Selection", usr) as mob in mob_list
				lst[i] = temp.loc

	if(targetselected)
		if(!target)
			usr << "<font color='red'>Error: callproc(): owner of proc no longer exists.</font>"
			return

		var/actual_name = procname
		//Remove the "/proc/" in front of the actual name
		if(findtext(procname, "/proc/"))
			actual_name = replacetext(procname, "/proc/", "")
		else if(findtext(procname, "/proc"))
			actual_name = replacetext(procname, "/proc", "")
		else if(findtext(procname, "proc/"))
			actual_name = replacetext(procname, "proc/", "")
		//Remove Parenthesis if any
		actual_name = replacetext(actual_name, "()", "")

		if(!hascall(target,actual_name))
			usr << "<font color='red'>Error: callproc(): target has no such call [procname].</font>"
			return
		log_admin("[key_name(src)] called [target]'s [procname]() with [lst.len ? "the arguments [list2params(lst)]":"no arguments"].")
		returnval = call(target,actual_name)(arglist(lst)) // Pass the lst as an argument list to the proc
	else
		//this currently has no hascall protection. wasn't able to get it working.
		log_admin("[key_name(src)] called [procname]() with [lst.len ? "the arguments [list2params(lst)]":"no arguments"].")
		returnval = call(procname)(arglist(lst)) // Pass the lst as an argument list to the proc

	usr << "<font color='blue'>[procname] returned: [returnval ? returnval : "null"]</font>"
	feedback_add_details("admin_verb","APC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!



/client/proc/callatomproc(atom/A)
	set category = "Debug"
	set name = "Atom ProcCall"
	set waitfor = 0

	if(!check_rights(R_DEBUG)) return
	if(config.debugparanoid && !check_rights(R_ADMIN)) return

	var/lst[] // List reference
	lst = new/list() // Make the list
	var/returnval = null
	var/class = null

	var/procname = input("Proc name, eg: attack_hand","Proc:", null) as text|null
	if(!procname)
		return

	if(!hascall(A,procname))
		usr << "<font color='red'>Error: callatomproc(): type [A.type] has no proc named [procname].</font>"
		return

	var/argnum = input("Number of arguments","Number:",0) as num|null
	if(!argnum && (argnum!=0))	return

	lst.len = argnum

	var/i
	for(i=1, i<argnum+1, i++) // Lists indexed from 1 forwards in byond

		// Make a list with each index containing one variable, to be given to the proc
		class = input("What kind of variable?","Variable Type") in list("text","num","type","reference","mob reference","icon","file","client","mob's area","CANCEL")
		switch(class)
			if("CANCEL")
				return

			if("text")
				lst[i] = input("Enter new text:","Text",null) as text

			if("num")
				lst[i] = input("Enter new number:","Num",0) as num

			if("type")
				lst[i] = input("Enter type:","Type") in typesof(/obj,/mob,/area,/turf)

			if("reference")
				lst[i] = input("Select reference:","Reference",src) as mob|obj|turf|area in world

			if("mob reference")
				lst[i] = input("Select reference:","Reference",usr) as mob in mob_list

			if("file")
				lst[i] = input("Pick file:","File") as file

			if("icon")
				lst[i] = input("Pick icon:","Icon") as icon

			if("client")
				var/list/keys = list()
				for(var/mob/M in player_list)
					keys += M.client
				lst[i] = input("Please, select a player!", "Selection", null, null) as null|anything in keys

			if("mob's area")
				var/mob/temp = input("Select mob", "Selection", usr) as mob in mob_list
				lst[i] = temp.loc

	log_admin("[key_name(src)] called [A]'s [procname]() with [lst.len ? "the arguments [list2params(lst)]":"no arguments"].")
	message_admins("\blue [key_name_admin(src)] called [A]'s [procname]() with [lst.len ? "the arguments [list2params(lst)]":"no arguments"].")
	returnval = call(A,procname)(arglist(lst)) // Pass the lst as an argument list to the proc
	usr << "<font color='blue'>[procname] returned: [returnval ? returnval : "null"]</font>"
	feedback_add_details("admin_verb","AAPC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!




/client/proc/Cell()
	set category = "Debug"
	set name = "Cell"
	if(!mob)
		return
	var/turf/T = mob.loc

	if (!( istype(T, /turf) ))
		return

	var/list/air_info = T.return_air()

	var/t = "\blue Coordinates: [T.x],[T.y],[T.z]\n"
	t += "\red Temperature: [air_info[2]]\n"
	t += "\red Pressure: [air_info[3]]kPa\n"
	t += "\blue Gas Type: [air_info[1]]\n"

	usr.show_message(t, 1)
	feedback_add_details("admin_verb","ASL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_robotize(var/mob/M in mob_list)
	set category = "Fun"
	set name = "Make Robot"

	if(!ticker)
		alert("Wait until the game starts")
		return
	if(istype(M, /mob/living/carbon/human))
		log_admin("[key_name(src)] has robotized [M.key].")
		spawn(10)
			M:Robotize()

	else
		alert("Invalid mob")

/client/proc/cmd_admin_animalize(var/mob/M in mob_list)
	set category = "Fun"
	set name = "Make Simple Animal"

	if(!ticker)
		alert("Wait until the game starts")
		return

	if(!M)
		alert("That mob doesn't seem to exist, close the panel and try again.")
		return

	if(istype(M, /mob/new_player))
		alert("The mob must not be a new_player.")
		return

	log_admin("[key_name(src)] has animalized [M.key].")
	spawn(10)
		M.Animalize()

/client/proc/cmd_admin_alienize(var/mob/M in mob_list)
	set category = "Fun"
	set name = "Make Alien"

	if(!ticker)
		alert("Wait until the game starts")
		return
	if(ishuman(M))
		log_admin("[key_name(src)] has alienized [M.key].")
		spawn(10)
			M:Alienize()
			feedback_add_details("admin_verb","MKAL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		log_admin("[key_name(usr)] made [key_name(M)] into an alien.")
		message_admins("\blue [key_name_admin(usr)] made [key_name(M)] into an alien.", 1)
	else
		alert("Invalid mob")

/client/proc/cmd_admin_change_hivenumber(mob/living/carbon/Xenomorph/M in mob_list, var/hivenumber = XENO_HIVE_NORMAL)
	set category = "Debug"
	set name = "Change Hivenumber"

	if(!ticker)
		alert("Wait until the game starts")
		return
	if(isXeno(M))
		log_admin("[key_name(src)] changed hivenumber of [M] to [M.hivenumber].")
		M.hivenumber = hivenumber
		if(istype(M, /mob/living/carbon/Xenomorph/Larva))
			var/mob/living/carbon/Xenomorph/Larva/L = M
			L.update_icons() // larva renaming done differently
		else
			M.generate_name()
		if(istype(M, /mob/living/carbon/Xenomorph/Queen))
			update_living_queens()
		usr << "Hivenumber set to [M.hivenumber]"
		feedback_add_details("admin_verb","CHHN") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		message_admins("\blue [key_name(src)] changed hivenumber of [M] to [M.hivenumber].", 1)
	else
		alert("Invalid mob")

//TODO: merge the vievars version into this or something maybe mayhaps
/client/proc/cmd_debug_del_all()
	set category = "Debug"
	set name = "Delete Instance"

	// to prevent REALLY stupid deletions
	var/blocked = list(/obj, /obj/item, /obj/effect, /obj/mecha, /obj/machinery, /mob, /mob/living, /mob/living/carbon, /mob/living/carbon/Xenomorph, /mob/living/carbon/human, /mob/dead, /mob/dead/observer, /mob/living/silicon, /mob/living/silicon/robot, /mob/living/silicon/ai)
	var/chosen_deletion = input(usr, "Type the path of the object you want to delete", "Delete:") as null|text
	if(chosen_deletion)
		chosen_deletion = text2path(chosen_deletion)
		if(ispath(chosen_deletion))
			if(!ispath(/mob) && !ispath(/obj))
				usr << "<span class = 'warning'>Only works for types of /obj or /mob.</span>"
			else
				var/hsbitem = input(usr, "Choose an object to delete.", "Delete:") as null|anything in typesof(chosen_deletion)
				if(hsbitem)
					var/do_delete = 1
					if(hsbitem in blocked)
						if(alert("Are you REALLY sure you wish to delete all instances of [hsbitem]? This will lead to catastrophic results!",,"Yes","No") != "Yes")
							do_delete = 0
					var/del_amt = 0
					if(do_delete)
						for(var/atom/O in world)
							if(istype(O, hsbitem))
								del_amt++
								cdel(O)
						log_admin("[key_name(src)] has deleted all instances of [hsbitem] ([del_amt]).")
						message_admins("[key_name_admin(src)] has deleted all instances of [hsbitem] ([del_amt]).", 0)
		else
			usr << "<span class = 'warning'>Not a valid type path.</span>"
	feedback_add_details("admin_verb","DELA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_debug_make_powernets()
	set category = "Debug"
	set name = "Generate Powernets"
	makepowernets()
	log_admin("[key_name(src)] has remade the powernet. makepowernets() called.")
	message_admins("[key_name_admin(src)] has remade the powernets. makepowernets() called.", 0)
	feedback_add_details("admin_verb","MPWN") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_debug_tog_aliens()
	set category = "Server"
	set name = "Toggle Aliens"

	aliens_allowed = !aliens_allowed
	log_admin("[key_name(src)] has turned aliens [aliens_allowed ? "on" : "off"].")
	message_admins("[key_name_admin(src)] has turned aliens [aliens_allowed ? "on" : "off"].", 0)
	feedback_add_details("admin_verb","TAL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_grantfullaccess(var/mob/M in mob_list)
	set category = "Admin"
	set name = "Grant Full Access"

	if (!ticker)
		alert("Wait until the game starts")
		return
	if (istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		if (H.wear_id)
			var/obj/item/card/id/id = H.wear_id
			if(istype(H.wear_id, /obj/item/device/pda))
				var/obj/item/device/pda/pda = H.wear_id
				id = pda.id
			id.icon_state = "gold"
			id:access = get_all_accesses()+get_all_centcom_access()+get_all_syndicate_access()
		else
			var/obj/item/card/id/id = new/obj/item/card/id(M);
			id.icon_state = "gold"
			id:access = get_all_accesses()+get_all_centcom_access()+get_all_syndicate_access()
			id.registered_name = H.real_name
			id.assignment = "Captain"
			id.name = "[id.registered_name]'s ID Card ([id.assignment])"
			H.equip_to_slot_or_del(id, WEAR_ID)
			H.update_inv_wear_id()
	else
		alert("Invalid mob")
	feedback_add_details("admin_verb","GFA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(src)] has granted [M.key] full access.")
	message_admins("\blue [key_name_admin(usr)] has granted [M.key] full access.", 1)

/client/proc/cmd_admin_grantallskills(var/mob/M in mob_list)
	set category = "Admin"
	set name = "Grant All Skills"

	if (!ticker)
		alert("Wait until the game starts")
		return
	if(M.mind)
		M.mind.cm_skills = null // No restrictions
	else
		alert("Invalid mob")
	feedback_add_details("admin_verb","GAS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(src)] has granted [M.key] all skills.")
	message_admins("\blue [key_name_admin(usr)] has granted [M.key] all skills.", 1)

/client/proc/cmd_assume_direct_control(var/mob/M in mob_list)
	set category = "Admin"
	set name = "Assume direct control"
	set desc = "Direct intervention"

	if(!check_rights(R_DEBUG|R_ADMIN))	return
	if(M.disposed) return //mob is garbage collected
	if(M.ckey)
		if(alert("This mob is being controlled by [M.ckey]. Are you sure you wish to assume control of it? [M.ckey] will be made a ghost.",,"Yes","No") != "Yes")
			return
		else
			var/mob/dead/observer/ghost = new/mob/dead/observer(M,1)
			ghost.ckey = M.ckey
			if(ghost.client) ghost.client.change_view(world.view)
	message_admins("\blue [key_name_admin(usr)] assumed direct control of [M].", 1)
	log_admin("[key_name(usr)] assumed direct control of [M].")
	var/mob/adminmob = src.mob
	M.ckey = src.ckey
	if(M.client) M.client.change_view(world.view)
	if( isobserver(adminmob) )
		cdel(adminmob)
	feedback_add_details("admin_verb","ADC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!






/client/proc/cmd_admin_areatest()
	set category = "Mapping"
	set name = "Test areas"

	var/list/areas_all = list()
	var/list/areas_with_APC = list()
	var/list/areas_with_air_alarm = list()
	var/list/areas_with_RC = list()
	var/list/areas_with_light = list()
	var/list/areas_with_LS = list()
	var/list/areas_with_intercom = list()
	var/list/areas_with_camera = list()

	for(var/area/A in all_areas)
		if(!(A.type in areas_all))
			areas_all.Add(A.type)

	for(var/obj/machinery/power/apc/APC in machines)
		var/area/A = get_area(APC)
		if(!(A.type in areas_with_APC))
			areas_with_APC.Add(A.type)

	for(var/obj/machinery/alarm/alarm in machines)
		var/area/A = get_area(alarm)
		if(!(A.type in areas_with_air_alarm))
			areas_with_air_alarm.Add(A.type)

	for(var/obj/machinery/requests_console/RC in machines)
		var/area/A = get_area(RC)
		if(!(A.type in areas_with_RC))
			areas_with_RC.Add(A.type)

	for(var/obj/machinery/light/L in machines)
		var/area/A = get_area(L)
		if(!(A.type in areas_with_light))
			areas_with_light.Add(A.type)

	for(var/obj/machinery/light_switch/LS in machines)
		var/area/A = get_area(LS)
		if(!(A.type in areas_with_LS))
			areas_with_LS.Add(A.type)

	for(var/obj/item/device/radio/intercom/I in item_list)
		var/area/A = get_area(I)
		if(!(A.type in areas_with_intercom))
			areas_with_intercom.Add(A.type)

	for(var/obj/machinery/camera/C in machines)
		var/area/A = get_area(C)
		if(!(A.type in areas_with_camera))
			areas_with_camera.Add(A.type)

	var/list/areas_without_APC = areas_all - areas_with_APC
	var/list/areas_without_air_alarm = areas_all - areas_with_air_alarm
	var/list/areas_without_RC = areas_all - areas_with_RC
	var/list/areas_without_light = areas_all - areas_with_light
	var/list/areas_without_LS = areas_all - areas_with_LS
	var/list/areas_without_intercom = areas_all - areas_with_intercom
	var/list/areas_without_camera = areas_all - areas_with_camera

	world << "<b>AREAS WITHOUT AN APC:</b>"
	for(var/areatype in areas_without_APC)
		world << "* [areatype]"

	world << "<b>AREAS WITHOUT AN AIR ALARM:</b>"
	for(var/areatype in areas_without_air_alarm)
		world << "* [areatype]"

	world << "<b>AREAS WITHOUT A REQUEST CONSOLE:</b>"
	for(var/areatype in areas_without_RC)
		world << "* [areatype]"

	world << "<b>AREAS WITHOUT ANY LIGHTS:</b>"
	for(var/areatype in areas_without_light)
		world << "* [areatype]"

	world << "<b>AREAS WITHOUT A LIGHT SWITCH:</b>"
	for(var/areatype in areas_without_LS)
		world << "* [areatype]"

	world << "<b>AREAS WITHOUT ANY INTERCOMS:</b>"
	for(var/areatype in areas_without_intercom)
		world << "* [areatype]"

	world << "<b>AREAS WITHOUT ANY CAMERAS:</b>"
	for(var/areatype in areas_without_camera)
		world << "* [areatype]"

/client/proc/startSinglo()

	set category = "Debug"
	set name = "Start Singularity"
	set desc = "Sets up the singularity and all machines to get power flowing through the station"

	if(alert("Are you sure? This will start up the engine. Should only be used during debug!",,"Yes","No") != "Yes")
		return

	for(var/obj/machinery/power/emitter/E in machines)
		if(E.anchored)
			E.active = 1

	for(var/obj/machinery/field_generator/F in machines)
		if(F.anchored)
			F.Varedit_start = 1
	spawn(30)
		for(var/obj/machinery/the_singularitygen/G in machines)
			if(G.anchored)
				var/obj/machinery/singularity/S = new /obj/machinery/singularity(get_turf(G), 50)
				spawn(0)
					cdel(G)
				S.energy = 1750
				S.current_size = 7
				S.icon = 'icons/effects/224x224.dmi'
				S.icon_state = "singularity_s7"
				S.pixel_x = -96
				S.pixel_y = -96
				S.grav_pull = 0
				S.dissipate = 0

	for(var/obj/machinery/power/rad_collector/Rad in machines)
		if(Rad.anchored)
			if(!Rad.P)
				var/obj/item/tank/phoron/Phoron = new/obj/item/tank/phoron(Rad)
				Phoron.gas_type = GAS_TYPE_PHORON
				Phoron.pressure = ONE_ATMOSPHERE * 3
				Rad.drainratio = 0
				Rad.P = Phoron
				Phoron.loc = Rad

			if(!Rad.active)
				Rad.toggle_power()

	for(var/obj/machinery/power/smes/SMES in machines)
		if(SMES.anchored)
			SMES.chargemode = 1

/client/proc/setup_supermatter_engine()
	set category = "Debug"
	set name = "Setup supermatter"
	set desc = "Sets up the supermatter engine"

	if(!check_rights(R_DEBUG|R_ADMIN))      return

	var/response = alert("Are you sure? This will start up the engine. Should only be used during debug!",,"Setup Completely","Setup except coolant","No")

	if(response == "No")
		return

	var/found_the_pump = 0
	var/obj/machinery/power/supermatter/SM

	for(var/obj/machinery/M in machines)
		if(!M)
			continue
		if(!M.loc)
			continue
		if(!M.loc.loc)
			continue

		if(istype(M.loc.loc,/area/sulaco/engineering/engine))
			if(istype(M,/obj/machinery/power/rad_collector))
				var/obj/machinery/power/rad_collector/Rad = M
				Rad.anchored = 1
				Rad.connect_to_network()

				var/obj/item/tank/phoron/Phoron = new/obj/item/tank/phoron(Rad)

				Phoron.pressure = ONE_ATMOSPHERE * 4
				Rad.P = Phoron

				Phoron.loc = Rad

				if(!Rad.active)
					Rad.toggle_power()
				Rad.update_icon()

			else if(istype(M,/obj/machinery/power/supermatter))
				SM = M
				spawn(50)
					SM.power = 320

			else if(istype(M,/obj/machinery/power/smes))	//This is the SMES inside the engine room.  We don't need much power.
				var/obj/machinery/power/smes/SMES = M
				SMES.chargemode = 1
				SMES.chargelevel = 200000
				SMES.output = 75000

		else if(istype(M.loc.loc,/area/sulaco/engineering/smes))	//Set every SMES to charge and spit out 300,000 power between the 4 of them.
			if(istype(M,/obj/machinery/power/smes))
				var/obj/machinery/power/smes/SMES = M
				SMES.chargemode = 1
				SMES.chargelevel = 200000
				SMES.output = 75000

	if(!found_the_pump && response == "Setup Completely")
		src << "\red Unable to locate air supply to fill up with coolant, adding some coolant around the supermatter"



	log_admin("[key_name(usr)] setup the supermatter engine [response == "Setup except coolant" ? "without coolant" : ""]")
	message_admins("\blue [key_name_admin(usr)] setup the supermatter engine  [response == "Setup except coolant" ? "without coolant": ""]", 1)
	return



/client/proc/cmd_debug_mob_lists()
	set category = "Debug"
	set name = "Debug Mob Lists"
	set desc = "For when you just gotta know"

	switch(input("Which list?") in list("Players","Admins","Mobs","Living Mobs","Dead Mobs", "Clients"))
		if("Players")
			usr << list2text(player_list,",")
		if("Admins")
			usr << list2text(admins,",")
		if("Mobs")
			usr << list2text(mob_list,",")
		if("Living Mobs")
			usr << list2text(living_mob_list,",")
		if("Dead Mobs")
			usr << list2text(dead_mob_list,",")
		if("Clients")
			usr << list2text(clients,",")

// DNA2 - Admin Hax
/client/proc/cmd_admin_toggle_block(var/mob/M,var/block)
	if(!ticker)
		alert("Wait until the game starts")
		return
	if(istype(M, /mob/living/carbon))
		M.dna.SetSEState(block,!M.dna.GetSEState(block))
		domutcheck(M,null,MUTCHK_FORCED)
		M.update_mutations()
		var/state="[M.dna.GetSEState(block)?"on":"off"]"
		var/blockname=assigned_blocks[block]
		message_admins("[key_name_admin(src)] has toggled [M.key]'s [blockname] block [state]!")
		log_admin("[key_name(src)] has toggled [M.key]'s [blockname] block [state]!")
	else
		alert("Invalid mob")
