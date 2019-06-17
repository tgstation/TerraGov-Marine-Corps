#define OW_MAIN 0
#define OW_MONITOR 1
#define OW_SUPPLIES 2

#define MAX_SUPPLY_DROPS 4

#define HIDE_NONE 0
#define HIDE_ON_GROUND 1
#define HIDE_ON_SHIP 2

/obj/machinery/computer/camera_advanced/overwatch
	name = "Overwatch Console"
	desc = "State of the art machinery for giving orders to a squad."
	density = FALSE
	icon_state = "overwatch"
	req_access = list(ACCESS_MARINE_BRIDGE)
	networks = list("marine")
	open_prompt = FALSE

	var/state = OW_MAIN
	var/x_offset_s = 0
	var/y_offset_s = 0
	var/living_marines_sorting = FALSE
	var/busy = FALSE //The overwatch computer is busy launching an OB/SB, lock controls
	var/dead_hidden = FALSE //whether or not we show the dead marines in the squad.
	var/z_hidden = 0 //which z level is ignored when showing marines.
	var/squad_console = NO_SQUAD //Is this associated to a specific squad?
	var/datum/squad/current_squad = null //Squad being currently overseen
	var/list/squads = list() //All the squads available
	var/obj/selected_target //Selected target for bombarding
//	var/console_locked = 0

/obj/machinery/computer/camera_advanced/overwatch/main
	icon_state = "overwatch_main"
	name = "Main Overwatch Console"
	desc = "State of the art machinery for general overwatch purposes."

/obj/machinery/computer/camera_advanced/overwatch/alpha
	name = "Alpha Overwatch Console"
	squad_console = ALPHA_SQUAD

/obj/machinery/computer/camera_advanced/overwatch/bravo
	name = "Bravo Overwatch Console"
	squad_console = BRAVO_SQUAD

/obj/machinery/computer/camera_advanced/overwatch/charlie
	name = "Charlie Overwatch Console"
	squad_console = CHARLIE_SQUAD

/obj/machinery/computer/camera_advanced/overwatch/delta
	name = "Delta Overwatch Console"
	squad_console = DELTA_SQUAD

/obj/machinery/computer/camera_advanced/overwatch/attackby(obj/item/I, mob/user, params)
	return

/obj/machinery/computer/camera_advanced/overwatch/bullet_act(var/obj/item/projectile/Proj) //Can't shoot it
	return FALSE

/obj/machinery/computer/camera_advanced/overwatch/attack_ai(var/mob/user as mob)
	return attack_hand(user)


/obj/machinery/computer/camera_advanced/overwatch/attack_paw(var/mob/user as mob) //why monkey why
	return attack_hand(user)


/obj/machinery/computer/camera_advanced/overwatch/CreateEye()
	. = ..()
	eyeobj.visible_icon = TRUE
	eyeobj.icon = 'icons/mob/cameramob.dmi'
	eyeobj.icon_state = "generic_camera"


/obj/machinery/computer/camera_advanced/overwatch/attack_hand(mob/user)
	. = ..()
	if(.)  //Checks for power outages
		return
	if(!allowed(user))
		to_chat(user, "<span class='warning'>You don't have access.</span>")
		return
	if(!length(squads))
		for(var/i in SSjob.squads)
			var/datum/squad/S = SSjob.squads[i]
			squads += S
	if(!current_squad && !(current_squad = get_squad_by_id(squad_console)))
		to_chat(user, "<span class='warning'>Error: Unable to link to a proper squad.</span>")
		return
	user.set_interaction(src)
	var/dat
	if(!operator)
		dat += "<BR><B>Operator:</b> <A href='?src=\ref[src];operation=change_operator'>----------</A><BR>"
	else
		dat += "<BR><B>Operator:</b> <A href='?src=\ref[src];operation=change_operator'>[operator.name]</A><BR>"
		dat += "   <A href='?src=\ref[src];operation=logout'>{Stop Overwatch}</A><BR>"
		dat += "----------------------<br>"
		switch(state)
			if(OW_MAIN)
				if(!current_squad) //No squad has been set yet. Pick one.
					dat += "<br>Current Squad: <A href='?src=\ref[src];operation=pick_squad'>----------</A><BR>"
				else
					dat += "<br><b>[current_squad.name] Squad</A></b>   "
					dat += "<A href='?src=\ref[src];operation=message'>\[Message Squad\]</a><br><br>"
					dat += "----------------------<BR><BR>"
					if(current_squad.squad_leader)
						dat += "<B>Squad Leader:</B> <A href='?src=\ref[src];operation=use_cam;cam_target=\ref[current_squad.squad_leader]'>[current_squad.squad_leader.name]</a> "
						dat += "<A href='?src=\ref[src];operation=sl_message'>\[MSG\]</a> "
						dat += "<A href='?src=\ref[src];operation=change_lead'>\[CHANGE SQUAD LEADER\]</a><BR><BR>"
					else
						dat += "<B>Squad Leader:</B> <font color=red>NONE</font> <A href='?src=\ref[src];operation=change_lead'>\[ASSIGN SQUAD LEADER\]</a><BR><BR>"

					dat += "<B>Primary Objective:</B> "
					if(current_squad.primary_objective)
						dat += "[current_squad.primary_objective] <a href='?src=\ref[src];operation=set_primary'>\[Set\]</a><br>"
					else
						dat += "<b><font color=red>NONE!</font></b> <a href='?src=\ref[src];operation=set_primary'>\[Set\]</a><br>"
					dat += "<b>Secondary Objective:</b> "
					if(current_squad.secondary_objective)
						dat += "[current_squad.secondary_objective] <a href='?src=\ref[src];operation=set_secondary'>\[Set\]<br></a>"
					else
						dat += "<b><font color=red>NONE!</font></b> <a href='?src=\ref[src];operation=set_secondary'>\[Set\]<br></a>"
					dat += "<br>"
					dat += "<A href='?src=\ref[src];operation=insubordination'>Report a marine for insubordination</a><BR>"
					dat += "<A href='?src=\ref[src];operation=squad_transfer'>Transfer a marine to another squad</a><BR><BR>"
					dat += "<a href='?src=\ref[src];operation=supplies'>Supply Drop Control</a><br>"
					dat += "<a href='?src=\ref[src];operation=monitor'>Squad Monitor</a><br>"
					dat += "----------------------<br>"
					dat += "<b>Rail Gun Control</b><br>"
					dat += "<b>Current Rail Gun Status:</b> "
					var/cooldown_left = (almayer_rail_gun.last_firing + 600) - world.time // 60 seconds between shots
					if(cooldown_left > 0)
						dat += "Rail Gun on cooldown ([round(cooldown_left/10)] seconds)<br>"
					else if(!almayer_rail_gun.rail_gun_ammo?.ammo_count)
						dat += "<font color='red'>Ammo depleted.</font><br>"
					else
						dat += "<font color='green'>Ready!</font><br>"
					dat += "<B>[current_squad.name] Laser Targets:</b><br>"
					if(active_laser_targets.len)
						for(var/obj/effect/overlay/temp/laser_target/LT in current_squad.squad_laser_targets)
							if(!istype(LT))
								continue
							dat += "<a href='?src=\ref[src];operation=use_cam;cam_target=\ref[LT];selected_target=\ref[LT]'>[LT.name]</a><br>"
					else
						dat += "<span class='warning'>None</span><br>"
					dat += "<B>[current_squad.name] Beacon Targets:</b><br>"
					if(active_orbital_beacons.len)
						for(var/obj/item/squad_beacon/bomb/OB in current_squad.squad_orbital_beacons)
							if(!istype(OB))
								continue
							dat += "<a href='?src=\ref[src];operation=use_cam;cam_target=\ref[OB];selected_target=\ref[OB]'>[OB.name]</a><br>"
					else
						dat += "<span class='warning'>None transmitting</span><br>"
					dat += "<b>Selected Target:</b><br>"
					if(!selected_target) // Clean the targets if nothing is selected
						dat += "<span class='warning'>None</span><br>"
					else if(!(selected_target in active_laser_targets) && !(selected_target in active_orbital_beacons)) // Or available
						dat += "<span class='warning'>None</span><br>"
						selected_target = null
					else
						dat += "<font color='green'>[selected_target.name]</font><br>"
					dat += "<A href='?src=\ref[src];operation=shootrailgun'>\[FIRE!\]</a><br>"
					dat += "----------------------<br>"
					dat += "<br><br><a href='?src=\ref[src];operation=refresh'>{Refresh}</a>"
			if(OW_MONITOR)//Info screen.
				dat += get_squad_info()
			if(OW_SUPPLIES)
				dat += "<BR><B>Supply Drop Control</B><BR><BR>"
				if(!current_squad)
					dat += "No squad selected!"
				else
					dat += "<B>Current Supply Drop Status:</B> "
					var/cooldown_left = (current_squad.supply_cooldown + 5000) - world.time
					if(cooldown_left > 0)
						dat += "Launch tubes resetting ([round(cooldown_left/10)] seconds)<br>"
					else
						dat += "<font color='green'>Ready!</font><br>"
					dat += "<B>Launch Pad Status:</b> "
					var/can_supply = FALSE
					for(var/obj/C in current_squad.drop_pad.loc) //This thing should ALWAYS exist.
						if(is_type_in_typecache(C, GLOB.supply_drops) && !C.anchored) //Can only send supply droppable items
							can_supply = TRUE
							break
					if(can_supply)
						dat += "<font color='green'>Supply drop loaded</font><BR>"
					else
						dat += "Empty<BR>"
					dat += "<B>Supply Beacon Status:</b> "
					if(current_squad.sbeacon)
						if(isturf(current_squad.sbeacon.loc))
							dat += "<font color='green'>Transmitting!</font><BR>"
						else
							dat += "Not Transmitting<BR>"
					else
						dat += "Not Transmitting<BR>"
					dat += "<B>X-Coordinate Offset:</B> [x_offset_s] <A href='?src=\ref[src];operation=supply_x'>\[Change\]</a><BR>"
					dat += "<B>Y-Coordinate Offset:</B> [y_offset_s] <A href='?src=\ref[src];operation=supply_y'>\[Change\]</a><BR><BR>"
					dat += "<A href='?src=\ref[src];operation=dropsupply'>\[LAUNCH!\]</a>"
				dat += "<BR><BR>----------------------<br>"
				dat += "<A href='?src=\ref[src];operation=refresh'>{Refresh}</a><br>"
				dat += "<A href='?src=\ref[src];operation=back'>{Back}</a>"

	var/datum/browser/popup = new(user, "squad_overwatch", "<div align='center'>[current_squad.name] Overwatch Console</div>", 550, 550)
	popup.set_content(dat)
	popup.open(FALSE)
	onclose(user, "squad_overwatch")


