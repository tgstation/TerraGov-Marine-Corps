////////////////
//  SECURITY  //
////////////////
#define UPLOAD_LIMIT			1000000	//Restricts client uploads to the server to 1MB
#define UPLOAD_LIMIT_ADMIN		10000000	//Restricts admin uploads to the server to 10MB

GLOBAL_LIST_INIT(blacklisted_builds, list(
	"1407" = "bug preventing client display overrides from working leads to clients being able to see things/mobs they shouldn't be able to see",
	"1408" = "bug preventing client display overrides from working leads to clients being able to see things/mobs they shouldn't be able to see",
	"1428" = "bug causing right-click menus to show too many verbs that's been fixed in version 1429",

	))

	/*
	When somebody clicks a link in game, this Topic is called first.
	It does the stuff in this proc and  then is redirected to the Topic() proc for the src=[0xWhatever]
	(if specified in the link). ie locate(hsrc).Topic()

	Such links can be spoofed.

	Because of this certain things MUST be considered whenever adding a Topic() for something:
		- Can it be fed harmful values which could cause runtimes?
		- Is the Topic call an admin-only thing?
		- If so, does it have checks to see if the person who called it (usr.client) is an admin?
		- Are the processes being called by Topic() particularly laggy?
		- If so, is there any protection against somebody spam-clicking a link?
	If you have any  questions about this stuff feel free to ask. ~Carn
	*/

/client/Topic(href, href_list, hsrc)
	if(!usr || usr != mob)	//stops us calling Topic for somebody else's client. Also helps prevent usr=null
		return

	//Asset cache
	if(href_list["asset_cache_confirm_arrival"])
		var/job = text2num(href_list["asset_cache_confirm_arrival"])
		//because we skip the limiter, we have to make sure this is a valid arrival and not somebody tricking us
		//into letting append to a list without limit.
		if(job && job <= last_asset_job && !(job in completed_asset_jobs))
			completed_asset_jobs += job
			return
		else if(job in completed_asset_jobs) //byond bug ID:2256651
			to_chat(src, "<span class='danger'>An error has been detected in how your client is receiving resources. Attempting to correct.... (If you keep seeing these messages you might want to close byond and reconnect)</span>")
			src << browse("...", "window=asset_cache_browser")


	if(href_list["_src_"] == "chat") // Oh god the ping hrefs.
		return chatOutput.Topic(href, href_list)


	//Search the href for script injection.
	if(findtext(href,"<script", 1, 0))
		log_world("[key_name(usr)] attempted use of scripts within a topic call.")
		message_admins("[ADMIN_TPMONTY(usr)] attempted use of scripts within a topic call.")
		return


	//Logs all hrefs, except chat pings
	if(!(href_list["_src_"] == "chat" && href_list["proc"] == "ping" && LAZYLEN(href_list) == 2))
		log_href("[src] (usr:[usr]\[[COORD(usr)]\]) : [hsrc ? "[hsrc] " : ""][href]")


	//Admin PM
	if(href_list["priv_msg"])
		private_message(href_list["priv_msg"], null)
		return


	switch(href_list["_src_"])
		if("holder")
			hsrc = holder
		if("usr")
			hsrc = mob
		if("prefs")
			return prefs.process_link(usr, href_list)
		if("vars")
			return view_var_Topic(href, href_list, hsrc)
		if("chat")
			return chatOutput.Topic(href, href_list)


	switch(href_list["action"])
		if("openLink")
			src << link(href_list["link"])

	if(hsrc)
		var/datum/real_src = hsrc
		if(QDELETED(real_src))
			return

	return ..()	//redirect to hsrc.Topic()


