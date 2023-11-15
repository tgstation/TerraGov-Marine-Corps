#define OW_MAIN 0
#define OW_MONITOR 1

#define HIDE_NONE 0
#define HIDE_ON_GROUND 1
#define HIDE_ON_SHIP 2

#define SPOTLIGHT_COOLDOWN_DURATION 6 MINUTES
#define SPOTLIGHT_DURATION 2 MINUTES


#define MESSAGE_SINGLE "Message this marine"
#define ASL "Set or un-set as aSL"
#define SWITCH_SQUAD "Switch this marine's squad"

#define MARK_LASE "Mark this lase on minimap"
#define FIRE_LASE "!!FIRE OB!!"

#define ORBITAL_SPOTLIGHT "Shine orbital spotlight"
#define MESSAGE_NEAR "Message all nearby marines"
#define SQUAD_ACTIONS "Open squad actions menu"

#define MESSAGE_SQUAD "Message all marines in a squad"
#define SWITCH_SQUAD_NEAR "Move all nearby marines to a squad"


GLOBAL_LIST_EMPTY(active_orbital_beacons)
GLOBAL_LIST_EMPTY(active_laser_targets)
GLOBAL_LIST_EMPTY(active_cas_targets)
/obj/machinery/computer/camera_advanced/overwatch
	name = "Overwatch Console"
	desc = "State of the art machinery for giving orders to a squad. <b>Shift click</b> to send order when watching squads."
	density = FALSE
	icon_state = "overwatch"
	screen_overlay = "overwatch_screen"
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
	///Groundside minimap for overwatch
	var/datum/action/minimap/marine/external/cic_mini
	///Overrides the minimap action minimap and marker flags
	var/map_flags = MINIMAP_FLAG_MARINE
	///Ref of the lase that's had an OB warning mark placed on the minimap
	var/obj/effect/overlay/temp/laser_target/OB/marked_lase
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

/obj/machinery/computer/camera_advanced/overwatch/Initialize(mapload)
	. = ..()
	send_attack_order = new
	send_defend_order = new
	send_retreat_order = new
	send_rally_order = new
	cic_mini = new(null, map_flags, map_flags)
	GLOB.main_overwatch_consoles += src

/obj/machinery/computer/camera_advanced/overwatch/Destroy()
	QDEL_NULL(send_attack_order)
	QDEL_NULL(send_defend_order)
	QDEL_NULL(send_retreat_order)
	QDEL_NULL(send_rally_order)
	QDEL_NULL(cic_mini)
	GLOB.main_overwatch_consoles -= src
	current_order = null
	selected_target = null
	current_squad = null
	marked_lase = null
	return ..()

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
	if(cic_mini)
		cic_mini.target = user
		cic_mini.give_action(user)
		actions += cic_mini

/obj/machinery/computer/camera_advanced/overwatch/main
	icon_state = "overwatch_main"
	screen_overlay = "overwatch_main_screen"
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
	screen_overlay = "overwatch_req_screen"
	name = "Requisition Overwatch Console"
	desc = "Big Brother Requisition demands to see money flowing into the void that is greed."
	circuit = /obj/item/circuitboard/computer/supplyoverwatch

/obj/machinery/computer/camera_advanced/overwatch/som
	faction = FACTION_SOM
	icon_state = "som_console"
	screen_overlay = "som_overwatch_emissive"
	light_color = LIGHT_COLOR_FLARE
	networks = list(SOM_CAMERA_NETWORK)
	req_access = list(ACCESS_MARINE_BRIDGE)
	map_flags = MINIMAP_FLAG_MARINE_SOM

/obj/machinery/computer/camera_advanced/overwatch/main/som
	faction = FACTION_SOM
	icon_state = "som_console"
	screen_overlay = "som_main_overwatch_emissive"
	light_color = LIGHT_COLOR_FLARE
	networks = list(SOM_CAMERA_NETWORK)
	req_access = list(ACCESS_MARINE_BRIDGE)
	map_flags = MINIMAP_FLAG_MARINE_SOM

/obj/machinery/computer/camera_advanced/overwatch/som/zulu
	name = "\improper Zulu Overwatch Console"

