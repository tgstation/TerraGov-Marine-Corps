#define OW_MAIN 0
#define OW_MONITOR 1

#define HIDE_NONE 0
#define HIDE_ON_GROUND 1
#define HIDE_ON_SHIP 2

GLOBAL_LIST_EMPTY(active_orbital_beacons)
GLOBAL_LIST_EMPTY(active_laser_targets)
GLOBAL_LIST_EMPTY(active_cas_targets)
/obj/machinery/computer/camera_advanced/overwatch
	name = "Overwatch Console"
	desc = "State of the art machinery for giving orders to a squad. <b>Shift click</b> to send order when watching squads."
	density = FALSE
	icon_state = "overwatch"
	req_access = list(ACCESS_MARINE_BRIDGE)
	networks = list("marine")
	open_prompt = FALSE
	interaction_flags = INTERACT_MACHINE_DEFAULT

	var/state = OW_MAIN
	var/living_marines_sorting = FALSE
	///The overwatch computer is busy launching an OB/SB, lock controls
	var/busy = FALSE
	///whether or not we show the dead marines in the squad.
	var/dead_hidden = FALSE
	///which z level is ignored when showing marines.
	var/z_hidden = 0
	///Squad being currently overseen
	var/datum/squad/current_squad = null
	///Selected target for bombarding
	var/obj/selected_target
	///Selected order to give to marine
	var/datum/action/innate/order/current_order
	///datum used when sending an attack order
	var/datum/action/innate/order/attack_order/send_attack_order
	///datum used when sending a retreat order
	var/datum/action/innate/order/retreat_order/send_retreat_order
	///datum used when sending a defend order
	var/datum/action/innate/order/defend_order/send_defend_order

/obj/machinery/computer/camera_advanced/overwatch/Initialize()
	. = ..()
	send_attack_order = new
	send_defend_order = new
	send_retreat_order = new

/obj/machinery/computer/camera_advanced/overwatch/give_actions(mob/living/user)
	. = ..()
	if(send_attack_order)
		send_attack_order.target = user
		send_attack_order.give_action(user)
		actions += send_attack_order
	if(send_defend_order)
		send_defend_order.target = user
		send_defend_order.give_action(user)
		actions += send_defend_order
	if(send_retreat_order)
		send_retreat_order.target = user
		send_retreat_order.give_action(user)
		actions += send_retreat_order

/obj/machinery/computer/camera_advanced/overwatch/main
	icon_state = "overwatch_main"
	name = "Main Overwatch Console"
	desc = "State of the art machinery for general overwatch purposes."

/obj/machinery/computer/camera_advanced/overwatch/alpha
	name = "Alpha Overwatch Console"

/obj/machinery/computer/camera_advanced/overwatch/bravo
	name = "Bravo Overwatch Console"

/obj/machinery/computer/camera_advanced/overwatch/charlie
	name = "Charlie Overwatch Console"

/obj/machinery/computer/camera_advanced/overwatch/delta
	name = "Delta Overwatch Console"


/obj/machinery/computer/camera_advanced/overwatch/attackby(obj/item/I, mob/user, params)
	return


/obj/machinery/computer/camera_advanced/overwatch/CreateEye()
	. = ..()
	eyeobj.visible_icon = TRUE
	eyeobj.icon = 'icons/mob/cameramob.dmi'
	eyeobj.icon_state = "generic_camera"

/obj/machinery/computer/camera_advanced/overwatch/give_eye_control(mob/user)
	. = ..()
	RegisterSignal(user, COMSIG_MOB_CLICK_SHIFT, .proc/send_orders)

/obj/machinery/computer/camera_advanced/overwatch/remove_eye_control(mob/living/user)
	. = ..()
	UnregisterSignal(user, COMSIG_MOB_CLICK_SHIFT)

/obj/machinery/computer/camera_advanced/overwatch/can_interact(mob/user)
	. = ..()
	if(!.)
		return FALSE

	if(!allowed(user))
		return FALSE

	return TRUE


