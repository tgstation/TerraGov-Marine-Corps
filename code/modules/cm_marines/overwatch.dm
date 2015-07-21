/obj/machinery/computer/overwatch
	name = "Overwatch Console"
	desc = "State of the art machinery for giving orders to a squad."
	icon_state = "dummy"
	req_access = list(access_sulaco_bridge)

	var/datum/squad/current_squad = null
	var/mob/living/carbon/human/operator = null
	var/state = 0
	var/mob/living/carbon/human/info_from = null
	var/obj/machinery/camera/cam = null
	var/list/network = list("LEADER")
	var/is_watching = 0


/obj/machinery/computer/overwatch/attackby(var/obj/I as obj, var/mob/user as mob)  //Can't break or disassemble.
	return

/obj/machinery/computer/overwatch/bullet_act(var/obj/item/projectile/Proj) //Can't shoot it
	return

/obj/machinery/computer/overwatch/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)


/obj/machinery/computer/overwatch/attack_paw(var/mob/user as mob) //why monkey why
	return src.attack_hand(user)

/obj/machinery/computer/overwatch/attack_hand(var/mob/user as mob)
	if(..())  //Checks for power outages
		return

	user.set_machine(src)
	var/dat = "<head><title>Overwatch Console</title></head><body>"

	if(!operator)
		dat += "<BR>Operator: <A href='?src=\ref[src];operation=change_operator'>----------</A><BR>"
	else
		dat += "<BR>Operator: <A href='?src=\ref[src];operation=change_operator'>[operator.name]</A><BR>"
		dat += "<A href='?src=\ref[src];operation=logout'>{Stop Overwatch}</A><BR>"
		dat += "----------------------<br>"

		switch(src.state)
			if(0)
				if(!current_squad) //No squad has been set yet. Pick one.
					dat += "Current Squad: <A href='?src=\ref[src];operation=pick_squad'>----------</A><BR>"
				else
					dat += "Current Squad: <A href='?src=\ref[src];operation=pick_squad'>[current_squad.name] Squad</A>  "
					dat += "<A href='?src=\ref[src];operation=message'>\[Message Squad\]</a><br><br>"
					dat += "----------------------<BR><BR>"
					if(current_squad.squad_leader && istype(current_squad.squad_leader))
						dat += "<B>Squad Leader:</B> <A href='?src=\ref[src];operation=get_info;info_from=\ref[current_squad.squad_leader]'>[current_squad.squad_leader.name]</a> "
						dat += "<A href='?src=\ref[src];operation=cam'>\[CAM\]</a> "
						dat += "<A href='?src=\ref[src];operation=sl_message'>\[MSG\]</a><BR><BR>"
					else
						dat += "<B>Squad Leader:</B> <font color=red>NONE</font><br><BR>"
					dat += "<B>Primary Objective:</B> "
					if(current_squad.primary_objective)
						dat += "<A href='?src=\ref[src];operation=check_primary'>\[Check\]</A> <A href='?src=\ref[src];operation=set_primary'>\[Set\]</A><BR>"
					else
						dat += "<B><font color=red>NONE!</font></B> <A href='?src=\ref[src];operation=set_primary'>\[Set\]</A><BR>"
					dat += "<B>Secondary Objective:</B> "
					if(current_squad.secondary_objective)
						dat += "<A href='?src=\ref[src];operation=check_secondary'>\[Check\]</A> <A href='?src=\ref[src];operation=set_secondary'>\[Set\]</A><BR>"
					else
						dat += "<B><font color=red>NONE!</font></B> <A href='?src=\ref[src];operation=set_secondary'>\[Set\]</A><BR>"
					dat += "<BR>"
					if(!current_squad.supply_timer)
						if(!current_squad.sbeacon)
							dat += "<b>Supply Drop Status:</b> No beacon located! <A href='?src=\ref[src];operation=refresh'>\[Locate\]</A><BR>"
						else
							dat += "<b>Supply Drop Status:</b> Available - <A href='?src=\ref[src];operation=dropsupply'>\[Drop\]</A><BR>"
					else
						dat += "<b>Supply Drop Status:</b> Launch Tubes Resetting</A><BR>"

					if(!current_squad.bomb_timer)
						if(!current_squad.bbeacon)
							dat += "<b>Orbital Bombardment Status:</b> No beacon located! <A href='?src=\ref[src];operation=refresh'>\[Locate\]</A><BR>"
						else
							dat += "<b>Orbital Bombardment Status:</b> Available - <A href='?src=\ref[src];operation=dropbomb'>\[FIRE!\]</A><BR>"
					else
						dat += "<b>Orbital Bombardment Status:</b> Orbital Cannon Resetting</A><BR><BR>"
					dat += "<A href='?src=\ref[src];operation=monitor'>Squad Monitor</a>"
					dat += "<BR><BR>----------------------<BR></Body>"
					dat += "<BR><BR><A href='?src=\ref[src];operation=refresh'>{Refresh}</a></Body>"

			if(1)//Info screen.
				dat += "<BR><B>Squad Monitor</B><BR><BR>"
				if(!current_squad)
					dat += "No squad selected!<BR>"
				else
					dat += "<table border='1' style='width:100%' align='center'><tr>"
					dat += "<th>Name</th><th>Role</th><th>State</th><th>Location</th><th>SL Distance</th></tr>"

					for(var/mob/living/carbon/human/H in mob_list)
						if(!H.mind) continue
						var/datum/squad/H_squad = H.mind.assigned_squad //This should be set always for squaddies.
						if(!H || !H_squad || H_squad != current_squad || H.z == 0) continue
						var/area/A = get_area(H)
						var/mob_state = ""
						var/role = ""
						var/dist = 0

						if(current_squad.squad_leader)
							if(H.z == current_squad.squad_leader.z && H.z != 0)
								dist = get_dist(H,current_squad.squad_leader)
							else if (H == current_squad.squad_leader)
								dist = -2
							else
								dist = -1
						if(H.mind)
							if(H.mind.assigned_role) role = H.mind.assigned_role
						if(H.stat == CONSCIOUS) mob_state = "Conscious"
						if(H.stat == UNCONSCIOUS) mob_state = "<b>Unconscious</b>"
						if(H.stat == DEAD) mob_state = "<font color='red'>DEAD</font>"

						dat += "<tr><td>[H.name]</td><td>[role]</td><td>[mob_state]</td><td>[sanitize(A.name)]</td>"
						if(dist > -1 && H != current_squad.squad_leader)
							dat += "<td>[dist]</td></tr>"
						else if (dist == -1)
							dat += "<td>???</td></tr>"
						else if (dist == -2)
							dat += "<td><font color='red'>Leader</font></td></tr>"
					dat += "</table>"

				dat += "<BR><BR>----------------------<br>"
				dat += "<A href='?src=\ref[src];operation=refresh'>{Refresh}</a><br>"
				dat += "<A href='?src=\ref[src];operation=back'>{Back}</a></body>"
	user << browse(dat, "window=overwatch;size=500x500")
	onclose(user, "overwatch")
	return

