GLOBAL_LIST_EMPTY(faxes)


/datum/fax
	var/mob/sender
	var/obj/machinery/faxmachine/sendmachine
	var/department
	var/faxmachine_department
	var/title
	var/message
	var/senttime
	var/admin = FALSE
	var/marked = FALSE


/proc/send_fax(mob/sender, sendmachine, department, title, message, admin)
	var/datum/fax/F = new
	var/obj/machinery/faxmachine/SM = sendmachine
	if(admin)
		F.sender = sender.client
	else
		F.sender = sender
	F.sendmachine = SM
	if(SM)
		F.faxmachine_department = SM.department
	F.department = department
	F.title = title
	F.message = message
	F.senttime = worldtime2text()
	F.admin = admin

	GLOB.faxes[F] = F

	if(admin)
		log_admin("[key_name(sender)] sent a fax. | Adressed to: [department][SM?.department ? " | From: [SM.department]" : ""] | Titled: [title] | Message: [message]")
	else
		log_game("[key_name(sender)] sent a fax. | Adressed to: [department][SM?.department ? " | From: [SM.department]" : ""] | Titled: [title] | Message: [message]")

	if(SM)
		for(var/client/C in GLOB.admins)
			if(check_other_rights(C, R_ADMIN, FALSE))
				to_chat(C, "<span class='notice'><b><font color='#1F66A0'>FAX: </font>[ADMIN_FULLMONTY(sender)]:</b> Adressed to: [department][SM?.department ? " | From: [SM.department]" : ""] | Titled: [title] <b>(<a href='?src=[REF(C.holder)];[HrefToken(TRUE)];faxreply=[REF(F)]]'>REPLY</a>) (<a href='?src=[REF(C.holder)];[HrefToken(TRUE)];faxview=[REF(F)]'>VIEW</a>) (<a href='?src=[REF(C.holder)];[HrefToken(TRUE)];faxmark=[REF(F)]]'>MARK</a>)</b></span>")
				C << 'sound/effects/sos-morse-code.ogg'
			else
				to_chat(C, "<span class='notice'><b><font color='#1F66A0'>FAX: </font>[key_name(sender)]:</b> Adressed to: [department][SM?.department ? " | From: [SM.department]" : ""] | Titled: [title] <b>(<a href='?src=[REF(C.holder)];[HrefToken(TRUE)];faxreply=[REF(F)]]'>REPLY</a>) (<a href='?src=[REF(C.holder)];[HrefToken(TRUE)];faxview=[REF(F)]'>VIEW</a>) (<a href='?src=[REF(C.holder)];[HrefToken(TRUE)];faxmark=[REF(F)]]'>MARK</a>)</b></span>")
				C << 'sound/effects/sos-morse-code.ogg'

	for(var/x in GLOB.faxmachines)
		var/obj/machinery/faxmachine/FM = x
		if(FM == SM)
			continue
		if(FM.department != department)
			continue
		if(FM.machine_stat & (BROKEN|NOPOWER))
			continue

		flick("faxreceive", F)

		var/obj/item/paper/P = new /obj/item/paper(FM.loc)
		P.name = "[title]"
		P.info = "[message]"
		P.update_icon()

		if(admin)
			var/image/stampoverlay = image('icons/obj/items/paper.dmi')
			stampoverlay.icon_state = "paper_stamp-tgmc"
			if(!P.stamped)
				P.stamped = new
			P.stamped += /obj/item/tool/stamp
			P.overlays += stampoverlay
			P.stamps += "<HR><i>This paper has been stamped by the High Command Quantum Relay.</i>"

		playsound(FM.loc, "sound/items/polaroid1.ogg", 15, 1)


/datum/admins/proc/view_faxes()
	set category = "Fun"
	set name = "View Faxes"

	if(!check_rights(R_ADMIN, FALSE) && !is_mentor(usr.client))
		return

	var/dat

	for(var/i in GLOB.faxes)
		var/datum/fax/F = i
		if(F.admin)
			dat += "(STAFF) [F.senttime] | Title: '[F.title]' | Addressed to: [F.department]<br>"
			dat += "Sender: [key_name_admin(F.sender)] [check_rights(R_ADMIN, FALSE) ? "[ADMIN_PP(F.sender)] " : ""](<a href='?src=[REF(usr.client.holder)];[HrefToken()];faxview=[REF(F)]'>VIEW</a>)"
		else
			dat += "[F.marked ? "(MARKED BY [F.marked] " : "(UNMARKED)"] [F.senttime] | Title: [F.title] | Addressed to: [F.department][F.faxmachine_department ? " | From: [F.faxmachine_department]" : ""]<br>"
			dat += "Sender: [key_name_admin(F.sender)] [check_rights(R_ADMIN, FALSE) ? "[ADMIN_PP(F.sender)] " : ""][ADMIN_SM(F.sender)] (<a href='?src=[REF(usr.client.holder)];[HrefToken()];faxreply=[REF(F)]'>REPLY</a>) (<a href='?src=[REF(usr.client.holder)];[HrefToken()];faxview=[REF(F)]'>VIEW</a>) (<a href='?src=[REF(usr.client.holder)];[HrefToken()];faxmark=[REF(F)]'>MARK</a>)"
		dat += "<hr>"

	dat += "<a href='?src=[REF(usr.client.holder)];[HrefToken()];faxcreate=[REF(usr)]'>CREATE NEW FAX</a>"

	var/datum/browser/browser = new(usr, "faxview", "<div align='center'>Faxes</div>")
	browser.set_content(dat)
	browser.open(FALSE)


/proc/generate_templated_fax(to_department, subject, addressed_to, message_body, sent_by, sent_department)
	var/fax_html = {"
		<font face="Verdana" color="black" size="1">
			<center>
				Secure Communication SC-CLTMGC-01b
			</center>

			<hr />

			<b>Assignment detail</b><br />
			Vessel: [CONFIG_GET(string/ship_name)]
			<br />
			Date, Time: [GAME_YEAR]-[time2text(world.realtime, "MM-DD")] [worldtime2text()]<br />
			Index: #001<br />

			<hr />
			
			<br />
			Recipient: [addressed_to] [to_department], [CONFIG_GET(string/ship_name)].<br />
			Subject: <b>[subject]</b>

			<br /><br />
			[message_body]
			<br /><br />

			Regards,<br />
			<center>[sent_by] - [sent_department]</center>
			<br />
			<hr />
			<font size ="1">
				<i>
					This message is intended only for the Corporate Liason aboard the [CONFIG_GET(string/ship_name)], 
					all other suchs persons should not read, receive a copy, or be exposed to this communication in any form. 
					Failing to adhere to this warning will result in liquidation of division under Act 09.B-4. 
					By authoring a reply to this transmission, such person confirms they abide by the regulations as set forth to them.
				</i>
			</font>
		</font>	
	"}
	return fax_html