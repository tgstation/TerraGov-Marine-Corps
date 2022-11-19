
/*

	All telecommunications interactions:

*/
/obj/machinery/telecomms
	var/temp = "" // output message


/obj/machinery/telecomms/attackby(obj/item/I, mob/user, params)
	// Using a multitool lets you access the receiver's interface
	if(ismultitool(I))
		interact(user)
	else
		return ..()


/obj/machinery/telecomms/interact(mob/user)
	. = ..()
	if(.)
		return
	// You need a multitool to use this, or be silicon
	if(iscarbon(user))
		// istype returns false if the value is null
		if(!istype(user.get_active_held_item(), /obj/item/multitool))
			return
	var/obj/item/multitool/P = get_multitool(user)
	var/dat
	dat += "<br>[temp]<br>"
	dat += "<br>Power Status: <a href='?src=[REF(src)];input=toggle'>[toggled ? "On" : "Off"]</a>"
	if(on && toggled)
		if(id != "" && id)
			dat += "<br>Identification String: <a href='?src=[REF(src)];input=id'>[id]</a>"
		else
			dat += "<br>Identification String: <a href='?src=[REF(src)];input=id'>NULL</a>"
		dat += "<br>Network: <a href='?src=[REF(src)];input=network'>[network]</a>"
		dat += "<br>Prefabrication: [length(autolinkers) ? "TRUE" : "FALSE"]"
		if(hide)
			dat += "<br>Shadow Link: ACTIVE</a>"

		//Show additional options for certain machines.
		dat += Options_Menu()

		dat += "<br>Linked Network Entities: <ol>"

		var/i = 0
		for(var/obj/machinery/telecomms/T in links)
			i++
			if(T.hide && !hide)
				continue
			dat += "<li>[REF(T)] [T.name] ([T.id])  <a href='?src=[REF(src)];unlink=[i]'>\[X\]</a></li>"
		dat += "</ol>"

		dat += "<br>Filtering Frequencies: "

		i = 0
		if(length(freq_listening))
			for(var/x in freq_listening)
				i++
				if(i < length(freq_listening))
					dat += "[format_frequency(x)] GHz<a href='?src=[REF(src)];delete=[x]'>\[X\]</a>; "
				else
					dat += "[format_frequency(x)] GHz<a href='?src=[REF(src)];delete=[x]'>\[X\]</a>"
		else
			dat += "NONE"

		dat += "<br>  <a href='?src=[REF(src)];input=freq'>\[Add Filter\]</a>"
		dat += "<hr>"

		if(P)
			var/obj/machinery/telecomms/T = P.buffer
			if(istype(T))
				dat += "<br><br>MULTITOOL BUFFER: [T] ([T.id]) <a href='?src=[REF(src)];link=1'>\[Link\]</a> <a href='?src=[REF(src)];flush=1'>\[Flush\]"
			else
				dat += "<br><br>MULTITOOL BUFFER: <a href='?src=[REF(src)];buffer=1'>\[Add Machine\]</a>"

	temp = ""

	var/datum/browser/browser = new(user, "tcommachine", "<div align='center'>[src] Access</div>", 520, 500)
	browser.set_content(dat)
	browser.open()


// Returns a multitool from a user depending on their mobtype.
/obj/machinery/telecomms/proc/get_multitool(mob/user)

	var/obj/item/multitool/P = null
	// Let's double check
	if(!issilicon(user) && istype(user.get_active_held_item(), /obj/item/multitool))
		P = user.get_active_held_item()
	return P


// Additional Options for certain machines. Use this when you want to add an option to a specific machine.
// Example of how to use below.
/obj/machinery/telecomms/proc/Options_Menu()
	return ""


// The topic for Additional Options. Use this for checking href links for your specific option.
// Example of how to use below.
/obj/machinery/telecomms/proc/Options_Topic(href, href_list)
	return


