/datum/admins/proc/secrets_panel()
	set name = "Secrets Panel"
	set category = "Admin"

	if(!check_rights(R_ADMIN))	
		return

	var/dat = "<b>Papa Echard is watching.</b><hr>"


	dat += {"
		<b>Power</b><br>
		<br>
		<a href='?src=[REF(src)];[HrefToken()];secrets=unpower'>Unpower ship SMESs and APCs</a><br>
		<a href='?src=[REF(src)];[HrefToken()];secrets=power'>Power ship SMESs and APCs</a><br>
		<a href='?src=[REF(src)];[HrefToken()];secrets=quickpower'>Power ship SMESs</a><br>
		<a href='?src=[REF(src)];[HrefToken()];secrets=powereverything'>Power ALL SMESs and APCs everywhere</a><br>
		<a href='?src=[REF(src)];[HrefToken()];secrets=blackout'>Break all lights</a><br>
		<a href='?src=[REF(src)];[HrefToken()];secrets=whiteout'>Fix all lights</a><br>
		<br>
		<b>Mass-Teleportation</b><br>
		<br>
		<a href='?src=[REF(src)];[HrefToken()];secrets=gethumans'>Get ALL humans</a><br>
		<a href='?src=[REF(src)];[HrefToken()];secrets=getxenos'>Get ALL Xenos</a><br>
		<a href='?src=[REF(src)];[HrefToken()];secrets=getall'>Get ALL living, cliented mobs</a><br>
		<br>
		<b>Mass-Rejuvenate</b><br>
		<br>
		<a href='?src=[REF(src)];[HrefToken()];secrets=rejuvall'>Rejuv ALL cliented mobs</a><br>
		"}

	usr << browse(dat, "window=secrets")