/obj/machinery/computer/camera_advanced/overwatch/som/yankee
	name = "\improper Yankee Overwatch Console"

/obj/machinery/computer/camera_advanced/overwatch/som/xray
	name = "\improper X-ray Overwatch Console"

/obj/machinery/computer/camera_advanced/overwatch/som/whiskey
	name = "\improper Whiskey Overwatch Console"

/obj/machinery/computer/camera_advanced/overwatch/CreateEye()
	eyeobj = new(null, parent_cameranet, faction)
	eyeobj.origin = src
	RegisterSignal(eyeobj, COMSIG_QDELETING, PROC_REF(clear_eye_ref))
	eyeobj.visible_icon = TRUE
	eyeobj.icon = 'icons/mob/cameramob.dmi'
	eyeobj.icon_state = "generic_camera"
	cic_mini.override_locator(eyeobj)

/obj/machinery/computer/camera_advanced/overwatch/give_eye_control(mob/user)
	. = ..()
	RegisterSignal(user, COMSIG_MOB_CLICK_SHIFT, PROC_REF(send_order))
	RegisterSignal(user, COMSIG_ORDER_SELECTED, PROC_REF(set_order))
	RegisterSignal(user, COMSIG_MOB_MIDDLE_CLICK, PROC_REF(attempt_radial))
	RegisterSignal(SSdcs, COMSIG_GLOB_OB_LASER_CREATED, PROC_REF(alert_lase))