// RELAY
/obj/machinery/telecomms/relay/Options_Menu()
	var/dat = ""
	dat += "<br>Broadcasting: <A href='?src=[REF(src)];broadcast=1'>[broadcasting ? "YES" : "NO"]</a>"
	dat += "<br>Receiving:    <A href='?src=[REF(src)];receive=1'>[receiving ? "YES" : "NO"]</a>"
	return dat


/obj/machinery/telecomms/relay/Options_Topic(href, href_list)
	if(href_list["receive"])
		receiving = !receiving
		temp = "<font color = #efef88>-% Receiving mode changed. %-</font>"
		message_admins("[usr] has changed the receiving mode at [src] in [ADMIN_VERBOSEJMP(loc)]")
		log_game("[usr] has changed the receiving mode at [src] in [AREACOORD(loc)]")
	if(href_list["broadcast"])
		broadcasting = !broadcasting
		temp = "<font color = #efef88>-% Broadcasting mode changed. %-</font>"
		message_admins("[usr] has changed the broadcasting mode at [src] in [ADMIN_VERBOSEJMP(loc)]")
		log_game("[usr] has changed the broadcasting mode at [src] in [AREACOORD(loc)]")


// BUS
/obj/machinery/telecomms/bus/Options_Menu()
	var/dat = "<br>Change Signal Frequency: <A href='?src=[REF(src)];change_freq=1'>[change_frequency ? "YES ([change_frequency])" : "NO"]</a>"
	return dat


/obj/machinery/telecomms/bus/Options_Topic(href, href_list)
	if(href_list["change_freq"] && isadmin(usr))
		var/newfreq = input(usr, "Specify a new frequency for new signals to change to. Enter null to turn off frequency changing. Decimals assigned automatically.", src, network) as null|num
		if(newfreq)
			if(findtext(num2text(newfreq), "."))
				newfreq *= 10 // shift the decimal one place
			if(newfreq < 10000)
				change_frequency = newfreq
				temp = "<font color = #efef88>-% New frequency to change to assigned: \"[newfreq] GHz\" %-</font>"
				message_admins("[usr] has assigned new frequency [newfreq] at [src] in[ADMIN_VERBOSEJMP(loc)]")
				log_game("[usr] has assigned new frequency [newfreq] at [src] in [AREACOORD(loc)]")
		else
			change_frequency = 0
			temp = "<font color = #efef88>-% Frequency changing deactivated %-</font>"


