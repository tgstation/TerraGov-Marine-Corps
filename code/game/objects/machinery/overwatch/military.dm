/obj/machinery/computer/camera_advanced/overwatch/military
	///Ref of the lase that's had an OB warning mark placed on the minimap
	var/obj/effect/overlay/temp/laser_target/ob/marked_lase
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
	///Static list of CIC radial options for the camera when clicking on a marine
	var/static/list/human_radial_options = list(
		MESSAGE_SINGLE = image(icon = 'icons/mob/radial.dmi', icon_state = "cic_message_single"),
		ASL = image(icon = 'icons/mob/radial.dmi', icon_state = "cic_asl"),
		SWITCH_SQUAD = image(icon = 'icons/mob/radial.dmi', icon_state = "cic_switch_squad"),
	)
	///Static list of CIC radial options for the camera when clicking on an OB marker
	var/static/list/bombardment_radial_options = list(
		MARK_LASE = image(icon = 'icons/mob/radial.dmi', icon_state = "cic_mark_ob"),
		FIRE_LASE = image(icon = 'icons/mob/radial.dmi', icon_state = "cic_fire_ob"),
	)
	///Static list of CIC radial options for the camera when clicking on a turf
	var/static/list/turf_radial_options = list(
		ORBITAL_SPOTLIGHT = image(icon = 'icons/mob/radial.dmi', icon_state = "cic_orbital_spotlight"),
		MESSAGE_NEAR = image(icon = 'icons/mob/radial.dmi', icon_state = "cic_message_near"),
		SQUAD_ACTIONS =  image(icon = 'icons/mob/radial.dmi', icon_state = "cic_squad_actions"),
	)
	///Static list of CIC radial options for the camera when having clicked on a turf and selected Squad Actions
	var/static/list/squad_radial_options = list(
		MESSAGE_SQUAD = image(icon = 'icons/mob/radial.dmi', icon_state = "cic_message_near"),
		SWITCH_SQUAD_NEAR = image(icon = 'icons/mob/radial.dmi', icon_state = "cic_switch_squad_near"),
	)

/obj/machinery/computer/camera_advanced/overwatch/military/Initialize(mapload)
	. = ..()
	send_attack_order = new
	send_defend_order = new
	send_retreat_order = new
	send_rally_order = new

/obj/machinery/computer/camera_advanced/overwatch/military/Destroy()
	QDEL_NULL(send_attack_order)
	QDEL_NULL(send_defend_order)
	QDEL_NULL(send_retreat_order)
	QDEL_NULL(send_rally_order)
	selected_target = null
	current_order = null
	marked_lase = null
	return ..()

/obj/machinery/computer/camera_advanced/overwatch/military/give_actions(mob/living/user)
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

/obj/machinery/computer/camera_advanced/overwatch/military/give_eye_control(mob/user)
	. = ..()
	RegisterSignal(user, COMSIG_MOB_CLICK_SHIFT, PROC_REF(send_order))
	RegisterSignal(user, COMSIG_ORDER_SELECTED, PROC_REF(set_order))
	RegisterSignal(user, COMSIG_MOB_MIDDLE_CLICK, PROC_REF(attempt_radial))
	RegisterSignal(SSdcs, COMSIG_GLOB_OB_LASER_CREATED, PROC_REF(alert_lase))


/obj/machinery/computer/camera_advanced/overwatch/military/remove_eye_control(mob/living/user)
	. = ..()
	UnregisterSignal(user, list(COMSIG_MOB_CLICK_SHIFT, COMSIG_ORDER_SELECTED, COMSIG_MOB_MIDDLE_CLICK))
	UnregisterSignal(SSdcs, COMSIG_GLOB_OB_LASER_CREATED)

