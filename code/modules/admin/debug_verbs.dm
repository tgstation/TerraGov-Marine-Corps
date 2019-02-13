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


/datum/admins/proc/proccall_atom(datum/A as null|area|mob|obj|turf)
	set category = "Debug"
	set name = "Atom ProcCall"
	set waitfor = FALSE

	if(!check_rights(R_DEBUG))
		return

	var/procname = input("Proc name, eg: attack_hand", "Proc:", null) as text|null
	if(!procname)
		return

	if(!hascall(A, procname))
		to_chat(usr, "<font color='red'>Error: callproc_datum(): type [A.type] has no proc named [procname].</font>")
		return

	var/list/lst = usr.client.holder.get_callproc_args()
	if(!lst)
		return

	if(!A || !IsValidSrc(A))
		to_chat(usr, "<span class='warning'>Error: callproc_datum(): owner of proc no longer exists.</span>")
		return

	log_admin("[key_name(usr)] called [A]'s [procname]() with [length(lst) ? "the arguments [list2params(lst)]" : "no arguments"].")
	message_admins("[ADMIN_TPMONTY(usr)] called [A]'s [procname]() with [length(lst) ? "the arguments [list2params(lst)]" : "no arguments"].")
	admin_ticket_log(A, "[key_name_admin(usr)] called [A]'s [procname]() with [length(lst) ? "the arguments [list2params(lst)]" : "no arguments"].")

	var/returnval = WrapAdminProcCall(A, procname, lst) // Pass the lst as an argument list to the proc
	. = usr.client.holder.get_callproc_returnval(returnval, procname)
	if(.)
		to_chat(usr, .)


/datum/admins/proc/proccall_advanced()
	set category = "Debug"
	set name = "Advanced ProcCall"
	set waitfor = FALSE

	if(!check_rights(R_DEBUG))
		return

	var/datum/target = null
	var/targetselected = 0
	var/returnval = null

	switch(alert("Proc owned by something?",, "Yes", "No"))
		if("Yes")
			targetselected = TRUE
			var/list/value = usr.client.vv_get_value(default_class = VV_ATOM_REFERENCE, classes = list(VV_ATOM_REFERENCE, VV_DATUM_REFERENCE, VV_MOB_REFERENCE, VV_CLIENT))
			if(!value["class"] || !value["value"])
				return
			target = value["value"]
		if("No")
			target = null
			targetselected = FALSE

	var/procname = input("Proc path, eg: /proc/attack_hand", "Path:", null) as text|null
	if(!procname)
		return

	//strip away everything but the proc name
	var/list/proclist = splittext(procname, "/")
	if(!length(proclist))
		return

	procname = proclist[length(proclist)]

	var/proctype = "proc"
	if("verb" in proclist)
		proctype = "verb"


	var/procpath
	if(targetselected && !hascall(target, procname))
		to_chat(usr, "<font color='red'>Error: callproc(): type [target.type] has no [proctype] named [procname].</font>")
		return
	else if(!targetselected)
		procpath = text2path("/[proctype]/[procname]")
		if(!procpath)
			to_chat(usr, "<font color='red'>Error: callproc(): proc [procname] does not exist. (Did you forget the /proc/ part?)</font>")
			return

	var/list/lst = usr.client.holder.get_callproc_args()
	if(!lst)
		return

	if(targetselected)
		if(!target)
			to_chat(usr, "<font color='red'>Error: callproc(): owner of proc no longer exists.</font>")
			return
		log_admin("[key_name(usr)] called [target]'s [procname]() with [length(lst) ? "the arguments [list2params(lst)]" : "no arguments"].")
		message_admins("[ADMIN_TPMONTY(usr)] called [target]'s [procname]() with [length(lst) ? "the arguments [list2params(lst)]" : "no arguments"].")
		admin_ticket_log(target, "[key_name(usr)] called [target]'s [procname]() with [length(lst) ? "the arguments [list2params(lst)]" : "no arguments"].")
		returnval = WrapAdminProcCall(target, procname, lst) // Pass the lst as an argument list to the proc
	else
		//this currently has no hascall protection. wasn't able to get it working.
		log_admin("[key_name(usr)] called [procname]() with [length(lst) ? "the arguments [list2params(lst)]" : "no arguments"].")
		message_admins("[ADMIN_TPMONTY(usr)] called [procname]() with [length(lst) ? "the arguments [list2params(lst)]" : "no arguments"].")
		returnval = WrapAdminProcCall(GLOBAL_PROC, procpath, lst) // Pass the lst as an argument list to the proc

	. = usr.client.holder.get_callproc_returnval(returnval, procname)
	if(.)
		to_chat(usr, .)


