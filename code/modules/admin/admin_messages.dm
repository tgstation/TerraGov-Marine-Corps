
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