/obj/machinery/computer/camera_advanced/overwatch/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(!href_list["operation"])
		return

	if((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))) || (issilicon(usr)))
		usr.set_interaction(src)

	switch(href_list["operation"])
		// main interface
		if("back")
			state = OW_MAIN
		if("monitor")
			state = OW_MONITOR
		if("monitor1")
			state = OW_MONITOR
			current_squad = get_squad_by_id(ALPHA_SQUAD)
		if("monitor2")
			state = OW_MONITOR
			current_squad = get_squad_by_id(BRAVO_SQUAD)
		if("monitor3")
			state = OW_MONITOR
			current_squad = get_squad_by_id(CHARLIE_SQUAD)
		if("monitor4")
			state = OW_MONITOR
			current_squad = get_squad_by_id(DELTA_SQUAD)
		if("supplies")
			state = OW_SUPPLIES
		if("change_operator")
			if(operator != usr)
				if(current_squad)
					current_squad.overwatch_officer = usr
				operator = usr
				var/mob/living/carbon/human/H = operator
				var/obj/item/card/id/ID = H.get_idcard()
				visible_message("<span class='boldnotice'>Basic overwatch systems initialized. Welcome, [ID ? "[ID.rank] ":""][operator.name]. Please select a squad.</span>")
				current_squad?.message_squad("Attention. Your Overwatch officer is now [ID ? "[ID.rank] ":""][operator.name].")
		if("change_main_operator")
			if(operator != usr)
				operator = usr
				var/mob/living/carbon/human/H = operator
				var/obj/item/card/id/ID = H.get_idcard()
				visible_message("<span class='boldnotice'>Main overwatch systems initialized. Welcome, [ID ? "[ID.rank] ":""][operator.name].</span>")
		if("logout")
			if(current_squad)
				current_squad.overwatch_officer = null //Reset the squad's officer.
			var/mob/living/carbon/human/H = operator
			var/obj/item/card/id/ID = H.get_idcard()
			current_squad?.message_squad("Attention. [ID ? "[ID.rank] ":""][operator ? "[operator.name]":"sysadmin"] is no longer your Overwatch officer. Overwatch functions deactivated.")
			visible_message("<span class='boldnotice'>Overwatch systems deactivated. Goodbye, [ID ? "[ID.rank] ":""][operator ? "[operator.name]":"sysadmin"].</span>")
			operator = null
			current_squad = null
			state = OW_MAIN
		if("logout_main")
			var/mob/living/carbon/human/H = operator
			var/obj/item/card/id/ID = H.get_idcard()
			visible_message("<span class='boldnotice'>Main overwatch systems deactivated. Goodbye, [ID ? "[ID.rank] ":""][operator ? "[operator.name]":"sysadmin"].</span>")
			operator = null
			current_squad = null
			selected_target = null
			state = OW_MAIN
		if("pick_squad")
			if(operator == usr)
				if(current_squad)
					to_chat(usr, "<span class='warning'>[icon2html(src, usr)] You are already selecting a squad.</span>")
				else
					var/list/squad_choices = list()
					for(var/i in SSjob.squads)
						var/datum/squad/S = SSjob.squads[i]
						if(!S.overwatch_officer)
							squad_choices += S.name

					var/squad_name = input("Which squad would you like to claim for Overwatch?") as null|anything in squad_choices
					if(!squad_name || operator != usr)
						return
					if(current_squad)
						to_chat(usr, "<span class='warning'>[icon2html(src, usr)] You are already selecting a squad.</span>")
						return
					var/datum/squad/selected = SSjob.squads[squad_name]
					if(selected)
						selected.overwatch_officer = usr //Link everything together, squad, console, and officer
						current_squad = selected
						current_squad.message_squad("Attention - Your squad has been selected for Overwatch. Check your Status pane for objectives.")
						current_squad.message_squad("Your Overwatch officer is: [operator.name].")
						visible_message("<span class='boldnotice'>Tactical data for squad '[current_squad]' loaded. All tactical functions initialized.</span>")
						attack_hand(usr)
						if(!current_squad.drop_pad) //Why the hell did this not link?
							for(var/obj/structure/supply_drop/S in GLOB.item_list)
								S.force_link() //LINK THEM ALL!

					else
						to_chat(usr, "[icon2html(src, usr)] <span class='warning'>Invalid input. Aborting.</span>")
		if("message")
			if(current_squad && operator == usr)
				var/input = stripped_input(usr, "Please write a message to announce to the squad:", "Squad Message")
				if(input)
					current_squad.message_squad(input, usr) //message, adds username
					visible_message("<span class='boldnotice'>Message sent to all Marines of squad '[current_squad]'.</span>")
		if("sl_message")
			if(current_squad && operator == usr)
				var/input = stripped_input(usr, "Please write a message to announce to the squad leader:", "SL Message")
				if(input)
					current_squad.message_leader(input, usr)
					visible_message("<span class='boldnotice'>Message sent to Squad Leader [current_squad.squad_leader] of squad '[current_squad]'.</span>")
		if("set_primary")
			var/input = stripped_input(usr, "What will be the squad's primary objective?", "Primary Objective")
			if(input)
				current_squad.primary_objective = input + " ([worldtime2text()])"
				current_squad.message_squad("Your primary objective has changed. See Status pane for details.")
				visible_message("<span class='boldnotice'>Primary objective of squad '[current_squad]' set.</span>")
		if("set_secondary")
			var/input = stripped_input(usr, "What will be the squad's secondary objective?", "Secondary Objective")
			if(input)
				current_squad.secondary_objective = input + " ([worldtime2text()])"
				current_squad.message_squad("Your secondary objective has changed. See Status pane for details.")
				visible_message("<span class='boldnotice'>Secondary objective of squad '[current_squad]' set.</span>")
		if("supply_x")
			var/input = input(usr,"What X-coordinate offset between -5 and 5 would you like? (Positive means east)","X Offset",0) as num
			input = CLAMP(round(input), -5, 5)
			to_chat(usr, "[icon2html(src, usr)] <span class='notice'>X-offset is now [input].</span>")
			x_offset_s = input
		if("supply_y")
			var/input = input(usr,"What Y-coordinate offset between -5 and 5 would you like? (Positive means north)","Y Offset",0) as num
			input = CLAMP(round(input), -5, 5)
			to_chat(usr, "[icon2html(src, usr)] <span class='notice'>Y-offset is now [input].</span>")
			y_offset_s = input
		if("refresh")
			attack_hand(usr)
		if("change_sort")
			living_marines_sorting = !living_marines_sorting
			if(living_marines_sorting)
				to_chat(usr, "[icon2html(src, usr)] <span class='notice'>Marines are now sorted by health status.</span>")
			else
				to_chat(usr, "[icon2html(src, usr)] <span class='notice'>Marines are now sorted by rank.</span>")
		if("hide_dead")
			dead_hidden = !dead_hidden
			if(dead_hidden)
				to_chat(usr, "[icon2html(src, usr)] <span class='notice'>Dead marines are now not shown.</span>")
			else
				to_chat(usr, "[icon2html(src, usr)] <span class='notice'>Dead marines are now shown again.</span>")
		if("choose_z")
			switch(z_hidden)
				if(HIDE_NONE)
					z_hidden = HIDE_ON_SHIP
					to_chat(usr, "[icon2html(src, usr)] <span class='notice'>Marines on the [CONFIG_GET(string/ship_name)] are now hidden.</span>")
				if(HIDE_ON_SHIP)
					z_hidden = HIDE_ON_GROUND
					to_chat(usr, "[icon2html(src, usr)] <span class='notice'>Marines on the ground are now hidden.</span>")
				if(HIDE_ON_GROUND)
					z_hidden = HIDE_NONE
					to_chat(usr, "[icon2html(src, usr)] <span class='notice'>No location is ignored anymore.</span>")

		if("change_lead")
			change_lead()
		if("insubordination")
			mark_insubordination()
		if("squad_transfer")
			transfer_squad()
		if("dropsupply")
			if(current_squad)
				if((current_squad.supply_cooldown + 5 MINUTES) > world.time)
					to_chat(usr, "[icon2html(src, usr)] <span class='warning'>Supply drop not yet available!</span>")
				else
					handle_supplydrop()
		if("dropbomb")
			if((almayer_orbital_cannon.last_orbital_firing + 5000) > world.time)
				to_chat(usr, "[icon2html(src, usr)] <span class='warning'>Orbital bombardment not yet available!</span>")
			else
				handle_bombard()
		if("shootrailgun")
			if((almayer_rail_gun.last_firing + 600) > world.time)
				to_chat(usr, "[icon2html(src, usr)] <span class='warning'>The Rail Gun hasn't cooled down yet!</span>")
			else if(!selected_target)
				to_chat(usr, "[icon2html(src, usr)] <span class='warning'>No target detected!</span>")
			else
				almayer_rail_gun.fire_rail_gun(get_turf(selected_target),usr)
		if("back")
			state = OW_MAIN
		if("use_cam")
			if(isAI(usr))
				return
			var/atom/cam_target = locate(href_list["cam_target"])
			open_prompt(usr)
			eyeobj.setLoc(get_turf(cam_target))
			to_chat(usr, "[icon2html(src, usr)] <span class='notice'>Jumping to the latest available location of [cam_target].</span>")

	updateUsrDialog()

