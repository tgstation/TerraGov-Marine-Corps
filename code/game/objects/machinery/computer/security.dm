/obj/machinery/computer/secure_data
	name = "Security Records"
	desc = "Used to view and edit personnel's security records"
	icon_state = "computer_small"
	screen_overlay = "security"
	broken_icon = "computer_small_red_broken"
	req_one_access = list(ACCESS_MARINE_BRIG, ACCESS_NT_CORPORATE, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_LOGISTICS)
	circuit = /obj/item/circuitboard/computer/secure_data
	var/obj/item/card/id/scan = null
	var/authenticated = null
	var/rank = null
	var/screen = null
	var/datum/data/record/active1 = null
	var/datum/data/record/active2 = null
	var/a_id = null
	var/temp = null
	var/printing = null
	var/can_change_id = 0
	var/list/Perp
	var/tempname = null
	//Sorting Variables
	var/sortBy = "name"
	var/order = 1 // -1 = Descending - 1 = Ascending

/obj/machinery/computer/secure_data/verb/eject_id()
	set category = "Object"
	set name = "Eject ID Card"
	set src in oview(1)

	if(!usr || usr.stat || usr.lying_angle)
		return

	if(scan)
		to_chat(usr, "You remove \the [scan] from \the [src].")
		scan.loc = get_turf(src)
		if(!usr.get_active_held_item() && istype(usr,/mob/living/carbon/human))
			usr.put_in_hands(scan)
		scan = null
	else
		to_chat(usr, "There is nothing to remove from the console.")

/obj/machinery/computer/secure_data/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/card/id) && !scan)
		if(!user.drop_held_item())
			return
		I.forceMove(src)
		scan = I
		to_chat(user, "You insert [I].")


