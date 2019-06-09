/datum/admins
	var/datum/admin_rank/rank

	var/target
	var/name = "nobody's admin datum (no rank)"
	var/client/owner	= null
	var/fakekey			= null

	var/datum/marked_datum
	var/marked_file

	var/href_token

	var/deadmined


/datum/admins/New(datum/admin_rank/R, ckey, protected)
	if(IsAdminAdvancedProcCall())
		log_admin("[key_name(usr)] has tried to elevate permissions!")
		message_admins("[ADMIN_TPMONTY(usr)] has tried to elevate permissions!")
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
		log_admin("[key_name(usr)] has tried to elevate permissions!")
		message_admins("[ADMIN_TPMONTY(usr)] has tried to elevate permissions!")
		return QDEL_HINT_LETMELIVE
	return ..()


/datum/admins/proc/activate()
	if(IsAdminAdvancedProcCall())
		log_admin("[key_name(usr)] has tried to elevate permissions!")
		message_admins("[ADMIN_TPMONTY(usr)] has tried to elevate permissions!")
		return
	GLOB.deadmins -= target
	GLOB.admin_datums[target] = src
	deadmined = FALSE
	if(GLOB.directory[target])
		associate(GLOB.directory[target])	//find the client for a ckey if they are connected and associate them with us


/datum/admins/proc/deactivate()
	if(IsAdminAdvancedProcCall())
		log_admin("[key_name(usr)] has tried to elevate permissions!")
		message_admins("[ADMIN_TPMONTY(usr)] has tried to elevate permissions!")
		return
	GLOB.deadmins[target] = src
	GLOB.admin_datums -= target
	deadmined = TRUE
	var/client/C
	if((C = owner) || (C = GLOB.directory[target]))
		disassociate()
		C.verbs += /client/proc/readmin


/datum/admins/proc/associate(client/C)
	if(IsAdminAdvancedProcCall())
		log_admin("[key_name(usr)] has tried to elevate permissions!")
		message_admins("[ADMIN_TPMONTY(usr)] has tried to elevate permissions!")
		return

	if(!istype(C))
		return

	if(C.ckey != target)
		log_admin("[key_name(C)] has attempted to associate with [target]'s admin datum.")
		message_admins("[ADMIN_TPMONTY(C.mob)]has attempted to associate with [target]'s admin datum.")
		return
	if(deadmined)
		activate()
	owner = C
	owner.holder = src
	owner.add_admin_verbs()
	owner.verbs -= /client/proc/readmin
	GLOB.admins |= C


/datum/admins/proc/disassociate()
	if(IsAdminAdvancedProcCall())
		log_admin("[key_name(usr)] has tried to elevate permissions!")
		message_admins("[ADMIN_TPMONTY(usr)] has tried to elevate permissions!")
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
			log_admin_private("[key_name(src)] is trying to re-admin but they have no de-admin entry.")
			message_admins("[ADMIN_TPMONTY(usr)]is trying to re-admin but they have no de-admin entry.")
			return

	A.associate(src)

	if(!holder)//This can happen if an admin attempts to vv themself into somebody elses's deadmin datum by getting ref via brute force
		return

	log_admin("[key_name(usr)] re-adminned themselves.")
	message_admins("[ADMIN_TPMONTY(usr)] re-adminned themselves.")


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
	if(rights_required && other.holder?.rank?.rights)
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
		if(usr.client.holder.rank.rights == R_EVERYTHING)
			return TRUE
		if(usr.client == other)
			return TRUE
		if(usr.client.holder.rank.rights != other.holder.rank.rights && ((usr.client.holder.rank.rights & other.holder.rank.rights) == other.holder.rank.rights))
			return TRUE
	to_chat(usr, "<span class='warning'>They have more or equal rights than you.</span>")
	return FALSE


/datum/admins/proc/check_if_greater_rights_than_holder(datum/admins/other)
	if(!istype(other))
		return TRUE
	if(rank.rights == R_EVERYTHING)
		return TRUE
	if(src == other)
		return TRUE
	if(rank.rights != other.rank.rights)
		if((rank.rights & other.rank.rights) == other.rank.rights)
			return TRUE
	return FALSE