/client/proc/handle_spam_prevention(message, mute_type)
	if(CONFIG_GET(flag/automute_on) && !check_rights(R_ADMIN, FALSE) && last_message == message)
		last_message_count++
		if(last_message_count >= SPAM_TRIGGER_AUTOMUTE)
			to_chat(src, "<span class='danger'>You have exceeded the spam filter limit for identical messages. An auto-mute was applied.</span>")
			mute(src, mute_type, TRUE)
			return TRUE
		else if(last_message_count >= SPAM_TRIGGER_WARNING)
			to_chat(src, "<span class='danger'>You are nearing the spam filter limit for identical messages.</span>")
			return TRUE
	else
		last_message = message
		last_message_count = 0
		return FALSE


//This stops files larger than UPLOAD_LIMIT being sent from client to server via input(), client.Import() etc.
/client/AllowUpload(filename, filelength)
	if(!check_rights(R_ADMIN, FALSE) && filelength > UPLOAD_LIMIT)
		to_chat(src, "<font color='red'>Error: AllowUpload(): File Upload too large. Upload Limit: [UPLOAD_LIMIT/1024]KiB.</font>")
		return FALSE
	else if(filelength > UPLOAD_LIMIT_ADMIN)
		to_chat(src, "<font color='red'>Error: AllowUpload(): File Upload too large. Upload Limit: [UPLOAD_LIMIT/1024]KiB. Stop trying to break the server.</font>")
		return FALSE
	return TRUE


///////////////
//  CONNECT  //
///////////////
GLOBAL_VAR_INIT(external_rsc_url, TRUE)


