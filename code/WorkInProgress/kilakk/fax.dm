var/list/obj/machinery/faxmachine/allfaxes = list()
var/list/alldepartments = list()

/obj/machinery/faxmachine
	name = "fax machine"
	icon = 'icons/obj/machines/library.dmi'
	icon_state = "fax"
//	req_one_access = list(ACCESS_MARINE_BRIDGE) //Warden needs to be able to Fax solgov too.
	anchored = 1
	density = 1
	use_power = 1
	idle_power_usage = 30
	active_power_usage = 200
	power_channel = EQUIP

	var/obj/item/card/id/scan = null // identification
	var/authenticated = 0

	var/obj/item/paper/tofax = null // what we're sending
	var/sendcooldown = 0 // to avoid spamming fax messages

	var/department = "Liaison" // our department

	var/dpt = "Weyland Yutani" // the department we're sending to


/obj/machinery/faxmachine/New()
	..()
	allfaxes += src

	if( !("[department]" in alldepartments) ) //Initialize departments. This will work with multiple fax machines.
		alldepartments += department
	if(!("Weyland Yutani" in alldepartments))
		alldepartments += "Weyland Yutani"
	if(!("USCM High Command" in alldepartments))
		alldepartments += "USCM High Command"

/obj/machinery/faxmachine/process()
	return 0

/obj/machinery/faxmachine/attack_ai(mob/user as mob)
	return attack_hand(user)

/obj/machinery/faxmachine/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/machinery/faxmachine/attack_hand(mob/user as mob)
	user.set_interaction(src)

	var/dat = "Fax Machine<BR>"

	var/scan_name
	if(scan)
		scan_name = scan.name
	else
		scan_name = "--------"

	dat += "Confirm Identity: <a href='byond://?src=\ref[src];scan=1'>[scan_name]</a><br>"

	if(authenticated)
		dat += "<a href='byond://?src=\ref[src];logout=1'>{Log Out}</a>"
	else
		dat += "<a href='byond://?src=\ref[src];auth=1'>{Log In}</a>"

	dat += "<hr>"

	if(authenticated)
		dat += "<b>Logged in to:</b> Weyland-Yutani Private Corporate Network<br><br>"

		if(tofax)
			dat += "<a href='byond://?src=\ref[src];remove=1'>Remove Paper</a><br><br>"

			if(sendcooldown)
				dat += "<b>Transmitter arrays realigning. Please stand by.</b><br>"

			else
				dat += "<a href='byond://?src=\ref[src];send=1'>Send</a><br>"
				dat += "<b>Currently sending:</b> [tofax.name]<br>"
				dat += "<b>Sending to:</b> <a href='byond://?src=\ref[src];dept=1'>[dpt]</a><br>"

		else
			if(sendcooldown)
				dat += "Please insert paper to send via secure connection.<br><br>"
				dat += "<b>Transmitter arrays realigning. Please stand by.</b><br>"
			else
				dat += "Please insert paper to send via secure connection.<br><br>"

	else
		dat += "Proper authentication is required to use this device.<br><br>"

		if(tofax)
			dat += "<a href ='byond://?src=\ref[src];remove=1'>Remove Paper</a><br>"

	user << browse(dat, "window=copier")
	onclose(user, "copier")
	return

/obj/machinery/faxmachine/Topic(href, href_list)
	if(href_list["send"])
		if(tofax)

			if(dpt == "USCM High Command")
				Centcomm_fax(src, tofax.info, tofax.name, usr)
				sendcooldown = 1200

			else if(dpt == "Weyland Yutani")
				Solgov_fax(src, tofax.info, tofax.name, usr)
				sendcooldown = 1200
			else
				SendFax(tofax.info, tofax.name, usr, dpt)
				sendcooldown = 600

			usr << "Message transmitted successfully."

			spawn(sendcooldown) // cooldown time
				sendcooldown = 0

	if(href_list["remove"])
		if(tofax)
			if(!ishuman(usr))
				usr << "<span class='warning'>You can't do it.</span>"
			else
				tofax.loc = usr.loc
				usr.put_in_hands(tofax)
				usr << "<span class='notice'>You take the paper out of \the [src].</span>"
				tofax = null

	if(href_list["scan"])
		if (scan)
			if(ishuman(usr))
				scan.loc = usr.loc
				if(!usr.get_active_hand())
					usr.put_in_hands(scan)
				scan = null
			else
				scan.loc = src.loc
				scan = null
		else
			var/obj/item/I = usr.get_active_hand()
			if (istype(I, /obj/item/card/id))
				usr.drop_inv_item_to_loc(I, src)
				scan = I
		authenticated = 0

	if(href_list["dept"])
		var/lastdpt = dpt
		dpt = input(usr, "Which department?", "Choose a department", "") as null|anything in alldepartments
		if(!dpt) dpt = lastdpt

	if(href_list["auth"])
		if ( (!( authenticated ) && (scan)) )
			if (check_access(scan))
				authenticated = 1

	if(href_list["logout"])
		authenticated = 0

	updateUsrDialog()