/obj/machinery/computer/camera_advanced/overwatch/interact(mob/user)
	. = ..()
	if(.)
		return

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
						dat += "[current_squad.secondary_objective] <a href='?src=\ref[src];operation=set_secondary'>\[Set\]</a><br>"
					else
						dat += "<b><font color=red>NONE!</font></b> <a href='?src=\ref[src];operation=set_secondary'>\[Set\]</a><br>"
					dat += "<br>"
					dat += "<A href='?src=\ref[src];operation=insubordination'>Report a marine for insubordination</a><BR>"
					dat += "<A href='?src=\ref[src];operation=squad_transfer'>Transfer a marine to another squad</a><BR><BR>"
					dat += "<a href='?src=\ref[src];operation=monitor'>Squad Monitor</a><br>"
					dat += "----------------------<br>"
					dat += "<b>Rail Gun Control</b><br>"
					dat += "<b>Current Rail Gun Status:</b> "
					var/cooldown_left = (GLOB.marine_main_ship?.rail_gun?.last_firing + 600) - world.time // 60 seconds between shots
					if(cooldown_left > 0)
						dat += "Rail Gun on cooldown ([round(cooldown_left/10)] seconds)<br>"
					else if(!GLOB.marine_main_ship?.rail_gun?.rail_gun_ammo?.ammo_count)
						dat += "<font color='red'>Ammo depleted.</font><br>"
					else
						dat += "<font color='green'>Ready!</font><br>"
					dat += "<B>[current_squad.name] Laser Targets:</b><br>"
					if(length(GLOB.active_laser_targets))
						for(var/obj/effect/overlay/temp/laser_target/LT in current_squad.squad_laser_targets)
							if(!istype(LT))
								continue
							dat += "<a href='?src=[REF(src)];operation=use_cam;cam_target=[REF(LT)];selected_target=[REF(LT)]'>[LT]</a><br>"
					else
						dat += "<span class='warning'>None</span><br>"
					dat += "<B>[current_squad.name] Beacon Targets:</b><br>"
					if(length(GLOB.active_orbital_beacons))
						for(var/obj/item/squad_beacon/bomb/OB in current_squad.squad_orbital_beacons)
							if(!istype(OB))
								continue
							dat += "<a href='?src=[REF(src)];operation=use_cam;cam_target=[REF(OB)];selected_target=[REF(OB)]'>[OB]</a><br>"
					else
						dat += "<span class='warning'>None transmitting</span><br>"
					dat += "<b>Selected Target:</b><br>"
					if(!selected_target) // Clean the targets if nothing is selected
						dat += "<span class='warning'>None</span><br>"
					else if(!(selected_target in GLOB.active_laser_targets) && !(selected_target in GLOB.active_orbital_beacons)) // Or available
						dat += "<span class='warning'>None</span><br>"
						selected_target = null
					else
						dat += "<font color='green'>[selected_target]</font><br>"
					dat += "<A href='?src=\ref[src];operation=shootrailgun'>\[FIRE!\]</a><br>"
					dat += "----------------------<br>"
					dat += "<br><br><a href='?src=\ref[src];operation=refresh'>{Refresh}</a>"
			if(OW_MONITOR)//Info screen.
				dat += get_squad_info()

	var/datum/browser/popup = new(user, "overwatch", "<div align='center'>[current_squad ? current_squad.name : ""] Overwatch Console</div>", 550, 550)
	popup.set_content(dat)
	popup.open()


