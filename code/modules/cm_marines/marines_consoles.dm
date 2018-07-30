//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/obj/machinery/computer/marine_card
	name = "Identification Computer"
	desc = "You can use this to change ID's."
	icon_state = "id"
	req_access = list(ACCESS_MARINE_LOGISTICS)
	circuit = "/obj/item/circuitboard/computer/card"
	var/obj/item/card/id/scan = null
	var/obj/item/card/id/modify = null
	var/authenticated = 0.0
	var/mode = 0.0
	var/printing = null


/obj/machinery/computer/marine_card/attackby(O as obj, user as mob)//TODO:SANITY
	if(istype(O, /obj/item/card/id))
		var/obj/item/card/id/idcard = O
		if(ACCESS_MARINE_LOGISTICS in idcard.access)
			if(!scan)
				usr.drop_held_item()
				idcard.loc = src
				scan = idcard
			else if(!modify)
				usr.drop_held_item()
				idcard.loc = src
				modify = idcard
			else
				user << "Both slots are full already. Remove a card first."
		else
			if(!modify)
				usr.drop_held_item()
				idcard.loc = src
				modify = idcard
			else
				user << "Both slots are full already. Remove a card first."
	else
		..()


/obj/machinery/computer/marine_card/attack_ai(var/mob/user as mob)
	return attack_hand(user)


/obj/machinery/computer/marine_card/attack_paw(var/mob/user as mob)
	return attack_hand(user)


/obj/machinery/computer/marine_card/bullet_act()
	return 0

