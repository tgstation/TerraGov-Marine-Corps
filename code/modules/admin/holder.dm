/datum/admins
	var/datum/admin_rank/rank

	var/target
	var/name = "nobody's admin datum (no rank)"
	var/client/owner = null
	var/fakekey = null

	var/datum/marked_datum
	var/marked_file

	/// Code security critcal token used for authorizing href topic calls
	var/href_token

	///Reference to filteriffic tgui holder datum
	var/datum/filter_editor/filteriffic
	///Reference to particle editor tgui holder datum
	var/datum/particle_editor/particle_test
	var/datum/plane_master_debug/plane_debug

	///Whether this admin is currently deadminned or not
	var/deadmined = FALSE
	///Whether this admin has ghost interaction enabled
	var/ghost_interact = FALSE
	///Whether this admin is invisiminning
	var/invisimined = FALSE
	/// A lazylist of tagged datums, for quick reference with the View Tags verb
	var/list/tagged_datums

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

/datum/admins/can_vv_get(var_name)
	if(var_name == NAMEOF(src, href_token))
		return FALSE
	return ..()

/datum/admins/proc/activate()
	if(IsAdminAdvancedProcCall())
		log_admin("[key_name(usr)] has tried to elevate permissions!")
		message_admins("[ADMIN_TPMONTY(usr)] has tried to elevate permissions!")
		return
	GLOB.deadmins -= target
	GLOB.admin_datums[target] = src
	plane_debug = new(src)
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
	QDEL_NULL(plane_debug)
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

ADMIN_VERB(deadmin, R_NONE, "DeAdmin", "Shed your admin powers.", ADMIN_CATEGORY_MAIN)
	user.holder.deactivate()
	to_chat(user, span_interface("You are now a normal player."))
	log_admin("[key_name(user)] deadminned themselves.")
	message_admins("[key_name_admin(user)] deadminned themselves.")


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
			chosen = input("Please, select an area.", title) as null|anything in get_sorted_areas()
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

/**
*Kicks all the clients currently in the lobby. The second parameter (kick_only_afk) determins if an is_afk() check is ran, or if all clients are kicked
*defaults to kicking everyone (afk + non afk clients in the lobby)
*returns a list of ckeys of the kicked clients
*/
/proc/kick_clients_in_lobby(message, kick_only_afk = 0)
	var/list/kicked_client_names = list()
	for(var/client/C in GLOB.clients)
		if(isnewplayer(C.mob))
			if(kick_only_afk && !C.is_afk()) //Ignore clients who are not afk
				continue
			if(message)
				to_chat(C, message, confidential = TRUE)
			kicked_client_names.Add("[C.key]")
			qdel(C)
	return kicked_client_names