/client/New(TopicData)
	var/tdata = TopicData //save this for later use
	chatOutput = new /datum/chatOutput(src)
	TopicData = null	//Prevent calls to client.Topic from connect

	if(connection != "seeker" && connection != "web")	//Invalid connection type.
		return null


	if(!GLOB.guests_allowed && IsGuestKey(key))
		alert(src,"This server doesn't allow guest accounts to play. Please go to http://www.byond.com/ and register for a key.", "Guest", "OK")
		qdel(src)
		return

	GLOB.clients += src
	GLOB.directory[ckey] = src

	GLOB.ahelp_tickets.ClientLogin(src)

	if(CONFIG_GET(flag/localhost_rank))
		var/static/list/localhost_addresses = list("127.0.0.1", "::1")
		if(isnull(address) || (address in localhost_addresses))
			var/datum/admin_rank/rank = new("!localhost!", R_EVERYTHING, , R_EVERYTHING)
			var/datum/admins/admin = new(rank, ckey, TRUE)
			admin.associate(src)

	holder = GLOB.admin_datums[ckey]
	if(holder)
		GLOB.admins |= src
		holder.owner = src
		holder.activate()
	else if(GLOB.deadmins[ckey])
		verbs += /client/proc/readmin

	//preferences datum - also holds some persistant data for the client (because we may as well keep these datums to a minimum)
	prefs = GLOB.preferences_datums[ckey]
	if(!prefs || isnull(prefs) || !istype(prefs))
		prefs = new /datum/preferences(src)
		GLOB.preferences_datums[ckey] = prefs
	prefs.parent = src
	prefs.last_ip = address				//these are gonna be used for banning
	prefs.last_id = computer_id			//these are gonna be used for banning

	var/full_version = "[byond_version].[byond_build ? byond_build : "xxx"]"

	if(CONFIG_GET(flag/log_access))
		for(var/I in GLOB.clients)
			if(!I)
				stack_trace("null in GLOB.clients during client/New()")
				continue
			if(I == src)
				continue
			var/client/C = I
			if(C.key && (C.key != key) )
				var/matches
				if( (C.address == address) )
					matches += "IP ([address])"
				if( (C.computer_id == computer_id) )
					if(matches)
						matches += " and "
					matches += "ID ([computer_id])"
				if(matches)
					if(C)
						message_admins("<span class='danger'><B>Notice: </B></span><span class='notice'>[key_name_admin(src)] has the same [matches] as [key_name_admin(C)].</span>")
						log_access("Notice: [key_name(src)] has the same [matches] as [key_name(C)].")
					else
						message_admins("<span class='danger'><B>Notice: </B></span><span class='notice'>[key_name_admin(src)] has the same [matches] as [key_name_admin(C)] (no longer logged in). </span>")
						log_access("Notice: [key_name(src)] has the same [matches] as [key_name(C)] (no longer logged in).")

	. = ..()	//calls mob.Login()
	chatOutput.start() // Starts the chat

	if(byond_version < 512)
		to_chat(src, "<span class='userdanger'>Your version of byond is severely out of date.</span>")
		to_chat(src, "<span class='danger'>Please download a new version of byond. If [byond_build] is the latest, you can go to <a href=\"https://secure.byond.com/download/build\">BYOND's website</a> to download other versions.</span>")
		addtimer(CALLBACK(src, qdel(src), 2 SECONDS))
		return

	if(!byond_build || byond_build < 1386)
		message_admins("[key_name(src)] has been detected as spoofing their byond version. Connection rejected.")
		log_access("Failed Login: [key] - Spoofed byond version")
		qdel(src)
		return

	if(num2text(byond_build) in GLOB.blacklisted_builds)
		log_access("Failed login: [key] - blacklisted byond version")
		to_chat(src, "<span class='userdanger'>Your version of byond is blacklisted.</span>")
		to_chat(src, "<span class='danger'>Byond build [byond_build] ([byond_version].[byond_build]) has been blacklisted for the following reason: [GLOB.blacklisted_builds[num2text(byond_build)]].</span>")
		to_chat(src, "<span class='danger'>Please download a new version of byond. If [byond_build] is the latest, you can go to <a href=\"https://secure.byond.com/download/build\">BYOND's website</a> to download other versions.</span>")
		addtimer(CALLBACK(src, qdel(src), 2 SECONDS))
		return

	if(GLOB.custom_info)
		to_chat(src, "<h1 class='alert'>Custom Information</h1>")
		to_chat(src, "<h2 class='alert'>The following custom information has been set for this round:</h2>")
		to_chat(src, "<span class='alert'>[GLOB.custom_info]</span>")
		to_chat(src, "<br>")

	preload_rsc = GLOB.external_rsc_url

	var/cached_player_age = set_client_age_from_db(tdata) //we have to cache this because other shit may change it and we need it's current value now down below.
	if(isnum(cached_player_age) && cached_player_age == -1) //first connection
		player_age = 0
	var/nnpa = CONFIG_GET(number/notify_new_player_age)
	if(isnum(cached_player_age) && cached_player_age == -1) //first connection
		if(nnpa >= 0)
			message_admins("New user: [key_name_admin(src)] is connecting here for the first time.")
	else if(isnum(cached_player_age) && cached_player_age < nnpa)
		message_admins("New user: [key_name_admin(src)] just connected with an age of [cached_player_age] day[(player_age == 1 ? "" : "s")]")
	if(CONFIG_GET(flag/use_account_age_for_jobs) && account_age >= 0)
		player_age = account_age
	if(account_age >= 0 && account_age < nnpa)
		message_admins("[key_name_admin(src)] (IP: [address], ID: [computer_id]) is a new BYOND account [account_age] day[(account_age == 1 ? "" : "s")] old, created on [account_join_date].")


	get_message_output("watchlist entry", ckey)
	validate_key_in_db()

	send_assets()

	generate_clickcatcher()
	apply_clickcatcher()

	if(prefs.lastchangelog != GLOB.changelog_hash) //bolds the changelog button on the interface so we know there are updates.
		winset(src, "rpane.changelog", "background-color=#ED9F9B;font-style=bold")

	if(ckey in GLOB.clientmessages)
		for(var/message in GLOB.clientmessages[ckey])
			to_chat(src, message)
		GLOB.clientmessages.Remove(ckey)

	to_chat(src, get_message_output("message", ckey))

	if(holder)
		if(holder.rank.rights & R_ADMIN)
			message_admins("Admin login: [key_name_admin(src)].")
			to_chat(src, get_message_output("memo"))
		else if(holder.rank.rights & R_MENTOR)
			message_staff("Mentor login: [key_name_admin(src)].")

	if(GLOB.player_details[ckey])
		player_details = GLOB.player_details[ckey]
		player_details.byond_version = full_version
	else
		player_details = new
		player_details.byond_version = full_version
		GLOB.player_details[ckey] = player_details

	winset(src, null, "mainwindow.title='[CONFIG_GET(string/title)]'")



