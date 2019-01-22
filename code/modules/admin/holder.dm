GLOBAL_LIST_EMPTY(admin_datums)
GLOBAL_PROTECT(admin_datums)
GLOBAL_LIST_EMPTY(protected_admins)
GLOBAL_PROTECT(protected_admins)

GLOBAL_VAR_INIT(href_token, GenerateToken())
GLOBAL_PROTECT(href_token)


/datum/admins
	var/datum/admin_rank/rank

	var/target
	var/name = "nobody's admin datum (no rank)"
	var/client/owner	= null
	var/fakekey			= null

	var/datum/marked_datum

	var/spamcooldown = 0

	var/href_token

	var/deadmined


/datum/admins/New(datum/admin_rank/R, ckey, protected)
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		if(!target) //only del if this is a true creation (and not just a New() proc call), other wise trialmins/coders could abuse this to deadmin other admins
			QDEL_IN(src, 0)
			CRASH("Admin proc call creation of admin datum.")
		return
	if(!ckey)
		QDEL_IN(src, 0)
		throw EXCEPTION("Admin datum created without a ckey.")
		return
	if(!istype(R))
		QDEL_IN(src, 0)
		throw EXCEPTION("Admin datum created without a rank.")
		return
	target = ckey
	name = "[ckey]'s admin datum ([R])"
	rank = R
	href_token = GenerateToken()
	if(R.rights & R_DEBUG) //grant profile access
		world.SetConfig("APP/admin", ckey, "role=admin")
	//only admins with +ADMIN start admined
	if(protected)
		GLOB.protected_admins[target] = src

	activate()


/datum/admins/Destroy()
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return QDEL_HINT_LETMELIVE
	. = ..()


/datum/admins/proc/activate()
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return
	GLOB.deadmins -= target
	GLOB.admin_datums[target] = src
	deadmined = FALSE
	if (GLOB.directory[target])
		associate(GLOB.directory[target])	//find the client for a ckey if they are connected and associate them with us


/datum/admins/proc/deactivate()
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return
	GLOB.deadmins[target] = src
	GLOB.admin_datums -= target
	deadmined = TRUE
	var/client/C
	if ((C = owner) || (C = GLOB.directory[target]))
		disassociate()
		C.verbs += /client/proc/readmin


/datum/admins/proc/associate(client/C)
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return

	if(istype(C))
		if(C.ckey != target)
			var/msg = " has attempted to associate with [target]'s admin datum"
			message_admins("[key_name_admin(C)][msg]")
			log_admin("[key_name(C)][msg]")
			return
		if (deadmined)
			activate()
		owner = C
		owner.holder = src
		owner.add_admin_verbs()	//TODO <--- todo what? the proc clearly exists and works since its the backbone to our entire admin system
		owner.verbs -= /client/proc/readmin
		GLOB.admins |= C


/datum/admins/proc/disassociate()
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return
	if(owner)
		GLOB.admins -= owner
		owner.remove_admin_verbs()
		owner.holder = null
		owner = null


/client/proc/readmin()
	set name = "Re-Admin"
	set category = "Admin"
	set desc = "Regain your admin powers."

	var/datum/admins/A = GLOB.deadmins[ckey]

	if(!A)
		A = GLOB.admin_datums[ckey]
		if(!A)
			log_admin_private("[key_name(src)] is trying to readmin but they have no deadmin entry.")
			message_admins("[key_name_admin(src)] is trying to readmin but they have no deadmin entry.")
			return

	A.associate()

	if(!holder)//This can happen if an admin attempts to vv themself into somebody elses's deadmin datum by getting ref via brute force
		return

	message_admins("[key_name(usr)] re-adminned themselves.")
	log_admin("[ADMIN_TPMONTY(usr)] re-adminned themselves.")


/client/proc/deadmin()
	set name = "De-Admin"
	set category = "Admin"
	set desc = "Temporarily remove your admin powers."

	if(!holder)
		return

	holder.deactivate()

	log_admin("[key_name(usr)] de-adminned themselves.")
	message_admins("[ADMIN_TPMONTY(usr)] de-adminned themselves.")