/obj/machinery/computer/camera_advanced/overwatch/main/attack_hand(mob/user)
	. = ..()
	if(.)  //Checks for power outages
		return
	if(!allowed(user))
		to_chat(user, "<span class='warning'>You don't have access.</span>")
		return
	if(!length(squads))
		for(var/i in SSjob.squads)
			var/datum/squad/S = SSjob.squads[i]
			squads += S
	user.set_interaction(src)
	var/dat
	if(!operator)
		dat += "<B>Main Operator:</b> <A href='?src=\ref[src];operation=change_main_operator'>----------</A><BR>"
	else
		dat += "<B>Main Operator:</b> <A href='?src=\ref[src];operation=change_main_operator'>[operator.name]</A><BR>"
		dat += "   <A href='?src=\ref[src];operation=logout_main'>{Stop Overwatch}</A><BR>"
		dat += "----------------------<br>"
		switch(state)
			if(OW_MAIN)
				for(var/datum/squad/S in squads)
					dat += "<b>[S.name] Squad</b> <a href='?src=\ref[src];operation=message;current_squad=\ref[S]'>\[Message Squad\]</a><br>"
					if(S.squad_leader)
						dat += "<b>Leader:</b> <a href='?src=\ref[src];operation=use_cam;cam_target=\ref[S.squad_leader]'>[S.squad_leader.name]</a> "
						dat += "<a href='?src=\ref[src];operation=sl_message;current_squad=\ref[S]'>\[MSG\]</a><br>"
					else
						dat += "<b>Leader:</b> <font color=red>NONE</font><br>"
					if(S.overwatch_officer)
						dat += "<b>Squad Overwatch:</b> [S.overwatch_officer.name]<br>"
					else
						dat += "<b>Squad Overwatch:</b> <font color=red>NONE</font><br>"
					dat += "<A href='?src=\ref[src];operation=monitor[S.id]'>[S.name] Squad Monitor</a><br>"
				dat += "----------------------<br>"
				dat += "<b>Orbital Bombardment Control</b><br>"
				dat += "<b>Current Cannon Status:</b> "
				var/cooldown_left = (almayer_orbital_cannon.last_orbital_firing + 5000) - world.time
				if(cooldown_left > 0)
					dat += "Cannon on cooldown ([round(cooldown_left/10)] seconds)<br>"
				else if(!almayer_orbital_cannon.chambered_tray)
					dat += "<font color='red'>No ammo chambered in the cannon.</font><br>"
				else
					dat += "<font color='green'>Ready!</font><br>"
				dat += "<B>Laser Targets:</b><br>"
				if(active_laser_targets.len)
					for(var/obj/effect/overlay/temp/laser_target/LT in active_laser_targets)
						if(!istype(LT))
							continue
						dat += "<a href='?src=\ref[src];operation=use_cam;cam_target=\ref[LT];selected_target=\ref[LT]'>[LT.name]</a><br>"
				else
					dat += "<span class='warning'>None</span><br>"
				dat += "<B>Beacon Targets:</b><br>"
				if(active_orbital_beacons.len)
					for(var/obj/item/squad_beacon/bomb/OB in active_orbital_beacons)
						if(!istype(OB))
							continue
						dat += "<a href='?src=\ref[src];operation=use_cam;cam_target=\ref[OB];selected_target=\ref[OB]'>[OB.name]</a><br>"
				else
					dat += "<span class='warning'>None transmitting</span><br>"
				dat += "<b>Selected Target:</b><br>"
				if(!selected_target) // Clean the targets if nothing is selected
					dat += "<span class='warning'>None</span><br>"
				else if(!(selected_target in active_laser_targets) && !(selected_target in active_orbital_beacons)) // Or available
					dat += "<span class='warning'>None</span><br>"
					selected_target = null
				else
					dat += "<font color='green'>[selected_target.name]</font><br>"
				dat += "<A href='?src=\ref[src];operation=dropbomb'>\[FIRE!\]</a><br>"
				dat += "----------------------<BR>"
				dat += "<A href='?src=\ref[src];operation=refresh'>{Refresh}</a>"
			if(OW_MONITOR)//Info screen.
				dat += get_squad_info()

	var/datum/browser/popup = new(user, "main_overwatch", "<div align='center'>Main Overwatch Console</div>", 550, 550)
	popup.set_content(dat)
	popup.open(FALSE)
	onclose(user, "main_overwatch")


