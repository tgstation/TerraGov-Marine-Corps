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

	if(!check_rights(R_DEBUG)) return
	if(config.debugparanoid && !check_rights(R_ADMIN)) return

	spawn(0)
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

/client/proc/Cell()
	set category = "Debug"
	set name = "Cell"
	if(!mob)
		return
	var/turf/T = mob.loc

	if (!( istype(T, /turf) ))
		return

	var/datum/gas_mixture/env = T.return_air()

	var/t = "\blue Coordinates: [T.x],[T.y],[T.z]\n"
	t += "\red Temperature: [env.temperature]\n"
	t += "\red Pressure: [env.return_pressure()]kPa\n"
	for(var/g in env.gas)
		t += "\blue [g]: [env.gas[g]] / [env.gas[g] * R_IDEAL_GAS_EQUATION * env.temperature / env.volume]kPa\n"

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
			var/obj/item/weapon/card/id/id = H.wear_id
			if(istype(H.wear_id, /obj/item/device/pda))
				var/obj/item/device/pda/pda = H.wear_id
				id = pda.id
			id.icon_state = "gold"
			id:access = get_all_accesses()+get_all_centcom_access()+get_all_syndicate_access()
		else
			var/obj/item/weapon/card/id/id = new/obj/item/weapon/card/id(M);
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

/client/proc/cmd_assume_direct_control(var/mob/M in mob_list)
	set category = "Admin"
	set name = "Assume direct control"
	set desc = "Direct intervention"

	if(!check_rights(R_DEBUG|R_ADMIN))	return
	if(M.ckey)
		if(alert("This mob is being controlled by [M.ckey]. Are you sure you wish to assume control of it? [M.ckey] will be made a ghost.",,"Yes","No") != "Yes")
			return
		else
			var/mob/dead/observer/ghost = new/mob/dead/observer(M,1)
			ghost.ckey = M.ckey
			if(ghost.client) ghost.client.view = world.view
	message_admins("\blue [key_name_admin(usr)] assumed direct control of [M].", 1)
	log_admin("[key_name(usr)] assumed direct control of [M].")
	var/mob/adminmob = src.mob
	M.ckey = src.ckey
	if(M.client) M.client.view = world.view
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

/client/proc/cmd_admin_dress(var/mob/living/carbon/human/M in mob_list)
	set category = "Fun"
	set name = "Select Equipment"
	if(!ishuman(M))
		alert("Invalid mob")
		return
	//log_admin("[key_name(src)] has alienized [M.key].")
	var/list/dresspacks = list(
		"strip",
		"USCM Cryo",
		"USCM Private",
		"USCM Specialist (Smartgunner)",
		"USCM Specialist (Armor)",
		"USCM Second-Lieutenant (SO)",
		"USCM First-Lieutenant (XO)",
		"USCM Captain (CO)",
		"USCM Officer (USCM Command)",
		"USCM Admiral (USCM Command)",
		"USCM Combat Synth (Smartgunner)",
		"Weyland-Yutani PMC (Standard)",
		"Weyland-Yutani PMC (Leader)",
		"Weyland-Yutani PMC (Gunner)",
		"Weyland-Yutani PMC (Sniper)",
		"UPP Soldier (Standard)",
		"UPP Soldier (Medic)",
		"UPP Soldier (Heavy)",
		"UPP Soldier (Leader)",
		"UPP Commando (Standard)",
		"UPP Commando (Medic)",
		"UPP Commando (Leader)",
		"CLF Fighter (Standard)",
		"CLF Fighter (Medic)",
		"CLF Fighter (Leader)",
		"Freelancer (Standard)",
		"Freelancer (Medic)",
		"Freelancer (Leader)",
		"Weyland-Yutani Deathsquad",
		"Business Person",
		"UPP Spy",
		"Mk50 Compression Suit",
		"Fleet Admiral",
		"Yautja Warrior",
		"Yautja Elder"
		)

	var/dresscode = input("Select dress for [M]", "Robust quick dress shop") as null|anything in dresspacks
	if (isnull(dresscode))
		return
	feedback_add_details("admin_verb","SEQ") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	for (var/obj/item/I in M)
		if (istype(I, /obj/item/weapon/implant))
			continue
		cdel(I)
	M.arm_equipment(M, dresscode)
	M.regenerate_icons()
	log_admin("[key_name(usr)] changed the equipment of [key_name(M)] to [dresscode].")
	message_admins("\blue [key_name_admin(usr)] changed the equipment of [key_name_admin(M)] to [dresscode].", 1)
	return

