/obj/machinery/computer/skills
	name = "Employment Records"
	desc = "Used to view personnel's employment records"
	icon_state = "medlaptop"
	req_one_access = list(ACCESS_MARINE_BRIDGE)
	circuit = "/obj/item/circuitboard/computer/skills"
	var/obj/item/card/id/scan = null
	var/authenticated = null
	var/rank = null
	var/screen = null
	var/datum/data/record/active1 = null
	var/a_id = null
	var/temp = null
	var/printing = null
	var/can_change_id = 0
	var/list/Perp
	var/tempname = null
	//Sorting Variables
	var/sortBy = "name"
	var/order = 1 // -1 = Descending - 1 = Ascending


/obj/machinery/computer/skills/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/card/id) && !scan)
		if(!user.drop_held_item())
			return
		I.forceMove(src)
		scan = I
		to_chat(user, "You insert [I].")


/obj/machinery/computer/skills/interact(mob/user)
	. = ..()
	if(.)
		return

	var/dat
	if (temp)
		dat = text("[]<BR><BR><A href='?src=\ref[];choice=Clear Screen'>Clear Screen</A>", temp, src)
	else
		dat = text("Confirm Identity: <A href='?src=\ref[];choice=Confirm Identity'>[]</A><HR>", src, (scan ? text("[]", scan.name) : "----------"))
		if (authenticated)
			switch(screen)
				if(1)
					dat += {"
<p style='text-align:center;'>"}
					dat += text("<A href='?src=\ref[];choice=Search Records'>Search Records</A><BR>", src)
					dat += text("<A href='?src=\ref[];choice=New Record (General)'>New Record</A><BR>", src)
					dat += {"
</p>
<table style="text-align:center;" cellspacing="0" width="100%">
<tr>
<th>Records:</th>
</tr>
</table>
<table style="text-align:center;" border="1" cellspacing="0" width="100%">
<tr>
<th><A href='?src=\ref[src];choice=Sorting;sort=name'>Name</A></th>
<th><A href='?src=\ref[src];choice=Sorting;sort=id'>ID</A></th>
<th><A href='?src=\ref[src];choice=Sorting;sort=rank'>Rank</A></th>
<th><A href='?src=\ref[src];choice=Sorting;sort=fingerprint'>Fingerprints</A></th>
</tr>"}
					if(!isnull(GLOB.datacore.general))
						for(var/datum/data/record/R in sortRecord(GLOB.datacore.general, sortBy, order))
							for(var/datum/data/record/E in GLOB.datacore.security)
							var/background
							dat += text("<tr style=[]><td><A href='?src=\ref[];choice=Browse Record;d_rec=\ref[]'>[]</a></td>", background, src, R, R.fields["name"])
							dat += text("<td>[]</td>", R.fields["id"])
							dat += text("<td>[]</td>", R.fields["rank"])
							dat += text("<td>[]</td>", R.fields["fingerprint"])
						dat += "</table><hr width='75%' />"
					dat += text("<br><br><A href='?src=\ref[];choice=Log Out'>{Log Out}</A>",src)
				if(2)
					dat += "<CENTER><B>Employment Record</B></CENTER><BR>"
					if ((istype(active1, /datum/data/record) && GLOB.datacore.general.Find(active1)))
						if(istype(active1.fields["photo_front"], /obj/item/photo))
							var/obj/item/photo/P1 = active1.fields["photo_front"]
							DIRECT_OUTPUT(user, browse_rsc(P1.picture.picture_image, "photo_front"))
						if(istype(active1.fields["photo_side"], /obj/item/photo))
							var/obj/item/photo/P2 = active1.fields["photo_side"]
							DIRECT_OUTPUT(user, browse_rsc(P2.picture.picture_image, "photo_side"))
						dat += text("<table><tr><td>	\
						Name: <A href='?src=\ref[src];choice=Edit Field;field=name'>[active1.fields["name"]]</A><BR> \
						ID: <A href='?src=\ref[src];choice=Edit Field;field=id'>[active1.fields["id"]]</A><BR>\n	\
						Sex: <A href='?src=\ref[src];choice=Edit Field;field=sex'>[active1.fields["sex"]]</A><BR>\n	\
						Age: <A href='?src=\ref[src];choice=Edit Field;field=age'>[active1.fields["age"]]</A><BR>\n	\
						Rank: <A href='?src=\ref[src];choice=Edit Field;field=rank'>[active1.fields["rank"]]</A><BR>\n	\
						Fingerprint: <A href='?src=\ref[src];choice=Edit Field;field=fingerprint'>[active1.fields["fingerprint"]]</A><BR>\n	\
						Physical Status: [active1.fields["p_stat"]]<BR>\n	\
						Mental Status: [active1.fields["m_stat"]]<BR><BR>\n	\
						Employment/skills summary:<BR> [decode(active1.fields["notes"])]<BR></td>	\
						<td align = center valign = top>Photo:<br><img src=photo_front height=80 width=80 border=4>	\
						<img src=photo_side height=80 width=80 border=4></td></tr></table>")
					else
						dat += "<B>General Record Lost!</B><BR>"
					dat += text("<BR><BR>\n<A href='?src=\ref[];choice=Print Record'>Print Record</A><BR>\n<A href='?src=\ref[];choice=Return'>Back</A><BR>", src, src)
				if(3)
					if(!Perp.len)
						dat += text("ERROR.  String could not be located.<br><br><A href='?src=\ref[];choice=Return'>Back</A>", src)
					else
						dat += {"
<table style="text-align:center;" cellspacing="0" width="100%">
<tr>					"}
						dat += text("<th>Search Results for '[]':</th>", tempname)
						dat += {"
</tr>
</table>
<table style="text-align:center;" border="1" cellspacing="0" width="100%">
<tr>
<th>Name</th>
<th>ID</th>
<th>Rank</th>
<th>Fingerprints</th>
</tr>					"}
						for(var/i=1, i<=Perp.len, i += 2)
							var/crimstat = ""
							var/datum/data/record/R = Perp[i]
							if(istype(Perp[i+1],/datum/data/record/))
								var/datum/data/record/E = Perp[i+1]
								crimstat = E.fields["criminal"]
							var/background
							background = "'background-color:#00FF7F;'"
							dat += text("<tr style=[]><td><A href='?src=\ref[];choice=Browse Record;d_rec=\ref[]'>[]</a></td>", background, src, R, R.fields["name"])
							dat += text("<td>[]</td>", R.fields["id"])
							dat += text("<td>[]</td>", R.fields["rank"])
							dat += text("<td>[]</td>", R.fields["fingerprint"])
							dat += text("<td>[]</td></tr>", crimstat)
						dat += "</table><hr width='75%' />"
						dat += text("<br><A href='?src=\ref[];choice=Return'>Return to index.</A>", src)
				else
		else
			dat += text("<A href='?src=\ref[];choice=Log In'>{Log In}</A>", src)

	var/datum/browser/popup = new(user, "secure_rec", "<div align='center'>Employment Records</div>", 600, 400)
	popup.set_content(dat)
	popup.open()

/*Revised /N
I can't be bothered to look more of the actual code outside of switch but that probably needs revising too.
What a mess.*/
/obj/machinery/computer/skills/Topic(href, href_list)
	. = ..()
	if(.)
		return
	if (!( GLOB.datacore.general.Find(active1) ))
		active1 = null

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

		if("Log In")
			if (isAI(usr))
				src.active1 = null
				src.authenticated = usr.name
				src.rank = "AI"
				src.screen = 1
			else if (istype(scan, /obj/item/card/id))
				active1 = null
				if(check_access(scan))
					authenticated = scan.registered_name
					rank = scan.assignment
					screen = 1
//RECORD FUNCTIONS
		if("Search Records")
			var/t1 = input("Search String: (Partial Name or ID or Fingerprints or Rank)", "Secure. records", null, null)  as text
			if ((!( t1 ) || usr.stat || !( authenticated ) || usr.restrained() || !in_range(src, usr)))
				return
			Perp = new/list()
			t1 = lowertext(t1)
			var/list/components = text2list(t1, " ")
			if(components.len > 5)
				return //Lets not let them search too greedily.
			for(var/datum/data/record/R in GLOB.datacore.general)
				var/temptext = R.fields["name"] + " " + R.fields["id"] + " " + R.fields["fingerprint"] + " " + R.fields["rank"]
				for(var/i = 1, i<=components.len, i++)
					if(findtext(temptext,components[i]))
						var/prelist = new/list(2)
						prelist[1] = R
						Perp += prelist
			for(var/i = 1, i<=Perp.len, i+=2)
				for(var/datum/data/record/E in GLOB.datacore.security)
					var/datum/data/record/R = Perp[i]
					if ((E.fields["name"] == R.fields["name"] && E.fields["id"] == R.fields["id"]))
						Perp[i+1] = E
			tempname = t1
			screen = 3

		if ("Browse Record")
			var/datum/data/record/R = locate(href_list["d_rec"])
			if (!( GLOB.datacore.general.Find(R) ))
				temp = "Record Not Found!"
			else
				for(var/datum/data/record/E in GLOB.datacore.security)
				active1 = R
				screen = 2

		if ("Print Record")
			if (!( printing ))
				printing = 1
				sleep(50)
				var/obj/item/paper/P = new /obj/item/paper( loc )
				P.info = "<CENTER><B>Employment Record</B></CENTER><BR>"
				if ((istype(active1, /datum/data/record) && GLOB.datacore.general.Find(active1)))
					P.info += "Name: [active1.fields["name"]] ID: [active1.fields["id"]]<BR>\nSex: [active1.fields["sex"]]<BR>\nAge: [active1.fields["age"]]<BR>\nFingerprint: [active1.fields["fingerprint"]]<BR>\nPhysical Status: [active1.fields["p_stat"]]<BR>\nMental Status: [active1.fields["m_stat"]]<BR>\nEmployment/Skills Summary:<BR>\n[decode(active1.fields["notes"])]<BR>"
					P.name = "Employment Record ([active1.fields["name"]])"
				else
					P.info += "<B>General Record Lost!</B><BR>"
					P.name = "Employment Record (???)"
				P.info += "</TT>"

				printing = null

//RECORD CREATE
		if ("New Record (General)")
			active1 = CreateGeneralRecord()

//FIELD FUNCTIONS
		if ("Edit Field")
			var/a1 = active1
			switch(href_list["field"])
				if("name")
					if (istype(active1, /datum/data/record))
						var/t1 = reject_bad_name(input("Please input name:", "Secure. records", active1.fields["name"], null)  as text)
						if ((!( t1 ) || !length(trim(t1)) || !( authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!issilicon(usr)))) || active1 != a1)
							return
						active1.fields["name"] = t1
				if("id")
					if (istype(active1, /datum/data/record))
						var/t1 = stripped_input(usr, "Please input id:", "Secure. records", active1.fields["id"])
						if ((!( t1 ) || !( authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!issilicon(usr))) || active1 != a1))
							return
						active1.fields["id"] = t1
				if("fingerprint")
					if (istype(active1, /datum/data/record))
						var/t1 = stripped_input(usr, "Please input fingerprint hash:", "Secure. records", active1.fields["fingerprint"])
						if ((!( t1 ) || !( authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!issilicon(usr))) || active1 != a1))
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
						if ((!( t1 ) || !( authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!issilicon(usr))) || active1 != a1))
							return
						active1.fields["age"] = t1
				if("rank")
					var/list/L = list( "Head of Personnel", CAPTAIN, "AI" )
					//This was so silly before the change. Now it actually works without beating your head against the keyboard. /N
					if ((istype(active1, /datum/data/record) && L.Find(rank)))
						temp = "<h5>Rank:</h5>"
						temp += "<ul>"
						for(var/rank in SSjob.name_occupations)
							temp += "<li><a href='?src=\ref[src];choice=Change Rank;rank=[rank]'>[rank]</a></li>"
						temp += "</ul>"
					else
						alert(usr, "You do not have the required rank to do this!")
				if("species")
					if (istype(active1, /datum/data/record))
						var/t1 = stripped_input(usr, "Please enter race:", "General records", active1.fields["species"])
						if ((!( t1 ) || !( authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!issilicon(usr))) || active1 != a1))
							return
						active1.fields["species"] = t1

//TEMPORARY MENU FUNCTIONS
		else//To properly clear as per clear screen.
			temp=null
			switch(href_list["choice"])
				if ("Change Rank")
					if (active1)
						active1.fields["rank"] = href_list["rank"]
				else
					temp = "This function does not appear to be working at the moment. Our apologies."

	updateUsrDialog()


/obj/machinery/computer/skills/emp_act(severity)
	if(machine_stat & (BROKEN|NOPOWER))
		..(severity)
		return

	for(var/datum/data/record/R in GLOB.datacore.security)
		if(prob(10/severity))
			switch(rand(1,6))
				if(1)
					R.fields["name"] = GLOB.namepool[/datum/namepool].get_random_name(pick(MALE, FEMALE))
				if(2)
					R.fields["sex"]	= pick("Male", "Female")
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