/obj/machinery/computer/camera_advanced/overwatch/remove_eye_control(mob/living/user)
	. = ..()
	UnregisterSignal(user, COMSIG_MOB_CLICK_SHIFT)
	UnregisterSignal(user, COMSIG_ORDER_SELECTED)
	UnregisterSignal(user, COMSIG_MOB_MIDDLE_CLICK)
	UnregisterSignal(SSdcs, COMSIG_GLOB_OB_LASER_CREATED)

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
		dat += "<BR><B>Operator:</b> <A href='?src=[text_ref(src)];operation=change_operator'>----------</A><BR>"
	else
		dat += "<BR><B>Operator:</b> <A href='?src=[text_ref(src)];operation=change_operator'>[operator.name]</A><BR>"
		dat += "   <A href='?src=[text_ref(src)];operation=logout'>{Stop Overwatch}</A><BR>"
		dat += "----------------------<br>"
		switch(state)
			if(OW_MAIN)
				if(!current_squad) //No squad has been set yet. Pick one.
					dat += "<br>Current Squad: <A href='?src=[text_ref(src)];operation=pick_squad'>----------</A><BR>"
				else
					dat += "<br><b>[current_squad.name] Squad</A></b>   "
					dat += "<A href='?src=[text_ref(src)];operation=message'>\[Message Squad\]</a><br><br>"
					dat += "----------------------<BR><BR>"
					if(current_squad.squad_leader)
						dat += "<B>Squad Leader:</B> <A href='?src=[text_ref(src)];operation=use_cam;cam_target=\ref[current_squad.squad_leader]'>[current_squad.squad_leader.name]</a> "
						dat += "<A href='?src=[text_ref(src)];operation=sl_message'>\[MSG\]</a> "
						dat += "<A href='?src=[text_ref(src)];operation=change_lead'>\[CHANGE SQUAD LEADER\]</a><BR><BR>"
					else
						dat += "<B>Squad Leader:</B> <font color=red>NONE</font> <A href='?src=[text_ref(src)];operation=change_lead'>\[ASSIGN SQUAD LEADER\]</a><BR><BR>"

					dat += "<B>Primary Objective:</B> "
					if(current_squad.primary_objective)
						dat += "[current_squad.primary_objective] <a href='?src=[text_ref(src)];operation=set_primary'>\[Set\]</a><br>"
					else
						dat += "<b><font color=red>NONE!</font></b> <a href='?src=[text_ref(src)];operation=set_primary'>\[Set\]</a><br>"
					dat += "<b>Secondary Objective:</b> "
					if(current_squad.secondary_objective)
						dat += "[current_squad.secondary_objective] <a href='?src=[text_ref(src)];operation=set_secondary'>\[Set\]</a><br>"
					else
						dat += "<b><font color=red>NONE!</font></b> <a href='?src=[text_ref(src)];operation=set_secondary'>\[Set\]</a><br>"
					dat += "<br>"
					dat += "<A href='?src=[text_ref(src)];operation=insubordination'>Report a marine for insubordination</a><BR>"
					dat += "<A href='?src=[text_ref(src)];operation=squad_transfer'>Transfer a marine to another squad</a><BR><BR>"
					dat += "<a href='?src=[text_ref(src)];operation=monitor'>Squad Monitor</a><br>"
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
					dat += "<A href='?src=[text_ref(src)];operation=shootrailgun'>\[FIRE!\]</a><br>"
					dat += "----------------------<br>"
					dat += "<br><br><a href='?src=[text_ref(src)];operation=refresh'>{Refresh}</a>"
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
		if("monitorzulu_squad")
			state = OW_MONITOR
			current_squad = get_squad_by_id(ZULU_SQUAD)
		if("monitoryankee_squad")
			state = OW_MONITOR
			current_squad = get_squad_by_id(YANKEE_SQUAD)
		if("monitorxray_squad")
			state = OW_MONITOR
			current_squad = get_squad_by_id(XRAY_SQUAD)
		if("monitorwhiskey_squad")
			state = OW_MONITOR
			current_squad = get_squad_by_id(WHISKEY_SQUAD)
		if("change_operator")
			if(operator != usr)
				if(current_squad)
					current_squad.overwatch_officer = usr
				operator = usr
				var/mob/living/carbon/human/H = operator
				var/obj/item/card/id/ID = H.get_idcard()
				if(issilicon(operator))
					to_chat(operator, span_boldnotice("Basic overwatch systems initialized. Welcome, [ID ? "[ID.rank] ":""][operator.name]. Please select a squad."))
				visible_message(span_boldnotice("Basic overwatch systems initialized. Welcome, [ID ? "[ID.rank] ":""][operator.name]. Please select a squad."))
		if("change_main_operator")
			if(operator != usr)
				operator = usr
				var/mob/living/carbon/human/H = operator
				var/obj/item/card/id/ID = H.get_idcard()
				if(issilicon(operator))
					to_chat(operator, span_boldnotice("Main overwatch systems initialized. Welcome, [ID ? "[ID.rank] ":""][operator.name]."))
				visible_message(span_boldnotice("Main overwatch systems initialized. Welcome, [ID ? "[ID.rank] ":""][operator.name]."))
		if("logout")
			if(!current_squad)
				return
			var/obj/item/card/id/ID = operator.get_idcard()
			current_squad.overwatch_officer = null //Reset the squad's officer.
			if(issilicon(operator))
				to_chat(operator, span_boldnotice("Overwatch systems deactivated. Goodbye, [ID ? "[ID.rank] ":""][operator ? "[operator.name]":"sysadmin"]."))
			visible_message(span_boldnotice("Overwatch systems deactivated. Goodbye, [ID ? "[ID.rank] ":""][operator ? "[operator.name]":"sysadmin"]."))
			operator = null
			current_squad = null
			state = OW_MAIN
		if("logout_main")
			var/obj/item/card/id/ID = operator.get_idcard()
			if(issilicon(operator))
				to_chat(operator, span_boldnotice("Main overwatch systems deactivated. Goodbye, [ID ? "[ID.rank] ":""][operator ? "[operator.name]":"sysadmin"]."))
			visible_message(span_boldnotice("Main overwatch systems deactivated. Goodbye, [ID ? "[ID.rank] ":""][operator ? "[operator.name]":"sysadmin"]."))
			operator = null
			current_squad = null
			selected_target = null
			state = OW_MAIN
		if("pick_squad")
			if(operator != usr)
				return
			if(current_squad)
				to_chat(operator, span_warning("[icon2html(src, operator)] You are already selecting a squad."))
				return
			var/datum/squad/selected = tgui_input_list(operator, "Which squad would you like to claim for Overwatch?", null, watchable_squads)
			if(!selected || operator != usr)
				return
			selected.overwatch_officer = operator //Link everything together, squad, console, and officer
			current_squad = selected
			if(issilicon(operator))
				to_chat(operator, span_boldnotice("Tactical data for squad '[current_squad]' loaded. All tactical functions initialized."))
			visible_message(span_boldnotice("Tactical data for squad '[current_squad]' loaded. All tactical functions initialized."))
			attack_hand(operator)
		if("message")
			if(current_squad && operator == usr)
				var/input = tgui_input_text(operator, "Please write a message to announce to the squad:", "Squad Message")
				if(input)
					current_squad.message_squad(input, operator) //message, adds username
					if(issilicon(operator))
						to_chat(operator, span_boldnotice("Message sent to all Marines of squad '[current_squad]'."))
					visible_message(span_boldnotice("Message sent to all Marines of squad '[current_squad]'."))
		if("sl_message")
			if(current_squad && operator == usr)
				var/input = tgui_input_text(operator, "Please write a message to announce to the squad leader:", "SL Message")
				if(input)
					message_member(current_squad.squad_leader, input, operator)
					if(issilicon(operator))
						to_chat(operator, span_boldnotice("Message sent to Squad Leader [current_squad.squad_leader] of squad '[current_squad]'."))
					visible_message(span_boldnotice("Message sent to Squad Leader [current_squad.squad_leader] of squad '[current_squad]'."))
		if("set_primary")
			var/input = tgui_input_text(operator, "What will be the squad's primary objective?", "Primary Objective")
			if( is_ic_filtered(input) || NON_ASCII_CHECK(input))
				to_chat(operator, span_boldnotice("Message invalid. Check your message does not contain filtered words or characters."))
				return
			current_squad.primary_objective = input + " ([worldtime2text()])"
			current_squad.message_squad("Primary objective updated; see game panel for details.")
			if(issilicon(operator))
				to_chat(operator, span_boldnotice("Primary objective of squad '[current_squad]' set."))
			visible_message(span_boldnotice("Primary objective of squad '[current_squad]' set."))
		if("set_secondary")
			var/input = tgui_input_text(operator, "What will be the squad's secondary objective?", "Secondary Objective")
			if( is_ic_filtered(input) || NON_ASCII_CHECK(input))
				to_chat(operator, span_boldnotice("Message invalid. Check your message does not contain filtered words or characters."))
				return
			current_squad.secondary_objective = input + " ([worldtime2text()])"
			current_squad.message_squad("Secondary objective updated; see game panel for details.")
			if(issilicon(operator))
				to_chat(operator, span_boldnotice("Secondary objective of squad '[current_squad]' set."))
			visible_message(span_boldnotice("Secondary objective of squad '[current_squad]' set."))
		if("refresh")
			attack_hand(operator)
		if("change_sort")
			living_marines_sorting = !living_marines_sorting
			if(living_marines_sorting)
				to_chat(operator, "[icon2html(src, operator)] [span_notice("Marines are now sorted by health status.")]")
			else
				to_chat(operator, "[icon2html(src, operator)] [span_notice("Marines are now sorted by rank.")]")
		if("hide_dead")
			dead_hidden = !dead_hidden
			if(dead_hidden)
				to_chat(operator, "[icon2html(src, operator)] [span_notice("Dead marines are now not shown.")]")
			else
				to_chat(operator, "[icon2html(src, operator)] [span_notice("Dead marines are now shown again.")]")
		if("choose_z")
			switch(z_hidden)
				if(HIDE_NONE)
					z_hidden = HIDE_ON_SHIP
					to_chat(operator, "[icon2html(src, operator)] [span_notice("Marines on the [SSmapping.configs[SHIP_MAP].map_name] are now hidden.")]")
				if(HIDE_ON_SHIP)
					z_hidden = HIDE_ON_GROUND
					to_chat(operator, "[icon2html(src, operator)] [span_notice("Marines on the ground are now hidden.")]")
				if(HIDE_ON_GROUND)
					z_hidden = HIDE_NONE
					to_chat(operator, "[icon2html(src, operator)] [span_notice("No location is ignored anymore.")]")

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
			if((GLOB.marine_main_ship?.rail_gun?.last_firing + 600) > world.time)
				to_chat(operator, "[icon2html(src, operator)] [span_warning("The Rail Gun hasn't cooled down yet!")]")
			else if(!selected_target)
				to_chat(operator, "[icon2html(src, operator)] [span_warning("No target detected!")]")
			else
				GLOB.marine_main_ship?.rail_gun?.fire_rail_gun(get_turf(selected_target),operator)
		if("back")
			state = OW_MAIN
		if("use_cam")
			selected_target = locate(href_list["selected_target"])
			if(!isAI(operator))
				var/atom/cam_target = locate(href_list["cam_target"])
				if(!cam_target)
					return
				var/turf/cam_target_turf = get_turf(cam_target)
				if(!cam_target_turf)
					return
				open_prompt(operator)
				eyeobj.setLoc(cam_target_turf)
				if(isliving(cam_target))
					var/mob/living/L = cam_target
					track(L)
				else
					to_chat(operator, "[icon2html(src, operator)] [span_notice("Jumping to the latest available location of [cam_target].")]")

	updateUsrDialog()


/obj/machinery/computer/camera_advanced/overwatch/main/interact(mob/living/user)
	. = ..()
	if(.)
		return

	var/dat
	if(!operator)
		dat += "<B>Main Operator:</b> <A href='?src=[text_ref(src)];operation=change_main_operator'>----------</A><BR>"
	else
		dat += "<B>Main Operator:</b> <A href='?src=[text_ref(src)];operation=change_main_operator'>[operator.name]</A><BR>"
		dat += "   <A href='?src=[text_ref(src)];operation=logout_main'>{Stop Overwatch}</A><BR>"
		dat += "----------------------<br>"
		switch(state)
			if(OW_MAIN)
				for(var/datum/squad/S AS in watchable_squads)
					dat += "<b>[S.name] Squad</b> <a href='?src=[text_ref(src)];operation=message;current_squad=[text_ref(S)]'>\[Message Squad\]</a><br>"
					if(S.squad_leader)
						dat += "<b>Leader:</b> <a href='?src=[text_ref(src)];operation=use_cam;cam_target=\ref[S.squad_leader]'>[S.squad_leader.name]</a> "
						dat += "<a href='?src=[text_ref(src)];operation=sl_message;current_squad=[text_ref(S)]'>\[MSG\]</a><br>"
					else
						dat += "<b>Leader:</b> <font color=red>NONE</font><br>"
					if(S.overwatch_officer)
						dat += "<b>Squad Overwatch:</b> [S.overwatch_officer.name]<br>"
					else
						dat += "<b>Squad Overwatch:</b> <font color=red>NONE</font><br>"
					dat += "<A href='?src=[text_ref(src)];operation=monitor[S.id]'>[S.name] Squad Monitor</a><br>"
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
				dat += "<A href='?src=[text_ref(src)];operation=dropbomb'>\[FIRE!\]</a><br>"
				dat += "----------------------<BR>"
				dat += "<A href='?src=[text_ref(src)];operation=refresh'>{Refresh}</a>"
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
		dat += "<B>Main Operator:</b> <A href='?src=[text_ref(src)];operation=change_main_operator'>----------</A><BR>"
	else
		dat += "<B>Main Operator:</b> <A href='?src=[text_ref(src)];operation=change_main_operator'>[operator.name]</A><BR>"
		dat += "   <A href='?src=[text_ref(src)];operation=logout_main'>{Stop Overwatch}</A><BR>"
		dat += "----------------------<br>"
		switch(state)
			if(OW_MAIN)
				for(var/datum/squad/S AS in watchable_squads)
					dat += "<b>[S.name] Squad</b> <a href='?src=[text_ref(src)];operation=message;current_squad=[text_ref(S)]'>\[Message Squad\]</a><br>"
					if(S.squad_leader)
						dat += "<b>Leader:</b> <a href='?src=[text_ref(src)];operation=use_cam;cam_target=\ref[S.squad_leader]'>[S.squad_leader.name]</a> "
						dat += "<a href='?src=[text_ref(src)];operation=sl_message;current_squad=[text_ref(S)]'>\[MSG\]</a><br>"
					else
						dat += "<b>Leader:</b> <font color=red>NONE</font><br>"
					if(S.overwatch_officer)
						dat += "<b>Squad Overwatch:</b> [S.overwatch_officer.name]<br>"
					else
						dat += "<b>Squad Overwatch:</b> <font color=red>NONE</font><br>"
					dat += "<A href='?src=[text_ref(src)];operation=monitor[S.id]'>[S.name] Squad Monitor</a><br>"
			if(OW_MONITOR)//Info screen.
				dat += get_squad_info()

	var/datum/browser/popup = new(user, "overwatch", "<div align='center'>Requisition Overwatch Console</div>", 550, 550)
	popup.set_content(dat)
	popup.open()

/obj/machinery/computer/camera_advanced/overwatch/proc/send_to_squads(txt)
	for(var/datum/squad/squad AS in watchable_squads)
		squad.message_squad(txt)

///Checks and warnings before OB starts to fire
/obj/machinery/computer/camera_advanced/overwatch/proc/handle_bombard()
	if(!operator)
		return
	if(busy)
		to_chat(operator, "[icon2html(src, operator)] [span_warning("The [name] is busy processing another action!")]")
		return
	if(!GLOB.marine_main_ship?.orbital_cannon?.chambered_tray)
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
	busy = TRUE //All set, let's do this.
	var/warhead_type = GLOB.marine_main_ship.orbital_cannon.tray.warhead.name	//For the AI and Admin logs.

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
/obj/machinery/computer/camera_advanced/overwatch/proc/alert_lase(datum/source, obj/effect/overlay/temp/laser_target/OB/incoming_laser)
	SIGNAL_HANDLER
	if(!operator)
		return
	to_chat(operator, span_notice("Orbital Bombardment laser detected. Target: [AREACOORD_NO_Z(incoming_laser)]"))
	operator.playsound_local(source, 'sound/effects/binoctarget.ogg', 15)

///About to fire
/obj/machinery/computer/camera_advanced/overwatch/proc/do_fire_bombard(turf/T, user)
	visible_message(span_boldnotice("Orbital bombardment has fired! Impact imminent!"))
	addtimer(CALLBACK(src, PROC_REF(do_land_bombard), T, user), 2.5 SECONDS)

///Randomises OB impact location a little and tells the OB cannon to fire
/obj/machinery/computer/camera_advanced/overwatch/proc/do_land_bombard(turf/T, user)
	busy = FALSE
	var/x_offset = rand(-2,2) //Little bit of randomness.
	var/y_offset = rand(-2,2)
	var/turf/target = locate(T.x + x_offset,T.y + y_offset,T.z)
	if(target && istype(target))
		target.ceiling_debris_check(5)
		GLOB.marine_main_ship?.orbital_cannon?.fire_ob_cannon(target,user)

/obj/machinery/computer/camera_advanced/overwatch/proc/change_lead(datum/source, mob/living/carbon/human/target)
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


/obj/machinery/computer/camera_advanced/overwatch/proc/mark_insubordination()
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

/obj/machinery/computer/camera_advanced/overwatch/proc/transfer_squad(datum/source, mob/living/carbon/human/transfer_marine, datum/squad/new_squad)
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

/obj/machinery/computer/camera_advanced/overwatch/proc/message_member(mob/living/target, message, mob/living/carbon/human/sender)
	if(!target.client)
		return
	target.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:center valign='top'><u>CIC MESSAGE FROM [sender.real_name]:</u></span><br>" + message, /atom/movable/screen/text/screen_text/command_order)
	return TRUE

///Signal handler for radial menu
/obj/machinery/computer/camera_advanced/overwatch/proc/attempt_radial(datum/source, atom/A, params)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(do_radial), source, A, params)

