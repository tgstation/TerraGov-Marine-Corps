
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


/obj/machinery/computer/telecomms/attack_hand(mob/user)
	interact(user)


/obj/machinery/telecomms/interact(mob/user)
	// You need a multitool to use this, or be silicon
	if(!issilicon(user))
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
	browser.open(TRUE)

	return TRUE


// Returns a multitool from a user depending on their mobtype.
/obj/machinery/telecomms/proc/get_multitool(mob/user)

	var/obj/item/multitool/P = null
	// Let's double check
	if(!issilicon(user) && istype(user.get_active_held_item(), /obj/item/multitool))
		P = user.get_active_held_item()
	else if(isAI(user))
		var/mob/living/silicon/ai/U = user
		P = U.aiMulti
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
	if(href_list["broadcast"])
		broadcasting = !broadcasting
		temp = "<font color = #efef88>-% Broadcasting mode changed. %-</font>"


// BUS
/obj/machinery/telecomms/bus/Options_Menu()
	var/dat = "<br>Change Signal Frequency: <A href='?src=[REF(src)];change_freq=1'>[change_frequency ? "YES ([change_frequency])" : "NO"]</a>"
	return dat


/obj/machinery/telecomms/bus/Options_Topic(href, href_list)
	if(href_list["change_freq"])
		var/newfreq = input(usr, "Specify a new frequency for new signals to change to. Enter null to turn off frequency changing. Decimals assigned automatically.", src, network) as null|num
		if(canAccess(usr))
			if(newfreq)
				if(findtext(num2text(newfreq), "."))
					newfreq *= 10 // shift the decimal one place
				if(newfreq < 10000)
					change_frequency = newfreq
					temp = "<font color = #efef88>-% New frequency to change to assigned: \"[newfreq] GHz\" %-</font>"
			else
				change_frequency = 0
				temp = "<font color = #efef88>-% Frequency changing deactivated %-</font>"


/obj/machinery/telecomms/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(!issilicon(usr))
		if(!istype(usr.get_active_held_item(), /obj/item/multitool))
			return

	var/obj/item/multitool/P = get_multitool(usr)

	if(href_list["input"])
		switch(href_list["input"])
			if("toggle")
				toggled = !toggled
				temp = "<font color = #efef88>-% [src] has been [toggled ? "activated" : "deactivated"].</font>"
				update_power()
			if("id")
				var/newid = copytext(reject_bad_text(input(usr, "Specify the new ID for this machine", src, id) as null|text),1,MAX_MESSAGE_LEN)
				if(newid && canAccess(usr))
					id = newid
					temp = "<font color = #efef88>-% New ID assigned: \"[id]\" %-</font>"
			if("network")
				var/newnet = stripped_input(usr, "Specify the new network for this machine. This will break all current links.", src, network)
				if(newnet && canAccess(usr))
					if(length(newnet) > 15)
						temp = "<font color = #efef88>-% Too many characters in new network tag %-</font>"
					else
						for(var/obj/machinery/telecomms/T in links)
							LAZYREMOVE(T.links, src)
						network = newnet
						links = list()
						temp = "<font color = #efef88>-% New network tag assigned: \"[network]\" %-</font>"
			if("freq")
				var/newfreq = input(usr, "Specify a new frequency to filter (GHz). Decimals assigned automatically.", src, network) as null|num
				if(newfreq && canAccess(usr))
					if(findtext(num2text(newfreq), "."))
						newfreq *= 10 // shift the decimal one place
					if(!(newfreq in freq_listening) && newfreq < 10000)
						freq_listening.Add(newfreq)
						temp = "<font color = #efef88>-% New frequency filter assigned: \"[newfreq] GHz\" %-</font>"

	else if(href_list["delete"])
		var/x = text2num(href_list["delete"])
		temp = "<font color = #efef88>-% Removed frequency filter [x] %-</font>"
		freq_listening.Remove(x)

	else if(href_list["unlink"])
		if(text2num(href_list["unlink"]) <= length(links))
			var/obj/machinery/telecomms/T = links[text2num(href_list["unlink"])]
			if(T)
				temp = "<font color = #efef88>-% Removed [REF(T)] [T.name] from linked entities. %-</font>"
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
	usr.set_interaction(src)
	updateUsrDialog()


/obj/machinery/telecomms/proc/canAccess(mob/user)
	if(issilicon(user) || in_range(user, src))
		return TRUE
	return FALSE