/obj/machinery/computer/secure_data/interact(mob/user)
	. = ..()
	if(.)
		return

	var/dat
	if (temp) //TODO: this proc is awful
		dat = "<TT>[temp]</TT><BR><BR><A href='?src=[text_ref(src)];choice=Clear Screen'>Clear Screen</A>"
	else
		dat = "Confirm Identity: <A href='?src=[text_ref(src)];choice=Confirm Identity'>[scan ? "[scan.name]" : "----------"]</A><HR>"
		if (authenticated)
			switch(screen)
				if(1.0)
					dat += {"
<p style='text-align:center;'>"}
					dat += "<A href='?src=[text_ref(src)];choice=Search Records'>Search Records</A><BR>"
					dat += "<A href='?src=[text_ref(src)];choice=New Record (General)'>New Record</A><BR>"
					dat += {"
</p>
<table style="text-align:center;" cellspacing="0" width="100%">
<tr>
<th>Records:</th>
</tr>
</table>
<table style="text-align:center;" border="1" cellspacing="0" width="100%">
<tr>
<th><A href='?src=[text_ref(src)];choice=Sorting;sort=name'>Name</A></th>
<th><A href='?src=[text_ref(src)];choice=Sorting;sort=id'>ID</A></th>
<th><A href='?src=[text_ref(src)];choice=Sorting;sort=rank'>Rank</A></th>
<th><A href='?src=[text_ref(src)];choice=Sorting;sort=fingerprint'>Fingerprints</A></th>
<th>Criminal Status</th>
</tr>"}
					if(!isnull(GLOB.datacore.general))
						for(var/datum/data/record/R in sortRecord(GLOB.datacore.general, sortBy, order))
							var/crimstat = ""
							for(var/datum/data/record/E in GLOB.datacore.security)
								if ((E.fields["name"] == R.fields["name"] && E.fields["id"] == R.fields["id"]))
									crimstat = E.fields["criminal"]
							var/background
							switch(crimstat)
								if("*Arrest*")
									background = "'background-color:#DC143C;'"
								if("Incarcerated")
									background = "'background-color:#CD853F;'"
								if("Released")
									background = "'background-color:#3BB9FF;'"
								if("None")
									background = "'background-color:#00FF7F;'"
								if("")
									background = "'background-color:#FFFFFF;'"
									crimstat = "No Record."
							dat += "<tr style=[background]><td><A href='?src=[text_ref(src)];choice=Browse Record;d_rec=[text_ref(R)]'>[R.fields["name"]]</a></td>"
							dat += "<td>[R.fields["id"]]</td>"
							dat += "<td>[R.fields["rank"]]</td>"
							dat += "<td>[R.fields["fingerprint"]]</td>"
							dat += "<td>[crimstat]</td></tr>"
						dat += "</table><hr width='75%' />"
					dat += "<A href='?src=[text_ref(src)];choice=Record Maintenance'>Record Maintenance</A><br><br>"
					dat += "<A href='?src=[text_ref(src)];choice=Log Out'>{Log Out}</A>"
				if(2.0)
					dat += "<B>Records Maintenance</B><HR>"
					dat += "<BR><A href='?src=[text_ref(src)];choice=Delete All Records'>Delete All Records</A><BR><BR><A href='?src=[text_ref(src)];choice=Return'>Back</A>"
				if(3.0)
					dat += "<CENTER><B>Security Record</B></CENTER><BR>"
					if ((istype(active1, /datum/data/record) && GLOB.datacore.general.Find(active1)))
						if(istype(active1.fields["photo_front"], /obj/item/photo))
							var/obj/item/photo/P1 = active1.fields["photo_front"]
							DIRECT_OUTPUT(user, browse_rsc(P1.picture.picture_image, "photo_front"))
						if(istype(active1.fields["photo_side"], /obj/item/photo))
							var/obj/item/photo/P2 = active1.fields["photo_side"]
							DIRECT_OUTPUT(user, browse_rsc(P2.picture.picture_image, "photo_side"))
						dat += "<table><tr><td>	\
						Name: <A href='?src=[text_ref(src)];choice=Edit Field;field=name'>[active1.fields["name"]]</A><BR> \
						ID: <A href='?src=[text_ref(src)];choice=Edit Field;field=id'>[active1.fields["id"]]</A><BR>\n \
						Sex: <A href='?src=[text_ref(src)];choice=Edit Field;field=sex'>[active1.fields["sex"]]</A><BR>\n	\
						Age: <A href='?src=[text_ref(src)];choice=Edit Field;field=age'>[active1.fields["age"]]</A><BR>\n	\
						Rank: <A href='?src=[text_ref(src)];choice=Edit Field;field=rank'>[active1.fields["rank"]]</A><BR>\n	\
						Fingerprint: <A href='?src=[text_ref(src)];choice=Edit Field;field=fingerprint'>[active1.fields["fingerprint"]]</A><BR>\n	\
						Physical Status: [active1.fields["p_stat"]]<BR>\n	\
						Mental Status: [active1.fields["m_stat"]]<BR></td>	\
						<td align = center valign = top>Photo:<br> \
						<table><td align = center><img src=photo_front height=80 width=80 border=4><BR><A href='?src=[text_ref(src)];choice=Edit Field;field=photo front'>Update front photo</A></td> \
						<td align = center><img src=photo_side height=80 width=80 border=4><BR><A href='?src=[text_ref(src)];choice=Edit Field;field=photo side'>Update side photo</A></td></table> \
						</td></tr></table>"
					else
						dat += "<B>General Record Lost!</B><BR>"
					if ((istype(active2, /datum/data/record) && GLOB.datacore.security.Find(active2)))
						dat += "<BR>\n<CENTER><B>Security Data</B></CENTER><BR>\nCriminal Status: <A href='?src=[text_ref(src)];choice=Edit Field;field=criminal'>[active2.fields["criminal"]]</A><BR>\n<BR>\nMinor Crimes: <A href='?src=[text_ref(src)];choice=Edit Field;field=mi_crim'>[active2.fields["mi_crim"]]</A><BR>\nDetails: <A href='?src=[text_ref(src)];choice=Edit Field;field=mi_crim_d'>[active2.fields["mi_crim_d"]]</A><BR>\n<BR>\nMajor Crimes: <A href='?src=[text_ref(src)];choice=Edit Field;field=ma_crim'>[active2.fields["ma_crim"]]</A><BR>\nDetails: <A href='?src=[text_ref(src)];choice=Edit Field;field=ma_crim_d'>[active2.fields["ma_crim_d"]]</A><BR>\n<BR>\nImportant Notes:<BR>\n\t<A href='?src=[text_ref(src)];choice=Edit Field;field=notes'>[decode(active2.fields["notes"])]</A><BR>\n<BR>\n<CENTER><B>Comments/Log</B></CENTER><BR>"
						var/counter = 1
						while(active2.fields["com_[counter]"])
							dat += "[active2.fields["com_[counter]"]]<BR><A href='?src=[text_ref(src)];choice=Delete Entry;del_c=[counter]'>Delete Entry</A><BR><BR>"
							counter++
						dat += "<A href='?src=[text_ref(src)];choice=Add Entry'>Add Entry</A><BR><BR>"
						dat += "<A href='?src=[text_ref(src)];choice=Delete Record (Security)'>Delete Record (Security Only)</A><BR><BR>"
					else
						dat += "<B>Security Record Lost!</B><BR>"
						dat += "<A href='?src=[text_ref(src)];choice=New Record (Security)'>New Security Record</A><BR><BR>"
					dat += "\n<A href='?src=[text_ref(src)];choice=Delete Record (ALL)'>Delete Record (ALL)</A><BR><BR>\n<A href='?src=[text_ref(src)];choice=Print Record'>Print Record</A><BR>\n<A href='?src=[text_ref(src)];choice=Return'>Back</A><BR>"
				if(4.0)
					if(!length(Perp))
						dat += "ERROR.  String could not be located.<br><br><A href='?src=[text_ref(src)];choice=Return'>Back</A>"
					else
						dat += {"
<table style="text-align:center;" cellspacing="0" width="100%">
<tr>					"}
						dat += "<th>Search Results for '[tempname]':</th>"
						dat += {"
</tr>
</table>
<table style="text-align:center;" border="1" cellspacing="0" width="100%">
<tr>
<th>Name</th>
<th>ID</th>
<th>Rank</th>
<th>Fingerprints</th>
<th>Criminal Status</th>
</tr>					"}
						for(var/i=1, length(i<=Perp), i += 2)
							var/crimstat = ""
							var/datum/data/record/R = Perp[i]
							if(istype(Perp[i+1],/datum/data/record/))
								var/datum/data/record/E = Perp[i+1]
								crimstat = E.fields["criminal"]
							var/background
							switch(crimstat)
								if("*Arrest*")
									background = "'background-color:#DC143C;'"
								if("Incarcerated")
									background = "'background-color:#CD853F;'"
								if("Released")
									background = "'background-color:#3BB9FF;'"
								if("None")
									background = "'background-color:#00FF7F;'"
								if("")
									background = "'background-color:#FFFFFF;'"
									crimstat = "No Record."
							dat += "<tr style=[background]><td><A href='?src=[text_ref(src)];choice=Browse Record;d_rec=[text_ref(R)]'>[R.fields["name"]]</a></td>"
							dat += "<td>[R.fields["id"]]</td>"
							dat += "<td>[R.fields["rank"]]</td>"
							dat += "<td>[R.fields["fingerprint"]]</td>"
							dat += "<td>[crimstat]</td></tr>"
						dat += "</table><hr width='75%' />"
						dat += "<br><A href='?src=[text_ref(src)];choice=Return'>Return to index.</A>"
				else
		else
			dat += "<A href='?src=[text_ref(src)];choice=Log In'>{Log In}</A>"

	var/datum/browser/popup = new(user, "secure_rec", "<div align='center'>Security Records</div>", 600, 400)
	popup.set_content(dat)
	popup.open()

/*Revised /N
I can't be bothered to look more of the actual code outside of switch but that probably needs revising too.
What a mess.*/
/obj/machinery/computer/secure_data/Topic(href, href_list)
	. = ..()
	if(.)
		return
	if (!( GLOB.datacore.general.Find(active1) ))
		active1 = null
	if (!( GLOB.datacore.security.Find(active2) ))
		active2 = null
	switch(href_list["choice"])
// SORTING!
		if("Sorting")
			// Reverse the order if clicked twice
			if(sortBy == href_list["sort"])
				if(order == 1)
					order = -1
				else
					order = 1
			else
			// New sorting order!
				sortBy = href_list["sort"]
				order = initial(order)
//BASIC FUNCTIONS
		if("Clear Screen")
			temp = null

		if ("Return")
			screen = 1
			active1 = null
			active2 = null

		if("Confirm Identity")
			if (scan)
				if(istype(usr,/mob/living/carbon/human) && !usr.get_active_held_item())
					usr.put_in_hands(scan)
				else
					scan.loc = get_turf(src)
				scan = null
			else
				var/obj/item/I = usr.get_active_held_item()
				if (istype(I, /obj/item/card/id))
					if(usr.drop_held_item())
						I.forceMove(src)
						scan = I

		if("Log Out")
			authenticated = null
			screen = null
			active1 = null
			active2 = null

		if("Log In")
			if (isAI(usr))
				src.active1 = null
				src.active2 = null
				src.authenticated = usr.name
				src.rank = "AI"
				src.screen = 1
			else if (istype(scan, /obj/item/card/id))
				active1 = null
				active2 = null
				if(check_access(scan))
					authenticated = scan.registered_name
					rank = scan.assignment
					screen = 1
//RECORD FUNCTIONS
		if("Search Records")
			var/t1 = input("Search String: (Partial Name or ID or Fingerprints or Rank)", "Secure. records", null, null)  as text
			if ((!( t1 ) || usr.stat || !( authenticated ) || usr.restrained() || !in_range(src, usr)))
				return
			Perp = list()
			t1 = lowertext(t1)
			var/list/components = splittext(t1, " ")
			if(length(components) > 5)
				return //Lets not let them search too greedily.
			for(var/datum/data/record/R in GLOB.datacore.general)
				var/temptext = R.fields["name"] + " " + R.fields["id"] + " " + R.fields["fingerprint"] + " " + R.fields["rank"]
				for(var/i = 1, length(i<=components), i++)
					if(findtext(temptext,components[i]))
						var/list/prelist[2]
						prelist[1] = R
						Perp += prelist
			for(var/i = 1, length(i<=Perp), i+=2)
				for(var/datum/data/record/E in GLOB.datacore.security)
					var/datum/data/record/R = Perp[i]
					if ((E.fields["name"] == R.fields["name"] && E.fields["id"] == R.fields["id"]))
						Perp[i+1] = E
			tempname = t1
			screen = 4

		if("Record Maintenance")
			screen = 2
			active1 = null
			active2 = null

		if ("Browse Record")
			var/datum/data/record/R = locate(href_list["d_rec"])
			var/S = locate(href_list["d_rec"])
			if (!( GLOB.datacore.general.Find(R) ))
				temp = "Record Not Found!"
			else
				for(var/datum/data/record/E in GLOB.datacore.security)
					if ((E.fields["name"] == R.fields["name"] || E.fields["id"] == R.fields["id"]))
						S = E
				active1 = R
				active2 = S
				screen = 3

		if ("Print Record")
			if (!( printing ))
				printing = 1
				var/datum/data/record/record1 = null
				var/datum/data/record/record2 = null
				if ((istype(active1, /datum/data/record) && GLOB.datacore.general.Find(active1)))
					record1 = active1
				if ((istype(active2, /datum/data/record) && GLOB.datacore.security.Find(active2)))
					record2 = active2
				sleep(5 SECONDS)
				var/obj/item/paper/P = new /obj/item/paper( loc )
				P.info = "<CENTER><B>Security Record</B></CENTER><BR>"
				if (record1)
					P.info += "Name: [record1.fields["name"]] ID: [record1.fields["id"]]<BR>\nSex: [record1.fields["sex"]]<BR>\nAge: [record1.fields["age"]]<BR>\nFingerprint: [record1.fields["fingerprint"]]<BR>\nPhysical Status: [record1.fields["p_stat"]]<BR>\nMental Status: [record1.fields["m_stat"]]<BR>"
					P.name = "Security Record ([record1.fields["name"]])"
				else
					P.info += "<B>General Record Lost!</B><BR>"
					P.name = "Security Record"
				if (record2)
					P.info += "<BR>\n<CENTER><B>Security Data</B></CENTER><BR>\nCriminal Status: [record2.fields["criminal"]]<BR>\n<BR>\nMinor Crimes: [record2.fields["mi_crim"]]<BR>\nDetails: [record2.fields["mi_crim_d"]]<BR>\n<BR>\nMajor Crimes: [record2.fields["ma_crim"]]<BR>\nDetails: [record2.fields["ma_crim_d"]]<BR>\n<BR>\nImportant Notes:<BR>\n\t[decode(record2.fields["notes"])]<BR>\n<BR>\n<CENTER><B>Comments/Log</B></CENTER><BR>"
					var/counter = 1
					while(record2.fields["com_[counter]"])
						P.info += "[record2.fields["com_[counter]"]]<BR>"
						counter++
				else
					P.info += "<B>Security Record Lost!</B><BR>"
				P.info += "</TT>"
				printing = null
				updateUsrDialog()
//RECORD DELETE
		if ("Delete All Records")
			temp = ""
			temp += "Are you sure you wish to delete all Security records?<br>"
			temp += "<a href='?src=[text_ref(src)];choice=Purge All Records'>Yes</a><br>"
			temp += "<a href='?src=[text_ref(src)];choice=Clear Screen'>No</a>"

		if ("Purge All Records")
			for(var/datum/data/record/R in GLOB.datacore.security)
				GLOB.datacore.security -= R
				qdel(R)
			temp = "All Security records deleted."

		if ("Add Entry")
			if (!( istype(active2, /datum/data/record) ))
				return
			var/a2 = active2
			var/t1 = stripped_input(usr, "Add Comment:", "Secure. records")
			if ((!( t1 ) || !( authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!issilicon(usr))) || active2 != a2))
				return
			var/counter = 1
			while(active2.fields["com_[counter]"])
				counter++
			active2.fields["com_[counter]"] = "Made by [authenticated] ([rank]) on [time2text(world.realtime, "DDD MMM DD hh:mm:ss")], [GAME_YEAR]<BR>[t1]"

		if ("Delete Record (ALL)")
			if (active1)
				temp = "<h5>Are you sure you wish to delete the record (ALL)?</h5>"
				temp += "<a href='?src=[text_ref(src)];choice=Delete Record (ALL) Execute'>Yes</a><br>"
				temp += "<a href='?src=[text_ref(src)];choice=Clear Screen'>No</a>"

		if ("Delete Record (Security)")
			if (active2)
				temp = "<h5>Are you sure you wish to delete the record (Security Portion Only)?</h5>"
				temp += "<a href='?src=[text_ref(src)];choice=Delete Record (Security) Execute'>Yes</a><br>"
				temp += "<a href='?src=[text_ref(src)];choice=Clear Screen'>No</a>"

		if ("Delete Entry")
			if ((istype(active2, /datum/data/record) && active2.fields["com_[href_list["del_c"]]"]))
				active2.fields["com_[href_list["del_c"]]"] = "<B>Deleted</B>"
//RECORD CREATE
		if ("New Record (Security)")
			if ((istype(active1, /datum/data/record) && !( istype(active2, /datum/data/record) )))
				active2 = CreateSecurityRecord(active1.fields["name"], active1.fields["id"])
				screen = 3

		if ("New Record (General)")
			active1 = CreateGeneralRecord()
			active2 = null

//FIELD FUNCTIONS
		if ("Edit Field")
			if (is_not_allowed(usr))
				return
			var/a1 = active1
			var/a2 = active2
			switch(href_list["field"])
				if("name")
					if (istype(active1, /datum/data/record))
						var/t1 = reject_bad_name(input(usr, "Please input name:", "Secure. records", active1.fields["name"]) as text|null)
						if (!t1 || active1 != a1)
							return
						active1.fields["name"] = t1
				if("id")
					if (istype(active2, /datum/data/record))
						var/t1 = stripped_input(usr, "Please input id:", "Secure. records", active1.fields["id"])
						if (!t1 || active1 != a1)
							return
						active1.fields["id"] = t1
				if("fingerprint")
					if (istype(active1, /datum/data/record))
						var/t1 = stripped_input(usr, "Please input fingerprint hash:", "Secure. records", active1.fields["fingerprint"])
						if (!t1 || active1 != a1)
							return
						active1.fields["fingerprint"] = t1
				if("sex")
					if (istype(active1, /datum/data/record))
						if (active1.fields["sex"] == "Male")
							active1.fields["sex"] = "Female"
						else
							active1.fields["sex"] = "Male"
				if("age")
					if (istype(active1, /datum/data/record))
						var/t1 = input("Please input age:", "Secure. records", active1.fields["age"], null)  as num
						if (!t1 || active1 != a1)
							return
						active1.fields["age"] = t1
				if("mi_crim")
					if (istype(active2, /datum/data/record))
						var/t1 = stripped_input(usr, "Please input minor disabilities list:", "Secure. records", active2.fields["mi_crim"])
						if (!t1 || active2 != a2)
							return
						active2.fields["mi_crim"] = t1
				if("mi_crim_d")
					if (istype(active2, /datum/data/record))
						var/t1 = stripped_input(usr, "Please summarize minor dis.:", "Secure. records", active2.fields["mi_crim_d"])
						if (!t1 || active2 != a2)
							return
						active2.fields["mi_crim_d"] = t1
				if("ma_crim")
					if (istype(active2, /datum/data/record))
						var/t1 = stripped_input(usr, "Please input major diabilities list:", "Secure. records", active2.fields["ma_crim"])
						if (!t1 || active2 != a2)
							return
						active2.fields["ma_crim"] = t1
				if("ma_crim_d")
					if (istype(active2, /datum/data/record))
						var/t1 = stripped_input(usr, "Please summarize major dis.:", "Secure. records", active2.fields["ma_crim_d"])
						if (!t1 || active2 != a2)
							return
						active2.fields["ma_crim_d"] = t1
				if("notes")
					if (istype(active2, /datum/data/record))
						var/t1 = stripped_input("Please summarize notes:", "Secure. records", html_decode(active2.fields["notes"]))
						if (!t1 || active2 != a2)
							return
						active2.fields["notes"] = t1
				if("criminal")
					if (istype(active2, /datum/data/record))
						temp = "<h5>Criminal Status:</h5>"
						temp += "<ul>"
						temp += "<li><a href='?src=[text_ref(src)];choice=Change Criminal Status;criminal2=none'>None</a></li>"
						temp += "<li><a href='?src=[text_ref(src)];choice=Change Criminal Status;criminal2=arrest'>*Arrest*</a></li>"
						temp += "<li><a href='?src=[text_ref(src)];choice=Change Criminal Status;criminal2=incarcerated'>Incarcerated</a></li>"
						temp += "<li><a href='?src=[text_ref(src)];choice=Change Criminal Status;criminal2=released'>Released</a></li>"
						temp += "</ul>"
				if("rank")
					var/list/L = list( "Head of Personnel", CAPTAIN, "AI" )
					//This was so silly before the change. Now it actually works without beating your head against the keyboard. /N
					if ((istype(active1, /datum/data/record) && L.Find(rank)))
						temp = "<h5>Rank:</h5>"
						temp += "<ul>"
						for(var/rank in SSjob.name_occupations)
							temp += "<li><a href='?src=[text_ref(src)];choice=Change Rank;rank=[rank]'>[rank]</a></li>"
						temp += "</ul>"
					else
						alert(usr, "You do not have the required rank to do this!")
				if("species")
					if (istype(active1, /datum/data/record))
						var/t1 = stripped_input(usr, "Please enter species:", "General records", active1.fields["species"])
						if (!t1 || active1 != a1)
							return
						active1.fields["species"] = t1
				if("photo front")
					var/icon/photo = get_photo(usr)
					if(photo)
						active1.fields["photo_front"] = photo
				if("photo side")
					var/icon/photo = get_photo(usr)
					if(photo)
						active1.fields["photo_side"] = photo


//TEMPORARY MENU FUNCTIONS
		else//To properly clear as per clear screen.
			temp=null
			switch(href_list["choice"])
				if ("Change Rank")
					if (active1)
						active1.fields["rank"] = href_list["rank"]

				if ("Change Criminal Status")
					if (active2)
						switch(href_list["criminal2"])
							if("none")
								active2.fields["criminal"] = "None"
							if("arrest")
								active2.fields["criminal"] = "*Arrest*"
							if("incarcerated")
								active2.fields["criminal"] = "Incarcerated"
							if("released")
								active2.fields["criminal"] = "Released"

						for(var/mob/living/carbon/human/H in GLOB.human_mob_list)
							H.sec_hud_set_security_status()

				if ("Delete Record (Security) Execute")
					if (active2)
						qdel(active2)
						active2 = null

				if ("Delete Record (ALL) Execute")
					if (active1)
						for(var/datum/data/record/R in GLOB.datacore.medical)
							if ((R.fields["name"] == active1.fields["name"] || R.fields["id"] == active1.fields["id"]))
								GLOB.datacore.medical -= R
								qdel(R)
							else
						qdel(active1)
						active1 = null
					if (active2)
						qdel(active2)
						active2 = null
				else
					temp = "This function does not appear to be working at the moment. Our apologies."

	updateUsrDialog()


/obj/machinery/computer/secure_data/proc/is_not_allowed(mob/user)
	return !src.authenticated || user.stat || user.restrained() || (!in_range(src, user) && (!issilicon(user)))

/obj/machinery/computer/secure_data/proc/get_photo(mob/user)
	var/atom/A = user.get_active_held_item()
	if(!istype(A, /obj/item/photo))
		return
	return A

/obj/machinery/computer/secure_data/emp_act(severity)
	if(machine_stat & (BROKEN|NOPOWER))
		..(severity)
		return

	for(var/datum/data/record/R in GLOB.datacore.security)
		if(prob(10/severity))
			switch(rand(1,6))
				if(1)
					R.fields["name"] = GLOB.namepool[/datum/namepool].get_random_name(pick(MALE, FEMALE))
				if(2)
					R.fields["sex"] = pick("Male", "Female")
				if(3)
					R.fields["age"] = rand(5, 85)
				if(4)
					R.fields["criminal"] = pick("None", "*Arrest*", "Incarcerated", "Released")
				if(5)
					R.fields["p_stat"] = pick("*Unconcious*", "Active", "Physically Unfit")
				if(6)
					R.fields["m_stat"] = pick("*Insane*", "*Unstable*", "*Watch*", "Stable")
			continue

		else if(prob(1))
			GLOB.datacore.security -= R
			qdel(R)
			continue

	..(severity)

/obj/machinery/computer/secure_data/detective_computer
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "messyfiles"
	screen_overlay = "messyfiles_screen"