/datum/admins/proc/get_callproc_returnval(returnval, procname)
	. = ""
	if(islist(returnval))
		var/list/returnedlist = returnval
		. = "<font color='blue'>"
		if(length(returnedlist))
			var/assoc_check = returnedlist[1]
			if(istext(assoc_check) && (returnedlist[assoc_check] != null))
				. += "[procname] returned an associative list:"
				for(var/key in returnedlist)
					. += "\n[key] = [returnedlist[key]]"

			else
				. += "[procname] returned a list:"
				for(var/elem in returnedlist)
					. += "\n[elem]"
		else
			. = "[procname] returned an empty list"
		. += "</font>"

	else
		. = "<font color='blue'>[procname] returned: [!isnull(returnval) ? returnval : "null"]</font>"


/datum/admins/proc/get_callproc_args()
	var/argnum = input("Number of arguments", "Number:", 0) as num|null
	if(isnull(argnum))
		return

	. = list()
	var/list/named_args = list()
	while(argnum--)
		var/named_arg = input("Leave blank for positional argument. Positional arguments will be considered as if they were added first.", "Named argument") as text|null
		var/value = usr.client.vv_get_value(restricted_classes = list(VV_RESTORE_DEFAULT))
		if (!value["class"])
			return
		if(named_arg)
			named_args[named_arg] = value["value"]
		else
			. += value["value"]
	if(LAZYLEN(named_args))
		. += named_args


/datum/admins/proc/change_hivenumber(mob/living/carbon/Xenomorph/X in GLOB.xeno_mob_list)
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
	message_admins("[ADMIN_TPMONTY(usr)] changed hivenumber of [ADMIN_TPMONTY(X)] to [newhive].")


/datum/admins/proc/delete_all()
	set category = "Debug"
	set name = "Delete Instances"

	var/blocked = list(/obj, /obj/item, /obj/effect, /obj/mecha, /obj/machinery, /mob, /mob/living, /mob/living/carbon, /mob/living/carbon/Xenomorph, /mob/living/carbon/human, /mob/dead, /mob/dead/observer, /mob/living/silicon, /mob/living/silicon/robot, /mob/living/silicon/ai)
	var/chosen_deletion = input(usr, "Type the path of the object you want to delete", "Delete:") as null|text

	if(!chosen_deletion)
		return

	chosen_deletion = text2path(chosen_deletion)
	if(!ispath(chosen_deletion))
		return

	if(!ispath(/mob) && !ispath(/obj))
		to_chat(usr, "<span class = 'warning'>Only works for types of /obj or /mob.</span>")
		return

	var/hsbitem = input(usr, "Choose an object to delete.", "Delete:") as null|anything in typesof(chosen_deletion)
	if(!hsbitem)
		return

	var/do_delete = TRUE
	if(hsbitem in blocked)
		if(alert("Are you REALLY sure you wish to delete all instances of [hsbitem]? This will lead to catastrophic results!",,"Yes","No") != "Yes")
			do_delete = FALSE

	var/del_amt = 0
	if(!do_delete)
		return

	for(var/atom/O in world)
		if(istype(O, hsbitem))
			del_amt++
			qdel(O)

	log_admin("[key_name(src)] deleted all instances of [hsbitem] ([del_amt]).")
	message_admins("[ADMIN_TPMONTY(usr)] deleted all instances of [hsbitem] ([del_amt]).")


/datum/admins/proc/generate_powernets()
	set category = "Debug"
	set name = "Generate Powernets"
	set desc = "Regenerate all powernets."

	if(!check_rights(R_DEBUG))
		return

	SSmachines.makepowernets()
	log_admin("[key_name(src)] has remade the powernet. makepowernets() called.")
	message_admins("[key_name_admin(src)] has remade the powernets. makepowernets() called.")

