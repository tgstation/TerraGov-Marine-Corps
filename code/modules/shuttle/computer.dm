/obj/machinery/computer/shuttle
	name = "shuttle console"
	desc = "A shuttle control computer."
	icon_state = "syndishuttle"
	req_access = list( )
	var/shuttleId
	var/possible_destinations = ""
	var/admin_controlled
	var/no_destination_swap = 0

/obj/machinery/computer/shuttle/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!user || user.incapacitated())
		return
	ui_interact(user)

/obj/machinery/computer/shuttle/ui_interact(mob/user)
	. = ..()
	var/list/options = params2list(possible_destinations)
	var/obj/docking_port/mobile/M = SSshuttle.getShuttle(shuttleId)
	var/dat = "Status: [M ? M.getStatusText() : "*Missing*"]<br><br>"
	if(M)
		var/destination_found
		for(var/obj/docking_port/stationary/S in SSshuttle.stationary)
			if(!options.Find(S.id))
				continue
			if(!M.check_dock(S, silent=TRUE))
				continue
			destination_found = TRUE
			dat += "<A href='?src=[REF(src)];move=[S.id]'>Send to [S.name]</A><br>"
		if(!destination_found)
			dat += "<B>Shuttle Locked</B><br>"
			if(admin_controlled)
				dat += "Authorized personnel only<br>"
				dat += "<A href='?src=[REF(src)];request=1]'>Request Authorization</A><br>"
	dat += "<a href='?src=[REF(user)];mach_close=computer'>Close</a>"

	var/datum/browser/popup = new(user, "computer", "<div align='center'>[M ? M.name : "shuttle"]</div>", 300, 200)
	popup.set_content("<center>[dat]</center>")
	popup.set_title_image(usr.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()

/obj/machinery/computer/shuttle/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(isxeno(usr))
		return

	if(!allowed(usr))
		to_chat(usr, "<span class='danger'>Access denied.</span>")
		return TRUE

	if(href_list["move"])
		if(world.time < SSticker.round_start_time + SSticker.mode.deploy_time_lock)
			to_chat(usr, "<span class='warning'>The engines are still refueling.</span>")
			return TRUE
		var/obj/docking_port/mobile/M = SSshuttle.getShuttle(shuttleId)
		if(M.mode == SHUTTLE_RECHARGING)
			to_chat(usr, "<span class='warning'>The engines are not ready to use yet!</span>")
			return TRUE
		if(M.launch_status == ENDGAME_LAUNCHED)
			to_chat(usr, "<span class='warning'>You've already escaped. Never going back to that place again!</span>")
			return TRUE
		if(no_destination_swap)
			if(M.mode != SHUTTLE_IDLE)
				to_chat(usr, "<span class='warning'>Shuttle already in transit.</span>")
				return TRUE
		switch(SSshuttle.moveShuttle(shuttleId, href_list["move"], 1))
			if(0)
				visible_message("Shuttle departing. Please stand away from the doors.")
			if(1)
				to_chat(usr, "<span class='warning'>Invalid shuttle requested.</span>")
				return TRUE
			else
				to_chat(usr, "<span class='notice'>Unable to comply.</span>")
				return TRUE

/obj/machinery/computer/shuttle/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock, idnum, override=FALSE)
	if(port && (shuttleId == initial(shuttleId) || override))
		shuttleId = port.id