/obj/machinery/computer/camera_advanced/overwatch/military/get_dat()
	var/dat
	if(!operator)
		dat += "<BR><B>Operator:</b> <A href='byond://?src=[text_ref(src)];operation=change_operator'>----------</A><BR>"
		return dat
	dat += "<BR><B>Operator:</b> <A href='byond://?src=[text_ref(src)];operation=change_operator'>[operator.name]</A><BR>"
	dat += "   <A href='byond://?src=[text_ref(src)];operation=logout'>{Stop Overwatch}</A><BR>"
	dat += "----------------------<br>"
	if(overwatch_flags & OVERWATCH_ON_MONITOR)
		dat += get_squad_info()
		return dat

	if(!current_squad) //No squad has been set yet. Pick one.
		dat += "<br>Current Squad: <A href='byond://?src=[text_ref(src)];operation=pick_squad'>----------</A><BR>"
		return dat

	dat += "<br><b>[current_squad.name] Squad</A></b>   "
	dat += "<A href='byond://?src=[text_ref(src)];operation=message'>\[Message Squad\]</a><br><br>"
	dat += "----------------------<BR><BR>"
	if(current_squad.squad_leader)
		dat += "<B>Squad Leader:</B> <A href='byond://?src=[text_ref(src)];operation=use_cam;cam_target=\ref[current_squad.squad_leader]'>[current_squad.squad_leader.name]</a> "
		dat += "<A href='byond://?src=[text_ref(src)];operation=sl_message'>\[MSG\]</a> "
		dat += "<A href='byond://?src=[text_ref(src)];operation=change_lead'>\[CHANGE SQUAD LEADER\]</a><BR><BR>"
	else
		dat += "<B>Squad Leader:</B> <font color=red>NONE</font> <A href='byond://?src=[text_ref(src)];operation=change_lead'>\[ASSIGN SQUAD LEADER\]</a><BR><BR>"

	dat += "<B>Primary Objective:</B> "
	if(current_squad.primary_objective)
		dat += "[current_squad.primary_objective] <a href='byond://?src=[text_ref(src)];operation=set_primary'>\[Set\]</a><br>"
	else
		dat += "<b><font color=red>NONE!</font></b> <a href='byond://?src=[text_ref(src)];operation=set_primary'>\[Set\]</a><br>"
	dat += "<b>Secondary Objective:</b> "
	if(current_squad.secondary_objective)
		dat += "[current_squad.secondary_objective] <a href='byond://?src=[text_ref(src)];operation=set_secondary'>\[Set\]</a><br>"
	else
		dat += "<b><font color=red>NONE!</font></b> <a href='byond://?src=[text_ref(src)];operation=set_secondary'>\[Set\]</a><br>"
	dat += "<br>"
	dat += "<A href='byond://?src=[text_ref(src)];operation=insubordination'>Report a marine for insubordination</a><BR>"
	dat += "<A href='byond://?src=[text_ref(src)];operation=squad_transfer'>Transfer a marine to another squad</a><BR><BR>"
	dat += "<a href='byond://?src=[text_ref(src)];operation=monitor'>Squad Monitor</a><br>"
	dat += "----------------------<br>"

	dat += get_firesupport_data()

	dat += "<br><br><a href='byond://?src=[text_ref(src)];operation=refresh'>{Refresh}</a>"
	return dat

/obj/machinery/computer/camera_advanced/overwatch/military/main/get_dat()
	var/dat
	if(!operator)
		dat += "<BR><B>Operator:</b> <A href='byond://?src=[text_ref(src)];operation=change_operator'>----------</A><BR>"
		return dat
	dat += "<BR><B>Operator:</b> <A href='byond://?src=[text_ref(src)];operation=change_operator'>[operator.name]</A><BR>"
	dat += "   <A href='byond://?src=[text_ref(src)];operation=logout'>{Stop Overwatch}</A><BR>"
	dat += "----------------------<br>"
	if(overwatch_flags & OVERWATCH_ON_MONITOR)
		dat += get_squad_info()
		return dat

	for(var/datum/squad/S AS in watchable_squads)
		dat += "<b>[S.name] Squad</b> <a href='byond://?src=[text_ref(src)];operation=message;current_squad=[text_ref(S)]'>\[Message Squad\]</a><br>"
		if(S.squad_leader)
			dat += "<b>Leader:</b> <a href='byond://?src=[text_ref(src)];operation=use_cam;cam_target=\ref[S.squad_leader]'>[S.squad_leader.name]</a> "
			dat += "<a href='byond://?src=[text_ref(src)];operation=sl_message;current_squad=[text_ref(S)]'>\[MSG\]</a><br>"
		else
			dat += "<b>Leader:</b> <font color=red>NONE</font><br>"
		if(S.overwatch_officer)
			dat += "<b>Squad Overwatch:</b> [S.overwatch_officer.name]<br>"
		else
			dat += "<b>Squad Overwatch:</b> <font color=red>NONE</font><br>"
		dat += "<A href='byond://?src=[text_ref(src)];operation=monitor;squad_id=[S.id]'>[S.name] Squad Monitor</a><br>"
	dat += "----------------------<br>"

	dat += get_firesupport_data()

	dat += "<A href='byond://?src=[text_ref(src)];operation=refresh'>{Refresh}</a>"
	return dat

