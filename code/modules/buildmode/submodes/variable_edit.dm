/datum/buildmode_mode/varedit
	key = "edit"

	/// The name of the variable to modifiy
	var/var_name = null
	/// The value to modify to
	var/var_value = null

/datum/buildmode_mode/varedit/Destroy()
	var_name = null
	var_value = null
	return ..()

/datum/buildmode_mode/varedit/show_help(client/user)
	to_chat(user, custom_boxed_message("purple_box",\
		"[span_bold("Select var(type) & value")] -> Right Mouse Button on buildmode button\n\
		[span_bold("Set var(type) & value")] -> Left Mouse Button on turf/obj/mob\n\
		[span_bold("Reset var's value")] -> Right Mouse Button on turf/obj/mob"))

/datum/buildmode_mode/varedit/change_settings(client/user)
	var_name = input(user, "Enter variable name:" ,"Name", "name")

	if(!vv_varname_lockcheck(var_name))
		return

	var/temp_value = user.vv_get_value()
	if(isnull(temp_value["class"]))
		var_name = null
		var_value = null
		to_chat(user, span_notice("Variable unset."))
		return
	var_value = temp_value["value"]

/datum/buildmode_mode/varedit/handle_click(client/user, params, obj/object)
	var/list/modifiers = params2list(params)

	if(isnull(var_name))
		to_chat(user, span_warning("Choose a variable to modify first."))
		return

	if(LAZYACCESS(modifiers, LEFT_CLICK))
		if(!object.vars.Find(var_name))
			to_chat(user, span_warning("[initial(object.name)] does not have a var called '[var_name]'"))
			return
		if(object.vv_edit_var(var_name, var_value) == FALSE)
			to_chat(user, span_warning("Your edit was rejected by the object."))
			return
		log_admin("Build Mode: [key_name(user)] modified [object.name]'s [var_name] to [var_value]")

	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		if(!object.vars.Find(var_name))
			to_chat(user, span_warning("[initial(object.name)] does not have a var called '[var_name]'"))
			return
		var/reset_value = initial(object.vars[var_name])
		if(object.vv_edit_var(var_name, reset_value) == FALSE)
			to_chat(user, span_warning("Your edit was rejected by the object."))
			return
		log_admin("Build Mode: [key_name(user)] modified [object.name]'s [var_name] to [reset_value]")