/proc/GenerateToken()
	. = ""
	for(var/I in 1 to 32)
		. += "[rand(10)]"


/proc/RawHrefToken(forceGlobal = FALSE)
	var/tok = GLOB.href_token
	if(!forceGlobal && usr)
		var/client/C = usr.client
		if(!C)
			CRASH("No client for HrefToken()!")
		var/datum/admins/holder = C.holder
		if(holder)
			tok = holder.href_token
	return tok


/proc/HrefToken(forceGlobal = FALSE)
	return "admin_token=[RawHrefToken(forceGlobal)]"


/proc/HrefTokenFormField(forceGlobal = FALSE)
	return "<input type='hidden' name='admin_token' value='[RawHrefToken(forceGlobal)]'>"


/proc/check_rights(rights_required, show_msg = TRUE)
	if(!usr?.client)
		return FALSE

	if(rights_required)
		if(usr.client.holder?.rank && (usr.client.holder.rank.rights & rights_required))
			return TRUE
		else if(show_msg)
			to_chat(usr, "<span class='warning'>You do not have sufficient rights to do that. You require one of the following flags:[rights2text(rights_required," ")].</span>")
	else
		if(usr.client.holder)
			return TRUE
		else if(show_msg)
			to_chat(usr, "<span class='warning'>You are not a holder.</span>")
	return FALSE


/proc/check_other_rights(client/other, rights_required, show_msg = TRUE)
	if(!other)
		return FALSE
	if(rights_required && other.holder.rank.rights)
		if(rights_required & other.holder.rank.rights)
			return TRUE
		else if(show_msg)
			to_chat(usr, "<span class='warning'>You do not have sufficient rights to do that. You require one of the following flags:[rights2text(rights_required," ")].</span>")
	else
		if(other.holder)
			return TRUE
		else if(show_msg)
			to_chat(usr, "<span class='warning'>You are not a holder.</span>")
	return FALSE


/proc/check_if_greater_rights_than(client/other)
	if(!usr?.client)
		return FALSE
	if(usr.client.holder)
		if(!other?.holder?.rank)
			return TRUE
		if(usr.client.holder.rank.rights != other.holder.rank.rights && ((usr.client.holder.rank.rights & other.holder.rank.rights) == other.holder.rank.rights))
			return TRUE
	to_chat(usr, "<span class='warning'>Cannot proceed. They have more or equal rights than us.</span>")
	return FALSE


GLOBAL_PROTECT(admin_verbs_default)
GLOBAL_LIST_INIT(admin_verbs_default, world.AVdefault())
/world/proc/AVdefault()
	return list(
	/client/proc/deadmin,
	)
GLOBAL_PROTECT(admin_verbs_admin)
GLOBAL_LIST_INIT(admin_verbs_admin, world.AVadmin())
/world/proc/AVadmin()
	return list(
	/datum/admins/proc/admin_ghost,
	/datum/admins/proc/invisimin,
	/datum/admins/proc/stealth_mode,
	/datum/admins/proc/jobs_free,
	/datum/admins/proc/jobs_list,
	/datum/admins/proc/change_key,
	/datum/admins/proc/rejuvenate,
	/datum/admins/proc/toggle_sleep,
	/datum/admins/proc/toggle_sleep_area,
	/datum/admins/proc/change_squad,
	/datum/admins/proc/direct_control,
	/datum/admins/proc/logs_server,
	/datum/admins/proc/logs_current,
	/datum/admins/proc/logs_folder,
	/datum/admins/proc/jump_area,
	/datum/admins/proc/jump_turf,
	/datum/admins/proc/jump_coord,
	/datum/admins/proc/jump_mob,
	/datum/admins/proc/jump_key,
	/datum/admins/proc/get_mob,
	/datum/admins/proc/get_key,
	/datum/admins/proc/send_mob,
	/client/proc/cmd_admin_pm_panel, //REWORK THIS ONE
)
GLOBAL_PROTECT(admin_verbs_ban)
GLOBAL_LIST_INIT(admin_verbs_ban, world.AVban())
/world/proc/AVban()
	return list(

	)
