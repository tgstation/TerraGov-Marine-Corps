GLOBAL_VAR(AdminProcCaller)
GLOBAL_PROTECT(AdminProcCaller)
GLOBAL_VAR_INIT(AdminProcCallCount, FALSE)
GLOBAL_PROTECT(AdminProcCallCount)
GLOBAL_VAR(LastAdminCalledTargetRef)
GLOBAL_PROTECT(LastAdminCalledTargetRef)
GLOBAL_VAR(LastAdminCalledTarget)
GLOBAL_PROTECT(LastAdminCalledTarget)
GLOBAL_VAR(LastAdminCalledProc)
GLOBAL_PROTECT(LastAdminCalledProc)
GLOBAL_LIST_EMPTY(AdminProcCallSpamPrevention)
GLOBAL_PROTECT(AdminProcCallSpamPrevention)


/datum/admins/proc/proccall_advanced()
	set category = "Debug"
	set name = "Advanced ProcCall"
	set waitfor = 0

	if(!check_rights(R_DEBUG))
		return

	var/target = null
	var/targetselected = FALSE
	var/lst[] // List reference
	lst = new/list() // Make the list
	var/returnval = null
	var/class = null

	switch(alert("Proc owned by something?",,"Yes","No"))
		if("Yes")
			targetselected = TRUE
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
	if(!procname)
		return

	var/argnum = input("Number of arguments", "Number:", 0) as num|null
	if(!argnum && (argnum != 0))
		return

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
				lst[i] = input("Enter type:","Type") in typesof(/obj, /mob, /area, /turf)

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


/datum/admins/proc/proccall_atom(atom/A)
	set category = "Debug"
	set name = "Atom ProcCall"
	set waitfor = 0

	if(!check_rights(R_DEBUG))
		return

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


/datum/admins/proc/change_hivenumber(mob/living/carbon/Xenomorph/X in mob_list)
	set category = "Debug"
	set name = "Change Hivenumber"
	set desc = "Set the hivenumber of a xenomorph."

	if(!check_rights(R_DEBUG))
		return

	if(!X || !istype(X))
		return

	var/hivenumber_status = X.hivenumber

	var/list/namelist = list()
	for(var/datum/hive_status/H in hive_datum)
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

	if(!X || !istype(X) || X.gc_destroyed || !ticker || X.hivenumber != hivenumber_status)
		return

	X.set_hive_number(newhivenumber)
	log_admin("[key_name(src)] changed hivenumber of [X] to [newhive].")
	message_admins("[key_name(src)] changed hivenumber of [X] to [newhive].")


/datum/admins/proc/delete_all()
	set category = "Debug"
	set name = "Delete Instance"

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
					var/do_delete = TRUE
					if(hsbitem in blocked)
						if(alert("Are you REALLY sure you wish to delete all instances of [hsbitem]? This will lead to catastrophic results!",,"Yes","No") != "Yes")
							do_delete = FALSE
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


/datum/admins/proc/generate_powernets()
	set category = "Debug"
	set name = "Generate Powernets"
	set desc = "Regenerate all powernets."

	if(!check_rights(R_DEBUG))
		return

	makepowernets()

	log_admin("[key_name(src)] has remade the powernets.")
	message_admins("[key_name_admin(src)] has remade the powernets.")


/datum/admins/proc/debug_mob_lists()
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


/datum/admins/proc/dna_toggle_block(var/mob/M,var/block)
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
	set name = "Spawn"
	set category = "Debug"
	set desc = "Spawn an atom."

	if(!check_rights(R_SPAWN))
		return

	var/list/types = typesof(/atom)
	var/list/matches = new()

	for(var/path in types)
		if(findtext("[path]", object))
			matches += path

	if(length(matches) == 0)
		return

	var/chosen
	if(length(matches) == 1)
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

	log_admin("[key_name(usr)] spawned [chosen] at ([usr.x],[usr.y],[usr.z]) ([get_area(usr)]).")
	message_admins("[key_name_admin(usr)] spawned [chosen] at ([usr.x],[usr.y],[usr.z]) ([get_area(usr)]).")


/datum/admins/proc/delete_atom(atom/O as obj|mob|turf in world)
	set category = "Debug"
	set name = "Delete"
	set desc = "Delete an atom."

	if(!check_rights(R_DEBUG))
		return

	if(alert(src, "Are you sure you want to delete: [O]?",, "Yes", "No") == "No")
		return

	qdel(O)

	log_admin("[key_name(usr)] deleted [O] at ([O.x],[O.y],[O.z]) ([get_area(src)]).")
	message_admins("[key_name_admin(usr)] deleted [O] at ([O.x],[O.y],[O.z]) ([get_area(src)]).")


/datum/admins/proc/fix_next_move()
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


/datum/admins/proc/restart_controller(controller in list("Master", "Failsafe"))
	set category = "Debug"
	set name = "Restart Controller"
	set desc = "Restart one of the various periodic loop controllers for the game (be careful!)"

	if(!check_rights(R_DEBUG))
		return

	switch(controller)
		if("Master")
			Recreate_MC()
		if("Failsafe")
			new /datum/controller/failsafe()

	log_admin("[key_name(usr)] has restarted the [controller] controller.")
	message_admins("[key_name_admin(usr)] has restarted the [controller] controller.")


/datum/admins/proc/debug_controller(controller in list("Master","Ticker","Lighting","Jobs","Sun","Radio","Supply","Shuttles","Configuration","Cameras", "Transfer Controller", "Gas Data"))
	set category = "Debug"
	set name = "Debug Controllers"
	set desc = "Debug the various periodic loop controllers for the game."

	if(!check_rights(R_DEBUG))
		return

	switch(controller)
		if("Master")
			debug_variables(Master)
		if("Ticker")
			debug_variables(ticker)
		if("Lighting")
			debug_variables(lighting_controller)
		if("Jobs")
			debug_variables(RoleAuthority)
		if("Sun")
			debug_variables(sun)
		if("Radio")
			debug_variables(radio_controller)
		if("Supply")
			debug_variables(supply_controller)
		if("Shuttles")
			debug_variables(shuttle_controller)
		if("Configuration")
			debug_variables(config)
		if("Cameras")
			debug_variables(cameranet)

	log_admin("[key_name(usr)] is debugging the [controller] controller.")
	message_admins("[key_name_admin(usr)] is debugging the [controller] controller.")


/datum/admins/proc/check_contents(mob/living/M as mob in mob_list)
	set category = "Debug"
	set name = "Check Contents"

	if(!check_rights(R_DEBUG))
		return

	var/list/L = M.get_contents()
	for(var/t in L)
		to_chat(usr, "[t]")

	log_admin("[key_name(usr)] checked the contents of [M.name].")
	message_admins("[key_name_admin(usr)] checked the contents of [M.name].")


/datum/admins/proc/update_mob_sprite(mob/living/carbon/human/H as mob)
	set category = "Debug"
	set name = "Update Mob Sprite"
	set desc = "Should fix any mob sprite errors."

	if(!check_rights(R_DEBUG))
		return

	if(!H || !istype(H))
		return

	H.regenerate_icons()

	log_admin("[key_name(usr)] updated the mob sprite of [key_name(H)].")
	message_admins("[key_name_admin(usr)] updated the mob sprite of [key_name_admin(H)].")