/datum/admins/proc/debug_mob_lists()
	set category = "Debug"
	set name = "Debug Mob Lists"

	var/dat = "<html><head><title>"

	var/choice = input("Which list?") as null|anything in list("Players", "Admins", "Clients", "Mobs", "Living Mobs", "Dead Mobs", "Xenos", "Alive Xenos", "Dead Xenos")
	if(!choice)
		return

	switch(choice)
		if("Players")
			dat += "Players</title></head><body>"
			dat += tg_list2text(GLOB.player_list, "<br>")
		if("Admins")
			dat += "Admins</title></head><body>"
			dat += tg_list2text(GLOB.admins, "<br>")
		if("Clients")
			dat += "Clients</title></head><body>"
			dat += tg_list2text(GLOB.clients, "<br>")
		if("Mobs")
			dat += "Mobs</title></head><body>"
			dat += tg_list2text(GLOB.mob_list, "<br>")
		if("Living Mobs")
			dat += "Living Mobs</title></head><body>"
			dat += tg_list2text(GLOB.alive_mob_list, "<br>")
		if("Dead Mobs")
			dat += "Dead Mobs</title></head><body>"
			dat += tg_list2text(GLOB.dead_mob_list, "<br>")
		if("Xenos")
			dat += "Xenos</title></head><body>"
			dat += tg_list2text(GLOB.xeno_mob_list, "<br>")
		if("Alive Xenos")
			dat += "Alive Xenos</title></head><body>"
			dat += tg_list2text(GLOB.alive_xeno_list, "<br>")
		if("Dead Xenos")
			dat += "Dead Xenos</title></head><body>"
			dat += tg_list2text(GLOB.dead_xeno_list, "<br>")
		if("Humans")
			dat += "Humans</title></head><body>"
			dat += tg_list2text(GLOB.human_mob_list, "<br>")
		if("Alive Humans")
			dat += "Alive Humans</title></head><body>"
			dat += tg_list2text(GLOB.alive_human_list, "<br>")
		if("Dead Xenos")
			dat += "Dead Xenos</title></head><body>"
			dat += tg_list2text(GLOB.dead_human_list, "<br>")

	dat += "</body></html>"

	usr << browse(dat, "window=moblists")

	log_admin("[key_name(usr)] is debugging the [choice] list.")
	message_admins("[ADMIN_TPMONTY(usr)] is debugging the [choice] list.")


/datum/admins/proc/spawn_atom(var/object as text)
	set category = "Debug"
	set name = "Spawn"
	set desc = "Spawn an atom."

	if(!check_rights(R_SPAWN))
		return

	if(!object)
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

	if(ispath(chosen, /turf))
		var/turf/T = get_turf(usr.loc)
		T.ChangeTurf(chosen)
	else
		new chosen(usr.loc)

	log_admin("[key_name(usr)] spawned [chosen] at [AREACOORD(usr.loc)].")
	message_admins("[ADMIN_TPMONTY(usr)] spawned [chosen] at [ADMIN_VERBOSEJMP(usr.loc)].")


/datum/admins/proc/delete_atom(atom/O as obj|mob|turf in world)
	set category = "Debug"
	set name = "Delete"
	set desc = "Delete an atom."

	if(!check_rights(R_DEBUG))
		return

	if(alert(src, "Are you sure you want to delete: [O]?",, "Yes", "No") != "Yes")
		return

	var/turf/T = get_turf(O)

	log_admin("[key_name(usr)] deleted [O] at [AREACOORD(T)].")
	message_admins("[ADMIN_TPMONTY(usr)] deleted [O] at [ADMIN_VERBOSEJMP(T)].")

	qdel(O)


