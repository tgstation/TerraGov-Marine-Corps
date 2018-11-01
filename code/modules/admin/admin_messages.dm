
/datum/admins/proc/viewUnheardAhelps()
	set name = "View Unheard Ahelps"
	set desc = "View any Ahelps that went unanswered"
	set category = "Admin"


	var/body = "<html><head><title>Unheard Ahelps</title></head>" //DISCLAMER: I suck at HTML
	body += "<body><B>Unheard Ahelps</B>"
	body += "<br>"

	var/admin_number_afk = 0
	var/list/adminholders = list()
	for(var/client/X in admins)
		if((R_ADMIN & X.holder.rights) || (R_MOD & X.holder.rights)) // just admins here please
			adminholders += X
			if(X.is_afk())
				admin_number_afk++

	if(adminholders.len && (admin_number_afk != adminholders.len))
		if((R_ADMIN & usr.client.holder.rights) || (R_MOD & usr.client.holder.rights))
			for(var/CID in unansweredAhelps)
				body += "[unansweredAhelps[CID]]" //If I have done these correctly, it should have the options bar as well a mark and noresponse
			body += "<br><br></body></html>"
			src << browse(body, "window=ahelps;size=800x300")
			return
		else
			body += "<br><br></body></html>"
			src << browse(body, "window=ahelps;size=800x300")
			return
	else
		for(var/CID in unansweredAhelps)
			body += "[unansweredAhelps[CID]]" //If I have done these correctly, it should have the options bar as well a mark and noresponse
		body += "<br><br></body></html>"
		src << browse(body, "window=ahelps;size=800x300")
		return

	

/datum/admins/proc/viewUnheardMhelps()
	set name = "View Unheard Mhelps"
	set desc = "View any Mhelps that went unanswered"
	set category = "Admin"

	var/body = "<html><head><title>Unheard Mhelps</title></head>" //DISCLAMER: I suck at HTML
	body += "<body><B>Unheard Mhelps</B>"
	body += "<br>"

	for(var/CID in unansweredMhelps)
		body += "[unansweredMhelps[CID]]" //If I have done these correctly, it should have the options bar as well a mark and noresponse

	body += "<br><br></body></html>"

	src << browse(body, "window=ahelps;size=800x300")

//By popular request
/datum/admins/proc/viewCLFaxes()
	set name = "View CL Faxes"
	set desc = "View all faxes from the CL this round"
	set category = "Admin"

	var/body = "<html><head><title>Faxes from the CL</title></head>"
	body += "<body><B>Faxes:</B>"
	body += "<br><br>"

	for(var/text in CLFaxes)
		body += text
		body += "<br><br>"

	body += "<br><br></body></html>"
	src << browse(body, "window=clfaxviewer;size=300x600")

//While I'm at it
/datum/admins/proc/viewUSCMFaxes()
	set name = "View USCM Faxes"
	set desc = "View all faxes to USCM this round"
	set category = "Admin"

	var/body = "<html><head><title>Faxes</title></head>"
	body += "<body><B>Faxes:</B>"
	body += "<br><br>"

	for(var/text in USCMFaxes)
		body += text
		body += "<br><br>"

	body += "<br><br></body></html>"
	src << browse(body, "window=uscmfaxviewer;size=300x600")