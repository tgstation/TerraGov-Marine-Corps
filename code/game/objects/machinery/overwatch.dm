#define OW_MAIN 0
#define OW_MONITOR 1

#define HIDE_NONE 0
#define HIDE_ON_GROUND 1
#define HIDE_ON_SHIP 2

#define SPOTLIGHT_COOLDOWN_DURATION 6 MINUTES
#define SPOTLIGHT_DURATION 2 MINUTES

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
	/// The faction that this computer can overwatch
	var/faction = FACTION_TERRAGOV
	/// The list of all squads that can be watched
	var/list/watchable_squads

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
	///datum used when sending a rally order
	var/datum/action/innate/order/rally_order/send_rally_order

/obj/machinery/computer/camera_advanced/overwatch/Initialize()
	. = ..()
	send_attack_order = new
	send_defend_order = new
	send_retreat_order = new
	send_rally_order = new

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
	if(send_rally_order)
		send_rally_order.target = user
		send_rally_order.give_action(user)
		actions += send_rally_order

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

/obj/machinery/computer/camera_advanced/overwatch/req
	icon_state = "overwatch_req"
	name = "Requisition Overwatch Console"
	desc = "Big Brother Requisition demands to see money flowing into the void that is greed."

/obj/machinery/computer/camera_advanced/overwatch/rebel
	faction = FACTION_TERRAGOV_REBEL
	req_access = list(ACCESS_MARINE_BRIDGE_REBEL)

/obj/machinery/computer/camera_advanced/overwatch/rebel/main
	icon_state = "overwatch_main"
	name = "Main Overwatch Console"
	desc = "State of the art machinery for general overwatch purposes."

/obj/machinery/computer/camera_advanced/overwatch/rebel/alpha
	name = "Alpha Overwatch Console"

/obj/machinery/computer/camera_advanced/overwatch/rebel/bravo
	name = "Bravo Overwatch Console"

/obj/machinery/computer/camera_advanced/overwatch/rebel/charlie
	name = "Charlie Overwatch Console"

/obj/machinery/computer/camera_advanced/overwatch/rebel/delta
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
	RegisterSignal(user, COMSIG_MOB_CLICK_SHIFT, .proc/send_order)
	RegisterSignal(user, COMSIG_ORDER_SELECTED, .proc/set_order)
	RegisterSignal(user, COMSIG_MOB_MIDDLE_CLICK, .proc/attempt_spotlight)

