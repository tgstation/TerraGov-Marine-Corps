/datum/admins/proc/secrets_panel()
	set name = "Secrets Panel"
	set category = "Admin"

	if(!check_rights(R_ADMIN))	
		return

	var/dat = "<b>Papa Echard is watching.</b><hr>"


	dat += {"
		<b>Power</b><br>
		<br>
		<a href='?src=[REF(src)];[HrefToken()];secretsfun=unpower'>Unpower ship SMESs and APCs</a><br>
		<a href='?src=[REF(src)];[HrefToken()];secretsfun=power'>Power ship SMESs and APCs</a><br>
		<a href='?src=[REF(src)];[HrefToken()];secretsfun=quickpower'>Power ship SMESs</a><br>
		<a href='?src=[REF(src)];[HrefToken()];secretsfun=powereverything'>Power ALL SMESs and APCs everywhere</a><br>
		<a href='?src=[REF(src)];[HrefToken()];secretsfun=blackout'>Break all lights</a><br>
		<a href='?src=[REF(src)];[HrefToken()];secretsfun=whiteout'>Fix all lights</a><br>
		<br>
		<b>Mass-Teleportation</b><br>
		<br>
		<a href='?src=[REF(src)];[HrefToken()];secretsfun=gethumans'>Get ALL humans</a><br>
		<a href='?src=[REF(src)];[HrefToken()];secretsfun=getxenos'>Get ALL Xenos</a><br>
		<a href='?src=[REF(src)];[HrefToken()];secretsfun=getall'>Get ALL living, cliented mobs</a><br>
		<br>
		<b>Mass-Rejuvenate</b><br>
		<br>
		<a href='?src=[REF(src)];[HrefToken()];secretsfun=rejuvall'>Rejuv ALL cliented mobs</a><br>
		"}

	usr << browse(dat, "window=secrets")