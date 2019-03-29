/datum/admins/proc/secrets_panel()
	set name = "Secrets Panel"
	set category = "Admin"

	if(!check_rights(R_ADMIN))	
		return

	var/ref = "[REF(usr.client.holder)];[HrefToken()]"
	var/dat = "<b>Use responsibly.</b><hr>"


	dat += {"
		<b>Power</b><br>
		<br>
		<a href='?src=[ref];secrets=unpower'>Unpower ship SMESs and APCs</a><br>
		<a href='?src=[ref];secrets=power'>Power ship SMESs and APCs</a><br>
		<a href='?src=[ref];secrets=quickpower'>Power ship SMESs</a><br>
		<a href='?src=[ref];secrets=powereverything'>Power ALL SMESs and APCs everywhere</a><br>
		<a href='?src=[ref];secrets=blackout'>Break all lights</a><br>
		<a href='?src=[ref];secrets=whiteout'>Fix all lights</a><br>
		<br>
		<b>Mass-Teleportation</b><br>
		<br>
		<a href='?src=[ref];secrets=gethumans'>Get ALL humans</a><br>
		<a href='?src=[ref];secrets=getxenos'>Get ALL Xenos</a><br>
		<a href='?src=[ref];secrets=getall'>Get ALL living, cliented mobs</a><br>
		<br>
		<b>Mass-Rejuvenate</b><br>
		<br>
		<a href='?src=[ref];secrets=rejuvall'>Rejuv ALL cliented mobs</a><br>
		"}

	var/datum/browser/browser = new(usr, "secretspanel", "<div align='center'>Mode Panel</div>")
	browser.set_content(dat)
	browser.open()