/obj/machinery/telecomms/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(iscarbon(usr))
		if(!istype(usr.get_active_held_item(), /obj/item/multitool))
			return

	var/obj/item/multitool/P = get_multitool(usr)

	if(href_list["input"])
		switch(href_list["input"])
			if("toggle")
				toggled = !toggled
				temp = "<font color = #efef88>-% [src] has been [toggled ? "activated" : "deactivated"].</font>"
				message_admins("[usr] has toggled telecomms power to [src] at [ADMIN_VERBOSEJMP(loc)]")
				log_game("[usr] has toggled telecomms power to [src] at [AREACOORD(loc)]")
				update_power()
			if("id")
				var/newid = reject_bad_text(stripped_input(usr, "Specify the new ID for this machine", src, id, MAX_MESSAGE_LEN))
				if(newid && isadmin(usr))
					id = newid
					temp = "<font color = #efef88>-% New ID assigned: \"[id]\" %-</font>"
					message_admins("[usr] has assigned new telecomms ID [id] to [src] at [ADMIN_VERBOSEJMP(loc)]")
					log_game("[usr] assigned new telecomms ID [id] to [src] at [AREACOORD(loc)]")
				else
					message_admins("[usr] attemped to assign new telecomms ID [id] to [src] in [ADMIN_VERBOSEJMP(loc)]")
			if("network")
				var/newnet = stripped_input(usr, "Specify the new network for this machine. This will break all current links.", src, network)
				if(newnet)
					if(length(newnet) > 15)
						temp = "<font color = #efef88>-% Too many characters in new network tag %-</font>"
					else
						if(isadmin(usr))
							for(var/obj/machinery/telecomms/T in links)
								LAZYREMOVE(T.links, src)
							network = newnet
							links = list()
							temp = "<font color = #efef88>-% New network tag assigned: \"[network]\" %-</font>"
							message_admins("[usr] has assigned new telecomms network to [newnet] at [src] in [ADMIN_VERBOSEJMP(loc)]")
							log_game("[usr] has assigned new telecomms network to [newnet] at [src] in [AREACOORD(loc)]")
						else
							message_admins("[usr] attemped to change network to [newnet] at [src] in [ADMIN_VERBOSEJMP(loc)]")
			if("freq")
				var/newfreq = input(usr, "Specify a new frequency to filter (GHz). Decimals assigned automatically.", src, network) as null|num
				if(newfreq && isadmin(usr))
					if(findtext(num2text(newfreq), "."))
						newfreq *= 10 // shift the decimal one place
					if(!(newfreq in freq_listening) && newfreq < 10000)
						freq_listening.Add(newfreq)
						temp = "<font color = #efef88>-% New frequency filter assigned: \"[newfreq] GHz\" %-</font>"
						message_admins("[usr] has assigned new frequency filter [newfreq] at [src] in [ADMIN_VERBOSEJMP(loc)]")
						log_game("[usr] has assigned new frequency filter [newfreq] at [src] in [AREACOORD(loc)]")
					else
						message_admins("[usr] attemped to assign assigned new frequency filter [newfreq] at [src] in [ADMIN_VERBOSEJMP(loc)]")

	else if(href_list["delete"])
		var/x = text2num(href_list["delete"])
		temp = "<font color = #efef88>-% Removed frequency filter [x] %-</font>"
		message_admins("[usr] Removed frequency filter [x] at [src] in [ADMIN_VERBOSEJMP(loc)]")
		log_game("[usr] Removed frequency filter [x] at [src] in [AREACOORD(loc)]")
		if(isadmin(usr))
			freq_listening.Remove(x)
		else
			message_admins("[usr] Tried to remove frequency filter [x] at [src] in [ADMIN_VERBOSEJMP(loc)]")

	else if(href_list["unlink"] && isadmin(usr))
		if(text2num(href_list["unlink"]) <= length(links))
			var/obj/machinery/telecomms/T = links[text2num(href_list["unlink"])]
			if(T)
				temp = "<font color = #efef88>-% Removed [REF(T)] [T.name] from linked entities. %-</font>"
				message_admins("[usr] Removed [REF(T)] [T.name] at [src] in [ADMIN_VERBOSEJMP(loc)]")
				log_game("[usr] Removed [REF(T)] [T.name] at [src] in [AREACOORD(loc)]")
				// Remove link entries from both T and src.
				if(T.links)
					LAZYREMOVE(T.links, src)
				LAZYREMOVE(links, T)

			else
				temp = "<font color = #efef88>-% Unable to locate machine to unlink from, try again. %-</font>"

	else if(href_list["link"])
		if(P)
			var/obj/machinery/telecomms/T = P.buffer
			if(istype(T) && T != src)
				if(!(src in T.links))
					T.links += src
				if(!(T in links))
					links += T
				temp = "<font color = #efef88>-% Successfully linked with [REF(T)] [T.name] %-</font>"
			else
				temp = "<font color = #efef88>-% Unable to acquire buffer %-</font>"

	else if(href_list["buffer"])
		P.buffer = src
		temp = "<font color = #efef88>-% Successfully stored [REF(P.buffer)] [P.buffer.name] in buffer %-</font>"


	else if(href_list["flush"])
		temp = "<font color = #efef88>-% Buffer successfully flushed. %-</font>"
		P.buffer = null

	Options_Topic(href, href_list)
	updateUsrDialog()
