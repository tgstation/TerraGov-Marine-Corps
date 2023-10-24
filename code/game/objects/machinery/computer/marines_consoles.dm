/obj/machinery/computer/marine_card
	name = "Identification Computer"
	desc = "You can use this to change ID's."
	icon_state = "computer_small"
	screen_overlay = "id"
	req_access = list(ACCESS_MARINE_LOGISTICS)
	circuit = /obj/item/circuitboard/computer/card
	resistance_flags = INDESTRUCTIBLE
	var/obj/item/card/id/scan = null
	var/obj/item/card/id/modify = null
	var/authenticated = 0
	var/mode = 0
	var/printing = null


/obj/machinery/computer/marine_card/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/card/id))
		var/obj/item/card/id/idcard = I
		if(ACCESS_MARINE_LOGISTICS in idcard.access)
			if(scan && modify)
				to_chat(user, "Both slots are full already. Remove a card first.")
				return
			if(!scan)
				user.drop_held_item()
				idcard.forceMove(src)
				scan = idcard
			else if(!modify)
				user.drop_held_item()
				idcard.forceMove(src)
				modify = idcard
		else
			if(modify)
				to_chat(user, "The modifying slot is full already. Remove a card first.")
				return
			user.drop_held_item()
			idcard.forceMove(src)
			modify = idcard
	updateUsrDialog()

/obj/machinery/computer/marine_card/interact(mob/user)
	. = ..()
	if(.)
		return

	var/dat
	if(!SSticker)
		return

	if(mode) // accessing crew manifest

		dat += "<h4>Crew Manifest</h4>"
		dat += "Entries cannot be modified from this terminal.<br><br>"
		if(GLOB.datacore)
			dat += GLOB.datacore.get_manifest(0) // make it monochrome
		dat += "<br>"
		dat += "<a href='?src=[text_ref(src)];choice=print'>Print</a><br>"
		dat += "<br>"
		dat += "<a href='?src=[text_ref(src)];choice=mode;mode_target=0'>Access ID modification console.</a><br>"

	else
		var/header

		var/target_name
		var/target_owner
		var/target_rank
		if(modify)
			target_name = modify.name
		else
			target_name = "--------"
		if(modify?.registered_name)
			target_owner = modify.registered_name
		else
			target_owner = "--------"
		if(modify?.assignment)
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
			header += "Target: <a href='?src=[text_ref(src)];choice=modify'>[target_name]</a><br>"
			header += "Confirm Identity: <a href='?src=[text_ref(src)];choice=scan'>[scan_name]</a><br>"
		else
			header += "<div align='center'><br>"
			header += "<a href='?src=[text_ref(src)];choice=modify'>Remove [target_name]</a> || "
			header += "<a href='?src=[text_ref(src)];choice=scan'>Remove [scan_name]</a> <br> "
			header += "<a href='?src=[text_ref(src)];choice=mode;mode_target=1'>Access Crew Manifest</a> || "
			header += "<a href='?src=[text_ref(src)];choice=logout'>Log Out</a></div>"

		header += "<hr>"

		var/jobs_all = ""
		var/list/alljobs = (GLOB.jobs_regular_all - GLOB.jobs_som - list(SYNTHETIC, SILICON_AI) + "Custom")
		for(var/job in alljobs)
			jobs_all += "<a href='?src=[text_ref(src)];choice=assign;assign_target=[job]'>[replacetext(job, " ", "&nbsp")]</a> " //make sure there isn't a line break in the middle of a job


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
			carddesc += "<form name='cardcomp' action='?src=[text_ref(src)]' method='get'>"
			carddesc += "<input type='hidden' name='src' value='\ref[src]'>"
			carddesc += "<input type='hidden' name='choice' value='reg'>"
			carddesc += "<b>Registered Name:</b> <input type='text' id='namefield' name='reg' value='[target_owner]' style='width:250px; background-color:white;' onchange='markRed()'>"
			carddesc += "<input type='submit' value='Rename' onclick='markGreen()'>"
			carddesc += "</form>"

			carddesc += "<form name='accountnum' action='?src=[text_ref(src)]' method='get'>"
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
				paygrade += "<form name='paygrade' action='?src=[text_ref(src)]' method='get'>"
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
			accesses += "<div align='center'><b>Access</b></div>"
			accesses += "<table style='width:100%'>"
			accesses += "<tr>"
			for(var/i in 1 to 8)
				accesses += "<td style='width:14%'><b>[get_region_accesses_name(i)]:</b></td>"
			accesses += "</tr><tr>"
			for(var/i in 1 to 8)
				accesses += "<td style='width:14%' valign='top'>"
				for(var/A in get_region_accesses(i))
					if(A in modify.access)
						accesses += "<a href='?src=[text_ref(src)];choice=access;access_target=[A];allowed=0'><font color=\"red\">[replacetext(get_access_desc(A), " ", "&nbsp")]</font></a> "
					else
						accesses += "<a href='?src=[text_ref(src)];choice=access;access_target=[A];allowed=1'>[replacetext(get_access_desc(A), " ", "&nbsp")]</a> "
					accesses += "<br>"
				accesses += "</td>"
			accesses += "</tr></table>"
			body = "[carddesc]<br>[jobs]<br>[paygrade]<br><br>[accesses]" //CHECK THIS
		else
			body = "<a href='?src=[text_ref(src)];choice=auth'>{Log in}</a> <br><hr>"
			body += "<a href='?src=[text_ref(src)];choice=mode;mode_target=1'>Access Crew Manifest</a>"
		dat = "<tt>[header][body]<hr><br></tt>"

	var/datum/browser/popup = new(user, "id_com", "<div align='center'>Identification Card Modifier</div>", 800, 650)
	popup.set_content(dat)
	popup.open()