GLOBAL_PROTECT(admin_verbs_asay)
GLOBAL_LIST_INIT(admin_verbs_asay, world.AVasay())
/world/proc/AVasay()
	return list(
	/datum/admins/proc/asay
	)
GLOBAL_PROTECT(admin_verbs_fun)
GLOBAL_LIST_INIT(admin_verbs_fun, world.AVfun())
/world/proc/AVfun()
	return list(

	)
GLOBAL_PROTECT(admin_verbs_spawn)
GLOBAL_LIST_INIT(admin_verbs_spawn, world.AVspawn())
/world/proc/AVspawn()
	return list(
	)

GLOBAL_PROTECT(admin_verbs_sound)
GLOBAL_LIST_INIT(admin_verbs_sound, world.AVsound())
/world/proc/AVsound()
	return list(
	)
GLOBAL_PROTECT(admin_verbs_server)
GLOBAL_LIST_INIT(admin_verbs_server, world.AVserver())
/world/proc/AVserver()
	return list(

	)
GLOBAL_PROTECT(admin_verbs_debug)
GLOBAL_LIST_INIT(admin_verbs_debug, world.AVdebug())
/world/proc/AVdebug()
	return list(

	)
GLOBAL_PROTECT(admin_verbs_permissions)
GLOBAL_LIST_INIT(admin_verbs_permissions, world.AVpermissions())
/world/proc/AVpermissions()
	return list(

	)
GLOBAL_PROTECT(admin_verbs_color)
GLOBAL_LIST_INIT(admin_verbs_color, world.AVcolor())
/world/proc/AVcolor()
	return list(

	)
GLOBAL_PROTECT(admin_verbs_mentor)
GLOBAL_LIST_INIT(admin_verbs_mentor, world.AVmentor())
/world/proc/AVmentor()
	return list(
	/datum/admins/proc/msay,
	/datum/admins/proc/dsay
)


/client/proc/add_admin_verbs()
	if(holder)
		var/rights = holder.rank.rights
		verbs += GLOB.admin_verbs_default
		if(rights & R_ADMIN)
			verbs += GLOB.admin_verbs_admin
		if(rights & R_MENTOR)
			verbs += GLOB.admin_verbs_mentor
		if(rights & R_BAN)
			verbs += GLOB.admin_verbs_ban
		if(rights & R_ASAY)
			verbs += GLOB.admin_verbs_asay
		if(rights & R_FUN)
			verbs += GLOB.admin_verbs_fun
		if(rights & R_SERVER)
			verbs += GLOB.admin_verbs_server
		if(rights & R_DEBUG)
			verbs += GLOB.admin_verbs_debug
		if(rights & R_PERMISSIONS)
			verbs += GLOB.admin_verbs_permissions
		if(rights & R_SOUND)
			verbs += GLOB.admin_verbs_sound
		if(rights & R_SPAWN)
			verbs += GLOB.admin_verbs_spawn


/client/proc/remove_admin_verbs()
	verbs.Remove(
		GLOB.admin_verbs_default,
		GLOB.admin_verbs_admin,
		GLOB.admin_verbs_mentor,
		GLOB.admin_verbs_ban,
		GLOB.admin_verbs_asay,
		GLOB.admin_verbs_fun,
		GLOB.admin_verbs_server,
		GLOB.admin_verbs_debug,
		GLOB.admin_verbs_permissions,
		GLOB.admin_verbs_sound,
		GLOB.admin_verbs_spawn,
		)


/proc/is_mentor(client/C)
	if(!istype(C))
		return FALSE
	if(!C?.holder?.rank?.rights)
		return FALSE
	if(C.holder.rank.rights & R_ADMIN)
		return FALSE
	if(!(C.holder.rank.rights & R_MENTOR))
		return FALSE
	return TRUE