//////////////////
//  DISCONNECT  //
//////////////////
/client/Del()
	if(isliving(mob))
		var/mob/living/L = mob
		L.begin_away()
	if(holder)
		if(check_rights(R_ADMIN, FALSE))
			message_admins("Admin logout: [key_name(src)].")
		else if(check_rights(R_MENTOR, FALSE))
			message_staff("Mentor logout: [key_name(src)].")
		holder.owner = null
		GLOB.admins -= src

	GLOB.ahelp_tickets.ClientLogout(src)
	GLOB.directory -= ckey
	GLOB.clients -= src
	GLOB.directory -= ckey
	GLOB.clients -= src
	QDEL_LIST_ASSOC_VAL(char_render_holders)
	return ..()


/client/Destroy()
	return QDEL_HINT_HARDDEL_NOW



//checks if a client is afk
//3000 frames = 5 minutes
/client/proc/is_afk(duration = 5 MINUTES)
	if(inactivity > duration)
		return inactivity
	return FALSE


//send resources to the client. It's here in its own proc so we can move it around easiliy if need be
/client/proc/send_assets()
	//get the common files
	getFiles(
		'html/search.js',
		'html/panels.css',
		'html/browser/common.css',
		'html/browser/scannernew.css',
		)
	spawn(10) //removing this spawn causes all clients to not get verbs.
		//Precache the client with all other assets slowly, so as to not block other browse() calls
		getFilesSlow(src, SSassets.preload, register_asset = FALSE)


//Hook, override it to run code when dir changes
//Like for /atoms, but clients are their own snowflake FUCK
/client/proc/setDir(newdir)
	dir = newdir

/client/proc/get_offset()
	return max(abs(pixel_x / 32), abs(pixel_y / 32))


/client/proc/show_character_previews(mutable_appearance/MA)
	var/pos = 0
	for(var/D in GLOB.cardinals)
		pos++
		var/obj/screen/O = LAZYACCESS(char_render_holders, "[D]")
		if(!O)
			O = new
			LAZYSET(char_render_holders, "[D]", O)
			screen |= O
		O.appearance = MA
		O.dir = D
		O.screen_loc = "character_preview_map:0,[pos]"

/client/proc/clear_character_previews()
	for(var/index in char_render_holders)
		var/obj/screen/S = char_render_holders[index]
		screen -= S
		qdel(S)
	char_render_holders = null


