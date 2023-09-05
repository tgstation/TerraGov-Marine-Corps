/obj/machinery/faxmachine
	name = "fax machine"
	icon = 'icons/obj/machines/library.dmi'
	icon_state = "fax"
	anchored = TRUE
	density = TRUE
	use_power = TRUE
	idle_power_usage = 30
	active_power_usage = 200
	power_channel = EQUIP

	var/obj/item/card/id/idscan = null
	var/authenticated = FALSE

	var/obj/item/paper/message = null
	var/sendcooldown = FALSE

	var/department = CORPORATE_LIAISON
	var/selected = "Nanotrasen"


/obj/machinery/faxmachine/Initialize(mapload)
	. = ..()
	GLOB.faxmachines += src


/obj/machinery/faxmachine/Destroy()
	GLOB.faxmachines -= src
	return ..()


/obj/machinery/faxmachine/deconstruct(disassembled = TRUE)
	if(idscan)
		idscan.forceMove(get_turf(src))
		idscan = null

	return ..()


/obj/machinery/faxmachine/process()
	return FALSE


/obj/machinery/faxmachine/interact(mob/user)
	. = ..()
	if(.)
		return

	var/dat
	var/scan_name
	if(idscan)
		scan_name = idscan.name
	else
		scan_name = "--------"

	dat += "Confirm Identity: <a href='byond://?src=[text_ref(src)];scan=1'>[scan_name]</a><br>"

	if(authenticated)
		dat += "<a href='byond://?src=[text_ref(src)];logout=1'>{Log Out}</a>"
	else
		dat += "<a href='byond://?src=[text_ref(src)];auth=1'>{Log In}</a>"

	dat += "<hr>"

	if(authenticated)
		dat += "<b>Logged in to:</b> Nanotrasen Private Corporate Network<br><br>"
		if(message)
			dat += "<a href='byond://?src=[text_ref(src)];remove=1'>Remove Paper</a><br><br>"
			if(sendcooldown)
				dat += "<b>Transmitter arrays realigning. Please stand by.</b><br>"
			else
				dat += "<a href='byond://?src=[text_ref(src)];send=1'>Send</a><br>"
				dat += "<b>Currently sending:</b> [message.name]<br>"
				dat += "<b>Sending to:</b> <a href='byond://?src=[text_ref(src)];dept=1'>[selected]</a><br>"
		else
			if(sendcooldown)
				dat += "Please insert paper to send via secure connection.<br><br>"
				dat += "<b>Transmitter arrays realigning. Please stand by.</b><br>"
			else
				dat += "Please insert paper to send via secure connection.<br><br>"
	else
		dat += "Proper authentication is required to use this device.<br><br>"
		if(message)
			dat += "<a href ='byond://?src=[text_ref(src)];remove=1'>Remove Paper</a><br>"

	var/datum/browser/popup = new(user, "fax", "<div align='center'>Fax Machine</div>")
	popup.set_content(dat)
	popup.open()


/obj/machinery/faxmachine/Topic(href, href_list)
	. = ..()
	if(.)
		return
	if(href_list["send"])
		if(message)
			send_fax(usr, src, selected, message.name, message.info, FALSE)
			to_chat(usr, "Message transmitted successfully.")
			sendcooldown = TRUE
			addtimer(VARSET_CALLBACK(src, sendcooldown, FALSE), 2 MINUTES)
			updateUsrDialog()
	if(href_list["remove"])
		if(message)
			if(!ishuman(usr))
				to_chat(usr, span_warning("You can't do it."))
			else
				message.loc = usr.loc
				usr.put_in_hands(message)
				to_chat(usr, span_notice("You take the paper out of \the [src]."))
				message = null
	if(href_list["scan"])
		if(idscan)
			if(ishuman(usr))
				idscan.loc = usr.loc
				if(!usr.get_active_held_item())
					usr.put_in_hands(idscan)
				idscan = null
			else
				idscan.loc = loc
				idscan = null
		else
			var/obj/item/I = usr.get_active_held_item()
			if(istype(I, /obj/item/card/id))
				usr.transferItemToLoc(I, src)
				idscan = I
		authenticated = FALSE

	if(href_list["dept"])
		var/choice = tgui_input_list(usr, "Who do you want to message?", "Fax", list("Nanotrasen", "TGMC High Command", "TGMC Provost Marshall"))
		if(!choice)
			return
		selected = choice

	if(href_list["auth"])
		if(!authenticated && idscan)
			if(check_access(idscan))
				authenticated = TRUE

	if(href_list["logout"])
		authenticated = FALSE

	updateUsrDialog()


/obj/machinery/faxmachine/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(istype(I, /obj/item/paper))
		if(!message)
			user.transferItemToLoc(I, src)
			message = I
			to_chat(user, span_notice("You insert the paper into \the [src]."))
			flick("faxsend", src)
			updateUsrDialog()
		else
			to_chat(user, span_notice("There is already something in \the [src]."))

	else if(istype(I, /obj/item/card/id))
		var/obj/item/card/id/idcard = I
		if(!idscan)
			user.transferItemToLoc(idcard, src)
			idscan = idcard

	else if(iswrench(I))
		playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
		anchored = !anchored
		to_chat(user, span_notice("You [anchored ? "wrench" : "unwrench"] \the [src]."))


/obj/machinery/faxmachine/cic
	department = "Combat Information Center"

/obj/machinery/faxmachine/cmp
	department = "Brig"

/obj/machinery/faxmachine/brig
	department = "Brig"

/obj/machinery/faxmachine/research
	department = "Research"

/obj/machinery/faxmachine/warden //Prison Station
	department = "Warden"
