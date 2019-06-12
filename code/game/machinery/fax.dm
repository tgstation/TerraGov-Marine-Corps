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

	var/department = "Corporate Liaison"
	var/selected = "Nanotrasen"


/obj/machinery/faxmachine/Initialize()
	. = ..()
	GLOB.faxmachines += src


/obj/machinery/faxmachine/Destroy()
	GLOB.faxmachines -= src
	return ..()


/obj/machinery/faxmachine/process()
	return FALSE


/obj/machinery/faxmachine/attack_ai(mob/user as mob)
	return attack_hand(user)


/obj/machinery/faxmachine/attack_paw(mob/user as mob)
	return attack_hand(user)


/obj/machinery/faxmachine/attack_hand(mob/user as mob)
	user.set_interaction(src)

	var/dat

	var/scan_name
	if(idscan)
		scan_name = idscan.name
	else
		scan_name = "--------"

	dat += "Confirm Identity: <a href='byond://?src=\ref[src];scan=1'>[scan_name]</a><br>"

	if(authenticated)
		dat += "<a href='byond://?src=\ref[src];logout=1'>{Log Out}</a>"
	else
		dat += "<a href='byond://?src=\ref[src];auth=1'>{Log In}</a>"

	dat += "<hr>"

	if(authenticated)
		dat += "<b>Logged in to:</b> Nanotrasen Private Corporate Network<br><br>"
		if(message)
			dat += "<a href='byond://?src=\ref[src];remove=1'>Remove Paper</a><br><br>"
			if(sendcooldown)
				dat += "<b>Transmitter arrays realigning. Please stand by.</b><br>"
			else
				dat += "<a href='byond://?src=\ref[src];send=1'>Send</a><br>"
				dat += "<b>Currently sending:</b> [message.name]<br>"
				dat += "<b>Sending to:</b> <a href='byond://?src=\ref[src];dept=1'>[selected]</a><br>"
		else
			if(sendcooldown)
				dat += "Please insert paper to send via secure connection.<br><br>"
				dat += "<b>Transmitter arrays realigning. Please stand by.</b><br>"
			else
				dat += "Please insert paper to send via secure connection.<br><br>"
	else
		dat += "Proper authentication is required to use this device.<br><br>"
		if(message)
			dat += "<a href ='byond://?src=\ref[src];remove=1'>Remove Paper</a><br>"

	var/datum/browser/popup = new(user, "fax", "<div align='center'>Fax Machine</div>")
	popup.set_content(dat)
	popup.open(FALSE)
	onclose(user, "fax")


/obj/machinery/faxmachine/Topic(href, href_list)
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
				to_chat(usr, "<span class='warning'>You can't do it.</span>")
			else
				message.loc = usr.loc
				usr.put_in_hands(message)
				to_chat(usr, "<span class='notice'>You take the paper out of \the [src].</span>")
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
		var/choice = input(usr, "Who do you want to message?", "Fax", "") as null|anything in list("Nanotrasen", "TGMC High Command", "TGMC Provost Marshall")
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
			to_chat(user, "<span class='notice'>You insert the paper into \the [src].</span>")
			flick("faxsend", src)
			updateUsrDialog()
		else
			to_chat(user, "<span class='notice'>There is already something in \the [src].</span>")

	else if(istype(I, /obj/item/card/id))
		var/obj/item/card/id/idcard = I
		if(!idscan)
			user.transferItemToLoc(idcard, src)
			idscan = idcard

	else if(iswrench(I))
		playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
		anchored = !anchored
		to_chat(user, "<span class='notice'>You [anchored ? "wrench" : "unwrench"] \the [src].</span>")


/obj/machinery/faxmachine/cic
	department = "Combat Information Center"

/obj/machinery/faxmachine/cmp
	department = "Command Master at Arms"

/obj/machinery/faxmachine/brig
	department = "Brig"

/obj/machinery/faxmachine/research
	department = "Research"

/obj/machinery/faxmachine/warden //Prison Station
	department = "Warden"