/client/proc/set_client_age_from_db(connectiontopic)
	if(IsGuestKey(key))
		return
	if(!SSdbcore.Connect())
		return
	var/sql_ckey = sanitizeSQL(ckey)
	var/datum/DBQuery/query_get_related_ip = SSdbcore.NewQuery("SELECT ckey FROM [format_table_name("player")] WHERE ip = INET_ATON('[address]') AND ckey != '[sql_ckey]'")
	if(!query_get_related_ip.Execute())
		qdel(query_get_related_ip)
		return
	related_accounts_ip = ""
	while(query_get_related_ip.NextRow())
		related_accounts_ip += "[query_get_related_ip.item[1]], "
	qdel(query_get_related_ip)
	var/datum/DBQuery/query_get_related_cid = SSdbcore.NewQuery("SELECT ckey FROM [format_table_name("player")] WHERE computerid = '[computer_id]' AND ckey != '[sql_ckey]'")
	if(!query_get_related_cid.Execute())
		qdel(query_get_related_cid)
		return
	related_accounts_cid = ""
	while (query_get_related_cid.NextRow())
		related_accounts_cid += "[query_get_related_cid.item[1]], "
	qdel(query_get_related_cid)
	var/admin_rank = "Player"
	if(holder && holder.rank)
		admin_rank = holder.rank.name
	var/sql_ip = sanitizeSQL(address)
	var/sql_computerid = sanitizeSQL(computer_id)
	var/sql_admin_rank = sanitizeSQL(admin_rank)
	var/new_player
	var/datum/DBQuery/query_client_in_db = SSdbcore.NewQuery("SELECT 1 FROM [format_table_name("player")] WHERE ckey = '[sql_ckey]'")
	if(!query_client_in_db.Execute())
		qdel(query_client_in_db)
		return
	if(!query_client_in_db.NextRow())
		new_player = 1
		account_join_date = sanitizeSQL(findJoinDate())
		var/sql_key = sanitizeSQL(key)
		var/datum/DBQuery/query_add_player = SSdbcore.NewQuery("INSERT INTO [format_table_name("player")] (`ckey`, `byond_key`, `firstseen`, `firstseen_round_id`, `lastseen`, `lastseen_round_id`, `ip`, `computerid`, `lastadminrank`, `accountjoindate`) VALUES ('[sql_ckey]', '[sql_key]', Now(), '[GLOB.round_id]', Now(), '[GLOB.round_id]', INET_ATON('[sql_ip]'), '[sql_computerid]', '[sql_admin_rank]', [account_join_date ? "'[account_join_date]'" : "NULL"])")
		if(!query_add_player.Execute())
			qdel(query_client_in_db)
			qdel(query_add_player)
			return
		qdel(query_add_player)
		if(!account_join_date)
			account_join_date = "Error"
			account_age = -1
	qdel(query_client_in_db)
	var/datum/DBQuery/query_get_client_age = SSdbcore.NewQuery("SELECT firstseen, DATEDIFF(Now(),firstseen), accountjoindate, DATEDIFF(Now(),accountjoindate) FROM [format_table_name("player")] WHERE ckey = '[sql_ckey]'")
	if(!query_get_client_age.Execute())
		qdel(query_get_client_age)
		return
	if(query_get_client_age.NextRow())
		player_join_date = query_get_client_age.item[1]
		player_age = text2num(query_get_client_age.item[2])
		if(!account_join_date)
			account_join_date = query_get_client_age.item[3]
			account_age = text2num(query_get_client_age.item[4])
			if(!account_age)
				account_join_date = sanitizeSQL(findJoinDate())
				if(!account_join_date)
					account_age = -1
				else
					var/datum/DBQuery/query_datediff = SSdbcore.NewQuery("SELECT DATEDIFF(Now(),'[account_join_date]')")
					if(!query_datediff.Execute())
						qdel(query_datediff)
						return
					if(query_datediff.NextRow())
						account_age = text2num(query_datediff.item[1])
					qdel(query_datediff)
	qdel(query_get_client_age)
	if(!new_player)
		var/datum/DBQuery/query_log_player = SSdbcore.NewQuery("UPDATE [format_table_name("player")] SET lastseen = Now(), lastseen_round_id = '[GLOB.round_id]', ip = INET_ATON('[sql_ip]'), computerid = '[sql_computerid]', lastadminrank = '[sql_admin_rank]', accountjoindate = [account_join_date ? "'[account_join_date]'" : "NULL"] WHERE ckey = '[sql_ckey]'")
		if(!query_log_player.Execute())
			qdel(query_log_player)
			return
		qdel(query_log_player)
	if(!account_join_date)
		account_join_date = "Error"
	var/datum/DBQuery/query_log_connection = SSdbcore.NewQuery("INSERT INTO `[format_table_name("connection_log")]` (`id`,`datetime`,`server_ip`,`server_port`,`round_id`,`ckey`,`ip`,`computerid`) VALUES(null,Now(),INET_ATON(IF('[world.internet_address]' LIKE '', '0', '[world.internet_address]')),'[world.port]','[GLOB.round_id]','[sql_ckey]',INET_ATON('[sql_ip]'),'[sql_computerid]')")
	query_log_connection.Execute()
	qdel(query_log_connection)
	if(new_player)
		player_age = -1
	. = player_age


