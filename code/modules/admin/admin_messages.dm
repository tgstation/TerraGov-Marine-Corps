
/client/proc/viewUnheardAhelps()
	set name = "View Unheard Ahelps"
	set desc = "View any Ahelps that went unanswered"
	set category = "Admin"

	var/body = "<html><head><title>Unheard Ahelps</title></head>" //DISCLAMER: I suck at HTML
	body += "<body><B>Unheard Ahelps</B>"
	body += "<br><br>"
	body += "<a href='?deleteallahelps=\ref[src]'>Delete All</a>"

	for(var/message in unansweredAhelps)
		body += "[message]<br>" //If I have done these correctly, it should have the options bar as well a mark and noresponse
		body += "<a href='?deleteahelp=[message]'>Delete</a>"
		body += "<br><br>"

	body += "<br><br></body></html>"

	src << browse(body, "size=550x550")