/obj/machinery/computer/camera_advanced/overwatch/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(!href_list["operation"])
		return

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
			if(!current_squad)
				return
			var/obj/item/card/id/ID = operator.get_idcard()
			current_squad.overwatch_officer = null //Reset the squad's officer.
			current_squad.message_squad("Attention. [ID ? "[ID.rank] ":""][operator ? "[operator.name]":"sysadmin"] is no longer your Overwatch officer. Overwatch functions deactivated.")
			visible_message("<span class='boldnotice'>Overwatch systems deactivated. Goodbye, [ID ? "[ID.rank] ":""][operator ? "[operator.name]":"sysadmin"].</span>")
			operator = null
			current_squad = null
			state = OW_MAIN
		if("logout_main")
			var/obj/item/card/id/ID = operator.get_idcard()
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
					for(var/i in SSjob.active_squads)
						var/datum/squad/S = SSjob.active_squads[i]
						if(!S.overwatch_officer)
							squad_choices += S.name

					var/squad_name = tgui_input_list(usr, "Which squad would you like to claim for Overwatch?", null, squad_choices)
					if(!squad_name || operator != usr)
						return
					if(current_squad)
						to_chat(usr, "<span class='warning'>[icon2html(src, usr)] You are already selecting a squad.</span>")
						return
					var/datum/squad/selected = SSjob.active_squads[squad_name]
					if(selected)
						selected.overwatch_officer = usr //Link everything together, squad, console, and officer
						current_squad = selected
						current_squad.message_squad("Attention - Your squad has been selected for Overwatch. Check your Status pane for objectives.")
						current_squad.message_squad("Your Overwatch officer is: [operator.name].")
						visible_message("<span class='boldnotice'>Tactical data for squad '[current_squad]' loaded. All tactical functions initialized.</span>")
						attack_hand(usr)


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
					to_chat(usr, "[icon2html(src, usr)] <span class='notice'>Marines on the [SSmapping.configs[SHIP_MAP].map_name] are now hidden.</span>")
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
		if("dropbomb")
			handle_bombard()
		if("shootrailgun")
			var/mob/living/user = usr
			if(user.interactee)
				to_chat(usr, "[icon2html(src, usr)] <span class='warning'>Your busy doing something else, and press the wrong button!</span>")
				return
			if((GLOB.marine_main_ship?.rail_gun?.last_firing + 600) > world.time)
				to_chat(usr, "[icon2html(src, usr)] <span class='warning'>The Rail Gun hasn't cooled down yet!</span>")
			else if(!selected_target)
				to_chat(usr, "[icon2html(src, usr)] <span class='warning'>No target detected!</span>")
			else
				GLOB.marine_main_ship?.rail_gun?.fire_rail_gun(get_turf(selected_target),usr)
		if("back")
			state = OW_MAIN
		if("use_cam")
			selected_target = locate(href_list["selected_target"])
			if(!isAI(usr))
				var/atom/cam_target = locate(href_list["cam_target"])
				open_prompt(usr)
				eyeobj.setLoc(get_turf(cam_target))
				if(isliving(cam_target))
					var/mob/living/L = cam_target
					track(L)
				else
					to_chat(usr, "[icon2html(src, usr)] <span class='notice'>Jumping to the latest available location of [cam_target].</span>")

	updateUsrDialog()


/obj/machinery/computer/camera_advanced/overwatch/main/interact(mob/living/user)
	. = ..()
	if(.)
		return

	var/dat
	if(!operator)
		dat += "<B>Main Operator:</b> <A href='?src=\ref[src];operation=change_main_operator'>----------</A><BR>"
	else
		dat += "<B>Main Operator:</b> <A href='?src=\ref[src];operation=change_main_operator'>[operator.name]</A><BR>"
		dat += "   <A href='?src=\ref[src];operation=logout_main'>{Stop Overwatch}</A><BR>"
		dat += "----------------------<br>"
		switch(state)
			if(OW_MAIN)
				for(var/s in SSjob.active_squads)
					var/datum/squad/S = SSjob.active_squads[s]
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
				if(!GLOB.marine_main_ship?.orbital_cannon?.chambered_tray)
					dat += "<font color='red'>No ammo chambered in the cannon.</font><br>"
				else
					dat += "<font color='green'>Ready!</font><br>"
				dat += "<B>Laser Targets:</b><br>"
				if(length(GLOB.active_laser_targets))
					for(var/obj/effect/overlay/temp/laser_target/LT in GLOB.active_laser_targets)
						if(!istype(LT))
							continue
						dat += "<a href='?src=[REF(src)];operation=use_cam;cam_target=[REF(LT)];selected_target=[REF(LT)]'>[LT]</a><br>"
				else
					dat += "<span class='warning'>None</span><br>"
				dat += "<B>Beacon Targets:</b><br>"
				if(length(GLOB.active_orbital_beacons))
					for(var/obj/item/squad_beacon/bomb/OB in GLOB.active_orbital_beacons)
						if(!istype(OB))
							continue
						dat += "<a href='?src=\ref[src];operation=use_cam;cam_target=[REF(OB)];selected_target=[REF(OB)]'>[OB]</a><br>"
				else
					dat += "<span class='warning'>None transmitting</span><br>"
				dat += "<b>Selected Target:</b><br>"
				if(!selected_target) // Clean the targets if nothing is selected
					dat += "<span class='warning'>None</span><br>"
				else if(!(selected_target in GLOB.active_laser_targets) && !(selected_target in GLOB.active_orbital_beacons)) // Or available
					dat += "<span class='warning'>None</span><br>"
					selected_target = null
				else
					dat += "<font color='green'>[selected_target.name]</font><br>"
				dat += "<A href='?src=\ref[src];operation=dropbomb'>\[FIRE!\]</a><br>"
				dat += "----------------------<BR>"
				dat += "<A href='?src=\ref[src];operation=refresh'>{Refresh}</a>"
			if(OW_MONITOR)//Info screen.
				dat += get_squad_info()

	var/datum/browser/popup = new(user, "overwatch", "<div align='center'>Main Overwatch Console</div>", 550, 550)
	popup.set_content(dat)
	popup.open()


