/datum/admins/proc/map_template_load()
	set category = "Debug"
	set name = "Map template - Place"

	if(!check_rights(R_FUN))
		return

	var/datum/map_template/template

	var/map = input(usr, "Choose a Map Template to place at your CURRENT LOCATION", "Place Map Template") as null|anything in SSmapping.map_templates
	if(!map)
		return

	template = SSmapping.map_templates[map]

	var/turf/T = get_turf(usr)
	if(!T)
		return

	var/list/preview = list()
	for(var/S in template.get_affected_turfs(T, TRUE))
		var/image/item = image('icons/turf/overlays.dmi', S, "greenOverlay")
		item.plane = ABOVE_LIGHTING_PLANE
		preview += item

	var/delete
	if(alert(usr, "Delete already placed objects?", "Delete", "Yes", "No") == "Yes")
		delete = TRUE

	usr.client.images += preview
	if(alert(usr, "Are you sure you want to place your template here?", "Template Confirm", "Yes", "No") != "Yes")
		usr.client.images -= preview
		return
	if(!template.load(T, TRUE, delete))
		usr.client.images -= preview
		return
	usr.client.images -= preview

	log_admin("[key_name(usr)] has placed a map template '[template.name]' at [AREACOORD(T)]")
	message_admins("[ADMIN_TPMONTY(usr)] has placed a map template '[template.name]' at [ADMIN_COORDJMP(T)]")



/datum/admins/proc/map_template_upload()
	set category = "Debug"
	set name = "Map Template - Upload"

	if(!check_rights(R_FUN))
		return

	var/map = input(usr, "Choose a Map Template to upload to template storage", "Upload Map Template") as null|file
	if(!map)
		return

	if(copytext_char("[map]", -4) != ".dmm")//4 == length(".dmm")
		to_chat(usr, span_warning("Filename must end in '.dmm': [map]"))
		return

	var/datum/map_template/M
	switch(alert(usr, "What kind of map is this?", "Map type", "Normal", "Shuttle", "Cancel"))
		if("Normal")
			M = new /datum/map_template(map, "[map]", TRUE)
		if("Shuttle")
			to_chat(usr, span_warning("Not implemented yet."))
			return
			//M = new /datum/map_template/shuttle(map, "[map]", TRUE)
		else
			return
	if(!M.cached_map)
		to_chat(usr, span_warning("Map template '[map]' failed to parse properly."))
		return

	var/datum/map_report/report = M.cached_map.check_for_errors()
	var/report_link
	if(report)
		report.show_to(usr)
		report_link = " - <a href='?src=[REF(report)];[HrefToken(TRUE)];show=1'>validation report</a>"
		to_chat(usr, span_warning("Map template '[map]' <a href='?src=[REF(report)];[HrefToken()];show=1'>failed validation</a>."))
		if(report.loadable)
			var/response = alert(usr, "The map failed validation, would you like to load it anyways?", "Map Errors", "Cancel", "Upload Anyways")
			if(response != "Upload Anyways")
				return
		else
			to_chat(usr, span_warning("The map failed validation and cannot be loaded."))
			return

	SSmapping.map_templates[M.name] = M

	log_admin("[key_name(usr)] has uploaded a map template '[map]' ([M.width]x[M.height])[report_link].")
	message_admins("[ADMIN_TPMONTY(usr)] has uploaded a map template '[map]' ([M.width]x[M.height])[report_link].")
