/client/verb/manage_decals()
	set category = "OOC"
	set name = "Favourite/View Decals"

	SScustom_decals.ui_interact(mob)


#define DECAL_DATA_FILE "data/custom_decals/_decal_data.json"
#define DECAL_DATA_FORMAT_VERSION 1

//todo need to sanitize this when saving prefs
#define MAX_FAVOURITE_DECALS 10

SUBSYSTEM_DEF(custom_decals)
	name = "Custom Decals"
	init_order = INIT_ORDER_CUSTOM_DECALS
	flags = SS_NO_FIRE

	var/list/datum/custom_decal/decals = list()
	var/list/deleted_decal_md5s = list()

/datum/controller/subsystem/custom_decals/Initialize()
	var/json_file = file(DECAL_DATA_FILE)
	if(fexists(json_file))
		var/list/old_data = json_decode(file2text(json_file))
		for(var/list/decal_data AS in old_data["decals"])
			var/datum/custom_decal/new_decal = new
			new_decal.deserialize_list(decal_data)
			decals += new_decal
	return SS_INIT_SUCCESS

/datum/controller/subsystem/custom_decals/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DecalManager", "Decal Managment")
		ui.open()

/datum/controller/subsystem/custom_decals/ui_data(mob/user)
	var/list/data = list()
	data["favourite_decals"] = user.client.prefs.favourite_decals
	return data

/datum/controller/subsystem/custom_decals/ui_state(mob/user)
	return GLOB.always_state

/datum/controller/subsystem/custom_decals/ui_static_data(mob/user)
	var/list/data = list()
	data["ckey"] = user.ckey
	data["admin_mode"] = check_other_rights(user.client, R_ADMIN, FALSE)
	data["decals"] = list()
	for(var/datum/custom_decal/decal AS in SScustom_decals.decals)
		var/list/decal_data = list()
		decal_data["name"] = decal.name
		decal_data["md5"] = decal.md5
		//calling twice should have minimal overhead, and this lets us add more at runtime
		user << browse_rsc(decal.decal_icon, "decal_[decal.md5].png")

		decal_data["creator_ckey"] = decal.creator_ckey
		decal_data["creation_round_id"] = decal.creation_round_id
		decal_data["favourites"] = decal.favourites
		decal_data["tags"] = decal.tags
		decal_data["width"] = decal.width
		decal_data["height"] = decal.height

		data["decals"] += list(decal_data)
	return data

/datum/controller/subsystem/custom_decals/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/client/client_user = usr.client
	switch(action)
		if("toggle_favourite")
			var/md5 = params["md5"]
			if(!md5)
				return FALSE
			if(md5 in client_user.prefs.favourite_decals)
				client_user.prefs.favourite_decals -= md5
				var/datum/custom_decal/decal = SScustom_decals.get_decal(md5)
				decal?.favourites--
			else
				if(length(client_user.prefs.favourite_decals) >= MAX_FAVOURITE_DECALS)
					tgui_alert(client_user, "You can only have [MAX_FAVOURITE_DECALS] favourite decals at a time")
					return FALSE
				client_user.prefs.favourite_decals += md5
				var/datum/custom_decal/decal = SScustom_decals.get_decal(md5)
				decal?.favourites++
			. = TRUE
			client_user.prefs.save_preferences()
			save_decals()
			update_static_data_for_all_viewers()
		if("new_decal")
			SScustom_decals.new_decal(client_user)
		if("delete_decal")
			var/md5 = params["md5"]
			var/reason = params["reason"]
			if(!md5 || !reason)
				return FALSE
			SScustom_decals.delete_decal(md5, client_user, reason)
			. = TRUE
		if("rename_decal")
			var/md5 = params["md5"]
			if(!md5)
				return
			var/name = params["new_name"]
			if(!name)
				return FALSE
			var/filter_result = is_ic_filtered(name)
			if(filter_result)
				to_chat(usr, span_warning("That name contained a word prohibited in IC chat! Consider reviewing the server rules.\n<span replaceRegex='show_filtered_ic_chat'>\"[name]\"</span>"))
				SSblackbox.record_feedback(FEEDBACK_TALLY, "ic_blocked_words", 1, lowertext(config.ic_filter_regex.match))
				REPORT_CHAT_FILTER_TO_USER(usr, filter_result)
				log_filter("Decal naming", name, filter_result)
				return FALSE
			if(tgui_alert(usr, "Are you sure you want to rename this decal to \"[name]\"", "Decal Rename", list("Yes", "No")) != "Yes")
				return FALSE
			SScustom_decals.rename_decal(md5, client_user, name)
			. = TRUE