/world/proc/AVdefault()
	return list(
	/client/proc/deadmin
	)
GLOBAL_LIST_INIT(admin_verbs_default, world.AVdefault())
GLOBAL_PROTECT(admin_verbs_default)

/world/proc/AVadmin()
	return list(
	/datum/admins/proc/show_player_panel,
	/datum/admins/proc/pref_attack_logs,
	/datum/admins/proc/pref_ff_attack_logs,
	/datum/admins/proc/pref_end_attack_logs,
	/datum/admins/proc/pref_debug_logs,
	/datum/admins/proc/set_ooc_color_self,
	/datum/admins/proc/admin_ghost,
	/datum/admins/proc/invisimin,
	/datum/admins/proc/stealth_mode,
	/datum/admins/proc/give_mob,
	/datum/admins/proc/give_mob_panel,
	/datum/admins/proc/rejuvenate,
	/datum/admins/proc/rejuvenate_panel,
	/datum/admins/proc/toggle_sleep,
	/datum/admins/proc/toggle_sleep_panel,
	/datum/admins/proc/toggle_sleep_area,
	/datum/admins/proc/direct_control,
	/datum/admins/proc/logs_server,
	/datum/admins/proc/logs_current,
	/datum/admins/proc/logs_folder,
	/datum/admins/proc/jump,
	/datum/admins/proc/get_mob,
	/datum/admins/proc/send_mob,
	/datum/admins/proc/jump_area,
	/datum/admins/proc/jump_turf,
	/datum/admins/proc/jump_coord,
	/datum/admins/proc/jump_mob,
	/datum/admins/proc/jump_key,
	/datum/admins/proc/player_panel,
	/datum/admins/proc/player_panel_extended,
	/datum/admins/proc/secrets_panel,
	/datum/admins/proc/remove_from_tank,
	/datum/admins/proc/game_panel,
	/datum/admins/proc/log_panel,
	/datum/admins/proc/mode_panel,
	/datum/admins/proc/job_slots,
	/datum/admins/proc/toggle_adminhelp_sound,
	/datum/admins/proc/toggle_prayers,
	/datum/admins/proc/mcdb,
	/datum/admins/proc/check_fingerprints,
	/client/proc/private_message_panel,
	/client/proc/private_message_context,
	/client/proc/msay,
	/client/proc/dsay
	)
GLOBAL_LIST_INIT(admin_verbs_admin, world.AVadmin())
GLOBAL_PROTECT(admin_verbs_admin)

/world/proc/AVmentor()
	return list(
	/datum/admins/proc/admin_ghost,
	/datum/admins/proc/subtle_message,
	/datum/admins/proc/subtle_message_panel,
	/datum/admins/proc/view_faxes,
	/datum/admins/proc/toggle_adminhelp_sound,
	/datum/admins/proc/toggle_prayers,
	/datum/admins/proc/imaginary_friend,
	/client/proc/private_message_panel,
	/client/proc/private_message_context,
	/client/proc/msay,
	/client/proc/dsay
	)
GLOBAL_LIST_INIT(admin_verbs_mentor, world.AVmentor())
GLOBAL_PROTECT(admin_verbs_mentor)

/world/proc/AVban()
	return list(
	/datum/admins/proc/ban_panel,
	/datum/admins/proc/sticky_ban_panel,
	/datum/admins/proc/unban_panel,
	/datum/admins/proc/note_panel
	)
GLOBAL_LIST_INIT(admin_verbs_ban, world.AVban())
GLOBAL_PROTECT(admin_verbs_ban)

/world/proc/AVasay()
	return list(
	/client/proc/asay
	)
GLOBAL_LIST_INIT(admin_verbs_asay, world.AVasay())
GLOBAL_PROTECT(admin_verbs_asay)

