GLOBAL_DATUM_INIT(AdminProcCallHandler, /mob/proccall_handler, new())
GLOBAL_PROTECT(AdminProcCallHandler)

/// Used to handle proccalls called indirectly by an admin (e.g. tgs, circuits).
/// Has to be a mob because IsAdminAdvancedProcCall() checks usr, which is a mob variable.
/// So usr is set to this for any proccalls that don't have any usr mob/client to refer to.
/mob/proccall_handler
	name = "ProcCall Handler"
	desc = "If you are seeing this, tell a coder."

	var/list/callers = list()

	invisibility = INVISIBILITY_ABSTRACT
	density = FALSE

/// Adds a caller.
/mob/proccall_handler/proc/add_caller(caller_name)
	callers += caller_name
	name = "[initial(name)] ([callers.Join(") (")])"

/// Removes a caller.
/mob/proccall_handler/proc/remove_caller(caller_name)
	callers -= caller_name
	name = "[initial(name)] ([callers.Join(") (")])"

/mob/proccall_handler/Initialize(mapload)
	. = ..()
	if(GLOB.AdminProcCallHandler && GLOB.AdminProcCallHandler != src)
		return INITIALIZE_HINT_QDEL
	GLOB.AdminProcCallHandler = src

/mob/proccall_handler/vv_edit_var(var_name, var_value)
	if(GLOB.AdminProcCallHandler != src)
		return ..()
	return FALSE

/mob/proccall_handler/CanProcCall(procname)
	if(GLOB.AdminProcCallHandler != src)
		return ..()
	return FALSE

// Shit will break if this is allowed to be deleted
/mob/proccall_handler/Destroy(force)
	if(GLOB.AdminProcCallHandler != src)
		return ..()
	if(!force)
		stack_trace("Attempted deletion on [type] - [name], aborting.")
		return QDEL_HINT_LETMELIVE
	return ..()

/**
 * Handles a userless proccall, used by circuits.
 *
 * Arguments:
 * * user - a string used to identify the user
 * * target - the target to proccall on
 * * proc - the proc to call
 * * arguments - any arguments
 */
/proc/HandleUserlessProcCall(user, datum/target, procname, list/arguments)
	if(IsAdminAdvancedProcCall())
		return
	var/mob/proccall_handler/handler = GLOB.AdminProcCallHandler
	handler.add_caller(user)
	var/lastusr = usr
	usr = handler
	. = WrapAdminProcCall(target, procname, arguments)
	usr = lastusr
	handler.remove_caller(user)

/**
 * Handles a userless sdql, used by circuits and tgs.
 *
 * Arguments:
 * * user - a string used to identify the user
 * * query_text - the query text
 */
/proc/HandleUserlessSDQL(user, query_text)
	if(IsAdminAdvancedProcCall())
		return
	var/mob/proccall_handler/handler = GLOB.AdminProcCallHandler
	handler.add_caller(user)
	var/lastusr = usr
	usr = handler
	. = world.SDQL2_query(query_text, user, user)
	usr = lastusr
	handler.remove_caller(user)

GLOBAL_VAR(AdminProcCaller)
GLOBAL_PROTECT(AdminProcCaller)
GLOBAL_VAR_INIT(AdminProcCallCount, FALSE)
GLOBAL_PROTECT(AdminProcCallCount)
GLOBAL_VAR(LastAdminCalledTargetRef)
GLOBAL_PROTECT(LastAdminCalledTargetRef)
GLOBAL_VAR(LastAdminCalledTarget)
GLOBAL_PROTECT(LastAdminCalledTarget)
GLOBAL_VAR(LastAdminCalledProc)
GLOBAL_PROTECT(LastAdminCalledProc)
GLOBAL_LIST_EMPTY(AdminProcCallSpamPrevention)
GLOBAL_PROTECT(AdminProcCallSpamPrevention)


/datum/admins/proc/proccall_atom(datum/A as null|area|mob|obj|turf)
	set category = null
	set name = "Atom ProcCall"
	set waitfor = FALSE

	if(!check_rights(R_DEBUG))
		return

	/// Holds a reference to the client incase something happens to them
	var/client/starting_client = usr.client

	var/procname = input("Proc name, eg: attack_hand", "Proc:", null) as text|null
	if(!procname)
		return

	if(!hascall(A, procname))
		to_chat(starting_client, "<font color='red'>Error: callproc_datum(): type [A.type] has no proc named [procname].</font>")
		return

	var/list/lst = starting_client.holder.get_callproc_args()
	if(!lst)
		return

	if(!A || !IsValidSrc(A))
		to_chat(starting_client, span_warning("Error: callproc_datum(): owner of proc no longer exists."))
		return

	log_admin("[key_name(usr)] called [A]'s [procname]() with [length(lst) ? "the arguments [list2params(lst)]" : "no arguments"].")
	message_admins("[ADMIN_TPMONTY(usr)] called [A]'s [procname]() with [length(lst) ? "the arguments [list2params(lst)]" : "no arguments"].")
	admin_ticket_log(A, "[key_name_admin(usr)] called [A]'s [procname]() with [length(lst) ? "the arguments [list2params(lst)]" : "no arguments"].")

	var/returnval = WrapAdminProcCall(A, procname, lst) // Pass the lst as an argument list to the proc
	. = starting_client.holder.get_callproc_returnval(returnval, procname)
	if(.)
		to_chat(usr, .)


/datum/admins/proc/proccall_advanced()
	set category = "Debug"
	set name = "Advanced ProcCall"
	set waitfor = FALSE

	if(!check_rights(R_DEBUG))
		return

	var/datum/target = null
	var/targetselected = 0
	var/returnval = null

	switch(alert("Proc owned by something?",, "Yes", "No"))
		if("Yes")
			targetselected = TRUE
			var/list/value = usr.client.vv_get_value(default_class = VV_ATOM_REFERENCE, classes = list(VV_ATOM_REFERENCE, VV_DATUM_REFERENCE, VV_MOB_REFERENCE, VV_CLIENT))
			if(!value["class"] || !value["value"])
				return
			target = value["value"]
		if("No")
			target = null
			targetselected = FALSE

	var/procname = input("Proc path, eg: /proc/attack_hand(mob/living/user)")
	if(!procname)
		return

	//strip away everything but the proc name
	var/list/proclist = splittext(procname, "/")
	if(!length(proclist))
		return

	procname = proclist[length(proclist)]

	var/proctype = "proc"
	if("verb" in proclist)
		proctype = "verb"


	var/procpath
	if(targetselected && !hascall(target, procname))
		to_chat(usr,
			type = MESSAGE_TYPE_DEBUG,
			html = "<font color='red'>Error: callproc(): type [target.type] has no [proctype] named [procname].</font>",)
		return
	else if(!targetselected)
		procpath = text2path("/[proctype]/[procname]")
		if(!procpath)
			to_chat(usr,
				type = MESSAGE_TYPE_DEBUG,
				html = "<font color='red'>Error: callproc(): proc [procname] does not exist. (Did you forget the /proc/ part?)</font>")
			return

	var/list/lst = usr.client.holder.get_callproc_args()
	if(!lst)
		return

	if(targetselected)
		if(!target)
			to_chat(usr,
				type = MESSAGE_TYPE_DEBUG,
				html = "<font color='red'>Error: callproc(): owner of proc no longer exists.</font>")
			return
		log_admin("[key_name(usr)] called [target]'s [procname]() with [length(lst) ? "the arguments [list2params(lst)]" : "no arguments"].")
		message_admins("[ADMIN_TPMONTY(usr)] called [target]'s [procname]() with [length(lst) ? "the arguments [list2params(lst)]" : "no arguments"].")
		admin_ticket_log(target, "[key_name(usr)] called [target]'s [procname]() with [length(lst) ? "the arguments [list2params(lst)]" : "no arguments"].")
		returnval = WrapAdminProcCall(target, procname, lst) // Pass the lst as an argument list to the proc
	else
		//this currently has no hascall protection. wasn't able to get it working.
		log_admin("[key_name(usr)] called [procname]() with [length(lst) ? "the arguments [list2params(lst)]" : "no arguments"].")
		message_admins("[ADMIN_TPMONTY(usr)] called [procname]() with [length(lst) ? "the arguments [list2params(lst)]" : "no arguments"].")
		returnval = WrapAdminProcCall(GLOBAL_PROC, procpath, lst) // Pass the lst as an argument list to the proc

	. = usr.client.holder.get_callproc_returnval(returnval, procname)
	if(.)
		to_chat(usr, .)


/datum/admins/proc/get_callproc_returnval(returnval, procname)
	. = ""
	if(islist(returnval))
		var/list/returnedlist = returnval
		. = "<span class='notice'>"
		if(length(returnedlist))
			var/assoc_check = returnedlist[1]
			if(istext(assoc_check) && (returnedlist[assoc_check] != null))
				. += "[procname] returned an associative list:"
				for(var/key in returnedlist)
					. += "\n[key] = [returnedlist[key]]"

			else
				. += "[procname] returned a list:"
				for(var/elem in returnedlist)
					. += "\n[elem]"
		else
			. = "[procname] returned an empty list"
		. += "</font>"

	else
		. = "<span class='notice'>[procname] returned: [!isnull(returnval) ? returnval : "null"]</font>"


/datum/admins/proc/get_callproc_args()
	var/argnum = input("Number of arguments", "Number:", 0) as num|null
	if(isnull(argnum))
		return

	. = list()
	var/list/named_args = list()
	while(argnum--)
		var/named_arg = input("Leave blank for positional argument. Positional arguments will be considered as if they were added first.", "Named argument") as text|null
		var/value = usr.client.vv_get_value(restricted_classes = list(VV_RESTORE_DEFAULT))
		if (!value["class"])
			return
		if(named_arg)
			named_args[named_arg] = value["value"]
		else
			. += value["value"]
	if(LAZYLEN(named_args))
		. += named_args

/proc/WrapAdminProcCall(datum/target, procname, list/arguments)
	if(target && procname == "Del")
		to_chat(usr, "Calling Del() is not allowed")
		return

	if(target != GLOBAL_PROC && !target.CanProcCall(procname))
		to_chat(usr, "Proccall on [target.type]/proc/[procname] is disallowed!")
		return
	var/current_caller = GLOB.AdminProcCaller
	var/user_identifier = usr ? usr.client?.ckey : GLOB.AdminProcCaller
	var/is_remote_handler = usr == GLOB.AdminProcCallHandler
	if(is_remote_handler)
		user_identifier = GLOB.AdminProcCallHandler.name

	if(!user_identifier)
		CRASH("WrapAdminProcCall with no ckey: [target] [procname] [english_list(arguments)]")

	if(!is_remote_handler && current_caller && current_caller != user_identifier)
		to_chat(usr, span_adminnotice("Another set of admin called procs are still running. Try again later."))
		return

	GLOB.LastAdminCalledProc = procname
	if(target != GLOBAL_PROC)
		GLOB.LastAdminCalledTargetRef = REF(target)

	if(!is_remote_handler)
		GLOB.AdminProcCaller = user_identifier //if this runtimes, too bad for you
		++GLOB.AdminProcCallCount
		. = world.WrapAdminProcCall(target, procname, arguments)
		GLOB.AdminProcCallCount--
		if(GLOB.AdminProcCallCount == 0)
			GLOB.AdminProcCaller = null
	else
		. = world.WrapAdminProcCall(target, procname, arguments)


/world/proc/WrapAdminProcCall(datum/target, procname, list/arguments)
	if(target == GLOBAL_PROC)
		return call(procname)(arglist(arguments))
	else if(target != world)
		return call(target, procname)(arglist(arguments))
	else
		log_admin_private("[key_name(usr)] attempted to call world/proc/[procname] with arguments: [english_list(arguments)]")


/proc/IsAdminAdvancedProcCall()
#ifdef TESTING
	return FALSE
#else
	return (GLOB.AdminProcCaller && GLOB.AdminProcCaller == usr?.client?.ckey) || (GLOB.AdminProcCallHandler && usr == GLOB.AdminProcCallHandler)
#endif