///Quick-select radial menu for Overwatch
/obj/machinery/computer/camera_advanced/overwatch/proc/do_radial(datum/source, atom/A, params)
	var/mob/living/carbon/human/human_target
	var/obj/effect/overlay/temp/laser_target/OB/laser_target
	var/turf/turf_target
	var/choice
	if(ishuman(A))
		human_target = A
		choice = show_radial_menu(source, human_target, human_radial_options, null, 48, null, FALSE, TRUE)

	else if(istype(A, /obj/effect/overlay/temp/laser_target/OB))
		laser_target = A
		choice = show_radial_menu(source, laser_target, bombardment_radial_options, null, 48, null, FALSE, TRUE)
	else
		turf_target = get_turf(A)
		choice = show_radial_menu(source, turf_target, turf_radial_options, null, 48, null, FALSE, TRUE)

	switch(choice)
		if(MESSAGE_SINGLE)
			var/input = tgui_input_text(source, "Please write a message to announce to this marine:", "CIC Message")
			message_member(human_target, input, source)
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
			SSminimaps.add_marker(laser_target, MINIMAP_FLAG_ALL, image('icons/UI_icons/map_blips.dmi', null, "ob_warning"))
			addtimer(CALLBACK(src, PROC_REF(remove_mark_from_lase)), 30 SECONDS)
		if(FIRE_LASE)
			selected_target = laser_target
			handle_bombard()
		if(ORBITAL_SPOTLIGHT)
			attempt_spotlight(source, turf_target, params)
		if(MESSAGE_NEAR)
			var/input = tgui_input_text(source, "Please write a message to announce to all marines nearby:", "CIC Proximity Message")
			for(var/mob/living/carbon/human/target in GLOB.alive_human_list_faction[faction])
				if(!target)
					return
				if(get_dist(target, turf_target) > WORLD_VIEW_NUM*2)
					continue
				message_member(target, input, source)
			message_member(source, input, source)
		if(SQUAD_ACTIONS)
			choice = show_radial_menu(source, turf_target, squad_radial_options, null, 48, null, FALSE, TRUE)
			var/datum/squad/chosen_squad = squad_select(source, turf_target)
			switch(choice)
				if(MESSAGE_SQUAD)
					var/input = tgui_input_text(source, "Please write a message to announce to the squad:", "Squad Message")
					if(input)
						chosen_squad.message_squad(input, source)
				if(SWITCH_SQUAD_NEAR)
					for(var/mob/living/carbon/human/target in GLOB.human_mob_list)
						if(!target.faction == faction || get_dist(target, turf_target) > 9)
							continue
						transfer_squad(source, target, chosen_squad)
