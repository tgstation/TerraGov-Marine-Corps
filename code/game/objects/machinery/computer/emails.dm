/obj/machinery/computer/emails
	name = "Personal Computer"
	desc = "A personal computer used to view emails"
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "terminal"
	screen_overlay = "terminal1"
	var/screen = 0
	var/email_type = /datum/fluff_email/mainship //the type of emails this computer will show. e.g. TGMC emails for the personal computers on the ship
	var/list/email_list
	var/selected_mail


/obj/machinery/computer/emails/Initialize(mapload)
	. = ..()
	email_list = list()
	var/list/L = subtypesof(email_type)
	var/email_amt = rand(2, 4)
	for(var/i in 1 to email_amt)
		var/path = pick_n_take(L)
		email_list += new path()

/obj/machinery/computer/emails/Destroy()
	email_list = null
	return ..()


/obj/machinery/computer/emails/interact(mob/user)
	. = ..()
	if(.)
		return

	var/dat

	switch(screen)
		if(0)
			dat += "<A href='?src=[text_ref(src)];open_inbox=1'><font size=4>Inbox</font></A><HR>"
		if(1)
			dat += "<font size=4>Inbox</font> | <A href='?src=[text_ref(src)];close_inbox=1'>Close</A><HR>"
			if(selected_mail)
				var/datum/fluff_email/E = email_list[selected_mail]
				dat += "<b>SUBJECT: [E.title]</b><HR>"
				dat += "<b>FROM:</b> NAME EXPUNGED<BR>"
				dat += "<b>TO:</b> NAME EXPUNGED<BR><BR>"
				dat += "[E.entry_text]<HR>"
				dat += "<A href='?src=[text_ref(src)];back=1'>Back</A>"
			else
				var/i = 0
				for(var/mail in email_list)
					i++
					var/datum/fluff_email/FE = mail
					dat += "<A href='?src=[text_ref(src)];selectmail=[i]'>[FE.title]</A><BR>"

	var/datum/browser/popup = new(user, "email", "<div align='center'>Personal Computer</div>", 600, 520)
	popup.set_content(dat)
	popup.open(FALSE)
	onclose(user, "email")


/obj/machinery/computer/emails/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(href_list["open_inbox"])
		screen = 1

	else if(href_list["close_inbox"])
		screen = 0

	else if(href_list["selectmail"])
		selected_mail = text2num(href_list["selectmail"])

	else if(href_list["back"])
		selected_mail = null

	updateUsrDialog()
