GLOBAL_DATUM(medal_management_panel, /datum/medal_management_panel)

ADMIN_VERB(medal_management_panel, R_FUN, "Medal Management", "Manage a players medals.", ADMIN_CATEGORY_MAIN)
	if(!SSdbcore.IsConnected())
		to_chat(user, span_warning("The database is not connected."))
		return

	if(!GLOB.medal_management_panel)
		GLOB.medal_management_panel = new /datum/medal_management_panel()

	GLOB.medal_management_panel.ui_interact(user.mob)

/datum/medal_management_panel
	interaction_flags = INTERACT_UI_INTERACT

/datum/medal_management_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(ui)
		return
	ui = new(user, src, "MedalPanel")
	ui.open()

/datum/medal_management_panel/ui_state(mob/user)
	return GLOB.always_state

/datum/medal_management_panel/ui_static_data(mob/user)
	var/list/data = list()
	data["medals"] = list()
	for(var/ckey in GLOB.medal_persistence_datums_by_ckey)
		var/datum/medal_persistence/persistence = GLOB.medal_persistence_datums_by_ckey[ckey]
		for(var/realname in persistence.medals_by_real_name)
			for(var/datum/persistent_medal_info/medal AS in persistence.medals_by_real_name[realname])
				data["medals"] += list(list(
					"id" = medal.id,
					"ckey" = ckey,
					"real_name" = realname,
					"medal_citation" = medal.medal_citation,
					"issued_by_real_name" = medal.issued_by_real_name,
					"issued_at" = medal.issued_at,
					"is_posthumous" = medal.is_posthumous,
				))
	return data

/datum/medal_management_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("delete")
			var/ckey = params["ckey"]
			var/id = params["id"]
			var/realname = params["real_name"]
			var/datum/medal_persistence/medal_datum = GLOB.medal_persistence_datums_by_ckey[ckey]
			if(!medal_datum)
				return FALSE
			var/datum/persistent_medal_info/medal_to_delete
			for(var/datum/persistent_medal_info/medal AS in medal_datum.medals_by_real_name[realname])
				if(medal.id == id)
					medal_to_delete = medal
					break

			var/make_sure_msg = "Are you sure you want to delete " + ckey + "'s medal? Citation: " + medal_to_delete.medal_citation + ". Issued by: " + medal_to_delete.issued_by_real_name + ", to " + medal_to_delete.issued_to_real_name + "."
			if(tgui_alert(usr, make_sure_msg, "PERMANENT MEDAL DELETION FOR [ckey]", list("No", "Yes", "No") != "Yes"))
				return FALSE
			medal_datum.mark_medal_as_deleted(medal_to_delete)
			message_admins("[key_name_admin(usr)] has deleted a medal (UID:[medal_to_delete.id]) for [ckey] issued at [medal_to_delete.issued_at].")
			log_admin_private("[key_name_admin(usr)] has deleted a medal (UID:[medal_to_delete.id]) for [ckey] issued at [medal_to_delete.issued_at]. Issued by: [medal_to_delete.issued_by_real_name], to [medal_to_delete.issued_to_real_name]. Citation: [medal_to_delete.medal_citation].")
			update_static_data_for_all_viewers()
			return TRUE