/obj/machinery/computer/camera_advanced/overwatch/proc/send_to_squads(txt)
	for(var/s in SSjob.active_squads)
		var/datum/squad/S = SSjob.active_squads[s]
		S.message_squad(txt)

/obj/machinery/computer/camera_advanced/overwatch/proc/handle_bombard()
	if(!usr)
		return
	if(busy)
		to_chat(usr, "[icon2html(src, usr)] <span class='warning'>The [name] is busy processing another action!</span>")
		return
	if(!GLOB.marine_main_ship?.orbital_cannon?.chambered_tray)
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
		playsound(selected_target.loc,'sound/effects/alert.ogg', 50, 1, 20)  //mostly used to warn xenos as the new ob sounds have a quiet beginning

	addtimer(CALLBACK(src, .proc/send_to_squads, "Transmitting beacon feed..."), 1.5 SECONDS)
	addtimer(CALLBACK(src, .proc/send_to_squads, "Calibrating trajectory window..."), 3 SECONDS)
	addtimer(CALLBACK(src, .proc/do_fire_bombard, T, usr), 3.1 SECONDS)

/obj/machinery/computer/camera_advanced/overwatch/proc/do_fire_bombard(turf/T, user)
	visible_message("<span class='boldnotice'>Orbital bombardment has fired! Impact imminent!</span>")
	send_to_squads("WARNING! Ballistic trans-atmospheric launch detected! Get outside of Danger Close!")
	addtimer(CALLBACK(src, .proc/do_land_bombard, T, user), 2.5 SECONDS)

/obj/machinery/computer/camera_advanced/overwatch/proc/do_land_bombard(turf/T, user)
	busy = FALSE
	var/x_offset = rand(-2,2) //Little bit of randomness.
	var/y_offset = rand(-2,2)
	var/turf/target = locate(T.x + x_offset,T.y + y_offset,T.z)
	if(target && istype(target))
		target.ceiling_debris_check(5)
		GLOB.marine_main_ship?.orbital_cannon?.fire_ob_cannon(target,user)

