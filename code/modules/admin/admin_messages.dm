
/client/proc/viewUnheardAhelps()
	set name = "View Unheard Ahelps"
	set desc = "View any Ahelps made with 0 non-AFK staff members"
	set category = "Admin"

	var/body = "<html><head><title>Unheard Ahelps</title></head>" //DISCLAMER: I suck at HTML
	body += "<body><B>Unheard Ahelps</B>
	body += "<br><br><br>"


	for(var/message in unheardAhelps)
		body += "[message]<br>"

	body += "<br><br></body></html>"

	src << browse(body, "size=550x550")

