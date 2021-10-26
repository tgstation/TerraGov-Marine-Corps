/datum/admins/proc/log_panel()
	set name = "Log Panel"
	set category = "Admin"

	if(!check_rights(R_LOG))
		return

	var/ref = "[REF(usr.client.holder)];[HrefToken()]"
	var/dat = {"
		<a href='?src=[ref];admin_log=1'>Admin Log</a><br>
		<a href='?src=[ref];adminprivate_log=1'>Adminprivate Log</a><br>
		<a href='?src=[ref];asay_log=1'>Asay Log</a><br>
		<a href='?src=[ref];msay_log=1'>Msay Log</a><br>
		<br>
		<a href='?src=[ref];say_log=1'>Say Log</a><br>
		<a href='?src=[ref];telecomms_log=1'>Telecomms Log</a><br>
		<a href='?src=[ref];game_log=1'>Game Log</a><br>
		<a href='?src=[ref];manifest_log=1'>Manifest Log</a><br>
		<a href='?src=[ref];access_log=1'>Access Log</a><br>
		<br>
		<a href='?src=[ref];attack_log=1'>Attack Log</a><br>
		<a href='?src=[ref];ffattack_log=1'>FF Attack Log</a><br>
		<a href='?src=[ref];explosion_log=1'>Explosion Log</a><br>
		"}

	var/datum/browser/browser = new(usr, "logpanel", "<div align='center'>Log Panel</div>", 220, 350)
	browser.set_content(dat)
	browser.open()