/obj/machinery/computer/camera_advanced/overwatch/proc/change_lead()
	if(!usr || usr != operator)
		return
	if(!current_squad)
		to_chat(usr, "[icon2html(src, usr)] <span class='warning'>No squad selected!</span>")
		return
	var/sl_candidates = list()
	for(var/mob/living/carbon/human/H in current_squad.get_all_members())
		if(istype(H) && H.stat != DEAD && H.mind && !is_banned_from(H.ckey, SQUAD_LEADER))
			sl_candidates += H
	var/new_lead = tgui_input_list(usr, "Choose a new Squad Leader", null, sl_candidates)
	if(!new_lead || new_lead == "Cancel") return
	var/mob/living/carbon/human/H = new_lead
	if(!istype(H) || !H.mind || H.stat == DEAD) //marines_list replaces mob refs of gibbed marines with just a name string
		to_chat(usr, "[icon2html(src, usr)] <span class='warning'>[H] is KIA!</span>")
		return
	if(H == current_squad.squad_leader)
		to_chat(usr, "[icon2html(src, usr)] <span class='warning'>[H] is already the Squad Leader!</span>")
		return
	if(is_banned_from(H.ckey, SQUAD_LEADER))
		to_chat(usr, "[icon2html(src, usr)] <span class='warning'>[H] is unfit to lead!</span>")
		return
	if(current_squad.squad_leader)
		current_squad.message_squad("Attention: [current_squad.squad_leader] is [current_squad.squad_leader.stat == DEAD ? "stepping down" : "demoted"]. A new Squad Leader has been set: [H.real_name].")
		visible_message("<span class='boldnotice'>Squad Leader [current_squad.squad_leader] of squad '[current_squad]' has been [current_squad.squad_leader.stat == DEAD ? "replaced" : "demoted and replaced"] by [H.real_name]! Logging to enlistment files.</span>")
		current_squad.demote_leader()
	else
		current_squad.message_squad("Attention: A new Squad Leader has been set: [H.real_name].")
		visible_message("<span class='boldnotice'>[H.real_name] is the new Squad Leader of squad '[current_squad]'! Logging to enlistment file.</span>")

	to_chat(H, "[icon2html(src, H)] <font size='3' color='blue'><B>\[Overwatch\]: You've been promoted to \'[ismarineleaderjob(H.job) ? "SQUAD LEADER" : "ACTING SQUAD LEADER"]\' for [current_squad.name]. Your headset has access to the command channel (:v).</B></font>")
	to_chat(usr, "[icon2html(src, usr)] [H.real_name] is [current_squad]'s new leader!")
	current_squad.promote_leader(H)


/obj/machinery/computer/camera_advanced/overwatch/proc/mark_insubordination()
	if(!usr || usr != operator)
		return
	if(!current_squad)
		to_chat(usr, "[icon2html(src, usr)] <span class='warning'>No squad selected!</span>")
		return
	var/mob/living/carbon/human/wanted_marine = tgui_input_list(usr, "Report a marine for insubordination", null, current_squad.get_all_members())
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
	var/mob/living/carbon/human/transfer_marine = tgui_input_list(usr, "Choose marine to transfer", null, current_squad.get_all_members())
	if(!transfer_marine)
		return

	if(!transfer_marine.job)
		CRASH("[transfer_marine] selected for transfer without a job.")

	if(S != current_squad)
		return //don't change overwatched squad, idiot.

	if(!istype(transfer_marine) || transfer_marine.stat == DEAD) //gibbed, decapitated, dead
		to_chat(usr, "[icon2html(src, usr)] <span class='warning'>[transfer_marine] is KIA.</span>")
		return

	if(!istype(transfer_marine.wear_id, /obj/item/card/id))
		to_chat(usr, "[icon2html(src, usr)] <span class='warning'>Transfer aborted. [transfer_marine] isn't wearing an ID.</span>")
		return

	var/choice = tgui_input_list(usr, "Choose the marine's new squad", null,  SSjob.active_squads)
	if(!choice)
		return
	if(S != current_squad)
		return
	var/datum/squad/new_squad = SSjob.active_squads[choice]

	if(!istype(transfer_marine) || transfer_marine.stat == DEAD)
		to_chat(usr, "[icon2html(src, usr)] <span class='warning'>[transfer_marine] is KIA.</span>")
		return

	if(!istype(transfer_marine.wear_id, /obj/item/card/id))
		to_chat(usr, "[icon2html(src, usr)] <span class='warning'>Transfer aborted. [transfer_marine] isn't wearing an ID.</span>")
		return

	var/datum/squad/old_squad = transfer_marine.assigned_squad
	if(new_squad == old_squad)
		to_chat(usr, "[icon2html(src, usr)] <span class='warning'>[transfer_marine] is already in [new_squad]!</span>")
		return

	if(ismarineleaderjob(transfer_marine.job) && new_squad.current_positions[/datum/job/terragov/squad/leader] >= SQUAD_MAX_POSITIONS(transfer_marine.job.total_positions))
		to_chat(usr, "[icon2html(src, usr)] <span class='warning'>Transfer aborted. [new_squad] can't have another [transfer_marine.job.title].</span>")
		return

	old_squad.remove_from_squad(transfer_marine)
	new_squad.insert_into_squad(transfer_marine)

	for(var/datum/data/record/t in GLOB.datacore.general) //we update the crew manifest
		if(t.fields["name"] == transfer_marine.real_name)
			t.fields["squad"] = new_squad.name
			break

	var/obj/item/card/id/ID = transfer_marine.wear_id
	ID.assigned_fireteam = 0 //reset fireteam assignment

	//Changes headset frequency to match new squad
	var/obj/item/radio/headset/mainship/marine/H = transfer_marine.wear_ear
	if(istype(H, /obj/item/radio/headset/mainship/marine))
		H.set_frequency(new_squad.radio_freq)

	transfer_marine.hud_set_job()
	visible_message("<span class='boldnotice'>[transfer_marine] has been transfered from squad '[old_squad]' to squad '[new_squad]'. Logging to enlistment file.</span>")
	to_chat(transfer_marine, "[icon2html(src, transfer_marine)] <font size='3' color='blue'><B>\[Overwatch\]:</b> You've been transfered to [new_squad]!</font>")


