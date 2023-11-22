/datum/admins
	var/datum/admin_rank/rank

	var/target
	var/name = "nobody's admin datum (no rank)"
	var/client/owner = null
	var/fakekey = null

	var/datum/marked_datum
	var/marked_file

	var/href_token

	///Reference to filteriffic tgui holder datum
	var/datum/filter_editor/filteriffic
	///Reference to particle editor tgui holder datum
	var/datum/particle_editor/particle_test

	///Whether this admin is currently deadminned or not
	var/deadmined = FALSE
	///Whether this admin has ghost interaction enabled
	var/ghost_interact = FALSE
	///Whether this admin is invisiminning
	var/invisimined = FALSE


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
		add_verb(C, /client/proc/readmin)


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
	remove_verb(owner, /client/proc/readmin)
	owner.init_verbs()
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
			message_admins("[ADMIN_TPMONTY(usr)] is trying to re-admin but they have no de-admin entry.")
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

//This proc checks whether subject has at least ONE of the rights specified in rights_required.
/proc/check_rights_for(client/subject, rights_required)
	if(subject?.holder)
		return subject.holder.check_for_rights(rights_required)
	return FALSE

/datum/admins/proc/check_for_rights(rights_required)
	if(rights_required && !(rights_required & rank.rights))
		return FALSE
	return TRUE

/proc/check_rights(rights_required, show_msg = TRUE)
	if(!usr?.client)
		return FALSE

	if(rights_required)
		if(usr.client.holder?.rank && (usr.client.holder.rank.rights & rights_required))
			return TRUE
		else if(show_msg)
			to_chat(usr, span_warning("You do not have sufficient rights to do that. You require one of the following flags:[rights2text(rights_required," ")]."))
	else
		if(usr.client.holder)
			return TRUE
		else if(show_msg)
			to_chat(usr, span_warning("You are not a holder."))
	return FALSE


/proc/check_other_rights(client/other, rights_required, show_msg = TRUE)
	if(!other)
		return FALSE
	if(rights_required && other.holder?.rank?.rights)
		if(rights_required & other.holder.rank.rights)
			return TRUE
		else if(show_msg)
			to_chat(usr, span_warning("You do not have sufficient rights to do that. You require one of the following flags:[rights2text(rights_required," ")]."))
	else
		if(other.holder)
			return TRUE
		else if(show_msg)
			to_chat(usr, span_warning("You are not a holder."))
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
	to_chat(usr, span_warning("They have more or equal rights than you."))
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
	/datum/admins/proc/pref_ff_attack_logs,
	/datum/admins/proc/pref_end_attack_logs,
	/datum/admins/proc/pref_debug_logs,
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
	/datum/admins/proc/jump,
	/datum/admins/proc/get_mob,
	/datum/admins/proc/send_mob,
	/datum/admins/proc/jump_area,
	/datum/admins/proc/jump_coord,
	/datum/admins/proc/jump_mob,
	/datum/admins/proc/jump_key,
	/datum/admins/proc/secrets_panel,
	/datum/admins/proc/remove_from_tank,
	/datum/admins/proc/delete_squad,
	/datum/admins/proc/game_panel,
	/datum/admins/proc/mode_panel,
	/datum/admins/proc/job_slots,
	/datum/admins/proc/toggle_adminhelp_sound,
	/datum/admins/proc/toggle_prayers,
	/datum/admins/proc/check_fingerprints,
	/client/proc/smite,
	/client/proc/show_traitor_panel,
	/client/proc/cmd_select_equipment,
	/client/proc/validate_objectives,
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
	/datum/admins/proc/stickybanpanel,
	/datum/admins/proc/unban_panel,
	/datum/admins/proc/note_panel,
	/datum/admins/proc/show_player_panel,
	/datum/admins/proc/player_panel,
	/datum/admins/proc/player_panel_extended,
	/datum/admins/proc/mcdb
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
	/client/proc/debugstatpanel,
	/datum/admins/proc/delete_atom,
	/datum/admins/proc/restart_controller,
	/client/proc/debug_controller,
	/datum/admins/proc/check_contents,
	/datum/admins/proc/reestablish_db_connection,
	/client/proc/reestablish_tts_connection,
	/datum/admins/proc/view_runtimes,
	/client/proc/SDQL2_query,
	/client/proc/toggle_cdn
	)
GLOBAL_LIST_INIT(admin_verbs_debug, world.AVdebug())
GLOBAL_PROTECT(admin_verbs_debug)