/mob/proc/arm_equipment(var/mob/living/carbon/human/M, var/dresscode)
	switch(dresscode)
		if ("strip")
			//do nothing
		if("USCM Cryo")
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/marine(M), WEAR_BACK)

			var/obj/item/weapon/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.access = list()
			W.assignment = "Marine"
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, WEAR_ID)

		if("USCM Private")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/marine(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine(M), WEAR_JACKET)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine(M), WEAR_HEAD)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/marine(M), WEAR_WAIST)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/marine(M), WEAR_BACK)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/m41a(M), WEAR_R_HAND)
			M.equip_to_slot_or_del(new /obj/item/weapon/combat_knife(M), WEAR_L_HAND)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine(M), WEAR_HANDS)

			var/obj/item/weapon/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.access = list()
			W.assignment = "Marine"
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, WEAR_ID)

		if("USCM Specialist (Smartgunner)")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/marine(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/smartgunner(M), WEAR_JACKET)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/specrag(M), WEAR_HEAD)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/marine(M), WEAR_WAIST)
			M.equip_to_slot_or_del(new /obj/item/smartgun_powerpack(M), WEAR_BACK)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/weapon/gun/smartgun(M), WEAR_R_HAND)
			M.equip_to_slot_or_del(new /obj/item/weapon/combat_knife(M), WEAR_L_HAND)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine(M), WEAR_HANDS)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/night/m56_goggles(M), WEAR_EYES)

			var/obj/item/weapon/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.access = list()
			W.assignment = "Smartgunner"
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, WEAR_ID)

		if("USCM Combat Synth (Smartgunner)")
			var/obj/item/clothing/under/marine/J = new(M)
			J.icon_state = ""
			J.item_color = ""
			M.equip_to_slot_or_del(J, WEAR_BODY)
			var/obj/item/clothing/head/helmet/specrag/L = new(M)
			L.icon_state = ""
			L.name = "synth faceplate"
			L.canremove = 0
			L.anti_hug = 99

			M.equip_to_slot_or_del(L, WEAR_HEAD)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/smartgunner(M), WEAR_JACKET)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/marine(M), WEAR_WAIST)
			M.equip_to_slot_or_del(new /obj/item/smartgun_powerpack(M), WEAR_BACK)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/weapon/gun/smartgun(M), WEAR_R_HAND)
			M.equip_to_slot_or_del(new /obj/item/weapon/combat_knife(M), WEAR_L_HAND)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine(M), WEAR_HANDS)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/night/m56_goggles(M), WEAR_EYES)

			var/obj/item/weapon/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card (Combat Synth)"
			W.access = list()
			W.assignment = "Smartgunner"
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, WEAR_ID)
			M.set_species("Machine")

		if("USCM Specialist (Armor)")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/marine(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/specialist(M), WEAR_JACKET)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/specialist(M), WEAR_HEAD)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/marine(M), WEAR_WAIST)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/marine(M), WEAR_BACK)
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas(M), WEAR_FACE)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/m41a(M), WEAR_R_HAND)
			M.equip_to_slot_or_del(new /obj/item/weapon/combat_knife(M), WEAR_L_HAND)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/specialist(M), WEAR_HANDS)

			var/obj/item/weapon/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.access = list()
			W.assignment = "B18 Specialist"
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, WEAR_ID)

		if("USCM Second-Lieutenant (SO)")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/marine/officer/bridge(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/cmcap/ro(M), WEAR_HEAD)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/gun/m4a3/full(M), WEAR_WAIST)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/marine(M), WEAR_BACK)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/mcom(M), WEAR_EAR)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(M), WEAR_HANDS)

			var/obj/item/weapon/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.access = list()
			W.assignment = "Second Lieutenant"
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, WEAR_ID)

		if("USCM First-Lieutenant (XO)")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/marine/officer/exec(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/cmcap(M), WEAR_HEAD)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/gun/m44/full(M), WEAR_WAIST)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/marine(M), WEAR_BACK)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/mcom(M), WEAR_EAR)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(M), WEAR_HANDS)

			var/obj/item/weapon/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.access = list()
			W.access = get_all_accesses()
			W.access += get_all_centcom_access()
			W.assignment = "USCM Executive Officer"
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, WEAR_ID)

		if("USCM Captain (CO)")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/marine/officer/command(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/cmberet/tan(M), WEAR_HEAD)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/gun/mateba/cmateba/full(M), WEAR_WAIST)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/marine(M), WEAR_BACK)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/mcom(M), WEAR_EAR)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(M), WEAR_HANDS)

			var/obj/item/weapon/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.access = list()
			W.access = get_all_accesses()
			W.access += get_all_centcom_access()
			W.assignment = "USCM Commanding Officer"
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, WEAR_ID)

		if("Weyland-Yutani PMC (Standard)")
			var/choice = rand(1,4)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/PMC(M), WEAR_EAR)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/PMC(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/veteran/PMC(M), WEAR_JACKET)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(M), WEAR_HANDS)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/PMC(M), WEAR_HEAD)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/veteran/PMC(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/PMC(M), WEAR_FACE)

			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(M), WEAR_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/grenade/explosive/PMC(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/device/flashlight(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/melee/baton(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/gun/m4a3/vp70,(M), WEAR_WAIST)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70(M), WEAR_R_STORE)

			switch(choice)
				if(1,2,3)
					M.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/m39/elite(M), WEAR_R_HAND)
					M.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m39/ap(M), WEAR_L_STORE)
					M.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m39/ap(M.back), WEAR_IN_BACK)
					M.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m39/ap(M.back), WEAR_IN_BACK)
					M.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m39/ap(M.back), WEAR_IN_BACK)
					M.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m39/ap(M.back), WEAR_IN_BACK)
				if(4)
					M.equip_to_slot_or_del(new /obj/item/weapon/gun/flamer(M), WEAR_R_HAND)
					M.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70(M), WEAR_L_STORE)
					M.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank(M.back), WEAR_IN_BACK)
					M.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank(M.back), WEAR_IN_BACK)
					M.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank(M.back), WEAR_IN_BACK)
					M.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank(M.back), WEAR_IN_BACK)

			var/obj/item/weapon/card/id/W = new(src)
			W.assignment = "PMC Standard"
			W.registered_name = M.real_name
			W.name = "[M.real_name]'s ID Card ([W.assignment])"
			W.icon_state = "centcom"
			W.access = get_all_accesses()
			W.access += get_all_centcom_access()
			M.equip_to_slot_or_del(W, WEAR_ID)

			if(M.mind)
				M.mind.assigned_role = "PMC"
				M.mind.special_role = "MODE"

		if("Weyland-Yutani PMC (Leader)")
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/PMC(M), WEAR_EAR)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/PMC/leader(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/veteran/PMC/leader(M), WEAR_JACKET)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(M), WEAR_HANDS)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/PMC/leader(M), WEAR_HEAD)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/veteran/PMC(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/PMC/leader(M), WEAR_FACE)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(M), WEAR_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/melee/baton(M.back), WEAR_IN_BACK)

			M.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/vp78(M), WEAR_WAIST)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp78(M.back), WEAR_R_STORE)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp78(M.back), WEAR_IN_BACK)

			M.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/m41a/elite(M), WEAR_R_HAND)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap(M), WEAR_L_STORE)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap(M.back), WEAR_IN_BACK)

			var/obj/item/weapon/card/id/W = new(src)
			W.assignment = "PMC Officer"
			W.registered_name = M.real_name
			W.name = "[M.real_name]'s ID Card ([W.assignment])"
			W.icon_state = "centcom"
			W.access = get_all_accesses()
			W.access += get_all_centcom_access()
			M.equip_to_slot_or_del(W, WEAR_ID)

			if(M.mind)
				M.mind.assigned_role = "PMC Leader"
				M.mind.special_role = "MODE"

		if("Weyland-Yutani PMC (Gunner)")
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/PMC(M), WEAR_EAR)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/night/m56_goggles(M), WEAR_EYES)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/PMC(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/smartgunner/veteran/PMC(M), WEAR_JACKET)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(M), WEAR_HANDS)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/PMC/gunner(M), WEAR_HEAD)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/veteran/PMC(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/PMC/leader(M), WEAR_FACE)
			M.equip_to_slot_or_del(new /obj/item/smartgun_powerpack/snow(M), WEAR_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/gun/smartgun(M), WEAR_R_HAND)

			M.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/gun/m4a3/vp70,(M), WEAR_WAIST)

			var/obj/item/weapon/card/id/W = new(src)
			W.assignment = "PMC Specialist"
			W.registered_name = M.real_name
			W.name = "[M.real_name]'s ID Card ([W.assignment])"
			W.icon_state = "centcom"
			W.access = get_all_accesses()
			W.access += get_all_centcom_access()
			M.equip_to_slot_or_del(W, WEAR_ID)

			if(M.mind)
				M.mind.assigned_role = "PMC"
				M.mind.special_role = "MODE"

		if("Weyland-Yutani PMC (Sniper)")
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/PMC(M), WEAR_EAR)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/PMC(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/veteran/PMC/sniper(M), WEAR_JACKET)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(M), WEAR_HANDS)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/PMC/sniper(M), WEAR_HEAD)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/veteran/PMC(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/m42_goggles(M), WEAR_EYES)

			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(M), WEAR_BACK)

			M.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/gun/m4a3/vp70,(M), WEAR_WAIST)

			M.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/sniper/elite(M), WEAR_R_HAND)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/sniper/elite(M), WEAR_L_STORE)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/sniper/elite(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/sniper/elite(M.back), WEAR_IN_BACK)

			var/obj/item/weapon/card/id/W = new(src)
			W.assignment = "PMC Sniper"
			W.registered_name = M.real_name
			W.name = "[M.real_name]'s ID Card ([W.assignment])"
			W.icon_state = "centcom"
			W.access = get_all_accesses()
			W.access += get_all_centcom_access()
			M.equip_to_slot_or_del(W, WEAR_ID)

			if(M.mind)
				M.mind.assigned_role = "PMC"
				M.mind.special_role = "MODE"

		if("Weyland-Yutani Deathsquad")
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/commando(M), WEAR_EAR)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/m42_goggles	(M), WEAR_EYES)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/PMC/commando(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/veteran/PMC/commando(M), WEAR_JACKET)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC/commando(M), WEAR_HANDS)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/PMC/commando(M), WEAR_HEAD)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/commando(M), WEAR_BACK)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/veteran/PMC/commando(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/PMC/leader(M), WEAR_FACE)
			M.equip_to_slot_or_del(new /obj/item/weapon/tank/emergency_oxygen/engi(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/grenade/incendiary(M), WEAR_L_STORE)
			M.equip_to_slot_or_del(new /obj/item/weapon/plastique(M), WEAR_R_STORE)
			M.equip_to_slot_or_del(new /obj/item/weapon/gun/revolver/mateba(M), WEAR_WAIST)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/revolver/mateba(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/m41a/elite(M), WEAR_J_STORE)

			var/obj/item/weapon/card/id/W = new(M)
			W.assignment = "Commando"
			W.registered_name = M.real_name
			W.name = "[M.real_name]'s ID Card ([W.assignment])"
			W.icon_state = "centcom"
			W.access = get_antagonist_pmc_access()
			M.equip_to_slot_or_del(W, WEAR_ID)

			if(M.mind)
				M.mind.assigned_role = "MODE"
				M.mind.special_role = "DEATH SQUAD"


		if("USCM Officer (USCM Command)")
			M.equip_if_possible(new /obj/item/clothing/under/rank/centcom/officer(M), WEAR_BODY)
			M.equip_if_possible(new /obj/item/clothing/shoes/centcom(M), WEAR_FEET)
			M.equip_if_possible(new /obj/item/clothing/gloves/white(M), WEAR_HANDS)
			M.equip_if_possible(new /obj/item/clothing/head/beret/centcom/officer(M), WEAR_HEAD)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/mcom(M), WEAR_EAR)


			var/obj/item/device/pda/heads/pda = new(M)
			pda.owner = M.real_name
			pda.ownjob = "USCM Officer"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"

			M.equip_if_possible(pda, WEAR_R_STORE)
			M.equip_if_possible(new /obj/item/clothing/glasses/sunglasses(M), WEAR_L_STORE)

			var/obj/item/weapon/card/id/centcom/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.access = get_all_accesses()
			W.access += get_all_centcom_access()
			W.assignment = "USCM Officer"
			W.registered_name = M.real_name
			M.equip_if_possible(W, WEAR_ID)

		if("USCM Admiral (USCM Command)")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/marine/officer/admiral(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/centcom(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(M), WEAR_HANDS)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/mcom(M), WEAR_EAR)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/gun/mateba/admiral(M), WEAR_WAIST)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/lightpack(M), WEAR_BACK)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/admiral(M), WEAR_HEAD)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/vest/admiral(M), WEAR_JACKET)

			M.equip_to_slot_or_del(new /obj/item/clothing/mask/breath(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/tank/emergency_oxygen/engi(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/box/handcuffs(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/revolver/mateba(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/revolver/mateba(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/grenade/phosphorus(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/grenade/flashbang(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/MP/admiral(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/handcuffs(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/handcuffs(M.back), WEAR_IN_BACK)




			var/obj/item/device/pda/heads/pda = new(M)
			pda.owner = M.real_name
			pda.ownjob = "USCM Admiral"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"

			M.equip_if_possible(pda, WEAR_R_STORE)
			M.equip_if_possible(new /obj/item/clothing/glasses/sunglasses(M), WEAR_L_STORE)

			var/obj/item/weapon/card/id/centcom/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.access = get_all_accesses()
			W.access += get_all_centcom_access()
			W.assignment = "USCM Admiral"
			W.registered_name = M.real_name
			M.equip_if_possible(W, WEAR_ID)

		if("UPP Soldier (Standard)")
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/bears(M), WEAR_EAR)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/UPP(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/faction/UPP(M), WEAR_JACKET)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/UPP(M), WEAR_HEAD)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/marine/upp(M), WEAR_WAIST)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/lightpack(M), WEAR_BACK)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(M), WEAR_HANDS)

			M.equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/food/snacks/upp(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/type71(M), WEAR_R_HAND)
			M.equip_to_slot_or_del(new /obj/item/weapon/grenade/explosive/upp(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/plastique(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(M), WEAR_R_STORE)
			M.equip_to_slot_or_del(new /obj/item/weapon/upp_knife(M), WEAR_L_STORE)

			var/obj/item/weapon/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.access = list()
			W.assignment = "UPP Soldier"
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, WEAR_ID)
			M.add_language("Russian")
			W.access = get_antagonist_access()

			if(M.mind)
				M.mind.assigned_role = "MODE"
				M.mind.special_role = "UPP"

		if("UPP Soldier (Medic)")
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/bears(M), WEAR_EAR)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/UPP/medic(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/faction/UPP(M), WEAR_JACKET)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/uppcap(M), WEAR_HEAD)
			//M.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/combatLifesaver(M), WEAR_WAIST)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/combatLifesaver/u(M), WEAR_WAIST)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/lightpack(M), WEAR_BACK)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(M), WEAR_HANDS)

			M.equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/food/snacks/upp(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/skorpion/upp(M), WEAR_R_HAND)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/upp_knife(M), WEAR_L_STORE)

			M.equip_to_slot_or_del(new /obj/item/weapon/melee/defibrillator(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/firstaid/adv(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/firstaid/fire(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/pill_bottle/tramadol(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/device/healthanalyzer(M), WEAR_R_STORE)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/hud/health(M), WEAR_EYES)




			var/obj/item/weapon/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.access = list()
			W.assignment = "UPP Medic"
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, WEAR_ID)
			M.add_language("Russian")
			W.access = get_antagonist_access()

			if(M.mind)
				M.mind.assigned_role = "MODE"
				M.mind.special_role = "UPP"

		if("UPP Soldier (Heavy)")
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/bears(M), WEAR_EAR)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/UPP(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/faction/UPP/heavy(M), WEAR_JACKET)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/UPP/heavy(M), WEAR_HEAD)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/marine/upp(M), WEAR_WAIST)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/lightpack(M), WEAR_BACK)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(M), WEAR_HANDS)

			M.equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/food/snacks/upp(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/type71/flamer(M), WEAR_R_HAND)
			M.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/c99/upp(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/c99(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/c99(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/grenade/explosive/upp(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/plastique(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(M), WEAR_R_STORE)
			M.equip_to_slot_or_del(new /obj/item/weapon/upp_knife(M), WEAR_L_STORE)


			var/obj/item/weapon/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.access = list()
			W.assignment = "UPP Specialist"
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, WEAR_ID)
			M.add_language("Russian")
			W.access = get_antagonist_access()

			if(M.mind)
				M.mind.assigned_role = "MODE"
				M.mind.special_role = "UPP"

		if("UPP Soldier (Leader)")
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/bears(M), WEAR_EAR)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/UPP(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/faction/UPP/heavy(M), WEAR_JACKET)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/uppcap/beret(M), WEAR_HEAD)
			//M.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/marine/upp(M), WEAR_WAIST)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/lightpack(M), WEAR_BACK)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(M), WEAR_HANDS)

			M.equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/food/snacks/upp(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/type71/flamer(M), WEAR_R_HAND)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/gun/korovin/standard(M), WEAR_WAIST)
			M.equip_to_slot_or_del(new /obj/item/weapon/grenade/explosive/upp(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/plastique(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/c99(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/c99(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(M), WEAR_R_STORE)
			M.equip_to_slot_or_del(new /obj/item/weapon/upp_knife(M), WEAR_L_STORE)

			var/obj/item/weapon/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.access = list()
			W.assignment = "UPP Leader"
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, WEAR_ID)
			M.add_language("Russian")
			W.access = get_antagonist_access()

			if(M.mind)
				M.mind.assigned_role = "MODE"
				M.mind.special_role = "UPP"


		if("UPP Commando (Standard)")
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/bears(M), WEAR_EAR)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/UPP(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/faction/UPP/commando(M), WEAR_JACKET)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/uppcap(M), WEAR_HEAD)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/gun/korovin/tranq(M), WEAR_WAIST)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/lightpack(M), WEAR_BACK)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(M), WEAR_HANDS)
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/PMC/upp(M), WEAR_FACE)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/night/m42_night_goggles/upp(M), WEAR_EYES)

			M.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/type71/carbine/commando(M), WEAR_R_HAND)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/gun/korovin/tranq(M), WEAR_WAIST)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(M.back), WEAR_IN_BACK)

			M.equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/food/snacks/upp(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/plastique(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/plastique(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/grenade/phosphorus/upp(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/device/chameleon	(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(M), WEAR_R_STORE)
			M.equip_to_slot_or_del(new /obj/item/weapon/upp_knife(M), WEAR_L_STORE)

			M.equip_to_slot_or_del(new /obj/item/weapon/handcuffs(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/handcuffs(M.back), WEAR_IN_BACK)


			var/obj/item/weapon/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.access = list()
			W.assignment = "UPP Commando"
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, WEAR_ID)
			M.add_language("Russian")
			W.access = get_antagonist_access()

			if(M.mind)
				M.mind.assigned_role = "MODE"
				M.mind.special_role = "UPP"


		if("UPP Commando (Medic)")
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/bears(M), WEAR_EAR)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/UPP/medic(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/faction/UPP/commando(M), WEAR_JACKET)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/uppcap(M), WEAR_HEAD)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/lightpack(M), WEAR_BACK)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(M), WEAR_HANDS)
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/PMC/upp(M), WEAR_FACE)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/night/m42_night_goggles/upp(M), WEAR_EYES)

			M.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/type71/carbine/commando(M), WEAR_R_HAND)
			//M.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/combatLifesaver/u(M), WEAR_WAIST)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/gun/korovin/tranq(M), WEAR_WAIST)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(M.back), WEAR_IN_BACK)

			M.equip_to_slot_or_del(new /obj/item/weapon/melee/defibrillator(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/firstaid/adv(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/firstaid/fire(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/pill_bottle/tramadol(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/hud/health(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/device/healthanalyzer(M), WEAR_R_STORE)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/combatLifesaver/u(M.back), WEAR_IN_BACK)

			M.equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/food/snacks/upp(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/plastique(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/plastique(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/device/chameleon	(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/upp_knife(M), WEAR_L_STORE)

			M.equip_to_slot_or_del(new /obj/item/weapon/handcuffs(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/handcuffs(M.back), WEAR_IN_BACK)


			var/obj/item/weapon/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.access = list()
			W.assignment = "UPP Commando Medic"
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, WEAR_ID)
			M.add_language("Russian")
			W.access = get_antagonist_access()

			if(M.mind)
				M.mind.assigned_role = "MODE"
				M.mind.special_role = "UPP"

		if("UPP Commando (Leader)")
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/bears(M), WEAR_EAR)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/UPP(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/faction/UPP/commando(M), WEAR_JACKET)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/uppcap/beret(M), WEAR_HEAD)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/lightpack(M), WEAR_BACK)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(M), WEAR_HANDS)
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/PMC/upp(M), WEAR_FACE)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/night/m42_night_goggles/upp(M), WEAR_EYES)

			M.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/type71/carbine/commando(M), WEAR_R_HAND)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/gun/korovin/tranq(M), WEAR_WAIST)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(M.back), WEAR_IN_BACK)

			M.equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/food/snacks/upp(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/plastique(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/plastique(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/grenade/phosphorus/upp(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/grenade/phosphorus/upp(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/device/chameleon	(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(M), WEAR_R_STORE)
			M.equip_to_slot_or_del(new /obj/item/weapon/upp_knife(M), WEAR_L_STORE)

			M.equip_to_slot_or_del(new /obj/item/weapon/handcuffs(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/handcuffs(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/box/handcuffs(M.back), WEAR_IN_BACK)




			var/obj/item/weapon/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.access = list()
			W.assignment = "UPP Commando Leader"
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, WEAR_ID)
			M.add_language("Russian")
			W.access = get_antagonist_access()

			if(M.mind)
				M.mind.assigned_role = "MODE"
				M.mind.special_role = "UPP"


		if("CLF Fighter (Standard)")
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/dutch(M), WEAR_EAR)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/colonist(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/militia(M), WEAR_JACKET)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/militia(M), WEAR_HEAD)
			//M.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/marine(M), WEAR_WAIST)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/lightpack(M), WEAR_BACK)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(M), WEAR_HANDS)
			M.equip_to_slot_or_del(new /obj/item/weapon/grenade/explosive/stick(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/grenade/incendiary/molotov(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/grenade/incendiary/molotov(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/device/flashlight(M), WEAR_R_STORE)

			spawn_rebel_gun(M)
			spawn_rebel_gun(M,1)

			var/obj/item/weapon/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.access = list()
			W.assignment = "Colonist"
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, WEAR_ID)
			W.access = get_all_accesses()

			if(M.mind)
				M.mind.assigned_role = "MODE"
				M.mind.special_role = "CLF"

		if("CLF Fighter (Medic)")
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/dutch(M), WEAR_EAR)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/colonist(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/militia(M), WEAR_JACKET)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/militia(M), WEAR_HEAD)
			//M.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/marine(M), WEAR_WAIST)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/lightpack(M), WEAR_BACK)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(M), WEAR_HANDS)
			M.equip_to_slot_or_del(new /obj/item/weapon/grenade/explosive/stick(M.back), WEAR_IN_BACK)

			M.equip_to_slot_or_del(new /obj/item/weapon/melee/defibrillator(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/firstaid/adv(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/firstaid/fire(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/pill_bottle/tramadol(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/device/healthanalyzer(M), WEAR_R_STORE)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/hud/health(M), WEAR_EYES)
			M.equip_to_slot_or_del(new /obj/item/device/flashlight(M), WEAR_L_STORE)


			spawn_rebel_gun(M)
			spawn_rebel_gun(M,1)

			var/obj/item/weapon/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.access = list()
			W.assignment = "Colonist Medic"
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, WEAR_ID)
			W.access = get_all_accesses()

			if(M.mind)
				M.mind.assigned_role = "MODE"
				M.mind.special_role = "CLF"

		if("CLF Fighter (Leader)")
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/dutch(M), WEAR_EAR)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/colonist(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/militia(M), WEAR_JACKET)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/frelancer(M), WEAR_HEAD)
			//M.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/marine(M), WEAR_WAIST)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/lightpack(M), WEAR_BACK)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(M), WEAR_HANDS)
			M.equip_to_slot_or_del(new /obj/item/weapon/grenade/explosive/stick(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/grenade/explosive/stick(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/plastique(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/plastique(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/device/flashlight(M), WEAR_R_STORE)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/box/handcuffs(M.back), WEAR_IN_BACK)

			spawn_rebel_gun(M)
			spawn_rebel_gun(M,1)
			spawn_rebel_gun(M,1)

			var/obj/item/weapon/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.access = list()
			W.assignment = "Colonist Leader"
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, WEAR_ID)
			W.access = get_all_accesses()

			if(M.mind)
				M.mind.assigned_role = "MODE"
				M.mind.special_role = "CLF"

		if("Freelancer (Standard)")
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/dutch(M), WEAR_EAR)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/freelancer(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/faction/freelancer(M), WEAR_JACKET)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/frelancer(M), WEAR_HEAD)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/marine(M), WEAR_WAIST)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/lightpack(M), WEAR_BACK)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(M), WEAR_HANDS)
			M.equip_to_slot_or_del(new /obj/item/weapon/grenade/explosive/stick(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/grenade/explosive/stick(M.back), WEAR_IN_BACK)

			spawn_merc_gun(M)
			spawn_rebel_gun(M,1)


			var/obj/item/weapon/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.access = list()
			W.assignment = "Freelancer"
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, WEAR_ID)
			W.access = get_all_accesses()

			if(M.mind)
				M.mind.assigned_role = "MODE"
				M.mind.special_role = "FREELANCERS"

		if("Freelancer (Medic)")
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/dutch(M), WEAR_EAR)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/freelancer(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/faction/freelancer(M), WEAR_JACKET)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/frelancer(M), WEAR_HEAD)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/marine(M), WEAR_WAIST)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/lightpack(M), WEAR_BACK)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(M), WEAR_HANDS)
			M.equip_to_slot_or_del(new /obj/item/weapon/grenade/explosive/stick(M.back), WEAR_IN_BACK)

			M.equip_to_slot_or_del(new /obj/item/weapon/melee/defibrillator(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/firstaid/adv(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/firstaid/fire(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/pill_bottle/tramadol(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/device/healthanalyzer(M), WEAR_R_STORE)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/hud/health(M), WEAR_EYES)

			spawn_merc_gun(M)

			var/obj/item/weapon/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.access = list()
			W.assignment = "Freelancer Medic"
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, WEAR_ID)
			W.access = get_all_accesses()

			if(M.mind)
				M.mind.assigned_role = "MODE"
				M.mind.special_role = "FREELANCERS"


		if("Freelancer (Leader)")
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/dutch(M), WEAR_EAR)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/freelancer(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/faction/freelancer(M), WEAR_JACKET)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/frelancer/beret(M), WEAR_HEAD)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/marine(M), WEAR_WAIST)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/lightpack(M), WEAR_BACK)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(M), WEAR_HANDS)
			M.equip_to_slot_or_del(new /obj/item/weapon/grenade/explosive/stick(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/plastique(M.back), WEAR_IN_BACK)

			spawn_merc_gun(M)
			spawn_merc_gun(M,1)

			var/obj/item/weapon/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.access = list()
			W.assignment = "Freelancer Warlord"
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, WEAR_ID)
			M.add_language("Russian")
			M.add_language("Sainja")
			W.access = get_all_accesses()

			if(M.mind)
				M.mind.assigned_role = "MODE"
				M.mind.special_role = "FREELANCERS"

		if("Business Person")
			M.equip_if_possible(new /obj/item/clothing/under/lawyer/bluesuit(M), WEAR_BODY)
			M.equip_if_possible(new /obj/item/clothing/shoes/centcom(M), WEAR_FEET)
			M.equip_if_possible(new /obj/item/clothing/gloves/white(M), WEAR_HANDS)

			M.equip_if_possible(new /obj/item/clothing/glasses/sunglasses(M), WEAR_L_STORE)
			M.equip_if_possible(new /obj/item/weapon/clipboard(M), WEAR_WAIST)

			var/obj/item/weapon/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.icon_state = "centcom"
			W.item_state = "id_inv"
			W.access = get_all_accesses()
			W.access = get_all_centcom_access()
			W.assignment = "Corporate Representative"
			W.registered_name = M.real_name
			M.equip_if_possible(W, WEAR_ID)

		if("UPP Spy")
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/industrial(M), WEAR_BACK)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/marine/officer/engi(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/brown(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/utility/full(M), WEAR_WAIST)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/mt(M), WEAR_EAR)

			M.equip_to_slot_or_del(new /obj/item/weapon/handcuffs(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/c99/upp/tranq(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/c99t(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/c99t(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/device/chameleon	(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/grenade/explosive/upp(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/plastique(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/plastique(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/box/handcuffs(M.back), WEAR_IN_BACK)

			var/obj/item/weapon/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.access = list(ACCESS_MARINE_ENGINEERING)
			W.assignment = "Maintenance Tech"
			W.registered_name = M.real_name
			M.equip_if_possible(W, WEAR_ID)

			if(M.mind)
				M.mind.assigned_role = "MODE"
				M.mind.special_role = "UPP"

		if ("Mk50 Compression Suit")
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/magboots(M), WEAR_FEET)

			M.equip_to_slot_or_del(new /obj/item/clothing/under/colonist(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/space/compression(M), WEAR_JACKET)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/compression(M), WEAR_HEAD)
			var /obj/item/weapon/tank/jetpack/J = new /obj/item/weapon/tank/jetpack/oxygen(M)
			M.equip_to_slot_or_del(J, WEAR_BACK)
			J.toggle()
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/breath(M), WEAR_FACE)
			J.Topic(null, list("stat" = 1))
			spawn_merc_gun(M)

		if("Fleet Admiral") //Renamed from Soviet Admiral
			M.equip_to_slot_or_del(new /obj/item/clothing/head/hgpiratecap(M), WEAR_HEAD)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(M), WEAR_HANDS)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/mcom(M), WEAR_EAR)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/thermal/eyepatch(M), WEAR_EYES)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/hgpirate(M), WEAR_JACKET)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(M), WEAR_BACK)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/soviet(M), WEAR_BODY)
			var/obj/item/weapon/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.icon_state = "centcom"
			W.access = list()
			W.access = get_all_accesses()
			W.access += get_all_centcom_access()
			W.assignment = "Fleet Admiral"
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, WEAR_ID)

		if("Yautja Warrior")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/chainshirt(M), WEAR_BODY)
			var/obj/item/clothing/gloves/yautja/bracer = new(M)
			bracer.charge = 2500
			bracer.charge_max = 2500
			M.verbs += /obj/item/clothing/gloves/yautja/proc/translate
			bracer.upgrades = 1
			M.equip_to_slot_or_del((bracer), WEAR_HANDS)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/yautja(M), WEAR_EAR)
			M.equip_to_slot_or_del(new /obj/item/weapon/melee/yautja_knife(M), WEAR_R_STORE)
			M.equip_to_slot_or_del(new /obj/item/device/yautja_teleporter(M),WEAR_L_STORE)
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/yautja(M), WEAR_FACE)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/yautja(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/yautja(M), WEAR_EAR)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/yautja(M), WEAR_JACKET)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/yautja(M), WEAR_WAIST)
			M.equip_to_slot_or_del(new /obj/item/weapon/melee/yautja_sword(M), WEAR_L_HAND)
			M.equip_to_slot_or_del(new /obj/item/weapon/grenade/spawnergrenade/smartdisc(M), WEAR_R_HAND)

		if("Yautja Elder")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/chainshirt(M), WEAR_BODY)
			var/obj/item/clothing/gloves/yautja/bracer = new(M)
			bracer.charge = 3000
			bracer.charge_max = 3000
			M.verbs += /obj/item/clothing/gloves/yautja/proc/translate
			bracer.upgrades = 2
			M.equip_to_slot_or_del((bracer), WEAR_HANDS)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/yautja(M), WEAR_EAR)
			M.equip_to_slot_or_del(new /obj/item/weapon/melee/yautja_knife(M), WEAR_R_STORE)
			M.equip_to_slot_or_del(new /obj/item/device/yautja_teleporter(M),WEAR_L_STORE)
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/yautja(M), WEAR_FACE)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/yautja(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/yautja(M), WEAR_EAR)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/yautja/full(M), WEAR_JACKET)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/yautja(M), WEAR_WAIST)
			M.equip_to_slot_or_del(new /obj/item/weapon/twohanded/glaive(M), WEAR_L_HAND)
			M.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/plasmarifle(M), WEAR_R_HAND)