/client/proc/findJoinDate()
	var/list/http = world.Export("http://byond.com/members/[ckey]?format=text")
	if(!http)
		log_world("Failed to connect to byond member page to age check [ckey]")
		return
	var/F = file2text(http["CONTENT"])
	if(F)
		var/regex/R = regex("joined = \"(\\d{4}-\\d{2}-\\d{2})\"")
		if(R.Find(F))
			. = R.group[1]
		else
			CRASH("Age check regex failed for [src.ckey]")


/client/proc/validate_key_in_db()
	var/sql_ckey = sanitizeSQL(ckey)
	var/sql_key
	var/datum/DBQuery/query_check_byond_key = SSdbcore.NewQuery("SELECT byond_key FROM [format_table_name("player")] WHERE ckey = '[sql_ckey]'")
	if(!query_check_byond_key.Execute())
		qdel(query_check_byond_key)
		return
	if(query_check_byond_key.NextRow())
		sql_key = query_check_byond_key.item[1]
	qdel(query_check_byond_key)
	if(key != sql_key)
		var/list/http = world.Export("http://byond.com/members/[ckey]?format=text")
		if(!http)
			log_world("Failed to connect to byond member page to get changed key for [ckey]")
			return
		var/F = file2text(http["CONTENT"])
		if(F)
			var/regex/R = regex("\\tkey = \"(.+)\"")
			if(R.Find(F))
				var/web_key = sanitizeSQL(R.group[1])
				var/datum/DBQuery/query_update_byond_key = SSdbcore.NewQuery("UPDATE [format_table_name("player")] SET byond_key = '[web_key]' WHERE ckey = '[sql_ckey]'")
				query_update_byond_key.Execute()
				qdel(query_update_byond_key)
			else
				CRASH("Key check regex failed for [ckey]")


/client/proc/add_system_note(system_ckey, message)
	var/sql_system_ckey = sanitizeSQL(system_ckey)
	var/sql_ckey = sanitizeSQL(ckey)
	//check to see if we noted them in the last day.
	var/datum/DBQuery/query_get_notes = SSdbcore.NewQuery("SELECT id FROM [format_table_name("messages")] WHERE type = 'note' AND targetckey = '[sql_ckey]' AND adminckey = '[sql_system_ckey]' AND timestamp + INTERVAL 1 DAY < NOW() AND deleted = 0 AND (expire_timestamp > NOW() OR expire_timestamp IS NULL)")
	if(!query_get_notes.Execute())
		qdel(query_get_notes)
		return
	if(query_get_notes.NextRow())
		qdel(query_get_notes)
		return
	qdel(query_get_notes)
	//regardless of above, make sure their last note is not from us, as no point in repeating the same note over and over.
	query_get_notes = SSdbcore.NewQuery("SELECT adminckey FROM [format_table_name("messages")] WHERE targetckey = '[sql_ckey]' AND deleted = 0 AND (expire_timestamp > NOW() OR expire_timestamp IS NULL) ORDER BY timestamp DESC LIMIT 1")
	if(!query_get_notes.Execute())
		qdel(query_get_notes)
		return
	if(query_get_notes.NextRow())
		if (query_get_notes.item[1] == system_ckey)
			qdel(query_get_notes)
			return
	qdel(query_get_notes)
	create_message("note", key, system_ckey, message, null, null, 0, 0, null, 0, 0)


/client/proc/change_view(new_size)
	if(isnull(new_size))
		CRASH("change_view called without argument.")

	view = new_size
	apply_clickcatcher()
	mob.reload_fullscreens()


/client/proc/generate_clickcatcher()
	if(void)
		return
	void = new()
	screen += void


/client/proc/apply_clickcatcher()
	generate_clickcatcher()
	var/list/actualview = getviewsize(view)
	void.UpdateGreed(actualview[1], actualview[2])