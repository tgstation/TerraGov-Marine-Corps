/*!
 * Old shuttle console code, the type that didn't allow free flying
 * Moved here to reduce the size of marine_dropship.dm
 */
/obj/machinery/computer/shuttle/shuttle_control
	name = "shuttle control console"
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "computer_small"
	screen_overlay = "shuttle"
	///Able to auto-relink to any shuttle with at least one of the flags in common if shuttleId is invalid.
	var/compatible_control_flags = NONE

/obj/machinery/computer/shuttle/shuttle_control/Initialize(mapload)
	. = ..()
	GLOB.shuttle_controls_list += src


/obj/machinery/computer/shuttle/shuttle_control/Destroy()
	GLOB.shuttle_controls_list -= src
	return ..()

/obj/machinery/computer/shuttle/shuttle_control/ui_interact(mob/user, datum/tgui/ui)
	if(!(SSshuttle.getShuttle(shuttleId)))
		RelinkShuttleId()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ShuttleControl")
		ui.open()

/obj/machinery/computer/shuttle/shuttle_control/ui_state(mob/user)
	return GLOB.access_state

/obj/machinery/computer/shuttle/shuttle_control/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	if(action != "selectDestination")
		return FALSE

	var/obj/docking_port/mobile/shuttle = SSshuttle.getShuttle(shuttleId)
	#ifndef TESTING
	if(!(shuttle.shuttle_flags & GAMEMODE_IMMUNE) && world.time < SSticker.round_start_time + SSticker.mode.deploy_time_lock)
		to_chat(usr, span_warning("The engines are still refueling."))
		return TRUE
	#endif
	if(!shuttle.can_move_topic(usr))
		return TRUE

	if(!params["destination"])
		return TRUE

	if(!(params["destination"] in possible_destinations))
		log_admin("[key_name(usr)] may be attempting a href dock exploit on [src] with target location \"[html_encode(params["destination"])]\"")
		message_admins("[ADMIN_TPMONTY(usr)] may be attempting a href dock exploit on [src] with target location \"[html_encode(params["destination"])]\"")
		return TRUE

	var/previous_status = shuttle.mode
	log_game("[key_name(usr)] has sent the shuttle [shuttle] to [params["destination"]]")

	switch(SSshuttle.moveShuttle(shuttleId, params["destination"], 1))
		if(0)
			if(previous_status != SHUTTLE_IDLE)
				visible_message(span_notice("Destination updated, recalculating route."))
			else
				visible_message(span_notice("Shuttle departing. Please stand away from the doors."))
				for(var/mob/living/silicon/ai/AI AS in GLOB.ai_list)
					if(!AI.client)
						continue
					to_chat(AI, span_info("[src] was commanded remotely to take off."))
			return TRUE
		if(1)
			to_chat(usr, span_warning("Invalid shuttle requested."))
			return TRUE
		else
			to_chat(usr, span_notice("Unable to comply."))
			return TRUE

/obj/machinery/computer/shuttle/shuttle_control/ui_data(mob/user)
	var/list/data = list()
	var/obj/docking_port/mobile/shuttle = SSshuttle.getShuttle(shuttleId)
	if(!shuttle)
		return data //empty but oh well

	data["linked_shuttle_name"] = shuttle.name
	data["shuttle_status"] = shuttle.getStatusText()

	for(var/obj/docking_port/stationary/docking_port AS in SSshuttle.stationary)
		//Is the shuttle landing spot in the possible_destinations list?
		if(!(docking_port.id in possible_destinations))
			continue

		//Add the docking port's data for the computer to display it
		var/list/dataset = list()
		dataset["id"] = docking_port.id
		dataset["name"] = docking_port.name
		dataset["locked"] = !shuttle.check_dock(docking_port, silent=TRUE)
		data["destinations"] += list(dataset)

	return data

/obj/machinery/computer/shuttle/shuttle_control/attack_ghost(mob/dead/observer/user)
	// Getting all valid destinations into an assoc list with "name" = "portid"
	var/list/port_assoc = list()
	for(var/destination in possible_destinations)
		for(var/obj/docking_port/port AS in SSshuttle.stationary)
			if(destination != port.id)
				continue
			port_assoc["[port.name]"] = destination

	var/list/destinations = list()
	for(var/destination in port_assoc)
		destinations += destination
	var/input = tgui_input_list(user, "Choose a port to teleport to:", "Ghost Shuttle teleport", destinations, null, 0)
	if(!input)
		return
	var/obj/docking_port/mobile/target_port = SSshuttle.getDock(port_assoc[input])

	if(!target_port || QDELETED(target_port) || !target_port.loc)
		return
	user.forceMove(get_turf(target_port))

/// Relinks the shuttleId in the console to a valid shuttle currently existing. Will only relink to a shuttle with a matching control_flags flag. Returns true if successfully relinked
/obj/machinery/computer/shuttle/shuttle_control/proc/RelinkShuttleId(forcedId)
	var/newId = null
	/// The preferred shuttleId to link to if it exists.
	var/preferredId = initial(shuttleId)
	var/obj/docking_port/mobile/M
	var/shuttleName = "Unknown"
	if(forcedId)
		M = SSshuttle.getShuttle(forcedId)
		if(!M)
			return FALSE
		newId = M.id
		shuttleName = M.name
	else
		M = null
		for(M AS in SSshuttle.mobile)
			if(!(M.control_flags & compatible_control_flags)) //Need at least one matching control flag
				continue
			newId = M.id
			shuttleName = M.name
			if(M.id == preferredId) //Lock selection in if we get the initial shuttleId of this console.
				break
	if(!newId)
		return FALSE //Did not relink

	if(newId == shuttleId)
		return TRUE //Did not relink but didn't have to since it is the same reference.

	shuttleId = newId
	name = "\improper '[shuttleName]' dropship console"
	desc = "The remote controls for the '[shuttleName]' Dropship."
	say("Relinked Dropship Control Console to: '[shuttleName]'")
	return TRUE //Did relink