/obj/machinery/faxmachine/attackby(obj/item/O as obj, mob/user as mob)

	if(istype(O, /obj/item/paper))
		if(!tofax)
			user.drop_inv_item_to_loc(O, src)
			tofax = O
			user << "<span class='notice'>You insert the paper into \the [src].</span>"
			flick("faxsend", src)
			updateUsrDialog()
		else
			user << "<span class='notice'>There is already something in \the [src].</span>"

	else if(istype(O, /obj/item/card/id))

		var/obj/item/card/id/idcard = O
		if(!scan)
			user.drop_inv_item_to_loc(idcard, src)
			scan = idcard

	else if(istype(O, /obj/item/tool/wrench))
		playsound(loc, 'sound/items/Ratchet.ogg', 25, 1)
		anchored = !anchored
		user << "<span class='notice'>You [anchored ? "wrench" : "unwrench"] \the [src].</span>"
	return

/proc/Centcomm_fax(var/originfax, var/sent, var/sentname, var/mob/Sender)
	var/faxcontents = "[sent]"
	fax_contents += faxcontents
	var/msg = "\blue <b><font color='#006100'>USCM FAX: </font>[key_name(Sender, 1)] (<A HREF='?_src_=holder;mark=\ref[src]'>Mark</A>) (<A HREF='?_src_=holder;adminplayeropts=\ref[Sender]'>PP</A>) (<A HREF='?_src_=vars;Vars=\ref[Sender]'>VV</A>) (<A HREF='?_src_=holder;subtlemessage=\ref[Sender]'>SM</A>) (<A HREF='?_src_=holder;adminplayerobservejump=\ref[Sender]'>JMP</A>) (<A HREF='?_src_=holder;secretsadmin=check_antagonist'>CA</A>) (<a href='?_src_=holder;USCMFaxReply=\ref[Sender];originfax=\ref[originfax]'>RPLY</a>)</b>: Receiving '[sentname]' via secure connection ... <a href='?_src_=holder;CentcommFaxView=\ref[faxcontents]'>view message</a>"
	USCMFaxes.Add("<a href='?_src_=holder;CentcommFaxView=\ref[faxcontents]'>\[view message at [world.timeofday]\]</a> <a href='?_src_=holder;USCMFaxReply=\ref[Sender];originfax=\ref[originfax]'>REPLY</a>")
	for(var/client/C in admins)
		C << msg

/proc/Solgov_fax(var/originfax, var/sent, var/sentname, var/mob/Sender)
	var/faxcontents = "[sent]"
	fax_contents += faxcontents
	var/msg = "\blue <b><font color='#1F66A0'>WEYLAND-YUTANI FAX: </font>[key_name(Sender, 1)] (<A HREF='?_src_=holder;ccmark=\ref[Sender]'>Mark</A>) (<A HREF='?_src_=holder;adminplayeropts=\ref[Sender]'>PP</A>) (<A HREF='?_src_=vars;Vars=\ref[Sender]'>VV</A>) (<A HREF='?_src_=holder;subtlemessage=\ref[Sender]'>SM</A>) (<A HREF='?_src_=holder;adminplayerobservejump=\ref[Sender]'>JMP</A>) (<A HREF='?_src_=holder;secretsadmin=check_antagonist'>CA</A>) (<a href='?_src_=holder;CLFaxReply=\ref[Sender];originfax=\ref[originfax]'>RPLY</a>)</b>: Receiving '[sentname]' via secure connection ... <a href='?_src_=holder;CentcommFaxView=\ref[faxcontents]'>view message</a>"
	CLFaxes.Add("<a href='?_src_=holder;CentcommFaxView=\ref[faxcontents]'>\[view message at [world.timeofday]\]</a> <a href='?_src_=holder;CLFaxReply=\ref[Sender];originfax=\ref[originfax]'>REPLY</a>")
	for(var/client/C in admins)
		if((R_ADMIN|R_MOD) & C.holder.rights)
			C << msg
			C << 'sound/effects/sos-morse-code.ogg'

proc/SendFax(var/sent, var/sentname, var/mob/Sender, var/dpt)

	for(var/obj/machinery/faxmachine/F in allfaxes)
		if( F.department == dpt )
			if(! (F.stat & (BROKEN|NOPOWER) ) )

				flick("faxreceive", F)

				// give the sprite some time to flick
				spawn(20)
					var/obj/item/paper/P = new /obj/item/paper( F.loc )
					P.name = "[sentname]"
					P.info = "[sent]"
					P.update_icon()

					playsound(F.loc, "sound/items/polaroid1.ogg", 15, 1)