/obj/machinery/computer/marine_card/Topic(href, href_list)
	. = ..()
	if(.)
		return

	switch(href_list["choice"])
		if ("modify")
			if (modify)
				GLOB.datacore.manifest_modify(modify.registered_name, modify.assignment)
				modify.name = "[modify.registered_name]'s ID Card ([modify.assignment])"
				if(ishuman(usr))
					modify.loc = usr.loc
					if(!usr.get_active_held_item())
						usr.put_in_hands(modify)
					modify = null
				else
					modify.loc = loc
					modify = null
			else
				var/obj/item/I = usr.get_active_held_item()
				if (istype(I, /obj/item/card/id))
					usr.drop_held_item()
					I.loc = src
					modify = I
			authenticated = 0
		if ("scan")
			if (scan)
				if(ishuman(usr))
					scan.loc = usr.loc
					if(!usr.get_active_held_item())
						usr.put_in_hands(scan)
					scan = null
				else
					scan.loc = src.loc
					scan = null
			else
				var/obj/item/I = usr.get_active_held_item()
				if (istype(I, /obj/item/card/id))
					usr.drop_held_item()
					I.loc = src
					scan = I
			authenticated = 0
		if ("auth")
			if ((!( authenticated ) && (scan || (issilicon(usr))) && (modify || mode)))
				if (check_access(scan))
					authenticated = 1
			else if ((!( authenticated ) && (issilicon(usr))) && (!modify))
				to_chat(usr, "You can't modify an ID without an ID inserted to modify. Once one is in the modify slot on the computer, you can log in.")
		if ("logout")
			authenticated = 0
		if("access")
			if(href_list["allowed"])
				if(authenticated)
					var/access_type = text2num(href_list["access_target"])
					var/access_allowed = text2num(href_list["allowed"])
					if(access_type in ALL_MARINE_ACCESS)
						modify.access -= access_type
						if(access_allowed == 1)
							modify.access += access_type
		if ("assign")
			if (authenticated)
				var/t1 = href_list["assign_target"]
				if(t1 == "Custom")
					var/temp_t = stripped_input("Enter a custom job assignment.","Assignment")
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
						to_chat(usr, span_warning("No log exists for this job."))
						return

					if(!modify)
						to_chat(usr, span_warning("No card to modify!"))
						return

					modify.access = jobdatum.get_access()
					modify.paygrade = jobdatum.paygrade
					modify.assignment = t1
					modify.rank = t1
		if ("reg")
			if (authenticated)
				var/t2 = modify
				//var/t1 = input(usr, "What name?", "ID computer", null)  as text
				if ((authenticated && modify == t2 && (in_range(src, usr) || (issilicon(usr))) && istype(loc, /turf)))
					var/temp_name = reject_bad_name(href_list["reg"])
					if(temp_name)
						modify.registered_name = temp_name
					else
						src.visible_message(span_notice("[src] buzzes rudely."))
		if ("account")
			if (authenticated)
				var/t2 = modify
				//var/t1 = input(usr, "What name?", "ID computer", null)  as text
				if ((authenticated && modify == t2 && (in_range(src, usr) || (issilicon(usr))) && istype(loc, /turf)))
					var/account_num = text2num(href_list["account"])
					modify.associated_account_number = account_num
		if ("paygrade")
			if(authenticated)
				var/t2 = modify
				if ((authenticated && modify == t2 && (in_range(src, usr) || (issilicon(usr))) && istype(loc, /turf)))
					modify.paygrade = href_list["paygrade"]
		if ("mode")
			mode = text2num(href_list["mode_target"])
		if ("print")
			if (!( printing ))
				printing = 1
				sleep(5 SECONDS)
				var/obj/item/paper/P = new /obj/item/paper( loc )

				var/t1 = "<h4>Crew Manifest</h4>"
				t1 += "<br>"
				if(GLOB.datacore)
					t1 += GLOB.datacore.get_manifest(0) // make it monochrome

				P.info = t1
				P.name = "paper- 'Crew Manifest'"
				printing = null
	if (modify)
		modify.name = "[modify.registered_name]'s ID Card ([modify.assignment])"

	updateUsrDialog()