/obj/machinery/computer/overwatch/Topic(href, href_list)
	if(..())
		return

	if(!href_list["operation"])
		return

	if((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon)))
		usr.set_machine(src)

	switch(href_list["operation"])
		// main interface
		if("back")
			src.state = 0
		if("monitor")
			src.state = 1
		if("change_operator")
			if(current_squad)
				current_squad.overwatch_officer = usr
			operator = usr
			send_to_squad("Attention - your Overwatch officer is now [operator.name].") //This checks for squad, so we don't need to.
		if("logout")
			send_to_squad("Attention - [operator.name] is no longer your Overwatch officer. Overwatch functions deactivated.")
			if(current_squad)
				current_squad.overwatch_officer = null //Reset the squad's officer.
			operator = null
			current_squad = null
			cam = null
			is_watching = 0 //Drop the camera
		if("pick_squad")
			if(operator == usr)
				if(current_squad)
					usr << "\icon[src] You are already selecting a squad. Log out first."
				else
					var/list/squad_list = list()
					var/datum/squad/selected = null
					var/name_sel = "Cancel" //default
					for(var/datum/squad/S in job_master.squads)
						if(S.usable && !S.overwatch_officer)
							squad_list += S.name

					squad_list += "Cancel"
					name_sel = input("Which squad would you like to claim for Overwatch?") as null|anything in squad_list
					if(name_sel != "Cancel" && !isnull(name_sel))
						selected = get_squad_by_name(name_sel)
						if(selected)
							selected.overwatch_officer = usr //Link everything together, squad, console, and officer
							current_squad = selected
							send_to_squad("Attention - Your squad has been selected for Overwatch. Check your Status pane for objectives.")
							send_to_squad("Your Overwatch officer is: [operator.name].")
							find_helmet_cam() //Set the helmet cam, if one is being worn by the SL
							if(!current_squad.drop_pad) //Why the hell did this not link?
								for(var/obj/item/effect/supply_drop/S in world)
									S.force_link() //LINK THEM ALL!

						else
							usr << "Not a valid squad."
		if("message")
			if(current_squad && operator == usr)
				var/input = stripped_input(usr, "Please write a message to announce to the squad:", "Squad Message")
				if(input)
					send_to_squad(input,1) //message, adds username
		if("sl_message")
			if(current_squad && operator == usr)
				var/input = stripped_input(usr, "Please write a message to announce to the squad leader:", "SL Message")
				if(input)
					send_to_squad(input,1,1) //message, adds usrname, only to leader
		if("check_primary")
			if(current_squad) //This is already checked, but ehh.
				if(current_squad.primary_objective)
					usr << "\icon[src] <b>Primary Objective:</b> [current_squad.primary_objective]"
		if("check_secondary")
			if(current_squad) //This is already checked, but ehh.
				if(current_squad.secondary_objective)
					usr << "\icon[src] <b>Secondary Objective:</b> [current_squad.secondary_objective]"
		if("set_primary")
			var/input = stripped_input(usr, "What will be the squad's primary objective?", "Primary Objective")
			if(input)
				current_squad.primary_objective = input
				send_to_squad("Your primary objective has changed. See Status pane for details.")
		if("set_secondary")
			var/input = stripped_input(usr, "What will be the squad's secondary objective?", "Secondary Objective")
			if(input)
				current_squad.secondary_objective = input
				send_to_squad("Your secondary objective has changed. See Status pane for details.")
		if("refresh")
			src.attack_hand(usr)
		if("dropsupply")
			if(current_squad)
				if(current_squad.supply_timer)
					usr << "\icon[src] Supply drop not yet available!"
				else
					if(current_squad.sbeacon)
						var/obj/structure/closet/crate/C = locate() in current_squad.drop_pad.loc
						if(C && istype(C))
							if(isturf(current_squad.sbeacon.loc))
								var/turf/T = get_turf(current_squad.sbeacon)
								if(istype(T,/turf/simulated/floor/gm))
									var/x_offset = input(usr,"X Offset","Set an X offset for the drop? (-5 to 5)","0") as num
									var/y_offset = input(usr,"Y Offset","Set a Y offset for the drop? (-5 to 5)","0") as num
									if(x_offset) x_offset = round(x_offset)
									if(y_offset) y_offset = round(y_offset) //Sanitize the values a bit, so we don't get like, 3.1415927
									if(x_offset < -5) x_offset = -5
									if(x_offset > 5) x_offset = 5
									if(y_offset < -5) y_offset = -5
									if(y_offset > 5) y_offset = 5
									x_offset += rand(-2,2) //Randomize the drop zone a little bit.
									y_offset += rand(-2,2)
									C.visible_message("The [C] begins to load into a launch tube. Stand clear!")
									current_squad.handle_stimer(5000)
									send_to_squad("Supply Drop Incoming!")
									del(current_squad.sbeacon) //Wipe the beacon. It's only good for one use.
									spawn(50)
										playsound(C.loc,'sound/effects/bamf.ogg', 100, 1)  //Ehh
										C.z = T.z
										C.x = T.x + x_offset
										C.y = T.y + x_offset
										spawn(1)
											playsound(C.loc,'sound/effects/bamf.ogg', 100, 1)  //Ehhhhhhhhh.
											C.visible_message("\icon[src] The [C] falls from the sky!")
									usr << "\icon[src] [C] launched! Another launch will be available in <b>5</b> minutes."

								else
									usr << "\icon[src] The beacon is not located outside."
							else
								usr << "\icon[src] The beacon is not on the ground!"
						else
							usr << "\icon[src] There's nothing located on the launch pad! Get Requisitions on the line!"
					else
						usr << "\icon[src] No beacon!"
		if("dropbomb")
			if(current_squad)
				if(current_squad.bomb_timer)
					usr << "\icon[src] Orbital bombardment not yet available!"
				else
					if(current_squad.bbeacon)
						if(isturf(current_squad.bbeacon.loc))
							var/turf/T = get_turf(current_squad.bbeacon)
							if(istype(T,/turf/simulated/floor/gm))
								var/x_offset = input(usr,"X Offset","Set an X offset for the bombardment? (-5 to 5)","0") as num
								var/y_offset = input(usr,"Y Offset","Set a Y offset for the bombardment? (-5 to 5)","0") as num
								if(x_offset) x_offset = round(x_offset)
								if(y_offset) y_offset = round(y_offset) //Sanitize the values a bit, so we don't get like, 3.1415927
								if(x_offset < -5) x_offset = -5
								if(x_offset > 5) x_offset = 5
								if(y_offset < -5) y_offset = -5
								if(y_offset > 5) y_offset = 5
								x_offset += rand(-3,3) //Randomize the drop zone a little bit.
								y_offset += rand(-3,3)
								usr << "\icon[src] \red FIRING!!"
								current_squad.handle_btimer(15000)
								send_to_squad("WARNING: Orbital Bombardment beginning! Get outside of Danger Close!")
								del(current_squad.bbeacon) //Wipe the beacon. It's only good for one use.
								spawn(50)
									for(var/mob/living/carbon/H in living_mob_list)
										if(H.z == src.z && !src.stat)
											H << "<span class='warning'>The deck of the Sulaco shudders as the orbital cannons fire at LV-624.</span>"
									var/turf/target = locate(T.x + x_offset,T.y + y_offset,T.z)
									if(target && istype(target))
										explosion(target, 2, 3, 4, 1) //Kaboom!
							else
								usr << "\icon[src] The beacon is not located outside."
						else
							usr << "\icon[src] The beacon is not on the ground!"
					else
						usr << "\icon[src] No beacon!"
		if("monitor")
			src.state = 1
			src.attack_hand(usr)
		if("back")
			src.state = 0
			src.attack_hand(usr)
		if("cam")
			if(current_squad)
				if(cam)
					if(is_watching)
						usr << "\icon[src] Stopping helmet cam view."
						is_watching = 0
						usr.reset_view(null)
					else
						usr << "\icon[src] Helmet camera activated."
						is_watching = 1
						check_eye(usr)
				else
					usr << "\icon[src] Searching for helmet cam.."
					find_helmet_cam()
					if(!cam)
						usr << "\icon[src] No helmet cam found for this squad! Tell your Squad Leader!"
						is_watching = 0
					else
						usr << "\icon[src] Helmet cam found and linked."
						is_watching = 1
						check_eye(usr)