/obj/machinery/computer/camera_advanced/overwatch/proc/send_to_squads(txt)
	for(var/datum/squad/S in squads)
		S.message_squad(txt)

/obj/machinery/computer/camera_advanced/overwatch/proc/handle_bombard()
	if(!usr)
		return
	if(busy)
		to_chat(usr, "[icon2html(src, usr)] <span class='warning'>The [name] is busy processing another action!</span>")
		return
	if(!almayer_orbital_cannon.chambered_tray)
		to_chat(usr, "[icon2html(src, usr)] <span class='warning'>The orbital cannon has no ammo chambered.</span>")
		return
	if(!selected_target)
		to_chat(usr, "[icon2html(src, usr)] <span class='warning'>No target detected!</span>")
		return
	var/area/A = get_area(selected_target)
	if(istype(A) && A.ceiling >= CEILING_DEEP_UNDERGROUND)
		to_chat(usr, "[icon2html(src, usr)] <span class='warning'>The target's signal is too weak.</span>")
		return
	var/turf/T = get_turf(selected_target)
	if(isspaceturf(T))
		to_chat(usr, "[icon2html(src, usr)] <span class='warning'>The target's landing zone appears to be out of bounds.</span>")
		return
	busy = TRUE //All set, let's do this.
	if(A)
		log_attack("[key_name(usr)] fired an orbital bombardment in for squad [current_squad] in [AREACOORD(T)].")
		message_admins("[ADMIN_TPMONTY(usr)] fired an orbital bombardment for squad [current_squad] in [ADMIN_VERBOSEJMP(T)].")
	visible_message("<span class='boldnotice'>Orbital bombardment request accepted. Orbital cannons are now calibrating.</span>")
	send_to_squads("Initializing fire coordinates...")
	if(selected_target)
		playsound(selected_target.loc,'sound/effects/alert.ogg', 50, 1, 20)  //Placeholder
	addtimer(CALLBACK(src, .send_to_squads, "Transmitting beacon feed..."), 1.5 SECONDS)
	addtimer(CALLBACK(src, .send_to_squads, "Calibrating trajectory window..."), 3 SECONDS)
	addtimer(CALLBACK(src, .do_fire_bombard, T, usr), 4.1 SECONDS)

/obj/machinery/computer/camera_advanced/overwatch/proc/do_fire_bombard(var/turf/T, var/user)
	visible_message("<span class='boldnotice'>Orbital bombardment has fired! Impact imminent!</span>")
	send_to_squads("WARNING! Ballistic trans-atmospheric launch detected! Get outside of Danger Close!")
	addtimer(CALLBACK(src, .do_land_bombard, T, user), 2.5 SECONDS)

/obj/machinery/computer/camera_advanced/overwatch/proc/do_land_bombard(var/turf/T, var/user)
	busy = FALSE
	var/x_offset = rand(-2,2) //Little bit of randomness.
	var/y_offset = rand(-2,2)
	var/turf/target = locate(T.x + x_offset,T.y + y_offset,T.z)
	if(target && istype(target))
		target.ceiling_debris_check(5)
		almayer_orbital_cannon.fire_ob_cannon(target,user)

/obj/machinery/computer/camera_advanced/overwatch/proc/change_lead()
	if(!usr || usr != operator)
		return
	if(!current_squad)
		to_chat(usr, "[icon2html(src, usr)] <span class='warning'>No squad selected!</span>")
		return
	var/sl_candidates = list()
	for(var/mob/living/carbon/human/H in current_squad.get_all_members())
		if(istype(H) && H.stat != DEAD && H.mind && !jobban_isbanned(H, "Squad Leader") && !is_banned_from(H.ckey, "Squad Leader"))
			sl_candidates += H
	var/new_lead = input(usr, "Choose a new Squad Leader") as null|anything in sl_candidates
	if(!new_lead || new_lead == "Cancel") return
	var/mob/living/carbon/human/H = new_lead
	if(!istype(H) || !H.mind || H.stat == DEAD) //marines_list replaces mob refs of gibbed marines with just a name string
		to_chat(usr, "[icon2html(src, usr)] <span class='warning'>[H] is KIA!</span>")
		return
	if(H == current_squad.squad_leader)
		to_chat(usr, "[icon2html(src, usr)] <span class='warning'>[H] is already the Squad Leader!</span>")
		return
	if(jobban_isbanned(H, "Squad Leader") || is_banned_from(H.ckey, "Squad Leader"))
		to_chat(usr, "[icon2html(src, usr)] <span class='warning'>[H] is unfit to lead!</span>")
		return
	if(current_squad.squad_leader)
		current_squad.message_squad("Attention: [current_squad.squad_leader] is [current_squad.squad_leader.stat == DEAD ? "stepping down" : "demoted"]. A new Squad Leader has been set: [H.real_name].")
		visible_message("<span class='boldnotice'>Squad Leader [current_squad.squad_leader] of squad '[current_squad]' has been [current_squad.squad_leader.stat == DEAD ? "replaced" : "demoted and replaced"] by [H.real_name]! Logging to enlistment files.</span>")
		current_squad.demote_squad_leader(current_squad.squad_leader.stat != DEAD)
	else
		current_squad.message_squad("Attention: A new Squad Leader has been set: [H.real_name].")
		visible_message("<span class='boldnotice'>[H.real_name] is the new Squad Leader of squad '[current_squad]'! Logging to enlistment file.</span>")

	to_chat(H, "[icon2html(src, H)] <font size='3' color='blue'><B>\[Overwatch\]: You've been promoted to \'[H.mind.assigned_role == "Squad Leader" ? "SQUAD LEADER" : "ACTING SQUAD LEADER"]\' for [current_squad.name]. Your headset has access to the command channel (:v).</B></font>")
	to_chat(usr, "[icon2html(src, usr)] [H.real_name] is [current_squad]'s new leader!")
	current_squad.squad_leader = H
	SSdirection.set_leader(current_squad.tracking_id, H)
	SSdirection.start_tracking("marine-sl", H)

	if(H.mind.assigned_role == "Squad Leader")
		H.mind.comm_title = "SL"
	else
		H.mind.comm_title = "aSL"
	if(H.mind.cm_skills)
		H.mind.cm_skills.leadership = max(SKILL_LEAD_TRAINED, H.mind.cm_skills.leadership)
		H.update_action_buttons()

	if(istype(H.wear_ear, /obj/item/radio/headset/almayer/marine))
		var/obj/item/radio/headset/almayer/marine/R = H.wear_ear
		if(!R.keyslot)
			R.keyslot = new /obj/item/encryptionkey/squadlead (src)
		else if(!R.keyslot2)
			R.keyslot2 = new /obj/item/encryptionkey/squadlead (src)
		R.recalculateChannels()
	if(istype(H.wear_id, /obj/item/card/id))
		var/obj/item/card/id/ID = H.wear_id
		ID.access += list(ACCESS_MARINE_LEADER, ACCESS_MARINE_DROPSHIP)
	H.hud_set_squad()
	H.update_inv_head() //updating marine helmet leader overlays
	H.update_inv_wear_suit()

