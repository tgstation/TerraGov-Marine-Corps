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

/*
checks if usr is an admin with at least ONE of the flags in rights_required. (Note, they don't need all the flags)
if rights_required == 0, then it simply checks if they are an admin.


NOTE: it checks usr! not src! So if you're checking somebody's rank in a proc which they did not call
you will have to do something like if(client.holder.rights & R_ADMIN) yourself.
*/
/proc/check_rights(rights_required, show_msg=1)
	if(usr?.client)
		if(rights_required)
			if(usr.client.holder)
				if(rights_required & usr.client.holder.rights)
					return TRUE
				else
					if(show_msg)
						to_chat(usr, "<span class='warning'>Error: You do not have sufficient rights to do that. You require one of the following flags:[rights2text(rights_required," ")].</span>")
		else
			if(usr.client.holder)
				return TRUE
			else if(show_msg)
					to_chat(usr, "<font color='red'>Error: You are not a holder.</font>")
	return FALSE

//probably a bit iffy - will hopefully figure out a better solution
/proc/check_if_greater_rights_than(client/other)
	if(usr && usr.client)
		if(usr.client.holder)
			if(!other || !other.holder)
				return 1
			if(usr.client.holder.rights != other.holder.rights)
				if( (usr.client.holder.rights & other.holder.rights) == other.holder.rights )
					return 1	//we have all the rights they have and more
		to_chat(usr, "<font color='red'>Error: Cannot proceed. They have more or equal rights to us.</font>")
	return 0

/client/proc/deadmin()
	admin_datums -= ckey
	if(holder)
		holder.disassociate()
		qdel(holder)
		holder = null
	return TRUE

/client/proc/readmin()
	//load text from file
	var/list/Lines = file2list("config/admins.txt")

	//process each line seperately
	for(var/line in Lines)
		if(!length(line))
			continue
		if(copytext(line,1,2) == "#")
			continue

		//Split the line at every "-"
		var/list/List = text2list(line, "-")
		if(!List.len)
			continue

		//ckey is before the first "-"
		var/target = ckey(List[1])
		if(!target)
			continue
		if(target != ckey)
			continue

		//rank follows the first "-"
		var/rank = ""
		if(List.len >= 2)
			rank = ckeyEx(List[2])

		//load permissions associated with this rank
		var/rights = admin_ranks[rank]

		//create the admin datum and store it for later use
		var/datum/admins/D = new /datum/admins(rank, rights, target)

		//find the client for a ckey if they are connected and associate them with the new admin datum
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
		if(holder.rights & R_ASAY)		verbs += /client/proc/togglebuildmodeself
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
		/client/proc/togglebuildmodeself,
		admin_verbs_admin,
		admin_verbs_ban,
		admin_verbs_fun,
		admin_verbs_server,
		admin_verbs_debug,
		admin_verbs_permissions,
		/client/proc/stealth_mode,
		admin_verbs_color,
		admin_verbs_sound,
		admin_verbs_spawn,
		debug_verbs
		)


/datum/admins/proc/hide_most_verbs()//Allows you to keep some functionality while hiding some verbs
	set name = "Adminverbs - Hide Most"
	set category = "Admin"

	verbs.Remove(/client/proc/hide_most_verbs, admin_verbs_hideable)
	verbs += /client/proc/show_verbs

	to_chat(src, "<span class='interface'>Most of your adminverbs have been hidden.</span>")
	feedback_add_details("admin_verb","HMV") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return


/datum/admins/proc/hide_verbs()
	set name = "Adminverbs - Hide All"
	set category = "Admin"

	remove_admin_verbs()
	verbs += /client/proc/show_verbs

	to_chat(src, "<span class='interface'>Almost all of your adminverbs have been hidden.</span>")
	feedback_add_details("admin_verb","TAVVH") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return


/datum/admins/proc/show_verbs()
	set name = "Adminverbs - Show"
	set category = "Admin"

	verbs -= /client/proc/show_verbs
	add_admin_verbs()

	to_chat(src, "<span class='interface'>All of your adminverbs are now visible.</span>")
	feedback_add_details("admin_verb","TAVVS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!



var/list/debug_verbs = list(
		)


/datum/admins/proc/enable_debug_verbs()
	set category = "Debug"
	set name = "*Debug Verbs - Show*"

	if(!check_rights(R_DEBUG)) return

	verbs += debug_verbs
	verbs -= /client/proc/enable_debug_verbs

	feedback_add_details("admin_verb","mDV") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/hide_debug_verbs()
	set category = "Debug"
	set name = "*Debug Verbs - Hide*"

	if(!check_rights(R_DEBUG)) return

	verbs -= debug_verbs
	verbs += /client/proc/enable_debug_verbs

	feedback_add_details("admin_verb","hDV") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/proc/is_mentor(client/C)
	if(!istype(C))
		return FALSE
	if(!C?.holder?.rights)
		return FALSE
	if(C.holder.rights & (R_MENTOR) && !(C.holder.rights & (R_ADMIN)))
		return TRUE
	return FALSE


/proc/message_admins(var/msg)
	log_admin_private("ADMIN LOG:[msg]")
	msg = "<span class='admin'><span class='prefix'>ADMIN LOG:</span> <span class='message'>[msg]</span></span>"
	for(var/client/C in admins)
		if(C.holder?.rights && (C.holder.rights & R_ADMIN))
			to_chat(C, msg)


/proc/message_staff(var/msg)
	msg = "<span class='admin'><span class=''prefix'>STAFF LOG:</span> <span class='message'>[msg]</span></span>"
	log_admin_private(msg)
	for(var/client/C in admins)
		if(C.holder.rights)
			to_chat(C, msg)


/proc/msg_admin_attack(var/text)
	log_attack(text)
	var/rendered = "<span class='admin'><span class='prefix'>ATTACK:</span> <span class='message'>[text]</span></span>"
	for(var/client/C in admins)
		if(R_ADMIN & C.holder.rights)
			if((C.prefs.toggles_chat & CHAT_ATTACKLOGS) && !((ticker.current_state == GAME_STATE_FINISHED) && (C.prefs.toggles_chat & CHAT_ENDROUNDLOGS)))
				var/msg = rendered
				to_chat(C, msg)


/proc/msg_admin_ff(var/text)
	log_attack(text) //Do everything normally BUT IN GREEN SO THEY KNOW
	var/rendered = "<span class=\"admin\"><span class=\"prefix\">ATTACK:</span> <font color=#00ff00><b>[text]</b></font></span>" //I used <font> because I never learned html correctly, fix this if you want
	for(var/client/C in admins)
		if(R_ADMIN & C.holder.rights)
			if((C.prefs.toggles_chat & CHAT_FFATTACKLOGS) && !((ticker.current_state == GAME_STATE_FINISHED) && (C.prefs.toggles_chat & CHAT_ENDROUNDLOGS)))
				var/msg = rendered
				to_chat(C, msg)


/client/proc/findStealthKey() //TEMPORARY
	if(holder)
		return holder.owner.key