/world/proc/AVdebug()
	return list(
	/datum/admins/proc/proccall_advanced,
	/datum/admins/proc/proccall_atom,
	/datum/admins/proc/delete_all,
	/datum/admins/proc/generate_powernets,
	/datum/admins/proc/debug_mob_lists,
	/datum/admins/proc/delete_atom,
	/datum/admins/proc/restart_controller,
	/datum/admins/proc/check_contents,
	/datum/admins/proc/SDQL2_query,
	/datum/admins/proc/map_template_load,
	/datum/admins/proc/map_template_upload,
	/datum/admins/proc/reestablish_db_connection,
	/datum/admins/proc/view_runtimes
	)
GLOBAL_LIST_INIT(admin_verbs_debug, world.AVdebug())
GLOBAL_PROTECT(admin_verbs_debug)

/world/proc/AVvaredit()
	return list(
	/client/proc/debug_variables
	)
GLOBAL_LIST_INIT(admin_verbs_varedit, world.AVvaredit())
GLOBAL_PROTECT(admin_verbs_varedit)

/world/proc/AVfun()
	return list(
	/datum/admins/proc/rank_and_equipment,
	/datum/admins/proc/set_view_range,
	/datum/admins/proc/emp,
	/datum/admins/proc/queen_report,
	/datum/admins/proc/hive_status,
	/datum/admins/proc/ai_report,
	/datum/admins/proc/command_report,
	/datum/admins/proc/narrate_global,
	/datum/admins/proc/narage_direct,
	/datum/admins/proc/subtle_message,
	/datum/admins/proc/subtle_message_panel,
	/datum/admins/proc/award_medal,
	/datum/admins/proc/custom_info,
	/datum/admins/proc/announce,
	/datum/admins/proc/force_distress,
	/datum/admins/proc/force_dropship,
	/datum/admins/proc/object_sound,
	/datum/admins/proc/drop_bomb,
	/datum/admins/proc/change_security_level,
	/datum/admins/proc/edit_appearance,
	/datum/admins/proc/create_outfit,
	/datum/admins/proc/offer,
	/datum/admins/proc/change_hivenumber,
	/datum/admins/proc/view_faxes,
	/datum/admins/proc/possess,
	/datum/admins/proc/release,
	/datum/admins/proc/launch_pod,
	/client/proc/toggle_buildmode
	)
GLOBAL_LIST_INIT(admin_verbs_fun, world.AVfun())
GLOBAL_PROTECT(admin_verbs_fun)

/world/proc/AVserver()
	return list(
	/datum/admins/proc/restart,
	/datum/admins/proc/shutdown_server,
	/datum/admins/proc/toggle_ooc,
	/datum/admins/proc/toggle_looc,
	/datum/admins/proc/toggle_deadchat,
	/datum/admins/proc/toggle_deadooc,
	/datum/admins/proc/start,
	/datum/admins/proc/toggle_join,
	/datum/admins/proc/toggle_respawn,
	/datum/admins/proc/set_respawn_time,
	/datum/admins/proc/end_round,
	/datum/admins/proc/delay_start,
	/datum/admins/proc/delay_end,
	/datum/admins/proc/toggle_gun_restrictions,
	/datum/admins/proc/toggle_synthetic_restrictions,
	/datum/admins/proc/reload_admins,
	/datum/admins/proc/map_change
	)
GLOBAL_LIST_INIT(admin_verbs_server, world.AVserver())
GLOBAL_PROTECT(admin_verbs_server)

/world/proc/AVpermissions()
	return list(
	/datum/admins/proc/permissions_panel,
	/datum/admins/proc/create_poll
	)
GLOBAL_LIST_INIT(admin_verbs_permissions, world.AVpermissions())
GLOBAL_PROTECT(admin_verbs_permissions)

/world/proc/AVcolor()
	return list(

	)
GLOBAL_LIST_INIT(admin_verbs_color, world.AVcolor())
GLOBAL_PROTECT(admin_verbs_color)

/world/proc/AVsound()
	return list(
	/datum/admins/proc/sound_file,
	/datum/admins/proc/sound_web,
	/datum/admins/proc/sound_stop,
	/datum/admins/proc/music_stop
	)
GLOBAL_LIST_INIT(admin_verbs_sound, world.AVsound())
GLOBAL_PROTECT(admin_verbs_sound)

/world/proc/AVspawn()
	return list(
	/datum/admins/proc/spawn_atom
	)
