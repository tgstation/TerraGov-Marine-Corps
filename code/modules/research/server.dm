/obj/machinery/r_n_d/server
	name = "R&D Server"
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "server"
	var/datum/research/files
	var/health = 100
	var/list/id_with_upload = list()		//List of R&D consoles with upload to server access.
	var/list/id_with_download = list()	//List of R&D consoles with download from server access.
	var/id_with_upload_string = ""		//String versions for easy editing in map editor.
	var/id_with_download_string = ""
	var/server_id = 0
	var/produces_heat = 1
	idle_power_usage = 800
	var/delay = 10
	req_access = list(ACCESS_MARINE_CMO) //Only the R&D can change server settings.

/obj/machinery/r_n_d/server/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/machine/rdserver(src)
	component_parts += new /obj/item/stock_parts/scanning_module(src)
	component_parts += new /obj/item/stack/cable_coil(src)
	component_parts += new /obj/item/stack/cable_coil(src)
	RefreshParts()

/obj/machinery/r_n_d/server/Destroy()
	griefProtection()
	. = ..()

/obj/machinery/r_n_d/server/RefreshParts()
	var/tot_rating = 0
	for(var/obj/item/stock_parts/SP in src)
		tot_rating += SP.rating
	idle_power_usage /= max(1, tot_rating)

/obj/machinery/r_n_d/server/Initialize()
	. = ..()
	if(!files) files = new /datum/research(src)
	var/list/temp_list
	if(!id_with_upload.len)
		temp_list = list()
		temp_list = text2list(id_with_upload_string, ";")
		for(var/N in temp_list)
			id_with_upload += text2num(N)
	if(!id_with_download.len)
		temp_list = list()
		temp_list = text2list(id_with_download_string, ";")
		for(var/N in temp_list)
			id_with_download += text2num(N)

/obj/machinery/r_n_d/server/process()
	var/env_temperature = 0
	if(loc)
		env_temperature = loc.return_temperature()
	switch(env_temperature)
		if(0 to T0C)
			health = min(100, health + 1)
		if(T0C to (T20C + 20))
			health = between(0, health, 100)
		if((T20C + 20) to (T0C + 70))
			health = max(0, health - 1)
	if(health <= 0)
		griefProtection() //I dont like putting this in process() but it's the best I can do without re-writing a chunk of rd servers.
		files.known_designs = list()
		for(var/datum/tech/T in files.known_tech)
			if(prob(1))
				T.level--
		files.RefreshResearch()
	if(delay)
		delay--
	else
		produce_heat()
		delay = initial(delay)

/obj/machinery/r_n_d/server/emp_act(severity)
	griefProtection()
	..()


/obj/machinery/r_n_d/server/ex_act(severity)
	griefProtection()
	..()

//Backup files to centcomm to help admins recover data after greifer attacks
/obj/machinery/r_n_d/server/proc/griefProtection()
	for(var/obj/machinery/r_n_d/server/centcom/C in GLOB.machines)
		for(var/datum/tech/T in files.known_tech)
			C.files.AddTech2Known(T)
		for(var/datum/design/D in files.known_designs)
			C.files.AddDesign2Known(D)
		C.files.RefreshResearch()

/obj/machinery/r_n_d/server/proc/produce_heat()


/obj/machinery/r_n_d/server/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(disabled)
		return

	else if(shocked)
		shock(user, 50)

	else if(isscrewdriver(I))
		opened = !opened
		if(opened)
			icon_state = "server_o"
			to_chat(user, "You open the maintenance hatch of [src].")
		else
			icon_state = "server"
			to_chat(user, "You close the maintenance hatch of [src].")

	else if(opened && iscrowbar(I))
		griefProtection()
		playsound(loc, 'sound/items/crowbar.ogg', 25, 1)
		var/obj/machinery/constructable_frame/machine_frame/M = new(loc)
		M.state = 2
		M.icon_state = "box_1"
		for(var/obj/O in component_parts)
			if(O.reliability != 100 && crit_fail)
				O.crit_fail = TRUE
			O.forceMove(loc)
		qdel(src)
		return TRUE

/obj/machinery/r_n_d/server/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if (disabled)
		return
	if (shocked)
		shock(user,50)
	return




/obj/machinery/r_n_d/server/centcom
	name = "Centcom Central R&D Database"
	server_id = -1

/obj/machinery/r_n_d/server/centcom/Initialize()
	. = ..()
	var/list/no_id_servers = list()
	var/list/server_ids = list()
	for(var/obj/machinery/r_n_d/server/S in GLOB.machines)
		switch(S.server_id)
			if(-1)
				continue
			if(0)
				no_id_servers += S
			else
				server_ids += S.server_id

	for(var/obj/machinery/r_n_d/server/S in no_id_servers)
		var/num = 1
		while(!S.server_id)
			if(num in server_ids)
				num++
			else
				S.server_id = num
				server_ids += num
		no_id_servers -= S

/obj/machinery/r_n_d/server/centcom/process()
	return PROCESS_KILL	//don't need process()


/obj/machinery/computer/rdservercontrol
	name = "R&D Server Controller"
	icon_state = "rdcomp"
	circuit = /obj/item/circuitboard/computer/rdservercontrol
	var/screen = 0
	var/obj/machinery/r_n_d/server/temp_server
	var/list/servers = list()
	var/list/consoles = list()
	var/badmin = 0