/*


		if ("tournament gangster") //gangster are supposed to fight each other. --rastaf0
			M.equip_to_slot_or_del(new /obj/item/clothing/under/det(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(M), WEAR_FEET)

			M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/det_suit(M), WEAR_JACKET)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/thermal/monocle(M), WEAR_EYES)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/det_hat(M), WEAR_HEAD)

			M.equip_to_slot_or_del(new /obj/item/weapon/cloaking_device(M), WEAR_R_STORE)

			M.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile(M), WEAR_R_HAND)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/a357(M), WEAR_L_STORE)

		if ("tournament chef") //Steven Seagal FTW
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/chef(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/chef(M), WEAR_JACKET)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/chefhat(M), WEAR_HEAD)

			M.equip_to_slot_or_del(new /obj/item/weapon/kitchen/rollingpin(M), WEAR_R_HAND)
			M.equip_to_slot_or_del(new /obj/item/weapon/kitchenknife(M), WEAR_L_HAND)
			M.equip_to_slot_or_del(new /obj/item/weapon/kitchenknife(M), WEAR_R_STORE)
			M.equip_to_slot_or_del(new /obj/item/weapon/kitchenknife(M), WEAR_J_STORE)

		if ("tournament janitor")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/janitor(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(M), WEAR_FEET)
			var/obj/item/weapon/storage/backpack/backpack = new(M)
			for(var/obj/item/I in backpack)
				cdel(I)
			M.equip_to_slot_or_del(backpack, WEAR_BACK)

			M.equip_to_slot_or_del(new /obj/item/weapon/mop(M), WEAR_R_HAND)
			var/obj/item/weapon/reagent_containers/glass/bucket/bucket = new(M)
			bucket.reagents.add_reagent("water", 70)
			M.equip_to_slot_or_del(bucket, WEAR_L_HAND)

			M.equip_to_slot_or_del(new /obj/item/weapon/grenade/chem_grenade/cleaner(M), WEAR_R_STORE)
			M.equip_to_slot_or_del(new /obj/item/weapon/grenade/chem_grenade/cleaner(M), WEAR_L_STORE)
			M.equip_to_slot_or_del(new /obj/item/stack/tile/plasteel(M), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/stack/tile/plasteel(M), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/stack/tile/plasteel(M), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/stack/tile/plasteel(M), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/stack/tile/plasteel(M), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/stack/tile/plasteel(M), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/stack/tile/plasteel(M), WEAR_IN_BACK)

		if ("pirate")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/pirate(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/brown(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/bandana(M), WEAR_HEAD)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/eyepatch(M), WEAR_EYES)
			M.equip_to_slot_or_del(new /obj/item/weapon/melee/energy/sword/pirate(M), WEAR_R_HAND)

		if ("space pirate")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/pirate(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/brown(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/space/pirate(M), WEAR_JACKET)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/pirate(M), WEAR_HEAD)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/eyepatch(M), WEAR_EYES)

			M.equip_to_slot_or_del(new /obj/item/weapon/melee/energy/sword/pirate(M), WEAR_R_HAND)

		if ("soviet soldier")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/soviet(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/ushanka(M), WEAR_HEAD)

		if("tunnel clown")//Tunnel clowns rule!
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/clown(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/clown_shoes(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(M), WEAR_HANDS)
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/clown_hat(M), WEAR_FACE)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/chaplain_hood(M), WEAR_HEAD)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), WEAR_EAR)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/thermal/monocle(M), WEAR_EYES)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/chaplain_hoodie(M), WEAR_JACKET)
			M.equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/food/snacks/grown/banana(M), WEAR_L_STORE)
			M.equip_to_slot_or_del(new /obj/item/weapon/bikehorn(M), WEAR_R_STORE)

			var/obj/item/weapon/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.access = get_all_accesses()
			W.assignment = "Tunnel Clown!"
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, WEAR_ID)

			var/obj/item/weapon/twohanded/fireaxe/fire_axe = new(M)
			M.equip_to_slot_or_del(fire_axe, WEAR_R_HAND)

		if("masked killer")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/overalls(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/white(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/latex(M), WEAR_HANDS)
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/surgical(M), WEAR_FACE)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/welding(M), WEAR_HEAD)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), WEAR_EAR)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/thermal/monocle(M), WEAR_EYES)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/apron(M), WEAR_JACKET)
			M.equip_to_slot_or_del(new /obj/item/weapon/kitchenknife(M), WEAR_L_STORE)
			M.equip_to_slot_or_del(new /obj/item/weapon/scalpel(M), WEAR_R_STORE)

			var/obj/item/weapon/twohanded/fireaxe/fire_axe = new(M)
			M.equip_to_slot_or_del(fire_axe, WEAR_R_HAND)

			for(var/obj/item/carried_item in M.contents)
				if(!istype(carried_item, /obj/item/weapon/implant))//If it's not an implant.
					carried_item.add_blood(M)//Oh yes, there will be blood...

		if("assassin")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/suit_jacket(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(M), WEAR_HANDS)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), WEAR_EAR)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses(M), WEAR_EYES)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/wcoat(M), WEAR_JACKET)
			M.equip_to_slot_or_del(new /obj/item/weapon/melee/energy/sword(M), WEAR_L_STORE)
			M.equip_to_slot_or_del(new /obj/item/weapon/cloaking_device(M), WEAR_R_STORE)

			var/obj/item/weapon/storage/secure/briefcase/sec_briefcase = new(M)
			for(var/obj/item/briefcase_item in sec_briefcase)
				cdel(briefcase_item)
			for(var/i=3, i>0, i--)
				sec_briefcase.contents += new /obj/item/weapon/spacecash/c1000
			sec_briefcase.contents += new /obj/item/weapon/gun/energy/crossbow
			sec_briefcase.contents += new /obj/item/weapon/gun/projectile/mateba
			sec_briefcase.contents += new /obj/item/ammo_magazine/a357
			sec_briefcase.contents += new /obj/item/weapon/plastique
			M.equip_to_slot_or_del(sec_briefcase, WEAR_L_HAND)

			var/obj/item/device/pda/heads/pda = new(M)
			pda.owner = M.real_name
			pda.ownjob = "Reaper"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"

			M.equip_to_slot_or_del(pda, WEAR_WAIST)

			var/obj/item/weapon/card/id/syndicate/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.access = get_all_accesses()
			W.assignment = "Reaper"
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, WEAR_ID)

		if("death commando")//Was looking to add this for a while.
			M.equip_death_commando()

		if("syndicate commando")
			M.equip_syndicate_commando()

		if("weyland-yutani representative")
			M.equip_if_possible(new /obj/item/clothing/under/rank/centcom/representative(M), WEAR_BODY)
			M.equip_if_possible(new /obj/item/clothing/shoes/centcom(M), WEAR_FEET)
			M.equip_if_possible(new /obj/item/clothing/gloves/white(M), WEAR_HANDS)
//			M.equip_if_possible(new /obj/item/device/radio/headset/heads/hop(M), WEAR_EAR)

			var/obj/item/device/pda/heads/pda = new(M)
			pda.owner = M.real_name
			pda.ownjob = "Corporate Representative"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"

			M.equip_if_possible(pda, WEAR_R_STORE)
			M.equip_if_possible(new /obj/item/clothing/glasses/sunglasses(M), WEAR_L_STORE)
			M.equip_if_possible(new /obj/item/weapon/clipboard(M), WEAR_WAIST)

			var/obj/item/weapon/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.icon_state = "centcom"
			W.item_state = "id_inv"
			W.access = get_all_accesses()
			W.access = get_all_centcom_access()
			W.assignment = "Corporate Representative"
			W.registered_name = M.real_name
			M.equip_if_possible(W, WEAR_ID)



		if("emergency response team")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/centcom_officer(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/swat(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/swat(M), WEAR_HANDS)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/ert(M), WEAR_EAR)
			M.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/gun(M), WEAR_WAIST)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses(M), WEAR_EYES)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(M), WEAR_BACK)

			var/obj/item/weapon/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.icon_state = "centcom"
			W.access = get_all_accesses()
			W.access += get_all_centcom_access()
			W.assignment = "Emergency Response Team"
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, WEAR_ID)

		if("special ops officer")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/syndicate/combat(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/swat/officer(M), WEAR_JACKET)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(M), WEAR_HANDS)
//			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/heads/captain(M), WEAR_EAR)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/thermal/eyepatch(M), WEAR_EYES)
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/cigarette/cigar/havana(M), WEAR_FACE)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/deathsquad/beret(M), WEAR_HEAD)
			M.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/pulse_rifle/M1911(M), WEAR_WAIST)
			M.equip_to_slot_or_del(new /obj/item/weapon/flame/lighter/zippo(M), WEAR_R_STORE)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(M), WEAR_BACK)

			var/obj/item/weapon/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.icon_state = "centcom"
			W.access = get_all_accesses()
			W.access += get_all_centcom_access()
			W.assignment = "Special Operations Officer"
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, WEAR_ID)

		if("blue wizard")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/lightpurple(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe(M), WEAR_JACKET)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), WEAR_EAR)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/wizard(M), WEAR_HEAD)
			M.equip_to_slot_or_del(new /obj/item/weapon/teleportation_scroll(M), WEAR_R_STORE)
			M.equip_to_slot_or_del(new /obj/item/weapon/spellbook(M), WEAR_R_HAND)
			M.equip_to_slot_or_del(new /obj/item/weapon/staff(M), WEAR_L_HAND)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(M), WEAR_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/box(M), WEAR_IN_BACK)

		if("red wizard")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/lightpurple(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe/red(M), WEAR_JACKET)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), WEAR_EAR)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/wizard/red(M), WEAR_HEAD)
			M.equip_to_slot_or_del(new /obj/item/weapon/teleportation_scroll(M), WEAR_R_STORE)
			M.equip_to_slot_or_del(new /obj/item/weapon/spellbook(M), WEAR_R_HAND)
			M.equip_to_slot_or_del(new /obj/item/weapon/staff(M), WEAR_L_HAND)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(M), WEAR_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/box(M), WEAR_IN_BACK)

		if("marisa wizard")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/lightpurple(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe/marisa(M), WEAR_JACKET)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal/marisa(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), WEAR_EAR)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/wizard/marisa(M), WEAR_HEAD)
			M.equip_to_slot_or_del(new /obj/item/weapon/teleportation_scroll(M), WEAR_R_STORE)
			M.equip_to_slot_or_del(new /obj/item/weapon/spellbook(M), WEAR_R_HAND)
			M.equip_to_slot_or_del(new /obj/item/weapon/staff(M), WEAR_L_HAND)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(M), WEAR_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/box(M), WEAR_IN_BACK)
		if("soviet admiral")
			M.equip_to_slot_or_del(new /obj/item/clothing/head/hgpiratecap(M), WEAR_HEAD)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(M), WEAR_HANDS)
//			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/heads/captain(M), WEAR_EAR)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/thermal/eyepatch(M), WEAR_EYES)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/hgpirate(M), WEAR_JACKET)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(M), WEAR_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/mateba(M), WEAR_WAIST)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/soviet(M), WEAR_BODY)
			var/obj/item/weapon/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.icon_state = "centcom"
			W.access = get_all_accesses()
			W.access += get_all_centcom_access()
			W.assignment = "Admiral"
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, WEAR_ID)
*/

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
				//S.consume_range = 3
				S.dissipate = 0
				//S.dissipate_delay = 10
				//S.dissipate_track = 0
				//S.dissipate_strength = 10

	for(var/obj/machinery/power/rad_collector/Rad in machines)
		if(Rad.anchored)
			if(!Rad.P)
				var/obj/item/weapon/tank/phoron/Phoron = new/obj/item/weapon/tank/phoron(Rad)
				Phoron.air_contents.gas["phoron"] = 70
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

				var/obj/item/weapon/tank/phoron/Phoron = new/obj/item/weapon/tank/phoron(Rad)

				Phoron.air_contents.gas["phoron"] = 29.1154	//This is a full tank if you filled it from a canister
				Rad.P = Phoron

				Phoron.loc = Rad

				if(!Rad.active)
					Rad.toggle_power()
				Rad.update_icon()

			else if(istype(M,/obj/machinery/atmospherics/binary/pump))	//Turning on every pump.
				var/obj/machinery/atmospherics/binary/pump/Pump = M
				if(Pump.name == "Engine Feed" && response == "Setup Completely")
					found_the_pump = 1
					Pump.air2.gas["nitrogen"] = 3750	//The contents of 2 canisters.
					Pump.air2.temperature = 50
					Pump.air2.update_values()
				Pump.on=1
				Pump.target_pressure = 4500
				Pump.update_icon()

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
		var/turf/simulated/T = SM.loc
		T.zone.air.gas["nitrogen"] += 450
		T.zone.air.temperature = 50
		T.zone.air.update_values()


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