GLOBAL_LIST_INIT(admin_verbs_spawn, world.AVspawn())
GLOBAL_PROTECT(admin_verbs_spawn)

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
		if(rights & R_DBRANKS)
			verbs += GLOB.admin_verbs_permissions
		if(rights & R_SOUND)
			verbs += GLOB.admin_verbs_sound
		if(rights & R_COLOR)
			verbs += GLOB.admin_verbs_color
		if(rights & R_VAREDIT)
			verbs += GLOB.admin_verbs_varedit
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
		GLOB.admin_verbs_color,
		GLOB.admin_verbs_varedit,
		GLOB.admin_verbs_spawn
		)


/proc/is_mentor(client/C)
	if(!istype(C))
		return FALSE
	if(!C?.holder?.rank?.rights)
		return FALSE
	if(check_other_rights(C, R_ADMINTICKET, FALSE))
		return FALSE
	if(!check_other_rights(C, R_MENTOR, FALSE))
		return FALSE
	return TRUE


/proc/message_admins(var/msg)
	msg = "<span class='admin'><span class='prefix'>ADMIN LOG:</span> <span class='message'>[msg]</span></span>"
	for(var/client/C in GLOB.admins)
		if(check_other_rights(C, R_ADMIN, FALSE))
			to_chat(C, msg)


/proc/message_staff(var/msg)
	msg = "<span class='admin'><span class='prefix'>STAFF LOG:</span> <span class='message'>[msg]</span></span>"
	for(var/client/C in GLOB.admins)
		if(check_other_rights(C, R_ADMIN, FALSE) || is_mentor(C))
			to_chat(C, msg)


/proc/msg_admin_attack(var/msg)
	msg = "<span class='admin'><span class='prefix'>ATTACK:</span> <span class='message'>[msg]</span></span>"
	for(var/client/C in GLOB.admins)
		if(!check_other_rights(C, R_ADMIN, FALSE))
			continue
		if((C.prefs.toggles_chat & CHAT_ATTACKLOGS) || ((SSticker.current_state == GAME_STATE_FINISHED) && (C.prefs.toggles_chat & CHAT_ENDROUNDLOGS)))
			to_chat(C, msg)


/proc/msg_admin_ff(var/msg)
	msg = "<span class='admin'><span class='prefix'>ATTACK:</span> <span class='green'>[msg]</span></span>"
	for(var/client/C in GLOB.admins)
		if(!check_other_rights(C, R_ADMIN, FALSE))
			continue
		if((C.prefs.toggles_chat & CHAT_FFATTACKLOGS) || ((SSticker.current_state == GAME_STATE_FINISHED) && (C.prefs.toggles_chat & CHAT_ENDROUNDLOGS)))
			to_chat(C, msg)


/client/proc/find_stealth_key(txt)
	if(txt)
		for(var/P in GLOB.stealthminID)
			if(GLOB.stealthminID[P] == txt)
				return P
	txt = GLOB.stealthminID[ckey]
	return txt


/client/proc/create_stealth_key()
	var/num = (rand(0,1000))
	var/i = 0
	while(i == 0)
		i = 1
		for(var/P in GLOB.stealthminID)
			if(num == GLOB.stealthminID[P])
				num++
				i = 0
	GLOB.stealthminID["[ckey]"] = "@[num2text(num)]"


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
	return usr?.client && GLOB.AdminProcCaller == usr.client.ckey


/proc/GenIrcStealthKey()
	var/num = (rand(0,1000))
	var/i = 0
	while(i == 0)
		i = 1
		for(var/P in GLOB.stealthminID)
			if(num == GLOB.stealthminID[P])
				num++
				i = 0
	var/stealth = "@[num2text(num)]"
	GLOB.stealthminID["IRCKEY"] = stealth
	return	stealth


/proc/IsAdminGhost(mob/user)
	if(!istype(user))
		return FALSE
	if(!user.client)
		return FALSE
	if(!isobserver(user))
		return FALSE
	if(!check_other_rights(user.client, R_ADMIN, FALSE)) // Are they allowed?
		return FALSE
	if(!user.client.ai_interact)
		return FALSE
	return TRUE