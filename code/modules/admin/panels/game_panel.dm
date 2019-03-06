/datum/admins/proc/game_panel()
	set name = "Game Panel"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return

	var/ref = "[REF(usr.client.holder)];[HrefToken()]"
	var/dat = {"
		<a href='?src=[ref];modemenu=1'>Change Game Mode</a><br>
		<br>
		<a href='?src=[ref];create_object=1'>Create Object</a><br>
		<a href='?src=[ref];quick_create_object=1'>Quick Create Object</a><br>
		<a href='?src=[ref];create_turf=1'>Create Turf</a><br>
		<a href='?src=[ref];create_mob=1'>Create Mob</a><br>
		<br>
		<a href='?src=[ref];admin_log=1'>Admin Log</a><br>
		<a href='?src=[ref];ffattack_log=1'>FF Log</a><br>
		<a href='?src=[ref];explosion_log=1'>Explosion Log</a><br>
		"}

	var/datum/browser/browser = new(usr, "gamepanel", "<div align='center'>Game Panel</div>", 220, 290)
	browser.set_content(dat)
	browser.open()


/datum/admins/proc/create_mob(mob/user)
	if(!check_rights(R_SPAWN))
		return

	var/static/create_mob_html
	if(!create_mob_html)
		var/mobjs = null
		mobjs = jointext(typesof(/mob), ";")
		create_mob_html = file2text('html/create_object.html')
		create_mob_html = replacetext(create_mob_html, "Create Object", "Create Mob")
		create_mob_html = replacetext(create_mob_html, "null /* object types */", "\"[mobjs]\"")

	user << browse(create_panel_helper(create_mob_html), "window=create_mob;size=425x475")


/datum/admins/proc/create_panel_helper(template)
	if(!check_rights(R_SPAWN))
		return

	var/final_html = replacetext(template, "/* ref src */", "[REF(src)];[HrefToken()]")
	final_html = replacetext(final_html,"/* hreftokenfield */","[HrefTokenFormField()]")
	return final_html


/datum/admins/proc/create_object(mob/user)
	if(!check_rights(R_SPAWN))
		return

	var/static/create_object_html = null
	if(!create_object_html)
		var/objectjs = null
		objectjs = jointext(typesof(/obj), ";")
		create_object_html = file2text('html/create_object.html')
		create_object_html = replacetext(create_object_html, "null /* object types */", "\"[objectjs]\"")

	user << browse(create_panel_helper(create_object_html), "window=create_object;size=425x475")


/datum/admins/proc/quick_create_object(mob/user)
	if(!check_rights(R_SPAWN))
		return

	var/static/list/create_object_forms = list(
	/obj, /obj/structure, /obj/machinery, /obj/effect, /obj/item, /obj/item/clothing, /obj/item/stack, /obj/item, /obj/item/weapon)

	var/path = input("Select the path of the object you wish to create.", "Path", /obj) in create_object_forms
	var/html_form = create_object_forms[path]

	if(!html_form)
		var/objectjs = jointext(typesof(path), ";")
		html_form = file2text('html/create_object.html')
		html_form = replacetext(html_form, "Create Object", "Create [path]")
		html_form = replacetext(html_form, "null /* object types */", "\"[objectjs]\"")
		create_object_forms[path] = html_form

	user << browse(create_panel_helper(html_form), "window=qco[path];size=425x475")


/datum/admins/proc/create_turf(mob/user)
	if(!check_rights(R_SPAWN))
		return

	var/static/create_turf_html
	if(!create_turf_html)
		var/turfjs = null
		turfjs = jointext(typesof(/turf), ";")
		create_turf_html = file2text('html/create_object.html')
		create_turf_html = replacetext(create_turf_html, "Create Object", "Create Turf")
		create_turf_html = replacetext(create_turf_html, "null /* object types */", "\"[turfjs]\"")

	user << browse(create_panel_helper(create_turf_html), "window=create_turf;size=425x475")