/obj/machinery/computer/camera_advanced/overwatch/proc/mark_insubordination()
	if(!usr || usr != operator)
		return
	if(!current_squad)
		to_chat(usr, "[icon2html(src, usr)] <span class='warning'>No squad selected!</span>")
		return
	var/mob/living/carbon/human/wanted_marine = input(usr, "Report a marine for insubordination") as null|anything in current_squad.get_all_members()
	if(!wanted_marine) return
	if(!istype(wanted_marine))//gibbed/deleted, all we have is a name.
		to_chat(usr, "[icon2html(src, usr)] <span class='warning'>[wanted_marine] is missing in action.</span>")
		return

	for (var/datum/data/record/E in GLOB.datacore.general)
		if(E.fields["name"] == wanted_marine.real_name)
			for (var/datum/data/record/R in GLOB.datacore.security)
				if (R.fields["id"] == E.fields["id"])
					if(!findtext(R.fields["ma_crim"],"Insubordination."))
						R.fields["criminal"] = "*Arrest*"
						if(R.fields["ma_crim"] == "None")
							R.fields["ma_crim"]	= "Insubordination."
						else
							R.fields["ma_crim"] += "Insubordination."
						visible_message("<span class='boldnotice'>[wanted_marine] has been reported for insubordination. Logging to enlistment file.</span>")
						to_chat(wanted_marine, "[icon2html(src, wanted_marine)] <font size='3' color='blue'><B>\[Overwatch\]:</b> You've been reported for insubordination by your overwatch officer.</font>")
						wanted_marine.sec_hud_set_security_status()
					return

/obj/machinery/computer/camera_advanced/overwatch/proc/transfer_squad()
	if(!usr || usr != operator)
		return
	if(!current_squad)
		to_chat(usr, "[icon2html(src, usr)] <span class='warning'>No squad selected!</span>")
		return
	var/datum/squad/S = current_squad
	var/mob/living/carbon/human/transfer_marine = input(usr, "Choose marine to transfer") as null|anything in current_squad.get_all_members()
	if(!transfer_marine)
		return
	if(S != current_squad)
		return //don't change overwatched squad, idiot.

	if(!istype(transfer_marine) || !transfer_marine.mind || transfer_marine.stat == DEAD) //gibbed, decapitated, dead
		to_chat(usr, "[icon2html(src, usr)] <span class='warning'>[transfer_marine] is KIA.</span>")
		return

	if(!istype(transfer_marine.wear_id, /obj/item/card/id))
		to_chat(usr, "[icon2html(src, usr)] <span class='warning'>Transfer aborted. [transfer_marine] isn't wearing an ID.</span>")
		return

	var/choice = input(usr, "Choose the marine's new squad") as null|anything in SSjob.squads
	if(!choice)
		return
	if(S != current_squad)
		return
	var/datum/squad/new_squad = SSjob.squads[choice]

	if(!istype(transfer_marine) || !transfer_marine.mind || transfer_marine.stat == DEAD)
		to_chat(usr, "[icon2html(src, usr)] <span class='warning'>[transfer_marine] is KIA.</span>")
		return

	if(!istype(transfer_marine.wear_id, /obj/item/card/id))
		to_chat(usr, "[icon2html(src, usr)] <span class='warning'>Transfer aborted. [transfer_marine] isn't wearing an ID.</span>")
		return

	var/datum/squad/old_squad = transfer_marine.assigned_squad
	if(new_squad == old_squad)
		to_chat(usr, "[icon2html(src, usr)] <span class='warning'>[transfer_marine] is already in [new_squad]!</span>")
		return


	var/no_place = FALSE
	switch(transfer_marine.mind.assigned_role)
		if("Squad Leader")
			if(new_squad.num_leaders == new_squad.max_leaders)
				no_place = TRUE
		if("Squad Specialist")
			if(new_squad.num_specialists == new_squad.max_specialists)
				no_place = TRUE
		if("Squad Engineer")
			if(new_squad.num_engineers >= new_squad.max_engineers)
				no_place = TRUE
		if("Squad Corpsman")
			if(new_squad.num_medics >= new_squad.max_medics)
				no_place = TRUE
		if("Squad Smartgunner")
			if(new_squad.num_smartgun == new_squad.max_smartgun)
				no_place = TRUE

	if(no_place)
		to_chat(usr, "[icon2html(src, usr)] <span class='warning'>Transfer aborted. [new_squad] can't have another [transfer_marine.mind.assigned_role].</span>")
		return

	old_squad.remove_marine_from_squad(transfer_marine)
	new_squad.put_marine_in_squad(transfer_marine)

	for(var/datum/data/record/t in GLOB.datacore.general) //we update the crew manifest
		if(t.fields["name"] == transfer_marine.real_name)
			t.fields["squad"] = new_squad.name
			break

	var/obj/item/card/id/ID = transfer_marine.wear_id
	ID.assigned_fireteam = 0 //reset fireteam assignment

	//Changes headset frequency to match new squad
	var/obj/item/radio/headset/almayer/marine/H = transfer_marine.wear_ear
	if(istype(H, /obj/item/radio/headset/almayer/marine))
		H.set_frequency(new_squad.radio_freq)

	transfer_marine.hud_set_squad()
	visible_message("<span class='boldnotice'>[transfer_marine] has been transfered from squad '[old_squad]' to squad '[new_squad]'. Logging to enlistment file.</span>")
	to_chat(transfer_marine, "[icon2html(src, transfer_marine)] <font size='3' color='blue'><B>\[Overwatch\]:</b> You've been transfered to [new_squad]!</font>")


/obj/machinery/computer/camera_advanced/overwatch/proc/handle_supplydrop()
	if(!usr || usr != operator)
		return

	if(busy)
		to_chat(usr, "[icon2html(src, usr)] <span class='warning'>The [name] is busy processing another action!</span>")
		return

	if(!current_squad.sbeacon)
		to_chat(usr, "[icon2html(src, usr)] <span class='warning'>No supply beacon detected!</span>")
		return

	var/list/supplies = list()
	for(var/obj/C in current_squad.drop_pad.loc) //This thing should ALWAYS exist.
		if(is_type_in_typecache(C, GLOB.supply_drops) && !C.anchored) //Can only send vendors and crates
			supplies.Add(C)
		if(supplies.len > MAX_SUPPLY_DROPS)
			break

	if(!supplies.len)
		to_chat(usr, "[icon2html(src, usr)] <span class='warning'>No deployable object was detected on the drop pad. Get Requisitions on the line!</span>")
		return

	var/area/A = get_area(current_squad.sbeacon)
	if(A && A.ceiling >= CEILING_DEEP_UNDERGROUND)
		to_chat(usr, "[icon2html(src, usr)] <span class='warning'>The [current_squad.sbeacon.name]'s signal is too weak. It is probably deep underground.</span>")
		return

	var/turf/T = get_turf(current_squad.sbeacon)

	if(!istype(T))
		to_chat(usr, "[icon2html(src, usr)] <span class='warning'>The [current_squad.sbeacon.name] was not detected on the ground.</span>")
		return

	if(isspaceturf(T) || T.density)
		to_chat(usr, "[icon2html(src, usr)] <span class='warning'>The [current_squad.sbeacon.name]'s landing zone appears to be obstructed or out of bounds.</span>")
		return

	busy = TRUE

	var/x_offset = x_offset_s
	var/y_offset = y_offset_s
	x_offset = CLAMP(round(x_offset), -5, 5)
	y_offset = CLAMP(round(y_offset), -5, 5)

	visible_message("<span class='boldnotice'>The supply drop is now loading into the launch tube! Stand by!</span>")
	current_squad.drop_pad.visible_message("<span class='warning'>\The [current_squad.drop_pad] whirrs as it beings to load the supply drop into a launch tube. Stand clear!</span>")
	for(var/obj/C in supplies)
		C.anchored = TRUE //to avoid accidental pushes
	current_squad.message_squad("Supply Drop Incoming!")
	playsound(current_squad.drop_pad.loc,'sound/effects/bamf.ogg', 50, 1)  //Ehhhhhhhhh.
	current_squad.sbeacon.visible_message("[icon2html(current_squad.sbeacon, viewers(current_squad.sbeacon))] <span class='boldnotice'>The [current_squad.sbeacon.name] begins to beep!</span>")
	addtimer(CALLBACK(src, .proc/fire_supplydrop, current_squad, supplies, x_offset, y_offset), 10 SECONDS)