//	src.updateUsrDialog()
	src.attack_hand(usr) //The above doesn't ever seem to work.


/obj/machinery/computer/overwatch/check_eye(var/mob/user as mob)
	if (user.stat || ((get_dist(user, src) > 1 || !( user.canmove ) || user.blinded) && !istype(user, /mob/living/silicon))) //user can't see - not sure why canmove is here.
		is_watching = 0
		user.unset_machine()
	else
		if ( !src.cam || !src.cam.can_use() ) //camera doesn't work or is gone
			is_watching = 0
			user.unset_machine()

	if(is_watching)
		user.reset_view(cam)
	else
		user.reset_view(null) //Stop the camera if they move away.
	return 1

/obj/machinery/computer/overwatch/proc/switch_to_camera(var/mob/user, var/obj/machinery/camera/C)
	if (!C.can_use() || user.stat || (get_dist(user, src) > 1 || user.machine != src || user.blinded || !( user.canmove ) && !istype(user, /mob/living/silicon)))
		return 0
	src.cam = C
	return 1

/obj/machinery/computer/overwatch/proc/find_helmet_cam()
	if(current_squad && !cam) //Look for a cam if we don't have one already.
		if(current_squad.squad_leader) //Link the camera, if any.
			var/mob/living/carbon/human/L = current_squad.squad_leader
			if(L && istype(L) && istype(L.head,/obj/item/clothing/head/helmet/marine2/leader))
				var/obj/item/clothing/head/helmet/marine2/leader/helm = L.head
				if(helm.camera)
					cam = helm.camera //Found and linked.
					return