///Radial squad select menu.
/obj/machinery/computer/camera_advanced/overwatch/proc/squad_select(datum/source, atom/A)
	var/list/squad_options = list()

	for(var/datum/squad/squad AS in watchable_squads)
		var/image/squad_icon = image(icon = 'icons/mob/radial.dmi', icon_state = "cic_squad_box")
		squad_icon.color = squad.color
		squad_options += list(squad.name = squad_icon)

	return SSjob.squads_by_name[faction][show_radial_menu(source, A, squad_options, null, 48, null, FALSE, TRUE)]

///Removes any active marks on OB lases, if any
/obj/machinery/computer/camera_advanced/overwatch/proc/remove_mark_from_lase()
	if(marked_lase)
		SSminimaps.remove_marker(marked_lase)
		marked_lase = null


///This is an orbital light. Basically, huge thing which the CIC can use to light up areas for a bit of time.
/obj/machinery/computer/camera_advanced/overwatch/proc/attempt_spotlight(datum/source, atom/A, params)
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

/obj/effect/overwatch_light/Initialize(mapload)
	. = ..()
	set_light(light_range, light_power)
	playsound(src,'sound/mecha/heavylightswitch.ogg', 25, 1, 20)
	visible_message(span_warning("You see a twinkle in the sky before your surroundings are hit with a beam of light!"))
	QDEL_IN(src, SPOTLIGHT_DURATION)