///saves the current decals and writes them to the json metadata save file
/datum/controller/subsystem/custom_decals/proc/save_decals()
	var/json_file = file(DECAL_DATA_FILE)

	var/list/collated_data = list()
	if(fexists(json_file))
		var/list/old_data = json_decode(file2text(json_file))
		for(var/list/decal_data AS in old_data["decals"])
			collated_data[decal_data["md5"]] = decal_data

	var/list/decal_data = list()
	for(var/datum/custom_decal/decal AS in decals)
		collated_data[decal.md5] = decal.serialize_list(semvers = list()) //Current data has priority over old data

	// Remove admin deleted decals from the list
	collated_data -= deleted_decal_md5s

	// Flatten the resulting list
	for(var/key in collated_data)
		decal_data += list(collated_data[key])

	var/list/all_data = list("version" = DECAL_DATA_FORMAT_VERSION)
	all_data["decals"] = decal_data
	var/payload = json_encode(all_data)
	fdel(json_file)
	WRITE_FILE(json_file, payload)

///Creates a new (unmanaged) decal datum and makes the user interact with it. THis means it auto gcs when the user closes it
/datum/controller/subsystem/custom_decals/proc/new_decal(client/creator)
	var/datum/custom_decal/decal = new()
	decal.creator_ckey = creator.ckey
	decal.ui_interact(creator.mob)

/datum/controller/subsystem/custom_decals/proc/save_decal(datum/custom_decal/decal)
	decals |= decal
	save_decals()
	update_static_data_for_all_viewers()

/datum/controller/subsystem/custom_decals/proc/delete_decal(md5_deleting, client/creator, reason)
	if(!check_other_rights(creator, R_ADMIN, TRUE))
		message_admins("[key_name_admin(creator)] attempted to delete decal [md5_deleting] without admin rights")
		return
	deleted_decal_md5s += md5_deleting
	decals -= get_decal(md5_deleting)
	fdel(file("data/custom_decals/decal_[md5_deleting].png"))
	save_decals()
	var/msg = "Decal [md5_deleting] deleted by [key_name_admin(creator)] for reason: [reason]"
	log_admin(msg)
	message_admins(msg)
	update_static_data_for_all_viewers()

/**
 * Returns the decal associated with the md5 key provided.
 * set ensure_loaded to TRUE if you are using it within the game world to force the icon to be loaded
 */
/datum/controller/subsystem/custom_decals/proc/get_decal(md5)
	for(var/datum/custom_decal/decal AS in decals)
		if(decal.md5 == md5)
			return decal

/**
 * Renames decal based on md5
 * Only users who are authorss or admins may rename decals
 */
/datum/controller/subsystem/custom_decals/proc/rename_decal(md5, client/editor, new_name)
	var/datum/custom_decal/decal = SScustom_decals.get_decal(md5)
	if(!decal)
		return
	if(!check_other_rights(editor, R_ADMIN))
		if(decal.creator_ckey != editor.ckey)
			return
	var/old_name = decal.name
	decal.name = new_name
	var/msg = "[key_name_admin(editor)] has renamed decal [md5] from [old_name] to [decal.name]"
	message_admins(msg)
	log_game(msg)
	update_static_data_for_all_viewers()

/datum/controller/subsystem/custom_decals/proc/radial_poll_user_fav_decals(mob/user, atom/anchor)
	RETURN_TYPE(/datum/custom_decal)
	if(!length(user.client?.prefs.favourite_decals))
		return null
	var/list/options = list()
	var/list/decal_lookup = list()
	for(var/md5 in user.client.prefs.favourite_decals)
		var/datum/custom_decal/decal = get_decal(md5)
		if(!decal)
			user.client.prefs.favourite_decals -= md5
			continue
		options[md5] = image(decal.decal_icon)
		decal_lookup[md5] = decal
	var/result = show_radial_menu(
			user = user,
			anchor = anchor,
			choices = options,
			require_near = TRUE,
		)
	if(!result)
		return null
	return decal_lookup[result]