//This is perhaps one of the weirdest places imaginable to put it, but it's a leadership skill, so

/mob/living/carbon/human/verb/issue_order(which as null|text)
	set hidden = TRUE

	if(skills.getRating("leadership") < SKILL_LEAD_TRAINED)
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
			message = pick(";GET MOVING!", ";GO, GO, GO!", ";WE ARE ON THE MOVE!", ";MOVE IT!", ";DOUBLE TIME!", ";ONWARDS!", ";MOVE MOVE MOVE!", ";ON YOUR FEET!", ";GET A MOVE ON!", ";ON THE DOUBLE!", ";ROLL OUT!", ";LET'S GO, LET'S GO!", ";MOVE OUT!", ";LEAD THE WAY!", ";FORWARD!", ";COME ON, MOVE!", ";HURRY, GO!")
			say(message)
			add_emote_overlay(move)
		if("hold")
			var/image/hold = image('icons/mob/talk.dmi', src, icon_state = "order_hold")
			message = pick(";DUCK AND COVER!", ";HOLD THE LINE!", ";HOLD POSITION!", ";STAND YOUR GROUND!", ";STAND AND FIGHT!", ";TAKE COVER!", ";COVER THE AREA!", ";BRACE FOR COVER!", ";BRACE!", ";INCOMING!")
			say(message)
			add_emote_overlay(hold)
		if("focus")
			var/image/focus = image('icons/mob/talk.dmi', src, icon_state = "order_focus")
			message = pick(";FOCUS FIRE!", ";PICK YOUR TARGETS!", ";CENTER MASS!", ";CONTROLLED BURSTS!", ";AIM YOUR SHOTS!", ";READY WEAPONS!", ";TAKE AIM!", ";LINE YOUR SIGHTS!", ";LOCK AND LOAD!", ";GET READY TO FIRE!")
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
	for(var/s in SSjob.active_squads)
		var/datum/squad/S = SSjob.active_squads[s]
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

		if(H.job)
			role = H.job.title
		else if(istype(H.wear_id, /obj/item/card/id))
			var/obj/item/card/id/ID = H.wear_id //we use their ID to get their role.
			role = ID.rank
		if(current_squad.squad_leader)
			if(H == current_squad.squad_leader)
				dist = "<b>N/A</b>"
				if(!ismarineleaderjob(H.job))
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
			if(SQUAD_LEADER)
				leader_text += marine_infos
				leader_count++
			if(SQUAD_SPECIALIST)
				spec_text += marine_infos
				spec_count++
			if(SQUAD_CORPSMAN)
				medic_text += marine_infos
				medic_count++
			if(SQUAD_ENGINEER)
				engi_text += marine_infos
				engi_count++
			if(SQUAD_SMARTGUNNER)
				smart_text += marine_infos
				smart_count++
			if(SQUAD_MARINE)
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
	dat += "<b>Squad Specialists: [spec_count] Deployed | Squad Smartgunners: [smart_count] Deployed</b><br>"
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