//This is perhaps one of the weirdest places imaginable to put it, but it's a leadership skill, so

/mob/living/carbon/human/verb/issue_order(command_aura as null|text)
	set hidden = TRUE

	if(skills.getRating(SKILL_LEADERSHIP) < SKILL_LEAD_TRAINED)
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
			to_chat(src, span_notice("<br>Orders give a buff to nearby marines for a short period of time, followed by a cooldown, as follows:<br><B>Move</B> - Increased mobility and chance to dodge projectiles.<br><B>Hold</B> - Increased resistance to pain and combat wounds.<br><B>Focus</B> - Increased gun accuracy and effective range.<br>"))
			return
		if(!command_aura)
			return

	if(command_aura_cooldown)
		to_chat(src, span_warning("You have recently given an order. Calm down."))
		return

	if(!(command_aura in command_aura_allowed))
		return
	var/aura_strength = skills.getRating(SKILL_LEADERSHIP) - 1
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

	command_aura_cooldown = addtimer(CALLBACK(src, PROC_REF(end_command_aura_cooldown)), 45 SECONDS)

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
	skill_name = SKILL_LEADERSHIP
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
	skill_name = SKILL_LEADERSHIP
	skill_min = SKILL_LEAD_TRAINED
	var/orders_visible = TRUE
	action_icon_state = "hide_order"

