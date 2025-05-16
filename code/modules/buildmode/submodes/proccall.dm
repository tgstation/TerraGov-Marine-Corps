/datum/buildmode_mode/proccall
	key = "proccall"
	///The procedure itself, which we will call in the future. For example "qdel"
	var/proc_name
	///The list of arguments for the proc.
	var/list/proc_args

/datum/buildmode_mode/proccall/show_help(client/user)
	to_chat(user, custom_boxed_message("purple_box",\
		"[span_bold("Choose procedure and arguments")] -> Right Mouse Button on buildmode button\n\
		[span_bold("Apply procedure on object")] -> Left Mouse Button on machinery"))

/datum/buildmode_mode/proccall/change_settings(client/user)
	if(!check_rights_for(user, R_DEBUG))
		return

	proc_name = input("Proc name, eg: fake_blood", "Proc:", null) as text|null
	if(!proc_name)
		return

	proc_args = user.get_callproc_args()

/datum/buildmode_mode/proccall/handle_click(client/user, params, datum/object)
	if(!proc_name || !proc_args)
		tgui_alert(user, "Undefined ProcCall or arguments.")
		return

	if(!hascall(object, proc_name))
		to_chat(user, span_warning("Error: callproc_datum(): type [object.type] has no proc named [proc_name]."), confidential = TRUE)
		return

	if(!is_valid_src(object))
		to_chat(user, span_warning("Error: callproc_datum(): owner of proc no longer exists."), confidential = TRUE)
		return


	var/msg = "[key_name(user)] called [object]'s [proc_name]() with [proc_args.len ? "the arguments [list2params(proc_args)]" : "no arguments"]."
	log_admin(msg)
	message_admins(msg)
	admin_ticket_log(object, msg)
	BLACKBOX_LOG_ADMIN_VERB("Atom ProcCall")

	var/returnval = user.get_callproc_returnval(WrapAdminProcCall(object, proc_name, proc_args), proc_name)
	if(returnval)
		to_chat(user, returnval, confidential = TRUE)