/obj/machinery/computer/camera_advanced/overwatch/proc/fire_supplydrop(datum/squad/S, list/supplies, x_offset, y_offset)
	if(QDELETED(S.sbeacon))
		to_chat(usr, "[icon2html(src, usr)] <span class='warning'>Launch aborted! Supply beacon signal lost.</span>")
		busy = FALSE
		return

	for(var/obj/C in supplies)
		if(QDELETED(C))
			supplies.Remove(C)
			continue
		if(C.loc != S.drop_pad.loc) //Crate no longer on pad somehow, abort.
			supplies.Remove(C)
			C.anchored = FALSE

	if(!supplies.len)
		to_chat(usr, "[icon2html(src, usr)] <span class='warning'>Launch aborted! No deployable object detected on the drop pad.</span>")
		busy = FALSE
		return

	S.supply_cooldown = world.time

	var/turf/T = get_turf(S.sbeacon)
	QDEL_NULL(S.sbeacon) //Wipe the beacon. It's only good for one use.
	T.visible_message("<span class='boldnotice'>A supply drop falls from the sky!</span>")
	playsound(T,'sound/effects/bamf.ogg', 50, 1)  //Ehhhhhhhhh.
	playsound(S.drop_pad.loc,'sound/effects/bamf.ogg', 50, 1)  //Ehh
	for(var/obj/C in supplies)
		C.anchored = FALSE
		var/turf/TC = locate(T.x + x_offset + rand(-2, 2), T.y + y_offset + rand(-2, 2), T.z)
		C.forceMove(TC)
		TC.ceiling_debris_check(2)
	visible_message("[icon2html(src, viewers(src))] <span class='boldnotice'>Supply drop launched! Another launch will be available in five minutes.</span>")
	busy = FALSE

/obj/structure/supply_drop
	name = "Supply Drop Pad"
	desc = "Place unanchored supplies on here to allow bridge Overwatch officers to drop them on people's heads."
	icon = 'icons/effects/warning_stripes.dmi'
	anchored = TRUE
	density = 0
	resistance_flags = UNACIDABLE
	layer = ABOVE_TURF_LAYER
	var/squad_name = "Alpha"
	var/sending_package = 0

/obj/structure/supply_drop/Initialize() //Link a squad to a drop pad
	. = ..()
	force_link()

/obj/structure/supply_drop/proc/force_link() //Somehow, it didn't get set properly on the new proc. Force it again,
	var/datum/squad/S = SSjob.squads[squad_name]
	if(S)
		S.drop_pad = src
	else
		to_chat(world, "Alert! Supply drop pads did not initialize properly.")

/obj/structure/supply_drop/alpha
	icon_state = "alphadrop"
	squad_name = "Alpha"

/obj/structure/supply_drop/bravo
	icon_state = "bravodrop"
	squad_name = "Bravo"

/obj/structure/supply_drop/charlie
	icon_state = "charliedrop"
	squad_name = "Charlie"

/obj/structure/supply_drop/delta
	icon_state = "deltadrop"
	squad_name = "Delta"

/obj/item/squad_beacon
	name = "squad supply beacon"
	desc = "A rugged, glorified laser pointer capable of sending a beam into space. Activate and throw this to call for a supply drop."
	icon_state = "motion0"
	w_class = 2
	var/activated = 0
	var/activation_time = 60
	var/datum/squad/squad = null
	var/icon_activated = "motion2"
	var/obj/machinery/camera/beacon_cam = null

/obj/item/squad_beacon/Destroy()
	if(src in active_orbital_beacons)
		active_orbital_beacons -= src
	if(squad)
		if(squad.sbeacon == src)
			squad.sbeacon = null
		if(src in squad.squad_orbital_beacons)
			squad.squad_orbital_beacons -= src
		squad = null
	if(beacon_cam)
		qdel(beacon_cam)
		beacon_cam = null
	SetLuminosity(0)
	return ..()

/obj/item/squad_beacon/attack_self(mob/user)
	if(activated)
		to_chat(user, "<span class='warning'>It's already been activated. Just leave it.</span>")
		return

	if(!ishuman(user)) return
	var/mob/living/carbon/human/H = user

	if(!user.mind)
		to_chat(user, "<span class='warning'>It doesn't seem to do anything for you.</span>")
		return

	squad = H.assigned_squad

	if(!squad)
		to_chat(user, "<span class='warning'>You need to be in a squad for this to do anything.</span>")
		return
	if(squad.sbeacon)
		to_chat(user, "<span class='warning'>Your squad already has a beacon activated.</span>")
		return
	var/area/A = get_area(user)
	if(A && istype(A) && A.ceiling >= CEILING_METAL)
		to_chat(user, "<span class='warning'>You have to be outside or under a glass ceiling to activate this.</span>")
		return

	var/delay = activation_time
	if(user.mind.cm_skills)
		delay = max(10, delay - 20*user.mind.cm_skills.leadership)

	user.visible_message("<span class='notice'>[user] starts setting up [src] on the ground.</span>",
	"<span class='notice'>You start setting up [src] on the ground and inputting all the data it needs.</span>")
	if(do_after(user, delay, TRUE, src, BUSY_ICON_GENERIC))
		squad.sbeacon = src
		user.transferItemToLoc(src, user.loc)
		activated = 1
		anchored = TRUE
		w_class = 10
		icon_state = "[icon_activated]"
		playsound(src, 'sound/machines/twobeep.ogg', 15, 1)
		user.visible_message("[user] activates [src]",
		"You activate [src]")

/obj/item/squad_beacon/bomb
	name = "orbital beacon"
	desc = "A bulky device that fires a beam up to an orbiting vessel to send local coordinates."
	icon_state = "motion4"
	w_class = 2
	activation_time = 80
	icon_activated = "motion1"

/obj/item/squad_beacon/bomb/attack_self(mob/living/carbon/human/H)
	if(!istype(H))
		return
	if(!H.mind)
		to_chat(H, "<span class='warning'>It doesn't seem to do anything for you.</span>")
		return
	activate(H)

/obj/item/squad_beacon/bomb/attack_hand(mob/living/carbon/human/H)
	if(!istype(H))
		return ..()
	if(!H.mind)
		to_chat(H, "<span class='warning'>It doesn't seem to do anything for you.</span>")
		return ..()
	if(activated)
		deactivate(H)
	else
		return ..()

