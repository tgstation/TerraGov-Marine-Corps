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
			stampoverlay.icon_state = "paper_stamp-uscm"
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


/proc/generate_templated_fax(show_nt_logo, fax_header, fax_subject, addressed_to, message_body, sent_by, sent_department)
	var/dat = ""
	dat += "<style>"
	dat += "body {"
	dat += "margin:0 auto;"
	dat += "padding:0;"
	dat += "background-image: url('https://i.imgur.com/uM2I2gT.jpg');"
	dat += "font-family: monospace;"
	dat += "}"

	dat += "#fax-logo {"
	dat += "text-align: center;"
	dat += "}"

	dat += "#fax-logo img {"
	dat += "width:250px;"
	dat += "margin-top: 20px;"
	dat += "margin-bottom: 12px;"
	dat += "opacity: .6;"
	dat += "}"

	dat += "#width-container {"
	dat += "width: 500px;"
	dat += "min-height:500px;"
	dat += "margin:0 auto;"
	dat += "margin-top: 10px;"
	dat += "margin-bottom: 10px;"
	dat += "padding-left: 20px;"
	dat += "padding-right: 20px;"
	dat += "}"

	dat += ".message-header-text p {"
	dat += "text-align: center;"
	dat += "margin: 0;"
	dat += "margin-bottom: 40px;"
	dat += "}"

	dat += "#header-title {"
	dat += "font-size: 17px;"
	dat += "font-weight: 600;"
	dat += "margin-bottom: 7px;"
	dat += "}"

	dat += "#header-subtitle {"
	dat += "font-size: 17px;"
	dat += "}"

	dat += ".message-body-text p {"
	dat += "text-align: left;"
	dat += "font-size: 17px;"
	dat += "}"

	dat += ".message-signature-text p {"
	dat += "text-align:right;"
	dat += "font-size:15px;"
	dat += "margin-bottom: 20px;"
	dat += "}"
	dat += "</style>"

	dat += "<body>"
	dat += "<div id='width-container'>"

	dat += "<div class='message-header-text'>"
	dat += "<p id='header-title'>[fax_header]</p>"
	dat += "<p id='header-subtitle'>[fax_subject] - [time2text(world.realtime, "DD Month")] [GAME_YEAR]</p>"
	dat += "</div> <!-- /message-header-text -->"

	dat += "<div class='message-body-text'>"

	dat += "<p>[addressed_to],</p>"

	dat += "[message_body]"

	dat += "</div> <!-- /message-body-text -->"

	dat += "<div class='message-signature-text'>"
	dat += "<p>"
	dat += "<em>[sent_by]</em>"
	dat += "<br/>"
	dat += "<em>[sent_department]</em>"
	dat += "<br/>"
	dat += "</p>"
	dat += "</div> <!-- /message-signature-text -->"

	dat += "</div> <!-- /width-container -->"
	dat += "</body>"
	return dat