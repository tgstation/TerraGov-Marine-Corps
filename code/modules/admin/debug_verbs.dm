GLOBAL_VAR(AdminProcCaller)
GLOBAL_PROTECT(AdminProcCaller)
GLOBAL_VAR_INIT(AdminProcCallCount, 0)
GLOBAL_PROTECT(AdminProcCallCount)
GLOBAL_VAR(LastAdminCalledTargetRef)
GLOBAL_PROTECT(LastAdminCalledTargetRef)
GLOBAL_VAR(LastAdminCalledTarget)
GLOBAL_PROTECT(LastAdminCalledTarget)
GLOBAL_VAR(LastAdminCalledProc)
GLOBAL_PROTECT(LastAdminCalledProc)
GLOBAL_LIST_EMPTY(AdminProcCallSpamPrevention)
GLOBAL_PROTECT(AdminProcCallSpamPrevention)

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
Call proc /mob/proc/Dizzy() for some player
Because if you select a player mob as owner it tries to do the proc for
/mob/living/carbon/human/ instead. And that gives a run-time error.
But you can call procs that are of type /mob/living/carbon/human/proc/ for that player.
*/

/client/proc/callproc()
	set category = "Debug"
	set name = "Advanced ProcCall"
	set waitfor = 0

	if(!check_rights(R_DEBUG)) return
	if(CONFIG_GET(flag/debugparanoid) && !check_rights(R_ADMIN)) return

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
			to_chat(usr, "<font color='red'>Error: callproc(): owner of proc no longer exists.</font>")
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
			to_chat(usr, "<font color='red'>Error: callproc(): target has no such call [procname].</font>")
			return
		log_admin("[key_name(src)] called [target]'s [procname]() with [lst.len ? "the arguments [list2params(lst)]":"no arguments"].")
		returnval = call(target,actual_name)(arglist(lst)) // Pass the lst as an argument list to the proc
	else
		//this currently has no hascall protection. wasn't able to get it working.
		log_admin("[key_name(src)] called [procname]() with [lst.len ? "the arguments [list2params(lst)]":"no arguments"].")
		returnval = call(procname)(arglist(lst)) // Pass the lst as an argument list to the proc

	to_chat(usr, "<font color='blue'>[procname] returned: [returnval ? returnval : "null"]</font>")
	feedback_add_details("admin_verb","APC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!



/client/proc/callatomproc(atom/A)
	set category = "Debug"
	set name = "Atom ProcCall"
	set waitfor = 0

	if(!check_rights(R_DEBUG)) return
	if(CONFIG_GET(flag/debugparanoid) && !check_rights(R_ADMIN)) return

	var/lst[] // List reference
	lst = new/list() // Make the list
	var/returnval = null
	var/class = null

	var/procname = input("Proc name, eg: attack_hand","Proc:", null) as text|null
	if(!procname)
		return

	if(!hascall(A,procname))
		to_chat(usr, "<font color='red'>Error: callatomproc(): type [A.type] has no proc named [procname].</font>")
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
	message_admins("<span class='notice'> [key_name_admin(src)] called [A]'s [procname]() with [lst.len ? "the arguments [list2params(lst)]":"no arguments"].</span>")
	returnval = call(A,procname)(arglist(lst)) // Pass the lst as an argument list to the proc
	to_chat(usr, "<font color='blue'>[procname] returned: [returnval ? returnval : "null"]</font>")
	feedback_add_details("admin_verb","AAPC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_robotize(var/mob/M in mob_list)
	set category = "Fun"
	set name = "Make Robot"

	if(!ticker)
		alert("Wait until the game starts")
		return

	if(M.gc_destroyed)
		alert("That mob doesn't seem to exist, close the panel and try again.")
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

	if(!M.gc_destroyed)
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

	if(M.gc_destroyed)
		alert("That mob doesn't seem to exist, close the panel and try again.")
		return

	if(ishuman(M))
		log_admin("[key_name(src)] has alienized [M.key].")
		spawn(10)
			M:Alienize()
			feedback_add_details("admin_verb","MKAL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		log_admin("[key_name(usr)] made [key_name(M)] into an alien.")
		message_admins("<span class='notice'> [key_name_admin(usr)] made [key_name(M)] into an alien.</span>", 1)
	else
		alert("Invalid mob")

/client/proc/cmd_admin_change_hivenumber(mob/living/carbon/Xenomorph/X in mob_list)
	set category = "Debug"
	set name = "Change Hivenumber"

	if(!check_rights(R_DEBUG|R_ADMIN))
		return

	if(!istype(X))
		to_chat(usr, "This can only be done to instances of type /mob/living/carbon/Xenomorph")
		return

	var/hivenumber_status = X.hivenumber

	var/list/namelist = list()
	for(var/datum/hive_status/H in hive_datum) // global hive datum list
		namelist += H.name

	var/newhive = input(src, "Select a hive.", null, null) in namelist

	if(!X || !istype(X))
		return

	var/newhivenumber
	switch(newhive)
		if("Normal")
			newhivenumber = XENO_HIVE_NORMAL
		if("Corrupted")
			newhivenumber = XENO_HIVE_CORRUPTED
		if("Alpha")
			newhivenumber = XENO_HIVE_ALPHA
		if("Beta")
			newhivenumber = XENO_HIVE_BETA
		if("Zeta")
			newhivenumber = XENO_HIVE_ZETA
		else
			return

	if(X.hivenumber != hivenumber_status)
		to_chat(usr, "Someone else changed this xeno while you were deciding")
		return

	if(!ticker)
		alert("Wait until the game starts")
		return

	if(!X || X.gc_destroyed)
		alert("That mob doesn't seem to exist, close the panel and try again.")
		return

	log_admin("[key_name(src)] changed hivenumber of [X] to [newhive].")
	message_admins("<span class='boldnotice'>[key_name(src)] changed hivenumber of [X] to [newhive].</span>", 1)

	X.set_hive_number(newhivenumber)

	feedback_add_details("admin_verb","CHHN") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


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
				to_chat(usr, "<span class = 'warning'>Only works for types of /obj or /mob.</span>")
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
								qdel(O)
						log_admin("[key_name(src)] has deleted all instances of [hsbitem] ([del_amt]).")
						message_admins("[key_name_admin(src)] has deleted all instances of [hsbitem] ([del_amt]).", 0)
		else
			to_chat(usr, "<span class = 'warning'>Not a valid type path.</span>")
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
			H.equip_to_slot_or_del(id, SLOT_WEAR_ID)
			H.update_inv_wear_id()
	else
		alert("Invalid mob")
	feedback_add_details("admin_verb","GFA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(src)] has granted [M.key] full access.")
	message_admins("<span class='notice'> [key_name_admin(usr)] has granted [M.key] full access.</span>", 1)

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
	message_admins("<span class='notice'> [key_name_admin(usr)] has granted [M.key] all skills.</span>", 1)

/client/proc/cmd_admin_changesquad(var/mob/living/carbon/human/H in mob_list)
	set category = "Admin"
	set name = "Change Squad"

	if(!check_rights(R_DEBUG|R_ADMIN))
		alert("Insufficient permissions.")
		return

	if(!ticker)
		alert("Wait until the game starts.")
		return

	if(!istype(H))
		alert("Invalid mob.")
		return

	if(!H.mind?.assigned_role)
		alert("Mob has no mind or role.")
		return

	switch(H.mind.assigned_role)
		if(!("Squad Marine" || "Squad Engineer" || "Squad Medic" || "Squad Smartgunner" || "Squad Specialist" || "Squad Leader"))
			alert("Invalid role")
			return

	H.set_everything(H.mind.assigned_role)

	H.assigned_squad?.remove_marine_from_squad(H)

	var/datum/squad/S = input(usr, "Choose the marine's new squad") as null|anything in RoleAuthority.squads
	if(!S)
		return

	S.put_marine_in_squad(H)

	for(var/datum/data/record/t in data_core.general) //we update the crew manifest
		if(t.fields["name"] == H.real_name)
			t.fields["squad"] = S.name
			break

	var/obj/item/card/id/ID = H.wear_id
	ID.assigned_fireteam = 0 //reset fireteam assignment

	//Changes headset frequency to match new squad
	if(istype(H.wear_ear, /obj/item/device/radio/headset/almayer/marine))
		var/obj/item/device/radio/headset/almayer/marine/E = H.wear_ear
		E.set_frequency(S.radio_freq)
	else
		if(H.wear_ear)
			qdel(H.wear_ear)
			H.update_icons()
		H.wear_ear = new /obj/item/device/radio/headset/almayer/marine
		var/obj/item/device/radio/headset/almayer/marine/E = H.wear_ear
		E.set_frequency(S.radio_freq)
		H.update_icons()

	H.hud_set_squad()

	feedback_add_details("admin_verb","CSQ") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(src)] has changed the squad of [H.key] to [S].")
	message_admins("<span class='boldnotice'>[key_name_admin(usr)] has changed the squad of [H.key] to [S].</span>", 1)

/client/proc/cmd_assume_direct_control(var/mob/M in mob_list)
	set category = "Admin"
	set name = "Assume direct control"
	set desc = "Direct intervention"

	if(!check_rights(R_DEBUG|R_ADMIN))	return
	if(M.gc_destroyed) return //mob is garbage collected
	if(M.ckey)
		if(alert("This mob is being controlled by [M.ckey]. Are you sure you wish to assume control of it? [M.ckey] will be made a ghost.",,"Yes","No") != "Yes")
			return
		else
			var/mob/dead/observer/ghost = new/mob/dead/observer(M,1)
			ghost.ckey = M.ckey
			if(ghost.client) ghost.client.change_view(world.view)
	message_admins("<span class='notice'> [key_name_admin(usr)] assumed direct control of [M].</span>", 1)
	log_admin("[key_name(usr)] assumed direct control of [M].")
	var/mob/adminmob = src.mob
	M.ckey = src.ckey
	if(M.client) M.client.change_view(world.view)
	if( isobserver(adminmob) )
		qdel(adminmob)
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

	to_chat(world, "<b>AREAS WITHOUT AN APC:</b>")
	for(var/areatype in areas_without_APC)
		to_chat(world, "* [areatype]")

	to_chat(world, "<b>AREAS WITHOUT AN AIR ALARM:</b>")
	for(var/areatype in areas_without_air_alarm)
		to_chat(world, "* [areatype]")

	to_chat(world, "<b>AREAS WITHOUT A REQUEST CONSOLE:</b>")
	for(var/areatype in areas_without_RC)
		to_chat(world, "* [areatype]")

	to_chat(world, "<b>AREAS WITHOUT ANY LIGHTS:</b>")
	for(var/areatype in areas_without_light)
		to_chat(world, "* [areatype]")

	to_chat(world, "<b>AREAS WITHOUT A LIGHT SWITCH:</b>")
	for(var/areatype in areas_without_LS)
		to_chat(world, "* [areatype]")

	to_chat(world, "<b>AREAS WITHOUT ANY INTERCOMS:</b>")
	for(var/areatype in areas_without_intercom)
		to_chat(world, "* [areatype]")

	to_chat(world, "<b>AREAS WITHOUT ANY CAMERAS:</b>")
	for(var/areatype in areas_without_camera)
		to_chat(world, "* [areatype]")


/client/proc/cmd_debug_mob_lists()
	set category = "Debug"
	set name = "Debug Mob Lists"
	set desc = "For when you just gotta know"

	switch(input("Which list?") in list("Players","Admins","Mobs","Living Mobs","Dead Mobs", "Clients"))
		if("Players")
			to_chat(usr, list2text(player_list,","))
		if("Admins")
			to_chat(usr, list2text(admins,","))
		if("Mobs")
			to_chat(usr, list2text(mob_list,","))
		if("Living Mobs")
			to_chat(usr, list2text(living_mob_list,","))
		if("Dead Mobs")
			to_chat(usr, list2text(dead_mob_list,","))
		if("Clients")
			to_chat(usr, list2text(clients,","))

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

/datum/admins/proc/spawn_atom(var/object as text)
	set category = "Debug"
	set desc = "(atom path) Spawn an atom"
	set name = "Spawn"

	if(!check_rights(R_SPAWN))	return

	var/list/types = typesof(/atom)
	var/list/matches = new()

	for(var/path in types)
		if(findtext("[path]", object))
			matches += path

	if(matches.len==0)
		return

	var/chosen
	if(matches.len==1)
		chosen = matches[1]
	else
		chosen = input("Select an atom type", "Spawn Atom", matches[1]) as null|anything in matches
		if(!chosen)
			return

	if(ispath(chosen,/turf))
		var/turf/T = get_turf(usr.loc)
		T.ChangeTurf(chosen)
	else
		new chosen(usr.loc)

	log_admin("[key_name(usr)] spawned [chosen] at ([usr.x],[usr.y],[usr.z])")
	feedback_add_details("admin_verb","SA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


//Merged Doohl's and the existing ticklag as they both had good elements about them ~Carn

/client/proc/ticklag()
	set category = "Debug"
	set name = "Set Ticklag"
	set desc = "Sets a new tick lag. Recommend you don't mess with this too much! Stable, time-tested ticklag value is 0.9"

	if(!check_rights(R_DEBUG))	return

	var/newtick = input("Sets a new tick lag. Please don't mess with this too much! The stable, time-tested ticklag value is 0.9","Lag of Tick", world.tick_lag) as num|null
	//I've used ticks of 2 before to help with serious singulo lags
	if(newtick && newtick <= 2 && newtick > 0)
		log_admin("[key_name(src)] has modified world.tick_lag to [newtick]", 0)
		message_admins("[key_name(src)] has modified world.tick_lag to [newtick]", 0)
		world.tick_lag = newtick
		feedback_add_details("admin_verb","TICKLAG") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

		switch(alert("Enable Tick Compensation?","Tick Comp is currently: [CONFIG_GET(flag/tickcomp)]","Yes","No"))
			if("Yes")	CONFIG_SET(flag/tickcomp, TRUE)
			else		CONFIG_SET(flag/tickcomp, FALSE)
	else
		to_chat(src, "<span class='warning'>Error: ticklag(): Invalid world.ticklag value. No changes made.</span>")



/client/proc/spatialagent()
	set category = "Debug"
	set name = "Spawn Spatial Agent"
	set desc = "Spawns a Spatial Agent. Useful for debugging."

	if (!check_rights(R_DEBUG))
		return

	var/T = get_turf(usr)
	var/mob/living/carbon/human/sa/sa = new(T)
	sa.ckey = usr.ckey
	change_view(world.view)
	sa.name = "Spatial Agent"
	sa.real_name = "Spatial Agent"
	sa.voice_name = "Spatial Agent"
	sa.h_style = "Cut Hair"

	var/datum/job/J = new /datum/job/other/spatial_agent
	J.generate_equipment(sa)
	J.generate_entry_conditions(sa)

//Spatial Agent human.
/mob/living/human/sa
	status_flags = CANPUSH

//Verbs.
/mob/living/carbon/human/sa/verb/sarejuv()
	set name = "Rejuvenate"
	set desc = "Restores your health."
	set category = "Agent"
	set popup_menu = 0

	revive()

/mob/living/carbon/human/sa/verb/leave()
	set name = "Teleport Out"
	set desc = "Ghosts you and deletes your mob."
	set category = "Agent"

	ghost()
	qdel(src)


datum

var/global/enable_power_update_profiling = 0

var/global/power_profiled_time = 0
var/global/power_last_profile_time = 0
var/global/list/power_update_requests_by_machine = list()
var/global/list/power_update_requests_by_area = list()

/proc/log_power_update_request(area/A, obj/machinery/M)
	if (!enable_power_update_profiling)
		return

	var/machine_type = "[M.type]"
	if (machine_type in power_update_requests_by_machine)
		power_update_requests_by_machine[machine_type] += 1
	else
		power_update_requests_by_machine[machine_type] = 1

	if (A.name in power_update_requests_by_area)
		power_update_requests_by_area[A.name] += 1
	else
		power_update_requests_by_area[A.name] = 1

	power_profiled_time += (world.time - power_last_profile_time)
	power_last_profile_time = world.time

/client/proc/toggle_power_update_profiling()
	set name = "Toggle Area Power Update Profiling"
	set desc = "Toggles the recording of area power update requests."
	set category = "Debug"
	if(!check_rights(R_DEBUG))	return

	if(enable_power_update_profiling)
		enable_power_update_profiling = 0

		to_chat(usr, "Area power update profiling disabled.")
		message_admins("[key_name(src)] toggled area power update profiling off.")
		log_admin("[key_name(src)] toggled area power update profiling off.")
	else
		enable_power_update_profiling = 1
		power_last_profile_time = world.time

		to_chat(usr, "Area power update profiling enabled.")
		message_admins("[key_name(src)] toggled area power update profiling on.")
		log_admin("[key_name(src)] toggled area power update profiling on.")

	feedback_add_details("admin_verb","APUP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/view_power_update_stats_machines()
	set name = "View Area Power Update Statistics By Machines"
	set desc = "See which types of machines are triggering area power updates."
	set category = "Debug"

	if(!check_rights(R_DEBUG))	return

	to_chat(usr, "Total profiling time: [power_profiled_time] ticks")
	for (var/M in power_update_requests_by_machine)
		to_chat(usr, "[M] = [power_update_requests_by_machine[M]]")

/client/proc/view_power_update_stats_area()
	set name = "View Area Power Update Statistics By Area"
	set desc = "See which areas are having area power updates."
	set category = "Debug"

	if(!check_rights(R_DEBUG))	return

	to_chat(usr, "Total profiling time: [power_profiled_time] ticks")
	to_chat(usr, "Total profiling time: [power_profiled_time] ticks")
	for (var/A in power_update_requests_by_area)
		to_chat(usr, "[A] = [power_update_requests_by_area[A]]")


#define DEBUG_XENO 0

#if DEBUG_XENO
/mob/verb/debug_xeno_mind()
	set name =  "Debug Xeno Mind"
	set category = "Debug"
	set desc = "Shows whether or not a mine is contained within the xenomorph list."

	if(!ticker || ticker.current_state != GAME_STATE_PLAYING || !ticker.mode)
		to_chat(src, "<span class='warning'>The round is either not ready, or has already finished.</span>")
		return
	if(mind in ticker.mode.xenomorphs)
		to_chat(src, "<span class='debuginfo'>[src] mind is in the xenomorph list. Mind key is [mind.key].</span>")
		to_chat(src, "<span class='debuginfo'>Current mob is: [mind.current]. Original mob is: [mind.original].</span>")
	to_chat(else src, "<span class='debuginfo'>This xenomorph is not in the xenomorph list.</span>")
#endif

#undef DEBUG_XENO


// Debug for testing seed genes.
/client/proc/show_plant_genes()
	set category = "Debug"
	set name = "Show Plant Genes"
	set desc = "Prints the round's plant gene masks."

	if(!holder)	return

	if(!gene_tag_masks)
		to_chat(usr, "Gene masks not set.")
		return

	for(var/mask in gene_tag_masks)
		to_chat(usr, "[mask]: [gene_tag_masks[mask]]")


/client/proc/forceEvent(var/type in allEvents)
	set name = "Trigger Event (Debug Only)"
	set category = "Debug"

	if(!holder)
		return

	if(ispath(type))
		new type
		message_admins("[key_name_admin(usr)] has triggered an event. ([type])", 1)


#define DEBUG_ARMOR_PROTECTION 0

#if DEBUG_ARMOR_PROTECTION
/mob/living/carbon/human/verb/check_overall_protection()
	set name = "Get Armor Value"
	set category = "Debug"
	set desc = "Shows the armor value of the bullet category."

	var/armor = 0
	var/counter = 0
	for(var/X in H.limbs)
		var/datum/limb/E = X
		armor = getarmor_organ(E, "bullet")
		to_chat(src, "<span class='debuginfo'><b>[E.name]</b> is protected with <b>[armor]</b> armor against bullets.</span>")
		counter += armor
	to_chat(src, "<span class='debuginfo'>The overall armor score is: <b>[counter]</b>.</span>")
#endif


/client/proc/cmd_admin_delete(atom/O as obj|mob|turf in world)
	set category = "Debug"
	set name = "Delete"

	if (!holder)
		to_chat(src, "Only administrators may use this command.")
		return

	if (alert(src, "Are you sure you want to delete:\n[O]\nat ([O.x], [O.y], [O.z])?", "Confirmation", "Yes", "No") == "Yes")
		log_admin("[key_name(usr)] deleted [O] at ([O.x],[O.y],[O.z])")
		message_admins("[key_name_admin(usr)] (<A HREF='?_src_=holder;adminmoreinfo=\ref[usr]'>?</A>) (<A HREF='?_src_=holder;adminplayerobservejump=\ref[usr]'>JMP</A>) (<A HREF='?_src_=holder;adminplayerfollow=\ref[usr]'>FLW</a>) deleted [O] at ([O.x],[O.y],[O.z])", 1)
		feedback_add_details("admin_verb","DEL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		qdel(O)


/proc/givetestverbs(mob/M as mob in mob_list)
	set desc = "Give this guy possess/release verbs"
	set category = "Debug"
	set name = "Give Possessing Verbs"
	M.verbs += /proc/possess
	M.verbs += /proc/release
	feedback_add_details("admin_verb","GPV") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!



/client/proc/fix_next_move()
	set category = "Debug"
	set name = "Unfreeze Everyone"
	var/largest_move_time = 0
	var/largest_click_time = 0
	var/mob/largest_move_mob = null
	var/mob/largest_click_mob = null
	for(var/mob/M in mob_list)
		if(!M.client)
			continue
		if(M.next_move >= largest_move_time)
			largest_move_mob = M
			if(M.next_move > world.time)
				largest_move_time = M.next_move - world.time
			else
				largest_move_time = 1
		if(M.next_click >= largest_click_time)
			largest_click_mob = M
			if(M.next_click > world.time)
				largest_click_time = M.next_click - world.time
			else
				largest_click_time = 0
		log_admin("DEBUG: [key_name(M)]  next_move = [M.next_move]  next_click = [M.next_click]  world.time = [world.time]")
		M.next_move = 1
		M.next_click = 0
	message_admins("[key_name_admin(largest_move_mob)] had the largest move delay with [largest_move_time] frames / [largest_move_time/10] seconds!", 1)
	message_admins("[key_name_admin(largest_click_mob)] had the largest click delay with [largest_click_time] frames / [largest_click_time/10] seconds!", 1)
	message_admins("world.time = [world.time]", 1)
	feedback_add_details("admin_verb","UFE") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/radio_report()
	set category = "Debug"
	set name = "Radio report"

	var/output = "<b>Radio Report</b><hr>"
	for (var/fq in radio_controller.frequencies)
		output += "<b>Freq: [fq]</b><br>"
		var/list/datum/radio_frequency/fqs = radio_controller.frequencies[fq]
		if (!fqs)
			output += "&nbsp;&nbsp;<b>ERROR</b><br>"
			continue
		for (var/filter in fqs.devices)
			var/list/f = fqs.devices[filter]
			if (!f)
				output += "&nbsp;&nbsp;[filter]: ERROR<br>"
				continue
			output += "&nbsp;&nbsp;[filter]: [f.len]<br>"
			for (var/device in f)
				if (isobj(device))
					output += "&nbsp;&nbsp;&nbsp;&nbsp;[device] ([device:x],[device:y],[device:z] in area [get_area(device:loc)])<br>"
				else
					output += "&nbsp;&nbsp;&nbsp;&nbsp;[device]<br>"

	usr << browse(output,"window=radioreport")
	feedback_add_details("admin_verb","RR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/reload_admins()
	set name = "Reload Admins"
	set category = "Debug"

	if(!check_rights(R_SERVER))	return

	message_admins("[usr.ckey] manually reloaded admins.")
	load_admins()
	feedback_add_details("admin_verb","RLDA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/reload_whitelist()
	set name = "Reload Whitelist"
	set category = "Debug"

	if(!check_rights(R_SERVER) || !RoleAuthority) return

	message_admins("[usr.ckey] manually reloaded the role whitelist.")
	RoleAuthority.load_whitelist()



#define DEBUG_PREDATOR_INITIALIZE 0

#if DEBUG_PREDATOR_INITIALIZE
/mob/verb/adjust_predator_round()
	set name = "Adjust Predator Round"
	set category = "Debug"
	set desc = "Adjust the number of predators present in a predator round."

	if(!ticker || !ticker.mode)
		to_chat(src, "<span class='warning'>The game hasn't started yet!</span?")
		return FALSE

	ticker.mode.pred_maximum_num = input(src,"What is the new maximum number of predators?","Input:",4) as num|null
	ticker.mode.pred_current_num = input(src,"What is the new current number of predators?","Input:",0) as num|null
#endif



// reference: /client/proc/modify_variables(var/atom/O, var/param_var_name = null, var/autodetect_class = 0)

/datum/proc/vv_edit_var(var_name, var_value) //called whenever a var is edited
	if(var_name == NAMEOF(src, vars))
		return FALSE
	vars[var_name] = var_value
	datum_flags |= DF_VAR_EDITED
	return TRUE

client
	proc/debug_variables(datum/D in world)
		set category = "Debug"
		set name = "View Variables"

		if(!usr.client || !usr.client.holder || !(usr.client.holder.rights & R_MOD))
			to_chat(usr, "<span class='warning'>You need to be a moderator or higher to access this.</span>")
			return

		if(!D)	return

		var/title = ""
		var/body = ""

		//Sort of a temporary solution for right now.
		if(istype(D,/datum/admins) && !(ishost(usr))) //Prevents non-hosts from changing their own permissions.
			to_chat(usr, "<span class='warning'>You need host permission to access this.</span>")
			return

		if((istype(D,/datum/ammo) || istype(D,/mob/living/carbon/Xenomorph/Predalien)) && !(usr.client.holder.rights & R_DEBUG))
			to_chat(usr, "<span class='warning'>You need debugging permission to access this.</span>")
			return

		if(istype(D, /atom))
			var/atom/A = D
			title = "[A.name] (\ref[A]) = [A.type]"

			#ifdef VARSICON
			if (A.icon)
				body += debug_variable("icon", new/icon(A.icon, A.icon_state, A.dir), 0)
			#endif

		var/icon/sprite

		if(istype(D,/atom))
			var/atom/AT = D
			if(AT.icon && AT.icon_state)
				sprite = new /icon(AT.icon, AT.icon_state)
				usr << browse_rsc(sprite, "view_vars_sprite.png")

		title = "[D] (\ref[D]) = [D.type]"

		body += {"<script type="text/javascript">

					function updateSearch(){
						var filter_text = document.getElementById('filter');
						var filter = filter_text.value.toLowerCase();

						if(event.keyCode == 13){	//Enter / return
							var vars_ol = document.getElementById('vars');
							var lis = vars_ol.getElementsByTagName("li");
							for ( var i = 0; i < lis.length; ++i )
							{
								try{
									var li = lis\[i\];
									if ( li.style.backgroundColor == "#ffee88" )
									{
										alist = lis\[i\].getElementsByTagName("a")
										if(alist.length > 0){
											location.href=alist\[0\].href;
										}
									}
								}catch(err) {   }
							}
							return
						}

						if(event.keyCode == 38){	//Up arrow
							var vars_ol = document.getElementById('vars');
							var lis = vars_ol.getElementsByTagName("li");
							for ( var i = 0; i < lis.length; ++i )
							{
								try{
									var li = lis\[i\];
									if ( li.style.backgroundColor == "#ffee88" )
									{
										if( (i-1) >= 0){
											var li_new = lis\[i-1\];
											li.style.backgroundColor = "white";
											li_new.style.backgroundColor = "#ffee88";
											return
										}
									}
								}catch(err) {  }
							}
							return
						}

						if(event.keyCode == 40){	//Down arrow
							var vars_ol = document.getElementById('vars');
							var lis = vars_ol.getElementsByTagName("li");
							for ( var i = 0; i < lis.length; ++i )
							{
								try{
									var li = lis\[i\];
									if ( li.style.backgroundColor == "#ffee88" )
									{
										if( (i+1) < lis.length){
											var li_new = lis\[i+1\];
											li.style.backgroundColor = "white";
											li_new.style.backgroundColor = "#ffee88";
											return
										}
									}
								}catch(err) {  }
							}
							return
						}

						//This part here resets everything to how it was at the start so the filter is applied to the complete list. Screw efficiency, it's client-side anyway and it only looks through 200 or so variables at maximum anyway (mobs).
						if(complete_list != null && complete_list != ""){
							var vars_ol1 = document.getElementById("vars");
							vars_ol1.innerHTML = complete_list
						}

						if(filter.value == ""){
							return;
						}else{
							var vars_ol = document.getElementById('vars');
							var lis = vars_ol.getElementsByTagName("li");

							for ( var i = 0; i < lis.length; ++i )
							{
								try{
									var li = lis\[i\];
									if ( li.innerText.toLowerCase().indexOf(filter) == -1 )
									{
										vars_ol.removeChild(li);
										i--;
									}
								}catch(err) {   }
							}
						}
						var lis_new = vars_ol.getElementsByTagName("li");
						for ( var j = 0; j < lis_new.length; ++j )
						{
							var li1 = lis\[j\];
							if (j == 0){
								li1.style.backgroundColor = "#ffee88";
							}else{
								li1.style.backgroundColor = "white";
							}
						}
					}



					function selectTextField(){
						var filter_text = document.getElementById('filter');
						filter_text.focus();
						filter_text.select();

					}

					function loadPage(list) {

						if(list.options\[list.selectedIndex\].value == ""){
							return;
						}

						location.href=list.options\[list.selectedIndex\].value;

					}
				</script> "}

		body += "<body onload='selectTextField(); updateSearch()' onkeyup='updateSearch()'>"

		body += "<div align='center'><table width='100%'><tr><td width='50%'>"

		if(sprite)
			body += "<table align='center' width='100%'><tr><td><img src='view_vars_sprite.png'></td><td>"
		else
			body += "<table align='center' width='100%'><tr><td>"

		body += "<div align='center'>"

		if(istype(D,/atom))
			var/atom/A = D
			if(isliving(A))
				body += "<a href='?_src_=vars;rename=\ref[D]'><b>[D]</b></a>"
				if(A.dir)
					body += "<br><font size='1'><a href='?_src_=vars;rotatedatum=\ref[D];rotatedir=left'><<</a> <a href='?_src_=vars;datumedit=\ref[D];varnameedit=dir'>[dir2text(A.dir)]</a> <a href='?_src_=vars;rotatedatum=\ref[D];rotatedir=right'>>></a></font>"
				var/mob/living/M = A
				body += "<br><font size='1'><a href='?_src_=vars;datumedit=\ref[D];varnameedit=ckey'>[M.ckey ? M.ckey : "No ckey"]</a> / <a href='?_src_=vars;datumedit=\ref[D];varnameedit=real_name'>[M.real_name ? M.real_name : "No real name"]</a></font>"
				body += {"
				<br><font size='1'>
				BRUTE:<font size='1'><a href='?_src_=vars;mobToDamage=\ref[D];adjustDamage=brute'>[M.getBruteLoss()]</a>
				FIRE:<font size='1'><a href='?_src_=vars;mobToDamage=\ref[D];adjustDamage=fire'>[M.getFireLoss()]</a>
				TOXIN:<font size='1'><a href='?_src_=vars;mobToDamage=\ref[D];adjustDamage=toxin'>[M.getToxLoss()]</a>
				OXY:<font size='1'><a href='?_src_=vars;mobToDamage=\ref[D];adjustDamage=oxygen'>[M.getOxyLoss()]</a>
				CLONE:<font size='1'><a href='?_src_=vars;mobToDamage=\ref[D];adjustDamage=clone'>[M.getCloneLoss()]</a>
				BRAIN:<font size='1'><a href='?_src_=vars;mobToDamage=\ref[D];adjustDamage=brain'>[M.getBrainLoss()]</a>
				</font>


				"}
			else
				body += "<a href='?_src_=vars;datumedit=\ref[D];varnameedit=name'><b>[D]</b></a>"
				if(A.dir)
					body += "<br><font size='1'><a href='?_src_=vars;rotatedatum=\ref[D];rotatedir=left'><<</a> <a href='?_src_=vars;datumedit=\ref[D];varnameedit=dir'>[dir2text(A.dir)]</a> <a href='?_src_=vars;rotatedatum=\ref[D];rotatedir=right'>>></a></font>"
		else
			body += "<b>[D]</b>"

		body += "</div>"

		body += "</tr></td></table>"

		var/formatted_type = text("[D.type]")
		if(length(formatted_type) > 25)
			var/middle_point = length(formatted_type) / 2
			var/splitpoint = findtext(formatted_type,"/",middle_point)
			if(splitpoint)
				formatted_type = "[copytext(formatted_type,1,splitpoint)]<br>[copytext(formatted_type,splitpoint)]"
			else
				formatted_type = "Type too long" //No suitable splitpoint (/) found.

		body += "<div align='center'><b><font size='1'>[formatted_type]</font></b>"

		if(src.holder && src.holder.marked_datum && src.holder.marked_datum == D)
			body += "<br><font size='1' color='red'><b>Marked Object</b></font>"

		body += "</div>"

		body += "</div></td>"

		body += "<td width='50%'><div align='center'><a href='?_src_=vars;datumrefresh=\ref[D]'>Refresh</a>"

		//if(ismob(D))
		//	body += "<br><a href='?_src_=vars;mob_player_panel=\ref[D]'>Show player panel</a></div></td></tr></table></div><hr>"

		body += {"	<form>
					<select name="file" size="1"
					onchange="loadPage(this.form.elements\[0\])"
					target="_parent._top"
					onmouseclick="this.focus()"
					style="background-color:#ffffff">
				"}

		body += {"	<option value>Select option</option>
  					<option value> </option>
				"}


		body += "<option value='?_src_=vars;mark_object=\ref[D]'>Mark Object</option>"
		if(ismob(D))
			body += "<option value='?_src_=vars;mob_player_panel=\ref[D]'>Show player panel</option>"

		body += "<option value>---</option>"

		if(ismob(D))
			body += "<option value='?_src_=vars;give_spell=\ref[D]'>Give Spell</option>"
			body += "<option value='?_src_=vars;give_disease=\ref[D]'>Give TG-style Disease</option>"
			body += "<option value='?_src_=vars;godmode=\ref[D]'>Toggle Godmode</option>"
			body += "<option value='?_src_=vars;build_mode=\ref[D]'>Toggle Build Mode</option>"

			body += "<option value='?_src_=vars;ninja=\ref[D]'>Make Space Ninja</option>"
			body += "<option value='?_src_=vars;make_skeleton=\ref[D]'>Make 2spooky</option>"

			body += "<option value='?_src_=vars;direct_control=\ref[D]'>Assume Direct Control</option>"
			body += "<option value='?_src_=vars;drop_everything=\ref[D]'>Drop Everything</option>"

			body += "<option value='?_src_=vars;regenerateicons=\ref[D]'>Regenerate Icons</option>"
			body += "<option value='?_src_=vars;addlanguage=\ref[D]'>Add Language</option>"
			body += "<option value='?_src_=vars;remlanguage=\ref[D]'>Remove Language</option>"
			body += "<option value='?_src_=vars;addorgan=\ref[D]'>Add Organ</option>"
			body += "<option value='?_src_=vars;remorgan=\ref[D]'>Remove Organ</option>"
			body += "<option value='?_src_=vars;addlimb=\ref[D]'>Add Limb</option>"
			body += "<option value='?_src_=vars;remlimb=\ref[D]'>Remove Limb</option>"

			body += "<option value='?_src_=vars;fix_nano=\ref[D]'>Fix NanoUI</option>"

			body += "<option value='?_src_=vars;addverb=\ref[D]'>Add Verb</option>"
			body += "<option value='?_src_=vars;remverb=\ref[D]'>Remove Verb</option>"
			if(ishuman(D))
				body += "<option value>---</option>"
				body += "<option value='?_src_=vars;edit_skill=\ref[D]'>Edit Skills</option>"
				body += "<option value='?_src_=vars;setmutantrace=\ref[D]'>Set Mutantrace</option>"
				body += "<option value='?_src_=vars;setspecies=\ref[D]'>Set Species</option>"
				body += "<option value='?_src_=vars;makeai=\ref[D]'>Make AI</option>"
				body += "<option value='?_src_=vars;makerobot=\ref[D]'>Make cyborg</option>"
				body += "<option value='?_src_=vars;makemonkey=\ref[D]'>Make monkey</option>"
				body += "<option value='?_src_=vars;makealien=\ref[D]'>Make alien</option>"
			body += "<option value>---</option>"
			body += "<option value='?_src_=vars;gib=\ref[D]'>Gib</option>"
		if(isobj(D))
			body += "<option value='?_src_=vars;delall=\ref[D]'>Delete all of type</option>"
		if(isobj(D) || ismob(D) || isturf(D))
			body += "<option value='?_src_=vars;explode=\ref[D]'>Trigger explosion</option>"
			body += "<option value='?_src_=vars;emp=\ref[D]'>Trigger EM pulse</option>"

		body += "</select></form>"

		body += "</div></td></tr></table></div><hr>"

		body += "<font size='1'><b>E</b> - Edit, tries to determine the variable type by itself.<br>"
		body += "<b>C</b> - Change, asks you for the var type first.<br>"
		body += "<b>M</b> - Mass modify: changes this variable for all objects of this type.</font><br>"

		body += "<hr><table width='100%'><tr><td width='20%'><div align='center'><b>Search:</b></div></td><td width='80%'><input type='text' id='filter' name='filter_text' value='' style='width:100%;'></td></tr></table><hr>"

		body += "<ol id='vars'>"

		var/list/names = list()
		for (var/V in D.vars)
			names += V

		names = sortList(names)

		for (var/V in names)
			body += debug_variable(V, D.vars[V], 0, D)

		body += "</ol>"

		var/html = "<html><head>"
		if (title)
			html += "<title>[title]</title>"
		html += {"<style>
	body
	{
		font-family: Verdana, sans-serif;
		font-size: 9pt;
	}
	.value
	{
		font-family: "Courier New", monospace;
		font-size: 8pt;
	}
	</style>"}
		html += "</head><body>"
		html += body

		html += {"
			<script type='text/javascript'>
				var vars_ol = document.getElementById("vars");
				var complete_list = vars_ol.innerHTML;
			</script>
		"}

		html += "</body></html>"

		usr << browse(html, "window=variables\ref[D];size=475x650")

		return

	proc/debug_variable(name, value, level, var/datum/DA = null)
		var/html = ""

		if(DA)
			html += "<li style='backgroundColor:white'>(<a href='?_src_=vars;datumedit=\ref[DA];varnameedit=[name]'>E</a>) (<a href='?_src_=vars;datumchange=\ref[DA];varnamechange=[name]'>C</a>) (<a href='?_src_=vars;datummass=\ref[DA];varnamemass=[name]'>M</a>) "
		else
			html += "<li>"

		if (isnull(value))
			html += "[name] = <span class='value'>null</span>"

		else if (istext(value))
			html += "[name] = <span class='value'>\"[value]\"</span>"

		else if (isicon(value))
			#ifdef VARSICON
			var/icon/I = new/icon(value)
			var/rnd = rand(1,10000)
			var/rname = "tmp\ref[I][rnd].png"
			usr << browse_rsc(I, rname)
			html += "[name] = (<span class='value'>[value]</span>) <img class=icon src=\"[rname]\">"
			#else
			html += "[name] = /icon (<span class='value'>[value]</span>)"
			#endif

/*		else if (istype(value, /image))
			#ifdef VARSICON
			var/rnd = rand(1, 10000)
			var/image/I = value

			src << browse_rsc(I.icon, "tmp\ref[value][rnd].png")
			html += "[name] = <img src=\"tmp\ref[value][rnd].png\">"
			#else
			html += "[name] = /image (<span class='value'>[value]</span>)"
			#endif
*/
		else if (isfile(value))
			html += "[name] = <span class='value'>'[value]'</span>"

		else if (istype(value, /datum))
			var/datum/D = value
			html += "<a href='?_src_=vars;Vars=\ref[value]'>[name] \ref[value]</a> = [D.type]"

		else if (istype(value, /client))
			var/client/C = value
			html += "<a href='?_src_=vars;Vars=\ref[value]'>[name] \ref[value]</a> = [C] [C.type]"
	//
		else if (istype(value, /list))
			var/list/L = value
			html += "[name] = /list ([L.len])"

			if (L.len > 0 && !(name == "underlays" || name == "overlays" || name == "vars" || L.len > 500))
				// not sure if this is completely right...
				if(0)   //(L.vars.len > 0)
					html += "<ol>"
					html += "</ol>"
				else
					html += "<ul>"
					var/index = 1
					for (var/entry in L)
						if(istext(entry))
							html += debug_variable(entry, L[entry], level + 1)
						//html += debug_variable("[index]", L[index], level + 1)
						else
							html += debug_variable(index, L[index], level + 1)
						index++
					html += "</ul>"

		else
			html += "[name] = <span class='value'>[value]</span>"

		html += "</li>"

		return html

/client/proc/view_var_Topic(href, href_list, hsrc)
	//This should all be moved over to datum/admins/Topic() or something ~Carn
	if( (usr.client != src) || !src.holder )
		return
	if(href_list["Vars"])
		debug_variables(locate(href_list["Vars"]))

	//~CARN: for renaming mobs (updates their name, real_name, mind.name, their ID/PDA and datacore records).
	else if(href_list["rename"])
		if(!check_rights(R_VAREDIT))	return

		var/mob/M = locate(href_list["rename"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		var/new_name = stripped_input(usr,"What would you like to name this mob?","Input a name",M.real_name,MAX_NAME_LEN)
		if( !new_name || !M )	return

		message_admins("Admin [key_name_admin(usr)] renamed [key_name_admin(M)] to [new_name].")
		M.fully_replace_character_name(M.real_name,new_name)
		href_list["datumrefresh"] = href_list["rename"]

	else if(href_list["varnameedit"] && href_list["datumedit"])
		if(!check_rights(R_VAREDIT))	return

		var/D = locate(href_list["datumedit"])
		if(!istype(D,/datum) && !istype(D,/client))
			to_chat(usr, "This can only be used on instances of types /client or /datum")
			return

		modify_variables(D, href_list["varnameedit"], 1)

	else if(href_list["varnamechange"] && href_list["datumchange"])
		if(!check_rights(R_VAREDIT))	return

		var/D = locate(href_list["datumchange"])
		if(!istype(D,/datum) && !istype(D,/client))
			to_chat(usr, "This can only be used on instances of types /client or /datum")
			return

		modify_variables(D, href_list["varnamechange"], 0)

	else if(href_list["varnamemass"] && href_list["datummass"])
		if(!check_rights(R_VAREDIT))	return

		var/atom/A = locate(href_list["datummass"])
		if(!istype(A))
			to_chat(usr, "This can only be used on instances of type /atom")
			return

		cmd_mass_modify_object_variables(A, href_list["varnamemass"])

	else if(href_list["mob_player_panel"])
		if(!check_rights(0))	return

		var/mob/M = locate(href_list["mob_player_panel"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		src.holder.show_player_panel(M)
		href_list["datumrefresh"] = href_list["mob_player_panel"]

	else if(href_list["give_spell"])
		if(!check_rights(R_ADMIN|R_FUN))	return

		var/mob/M = locate(href_list["give_spell"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		src.give_spell(M)
		href_list["datumrefresh"] = href_list["give_spell"]

	else if(href_list["give_disease"])
		if(!check_rights(R_ADMIN|R_FUN))	return

		var/mob/M = locate(href_list["give_disease"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		src.give_disease(M)
		href_list["datumrefresh"] = href_list["give_spell"]

	else if(href_list["godmode"])
		if(!check_rights(R_REJUVINATE))	return

		var/mob/M = locate(href_list["godmode"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		src.cmd_admin_godmode(M)
		href_list["datumrefresh"] = href_list["godmode"]

	else if(href_list["gib"])
		if(!check_rights(0))	return

		var/mob/M = locate(href_list["gib"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		src.cmd_admin_gib(M)

	else if(href_list["drop_everything"])
		if(!check_rights(R_DEBUG|R_ADMIN))	return

		var/mob/M = locate(href_list["drop_everything"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		if(usr.client)
			usr.client.cmd_admin_drop_everything(M)

	else if(href_list["direct_control"])
		if(!check_rights(0))	return

		var/mob/M = locate(href_list["direct_control"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		if(usr.client)
			usr.client.cmd_assume_direct_control(M)

	else if(href_list["make_skeleton"])
		if(!check_rights(R_FUN))	return

		var/mob/living/carbon/human/H = locate(href_list["make_skeleton"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
			return

		H.makeSkeleton()
		href_list["datumrefresh"] = href_list["make_skeleton"]

	else if(href_list["delall"])
		if(!check_rights(R_DEBUG|R_SERVER))	return

		var/obj/O = locate(href_list["delall"])
		if(!isobj(O))
			to_chat(usr, "This can only be used on instances of type /obj")
			return

		var/action_type = alert("Strict type ([O.type]) or type and all subtypes?",,"Strict type","Type and subtypes","Cancel")
		if(action_type == "Cancel" || !action_type)
			return

		if(alert("Are you really sure you want to delete all objects of type [O.type]?",,"Yes","No") != "Yes")
			return

		if(alert("Second confirmation required. Delete?",,"Yes","No") != "Yes")
			return

		var/O_type = O.type
		switch(action_type)
			if("Strict type")
				var/i = 0
				for(var/obj/Obj in object_list)
					if(Obj.type == O_type)
						i++
						qdel(Obj)
				if(!i)
					to_chat(usr, "No objects of this type exist")
					return
				log_admin("[key_name(usr)] deleted all objects of type [O_type] ([i] objects deleted) ")
				message_admins("<span class='notice'> [key_name(usr)] deleted all objects of type [O_type] ([i] objects deleted) </span>")
			if("Type and subtypes")
				var/i = 0
				for(var/obj/Obj in object_list)
					if(istype(Obj,O_type))
						i++
						qdel(Obj)
				if(!i)
					to_chat(usr, "No objects of this type exist")
					return
				log_admin("[key_name(usr)] deleted all objects of type or subtype of [O_type] ([i] objects deleted) ")
				message_admins("<span class='notice'> [key_name(usr)] deleted all objects of type or subtype of [O_type] ([i] objects deleted) </span>")

	else if(href_list["explode"])
		if(!check_rights(R_DEBUG|R_FUN))	return

		var/atom/A = locate(href_list["explode"])
		if(!isobj(A) && !ismob(A) && !isturf(A))
			to_chat(usr, "This can only be done to instances of type /obj, /mob and /turf")
			return

		src.cmd_admin_explosion(A)
		href_list["datumrefresh"] = href_list["explode"]

	else if(href_list["emp"])
		if(!check_rights(R_DEBUG|R_FUN))	return

		var/atom/A = locate(href_list["emp"])
		if(!isobj(A) && !ismob(A) && !isturf(A))
			to_chat(usr, "This can only be done to instances of type /obj, /mob and /turf")
			return

		src.cmd_admin_emp(A)
		href_list["datumrefresh"] = href_list["emp"]

	else if(href_list["mark_object"])
		if(!check_rights(0))	return

		var/datum/D = locate(href_list["mark_object"])
		if(!istype(D))
			to_chat(usr, "This can only be done to instances of type /datum")
			return

		src.holder.marked_datum = D
		href_list["datumrefresh"] = href_list["mark_object"]

	else if(href_list["rotatedatum"])
		if(!check_rights(0))	return

		var/atom/A = locate(href_list["rotatedatum"])
		if(!istype(A))
			to_chat(usr, "This can only be done to instances of type /atom")
			return

		switch(href_list["rotatedir"])
			if("right")	A.dir = turn(A.dir, -45)
			if("left")	A.dir = turn(A.dir, 45)
		href_list["datumrefresh"] = href_list["rotatedatum"]

	else if(href_list["makemonkey"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locate(href_list["makemonkey"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
			return

		if(alert("Confirm mob type change?",,"Transform","Cancel") != "Transform")	return
		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return
		holder.Topic(href, list("monkeyone"=href_list["makemonkey"]))

	else if(href_list["makerobot"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locate(href_list["makerobot"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
			return

		if(alert("Confirm mob type change?",,"Transform","Cancel") != "Transform")	return
		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return
		holder.Topic(href, list("makerobot"=href_list["makerobot"]))

	else if(href_list["makealien"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locate(href_list["makealien"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
			return

		if(alert("Confirm mob type change?",,"Transform","Cancel") != "Transform")	return
		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return
		holder.Topic(href, list("makealien"=href_list["makealien"]))

	else if(href_list["makeai"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locate(href_list["makeai"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
			return

		if(alert("Confirm mob type change?",,"Transform","Cancel") != "Transform")	return
		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return
		holder.Topic(href, list("makeai"=href_list["makeai"]))

	else if(href_list["setmutantrace"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locate(href_list["setmutantrace"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
			return

		var/new_mutantrace = input("Please choose a new mutantrace","Mutantrace",null) as null|anything in list("NONE","golem","lizard","slime","plant","shadow","tajaran","skrell","vox")
		switch(new_mutantrace)
			if(null)
				return
			if("NONE")
				new_mutantrace = ""
		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return
		if(H.dna)
			H.dna.mutantrace = new_mutantrace
			H.update_mutantrace()

	else if(href_list["setspecies"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locate(href_list["setspecies"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
			return

		var/new_species = input("Please choose a new species.","Species",null) as null|anything in all_species

		if(!new_species) return

		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return

		if(H.set_species(new_species))
			to_chat(usr, "Set species of [H] to [H.species].")
		else
			to_chat(usr, "Failed! Something went wrong.")

	else if(href_list["edit_skill"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locate(href_list["edit_skill"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
			return

		if(!H.mind)
			to_chat(usr, "This can't be used on humans without a mind.")
			return

		if(!H.mind.cm_skills)
			H.mind.cm_skills = new /datum/skills/pfc()

		var/selected_skill = input("Please choose a skill to edit.","Skills",null) as null|anything in list("cqc","endurance","engineer", "construction","firearms", "pistols", "rifles", "smgs", "shotguns", "heavy_weapons","smartgun","spec_weapons","leadership","medical", "surgery","melee_weapons","pilot","police","powerloader")
		if(!selected_skill)
			return

		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return

		if(!H.mind)
			to_chat(usr, "Mob lost its mind.")
			return

		var/new_skill_level = input("Select a new level for the [selected_skill] skill ","New Skill Level") as null|num
		if(isnull(new_skill_level))
			return

		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return

		if(!H.mind)
			to_chat(usr, "Mob lost its mind.")
			return

		switch(selected_skill)
			if("cqc")
				H.mind.cm_skills.cqc = new_skill_level
			if("melee_weapons")
				H.mind.cm_skills.melee_weapons = new_skill_level
			if("firearms")
				H.mind.cm_skills.firearms = new_skill_level
			if("pistols")
				H.mind.cm_skills.pistols = new_skill_level
			if("rifles")
				H.mind.cm_skills.rifles = new_skill_level
			if("smgs")
				H.mind.cm_skills.smgs = new_skill_level
			if("shotguns")
				H.mind.cm_skills.shotguns = new_skill_level
			if("heavy_weapons")
				H.mind.cm_skills.heavy_weapons = new_skill_level
			if("smartgun")
				H.mind.cm_skills.smartgun = new_skill_level
			if("spec_weapons")
				H.mind.cm_skills.spec_weapons = new_skill_level
			if("leadership")
				H.mind.cm_skills.leadership = new_skill_level
			if("medical")
				H.mind.cm_skills.medical = new_skill_level
			if("surgery")
				H.mind.cm_skills.surgery = new_skill_level
			if("pilot")
				H.mind.cm_skills.pilot = new_skill_level
			if("endurance")
				H.mind.cm_skills.endurance = new_skill_level
			if("engineer")
				H.mind.cm_skills.engineer = new_skill_level
			if("construction")
				H.mind.cm_skills.construction = new_skill_level
			if("police")
				H.mind.cm_skills.police = new_skill_level
			if("powerloader")
				H.mind.cm_skills.powerloader = new_skill_level
		
		H.update_action_buttons()

		to_chat(usr, "[H]'s [selected_skill] skill is now set to [new_skill_level].")


	else if(href_list["addlanguage"])
		if(!check_rights(R_SPAWN))	return

		var/mob/H = locate(href_list["addlanguage"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob")
			return

		var/new_language = input("Please choose a language to add.","Language",null) as null|anything in all_languages

		if(!new_language)
			return

		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return

		if(H.add_language(new_language))
			to_chat(usr, "Added [new_language] to [H].")
		else
			to_chat(usr, "Mob already knows that language.")

	else if(href_list["remlanguage"])
		if(!check_rights(R_SPAWN))	return

		var/mob/H = locate(href_list["remlanguage"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob")
			return

		if(!H.languages.len)
			to_chat(usr, "This mob knows no languages.")
			return

		var/datum/language/rem_language = input("Please choose a language to remove.","Language",null) as null|anything in H.languages

		if(!rem_language)
			return

		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return

		if(H.remove_language(rem_language.name))
			to_chat(usr, "Removed [rem_language] from [H].")
		else
			to_chat(usr, "Mob doesn't know that language.")

	else if(href_list["addverb"])
		if(!check_rights(R_DEBUG))      return

		var/mob/living/H = locate(href_list["addverb"])

		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob/living")
			return
		var/list/possibleverbs = list()
		possibleverbs += "Cancel" 								// One for the top...
		possibleverbs += typesof(/mob/proc,/mob/verb,/mob/living/proc,/mob/living/verb)
		switch(H.type)
			if(/mob/living/carbon/human)
				possibleverbs += typesof(/mob/living/carbon/proc,/mob/living/carbon/verb,/mob/living/carbon/human/verb,/mob/living/carbon/human/proc)
			if(/mob/living/silicon/robot)
				possibleverbs += typesof(/mob/living/silicon/proc,/mob/living/silicon/robot/proc,/mob/living/silicon/robot/verb)
			if(/mob/living/silicon/ai)
				possibleverbs += typesof(/mob/living/silicon/proc,/mob/living/silicon/ai/proc,/mob/living/silicon/ai/verb)
		possibleverbs -= H.verbs
		possibleverbs += "Cancel" 								// ...And one for the bottom

		var/verb = input("Select a verb!", "Verbs",null) as anything in possibleverbs
		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return
		if(!verb || verb == "Cancel")
			return
		else
			H.verbs += verb

	else if(href_list["remverb"])
		if(!check_rights(R_DEBUG))      return

		var/mob/H = locate(href_list["remverb"])

		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob")
			return
		var/verb = input("Please choose a verb to remove.","Verbs",null) as null|anything in H.verbs
		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return
		if(!verb)
			return
		else
			H.verbs -= verb

	else if(href_list["addorgan"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/M = locate(href_list["addorgan"])
		if(!istype(M))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon")
			return

		var/new_organ = input("Please choose an organ to add.","Organ",null) as null|anything in subtypesof(/datum/internal_organ)

		if(!M)
			to_chat(usr, "Mob doesn't exist anymore")
			return

		if(locate(new_organ) in M.internal_organs)
			to_chat(usr, "Mob already has that organ.")
			return

		if(istype(M,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			var/datum/internal_organ/I = new new_organ(H)

			var/organ_slot = input(usr, "Which slot do you want the organ to go in ('default' for default)?")  as text|null

			if(!organ_slot)
				return

			if(organ_slot != "default")
				organ_slot = sanitize(copytext(organ_slot,1,MAX_MESSAGE_LEN))
			else
				if(I.removed_type)
					var/obj/item/organ/O = new I.removed_type()
					organ_slot = O.organ_tag
					qdel(O)
				else
					organ_slot = "unknown organ"

			if(H.internal_organs_by_name[organ_slot])
				to_chat(usr, "[H] already has an organ in that slot.")
				qdel(I)
				return

			H.internal_organs_by_name[organ_slot] = I
			to_chat(usr, "Added new [new_organ] to [H] as slot [organ_slot].")
		else
			new new_organ(M)
			to_chat(usr, "Added new [new_organ] to [M].")

	else if(href_list["remorgan"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/M = locate(href_list["remorgan"])
		if(!istype(M))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon")
			return

		var/rem_organ = input("Please choose an organ to remove.","Organ",null) as null|anything in M.internal_organs

		if(!M)
			to_chat(usr, "Mob doesn't exist anymore")
			return

		if(!(locate(rem_organ) in M.internal_organs))
			to_chat(usr, "Mob does not have that organ.")
			return

		to_chat(usr, "Removed [rem_organ] from [M].")
		qdel(rem_organ)


	else if(href_list["addlimb"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/M = locate(href_list["addlimb"])
		if(!istype(M))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
			return

		var/new_limb = input("Please choose an organ to add.","Organ",null) as null|anything in subtypesof(/datum/limb)

		if(!M)
			to_chat(usr, "Mob doesn't exist anymore")
			return

		var/datum/limb/EO = locate(new_limb) in M.limbs
		if(!EO)
			return
		if(!(EO.status & LIMB_DESTROYED))
			to_chat(usr, "Mob already has that organ.")
			return

		EO.status = NOFLAGS
		EO.perma_injury = 0
		EO.germ_level = 0
		EO.reset_limb_surgeries()
		M.update_body(0)
		M.updatehealth()
		M.UpdateDamageIcon()

	else if(href_list["remlimb"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/M = locate(href_list["remlimb"])
		if(!istype(M))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
			return

		var/rem_limb = input("Please choose a limb to remove.","Organ",null) as null|anything in M.limbs

		if(!M)
			to_chat(usr, "Mob doesn't exist anymore")
			return

		var/datum/limb/EO = locate(rem_limb) in M.limbs
		if(!EO)
			return
		if(EO.status & LIMB_DESTROYED)
			to_chat(usr, "Mob doesn't have that limb.")
			return
		EO.droplimb(1)


	else if(href_list["fix_nano"])
		if(!check_rights(R_DEBUG)) return

		var/mob/H = locate(href_list["fix_nano"])

		if(!istype(H) || !H.client)
			to_chat(usr, "This can only be done on mobs with clients")
			return

		nanomanager.send_resources(H.client)

		to_chat(usr, "Resource files sent")
		to_chat(H, "Your NanoUI Resource files have been refreshed")

		log_admin("[key_name(usr)] resent the NanoUI resource files to [key_name(H)] ")

	else if(href_list["regenerateicons"])
		if(!check_rights(0))	return

		var/mob/M = locate(href_list["regenerateicons"])
		if(!ismob(M))
			to_chat(usr, "This can only be done to instances of type /mob")
			return
		M.regenerate_icons()

	else if(href_list["adjustDamage"] && href_list["mobToDamage"])
		if(!check_rights(R_DEBUG|R_ADMIN|R_FUN))	return

		var/mob/living/L = locate(href_list["mobToDamage"])
		if(!istype(L)) return

		var/Text = href_list["adjustDamage"]

		var/amount =  input("Deal how much damage to mob? (Negative values here heal)","Adjust [Text]loss",0) as num

		if(!L)
			to_chat(usr, "Mob doesn't exist anymore")
			return

		switch(Text)
			if("brute")	L.adjustBruteLoss(amount)
			if("fire")	L.adjustFireLoss(amount)
			if("toxin")	L.adjustToxLoss(amount)
			if("oxygen")L.adjustOxyLoss(amount)
			if("brain")	L.adjustBrainLoss(amount)
			if("clone")	L.adjustCloneLoss(amount)
			else
				to_chat(usr, "You caused an error. DEBUG: Text:[Text] Mob:[L]")
				return
		L.updatehealth()

		if(amount != 0)
			log_admin("[key_name(usr)] dealt [amount] amount of [Text] damage to [L] ")
			message_admins("<span class='notice'> [key_name(usr)] dealt [amount] amount of [Text] damage to [L] </span>")
			href_list["datumrefresh"] = href_list["mobToDamage"]

	if(href_list["datumrefresh"])
		var/datum/DAT = locate(href_list["datumrefresh"])
		if(!istype(DAT, /datum))
			return
		src.debug_variables(DAT)

	return

/datum/proc/CanProcCall(procname)
	return TRUE

/datum/proc/can_vv_get(var_name)
	return TRUE


/datum/verb/find_refs()
	set category = "Debug"
	set name = "Find References"
	set src in world

	find_references(FALSE)


/datum/verb/qdel_then_find_references()
	set category = "Debug"
	set name = "qdel() then Find References"
	set src in world

	qdel(src, TRUE)		//Force.
	if(!running_find_references)
		find_references(TRUE)

/datum/verb/qdel_then_if_fail_find_references()
	set category = "Debug"
	set name = "qdel() then Find References if GC failure"
	set src in world

	qdel_and_find_ref_if_fail(src, TRUE)

// Debug verbs.
/client/proc/restart_controller(controller in list("Master", "Failsafe"))
	set category = "Debug"
	set name = "Restart Controller"
	set desc = "Restart one of the various periodic loop controllers for the game (be careful!)"

	if(!holder)
		return
	switch(controller)
		if("Master")
			Recreate_MC()
//			SSblackbox.record_feedback("tally", "admin_verb", 1, "Restart Master Controller")
		if("Failsafe")
			new /datum/controller/failsafe()
//			SSblackbox.record_feedback("tally", "admin_verb", 1, "Restart Failsafe Controller")

	message_admins("Admin [key_name_admin(usr)] has restarted the [controller] controller.")

/client/proc/debug_controller(controller in list("Master","Ticker","Lighting","Air","Jobs","Sun","Radio","Supply","Shuttles","Configuration","Cameras", "Transfer Controller", "Gas Data"))
	set category = "Debug"
	set name = "Debug Controllers"
	set desc = "Debug the various periodic loop controllers for the game (be careful!)"

	if(!holder)	return
	switch(controller)
		if("Master")
			debug_variables(Master)
			feedback_add_details("admin_verb","DMaster")
		if("Ticker")
			debug_variables(ticker)
			feedback_add_details("admin_verb","DTicker")
		if("Lighting")
			debug_variables(lighting_controller)
			feedback_add_details("admin_verb","DLighting")
//		if("Air")
//			debug_variables(air_master)
//			feedback_add_details("admin_verb","DAir")
		if("Jobs")
			debug_variables(RoleAuthority)
			feedback_add_details("admin_verb","DJobs")
		if("Sun")
			debug_variables(sun)
			feedback_add_details("admin_verb","DSun")
		if("Radio")
			debug_variables(radio_controller)
			feedback_add_details("admin_verb","DRadio")
		if("Supply")
			debug_variables(supply_controller)
			feedback_add_details("admin_verb","DSupply")
		if("Shuttles")
			debug_variables(shuttle_controller)
			feedback_add_details("admin_verb","DShuttles")
		if("Configuration")
			debug_variables(config)
			feedback_add_details("admin_verb","DConf")
		if("Cameras")
			debug_variables(cameranet)
			feedback_add_details("admin_verb","DCameras")

	message_admins("Admin [key_name_admin(usr)] is debugging the [controller] controller.")
	return

/client/proc/atmos_toggle_debug(var/obj/machinery/atmospherics/M in view())
	set name = "Toggle Debug Messages"
	set category = "Debug"
	M.debug = !M.debug
	to_chat(usr, "[M]: Debug messages toggled [M.debug? "on" : "off"].")


/client/proc/cmd_mass_modify_object_variables(atom/A, var/var_name)
	set category = "Debug"
	set name = "Mass Edit Variables"
	set desc="(target) Edit all instances of a target item's variables"

	var/method = 0	//0 means strict type detection while 1 means this type and all subtypes (IE: /obj/item with this set to 1 will set it to ALL itms)

	if(!check_rights(R_VAREDIT))	return

	if(A && A.type)
		if(typesof(A.type))
			switch(input("Strict object type detection?") as null|anything in list("Strictly this type","This type and subtypes", "Cancel"))
				if("Strictly this type")
					method = 0
				if("This type and subtypes")
					method = 1
				if("Cancel")
					return
				if(null)
					return

	src.massmodify_variables(A, var_name, method)
	feedback_add_details("admin_verb","MEV") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/massmodify_variables(var/atom/O, var/var_name = "", var/method = 0)
	if(!check_rights(R_VAREDIT))	return

	var/list/locked = list("vars", "key", "ckey", "client")

	for(var/p in forbidden_varedit_object_types)
		if( istype(O,p) )
			to_chat(usr, "<span class='warning'>It is forbidden to edit this object's variables.</span>")
			return

	var/list/names = list()
	for (var/V in O.vars)
		names += V

	names = sortList(names)

	var/variable = ""

	if(!var_name)
		variable = input("Which var?","Var") as null|anything in names
	else
		variable = var_name

	if(!variable)	return
	var/default
	var/var_value = O.vars[variable]
	var/dir

	if(variable == "holder" || (variable in locked))
		if(!check_rights(R_DEBUG))	return

	if(isnull(var_value))
		to_chat(usr, "Unable to determine variable type.")

	else if(isnum(var_value))
		to_chat(usr, "Variable appears to be <b>NUM</b>.")
		default = "num"
		dir = 1

	else if(istext(var_value))
		to_chat(usr, "Variable appears to be <b>TEXT</b>.")
		default = "text"

	else if(isloc(var_value))
		to_chat(usr, "Variable appears to be <b>REFERENCE</b>.")
		default = "reference"

	else if(isicon(var_value))
		to_chat(usr, "Variable appears to be <b>ICON</b>.")
		var_value = "\icon[var_value]"
		default = "icon"

	else if(istype(var_value,/atom) || istype(var_value,/datum))
		to_chat(usr, "Variable appears to be <b>TYPE</b>.")
		default = "type"

	else if(istype(var_value,/list))
		to_chat(usr, "Variable appears to be <b>LIST</b>.")
		default = "list"

	else if(istype(var_value,/client))
		to_chat(usr, "Variable appears to be <b>CLIENT</b>.")
		default = "cancel"

	else
		to_chat(usr, "Variable appears to be <b>FILE</b>.")
		default = "file"

	to_chat(usr, "Variable contains: [var_value]")
	if(dir)
		switch(var_value)
			if(1)
				dir = "NORTH"
			if(2)
				dir = "SOUTH"
			if(4)
				dir = "EAST"
			if(8)
				dir = "WEST"
			if(5)
				dir = "NORTHEAST"
			if(6)
				dir = "SOUTHEAST"
			if(9)
				dir = "NORTHWEST"
			if(10)
				dir = "SOUTHWEST"
			else
				dir = null
		if(dir)
			to_chat(usr, "If a direction, direction is: [dir]")

	var/class = input("What kind of variable?","Variable Type",default) as null|anything in list("text",
		"num","type","icon","file","edit referenced object","restore to default")

	if(!class)
		return

	var/original_name

	if (!istype(O, /atom))
		original_name = "\ref[O] ([O])"
	else
		original_name = O:name

	switch(class)

		if("restore to default")
			O.vars[variable] = initial(O.vars[variable])
			if(method)
				if(istype(O, /mob))
					for(var/mob/M in mob_list)
						if ( istype(M , O.type) )
							M.vars[variable] = O.vars[variable]

				else if(istype(O, /obj))
					for(var/obj/A in object_list)
						if ( istype(A , O.type) )
							A.vars[variable] = O.vars[variable]

				else if(istype(O, /turf))
					for(var/turf/A in turfs)
						if ( istype(A , O.type) )
							A.vars[variable] = O.vars[variable]

			else
				if(istype(O, /mob))
					for(var/mob/M in mob_list)
						if (M.type == O.type)
							M.vars[variable] = O.vars[variable]

				else if(istype(O, /obj))
					for(var/obj/A in object_list)
						if (A.type == O.type)
							A.vars[variable] = O.vars[variable]

				else if(istype(O, /turf))
					for(var/turf/A in turfs)
						if (A.type == O.type)
							A.vars[variable] = O.vars[variable]

		if("edit referenced object")
			return .(O.vars[variable])

		if("text")
			var/new_value = input("Enter new text:","Text",O.vars[variable]) as text|null
			if(new_value == null) return
			O.vars[variable] = new_value

			if(method)
				if(istype(O, /mob))
					for(var/mob/M in mob_list)
						if ( istype(M , O.type) )
							M.vars[variable] = O.vars[variable]

				else if(istype(O, /obj))
					for(var/obj/A in object_list)
						if ( istype(A , O.type) )
							A.vars[variable] = O.vars[variable]

				else if(istype(O, /turf))
					for(var/turf/A in turfs)
						if ( istype(A , O.type) )
							A.vars[variable] = O.vars[variable]
			else
				if(istype(O, /mob))
					for(var/mob/M in mob_list)
						if (M.type == O.type)
							M.vars[variable] = O.vars[variable]

				else if(istype(O, /obj))
					for(var/obj/A in object_list)
						if (A.type == O.type)
							A.vars[variable] = O.vars[variable]

				else if(istype(O, /turf))
					for(var/turf/A in turfs)
						if (A.type == O.type)
							A.vars[variable] = O.vars[variable]

		if("num")
			var/new_value = input("Enter new number:","Num",\
					O.vars[variable]) as num|null
			if(new_value == null) return

			if(variable=="luminosity")
				O.SetLuminosity(new_value)
			else
				O.vars[variable] = new_value

			if(method)
				if(istype(O, /mob))
					for(var/mob/M in mob_list)
						if ( istype(M , O.type) )
							if(variable=="luminosity")
								M.SetLuminosity(new_value)
							else
								M.vars[variable] = O.vars[variable]

				else if(istype(O, /obj))
					for(var/obj/A in object_list)
						if ( istype(A , O.type) )
							if(variable=="luminosity")
								A.SetLuminosity(new_value)
							else
								A.vars[variable] = O.vars[variable]

				else if(istype(O, /turf))
					for(var/turf/A in turfs)
						if ( istype(A , O.type) )
							if(variable=="luminosity")
								A.SetLuminosity(new_value)
							else
								A.vars[variable] = O.vars[variable]

			else
				if(istype(O, /mob))
					for(var/mob/M in mob_list)
						if (M.type == O.type)
							if(variable=="luminosity")
								M.SetLuminosity(new_value)
							else
								M.vars[variable] = O.vars[variable]

				else if(istype(O, /obj))
					for(var/obj/A in object_list)
						if (A.type == O.type)
							if(variable=="luminosity")
								A.SetLuminosity(new_value)
							else
								A.vars[variable] = O.vars[variable]

				else if(istype(O, /turf))
					for(var/turf/A in turfs)
						if (A.type == O.type)
							if(variable=="luminosity")
								A.SetLuminosity(new_value)
							else
								A.vars[variable] = O.vars[variable]

		if("type")
			var/new_value
			new_value = input("Enter type:","Type",O.vars[variable]) as null|anything in typesof(/obj,/mob,/area,/turf)
			if(new_value == null) return
			O.vars[variable] = new_value
			if(method)
				if(istype(O, /mob))
					for(var/mob/M in mob_list)
						if ( istype(M , O.type) )
							M.vars[variable] = O.vars[variable]

				else if(istype(O, /obj))
					for(var/obj/A in object_list)
						if ( istype(A , O.type) )
							A.vars[variable] = O.vars[variable]

				else if(istype(O, /turf))
					for(var/turf/A in turfs)
						if ( istype(A , O.type) )
							A.vars[variable] = O.vars[variable]
			else
				if(istype(O, /mob))
					for(var/mob/M in mob_list)
						if (M.type == O.type)
							M.vars[variable] = O.vars[variable]

				else if(istype(O, /obj))
					for(var/obj/A in object_list)
						if (A.type == O.type)
							A.vars[variable] = O.vars[variable]

				else if(istype(O, /turf))
					for(var/turf/A in turfs)
						if (A.type == O.type)
							A.vars[variable] = O.vars[variable]

		if("file")
			var/new_value = input("Pick file:","File",O.vars[variable]) as null|file
			if(new_value == null) return
			O.vars[variable] = new_value

			if(method)
				if(istype(O, /mob))
					for(var/mob/M in mob_list)
						if ( istype(M , O.type) )
							M.vars[variable] = O.vars[variable]

				else if(istype(O.type, /obj))
					for(var/obj/A in object_list)
						if ( istype(A , O.type) )
							A.vars[variable] = O.vars[variable]

				else if(istype(O.type, /turf))
					for(var/turf/A in turfs)
						if ( istype(A , O.type) )
							A.vars[variable] = O.vars[variable]
			else
				if(istype(O, /mob))
					for(var/mob/M in mob_list)
						if (M.type == O.type)
							M.vars[variable] = O.vars[variable]

				else if(istype(O.type, /obj))
					for(var/obj/A in object_list)
						if (A.type == O.type)
							A.vars[variable] = O.vars[variable]

				else if(istype(O.type, /turf))
					for(var/turf/A in turfs)
						if (A.type == O.type)
							A.vars[variable] = O.vars[variable]

		if("icon")
			var/new_value = input("Pick icon:","Icon",O.vars[variable]) as null|icon
			if(new_value == null) return
			O.vars[variable] = new_value
			if(method)
				if(istype(O, /mob))
					for(var/mob/M in mob_list)
						if ( istype(M , O.type) )
							M.vars[variable] = O.vars[variable]

				else if(istype(O, /obj))
					for(var/obj/A in object_list)
						if ( istype(A , O.type) )
							A.vars[variable] = O.vars[variable]

				else if(istype(O, /turf))
					for(var/turf/A in turfs)
						if ( istype(A , O.type) )
							A.vars[variable] = O.vars[variable]

			else
				if(istype(O, /mob))
					for(var/mob/M in mob_list)
						if (M.type == O.type)
							M.vars[variable] = O.vars[variable]

				else if(istype(O, /obj))
					for(var/obj/A in object_list)
						if (A.type == O.type)
							A.vars[variable] = O.vars[variable]

				else if(istype(O, /turf))
					for(var/turf/A in turfs)
						if (A.type == O.type)
							A.vars[variable] = O.vars[variable]

	log_admin("[key_name(src)] mass modified [original_name]'s [variable] to [O.vars[variable]]")
	message_admins("[key_name_admin(src)] mass modified [original_name]'s [variable] to [O.vars[variable]]", 1)


var/list/forbidden_varedit_object_types = list(
										/datum/admins,						//Admins editing their own admin-power object? Yup, sounds like a good idea.
										/obj/machinery/blackbox_recorder,	//Prevents people messing with feedback gathering
										/datum/feedback_variable			//Prevents people messing with feedback gathering
									)

/*
/client/proc/cmd_modify_object_variables(obj/O as obj|mob|turf|area in world)
	set category = "Debug"
	set name = "Edit Variables"
	set desc="(target) Edit a target item's variables"
	src.modify_variables(O)
	feedback_add_details("admin_verb","EDITV") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
*/

/client/proc/cmd_modify_ticker_variables()
	set category = "Debug"
	set name = "Edit Ticker Variables"

	if (ticker == null)
		to_chat(src, "Game hasn't started yet.")
	else
		src.modify_variables(ticker)
		feedback_add_details("admin_verb","ETV") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/mod_list_add_ass() //haha

	var/class = "text"
	if(src.holder && src.holder.marked_datum)
		class = input("What kind of variable?","Variable Type") as null|anything in list("text",
			"num","type","reference","mob reference", "icon","file","list","edit referenced object","restore to default","marked datum ([holder.marked_datum.type])")
	else
		class = input("What kind of variable?","Variable Type") as null|anything in list("text",
			"num","type","reference","mob reference", "icon","file","list","edit referenced object","restore to default")

	if(!class)
		return

	if(holder.marked_datum && class == "marked datum ([holder.marked_datum.type])")
		class = "marked datum"

	var/var_value = null

	switch(class)

		if("text")
			var_value = input("Enter new text:","Text") as null|text

		if("num")
			var_value = input("Enter new number:","Num") as null|num

		if("type")
			var_value = input("Enter type:","Type") as null|anything in typesof(/obj,/mob,/area,/turf)

		if("reference")
			var_value = input("Select reference:","Reference") as null|mob|obj|turf|area in world

		if("mob reference")
			var_value = input("Select reference:","Reference") as null|mob in mob_list

		if("file")
			var_value = input("Pick file:","File") as null|file

		if("icon")
			var_value = input("Pick icon:","Icon") as null|icon

		if("marked datum")
			var_value = holder.marked_datum

	if(!var_value) return

	return var_value


/client/proc/mod_list_add(var/list/L)

	var/class = "text"
	if(src.holder && src.holder.marked_datum)
		class = input("What kind of variable?","Variable Type") as null|anything in list("text",
			"num","type","reference","mob reference", "icon","file","list","edit referenced object","restore to default","marked datum ([holder.marked_datum.type])")
	else
		class = input("What kind of variable?","Variable Type") as null|anything in list("text",
			"num","type","reference","mob reference", "icon","file","list","edit referenced object","restore to default")

	if(!class)
		return

	if(holder.marked_datum && class == "marked datum ([holder.marked_datum.type])")
		class = "marked datum"

	var/var_value = null

	switch(class)

		if("text")
			var_value = input("Enter new text:","Text") as text

		if("num")
			var_value = input("Enter new number:","Num") as num

		if("type")
			var_value = input("Enter type:","Type") in typesof(/obj,/mob,/area,/turf)

		if("reference")
			var_value = input("Select reference:","Reference") as mob|obj|turf|area in world

		if("mob reference")
			var_value = input("Select reference:","Reference") as mob in mob_list

		if("file")
			var_value = input("Pick file:","File") as file

		if("icon")
			var_value = input("Pick icon:","Icon") as icon

		if("marked datum")
			var_value = holder.marked_datum

	if(!var_value) return

	switch(alert("Would you like to associate a var with the list entry?",,"Yes","No"))
		if("Yes")
			L += var_value
			L[var_value] = mod_list_add_ass() //haha
		if("No")
			L += var_value

/client/proc/mod_list(var/list/L)
	if(!check_rights(R_VAREDIT))	return

	if(!istype(L,/list)) to_chat(src, "Not a List.")

	var/list/locked = list("vars", "key", "ckey", "client", "firemut", "ishulk", "telekinesis", "xray", "virus", "viruses", "cuffed", "ka", "last_eaten", "urine", "poo", "icon", "icon_state")
	var/list/names = sortList(L)

	var/variable = input("Which var?","Var") as null|anything in names + "(ADD VAR)"

	if(variable == "(ADD VAR)")
		mod_list_add(L)
		return

	if(!variable)
		return

	var/default

	var/dir

	if(variable in locked)
		if(!check_rights(R_DEBUG))	return

	if(isnull(variable))
		to_chat(usr, "Unable to determine variable type.")

	else if(isnum(variable))
		to_chat(usr, "Variable appears to be <b>NUM</b>.")
		default = "num"
		dir = 1

	else if(istext(variable))
		to_chat(usr, "Variable appears to be <b>TEXT</b>.")
		default = "text"

	else if(isloc(variable))
		to_chat(usr, "Variable appears to be <b>REFERENCE</b>.")
		default = "reference"

	else if(isicon(variable))
		to_chat(usr, "Variable appears to be <b>ICON</b>.")
		variable = "\icon[variable]"
		default = "icon"

	else if(istype(variable,/atom) || istype(variable,/datum))
		to_chat(usr, "Variable appears to be <b>TYPE</b>.")
		default = "type"

	else if(istype(variable,/list))
		to_chat(usr, "Variable appears to be <b>LIST</b>.")
		default = "list"

	else if(istype(variable,/client))
		to_chat(usr, "Variable appears to be <b>CLIENT</b>.")
		default = "cancel"

	else
		to_chat(usr, "Variable appears to be <b>FILE</b>.")
		default = "file"

	to_chat(usr, "Variable contains: [variable]")
	if(dir)
		switch(variable)
			if(1)
				dir = "NORTH"
			if(2)
				dir = "SOUTH"
			if(4)
				dir = "EAST"
			if(8)
				dir = "WEST"
			if(5)
				dir = "NORTHEAST"
			if(6)
				dir = "SOUTHEAST"
			if(9)
				dir = "NORTHWEST"
			if(10)
				dir = "SOUTHWEST"
			else
				dir = null

		if(dir)
			to_chat(usr, "If a direction, direction is: [dir]")

	var/class = "text"
	var/list/choices = list("text","num","type","reference","mob reference", "icon","file","list","edit referenced object","restore to default")
	if(src.holder && src.holder.marked_datum)
		choices += "marked datum ([holder.marked_datum.type])"
	if(!isnull(default) && default != "num")
		choices += "edit associated variable"
	choices += "DELETE FROM LIST"

	class = input("What kind of variable?","Variable Type",default) as null|anything in choices

	if(!class)
		return

	if(holder.marked_datum && class == "marked datum ([holder.marked_datum.type])")
		class = "marked datum"

	switch(class) //Spits a runtime error if you try to modify an entry in the contents list. Dunno how to fix it, yet.

		if("list")
			mod_list(variable)

		if("restore to default")
			L[L.Find(variable)]=initial(variable)

		if("edit referenced object")
			modify_variables(variable)

		if("DELETE FROM LIST")
			L -= variable
			return

		if("text")
			L[L.Find(variable)] = input("Enter new text:","Text") as text

		if("num")
			L[L.Find(variable)] = input("Enter new number:","Num") as num

		if("type")
			L[L.Find(variable)] = input("Enter type:","Type") in typesof(/obj,/mob,/area,/turf)

		if("reference")
			L[L.Find(variable)] = input("Select reference:","Reference") as mob|obj|turf|area in world

		if("mob reference")
			L[L.Find(variable)] = input("Select reference:","Reference") as mob in mob_list

		if("file")
			L[L.Find(variable)] = input("Pick file:","File") as file

		if("icon")
			L[L.Find(variable)] = input("Pick icon:","Icon") as icon

		if("marked datum")
			L[L.Find(variable)] = holder.marked_datum

		if("edit associated variable")
			var/temp_var = mod_list_add_ass()
			if(temp_var)
				L[variable] = temp_var


/client/proc/modify_variables(var/atom/O, var/param_var_name = null, var/autodetect_class = 0)
	if(!check_rights(R_VAREDIT))	return

	var/list/locked = list("vars", "key", "ckey", "client", "firemut", "ishulk", "telekinesis", "xray", "virus", "cuffed", "ka", "last_eaten", "icon", "icon_state", "mutantrace")

	for(var/p in forbidden_varedit_object_types)
		if( istype(O,p) )
			to_chat(usr, "<span class='warning'>It is forbidden to edit this object's variables.</span>")
			return

	var/class
	var/variable
	var/var_value

	if(param_var_name)
		if(!param_var_name in O.vars)
			to_chat(src, "A variable with this name ([param_var_name]) doesn't exist in this atom ([O])")
			return

		if(param_var_name == "holder" || (param_var_name in locked))
			if(!check_rights(R_DEBUG))	return

		variable = param_var_name

		var_value = O.vars[variable]

		if(autodetect_class)
			if(isnull(var_value))
				to_chat(usr, "Unable to determine variable type.")
				class = null
				autodetect_class = null
			else if(isnum(var_value))
				to_chat(usr, "Variable appears to be <b>NUM</b>.")
				class = "num"
				dir = 1

			else if(istext(var_value))
				to_chat(usr, "Variable appears to be <b>TEXT</b>.")
				class = "text"

			else if(isloc(var_value))
				to_chat(usr, "Variable appears to be <b>REFERENCE</b>.")
				class = "reference"

			else if(isicon(var_value))
				to_chat(usr, "Variable appears to be <b>ICON</b>.")
				var_value = "\icon[var_value]"
				class = "icon"

			else if(istype(var_value,/atom) || istype(var_value,/datum))
				to_chat(usr, "Variable appears to be <b>TYPE</b>.")
				class = "type"

			else if(istype(var_value,/list))
				to_chat(usr, "Variable appears to be <b>LIST</b>.")
				class = "list"

			else if(istype(var_value,/client))
				to_chat(usr, "Variable appears to be <b>CLIENT</b>.")
				class = "cancel"

			else
				to_chat(usr, "Variable appears to be <b>FILE</b>.")
				class = "file"

	else

		var/list/names = list()
		for (var/V in O.vars)
			names += V

		names = sortList(names)

		variable = input("Which var?","Var") as null|anything in names
		if(!variable)	return
		var_value = O.vars[variable]

		if(variable == "holder" || (variable in locked))
			if(!check_rights(R_DEBUG))	return

	if(!autodetect_class)

		var/dir
		var/default
		if(isnull(var_value))
			to_chat(usr, "Unable to determine variable type.")

		else if(isnum(var_value))
			to_chat(usr, "Variable appears to be <b>NUM</b>.")
			default = "num"
			dir = 1

		else if(istext(var_value))
			to_chat(usr, "Variable appears to be <b>TEXT</b>.")
			default = "text"

		else if(isloc(var_value))
			to_chat(usr, "Variable appears to be <b>REFERENCE</b>.")
			default = "reference"

		else if(isicon(var_value))
			to_chat(usr, "Variable appears to be <b>ICON</b>.")
			var_value = "\icon[var_value]"
			default = "icon"

		else if(istype(var_value,/atom) || istype(var_value,/datum))
			to_chat(usr, "Variable appears to be <b>TYPE</b>.")
			default = "type"

		else if(istype(var_value,/list))
			to_chat(usr, "Variable appears to be <b>LIST</b>.")
			default = "list"

		else if(istype(var_value,/client))
			to_chat(usr, "Variable appears to be <b>CLIENT</b>.")
			default = "cancel"

		else
			to_chat(usr, "Variable appears to be <b>FILE</b>.")
			default = "file"

		to_chat(usr, "Variable contains: [var_value]")
		if(dir)
			switch(var_value)
				if(1)
					dir = "NORTH"
				if(2)
					dir = "SOUTH"
				if(4)
					dir = "EAST"
				if(8)
					dir = "WEST"
				if(5)
					dir = "NORTHEAST"
				if(6)
					dir = "SOUTHEAST"
				if(9)
					dir = "NORTHWEST"
				if(10)
					dir = "SOUTHWEST"
				else
					dir = null
			if(dir)
				to_chat(usr, "If a direction, direction is: [dir]")

		if(src.holder && src.holder.marked_datum)
			class = input("What kind of variable?","Variable Type",default) as null|anything in list("text",
				"num","type","reference","mob reference", "icon","file","list","edit referenced object","restore to default","marked datum ([holder.marked_datum.type])")
		else
			class = input("What kind of variable?","Variable Type",default) as null|anything in list("text",
				"num","type","reference","mob reference", "icon","file","list","edit referenced object","restore to default")

		if(!class)
			return

	var/original_name

	if (!istype(O, /atom))
		original_name = "\ref[O] ([O])"
	else
		original_name = O:name

	if(holder.marked_datum && class == "marked datum ([holder.marked_datum.type])")
		class = "marked datum"

	switch(class)

		if("list")
			mod_list(O.vars[variable])
			return

		if("restore to default")
			O.vars[variable] = initial(O.vars[variable])

		if("edit referenced object")
			return .(O.vars[variable])

		if("text")
			var/var_new = input("Enter new text:","Text",O.vars[variable]) as null|text
			if(var_new==null) return
			O.vars[variable] = var_new

		if("num")
			if(variable=="luminosity")
				var/var_new = input("Enter new number:","Num",O.vars[variable]) as null|num
				if(var_new == null) return
				O.SetLuminosity(var_new)
			else if(variable=="stat")
				var/var_new = input("Enter new number:","Num",O.vars[variable]) as null|num
				if(var_new == null) return
				if((O.vars[variable] == 2) && (var_new < 2))//Bringing the dead back to life
					dead_mob_list -= O
					living_mob_list += O
				if((O.vars[variable] < 2) && (var_new == 2))//Kill he
					living_mob_list -= O
					dead_mob_list += O
				O.vars[variable] = var_new
			else
				var/var_new =  input("Enter new number:","Num",O.vars[variable]) as null|num
				if(var_new==null) return
				O.vars[variable] = var_new

		if("type")
			var/var_new = input("Enter type:","Type",O.vars[variable]) as null|anything in typesof(/obj,/mob,/area,/turf)
			if(var_new==null) return
			O.vars[variable] = var_new

		if("reference")
			var/var_new = input("Select reference:","Reference",O.vars[variable]) as null|mob|obj|turf|area in world
			if(var_new==null) return
			O.vars[variable] = var_new

		if("mob reference")
			var/var_new = input("Select reference:","Reference",O.vars[variable]) as null|mob in mob_list
			if(var_new==null) return
			O.vars[variable] = var_new

		if("file")
			var/var_new = input("Pick file:","File",O.vars[variable]) as null|file
			if(var_new==null) return
			O.vars[variable] = var_new

		if("icon")
			var/var_new = input("Pick icon:","Icon",O.vars[variable]) as null|icon
			if(var_new==null) return
			O.vars[variable] = var_new

		if("marked datum")
			O.vars[variable] = holder.marked_datum

	log_world("### VarEdit by [key_name(src)]: [O.type] '[variable]': [var_value] => [html_encode("[O.vars[variable]]")]")
	log_admin("[key_name(src)] modified [original_name]'s '[variable]': [html_encode("[var_value]")] => [O.vars[variable]]")
	message_admins("[key_name_admin(src)] modified [original_name]'s '[variable]': [var_value] => [O.vars[variable]]", 1)