/obj/machinery/computer/shuttle/shuttle_control/dropship
	name = "\improper 'Alamo' dropship console"
	desc = "The remote controls for the 'Alamo' Dropship. Named after the Alamo Mission, stage of the Battle of the Alamo in the United States' state of Texas in the Spring of 1836. The defenders held to the last, encouraging other Texans to rally to the flag."
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "computer_small"
	screen_overlay = "shuttle"
	resistance_flags = RESIST_ALL
	req_one_access = list(ACCESS_MARINE_SHUTTLE, ACCESS_MARINE_LEADER) // TLs can only operate the remote console
	shuttleId = SHUTTLE_DROPSHIP
	compatible_control_flags = SHUTTLE_MARINE_PRIMARY_DROPSHIP
	possible_destinations = list(DOCKING_PORT_LZ1, DOCKING_PORT_LZ2, SHUTTLE_DROPSHIP)

/obj/machinery/computer/shuttle/shuttle_control/dropship/two
	name = "\improper 'Normandy' dropship console"
	desc = "The remote controls for the 'Normandy' Dropship. Named after a department in France, noteworthy for the famous naval invasion of Normandy on the 6th of June 1944, a bloody but decisive victory in World War II and the campaign for the Liberation of France."
	shuttleId = SHUTTLE_NORMANDY
	possible_destinations = list(DOCKING_PORT_LZ1, DOCKING_PORT_LZ2, SHUTTLE_DROPSHIP, SHUTTLE_NORMANDY)

/obj/machinery/computer/shuttle/shuttle_control/canterbury
	name = "\improper 'Canterbury' shuttle console"
	desc = "The remote controls for the 'Canterbury' shuttle."
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "computer_small"
	screen_overlay = "shuttle"
	resistance_flags = RESIST_ALL
	shuttleId = SHUTTLE_CANTERBURY
	possible_destinations = list("canterbury_loadingdock")

/obj/machinery/computer/shuttle/shuttle_control/canterbury/ui_interact(mob/user)
	if(!allowed(user))
		to_chat(user, span_warning("Access Denied!"))
		return
	var/obj/docking_port/mobile/M = SSshuttle.getShuttle(shuttleId)
	var/dat = "Status: [M ? M.getStatusText() : "*Missing*"]<br><br>"
	if(M)
		dat += "<A href='?src=[REF(src)];move=crash-infinite-transit'>Initiate Evacuation</A><br>"

	var/datum/browser/popup = new(user, "computer", M ? M.name : "shuttle", 300, 200)
	popup.set_content("<center>[dat]</center>")
	popup.open()


/obj/machinery/computer/shuttle/shuttle_control/canterbury/Topic(href, href_list)
	// Since we want to avoid the standard move topic, we are just gonna override everything.
	add_fingerprint(usr, "topic")
	if(!can_interact(usr))
		return TRUE
	if(isxeno(usr))
		return TRUE
	if(!allowed(usr))
		to_chat(usr, span_danger("Access denied."))
		return TRUE
	if(!href_list["move"] || !iscrashgamemode(SSticker.mode))
		to_chat(usr, span_warning("[src] is unresponsive."))
		return FALSE

	if(!length(GLOB.active_nuke_list) && tgui_alert(usr, "Are you sure you want to launch the shuttle? Without sufficiently dealing with the threat, you will be in direct violation of your orders!", "Are you sure?", list("Yes", "Cancel")) != "Yes")
		return TRUE

	log_admin("[key_name(usr)] is launching the canterbury[!length(GLOB.active_nuke_list)? " early" : ""].")
	message_admins("[ADMIN_TPMONTY(usr)] is launching the canterbury[!length(GLOB.active_nuke_list)? " early" : ""].")

	var/obj/docking_port/mobile/M = SSshuttle.getShuttle(shuttleId)
	#ifndef TESTING
	if(!(M.shuttle_flags & GAMEMODE_IMMUNE) && world.time < SSticker.round_start_time + SSticker.mode.deploy_time_lock)
		to_chat(usr, span_warning("The engines are still refueling."))
		return TRUE
	#endif
	if(!M.can_move_topic(usr))
		return TRUE

	visible_message(span_notice("Shuttle departing. Please stand away from the doors."))
	M.destination = null
	M.mode = SHUTTLE_IGNITING
	M.setTimer(M.ignitionTime)

	var/datum/game_mode/infestation/crash/C = SSticker.mode
	addtimer(VARSET_CALLBACK(C, marines_evac, CRASH_EVAC_INPROGRESS), M.ignitionTime + 10 SECONDS)
	addtimer(VARSET_CALLBACK(C, marines_evac, CRASH_EVAC_COMPLETED), 2 MINUTES)
	return TRUE