/obj/item/squad_beacon/bomb/proc/activate(mob/living/carbon/human/H)
	if(!is_ground_level(H.z))
		to_chat(H, "<span class='warning'>You have to be on the planet to use this or it won't transmit.</span>")
		return
	var/area/A = get_area(H)
	if(A && istype(A) && A.ceiling >= CEILING_DEEP_UNDERGROUND)
		to_chat(H, "<span class='warning'>This won't work if you're standing deep underground.</span>")
		return
	var/delay = activation_time
	if(H.mind.cm_skills)
		delay = max(15, delay - 20*H.mind.cm_skills.leadership)
	H.visible_message("<span class='notice'>[H] starts setting up [src] on the ground.</span>",
	"<span class='notice'>You start setting up [src] on the ground and inputting all the data it needs.</span>")
	if(do_after(H, delay, TRUE, src, BUSY_ICON_GENERIC))
		message_admins("[ADMIN_TPMONTY(usr)] set up an orbital strike beacon.")
		name = "transmitting orbital beacon"
		active_orbital_beacons += src
		var/cam_name = ""
		cam_name += H.get_paygrade()
		cam_name += H.name
		if(H.assigned_squad)
			squad = H.assigned_squad
			name += " ([squad.name])"
			squad.squad_orbital_beacons += src
		var/n = active_orbital_beacons.Find(src)
		cam_name += " [n]"
		var/obj/machinery/camera/beacon_cam/BC = new(src, cam_name)
		H.transferItemToLoc(src, H.loc)
		beacon_cam = BC
		activated = TRUE
		anchored = TRUE
		w_class = 10
		layer = ABOVE_FLY_LAYER
		icon_state = "[icon_activated]"
		SetLuminosity(2)
		playsound(src, 'sound/machines/twobeep.ogg', 15, 1)
		H.visible_message("[H] activates [src]",
		"You activate [src]")

/obj/item/squad_beacon/bomb/proc/deactivate(mob/living/carbon/human/H)
	var/delay = activation_time * 0.5 //Half as long as setting it up.
	if(H.mind.cm_skills)
		delay = max(10, delay - 20 * H.mind.cm_skills.leadership)
	H.visible_message("<span class='notice'>[H] starts removing [src] from the ground.</span>",
	"<span class='notice'>You start removing [src] from the ground, deactivating it.</span>")
	if(do_after(H, delay, TRUE, src, BUSY_ICON_GENERIC))
		message_admins("[ADMIN_TPMONTY(usr)] removed an orbital strike beacon.")
		if(squad)
			squad.squad_orbital_beacons -= src
			squad = null
		if(src in active_orbital_beacons)
			active_orbital_beacons -= src
		qdel(beacon_cam)
		beacon_cam = null
		activated = FALSE
		anchored = FALSE
		w_class = initial(w_class)
		layer = initial(layer)
		name = initial(name)
		icon_state = initial(icon_state)
		SetLuminosity(0)
		playsound(src, 'sound/machines/twobeep.ogg', 15, 1)
		H.visible_message("[H] deactivates [src]",
		"You deactivate [src]")
		H.put_in_active_hand(src)



//This is perhaps one of the weirdest places imaginable to put it, but it's a leadership skill, so

/mob/living/carbon/human/verb/issue_order(which as null|text)
	set name = "Issue Order"
	set desc = "Issue an order to nearby humans, using your authority to strengthen their resolve."
	set category = "IC"

	if(!mind.cm_skills || (mind.cm_skills && mind.cm_skills.leadership < SKILL_LEAD_TRAINED))
		to_chat(src, "<span class='warning'>You are not competent enough in leadership to issue an order.</span>")
		return

	if(stat)
		to_chat(src, "<span class='warning'>You cannot give an order in your current state.</span>")
		return

	if(command_aura_cooldown > 0)
		to_chat(src, "<span class='warning'>You have recently given an order. Calm down.</span>")
		return

	if(!which)
		var/choice = input(src, "Choose an order") in command_aura_allowed + "help" + "cancel"
		if(choice == "help")
			to_chat(src, "<span class='notice'><br>Orders give a buff to nearby soldiers for a short period of time, followed by a cooldown, as follows:<br><B>Move</B> - Increased mobility and chance to dodge projectiles.<br><B>Hold</B> - Increased resistance to pain and combat wounds.<br><B>Focus</B> - Increased gun accuracy and effective range.<br></span>")
			return
		if(choice == "cancel")
			return
		command_aura = choice
	else
		command_aura = which

	if(command_aura_cooldown > 0)
		to_chat(src, "<span class='warning'>You have recently given an order. Calm down.</span>")
		return

	if(!(command_aura in command_aura_allowed))
		return
	command_aura_cooldown = 45 //45 ticks
	command_aura_tick = 10 //10 ticks
	var/message = ""
	switch(command_aura)
		if("move")
			var/image/move = image('icons/mob/talk.dmi', src, icon_state = "order_move")
			message = pick(";GET MOVING!", ";GO, GO, GO!", ";WE ARE ON THE MOVE!", ";MOVE IT!", ";DOUBLE TIME!")
			say(message)
			add_emote_overlay(move)
		if("hold")
			var/image/hold = image('icons/mob/talk.dmi', src, icon_state = "order_hold")
			message = pick(";DUCK AND COVER!", ";HOLD THE LINE!", ";HOLD POSITION!", ";STAND YOUR GROUND!", ";STAND AND FIGHT!")
			say(message)
			add_emote_overlay(hold)
		if("focus")
			var/image/focus = image('icons/mob/talk.dmi', src, icon_state = "order_focus")
			message = pick(";FOCUS FIRE!", ";PICK YOUR TARGETS!", ";CENTER MASS!", ";CONTROLLED BURSTS!", ";AIM YOUR SHOTS!")
			say(message)
			add_emote_overlay(focus)
	update_action_buttons()


/datum/action/skill/issue_order
	name = "Issue Order"
	skill_name = "leadership"
	skill_min = SKILL_LEAD_TRAINED
	var/order_type = null

/datum/action/skill/issue_order/action_activate()
	var/mob/living/carbon/human/human = owner
	if(istype(human))
		human.issue_order(order_type)

/datum/action/skill/issue_order/update_button_icon()
	var/mob/living/carbon/human/human = owner
	if(!istype(human))
		return
	button.overlays.Cut()
	button.overlays += image('icons/mob/order_icons.dmi', icon_state = "[order_type]")

	if(human.command_aura_cooldown > 0)
		button.color = rgb(255,0,0,255)
	else
		button.color = rgb(255,255,255,255)

/datum/action/skill/issue_order/move
	name = "Issue Move Order"
	order_type = "move"

/datum/action/skill/issue_order/hold
	name = "Issue Hold Order"
	order_type = "hold"

/datum/action/skill/issue_order/focus
	name = "Issue Focus Order"
	order_type = "focus"



/datum/action/skill/toggle_orders
	name = "Show/Hide Order Options"
	skill_name = "leadership"
	skill_min = SKILL_LEAD_TRAINED
	var/orders_visible = TRUE

/datum/action/skill/toggle_orders/New()
	return ..(/obj/item/megaphone)

/datum/action/skill/toggle_orders/action_activate()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return
	if(orders_visible)
		orders_visible = FALSE
		for(var/datum/action/skill/path in owner.actions)
			if(istype(path, /datum/action/skill/issue_order))
				path.remove_action(H)
	else
		orders_visible = TRUE
		var/list/subtypeactions = subtypesof(/datum/action/skill/issue_order)
		for(var/path in subtypeactions)
			var/datum/action/skill/issue_order/A = new path()
			A.give_action(H)


/obj/machinery/computer/camera_advanced/overwatch/proc/get_squad_by_id(id)
	if(!squads || !length(squads))
		return FALSE
	var/datum/squad/S
	for(S in squads)
		if(S.id == id)
			return S
	return FALSE