/obj/machinery/computer/rdservercontrol/Topic(href, href_list)
	. = ..()
	if(.)
		return

	usr.set_interaction(src)
	if(!allowed(usr))
		to_chat(usr, "<span class='warning'>You do not have the required access level</span>")
		return

	if(href_list["main"])
		screen = 0

	else if(href_list["access"] || href_list["data"] || href_list["transfer"])
		temp_server = null
		consoles = list()
		servers = list()
		for(var/obj/machinery/r_n_d/server/S in GLOB.machines)
			if(S.server_id == text2num(href_list["access"]) || S.server_id == text2num(href_list["data"]) || S.server_id == text2num(href_list["transfer"]))
				temp_server = S
				break
		if(href_list["access"])
			screen = 1
			for(var/obj/machinery/computer/rdconsole/C in GLOB.machines)
				if(C.sync)
					consoles += C
		else if(href_list["data"])
			screen = 2
		else if(href_list["transfer"])
			screen = 3
			for(var/obj/machinery/r_n_d/server/S in GLOB.machines)
				if(S == src)
					continue
				servers += S

	else if(href_list["upload_toggle"])
		var/num = text2num(href_list["upload_toggle"])
		if(num in temp_server.id_with_upload)
			temp_server.id_with_upload -= num
		else
			temp_server.id_with_upload += num

	else if(href_list["download_toggle"])
		var/num = text2num(href_list["download_toggle"])
		if(num in temp_server.id_with_download)
			temp_server.id_with_download -= num
		else
			temp_server.id_with_download += num

	else if(href_list["reset_tech"])
		var/choice = alert("Technology Data Rest", "Are you sure you want to reset this technology to its default data? Data lost cannot be recovered.", "Continue", "Cancel")
		if(choice == "Continue")
			for(var/datum/tech/T in temp_server.files.known_tech)
				if(T.id == href_list["reset_tech"])
					T.level = 1
					break
		temp_server.files.RefreshResearch()

	else if(href_list["reset_design"])
		var/choice = alert("Design Data Deletion", "Are you sure you want to delete this design? If you still have the prerequisites for the design, it'll reset to its base reliability. Data lost cannot be recovered.", "Continue", "Cancel")
		if(choice == "Continue")
			for(var/datum/design/D in temp_server.files.known_designs)
				if(D.id == href_list["reset_design"])
					D.reliability_mod = 0
					temp_server.files.known_designs -= D
					break
		temp_server.files.RefreshResearch()

	updateUsrDialog()
	return

/obj/machinery/computer/rdservercontrol/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(machine_stat & (BROKEN|NOPOWER))
		return
	user.set_interaction(src)
	var/dat = ""

	switch(screen)
		if(0) //Main Menu
			dat += "Connected Servers:<BR><BR>"

			for(var/obj/machinery/r_n_d/server/S in GLOB.machines)
				if(istype(S, /obj/machinery/r_n_d/server/centcom) && !badmin)
					continue
				dat += "[S.name] || "
				dat += "<A href='?src=\ref[src];access=[S.server_id]'> Access Rights</A>|"
				dat += "<A href='?src=\ref[src];data=[S.server_id]'>Data Management</A>"
				if(badmin) dat += "|<A href='?src=\ref[src];transfer=[S.server_id]'>Server-to-Server Transfer</A>"
				dat += "<BR>"

		if(1) //Access rights menu
			dat += "[temp_server.name] Access Rights<BR><BR>"
			dat += "Consoles with Upload Access<BR>"
			for(var/obj/machinery/computer/rdconsole/C in consoles)
				var/turf/console_turf = get_turf(C)
				dat += "* <A href='?src=\ref[src];upload_toggle=[C.id]'>[console_turf.loc]" //FYI, these are all numeric ids, eventually.
				if(C.id in temp_server.id_with_upload)
					dat += " (Remove)</A><BR>"
				else
					dat += " (Add)</A><BR>"
			dat += "Consoles with Download Access<BR>"
			for(var/obj/machinery/computer/rdconsole/C in consoles)
				var/turf/console_turf = get_turf(C)
				dat += "* <A href='?src=\ref[src];download_toggle=[C.id]'>[console_turf.loc]"
				if(C.id in temp_server.id_with_download)
					dat += " (Remove)</A><BR>"
				else
					dat += " (Add)</A><BR>"
			dat += "<HR><A href='?src=\ref[src];main=1'>Main Menu</A>"

		if(2) //Data Management menu
			dat += "[temp_server.name] Data ManagementP<BR><BR>"
			dat += "Known Technologies<BR>"
			for(var/datum/tech/T in temp_server.files.known_tech)
				dat += "* [T.name] "
				dat += "<A href='?src=\ref[src];reset_tech=[T.id]'>(Reset)</A><BR>" //FYI, these are all strings.
			dat += "Known Designs<BR>"
			for(var/datum/design/D in temp_server.files.known_designs)
				dat += "* [D.name] "
				dat += "<A href='?src=\ref[src];reset_design=[D.id]'>(Delete)</A><BR>"
			dat += "<HR><A href='?src=\ref[src];main=1'>Main Menu</A>"

		if(3) //Server Data Transfer
			dat += "[temp_server.name] Server to Server Transfer<BR><BR>"
			dat += "Send Data to what server?<BR>"
			for(var/obj/machinery/r_n_d/server/S in servers)
				dat += "[S.name] <A href='?src=\ref[src];send_to=[S.server_id]'> (Transfer)</A><BR>"
			dat += "<HR><A href='?src=\ref[src];main=1'>Main Menu</A>"

	var/datum/browser/popup = new(user, "server_control", "<div align='center'>R&D Server Control</div>", 575, 400)
	popup.set_content(dat)
	popup.open(FALSE)
	onclose(user, "server_control")


/obj/machinery/r_n_d/server/robotics
	name = "Robotics R&D Server"
	id_with_upload_string = "1;2"
	id_with_download_string = "1;2"
	server_id = 2


/obj/machinery/r_n_d/server/core
	name = "Core R&D Server"
	id_with_upload_string = "1"
	id_with_download_string = "1"
	server_id = 1