/obj/machinery/computer/marine_card/attack_hand(var/mob/user as mob)
	if(..())
		return

	user.set_interaction(src)
	var/dat
	if (!( ticker ))
		return
	if (mode) // accessing crew manifest

		dat += "<h4>Crew Manifest</h4>"
		dat += "Entries cannot be modified from this terminal.<br><br>"
		if(data_core)
			dat += data_core.get_manifest(0) // make it monochrome
		dat += "<br>"
		dat += "<a href='?src=\ref[src];choice=print'>Print</a><br>"
		dat += "<br>"
		dat += "<a href='?src=\ref[src];choice=mode;mode_target=0'>Access ID modification console.</a><br>"

		/*var/crew = ""
		var/list/L = list()
		for (var/datum/data/record/t in data_core.general)
			var/R = t.fields["name"] + " - " + t.fields["rank"]
			L += R
		for(var/R in sortList(L))
			crew += "[R]<br>"*/
		//dat = "<tt><b>Crew Manifest:</b><br>Please use security record computer to modify entries.<br><br>[crew]<a href='?src=\ref[src];choice=print'>Print</a><br><br><a href='?src=\ref[src];choice=mode;mode_target=0'>Access ID modification console.</a><br></tt>"
	else
		var/header = "<div align='center'><b>Identification Card Modifier</b></div>"

		var/target_name
		var/target_owner
		var/target_rank
		if(modify)
			target_name = modify.name
		else
			target_name = "--------"
		if(modify && modify.registered_name)
			target_owner = modify.registered_name
		else
			target_owner = "--------"
		if(modify && modify.assignment)
			target_rank = modify.assignment
		else
			target_rank = "Unassigned"

		var/scan_name
		if(scan)
			scan_name = scan.name
		else
			scan_name = "--------"

		if(!authenticated)
			header += "<br><i>Please insert the cards into the slots</i><br>"
			header += "Target: <a href='?src=\ref[src];choice=modify'>[target_name]</a><br>"
			header += "Confirm Identity: <a href='?src=\ref[src];choice=scan'>[scan_name]</a><br>"
		else
			header += "<div align='center'><br>"
			header += "<a href='?src=\ref[src];choice=modify'>Remove [target_name]</a> || "
			header += "<a href='?src=\ref[src];choice=scan'>Remove [scan_name]</a> <br> "
			header += "<a href='?src=\ref[src];choice=mode;mode_target=1'>Access Crew Manifest</a> || "
			header += "<a href='?src=\ref[src];choice=logout'>Log Out</a></div>"

		header += "<hr>"

		var/jobs_all = ""
		var/list/alljobs = (get_marine_jobs()) + "Custom"
		for(var/job in alljobs)
			jobs_all += "<a href='?src=\ref[src];choice=assign;assign_target=[job]'>[oldreplacetext(job, " ", "&nbsp")]</a> " //make sure there isn't a line break in the middle of a job


		var/body
		if (authenticated && modify)
			var/carddesc = {"<script type="text/javascript">
								function markRed(){
									var nameField = document.getElementById('namefield');
									nameField.style.backgroundColor = "#FFDDDD";
								}
								function markGreen(){
									var nameField = document.getElementById('namefield');
									nameField.style.backgroundColor = "#DDFFDD";
								}
								function markAccountGreen(){
									var nameField = document.getElementById('accountfield');
									nameField.style.backgroundColor = "#DDFFDD";
								}
								function markAccountRed(){
									var nameField = document.getElementById('accountfield');
									nameField.style.backgroundColor = "#FFDDDD";
								}
								function showAll(){
									var allJobsSlot = document.getElementById('alljobsslot');
									allJobsSlot.innerHTML = "<a href='#' onclick='hideAll()'>hide</a><br>"+ "[jobs_all]";
								}
								function hideAll(){
									var allJobsSlot = document.getElementById('alljobsslot');
									allJobsSlot.innerHTML = "<a href='#' onclick='showAll()'>show</a>";
								}
							</script>"}
			carddesc += "<form name='cardcomp' action='?src=\ref[src]' method='get'>"
			carddesc += "<input type='hidden' name='src' value='\ref[src]'>"
			carddesc += "<input type='hidden' name='choice' value='reg'>"
			carddesc += "<b>Registered Name:</b> <input type='text' id='namefield' name='reg' value='[target_owner]' style='width:250px; background-color:white;' onchange='markRed()'>"
			carddesc += "<input type='submit' value='Rename' onclick='markGreen()'>"
			carddesc += "</form>"

			carddesc += "<form name='accountnum' action='?src=\ref[src]' method='get'>"
			carddesc += "<input type='hidden' name='src' value='\ref[src]'>"
			carddesc += "<input type='hidden' name='choice' value='account'>"
			carddesc += "<b>Stored account number:</b> <input type='text' id='accountfield' name='account' value='[modify.associated_account_number]' style='width:250px; background-color:white;' onchange='markAccountRed()'>"
			carddesc += "<input type='submit' value='Rename' onclick='markAccountGreen()'>"
			carddesc += "</form>"

			carddesc += "<b>Assignment:</b> "
			var/jobs = "<span id='alljobsslot'><a href='#' onclick='showAll()'>[target_rank]</a></span><br>" //CHECK THIS
			var/paygrade = ""
			if(!(modify.paygrade in PAYGRADES_MARINE))
				paygrade += "<b>Paygrade:<b> [get_paygrades(modify.paygrade)] -- UNABLE TO MODIFY"
			else
				paygrade += "<form name='paygrade' action='?src=\ref[src]' method='get'>"
				paygrade += "<input type='hidden' name='src' value='\ref[src]'>"
				paygrade += "<input type='hidden' name='choice' value='paygrade'>"
				paygrade += "<b>Paygrade:</b> <select name='paygrade'>"
				var/i
				for(i in PAYGRADES_ENLISTED)
					if(i == modify.paygrade) paygrade += "<option value='[i]' selected=selected>[get_paygrades(i)]</option>"
					else paygrade += "<option value='[i]'>[get_paygrades(i)]</option>"
				if(copytext(scan.paygrade,1,2) == "O")
					var/r = text2num(copytext(scan.paygrade,2))
					r = r > 4 ? 4 : r
					while(--r > 0)
						i = "O[r]"
						if(i == modify.paygrade) paygrade += "<option value='[i]' selected=selected>[get_paygrades(i)]</option>"
						else paygrade += "<option value='[i]'>[get_paygrades(i)]</option>"
				paygrade += "</select>"
				paygrade += "<input type='submit' value='Modify'>"
				paygrade += "</form>"
			var/accesses = ""
			if(istype(src,/obj/machinery/computer/card/centcom))
				accesses += "<h5>Central Command:</h5>"
				for(var/A in get_all_centcom_access())
					if(A in modify.access)
						accesses += "<a href='?src=\ref[src];choice=access;access_target=[A];allowed=0'><font color=\"red\">[oldreplacetext(get_centcom_access_desc(A), " ", "&nbsp")]</font></a> "
					else
						accesses += "<a href='?src=\ref[src];choice=access;access_target=[A];allowed=1'>[oldreplacetext(get_centcom_access_desc(A), " ", "&nbsp")]</a> "
			else
				accesses += "<div align='center'><b>Access</b></div>"
				accesses += "<table style='width:100%'>"
				accesses += "<tr>"
				for(var/i = 1; i <= 6; i++)
					accesses += "<td style='width:14%'><b>[get_region_accesses_name(i)]:</b></td>"
				accesses += "</tr><tr>"
				for(var/i = 1; i <= 6; i++)
					accesses += "<td style='width:14%' valign='top'>"
					for(var/A in get_region_accesses(i))
						if(A in modify.access)
							accesses += "<a href='?src=\ref[src];choice=access;access_target=[A];allowed=0'><font color=\"red\">[oldreplacetext(get_access_desc(A), " ", "&nbsp")]</font></a> "
						else
							accesses += "<a href='?src=\ref[src];choice=access;access_target=[A];allowed=1'>[oldreplacetext(get_access_desc(A), " ", "&nbsp")]</a> "
						accesses += "<br>"
					accesses += "</td>"
				accesses += "</tr></table>"
			body = "[carddesc]<br>[jobs]<br>[paygrade]<br><br>[accesses]" //CHECK THIS
		else
			body = "<a href='?src=\ref[src];choice=auth'>{Log in}</a> <br><hr>"
			body += "<a href='?src=\ref[src];choice=mode;mode_target=1'>Access Crew Manifest</a>"
		dat = "<tt>[header][body]<hr><br></tt>"
	user << browse(dat, "window=id_com;size=625x500")
	onclose(user, "id_com")
	return

/obj/machinery/computer/marine_card/Topic(href, href_list)
	if(..())
		return
	usr.set_interaction(src)
	switch(href_list["choice"])
		if ("modify")
			if (modify)
				data_core.manifest_modify(modify.registered_name, modify.assignment)
				modify.name = text("[modify.registered_name]'s ID Card ([modify.assignment])")
				if(ishuman(usr))
					modify.loc = usr.loc
					if(!usr.get_active_hand())
						usr.put_in_hands(modify)
					modify = null
				else
					modify.loc = loc
					modify = null
			else
				var/obj/item/I = usr.get_active_hand()
				if (istype(I, /obj/item/card/id))
					usr.drop_held_item()
					I.loc = src
					modify = I
			authenticated = 0
		if ("scan")
			if (scan)
				if(ishuman(usr))
					scan.loc = usr.loc
					if(!usr.get_active_hand())
						usr.put_in_hands(scan)
					scan = null
				else
					scan.loc = src.loc
					scan = null
			else
				var/obj/item/I = usr.get_active_hand()
				if (istype(I, /obj/item/card/id))
					usr.drop_held_item()
					I.loc = src
					scan = I
			authenticated = 0
		if ("auth")
			if ((!( authenticated ) && (scan || (istype(usr, /mob/living/silicon))) && (modify || mode)))
				if (check_access(scan))
					authenticated = 1
			else if ((!( authenticated ) && (istype(usr, /mob/living/silicon))) && (!modify))
				usr << "You can't modify an ID without an ID inserted to modify. Once one is in the modify slot on the computer, you can log in."
		if ("logout")
			authenticated = 0
		if("access")
			if(href_list["allowed"])
				if(authenticated)
					var/access_type = text2num(href_list["access_target"])
					var/access_allowed = text2num(href_list["allowed"])
					if(access_type in get_all_marine_access())
						modify.access -= access_type
						if(access_allowed == 1)
							modify.access += access_type
		if ("assign")
			if (authenticated)
				var/t1 = href_list["assign_target"]
				if(t1 == "Custom")
					var/temp_t = copytext(sanitize(input("Enter a custom job assignment.","Assignment")),1,MAX_MESSAGE_LEN)
					//let custom jobs function as an impromptu alt title, mainly for sechuds
					if(temp_t && modify)
						modify.assignment = temp_t
				else
					var/datum/job/jobdatum
					for(var/jobtype in typesof(/datum/job))
						var/datum/job/J = new jobtype
						if(ckey(J.title) == ckey(t1))
							jobdatum = J
							break

					if(!jobdatum)
						usr << "\red No log exists for this job."
						return

					if(!modify)
						usr << "\red No card to modify!"
						return

					modify.access = jobdatum.get_access()
					modify.paygrade = jobdatum.paygrade
					modify.assignment = t1
					modify.rank = t1
		if ("reg")
			if (authenticated)
				var/t2 = modify
				//var/t1 = input(usr, "What name?", "ID computer", null)  as text
				if ((authenticated && modify == t2 && (in_range(src, usr) || (istype(usr, /mob/living/silicon))) && istype(loc, /turf)))
					var/temp_name = reject_bad_name(href_list["reg"])
					if(temp_name)
						modify.registered_name = temp_name
					else
						src.visible_message("<span class='notice'>[src] buzzes rudely.</span>")
		if ("account")
			if (authenticated)
				var/t2 = modify
				//var/t1 = input(usr, "What name?", "ID computer", null)  as text
				if ((authenticated && modify == t2 && (in_range(src, usr) || (istype(usr, /mob/living/silicon))) && istype(loc, /turf)))
					var/account_num = text2num(href_list["account"])
					modify.associated_account_number = account_num
		if ("paygrade")
			if(authenticated)
				var/t2 = modify
				if ((authenticated && modify == t2 && (in_range(src, usr) || (istype(usr, /mob/living/silicon))) && istype(loc, /turf)))
					modify.paygrade = href_list["paygrade"]
		if ("mode")
			mode = text2num(href_list["mode_target"])
		if ("print")
			if (!( printing ))
				printing = 1
				sleep(50)
				var/obj/item/paper/P = new /obj/item/paper( loc )
				/*var/t1 = "<B>Crew Manifest:</B><BR>"
				var/list/L = list()
				for (var/datum/data/record/t in data_core.general)
					var/R = t.fields["name"] + " - " + t.fields["rank"]
					L += R
				for(var/R in sortList(L))
					t1 += "[R]<br>"*/

				var/t1 = "<h4>Crew Manifest</h4>"
				t1 += "<br>"
				if(data_core)
					t1 += data_core.get_manifest(0) // make it monochrome

				P.info = t1
				P.name = "paper- 'Crew Manifest'"
				printing = null
	if (modify)
		modify.name = text("[modify.registered_name]'s ID Card ([modify.assignment])")
	updateUsrDialog()
	return


//This console changes a marine's squad. It's very simple.
//It also does not: change or increment the squad count (used in the login randomizer), nor does it check for jobs.
//Which means you could get sillyiness like "Alpha Sulaco Chief Medical Officer" or "Delta Logistics Officer".
//But in the long run it's not really a big deal.

/obj/machinery/computer/squad_changer
	name = "Squad Distribution Computer"
	desc = "You can use this to change someone's squad."
	icon_state = "guest"
	req_access = list(ACCESS_MARINE_LOGISTICS)
	var/obj/item/card/id/modify = null
	var/screen = 0 //0: main, 1: squad menu

/obj/machinery/computer/squad_changer/attackby(O as obj, user as mob)//TODO:SANITY
	if(user) add_fingerprint(user)
	if(istype(O, /obj/item/card/id))
		var/obj/item/card/id/idcard = O
		if(!modify)
			usr.drop_held_item()
			idcard.loc = src
			modify = idcard
		else
			user << "Remove the inserted card first."
	else
		..()


/obj/machinery/computer/squad_changer/attack_ai(var/mob/user as mob)
	return attack_hand(user)


/obj/machinery/computer/squad_changer/attack_paw(var/mob/user as mob)
	return attack_hand(user)


/obj/machinery/computer/squad_changer/bullet_act()
	return 0

/obj/machinery/computer/squad_changer/attack_hand(var/mob/user as mob)
	if(..())
		return
	if(user) add_fingerprint(user)

	usr.set_interaction(src)

	var/dat = "<div align='center'><b>Squad Distribution Console</b></div>"

	var/target_name

	if(modify)
		target_name = modify.name
	else
		target_name = "--------"

	dat += "<CENTER>"

	if(!modify)
		dat += "<br><i>Please insert the card into the slot:</i><br>"
		dat += "Target: <a href='?src=\ref[src];card=1'>[target_name]</a><br>"
	else
		dat += "<br>"
		dat += "<a href='?src=\ref[src];card=1'>Remove [target_name]</a>"

	dat += "<hr>"

	dat += "<BR><A href='?src=\ref[src];squad=1'>Modify Squad</A><BR>"
//	dat += "<BR><A href='?src=\ref[src];checksquads=1'>Examine Squads</A><BR></CENTER>" //I am too lazy to do this right now.

	user << browse(dat, "window=computer;size=400x300")
	onclose(user, "computer")


/obj/machinery/computer/squad_changer/Topic(href, href_list)
	if(..())
		return

	if (get_dist(src, usr) <= 1 && istype(src.loc, /turf))
		usr.set_interaction(src)
		if(href_list["card"])
			if(modify)
				modify.loc = src.loc
				if(!usr.get_active_hand() && istype(usr,/mob/living/carbon/human))
					usr.put_in_hands(modify)
				modify = null
			else
				var/obj/item/I = usr.get_active_hand()
				if (istype(I, /obj/item/card/id))
					usr.drop_held_item()
					I.loc = src
					modify = I
		else if(href_list["squad"])
			if(allowed(usr))
				if(modify && istype(modify))
					var/list/squad_list = list()
					for(var/datum/squad/S in RoleAuthority.squads)
						if(S.usable)
							squad_list += S.name

					var/name_sel = input("Which squad would you like to put the person in?") as null|anything in squad_list
					if(!name_sel)
						return
					var/datum/squad/selected = get_squad_by_name(name_sel)

					//First, remove any existing squad access and clear the card.
					for(var/datum/squad/Q in RoleAuthority.squads)
						if(findtext(modify.assignment,Q.name)) //Found one!
							modify.access -= Q.access //Remove any access found.
							usr << "Old squad access removed."

					modify.assignment = modify.rank //Use the original assignment name.
					if(selected && selected.usable) //Now we have a proper squad. Change their ID to it.
						var/card_ass = modify.assignment
						modify.assignment = "[selected.name] [card_ass]" //Add squad name to assignment. "Alpha Squad Marine"
						modify.access += selected.access //Add their new squad access (if anything) to their ID.
						usr << "[selected.name] Squad added to card."
					else
						usr << "No squad selected."
					modify.name = "[modify.registered_name]'s ID Card ([modify.assignment])" //Reset our ID name.
				else
					usr << "You need to insert a card to modify."
			else
				usr << "You don't have sufficient access to use this console."
		src.add_fingerprint(usr)
	src.attack_hand(usr)
	return


/obj/machinery/computer/crew
	name = "Crew monitoring computer"
	desc = "Used to monitor active health sensors built into marine jumpsuits."
	icon_state = "crew"
	use_power = 1
	idle_power_usage = 250
	active_power_usage = 500
//	circuit = "/obj/item/circuitboard/computer/crew"
	var/list/tracked = list(  )


/obj/machinery/computer/crew/New()
	tracked = list()
	..()

/obj/machinery/computer/crew/attack_ai(mob/living/user)
	attack_hand(user)
	ui_interact(user)


/obj/machinery/computer/crew/attack_hand(mob/living/user)
	add_fingerprint(user)
	if(stat & (BROKEN|NOPOWER))
		return
	ui_interact(user)


/obj/machinery/computer/crew/update_icon()

	if(stat & BROKEN)
		icon_state = "crewb"
	else
		if(stat & NOPOWER)
			icon_state = "crew0"
			stat |= NOPOWER
		else
			icon_state = initial(icon_state)
			stat &= ~NOPOWER


/obj/machinery/computer/crew/Topic(href, href_list)
	if(..()) return
	if( href_list["close"] )
		var/mob/user = usr
		var/datum/nanoui/ui = nanomanager.get_open_ui(user, src, "main")
		user.unset_interaction()
		ui.close()
		return 0
	if(href_list["update"])
		updateDialog()
		return 1

/obj/machinery/computer/crew/interact(mob/living/user)
	ui_interact(user)

/obj/machinery/computer/crew/ui_interact(mob/living/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	if(stat & (BROKEN|NOPOWER))
		return
	user.set_interaction(src)
	scan()

	var/data[0]
	var/list/crewmembers = list()

	for(var/obj/item/clothing/under/C in tracked)

		var/turf/pos = get_turf(C)

		if(C && pos)
			if(istype(C.loc, /mob/living/carbon/human))

				var/mob/living/carbon/human/H = C.loc
				if(H.mind.special_role && H.loc.z == 1) continue // survivors
				if(H.w_uniform != C)
					continue

				var/list/crewmemberData = list()

				crewmemberData["sensor_type"] = C.sensor_mode
				crewmemberData["dead"] = H.stat > 1
				crewmemberData["oxy"] = round(H.getOxyLoss(), 1)
				crewmemberData["tox"] = round(H.getToxLoss(), 1)
				crewmemberData["fire"] = round(H.getFireLoss(), 1)
				crewmemberData["brute"] = round(H.getBruteLoss(), 1)

				crewmemberData["name"] = "Unknown"
				crewmemberData["rank"] = "Unknown"
				if(H.wear_id && istype(H.wear_id, /obj/item/card/id) )
					var/obj/item/card/id/I = H.wear_id
					crewmemberData["name"] = I.name
					crewmemberData["rank"] = I.rank
				else if(H.wear_id && istype(H.wear_id, /obj/item/device/pda) )
					var/obj/item/device/pda/P = H.wear_id
					crewmemberData["name"] = (P.id ? P.id.name : "Unknown")
					crewmemberData["rank"] = (P.id ? P.id.rank : "Unknown")

				var/area/A = get_area(H)
				crewmemberData["area"] = sanitize(A.name)
//				crewmemberData["x"] = pos.x
//				crewmemberData["y"] = pos.y

				// Works around list += list2 merging lists; it's not pretty but it works
				crewmembers += "temporary item"
				crewmembers[crewmembers.len] = crewmemberData

	crewmembers = sortByKey(crewmembers, "name")

	data["crewmembers"] = crewmembers

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "crew_monitor.tmpl", "Crew Monitoring Computer", 900, 800)

		// adding a template with the key "mapContent" enables the map ui functionality
//		ui.add_template("mapContent", "crew_monitor_map_content.tmpl")
		// adding a template with the key "mapHeader" replaces the map header content
//		ui.add_template("mapHeader", "crew_monitor_map_header.tmpl")

		ui.set_initial_data(data)
		ui.open()

		// should make the UI auto-update; doesn't seem to?
		ui.set_auto_update(1)


/obj/machinery/computer/crew/proc/scan()
	for(var/mob/living/carbon/human/H in mob_list)
		if(!H || !istype(H)) continue
		if(isYautja(H)) continue
		var/obj/item/clothing/under/C = H.w_uniform
		if(!C || !istype(C)) continue
		if(C.has_sensor && H.mind)
			tracked |= C
	return 1