/obj/machinery/computer/camera_advanced/overwatch/remove_eye_control(mob/living/user)
	. = ..()
	UnregisterSignal(user, COMSIG_MOB_CLICK_SHIFT)
	UnregisterSignal(user, COMSIG_ORDER_SELECTED)
	UnregisterSignal(user, COMSIG_MOB_MIDDLE_CLICK)

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
	watchable_squads = SSjob.active_squads[faction]
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
						dat += "[span_warning("None")]<br>"
					dat += "<b>Selected Target:</b><br>"
					if(!selected_target) // Clean the targets if nothing is selected
						dat += "[span_warning("None")]<br>"
					else if(!(selected_target in GLOB.active_laser_targets) && !(selected_target in GLOB.active_orbital_beacons)) // Or available
						dat += "[span_warning("None")]<br>"
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
		if("monitoralpha_squad")
			state = OW_MONITOR
			current_squad = get_squad_by_id(ALPHA_SQUAD)
		if("monitorbravo_squad")
			state = OW_MONITOR
			current_squad = get_squad_by_id(BRAVO_SQUAD)
		if("monitorcharlie_squad")
			state = OW_MONITOR
			current_squad = get_squad_by_id(CHARLIE_SQUAD)
		if("monitordelta_squad")
			state = OW_MONITOR
			current_squad = get_squad_by_id(DELTA_SQUAD)
		if("change_operator")
			if(operator != usr)
				if(current_squad)
					current_squad.overwatch_officer = usr
				operator = usr
				var/mob/living/carbon/human/H = operator
				var/obj/item/card/id/ID = H.get_idcard()
				if(issilicon(usr))
					to_chat(usr, span_boldnotice("Basic overwatch systems initialized. Welcome, [ID ? "[ID.rank] ":""][operator.name]. Please select a squad."))
				visible_message(span_boldnotice("Basic overwatch systems initialized. Welcome, [ID ? "[ID.rank] ":""][operator.name]. Please select a squad."))
				current_squad?.message_squad("Attention. Your Overwatch officer is now [ID ? "[ID.rank] ":""][operator.name].")
		if("change_main_operator")
			if(operator != usr)
				operator = usr
				var/mob/living/carbon/human/H = operator
				var/obj/item/card/id/ID = H.get_idcard()
				if(issilicon(usr))
					to_chat(usr, span_boldnotice("Main overwatch systems initialized. Welcome, [ID ? "[ID.rank] ":""][operator.name]."))
				visible_message(span_boldnotice("Main overwatch systems initialized. Welcome, [ID ? "[ID.rank] ":""][operator.name]."))
		if("logout")
			if(!current_squad)
				return
			var/obj/item/card/id/ID = operator.get_idcard()
			current_squad.overwatch_officer = null //Reset the squad's officer.
			current_squad.message_squad("Attention. [ID ? "[ID.rank] ":""][operator ? "[operator.name]":"sysadmin"] is no longer your Overwatch officer. Overwatch functions deactivated.")
			if(issilicon(usr))
				to_chat(usr, span_boldnotice("Overwatch systems deactivated. Goodbye, [ID ? "[ID.rank] ":""][operator ? "[operator.name]":"sysadmin"]."))
			visible_message(span_boldnotice("Overwatch systems deactivated. Goodbye, [ID ? "[ID.rank] ":""][operator ? "[operator.name]":"sysadmin"]."))
			operator = null
			current_squad = null
			state = OW_MAIN
		if("logout_main")
			var/obj/item/card/id/ID = operator.get_idcard()
			if(issilicon(usr))
				to_chat(usr, span_boldnotice("Main overwatch systems deactivated. Goodbye, [ID ? "[ID.rank] ":""][operator ? "[operator.name]":"sysadmin"]."))
			visible_message(span_boldnotice("Main overwatch systems deactivated. Goodbye, [ID ? "[ID.rank] ":""][operator ? "[operator.name]":"sysadmin"]."))
			operator = null
			current_squad = null
			selected_target = null
			state = OW_MAIN
		if("pick_squad")
			if(operator != usr)
				return
			if(current_squad)
				to_chat(usr, span_warning("[icon2html(src, usr)] You are already selecting a squad."))
				return
			var/datum/squad/selected = tgui_input_list(usr, "Which squad would you like to claim for Overwatch?", null, watchable_squads)
			if(!selected || operator != usr)
				return
			selected.overwatch_officer = usr //Link everything together, squad, console, and officer
			current_squad = selected
			current_squad.message_squad("Attention - Your squad has been selected for Overwatch. Check your Game panel for objectives.")
			current_squad.message_squad("Your Overwatch officer is: [operator.name].")
			if(issilicon(usr))
				to_chat(usr, span_boldnotice("Tactical data for squad '[current_squad]' loaded. All tactical functions initialized."))
			visible_message(span_boldnotice("Tactical data for squad '[current_squad]' loaded. All tactical functions initialized."))
			attack_hand(usr)
		if("message")
			if(current_squad && operator == usr)
				var/input = stripped_input(usr, "Please write a message to announce to the squad:", "Squad Message")
				if(input)
					current_squad.message_squad(input, usr) //message, adds username
					if(issilicon(usr))
						to_chat(usr, span_boldnotice("Message sent to all Marines of squad '[current_squad]'."))
					visible_message(span_boldnotice("Message sent to all Marines of squad '[current_squad]'."))
		if("sl_message")
			if(current_squad && operator == usr)
				var/input = stripped_input(usr, "Please write a message to announce to the squad leader:", "SL Message")
				if(input)
					current_squad.message_leader(input, usr)
					if(issilicon(usr))
						to_chat(usr, span_boldnotice("Message sent to Squad Leader [current_squad.squad_leader] of squad '[current_squad]'."))
					visible_message(span_boldnotice("Message sent to Squad Leader [current_squad.squad_leader] of squad '[current_squad]'."))
		if("set_primary")
			var/input = stripped_input(usr, "What will be the squad's primary objective?", "Primary Objective")
			if(input)
				current_squad.primary_objective = input + " ([worldtime2text()])"
				current_squad.message_squad("Your primary objective has changed. See Game panel for details.")
				if(issilicon(usr))
					to_chat(usr, span_boldnotice("Primary objective of squad '[current_squad]' set."))
				visible_message(span_boldnotice("Primary objective of squad '[current_squad]' set."))
		if("set_secondary")
			var/input = stripped_input(usr, "What will be the squad's secondary objective?", "Secondary Objective")
			if(input)
				current_squad.secondary_objective = input + " ([worldtime2text()])"
				current_squad.message_squad("Your secondary objective has changed. See Game panel for details.")
				if(issilicon(usr))
					to_chat(usr, span_boldnotice("Secondary objective of squad '[current_squad]' set."))
				visible_message(span_boldnotice("Secondary objective of squad '[current_squad]' set."))
		if("refresh")
			attack_hand(usr)
		if("change_sort")
			living_marines_sorting = !living_marines_sorting
			if(living_marines_sorting)
				to_chat(usr, "[icon2html(src, usr)] [span_notice("Marines are now sorted by health status.")]")
			else
				to_chat(usr, "[icon2html(src, usr)] [span_notice("Marines are now sorted by rank.")]")
		if("hide_dead")
			dead_hidden = !dead_hidden
			if(dead_hidden)
				to_chat(usr, "[icon2html(src, usr)] [span_notice("Dead marines are now not shown.")]")
			else
				to_chat(usr, "[icon2html(src, usr)] [span_notice("Dead marines are now shown again.")]")
		if("choose_z")
			switch(z_hidden)
				if(HIDE_NONE)
					z_hidden = HIDE_ON_SHIP
					to_chat(usr, "[icon2html(src, usr)] [span_notice("Marines on the [SSmapping.configs[SHIP_MAP].map_name] are now hidden.")]")
				if(HIDE_ON_SHIP)
					z_hidden = HIDE_ON_GROUND
					to_chat(usr, "[icon2html(src, usr)] [span_notice("Marines on the ground are now hidden.")]")
				if(HIDE_ON_GROUND)
					z_hidden = HIDE_NONE
					to_chat(usr, "[icon2html(src, usr)] [span_notice("No location is ignored anymore.")]")

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
				to_chat(usr, "[icon2html(src, usr)] [span_warning("Your busy doing something else, and press the wrong button!")]")
				return
			if((GLOB.marine_main_ship?.rail_gun?.last_firing + 600) > world.time)
				to_chat(usr, "[icon2html(src, usr)] [span_warning("The Rail Gun hasn't cooled down yet!")]")
			else if(!selected_target)
				to_chat(usr, "[icon2html(src, usr)] [span_warning("No target detected!")]")
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
					to_chat(usr, "[icon2html(src, usr)] [span_notice("Jumping to the latest available location of [cam_target].")]")

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
				for(var/datum/squad/S AS in watchable_squads)
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
					dat += "[span_warning("None")]<br>"
				dat += "<b>Selected Target:</b><br>"
				if(!selected_target) // Clean the targets if nothing is selected
					dat += "[span_warning("None")]<br>"
				else if(!(selected_target in GLOB.active_laser_targets) && !(selected_target in GLOB.active_orbital_beacons)) // Or available
					dat += "[span_warning("None")]<br>"
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


/obj/machinery/computer/camera_advanced/overwatch/req/interact(mob/living/user)
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
				for(var/datum/squad/S AS in watchable_squads)
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
			if(OW_MONITOR)//Info screen.
				dat += get_squad_info()

	var/datum/browser/popup = new(user, "overwatch", "<div align='center'>Requisition Overwatch Console</div>", 550, 550)
	popup.set_content(dat)
	popup.open()

/obj/machinery/computer/camera_advanced/overwatch/proc/send_to_squads(txt)
	for(var/datum/squad/squad AS in watchable_squads)
		squad.message_squad(txt)

/obj/machinery/computer/camera_advanced/overwatch/proc/handle_bombard()
	if(!usr)
		return
	if(busy)
		to_chat(usr, "[icon2html(src, usr)] [span_warning("The [name] is busy processing another action!")]")
		return
	if(!GLOB.marine_main_ship?.orbital_cannon?.chambered_tray)
		to_chat(usr, "[icon2html(src, usr)] [span_warning("The orbital cannon has no ammo chambered.")]")
		return
	if(!selected_target)
		to_chat(usr, "[icon2html(src, usr)] [span_warning("No target detected!")]")
		return
	var/area/A = get_area(selected_target)
	if(istype(A) && A.ceiling >= CEILING_DEEP_UNDERGROUND)
		to_chat(usr, "[icon2html(src, usr)] [span_warning("The target's signal is too weak.")]")
		return
	var/turf/T = get_turf(selected_target)
	if(isspaceturf(T))
		to_chat(usr, "[icon2html(src, usr)] [span_warning("The target's landing zone appears to be out of bounds.")]")
		return
	busy = TRUE //All set, let's do this.
	var/warhead_type = GLOB.marine_main_ship.orbital_cannon.tray.warhead.name	//For the AI and Admin logs.

	for(var/mob/living/silicon/ai/AI AS in GLOB.ai_list)
		to_chat(AI, span_warning("NOTICE - Orbital bombardment triggered from overwatch consoles. Warhead type: [warhead_type]. Target: [AREACOORD_NO_Z(T)]"))
		playsound(AI,'sound/machines/triple_beep.ogg', 25, 1, 20)

	if(A)
		log_attack("[key_name(usr)] fired a [warhead_type]in for squad [current_squad] in [AREACOORD(T)].")
		message_admins("[ADMIN_TPMONTY(usr)] fired a [warhead_type]for squad [current_squad] in [ADMIN_VERBOSEJMP(T)].")
	visible_message(span_boldnotice("Orbital bombardment request accepted. Orbital cannons are now calibrating."))
	send_to_squads("Initializing fire coordinates...")
	if(selected_target)
		playsound(selected_target.loc,'sound/effects/alert.ogg', 50, 1, 20)  //mostly used to warn xenos as the new ob sounds have a quiet beginning

	addtimer(CALLBACK(src, .proc/send_to_squads, "Transmitting beacon feed..."), 1.5 SECONDS)
	addtimer(CALLBACK(src, .proc/send_to_squads, "Calibrating trajectory window..."), 3 SECONDS)
	addtimer(CALLBACK(src, .proc/do_fire_bombard, T, usr), 3.1 SECONDS)

/obj/machinery/computer/camera_advanced/overwatch/proc/do_fire_bombard(turf/T, user)
	visible_message(span_boldnotice("Orbital bombardment has fired! Impact imminent!"))
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
		to_chat(usr, "[icon2html(src, usr)] [span_warning("No squad selected!")]")
		return
	var/sl_candidates = list()
	for(var/mob/living/carbon/human/H in current_squad.get_all_members())
		if(istype(H) && H.stat != DEAD && H.mind && !is_banned_from(H.ckey, SQUAD_LEADER))
			sl_candidates += H
	var/new_lead = tgui_input_list(usr, "Choose a new Squad Leader", null, sl_candidates)
	if(!new_lead || new_lead == "Cancel") return
	var/mob/living/carbon/human/H = new_lead
	if(!istype(H) || !H.mind || H.stat == DEAD) //marines_list replaces mob refs of gibbed marines with just a name string
		to_chat(usr, "[icon2html(src, usr)] [span_warning("[H] is KIA!")]")
		return
	if(H == current_squad.squad_leader)
		to_chat(usr, "[icon2html(src, usr)] [span_warning("[H] is already the Squad Leader!")]")
		return
	if(is_banned_from(H.ckey, SQUAD_LEADER))
		to_chat(usr, "[icon2html(src, usr)] [span_warning("[H] is unfit to lead!")]")
		return
	if(current_squad.squad_leader)
		current_squad.message_squad("Attention: [current_squad.squad_leader] is [current_squad.squad_leader.stat == DEAD ? "stepping down" : "demoted"]. A new Squad Leader has been set: [H.real_name].")
		if(issilicon(usr))
			to_chat(usr, span_boldnotice("Squad Leader [current_squad.squad_leader] of squad '[current_squad]' has been [current_squad.squad_leader.stat == DEAD ? "replaced" : "demoted and replaced"] by [H.real_name]! Logging to enlistment files."))
		visible_message(span_boldnotice("Squad Leader [current_squad.squad_leader] of squad '[current_squad]' has been [current_squad.squad_leader.stat == DEAD ? "replaced" : "demoted and replaced"] by [H.real_name]! Logging to enlistment files."))
		current_squad.demote_leader()
	else
		current_squad.message_squad("Attention: A new Squad Leader has been set: [H.real_name].")
		if(issilicon(usr))
			to_chat(usr, span_boldnotice("[H.real_name] is the new Squad Leader of squad '[current_squad]'! Logging to enlistment file."))
		visible_message(span_boldnotice("[H.real_name] is the new Squad Leader of squad '[current_squad]'! Logging to enlistment file."))

	to_chat(H, "[icon2html(src, H)] <font size='3' color='blue'><B>\[Overwatch\]: You've been promoted to \'[ismarineleaderjob(H.job) ? "SQUAD LEADER" : "ACTING SQUAD LEADER"]\' for [current_squad.name]. Your headset has access to the command channel (:v).</B></font>")
	to_chat(usr, "[icon2html(src, usr)] [H.real_name] is [current_squad]'s new leader!")
	current_squad.promote_leader(H)


/obj/machinery/computer/camera_advanced/overwatch/proc/mark_insubordination()
	if(!usr || usr != operator)
		return
	if(!current_squad)
		to_chat(usr, "[icon2html(src, usr)] [span_warning("No squad selected!")]")
		return
	var/mob/living/carbon/human/wanted_marine = tgui_input_list(usr, "Report a marine for insubordination", null, current_squad.get_all_members())
	if(!wanted_marine) return
	if(!istype(wanted_marine))//gibbed/deleted, all we have is a name.
		to_chat(usr, "[icon2html(src, usr)] [span_warning("[wanted_marine] is missing in action.")]")
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
						if(issilicon(usr))
							to_chat(usr, span_boldnotice("[wanted_marine] has been reported for insubordination. Logging to enlistment file."))
						visible_message(span_boldnotice("[wanted_marine] has been reported for insubordination. Logging to enlistment file."))
						to_chat(wanted_marine, "[icon2html(src, wanted_marine)] <font size='3' color='blue'><B>\[Overwatch\]:</b> You've been reported for insubordination by your overwatch officer.</font>")
						wanted_marine.sec_hud_set_security_status()
					return

/obj/machinery/computer/camera_advanced/overwatch/proc/transfer_squad()
	if(!usr || usr != operator)
		return
	if(!current_squad)
		to_chat(usr, "[icon2html(src, usr)] [span_warning("No squad selected!")]")
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
		to_chat(usr, "[icon2html(src, usr)] [span_warning("[transfer_marine] is KIA.")]")
		return

	if(!istype(transfer_marine.wear_id, /obj/item/card/id))
		to_chat(usr, "[icon2html(src, usr)] [span_warning("Transfer aborted. [transfer_marine] isn't wearing an ID.")]")
		return

	var/datum/squad/new_squad = tgui_input_list(usr, "Choose the marine's new squad", null,  watchable_squads)
	if(!new_squad)
		return

	if(S != current_squad)
		return

	if(!istype(transfer_marine) || transfer_marine.stat == DEAD)
		to_chat(usr, "[icon2html(src, usr)] [span_warning("[transfer_marine] is KIA.")]")
		return

	if(!istype(transfer_marine.wear_id, /obj/item/card/id))
		to_chat(usr, "[icon2html(src, usr)] [span_warning("Transfer aborted. [transfer_marine] isn't wearing an ID.")]")
		return

	var/datum/squad/old_squad = transfer_marine.assigned_squad
	if(new_squad == old_squad)
		to_chat(usr, "[icon2html(src, usr)] [span_warning("[transfer_marine] is already in [new_squad]!")]")
		return

	if(ismarineleaderjob(transfer_marine.job) && new_squad.current_positions[/datum/job/terragov/squad/leader] >= SQUAD_MAX_POSITIONS(transfer_marine.job.total_positions))
		to_chat(usr, "[icon2html(src, usr)] [span_warning("Transfer aborted. [new_squad] can't have another [transfer_marine.job.title].")]")
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
	if(issilicon(usr))
		to_chat(usr, span_boldnotice("[transfer_marine] has been transfered from squad '[old_squad]' to squad '[new_squad]'. Logging to enlistment file."))
	visible_message(span_boldnotice("[transfer_marine] has been transfered from squad '[old_squad]' to squad '[new_squad]'. Logging to enlistment file."))
	to_chat(transfer_marine, "[icon2html(src, transfer_marine)] <font size='3' color='blue'><B>\[Overwatch\]:</b> You've been transfered to [new_squad]!</font>")

///This is an orbital light. Basically, huge thing which the CIC can use to light up areas for a bit of time.
/obj/machinery/computer/camera_advanced/overwatch/proc/attempt_spotlight(datum/source, atom/A, params)
	SIGNAL_HANDLER

	if(!powered())
		return 0

	var/area/here_we_are = get_area(src)
	var/obj/machinery/power/apc/myAPC = here_we_are.get_apc()

	var/power_amount = myAPC?.terminal?.powernet?.avail

	if(power_amount <= 10000)
		return

	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_ORBITAL_SPOTLIGHT))
		to_chat(source, span_notice("The Orbital spotlight is still recharging."))
		return
	var/area/place = get_area(A)
	if(istype(place) && place.ceiling >= CEILING_UNDERGROUND)
		to_chat(source, span_warning("You cannot illuminate this place. It is probably underground."))
		return
	var/turf/target = get_turf(A)
	if(!target)
		return
	new /obj/effect/overwatch_light(target)
	use_power(10000)	//Huge light needs big power. Still less than autodocs.
	TIMER_COOLDOWN_START(src, COOLDOWN_ORBITAL_SPOTLIGHT, SPOTLIGHT_COOLDOWN_DURATION)
	to_chat(source, span_notice("Orbital spotlight activated. Duration : [SPOTLIGHT_DURATION]"))

//This is an effect to be sure it is properly deleted and it does not interfer with existing lights too much.
/obj/effect/overwatch_light
	name = "overwatch beam of light"
	desc = "You are not supposed to see this. Please report it."
	icon_state = "" //No sprite
	invisibility = INVISIBILITY_MAXIMUM
	resistance_flags = RESIST_ALL
	light_system = STATIC_LIGHT
	light_color = COLOR_TESLA_BLUE
	light_range = 15	//This is a HUGE light.
	light_power = SQRTWO

/obj/effect/overwatch_light/Initialize()
	. = ..()
	set_light(light_range, light_power)
	playsound(src,'sound/mecha/heavylightswitch.ogg', 25, 1, 20)
	visible_message(span_warning("You see a twinkle in the sky before your surroundings are hit with a beam of light!"))
	QDEL_IN(src, SPOTLIGHT_DURATION)

//This is perhaps one of the weirdest places imaginable to put it, but it's a leadership skill, so

/mob/living/carbon/human/verb/issue_order(command_aura as null|text)
	set hidden = TRUE

	if(skills.getRating("leadership") < SKILL_LEAD_TRAINED)
		to_chat(src, span_warning("You are not competent enough in leadership to issue an order."))
		return

	if(stat)
		to_chat(src, span_warning("You cannot give an order in your current state."))
		return

	if(IsMute())
		to_chat(src, span_warning("You cannot give an order while muted."))
		return

	if(command_aura_cooldown)
		to_chat(src, span_warning("You have recently given an order. Calm down."))
		return

	if(!command_aura)
		command_aura = tgui_input_list(src, "Choose an order", items = command_aura_allowed + "help")
		if(command_aura == "help")
			to_chat(src, span_notice("<br>Orders give a buff to nearby soldiers for a short period of time, followed by a cooldown, as follows:<br><B>Move</B> - Increased mobility and chance to dodge projectiles.<br><B>Hold</B> - Increased resistance to pain and combat wounds.<br><B>Focus</B> - Increased gun accuracy and effective range.<br>"))
			return
		if(!command_aura)
			return

	if(command_aura_cooldown)
		to_chat(src, span_warning("You have recently given an order. Calm down."))
		return

	if(!(command_aura in command_aura_allowed))
		return
	var/aura_strength = skills.getRating("leadership") - 1
	var/aura_target = pick_order_target()
	SSaura.add_emitter(aura_target, command_aura, aura_strength + 4, aura_strength, 30 SECONDS, faction)

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

	command_aura_cooldown = addtimer(CALLBACK(src, .proc/end_command_aura_cooldown), 45 SECONDS)

	update_action_buttons()

///Choose what we're sending a buff order through
/mob/living/carbon/human/proc/pick_order_target()
	//If we're in overwatch, use the camera eye
	if(istype(remote_control, /mob/camera/aiEye/remote/hud/overwatch))
		return remote_control
	return src

/mob/living/carbon/human/proc/end_command_aura_cooldown()
	command_aura_cooldown = null
	update_action_buttons()

/datum/action/skill/issue_order
	name = "Issue Order"
	skill_name = "leadership"
	action_icon = 'icons/mob/order_icons.dmi'
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
	action_icon_state = "[order_type]"
	return ..()

/datum/action/skill/issue_order/handle_button_status_visuals()
	var/mob/living/carbon/human/human = owner
	if(!istype(human))
		return
	if(human.command_aura_cooldown)
		button.color = rgb(255,0,0,255)
	else
		button.color = rgb(255,255,255,255)

/datum/action/skill/issue_order/move
	name = "Issue Move Order"
	order_type = AURA_HUMAN_MOVE
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_KB_MOVEORDER,
	)

/datum/action/skill/issue_order/hold
	name = "Issue Hold Order"
	order_type = AURA_HUMAN_HOLD
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_KB_HOLDORDER,
	)

/datum/action/skill/issue_order/focus
	name = "Issue Focus Order"
	order_type = AURA_HUMAN_FOCUS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_KB_FOCUSORDER,
	)

/datum/action/skill/toggle_orders
	name = "Show/Hide Order Options"
	skill_name = "leadership"
	skill_min = SKILL_LEAD_TRAINED
	var/orders_visible = TRUE

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
	for(var/datum/squad/squad AS in watchable_squads)
		if(squad.id == id)
			return squad
	return FALSE

/obj/machinery/computer/camera_advanced/overwatch/proc/get_squad_info()
	var/dat = ""
	if(!current_squad)
		dat += "No Squad selected!<BR>"
		dat += get_squad_info_ending()
		return dat
	var/leader_text = ""
	var/leader_count = 0
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
	dat += "<b>Squad Smartgunners: [smart_count] Deployed</b><br>"
	dat += "<b>Squad Corpsmen: [medic_count] Deployed | Squad Engineers: [engi_count] Deployed</b><br>"
	dat += "<b>Squad Marines: [marine_count] Deployed</b><br>"
	dat += "<b>Total: [current_squad.get_total_members()] Deployed</b><br>"
	dat += "<b>Marines alive: [living_count]</b><br><br>"
	dat += "<table border='1' style='width:100%' align='center'><tr>"
	dat += "<th>Name</th><th>Role</th><th>State</th><th>Location</th><th>SL Distance</th></tr>"
	if(!living_marines_sorting)
		dat += leader_text + medic_text + engi_text + smart_text + marine_text + misc_text
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
/obj/machinery/computer/camera_advanced/overwatch/proc/send_order(datum/source, atom/target)
	SIGNAL_HANDLER
	if(!current_order)
		var/mob/user = source
		to_chat(user, span_warning("You have no order selected."))
		return
	current_order.send_order(target, faction = faction)

///Setter for the current order
/obj/machinery/computer/camera_advanced/overwatch/proc/set_order(datum/source, datum/action/innate/order/order)
	SIGNAL_HANDLER
	current_order = order

#undef OW_MAIN
#undef OW_MONITOR
