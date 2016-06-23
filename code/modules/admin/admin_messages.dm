
/datum/admins/proc/viewUnheardAhelps()
	set name = "View Unheard Ahelps"
	set desc = "View any Ahelps that went unanswered"
	set category = "Admin"

	var/body = "<html><head><title>Unheard Ahelps</title></head>" //DISCLAMER: I suck at HTML
	body += "<body><B>Unheard Ahelps</B>"
	body += "<br>"

	for(var/CID in unansweredAhelps)
		body += "[unansweredAhelps[CID]]" //If I have done these correctly, it should have the options bar as well a mark and noresponse

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
		body += "<a href='?_src_=holder;CentcommFaxView=\ref[text]'>view message</a>"
		var/obj/machinery/faxmachine/F = locate(CLFaxes[text])
		if(F) body += "   <a href='?src=holder;SolGovFaxReply=\"null\";originfax=\ref[F]'>RPLY</a>"
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
		body += "<a href='?_src_=holder;CentcommFaxView=\ref[text]'>view message</a>"
		var/obj/machinery/faxmachine/F = locate(USCMFaxes[text])
		if(F) body += "   <a href='?src=holder;CentCommFaxReply=\"null\";originfax=\ref[F]'>RPLY</a>"
		body += "<br><br>"

	body += "<br><br></body></html>"
	src << browse(body, "window=uscmfaxviewer;size=300x600")