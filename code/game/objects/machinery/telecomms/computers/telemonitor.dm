
/*
	Telecomms monitor tracks the overall trafficing of a telecommunications network
	and displays a heirarchy of linked machines.
*/


/obj/machinery/computer/telecomms/monitor
	name = "telecommunications monitoring console"
	desc = "Monitors the details of the telecommunications network it's synced with."
	icon_state = "computer"
	screen_overlay = "comm_monitor"

	var/screen = 0				// the screen number:
	var/list/machinelist = list()	// the machines located by the computer
	var/obj/machinery/telecomms/SelectedMachine

	var/network = "NULL"		// the network to probe

	var/temp = ""				// temporary feedback messages
	circuit = /obj/item/circuitboard/computer/comm_monitor

/obj/machinery/computer/telecomms/monitor/preset
	network = "tcommsat"

/obj/machinery/computer/telecomms/monitor/interact(mob/user)
	. = ..()
	var/dat

	switch(screen)
		if(0) // --- Main Menu ---
			dat += "<br>[temp]<br><br>"
			dat += "<br>Current Network: <a href='?src=[REF(src)];network=1'>[network]</a><br>"
			if(length(machinelist))
				dat += "<br>Detected Network Entities:<ul>"
				for(var/obj/machinery/telecomms/T in machinelist)
					dat += "<li><a href='?src=[REF(src)];viewmachine=[T.id]'>[REF(T)] [T.name]</a> ([T.id])</li>"
				dat += "</ul>"
				dat += "<br><a href='?src=[REF(src)];operation=release'>\[Flush Buffer\]</a>"
			else
				dat += "<a href='?src=[REF(src)];operation=probe'>\[Probe Network\]</a>"
		if(1) // --- Viewing Machine ---
			dat += "<br>[temp]<br>"
			dat += "<center><a href='?src=[REF(src)];operation=mainmenu'>\[Main Menu\]</a></center>"
			dat += "<br>Current Network: [network]<br>"
			dat += "Selected Network Entity: [SelectedMachine.name] ([SelectedMachine.id])<br>"
			dat += "Linked Entities: <ol>"
			for(var/obj/machinery/telecomms/T in SelectedMachine.links)
				if(!T.hide)
					dat += "<li><a href='?src=[REF(src)];viewmachine=[T.id]'>[REF(T.id)] [T.name]</a> ([T.id])</li>"
			dat += "</ol>"


	var/datum/browser/browser = new(user, "comm_monitor", "<div align='center'>Telecommunications Monitor</div>", 575, 400)
	browser.set_content(dat)
	browser.open(TRUE)

	temp = ""


/obj/machinery/computer/telecomms/monitor/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(href_list["viewmachine"])
		screen = 1
		for(var/obj/machinery/telecomms/T in machinelist)
			if(T.id == href_list["viewmachine"])
				SelectedMachine = T
				break

	else if(href_list["operation"])
		switch(href_list["operation"])
			if("release")
				machinelist = list()
				screen = 0
			if("mainmenu")
				screen = 0
			if("probe")
				if(length(machinelist))
					temp = "<font color = #f97c75>- FAILED: CANNOT PROBE WHEN BUFFER FULL -</font color>"
				else
					for(var/obj/machinery/telecomms/T in urange(25, src))
						if(T.network == network)
							LAZYADD(machinelist, T)
					if(!length(machinelist))
						temp = "<font color = #f97c75>- FAILED: UNABLE TO LOCATE NETWORK ENTITIES IN \[[network]\] -</font color>"
					else
						temp = "<font color = #88bff7>- [length(machinelist)] ENTITIES LOCATED & BUFFERED -</font color>"

					screen = 0

	else if(href_list["network"])
		var/newnet = stripped_input(usr, "Which network do you want to view?", "Comm Monitor", network)
		if(newnet && ((usr in range(1, src)) || issilicon(usr)))
			if(length(newnet) > 15)
				temp = "<font color = #f97c75>- FAILED: NETWORK TAG STRING TOO LENGHTLY -</font color>"
			else
				message_admins("[usr] attemped to change network to [newnet] at [src] in [ADMIN_VERBOSEJMP(loc)]")
				if(isadmin(usr))
					network = newnet
					screen = 0
					machinelist = list()
					temp = "<font color = #88bff7>- NEW NETWORK TAG SET IN ADDRESS \[[network]\] -</font color>"
					message_admins("[usr] has assigned new network tag to [newnet] at [src] in [ADMIN_VERBOSEJMP(loc)]")
					log_game("[usr] has assigned new network tag to [newnet] at [src] in [AREACOORD(loc)]")

	updateUsrDialog()