/obj/machinery/computer/camera_advanced/overwatch/proc/get_squad_info()
	var/dat = ""
	if(!current_squad)
		dat += "No Squad selected!<BR>"
		dat += get_squad_info_ending()
		return dat
	var/leader_text = ""
	var/leader_count = 0
	var/spec_text = ""
	var/spec_count = 0
	var/medic_text = ""
	var/medic_count = 0
	var/engi_text = ""
	var/engi_count = 0
	var/smart_text = ""
	var/smart_count = 0
	var/marine_text = ""
	var/marine_count = 0
	var/misc_text = ""
	var/living_count = 0
	var/conscious_text = ""
	var/unconscious_text = ""
	var/dead_text = ""
	var/gibbed_text = ""
	var/SL_z //z level of the Squad Leader
	if(current_squad.squad_leader)
		var/turf/SL_turf = get_turf(current_squad.squad_leader)
		SL_z = SL_turf?.z
	for(var/mob/living/carbon/human/H in current_squad.get_all_members())
		var/mob_name = "unknown"
		var/mob_state = ""
		var/role = "unknown"
		var/act_sl = ""
		var/fteam = ""
		var/dist = "<b>???</b>"
		var/area_name = "<b>???</b>"
		mob_name = H.real_name
		var/area/A = get_area(H)
		var/turf/M_turf = get_turf(H)
		if(A)
			area_name = sanitize(A.name)
		switch(z_hidden)
			if(HIDE_ON_GROUND)
				if(is_ground_level(M_turf?.z))
					continue
			if(HIDE_ON_SHIP)
				if(is_mainship_level(M_turf?.z))
					continue

		if(H.mind?.assigned_role)
			role = H.mind.assigned_role
		else
			var/obj/item/card/id/ID = H.wear_id //we use their ID to get their role.
			if(ID?.rank)
				role = ID.rank
		if(current_squad.squad_leader)
			if(H == current_squad.squad_leader)
				dist = "<b>N/A</b>"
				if(H.mind && H.mind.assigned_role != "Squad Leader")
					act_sl = " (acting SL)"
			else if(M_turf && SL_z && M_turf.z == SL_z)
				dist = "[get_dist(H, current_squad.squad_leader)] ([dir2text_short(get_dir(current_squad.squad_leader, H))])"
		switch(H.stat)
			if(CONSCIOUS)
				mob_state = "Conscious"
				living_count++
				conscious_text += "<tr><td><A href='?src=\ref[src];operation=use_cam;cam_target=\ref[H]'>[mob_name]</a></td><td>[role][act_sl]</td><td>[mob_state]</td><td>[area_name]</td><td>[dist]</td></tr>"
			if(UNCONSCIOUS)
				mob_state = "<b>Unconscious</b>"
				living_count++
				unconscious_text += "<tr><td><A href='?src=\ref[src];operation=use_cam;cam_target=\ref[H]'>[mob_name]</a></td><td>[role][act_sl]</td><td>[mob_state]</td><td>[area_name]</td><td>[dist]</td></tr>"
			if(DEAD)
				if(dead_hidden)
					continue
				mob_state = "<font color='red'>DEAD</font>"
				dead_text += "<tr><td><A href='?src=\ref[src];operation=use_cam;cam_target=\ref[H]'>[mob_name]</a></td><td>[role][act_sl]</td><td>[mob_state]</td><td>[area_name]</td><td>[dist]</td></tr>"
		if((!H.key || !H.client) && H.stat != DEAD)
			mob_state += " (SSD)"
		var/obj/item/card/id/ID = H.wear_id
		if(ID?.assigned_fireteam)
			fteam = " \[[ID.assigned_fireteam]\]"
		var/marine_infos = "<tr><td><A href='?src=\ref[src];operation=use_cam;cam_target=\ref[H]'>[mob_name]</a></td><td>[role][act_sl][fteam]</td><td>[mob_state]</td><td>[area_name]</td><td>[dist]</td></tr>"
		switch(role)
			if("Squad Leader")
				leader_text += marine_infos
				leader_count++
			if("Squad Specialist")
				spec_text += marine_infos
				spec_count++
			if("Squad Corpsman")
				medic_text += marine_infos
				medic_count++
			if("Squad Engineer")
				engi_text += marine_infos
				engi_count++
			if("Squad Smartgunner")
				smart_text += marine_infos
				smart_count++
			if("Squad Marine")
				marine_text += marine_infos
				marine_count++
			else
				misc_text += marine_infos
	if(!dead_hidden && !z_hidden) //gibbed marines are neither on the colony nor on the almayer
		for(var/X in current_squad.gibbed_marines_list) //listed marine was deleted or gibbed, all we have is their name
			var/role = current_squad.gibbed_marines_list[X]
			var/mob_state = "<font color='red'>FUBAR</font>"
			var/mob_name = X
			var/area_name = "<b>???</b>"
			var/dist = "<b>???</b>"
			gibbed_text += "<tr><td>[mob_name]</td><td>[role]</td><td>[mob_state]</td><td>[area_name]</td><td>[dist]</td></tr>"
			var/marine_infos = "<tr><td>[mob_name]</td><td>[role]</td><td>[mob_state]</td><td>[area_name]</td><td>[dist]</td></tr>"
			switch(role)
				if("Squad Leader")
					leader_text += marine_infos
					leader_count++
				if("Squad Specialist")
					spec_text += marine_infos
					spec_count++
				if("Squad Corpsman")
					medic_text += marine_infos
					medic_count++
				if("Squad Engineer")
					engi_text += marine_infos
					engi_count++
				if("Squad Smartgunner")
					smart_text += marine_infos
					smart_count++
				if("Squad Marine")
					marine_text += marine_infos
					marine_count++
				else
					misc_text += marine_infos
	if(current_squad.overwatch_officer)
		dat += "<b>Squad Overwatch:</b> [current_squad.overwatch_officer.name]<br>"
	else
		dat += "<b>Squad Overwatch:</b> <font color=red>NONE</font><br>"
	dat += "----------------------<br>"
	dat += "<b>[leader_count ? "Squad Leader Deployed":"<font color='red'>No Squad Leader Deployed!</font>"]</b><br>"
	dat += "<b>[spec_count ? "Squad Specialist Deployed":"<font color='red'>No Specialist Deployed!</font>"]</b><br>"
	dat += "<b>[smart_count ? "Squad Smartgunner Deployed":"<font color='red'>No Smartgunner Deployed!</font>"]</b><br>"
	dat += "<b>Squad Corpsmen: [medic_count] Deployed | Squad Engineers: [engi_count] Deployed</b><br>"
	dat += "<b>Squad Marines: [marine_count] Deployed</b><br>"
	dat += "<b>Total: [current_squad.get_total_members()] Deployed</b><br>"
	dat += "<b>Marines alive: [living_count]</b><br><br>"
	dat += "<table border='1' style='width:100%' align='center'><tr>"
	dat += "<th>Name</th><th>Role</th><th>State</th><th>Location</th><th>SL Distance</th></tr>"
	if(!living_marines_sorting)
		dat += leader_text + spec_text + medic_text + engi_text + smart_text + marine_text + misc_text
	else
		dat += conscious_text + unconscious_text + dead_text + gibbed_text
	dat += "</table>"
	dat += "<br>----------------------<br>"
	dat += "<b>Primary Objective:</b> "
	if(current_squad.primary_objective)
		dat += "[current_squad.primary_objective]<br>"
	else
		dat += "<b><font color=red>NONE!</font></b><br>"
	dat += "<b>Secondary Objective:</b> "
	if(current_squad.secondary_objective)
		dat += "[current_squad.secondary_objective]<br>"
	else
		dat += "<b><font color=red>NONE!</font></b><br>"
	dat += get_squad_info_ending()
	return dat

/obj/machinery/computer/camera_advanced/overwatch/proc/get_squad_info_ending()
	var/dat = ""
	dat += "----------------------<br>"
	dat += "<A href='?src=\ref[src];operation=refresh'>{Refresh}</a><br>"
	dat += "<A href='?src=\ref[src];operation=change_sort'>{Change Sorting Method}</a><br>"
	dat += "<A href='?src=\ref[src];operation=hide_dead'>{[dead_hidden ? "Show Dead Marines" : "Hide Dead Marines" ]}</a><br>"
	dat += "<A href='?src=\ref[src];operation=choose_z'>{Change Locations Ignored}</a><br>"
	dat += "<br><A href='?src=\ref[src];operation=back'>{Back}</a>"
	return dat

#undef OW_MAIN
#undef OW_MONITOR
#undef OW_SUPPLIES
#undef MAX_SUPPLY_DROPS