/client/proc/spawn_predators()
	set category = "Debug"
	set name = "Force Spawn Predators"
	set desc = "This allows you to spawn predators outside of predator rounds. They can join the hunt manually during a predator round instead."

	if(!ticker || !ticker.mode)
		alert("Wait until the game starts.")
		return

	var/sure = alert("Are you sure you want to force-spawn predators into the game?","Sure?","Yes","No")
	if(sure == "No") return

	var/datum/game_mode/predator_round = ticker.mode //For the round itself.
	predator_round.force_predator_spawn()

	message_admins("[key_name_admin(src)] used <b>spawn predators!</b>")
	return

/client/proc/global_fix_atmos()
	set name = "Global Fix Air"
	set category = "Debug"
	set desc = "Atmos panic button"

	var/a = alert("WARNING: THIS WILL RESET ALL AIR GROUPS OVER 1000 kPa TO STANDARD TEMPERATURE AND AIR MAKEUP. THERE IS A MEDIUM CHANCE LAG THE FUCK OUT OF THE GAME. DO YOU WISH TO PROCEED?",, "Yes", "No")

	if(a != "Yes") return

	log_admin("[src] has hit the atmos panic button. Good luck, as God save us all")

	var/i
	var/zone/Z
	var/datum/gas_mixture/G
	var/savefile/S = new("atmos_logging.sav")

	S["logging [time2text(world.realtime)]"] << "[time2text(world.realtime)] :: verb used by [src]"

	for(i in air_master.zones)
		Z = i
		if(!istype(Z)) continue
		G = Z.air
		if(!istype(G)) continue
		if(G.return_pressure() > 1000)
			for(var/g in G.gas)
				S["logging \ref[G] g"] << "[gas_data.name[g]]: [round((G.gas[g] / G.total_moles) * 100)]% ([round(G.gas[g], 0.01)])"
			G.gas["sleeping_agent_archived"] = null
			G.gas["sleeping_agent"] = 0
			G.gas["phoron_archived"] = null
			G.gas["phoron"] = 0
			G.gas["carbon_dioxide"] = 0
			G.gas["carbon_dioxide_archived"] = null
			G.gas["oxygen"] = 21.8366
			G.gas["oxygen_archived"] = null
			G.gas["nitrogen"] = 82.1472
			G.gas["nitrogen_archived"] = null
			G.gas["temperature_archived"] = null
			G.temperature = 293.15
			G.update_values()

	S.ExportText("/", file("atmos_logging.txt"))

	src << "<font size=15 color=red>TELL MADSNAILDISEASE YOU USED THIS!</font>"