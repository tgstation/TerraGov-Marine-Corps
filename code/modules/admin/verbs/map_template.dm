ADMIN_VERB(map_template_load, R_FUN, "Map template - Place", "Place an existing map template", ADMIN_CATEGORY_DEBUG)
	var/datum/map_template/template

	var/map = input(user, "Choose a Map Template to place at your CURRENT LOCATION", "Place Map Template") as null|anything in SSmapping.map_templates
	if(!map)
		return

	template = SSmapping.map_templates[map]

	var/turf/T = get_turf(user.mob)
	if(!T)
		return

	var/list/preview = list()
	for(var/S in template.get_affected_turfs(T, TRUE))
		var/image/item = image('icons/turf/overlays.dmi', S, "greenOverlay")
		SET_PLANE(item, ABOVE_LIGHTING_PLANE, T)
		preview += item

	var/delete
	if(alert(usr, "Delete already placed objects?", "Delete", "Yes", "No") == "Yes")
		delete = TRUE

	user.images += preview
	if(alert(user, "Are you sure you want to place your template here?", "Template Confirm", "Yes", "No") != "Yes")
		user.images -= preview
		return
	if(!template.load(T, TRUE, delete))
		user.images -= preview
		return
	user.images -= preview

	log_admin("[key_name(user)] has placed a map template '[template.name]' at [AREACOORD(T)]")
	message_admins("[ADMIN_TPMONTY(user.mob)] has placed a map template '[template.name]' at [ADMIN_COORDJMP(T)]")


ADMIN_VERB(map_template_upload, R_FUN, "Map template - Upload", "Upload and place a map template", ADMIN_CATEGORY_DEBUG)
	var/map = input(user, "Choose a Map Template to upload to template storage", "Upload Map Template") as null|file
	if(!map)
		return

	if(copytext("[map]", -4) != ".dmm")//4 == length(".dmm")
		to_chat(user, span_warning("Filename must end in '.dmm': [map]"))
		return

	var/datum/map_template/M
	switch(alert(user, "What kind of map is this?", "Map type", "Normal", "Shuttle", "Cancel"))
		if("Normal")
			M = new /datum/map_template(map, "[map]", TRUE)
		if("Shuttle")
			M = new /datum/map_template/shuttle(map, "[map]", TRUE)
		else
			return
	if(!M.cached_map)
		to_chat(user, span_warning("Map template '[map]' failed to parse properly."))
		return

	var/datum/map_report/report = M.cached_map.check_for_errors()
	var/report_link
	if(report)
		report.show_to(user.mob)
		report_link = " - <a href='byond://?src=[REF(report)];[HrefToken(TRUE)];show=1'>validation report</a>"
		to_chat(user, span_warning("Map template '[map]' <a href='byond://?src=[REF(report)];[HrefToken()];show=1'>failed validation</a>."))
		if(report.loadable)
			var/response = alert(user, "The map failed validation, would you like to load it anyways?", "Map Errors", "Cancel", "Upload Anyways")
			if(response != "Upload Anyways")
				return
		else
			to_chat(user, span_warning("The map failed validation and cannot be loaded."))
			return

	SSmapping.map_templates[M.name] = M

	log_admin("[key_name(user)] has uploaded a map template '[map]' ([M.width]x[M.height])[report_link].")
	message_admins("[ADMIN_TPMONTY(user.mob)] has uploaded a map template '[map]' ([M.width]x[M.height])[report_link].")