/proc/message_admins(var/msg)
	log_admin_private_asay(msg)
	msg = "<span class='admin'><span class='prefix'>ADMIN LOG:</span> <span class='message'>[msg]</span></span>"
	for(var/client/C in admins)
		if(check_other_rights(C, R_ADMIN))
			to_chat(C, msg)


/proc/message_staff(var/msg)
	log_admin_private_msay(msg)
	msg = "<span class='admin prefix'><span class=''prefix'>STAFF LOG:</span> <span class='message'>[msg]</span></span>"
	for(var/client/C in admins)
		if(C.holder)
			to_chat(C, msg)


/proc/msg_admin_attack(var/msg)
	msg = "<span class='admin'><span class='prefix'>ATTACK:</span> <span class='message'>[msg]</span></span>"
	for(var/client/C in admins)
		if(!check_other_rights(C, R_ADMIN))
			continue
		if((C.prefs.toggles_chat & CHAT_ATTACKLOGS) || ((ticker.current_state == GAME_STATE_FINISHED) && (C.prefs.toggles_chat & CHAT_ENDROUNDLOGS)))
			to_chat(C, msg)


/proc/msg_admin_ff(var/msg)
	msg = "<span class='admin'><span class='prefix'>ATTACK:</span> <span class='green'>[msg]</span></span>"
	for(var/client/C in admins)
		if(!check_other_rights(C, R_ADMIN))
			continue
		if((C.prefs.toggles_chat & CHAT_FFATTACKLOGS) || ((ticker.current_state == GAME_STATE_FINISHED) && (C.prefs.toggles_chat & CHAT_ENDROUNDLOGS)))
			to_chat(C, msg)


/client/proc/find_stealth_key(txt)
	if(txt)
		for(var/P in GLOB.stealthminID)
			if(GLOB.stealthminID[P] == txt)
				return P
	txt = GLOB.stealthminID[ckey]
	return txt


/proc/WrapAdminProcCall(datum/target, procname, list/arguments)
	if(target && procname == "Del")
		to_chat(usr, "Calling Del() is not allowed")
		return

	if(target != GLOBAL_PROC && !target.CanProcCall(procname))
		to_chat(usr, "Proccall on [target.type]/proc/[procname] is disallowed!")
		return
	var/current_caller = GLOB.AdminProcCaller
	var/ckey = usr ? usr.client.ckey : GLOB.AdminProcCaller
	if(!ckey)
		CRASH("WrapAdminProcCall with no ckey: [target] [procname] [english_list(arguments)]")
	if(current_caller && current_caller != ckey)
		if(!GLOB.AdminProcCallSpamPrevention[ckey])
			to_chat(usr, "<span class='adminnotice'>Another set of admin called procs are still running, your proc will be run after theirs finish.</span>")
			GLOB.AdminProcCallSpamPrevention[ckey] = TRUE
			UNTIL(!GLOB.AdminProcCaller)
			to_chat(usr, "<span class='adminnotice'>Running your proc</span>")
			GLOB.AdminProcCallSpamPrevention -= ckey
		else
			UNTIL(!GLOB.AdminProcCaller)
	GLOB.LastAdminCalledProc = procname
	if(target != GLOBAL_PROC)
		GLOB.LastAdminCalledTargetRef = "[REF(target)]"
	GLOB.AdminProcCaller = ckey	//if this runtimes, too bad for you
	++GLOB.AdminProcCallCount
	. = world.WrapAdminProcCall(target, procname, arguments)
	if(--GLOB.AdminProcCallCount == 0)
		GLOB.AdminProcCaller = null


/world/proc/WrapAdminProcCall(datum/target, procname, list/arguments)
	if(target == GLOBAL_PROC)
		return call(procname)(arglist(arguments))
	else if(target != world)
		return call(target, procname)(arglist(arguments))
	else
		log_admin_private("[key_name(usr)] attempted to call world/proc/[procname] with arguments: [english_list(arguments)]")


/proc/IsAdminAdvancedProcCall()
	return usr && usr.client && GLOB.AdminProcCaller == usr.client.ckey