//Sends a string to our currently selected squad.
/obj/machinery/computer/overwatch/proc/send_to_squad(var/txt = "", var/plus_name = 0, var/only_leader = 0)
	if(txt == "" || !current_squad || !operator) return //Logic

	var/text = sanitize(txt)
	var/nametext = ""
	if(plus_name)
		nametext = "[usr.name] transmits: "

	for(var/mob/living/carbon/human/M in living_mob_list)
		if(M && istype(M) && !M.stat && M.client && M.mind && M.mind.assigned_squad == current_squad) //Only living and connected people in our squad
			if(!only_leader)
				M << "\icon[src] <font color='blue'><B>\[Overwatch\]:</b> [nametext][text]</font>"
			else
				if(is_leader_from_card(M))
					M << "\icon[src] <font color='blue'><B>\[SL Overwatch\]:</b> [nametext][text]</font>"

/obj/item/effect/supply_drop
	name = "Supply Drop Pad"
	desc = "Place a crate on here to allow bridge Overwatch officers to drop them on people's heads."
	icon = 'icons/effects/warning_stripes.dmi'
	anchored = 1
	density = 0
	unacidable = 1
	var/squad = "Alpha"
	var/sending_package = 0

	New() //Link a squad to a drop pad
		..()
		spawn(10)
			force_link()

	proc/force_link() //Somehow, it didn't get set properly on the new proc. Force it again,
		var/datum/squad/S = get_squad_by_name(squad)
		if(S)
			S.drop_pad = src
		else
			world << "Alert! Supply drop pads did not initialize properly."

/obj/item/effect/supply_drop/alpha
	icon_state = "alphadrop"
	squad = "Alpha"

/obj/item/effect/supply_drop/bravo
	icon_state = "bravodrop"
	squad = "Bravo"

/obj/item/effect/supply_drop/charlie
	icon_state = "charliedrop"
	squad = "Charlie"

/obj/item/effect/supply_drop/delta
	icon_state = "deltadrop"
	squad = "Delta"