/obj/machinery/computer/camera_advanced/overwatch/military/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(!href_list["operation"])
		return

	switch(href_list["operation"])
		if("logout_main")
			selected_target = null
		if("back")
			current_squad = null
		if("use_cam")
			selected_target = locate(href_list["selected_target"])
		if("message")
			if(current_squad && operator == usr)
				if(TIMER_COOLDOWN_RUNNING(operator, COOLDOWN_HUD_ORDER))
					to_chat(operator, span_warning("You've sent an announcement or message too recently!"))
					return
				var/input = tgui_input_text(operator, "Please write a message to announce to the squad:", "Squad Message", max_length = MAX_COMMAND_MESSAGE_LENGTH)
				if(input)
					current_squad.message_squad(input, operator) //message, adds username
					if(issilicon(operator))
						to_chat(operator, span_boldnotice("Message sent to all Marines of squad '[current_squad]'."))
					visible_message(span_boldnotice("Message sent to all Marines of squad '[current_squad]'."))
		if("sl_message")
			if(current_squad && operator == usr)
				if(TIMER_COOLDOWN_RUNNING(operator, COOLDOWN_HUD_ORDER))
					to_chat(operator, span_warning("You've sent an announcement or message too recently!"))
					return
				var/input = tgui_input_text(operator, "Please write a message to announce to the squad leader:", "SL Message", max_length = MAX_COMMAND_MESSAGE_LENGTH)
				if(input)
					TIMER_COOLDOWN_START(operator, COOLDOWN_HUD_ORDER, CIC_ORDER_COOLDOWN)
					message_member(current_squad.squad_leader, input, operator)
					if(issilicon(operator))
						to_chat(operator, span_boldnotice("Message sent to Squad Leader [current_squad.squad_leader] of squad '[current_squad]'."))
					visible_message(span_boldnotice("Message sent to Squad Leader [current_squad.squad_leader] of squad '[current_squad]'."))
		if("set_primary")
			var/input = tgui_input_text(operator, "What will be the squad's primary objective?", "Primary Objective", max_length = MAX_COMMAND_MESSAGE_LENGTH * 0.75)
			if( is_ic_filtered(input) || NON_ASCII_CHECK(input))
				to_chat(operator, span_boldnotice("Message invalid. Check your message does not contain filtered words or characters."))
				return
			current_squad.primary_objective = input + " ([worldtime2text()])"
			current_squad.message_squad("Primary objective updated; see game panel for details.")
			if(issilicon(operator))
				to_chat(operator, span_boldnotice("Primary objective of squad '[current_squad]' set."))
			visible_message(span_boldnotice("Primary objective of squad '[current_squad]' set."))
		if("set_secondary")
			var/input = tgui_input_text(operator, "What will be the squad's secondary objective?", "Secondary Objective", max_length = MAX_COMMAND_MESSAGE_LENGTH * 0.75)
			if( is_ic_filtered(input) || NON_ASCII_CHECK(input))
				to_chat(operator, span_boldnotice("Message invalid. Check your message does not contain filtered words or characters."))
				return
			current_squad.secondary_objective = input + " ([worldtime2text()])"
			current_squad.message_squad("Secondary objective updated; see game panel for details.")
			if(issilicon(operator))
				to_chat(operator, span_boldnotice("Secondary objective of squad '[current_squad]' set."))
			visible_message(span_boldnotice("Secondary objective of squad '[current_squad]' set."))
		if("change_lead")
			if(operator != usr)
				return
			if(!current_squad)
				to_chat(operator, "[icon2html(src, operator)] [span_warning("No squad selected!")]")
				return
			var/sl_candidates = list()
			for(var/mob/living/carbon/human/target in current_squad.get_all_members())
				if(istype(target) && target.stat != DEAD && target.mind && !is_banned_from(target.ckey, SQUAD_LEADER))
					sl_candidates += target
			var/new_lead = tgui_input_list(operator, "Choose a new Squad Leader", null, sl_candidates)
			if(!new_lead || new_lead == "Cancel")
				return
			change_lead(operator, new_lead)
		if("insubordination")
			mark_insubordination()
		if("squad_transfer")
			if(!current_squad)
				to_chat(operator, "[icon2html(src, operator)] [span_warning("No squad selected!")]")
				return
			var/datum/squad/S = current_squad
			var/mob/living/carbon/human/transfer_marine = tgui_input_list(operator, "Choose marine to transfer", null, current_squad.get_all_members())

			if(!transfer_marine)
				return
			if(S != current_squad)
				return //don't change overwatched squad, idiot.

			var/datum/squad/new_squad = tgui_input_list(operator, "Choose the marine's new squad", null,  watchable_squads)

			transfer_squad(operator, transfer_marine, new_squad)
		if("dropbomb")
			handle_bombard()
		if("shootrailgun")
			if(operator.interactee != src)
				to_chat(operator, "[icon2html(src, operator)] [span_warning("You're busy doing something else, and press the wrong button!")]")
				return
			if((GLOB.rail_gun?.last_firing + 600) > world.time)
				to_chat(operator, "[icon2html(src, operator)] [span_warning("The Rail Gun hasn't cooled down yet!")]")
			else if(!selected_target)
				to_chat(operator, "[icon2html(src, operator)] [span_warning("No target detected!")]")
			else
				GLOB.rail_gun?.fire_rail_gun(get_turf(selected_target),operator)
	updateUsrDialog()

///Provides details on available firesupport options
/obj/machinery/computer/camera_advanced/overwatch/military/proc/get_firesupport_data()
	var/list/target_list = current_squad ? current_squad.squad_laser_targets : GLOB.active_laser_targets //if theres no current squad, this should be a main overwatch console
	var/dat
	dat += "<b>Orbital Bombardment Control</b><br>"
	dat += "<b>Current Cannon Status:</b> "
	if(!GLOB.orbital_cannon?.chambered_tray)
		dat += "<font color='red'>No ammo chambered in the cannon.</font><br>"
	else
		dat += "<font color='green'>Ready!</font><br>"
	dat += "<B>[current_squad ? "[current_squad.name] " : ""]Laser Targets:</b><br>"
	if(length(target_list))
		for(var/obj/effect/overlay/temp/laser_target/ob_lase AS in target_list)
			if(ob_lase.lasertype != LASER_TYPE_OB)
				continue
			dat += "<a href='byond://?src=[REF(src)];operation=use_cam;cam_target=[REF(ob_lase)];selected_target=[REF(ob_lase)]'>[ob_lase.name]</a><br>"
	else
		dat += "[span_warning("None")]<br>"
	dat += "<b>Selected Target:</b><br>"
	if(!selected_target) // Clean the targets if nothing is selected
		dat += "[span_warning("None")]<br>"
	else if(!(selected_target in target_list) && !(selected_target in GLOB.active_orbital_beacons)) // Or available
		dat += "[span_warning("None")]<br>"
		selected_target = null
	else
		dat += "<font color='green'>[selected_target.name]</font><br>"
	dat += "<A href='byond://?src=[text_ref(src)];operation=dropbomb'>\[FIRE!\]</a><br>"
	dat += "----------------------<BR>"

	dat += "<b>Rail Gun Control</b><br>"
	dat += "<b>Current Rail Gun Status:</b> "
	var/cooldown_left = (GLOB.rail_gun?.last_firing + 600) - world.time // 60 seconds between shots
	if(cooldown_left > 0)
		dat += "Rail Gun on cooldown ([round(cooldown_left/10)] seconds)<br>"
	else if(!GLOB.rail_gun?.rail_gun_ammo?.ammo_count)
		dat += "<font color='red'>Ammo depleted.</font><br>"
	else
		dat += "<font color='green'>Ready!</font><br>"
	dat += "<B>[current_squad ? "[current_squad.name] " : ""]Laser Targets:</b><br>"
	if(length(target_list))
		for(var/obj/effect/overlay/temp/laser_target/lase AS in target_list) //for whatever reason we can fire railgun on any lase type... in practical terms, any type EXCEPT railgun
			dat += "<a href='byond://?src=[REF(src)];operation=use_cam;cam_target=[REF(lase)];selected_target=[REF(lase)]'>[lase.name]</a><br>"
	else
		dat += "[span_warning("None")]<br>"
	dat += "<b>Selected Target:</b><br>"
	if(!selected_target) // Clean the targets if nothing is selected
		dat += "[span_warning("None")]<br>"
	else if(!(selected_target in target_list) && !(selected_target in GLOB.active_orbital_beacons)) // Or available
		dat += "[span_warning("None")]<br>"
		selected_target = null
	else
		dat += "<font color='green'>[selected_target.name]</font><br>"
	dat += "<A href='byond://?src=[text_ref(src)];operation=shootrailgun'>\[FIRE!\]</a><br>"
	dat += "----------------------<br>"
	return dat

///Signal handler for radial menu
/obj/machinery/computer/camera_advanced/overwatch/military/proc/attempt_radial(datum/source, atom/A, params)
	SIGNAL_HANDLER
	if(SEND_SIGNAL(operator, COMSIG_DO_OVERWATCH_RADIAL) & OVERWATCH_RADIAL_HIDE)
		return
	INVOKE_ASYNC(src, PROC_REF(do_radial), source, A, params)

///Quick-select radial menu for Overwatch
/obj/machinery/computer/camera_advanced/overwatch/military/proc/do_radial(datum/source, atom/A, params)
	var/mob/living/carbon/human/human_target
	var/obj/effect/overlay/temp/laser_target/ob/laser_target
	var/turf/turf_target
	var/choice
	if(ishuman(A))
		human_target = A
		choice = show_radial_menu(source, human_target, human_radial_options, null, 48, null, FALSE, TRUE)

	else if(istype(A, /obj/effect/overlay/temp/laser_target/ob))
		laser_target = A
		choice = show_radial_menu(source, laser_target, bombardment_radial_options, null, 48, null, FALSE, TRUE)
	else
		turf_target = get_turf(A)
		choice = show_radial_menu(source, turf_target, turf_radial_options, null, 48, null, FALSE, TRUE)

	switch(choice)
		if(MESSAGE_SINGLE)
			if(TIMER_COOLDOWN_RUNNING(operator, COOLDOWN_HUD_ORDER))
				to_chat(operator, span_warning("You've sent an announcement or message too recently!"))
				return
			var/input = tgui_input_text(source, "Please write a message to announce to this marine:", "CIC Message", max_length = MAX_COMMAND_MESSAGE_LENGTH)
			message_member(human_target, input, source)
			TIMER_COOLDOWN_START(operator, COOLDOWN_HUD_ORDER, CIC_ORDER_COOLDOWN)
		if(ASL)
			if(human_target == human_target.assigned_squad.squad_leader)
				human_target.assigned_squad.demote_leader()
				return
			change_lead(source, human_target)
		if(SWITCH_SQUAD)
			var/datum/squad/desired_squad = squad_select(source, human_target)
			transfer_squad(source, human_target, desired_squad)
		if(MARK_LASE)
			if(marked_lase)
				remove_mark_from_lase() //There can only be one
				marked_lase = laser_target
			SSminimaps.add_marker(laser_target, MINIMAP_FLAG_ALL, image('icons/UI_icons/map_blips.dmi', null, "ob_warning", MINIMAP_LOCATOR_LAYER))
			addtimer(CALLBACK(src, PROC_REF(remove_mark_from_lase)), 30 SECONDS)
		if(FIRE_LASE)
			selected_target = laser_target
			handle_bombard()
		if(ORBITAL_SPOTLIGHT)
			attempt_spotlight(source, turf_target, params)
		if(MESSAGE_NEAR)
			if(TIMER_COOLDOWN_RUNNING(operator, COOLDOWN_HUD_ORDER))
				to_chat(operator, span_warning("You've sent an announcement or message too recently!"))
				return
			var/input = tgui_input_text(source, "Please write a message to announce to all marines nearby:", "CIC Proximity Message", max_length = MAX_COMMAND_MESSAGE_LENGTH)
			for(var/mob/living/carbon/human/target in GLOB.alive_human_list_faction[faction])
				if(!target)
					return
				if(get_dist(target, turf_target) > WORLD_VIEW_NUM*2)
					continue
				message_member(target, input, source)
			message_member(source, input, source)
			TIMER_COOLDOWN_START(operator, COOLDOWN_HUD_ORDER, CIC_ORDER_COOLDOWN)
		if(SQUAD_ACTIONS)
			choice = show_radial_menu(source, turf_target, squad_radial_options, null, 48, null, FALSE, TRUE)
			var/datum/squad/chosen_squad = squad_select(source, turf_target)
			switch(choice)
				if(MESSAGE_SQUAD)
					if(TIMER_COOLDOWN_RUNNING(operator, COOLDOWN_HUD_ORDER))
						to_chat(operator, span_warning("You've sent an announcement or message too recently!"))
						return
					var/input = tgui_input_text(source, "Please write a message to announce to the squad:", "Squad Message", max_length = MAX_COMMAND_MESSAGE_LENGTH)
					if(input)
						chosen_squad.message_squad(input, source)
						TIMER_COOLDOWN_START(operator, COOLDOWN_HUD_ORDER, CIC_ORDER_COOLDOWN)
				if(SWITCH_SQUAD_NEAR)
					for(var/mob/living/carbon/human/target in GLOB.human_mob_list)
						if(!target.faction == faction || get_dist(target, turf_target) > 9)
							continue
						transfer_squad(source, target, chosen_squad)

///Removes any active marks on OB lases, if any
/obj/machinery/computer/camera_advanced/overwatch/military/proc/remove_mark_from_lase()
	if(marked_lase)
		SSminimaps.remove_marker(marked_lase)
		marked_lase = null

///This is an orbital light. Basically, huge thing which the CIC can use to light up areas for a bit of time.
/obj/machinery/computer/camera_advanced/overwatch/military/proc/attempt_spotlight(datum/source, atom/A, params)
	if(!powered())
		return 0

	var/area/here_we_are = get_area(src)
	var/obj/machinery/power/apc/myAPC = here_we_are.get_apc()

	var/power_amount = myAPC?.terminal?.powernet?.avail

	if(power_amount <= 10000)
		return

	if(TIMER_COOLDOWN_RUNNING(src, COOLDOWN_ORBITAL_SPOTLIGHT))
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

//Print order visual to all marines squad hud and give them an arrow to follow the waypoint
/obj/machinery/computer/camera_advanced/overwatch/military/proc/send_order(datum/source, atom/target)
	SIGNAL_HANDLER
	if(!current_order)
		var/mob/user = source
		to_chat(user, span_warning("You have no order selected."))
		return
	current_order.send_order(target, faction = faction)

///Setter for the current order
/obj/machinery/computer/camera_advanced/overwatch/military/proc/set_order(datum/source, datum/action/innate/order/order)
	SIGNAL_HANDLER
	current_order = order

///Messages all available squads
/obj/machinery/computer/camera_advanced/overwatch/military/proc/send_to_squads(txt)
	for(var/datum/squad/squad AS in watchable_squads)
		squad.message_squad(txt)

///Checks and warnings before OB starts to fire
/obj/machinery/computer/camera_advanced/overwatch/military/proc/handle_bombard()
	if(!operator)
		return
	if(overwatch_flags & OVERWATCH_BUSY)
		to_chat(operator, "[icon2html(src, operator)] [span_warning("The [name] is busy processing another action!")]")
		return
	if(!GLOB.orbital_cannon?.chambered_tray)
		to_chat(operator, "[icon2html(src, operator)] [span_warning("The orbital cannon has no ammo chambered.")]")
		return
	if(!selected_target)
		to_chat(operator, "[icon2html(src, operator)] [span_warning("No target detected!")]")
		return
	var/area/A = get_area(selected_target)
	if(istype(A) && A.ceiling >= CEILING_UNDERGROUND)
		to_chat(operator, "[icon2html(src, operator)] [span_warning("The target's signal is too weak.")]")
		return
	var/turf/T = get_turf(selected_target)
	if(!isturf(T)) //Huh?
		to_chat(operator, "[icon2html(src, operator)] [span_warning("Invalid target.")]")
		return
	if(isspaceturf(T))
		to_chat(operator, "[icon2html(src, operator)] [span_warning("The target's landing zone appears to be out of bounds.")]")
		return
	overwatch_flags |= OVERWATCH_BUSY //All set, let's do this.
	var/warhead_type = GLOB.orbital_cannon?.tray.warhead.name	//For the AI and Admin logs.

	for(var/mob/living/silicon/ai/AI AS in GLOB.ai_list)
		to_chat(AI, span_warning("NOTICE - Orbital bombardment triggered from overwatch consoles. Warhead type: [warhead_type]. Target: [AREACOORD_NO_Z(T)]"))
		playsound(AI,'sound/machines/triple_beep.ogg', 25, 1, 20)

	if(A)
		log_attack("[key_name(operator)] fired a [warhead_type]in for squad [current_squad] in [AREACOORD(T)].")
		message_admins("[ADMIN_TPMONTY(operator)] fired a [warhead_type]for squad [current_squad] in [ADMIN_VERBOSEJMP(T)].")
	visible_message(span_boldnotice("Orbital bombardment request accepted. Orbital cannons are now calibrating."))
	send_to_squads("ORBITAL BOMBARDMENT INBOUND AT [get_area(selected_target)]! Type: [warhead_type]!")
	if(selected_target)
		playsound(selected_target.loc,'sound/effects/alert.ogg', 50, 1, 20)  //mostly used to warn xenos as the new ob sounds have a quiet beginning

	addtimer(CALLBACK(src, PROC_REF(do_fire_bombard), T, operator), 3.1 SECONDS)

///Lets anyone using an overwatch console know that an OB has just been lased
/obj/machinery/computer/camera_advanced/overwatch/military/proc/alert_lase(datum/source, obj/effect/overlay/temp/laser_target/ob/incoming_laser)
	SIGNAL_HANDLER
	if(!operator)
		return
	to_chat(operator, span_notice("Orbital Bombardment laser detected. Target: [AREACOORD_NO_Z(incoming_laser)]"))
	operator.playsound_local(source, 'sound/effects/binoctarget.ogg', 15)

///About to fire
/obj/machinery/computer/camera_advanced/overwatch/military/proc/do_fire_bombard(turf/T, user)
	visible_message(span_boldnotice("Orbital bombardment has fired! Impact imminent!"))
	addtimer(CALLBACK(src, PROC_REF(do_land_bombard), T, user), 2.5 SECONDS)

///Randomises OB impact location a little and tells the OB cannon to fire
/obj/machinery/computer/camera_advanced/overwatch/military/proc/do_land_bombard(turf/T, user)
	overwatch_flags &= ~OVERWATCH_BUSY
	var/x_offset = rand(-2,2) //Little bit of randomness.
	var/y_offset = rand(-2,2)
	var/turf/target = locate(T.x + x_offset,T.y + y_offset,T.z)
	if(target && istype(target))
		target.ceiling_debris_check(5)
		GLOB.orbital_cannon?.fire_ob_cannon(target,user)

///Changes the current squad leader
/obj/machinery/computer/camera_advanced/overwatch/military/proc/change_lead(datum/source, mob/living/carbon/human/target)
	if(!source || source != operator)
		return
	if(!istype(target) || !target.mind || target.stat == DEAD) //marines_list replaces mob refs of gibbed marines with just a name string
		to_chat(source, "[icon2html(src, source)] [span_warning("[target] is KIA!")]")
		return
	var/datum/squad/target_squad = target.assigned_squad
	if(target == target_squad.squad_leader)
		to_chat(source, "[icon2html(src, source)] [span_warning("[target] is already the Squad Leader!")]")
		return
	if(is_banned_from(target.ckey, SQUAD_LEADER))
		to_chat(source, "[icon2html(src, source)] [span_warning("[target] is unfit to lead!")]")
		return
	if(target_squad.squad_leader)
		target_squad.message_squad("Acting Squad Leader updated to [target.real_name].")
		if(issilicon(source))
			to_chat(source, span_boldnotice("Squad Leader [target_squad.squad_leader] of squad '[target_squad]' has been [target_squad.squad_leader.stat == DEAD ? "replaced" : "demoted and replaced"] by [target.real_name]! Logging to enlistment files."))
		visible_message(span_boldnotice("Squad Leader [target_squad.squad_leader] of squad '[target_squad]' has been [target_squad.squad_leader.stat == DEAD ? "replaced" : "demoted and replaced"] by [target.real_name]! Logging to enlistment files."))
		target_squad.demote_leader()
	else
		target_squad.message_squad("Acting Squad Leader updated to [target.real_name].")
		if(issilicon(source))
			to_chat(source, span_boldnotice("[target.real_name] is the new Squad Leader of squad '[target_squad]'! Logging to enlistment file."))
		visible_message(span_boldnotice("[target.real_name] is the new Squad Leader of squad '[target_squad]'! Logging to enlistment file."))

	to_chat(target, "[icon2html(src, target)] <font size='3' color='blue'><B>\[Overwatch\]: You've been promoted to \'[(ismarineleaderjob(target.job) || issommarineleaderjob(target.job)) ? "SQUAD LEADER" : "ACTING SQUAD LEADER"]\' for [target_squad.name]. Your headset has access to the command channel (:v).</B></font>")
	to_chat(source, "[icon2html(src, source)] [target.real_name] is [target_squad]'s new leader!")
	target_squad.promote_leader(target)

///Marks a marine for insubordination
/obj/machinery/computer/camera_advanced/overwatch/military/proc/mark_insubordination()
	if(!usr || usr != operator)
		return
	if(!current_squad)
		to_chat(operator, "[icon2html(src, operator)] [span_warning("No squad selected!")]")
		return
	var/mob/living/carbon/human/wanted_marine = tgui_input_list(operator, "Report a marine for insubordination", null, current_squad.get_all_members())
	if(!wanted_marine) return
	if(!istype(wanted_marine))//gibbed/deleted, all we have is a name.
		to_chat(operator, "[icon2html(src, operator)] [span_warning("[wanted_marine] is missing in action.")]")
		return

	for (var/datum/data/record/E in GLOB.datacore.general)
		if(E.fields["name"] == wanted_marine.real_name)
			for (var/datum/data/record/R in GLOB.datacore.security)
				if (R.fields["id"] == E.fields["id"])
					if(!findtext(R.fields["ma_crim"],"Insubordination."))
						R.fields["criminal"] = "*Arrest*"
						if(R.fields["ma_crim"] == "None")
							R.fields["ma_crim"] = "Insubordination."
						else
							R.fields["ma_crim"] += "Insubordination."
						if(issilicon(operator))
							to_chat(operator, span_boldnotice("[wanted_marine] has been reported for insubordination. Logging to enlistment file."))
						visible_message(span_boldnotice("[wanted_marine] has been reported for insubordination. Logging to enlistment file."))
						to_chat(wanted_marine, "[icon2html(src, wanted_marine)] <font size='3' color='blue'><B>\[Overwatch\]:</b> You've been reported for insubordination by your overwatch officer.</font>")
						wanted_marine.sec_hud_set_security_status()
					return

///Moves a marine to another squad
/obj/machinery/computer/camera_advanced/overwatch/military/proc/transfer_squad(datum/source, mob/living/carbon/human/transfer_marine, datum/squad/new_squad)
	if(!source || source != operator)
		return

	if(!transfer_marine.job)
		CRASH("[transfer_marine] selected for transfer without a job.")

	if(!istype(transfer_marine)) //gibbed
		to_chat(source, "[icon2html(src, source)] [span_warning("[transfer_marine] is KIA.")]")
		return

	if(!istype(transfer_marine.wear_id, /obj/item/card/id))
		to_chat(source, "[icon2html(src, source)] [span_warning("Transfer aborted. [transfer_marine] isn't wearing an ID.")]")
		return

	if(!new_squad)
		return

	if((ismarineleaderjob(transfer_marine.job) || issommarineleaderjob(transfer_marine.job)) && new_squad.current_positions[transfer_marine.job.type] >= SQUAD_MAX_POSITIONS(transfer_marine.job.total_positions))
		to_chat(source, "[icon2html(src, source)] [span_warning("Transfer aborted. [new_squad] can't have another [transfer_marine.job.title].")]")
		return

	var/datum/squad/old_squad = transfer_marine.assigned_squad
	if(new_squad == old_squad)
		to_chat(source, "[icon2html(src, source)] [span_warning("[transfer_marine] is already in [new_squad]!")]")
		return

	if(old_squad)
		if(old_squad.squad_leader == transfer_marine)
			old_squad.demote_leader()
		old_squad.remove_from_squad(transfer_marine)
	new_squad.insert_into_squad(transfer_marine)

	for(var/datum/data/record/t in GLOB.datacore.general) //we update the crew manifest
		if(t.fields["name"] == transfer_marine.real_name)
			t.fields["squad"] = new_squad.name
			break

	var/obj/item/card/id/ID = transfer_marine.wear_id
	ID.assigned_fireteam = 0 //reset fireteam assignment

	//Changes headset frequency to match new squad
	var/obj/item/radio/headset/mainship/marine/headset = transfer_marine.wear_ear
	if(istype(headset, /obj/item/radio/headset/mainship/marine))
		headset.set_frequency(new_squad.radio_freq)

	transfer_marine.hud_set_job()
	if(issilicon(source))
		to_chat(source, span_boldnotice("[transfer_marine] has been transfered from squad '[old_squad]' to squad '[new_squad]'. Logging to enlistment file."))
	visible_message(span_boldnotice("[transfer_marine] has been transfered from squad '[old_squad]' to squad '[new_squad]'. Logging to enlistment file."))
	to_chat(transfer_marine, "[icon2html(src, transfer_marine)] <font size='3' color='blue'><B>\[Overwatch\]:</b> You've been transfered to [new_squad]!</font>")

///Messages a specific individual
/obj/machinery/computer/camera_advanced/overwatch/military/proc/message_member(mob/living/target, message, mob/living/carbon/human/sender)
	if(!target.client)
		return
	. = TRUE

	target.playsound_local(target, "sound/machines/dotprinter.ogg", 35)
	to_chat(target, span_notice("<b><i>New message from [sender.real_name]:</b> [message]</i>"))
	target.play_screen_text(HUD_ANNOUNCEMENT_FORMATTING("CIC MESSAGE FROM [sender.real_name]", capitalize(message), LEFT_ALIGN_TEXT), new /atom/movable/screen/text/screen_text/picture/potrait/custom_mugshot(null, null, sender), "#32cd32")

	var/list/tts_listeners = filter_tts_listeners(sender, target, null, RADIO_TTS_COMMAND)
	if(!length(tts_listeners))
		return
	var/list/treated_message = sender?.treat_message(message)
	var/list/extra_filters = list(TTS_FILTER_RADIO)
	if(isrobot(sender))
		extra_filters += TTS_FILTER_SILICON
	INVOKE_ASYNC(SStts, TYPE_PROC_REF(/datum/controller/subsystem/tts, queue_tts_message), sender, treated_message["tts_message"], sender.get_default_language(), sender.voice, sender.voice_filter, tts_listeners, FALSE, pitch = sender.pitch, special_filters = extra_filters.Join("|"), directionality = FALSE)

///Radial menu squad select menu
/obj/machinery/computer/camera_advanced/overwatch/military/proc/squad_select(datum/source, atom/A)
	var/list/squad_options = list()

	for(var/datum/squad/squad AS in watchable_squads)
		var/image/squad_icon = image(icon = 'icons/mob/radial.dmi', icon_state = "cic_squad_box")
		squad_icon.color = squad.color
		squad_options += list(squad.name = squad_icon)

	return SSjob.squads_by_name[faction][show_radial_menu(source, A, squad_options, null, 48, null, FALSE, TRUE)]

#undef MAX_COMMAND_MESSAGE_LENGTH