/datum/admins/proc/fix_next_move()
	set category = "Debug"
	set name = "Fix Next Move"

	var/largest_move_time = 0
	var/largest_click_time = 0
	var/mob/largest_move_mob = null
	var/mob/largest_click_mob = null
	for(var/mob/M in GLOB.mob_list)
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
		M.next_move = 1
		M.next_click = 0

	log_admin("[key_name(usr)] tried to fix next move: largest_next_move = [largest_move_time] | mob = [largest_move_mob] | next_click = [largest_click_time] | largest_click_mob = [largest_click_mob] | world.time = [world.time].")
	message_admins("[ADMIN_TPMONTY(largest_move_mob)] had the largest move delay with [largest_move_time] frames / [largest_move_time / 10] seconds.")
	message_admins("[ADMIN_TPMONTY(largest_click_mob)] had the largest click delay with [largest_click_time] frames / [largest_click_time / 10] seconds.")
	message_admins("[ADMIN_TPMONTY(usr)] tried to unfreeze everyone at: world.time = [world.time].")


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
	message_admins("[ADMIN_TPMONTY(usr)] has restarted the [controller] controller.")


/datum/admins/proc/debug_controller(controller in list("Master","Ticker","Lighting","Jobs","Sun","Radio","Supply","Shuttles","Configuration","Cameras", "Transfer Controller", "Gas Data"))
	set category = "Debug"
	set name = "Debug Controllers"
	set desc = "Debug the various periodic loop controllers for the game."

	if(!check_rights(R_DEBUG))
		return

	switch(controller)
		if("Master")
			usr.client.debug_variables(Master)
		if("Ticker")
			usr.client.debug_variables(ticker)
		if("Lighting")
			usr.client.debug_variables(lighting_controller)
		if("Jobs")
			usr.client.debug_variables(RoleAuthority)
		if("Sun")
			usr.client.debug_variables(sun)
		if("Radio")
			usr.client.debug_variables(radio_controller)
		if("Supply")
			usr.client.debug_variables(supply_controller)
		if("Shuttles")
			usr.client.debug_variables(shuttle_controller)
		if("Configuration")
			usr.client.debug_variables(config)
		if("Cameras")
			usr.client.debug_variables(cameranet)

	log_admin("[key_name(usr)] is debugging the [controller] controller.")
	message_admins("[ADMIN_TPMONTY(usr)] is debugging the [controller] controller.")


/datum/admins/proc/check_contents()
	set category = "Debug"
	set name = "Check Contents"

	if(!check_rights(R_DEBUG))
		return

	var/choice = input("Check contents of", "Check Contents") as null|anything in list("Key", "Cliented Mob", "Mob")
	if(!choice)
		return

	var/mob/M
	switch(choice)
		if("Key")
			var/selection = input("Please, select a key.", "Check Contents") as null|anything in sortKey(GLOB.clients)
			if(!selection)
				return
			M = selection:mob
		if("Cliented Mob")
			var/selection = input("Please, select a cliented mob.", "Check Contents") as null|anything in sortList(GLOB.player_list)
			if(!selection)
				return
			M = selection
		if("Mob")
			var/selection = input("Please, select a mob.", "Check Contents") as null|anything in sortList(GLOB.mob_list)
			if(!selection)
				return
			M = selection

	if(!isliving(M))
		return

	var/dat = "<b>Contents of [key_name(M)]:</b><hr>"

	var/list/L = M.get_contents()
	for(var/t in L)
		dat += "[t]<br>"

	usr << browse(dat, "window=contents")

	log_admin("[key_name(usr)] checked the contents of [key_name(M)].")
	message_admins("[ADMIN_TPMONTY(usr)] checked the contents of [ADMIN_TPMONTY(M)].")


/datum/admins/proc/update_mob_sprite()
	set category = "Debug"
	set name = "Update Mob Sprite"
	set desc = "Should fix any mob sprite errors."

	if(!check_rights(R_DEBUG))
		return

	var/selection = input("Please, select a human!", "Update Mob Sprite", null, null) as null|anything in sortmobs(GLOB.human_mob_list)
	if(!selection)
		return

	var/mob/living/carbon/human/H = selection

	H.regenerate_icons()

	log_admin("[key_name(usr)] updated the mob sprite of [key_name(H)].")
	message_admins("[ADMIN_TPMONTY(usr)] updated the mob sprite of [ADMIN_TPMONTY(H)].")