/world/proc/AVruntimes()
	return list(
	/datum/admins/proc/view_runtimes,
	)
GLOBAL_LIST_INIT(admin_verbs_runtimes, world.AVruntimes())
GLOBAL_PROTECT(admin_verbs_runtimes)

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
	/datum/admins/proc/rouny_all,
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
	/datum/admins/proc/object_sound,
	/datum/admins/proc/drop_bomb,
	/datum/admins/proc/drop_dynex_bomb,
	/datum/admins/proc/change_security_level,
	/datum/admins/proc/edit_appearance,
	/datum/admins/proc/offer,
	/datum/admins/proc/force_dropship,
	/datum/admins/proc/open_shuttlepanel,
	/datum/admins/proc/xeno_panel,
	/datum/admins/proc/view_faxes,
	/datum/admins/proc/possess,
	/datum/admins/proc/release,
	/client/proc/centcom_podlauncher,
	/datum/admins/proc/play_cinematic,
	/datum/admins/proc/set_tip,
	/datum/admins/proc/ghost_interact,
	/client/proc/force_event,
	/client/proc/toggle_events,
	/client/proc/run_weather,
	/client/proc/cmd_display_del_log,
	/datum/admins/proc/map_template_load,
	/datum/admins/proc/map_template_upload,
	/datum/admins/proc/spatial_agent,
	/datum/admins/proc/set_xeno_stat_buffs,
	/datum/admins/proc/check_bomb_impacts,
	/datum/admins/proc/adjust_gravity,
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
	/datum/admins/proc/change_ground_map,
	/datum/admins/proc/change_ship_map,
	/datum/admins/proc/panic_bunker,
	/datum/admins/proc/mode_check,
	/client/proc/toggle_cdn
	)
GLOBAL_LIST_INIT(admin_verbs_server, world.AVserver())
GLOBAL_PROTECT(admin_verbs_server)

/world/proc/AVpermissions()
	return list(
	/client/proc/edit_admin_permissions,
	/client/proc/poll_panel,
	)
GLOBAL_LIST_INIT(admin_verbs_permissions, world.AVpermissions())
GLOBAL_PROTECT(admin_verbs_permissions)

/world/proc/AVcolor()
	return list(
		/datum/admins/proc/set_ooc_color_self,
	)
GLOBAL_LIST_INIT(admin_verbs_color, world.AVcolor())
GLOBAL_PROTECT(admin_verbs_color)

/world/proc/AVsound()
	return list(
		/datum/admins/proc/sound_file,
		/datum/admins/proc/sound_web,
		/datum/admins/proc/sound_stop,
		/datum/admins/proc/music_stop,
		/client/proc/set_round_end_sound,
	)
GLOBAL_LIST_INIT(admin_verbs_sound, world.AVsound())
GLOBAL_PROTECT(admin_verbs_sound)

/world/proc/AVspawn()
	return list(
	/datum/admins/proc/spawn_atom,
	/client/proc/get_togglebuildmode,
	/client/proc/mass_replace,
	/client/proc/toggle_admin_tads,
	)
GLOBAL_LIST_INIT(admin_verbs_spawn, world.AVspawn())
GLOBAL_PROTECT(admin_verbs_spawn)

/world/proc/AVlog()
	return list(
	/datum/admins/proc/logs_server,
	/datum/admins/proc/logs_current,
	/datum/admins/proc/logs_folder,
	/client/proc/log_viewer_new
	)
GLOBAL_LIST_INIT(admin_verbs_log, world.AVlog())
GLOBAL_PROTECT(admin_verbs_log)

/client/proc/add_admin_verbs()
	if(holder)
		var/rights = holder.rank.rights
		add_verb(src, GLOB.admin_verbs_default)
		if(rights & R_ADMIN)
			add_verb(src, GLOB.admin_verbs_admin)
		if(rights & R_MENTOR)
			add_verb(src, GLOB.admin_verbs_mentor)
		if(rights & R_BAN)
			add_verb(src, GLOB.admin_verbs_ban)
		if(rights & R_ASAY)
			add_verb(src, GLOB.admin_verbs_asay)
		if(rights & R_FUN)
			add_verb(src, GLOB.admin_verbs_fun)
		if(rights & R_SERVER)
			add_verb(src, GLOB.admin_verbs_server)
		if(rights & R_DEBUG)
			add_verb(src, GLOB.admin_verbs_debug)
		if(rights & R_RUNTIME)
			add_verb(src, GLOB.admin_verbs_runtimes)
		if(rights & R_PERMISSIONS)
			add_verb(src, GLOB.admin_verbs_permissions)
		if(rights & R_DBRANKS)
			add_verb(src, GLOB.admin_verbs_permissions)
		if(rights & R_SOUND)
			add_verb(src, GLOB.admin_verbs_sound)
		if(rights & R_COLOR)
			add_verb(src, GLOB.admin_verbs_color)
		if(rights & R_VAREDIT)
			add_verb(src, GLOB.admin_verbs_varedit)
		if(rights & R_SPAWN)
			add_verb(src, GLOB.admin_verbs_spawn)
		if(rights & R_LOG)
			add_verb(src, GLOB.admin_verbs_log)


