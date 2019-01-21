GLOBAL_LIST_EMPTY(admin_datums)
GLOBAL_PROTECT(admin_datums)
GLOBAL_LIST_EMPTY(protected_admins)
GLOBAL_PROTECT(protected_admins)

GLOBAL_VAR_INIT(href_token, GenerateToken())
GLOBAL_PROTECT(href_token)

var/list/admin_datums = list()


/datum/admins
	var/rank			= "Temporary Admin"
	var/client/owner	= null
	var/rights = 0
	var/fakekey			= null

	var/datum/marked_datum

	var/href_token


/datum/admins/New(initial_rank = "Temporary Admin", initial_rights = 0, ckey)
	if(!ckey)
		stack_trace("Admin datum created without a ckey argument. Datum has been deleted")
		qdel(src)
		return
	rank = initial_rank
	rights = initial_rights
	if(rights & R_DEBUG) //grant profile access
		world.SetConfig("APP/admin", ckey, "role=admin")
	admin_datums[ckey] = src


/datum/admins/proc/associate(client/C)
	if(istype(C))
		owner = C
		owner.holder = src
		owner.add_admin_verbs()
		admins |= C


/datum/admins/proc/disassociate()
	if(owner)
		admins -= owner
		owner.remove_admin_verbs()
		owner.holder = null
		owner = null


/proc/check_rights(rights_required, show_msg = TRUE)
	if(!usr?.client)
		return FALSE

	if(rights_required)
		if(usr.client.holder && (usr.client.holder.rights & rights_required))
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

	if(rights_required && other.holder)
		if(rights_required & other.holder.rights)
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
		if(!other?.holder)
			return TRUE
		if(usr.client.holder.rights != other.holder.rights && ((usr.client.holder.rights & other.holder.rights) == other.holder.rights))
			return TRUE

	to_chat(usr, "<span class='warning'>Cannot proceed. They have more or equal rights to us.</span>")
	return FALSE


/client/proc/deadmin()
	admin_datums -= ckey
	if(holder)
		holder.disassociate()
		qdel(holder)
		holder = null
	return TRUE


/client/proc/readmin() //Basically load_admins but only takes the client's ckey.
	var/list/Lines = file2list("config/admins.txt")

	for(var/line in Lines)
		if(!length(line))
			continue
		if(copytext(line,1,2) == "#")
			continue
		var/list/List = text2list(line, "-")
		if(!List.len)
			continue
		var/target = ckey(List[1])
		if(!target)
			continue
		if(target != ckey)
			continue
		var/rank = ""
		if(List.len >= 2)
			rank = ckeyEx(List[2])
		var/rights = admin_ranks[rank]
		var/datum/admins/D = new /datum/admins(rank, rights, target)
		D.associate(directory[target])


/proc/IsAdminAdvancedProcCall()
	return usr?.client && GLOB.AdminProcCaller == usr.client.ckey


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


var/list/admin_verbs_default = list(
	)
var/list/admin_verbs_admin = list(
)
var/list/admin_verbs_ban = list(
	)
var/list/admin_verbs_sound = list(
	)
var/list/admin_verbs_fun = list(
	)
var/list/admin_verbs_spawn = list(
	)
var/list/admin_verbs_server = list(
	)
var/list/admin_verbs_debug = list(
	)
var/list/admin_verbs_permissions = list(
	)
var/list/admin_verbs_color = list(
	)

var/list/admin_verbs_hideable = list(
	)

var/list/admin_verbs_mentor = list(
)

/client/proc/add_admin_verbs()
	if(holder)
		verbs += admin_verbs_default
		if(holder.rights & R_ASAY)		verbs += admin_verbs_admin
		if(holder.rights & R_ADMIN)			verbs += admin_verbs_admin
		if(holder.rights & R_BAN)			verbs += admin_verbs_ban
		if(holder.rights & R_FUN)			verbs += admin_verbs_fun
		if(holder.rights & R_SERVER)		verbs += admin_verbs_server
		if(holder.rights & R_DEBUG)			verbs += admin_verbs_debug
		if(holder.rights & R_PERMISSIONS)	verbs += admin_verbs_permissions
		if(holder.rights & R_COLOR)			verbs += admin_verbs_color
		if(holder.rights & R_SOUND)		verbs += admin_verbs_sound
		if(holder.rights & R_SPAWN)			verbs += admin_verbs_spawn
		if(holder.rights & R_MENTOR)		verbs += admin_verbs_mentor

/client/proc/remove_admin_verbs()
	verbs.Remove(
		admin_verbs_default,
		admin_verbs_admin,
		admin_verbs_admin,
		admin_verbs_ban,
		admin_verbs_fun,
		admin_verbs_server,
		admin_verbs_debug,
		admin_verbs_permissions,
		admin_verbs_admin,
		admin_verbs_color,
		admin_verbs_sound,
		admin_verbs_spawn,
		)


/proc/is_mentor(client/C)
	if(!istype(C))
		return FALSE
	if(!C?.holder?.rights)
		return FALSE
	if(C.holder.rights & R_ADMIN)
		return FALSE
	if(!(C.holder.rights & R_MENTOR))
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


/proc/find_stealth_key() //TEMPORARY
	if(usr?.client?.holder)
		return usr.client.holder.owner.key