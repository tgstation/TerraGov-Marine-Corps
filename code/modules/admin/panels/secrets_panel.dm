ADMIN_VERB(utility_panel, R_DEBUG, "Utility Panel", "Utility panel with miscellaneous functions", ADMIN_CATEGORY_DEBUG)
	var/ref = "[REF(user.holder)];[HrefToken()]"
	var/dat = "<b>Use responsibly.</b><hr>"


	dat += {"
		<b>Power</b><br>
		<br>
		<a href='byond://?src=[ref];secrets=unpower'>Unpower ship SMESs and APCs</a><br>
		<a href='byond://?src=[ref];secrets=power'>Power ship SMESs and APCs</a><br>
		<a href='byond://?src=[ref];secrets=quickpower'>Power ship SMESs</a><br>
		<a href='byond://?src=[ref];secrets=powereverything'>Power ALL SMESs and APCs everywhere</a><br>
		<a href='byond://?src=[ref];secrets=blackout'>Break all lights</a><br>
		<a href='byond://?src=[ref];secrets=whiteout'>Fix all lights</a><br>
		<br>
		<b>Mass-Teleportation</b><br>
		<br>
		<a href='byond://?src=[ref];secrets=gethumans'>Get ALL humans</a><br>
		<a href='byond://?src=[ref];secrets=getxenos'>Get ALL Xenos</a><br>
		<a href='byond://?src=[ref];secrets=getall'>Get ALL living, cliented mobs</a><br>
		<br>
		<b>Mass-Rejuvenate</b><br>
		<br>
		<a href='byond://?src=[ref];secrets=rejuvall'>Rejuv ALL cliented mobs</a><br>
		"}

	var/datum/browser/browser = new(user, "secretspanel", "<div align='center'>Mode Panel</div>")
	browser.set_content(dat)
	browser.open()