/client/proc/remove_admin_verbs()
	remove_verb(src, list(
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
		GLOB.admin_verbs_spawn,
		GLOB.admin_verbs_log,
	))


/proc/is_mentor(client/C)
	if(!istype(C))
		return FALSE
	if(!C?.holder?.rank?.rights)
		return FALSE
	if(check_other_rights(C, R_ADMIN, FALSE))
		return FALSE
	if(!check_other_rights(C, R_MENTOR, FALSE))
		return FALSE
	return TRUE


/proc/message_admins(msg)
	msg = "<span class=\"admin\"><span class=\"prefix\">ADMIN LOG:</span> <span class=\"message\">[msg]</span></span>"
	for(var/client/C in GLOB.admins)
		if(check_other_rights(C, R_ADMIN, FALSE))
			to_chat(C,
				type = MESSAGE_TYPE_ADMINLOG,
				html = msg)



/proc/message_staff(msg)
	msg = "<span class=\"admin\"><span class=\"prefix\">STAFF LOG:</span> <span class=\"message\">[msg]</span></span>"
	for(var/client/C in GLOB.admins)
		if(check_other_rights(C, R_ADMIN, FALSE) || is_mentor(C))
			to_chat(C,
				type = MESSAGE_TYPE_STAFFLOG,
				html = msg)

/proc/msg_admin_ff(msg)
	msg = span_admin("[span_prefix("ATTACK:")] <span class='green'>[msg]</span>")
	for(var/client/C in GLOB.admins)
		if(!check_other_rights(C, R_ADMIN, FALSE))
			continue
		if((C.prefs.toggles_chat & CHAT_FFATTACKLOGS) || ((SSticker.current_state == GAME_STATE_FINISHED) && (C.prefs.toggles_chat & CHAT_ENDROUNDLOGS)))
			to_chat(C,
				type = MESSAGE_TYPE_ATTACKLOG,
				html = msg)


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

/proc/GenTgsStealthKey()
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
	if(!isobserver(user))
		return FALSE
	if(!user.client)
		return FALSE
	if(!check_other_rights(user.client, R_ADMIN, FALSE)) // Are they allowed?
		return FALSE
	if(!user.client.holder.ghost_interact)
		return FALSE
	return TRUE

/proc/isadmin(mob/user)
	if(!isobserver(user))
		return FALSE
	if(!user.client)
		return FALSE
	if(!check_other_rights(user.client, R_ADMIN, FALSE)) // Are they allowed?
		return FALSE
	return TRUE


/datum/admins/proc/apicker(text, title, list/targets)
	if(!check_rights(NONE))
		return

	var/atom/chosen
	var/choice = input(text, title) as null|anything in targets

	switch(choice)
		if(APICKER_CLIENT)
			var/client/C = input("Please, select a key.", title) as null|anything in sortKey(GLOB.clients)
			chosen = C?.mob
		if(APICKER_MOB)
			chosen = input("Please, select a mob.", title) as null|anything in sortNames(GLOB.mob_list)
		if(APICKER_LIVING)
			chosen = input("Please, select a living mob.", title) as null|anything in sortNames(GLOB.mob_living_list)
		if(APICKER_AREA)
			chosen = input("Please, select an area.", title) as null|anything in GLOB.sorted_areas
			chosen = pick(get_area_turfs(chosen))
		if(APICKER_TURF)
			chosen = input("Please, select a turf.", title) as null|turf in world
		if(APICKER_COORDS)
			var/X = input("X coordinate.", title) as null|num
			var/Y = input("Y coordinate.", title) as null|num
			var/Z = input("Z coordinate.", title) as null|num
			chosen = locate(X, Y, Z)

	return chosen


/datum/admins/vv_edit_var(var_name, var_value)
	return FALSE