/obj/machinery/computer/marine_card/centcom
	name = "CentCom Identification Computer"
	circuit = /obj/item/circuitboard/computer/card/centcom
	req_access = list(ACCESS_NT_CORPORATE)


//This console changes a marine's squad. It's very simple.
//It also does not: change or increment the squad count (used in the login randomizer), nor does it check for jobs.
//Which means you could get sillyiness like "Alpha Sulaco Chief Medical Officer" or "Delta Logistics Officer".
//But in the long run it's not really a big deal.

/obj/machinery/computer/squad_changer
	name = "Squad Distribution Computer"
	desc = "You can use this to change someone's squad."
	icon_state = "computer_small"
	screen_overlay = "guest"
	req_access = list(ACCESS_MARINE_LOGISTICS)
	resistance_flags = INDESTRUCTIBLE
	var/obj/item/card/id/modify = null
	var/screen = 0 //0: main, 1: squad menu
	///Which faction this computer belongs to
	var/faction = FACTION_TERRAGOV

/obj/machinery/computer/squad_changer/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/card/id))
		var/obj/item/card/id/idcard = I
		if(modify)
			to_chat(user, "Remove the inserted card first.")
			return

		user.drop_held_item()
		idcard.forceMove(src)
		modify = idcard


/obj/machinery/computer/squad_changer/interact(mob/user)
	. = ..()
	if(.)
		return

	var/dat

	var/target_name

	if(modify)
		target_name = modify.name
	else
		target_name = "--------"

	dat += "<CENTER>"

	if(!modify)
		dat += "<br><i>Please insert the card into the slot:</i><br>"
		dat += "Target: <a href='?src=[text_ref(src)];card=1'>[target_name]</a><br>"
	else
		dat += "<br>"
		dat += "<a href='?src=[text_ref(src)];card=1'>Remove [target_name]</a>"

	dat += "<hr>"

	dat += "<BR><A href='?src=[text_ref(src)];squad=1'>Modify Squad</A><BR>"

	var/datum/browser/popup = new(user, "computer", "<div align='center'>Squad Distribution Console</div>", 400, 300)
	popup.set_content(dat)
	popup.open()



/obj/machinery/computer/squad_changer/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(href_list["card"])
		if(modify)
			modify.loc = src.loc
			if(!usr.get_active_held_item() && istype(usr,/mob/living/carbon/human))
				usr.put_in_hands(modify)
			modify = null
		else
			var/obj/item/I = usr.get_active_held_item()
			if (istype(I, /obj/item/card/id))
				usr.drop_held_item()
				I.loc = src
				modify = I

	else if(href_list["squad"])
		if(allowed(usr))
			if(modify && istype(modify))
				var/list/squad_choices = list()
				for(var/datum/squad/squad AS in SSjob.active_squads[faction])
					if(!squad.overwatch_officer)
						squad_choices += squad.name

				var/squad_name = tgui_input_list(usr, "Which squad would you like to claim for Overwatch?", null, squad_choices)
				if(!squad_name || operator != usr)
					return
				var/datum/squad/selected
				for(var/datum/squad/squad AS in SSjob.active_squads[faction])
					if(squad.name == squad_name)
						selected = squad
						break

				//First, remove any existing squad access and clear the card.
				for(var/datum/squad/Q in SSjob.squads)
					if(findtext(modify.assignment, Q.name)) //Found one!
						modify.access -= Q.access //Remove any access found.
						to_chat(usr, "Old squad access removed.")

				if(selected) //Now we have a proper squad. Change their ID to it.
					modify.assignment = "[selected.name] [modify.rank]" //Change the assignment - "Alpha Squad Marine"
					modify.access += selected.access //Add their new squad access (if anything) to their ID.
					to_chat(usr, "[selected.name] Squad added to card.")
				else
					to_chat(usr, "No squad selected.")
				modify.name = "[modify.registered_name]'s ID Card ([modify.assignment])" //Reset our ID name.
			else
				to_chat(usr, "You need to insert a card to modify.")
		else
			to_chat(usr, "You don't have sufficient access to use this console.")

	updateUsrDialog()