/datum/action/skill/toggle_orders/action_activate()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return
	if(orders_visible)
		orders_visible = FALSE
		action_icon_state = "show_order"
		for(var/datum/action/skill/path in owner.actions)
			if(istype(path, /datum/action/skill/issue_order))
				path.remove_action(H)
	else
		orders_visible = TRUE
		action_icon_state = "hide_order"
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
				if(!ismarineleaderjob(H.job) && !issommarineleaderjob(H.job))
					act_sl = " (acting SL)"
			else if(M_turf && SL_z && M_turf.z == SL_z)
				dist = "[get_dist(H, current_squad.squad_leader)] ([dir2text_short(get_dir(current_squad.squad_leader, H))])"
		switch(H.stat)
			if(CONSCIOUS)
				mob_state = "Conscious"
				living_count++
				conscious_text += "<tr><td><A href='?src=[text_ref(src)];operation=use_cam;cam_target=[text_ref(H)]'>[mob_name]</a></td><td>[role][act_sl]</td><td>[mob_state]</td><td>[area_name]</td><td>[dist]</td></tr>"
			if(UNCONSCIOUS)
				mob_state = "<b>Unconscious</b>"
				living_count++
				unconscious_text += "<tr><td><A href='?src=[text_ref(src)];operation=use_cam;cam_target=[text_ref(H)]'>[mob_name]</a></td><td>[role][act_sl]</td><td>[mob_state]</td><td>[area_name]</td><td>[dist]</td></tr>"
			if(DEAD)
				if(dead_hidden)
					continue
				mob_state = "<font color='red'>DEAD</font>"
				dead_text += "<tr><td><A href='?src=[text_ref(src)];operation=use_cam;cam_target=[text_ref(H)]'>[mob_name]</a></td><td>[role][act_sl]</td><td>[mob_state]</td><td>[area_name]</td><td>[dist]</td></tr>"
		if((!H.key || !H.client) && H.stat != DEAD)
			mob_state += " (SSD)"
		var/obj/item/card/id/ID = H.wear_id
		if(ID?.assigned_fireteam)
			fteam = " \[[ID.assigned_fireteam]\]"
		var/marine_infos = "<tr><td><A href='?src=[text_ref(src)];operation=use_cam;cam_target=[text_ref(H)]'>[mob_name]</a></td><td>[role][act_sl][fteam]</td><td>[mob_state]</td><td>[area_name]</td><td>[dist]</td></tr>"
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
	dat += "<A href='?src=[text_ref(src)];operation=refresh'>{Refresh}</a><br>"
	dat += "<A href='?src=[text_ref(src)];operation=change_sort'>{Change Sorting Method}</a><br>"
	dat += "<A href='?src=[text_ref(src)];operation=hide_dead'>{[dead_hidden ? "Show Dead Marines" : "Hide Dead Marines" ]}</a><br>"
	dat += "<A href='?src=[text_ref(src)];operation=choose_z'>{Change Locations Ignored}</a><br>"
	dat += "<br><A href='?src=[text_ref(src)];operation=back'>{Back}</a>"
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