///Print order visual to all marines squad hud and give them an arrow to follow the waypoint
/obj/machinery/computer/camera_advanced/overwatch/proc/send_orders(datum/source, atom/object)
	SIGNAL_HANDLER
	var/turf/target_turf = get_turf(object)
	if (!current_order)
		to_chat(usr, "<span class='warning'>You didn't select any order!</span>")
		return
	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_CIC_ORDERS))
		to_chat(usr, "<span class='warning'>Your last order was too recent.</span>")
		return
	TIMER_COOLDOWN_START(src, COOLDOWN_CIC_ORDERS, ORDER_COOLDOWN)
	new current_order.visual_type(target_turf)
	var/obj/screen/arrow/arrow_hud
	var/datum/atom_hud/squad/squad_hud = GLOB.huds[DATA_HUD_SQUAD]
	var/list/final_list = squad_hud.hudusers
	final_list -= current_user //We don't want the eye to have an arrow, it's silly

	for(var/hud_user in final_list)
		if(!ishuman(hud_user))
			continue
		if(current_order.arrow_type)
			arrow_hud = new current_order.arrow_type
			arrow_hud.add_hud(hud_user, target_turf)
		notify_marine(hud_user, target_turf)

///Send a message and a sound to the marine if he is on the same z level as the turf
/obj/machinery/computer/camera_advanced/overwatch/proc/notify_marine(mob/living/marine, turf/target_turf) ///Send an order to that specific marine if it's on the right z level
	if(marine.z == target_turf.z)
		marine.playsound_local(marine, "sound/effects/CIC_order.ogg", 10, 1)
		to_chat(marine,"<span class='ordercic'>Command is urging you to [current_order.verb_name] [target_turf.loc.name]!</span>")

/datum/action/innate/order
	///the word used to describe the action when notifying marines
	var/verb_name
	///the type of arrow used in the order
	var/arrow_type
	///the type of the visual added on the ground
	var/visual_type

/datum/action/innate/order/attack_order
	name = "Send Attack Order"
	background_icon_state = "template2"
	action_icon_state = "attack"
	verb_name = "attack the enemy at"
	arrow_type = /obj/screen/arrow/attack_order_arrow
	visual_type = /obj/effect/temp_visual/order/attack_order

/datum/action/innate/order/defend_order
	name = "Send Defend Order"
	background_icon_state = "template2"
	action_icon_state = "defend"
	verb_name = "defend our position in"
	arrow_type = /obj/screen/arrow/defend_order_arrow
	visual_type = /obj/effect/temp_visual/order/defend_order

/datum/action/innate/order/retreat_order
	name = "Send Retreat Order"
	background_icon_state = "template2"
	action_icon_state = "retreat"
	verb_name = "retreat from"
	visual_type = /obj/effect/temp_visual/order/retreat_order

///Set the order as selected on the overwatch console
/datum/action/innate/order/proc/set_selected_order()
	var/mob/living/C = target
	var/mob/camera/aiEye/remote/remote_eye = C.remote_control
	var/obj/machinery/computer/camera_advanced/overwatch/console = remote_eye.origin
	console.current_order?.remove_selected_frame()
	if(console.current_order != src)
		console.current_order = src
		add_selected_frame()
		return
	console.current_order = null

/datum/action/innate/order/Activate()
	active = TRUE
	set_selected_order()

/datum/action/innate/order/Deactivate()
	active = FALSE
	set_selected_order()

#undef OW_MAIN
#undef OW_MONITOR
