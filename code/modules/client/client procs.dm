	////////////
	//SECURITY//
	////////////
#define UPLOAD_LIMIT		10485760	//Restricts client uploads to the server to 10MB //Boosted this thing. What's the worst that can happen?
#define MIN_CLIENT_VERSION	0		//Just an ambiguously low version for now, I don't want to suddenly stop people playing.
									//I would just like the code ready should it ever need to be used.
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

	if(href_list["_src_"] == "chat") // Oh god the ping hrefs.
		return chatOutput.Topic(href, href_list)

	//search the href for script injection
	if(findtext(href,"<script", 1, 0))
		log_world("[key_name(usr)] attempted use of scripts within a topic call.")
		message_admins("[ADMIN_TPMONTY(usr)] attempted use of scripts within a topic call.")
		//del(usr)
		return
/*
	//Logs all hrefs, except chat pings
	if(!(href_list["_src_"] == "chat" && href_list["proc"] == "ping" && length(href_list) == 2))
		log_href("[src] (usr:[usr]\[[AREACOORD(usr)]\]) : [hsrc ? "[hsrc] " : ""][href]")*/


	//Logs all hrefs
	if(CONFIG_GET(flag/log_hrefs))
		log_href("[time2text(world.timeofday,"hh:mm")] [src] (usr:[usr]) || [hsrc ? "[hsrc] " : ""][href]")

	// Admin PM
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
		if ("openLink")
			src << link(href_list["link"])

	return ..()	//redirect to hsrc.Topic()

/client/proc/handle_spam_prevention(var/message, var/mute_type)
	if(CONFIG_GET(flag/automute_on) && !holder && src.last_message == message)
		src.last_message_count++
		if(src.last_message_count >= SPAM_TRIGGER_AUTOMUTE)
			to_chat(src, "<span class='warning'>You have exceeded the spam filter limit for identical messages. An auto-mute was applied.</span>")
			//cmd_admin_mute(src.mob, mute_type, 1)
			return 1
		if(src.last_message_count >= SPAM_TRIGGER_WARNING)
			to_chat(src, "<span class='warning'>You are nearing the spam filter limit for identical messages.</span>")
			return 0
	else
		last_message = message
		src.last_message_count = 0
		return 0

//This stops files larger than UPLOAD_LIMIT being sent from client to server via input(), client.Import() etc.
/client/AllowUpload(filename, filelength)
	if(filelength > UPLOAD_LIMIT)
		to_chat(src, "<font color='red'>Error: AllowUpload(): File Upload too large. Upload Limit: [UPLOAD_LIMIT/1024]KiB.</font>")
		return 0
/*	//Don't need this at the moment. But it's here if it's needed later.
	//Helps prevent multiple files being uploaded at once. Or right after eachother.
	var/time_to_wait = fileaccess_timer - world.time
	if(time_to_wait > 0)
		to_chat(src, "<font color='red'>Error: AllowUpload(): Spam prevention. Please wait [round(time_to_wait/10)] seconds.</font>")
		return 0
	fileaccess_timer = world.time + FTPDELAY	*/
	return 1


	///////////
	//CONNECT//
	///////////
/client/New(TopicData)
	chatOutput = new /datum/chatOutput(src)
	TopicData = null							//Prevent calls to client.Topic from connect

	if(!(connection in list("seeker", "web")))					//Invalid connection type.
		return null
	if(byond_version < MIN_CLIENT_VERSION)		//Out of date client.
		return null

	if(!guests_allowed && IsGuestKey(key))
		alert(src,"This server doesn't allow guest accounts to play. Please go to http://www.byond.com/ and register for a key.","Guest","OK")
		qdel(src)
		return

	preload_rsc = TRUE // If config.resource_urls is not set, preload like normal.

	to_chat(src, "<span class='warning'>If the title screen is black, resources are still downloading. Please be patient until the title screen appears.</span>")


	GLOB.clients += src
	GLOB.directory[ckey] = src

	if(CONFIG_GET(flag/localhost_rank))
		var/static/list/localhost_addresses = list("127.0.0.1", "::1")
		if(isnull(address) || (address in localhost_addresses))
			var/datum/admin_rank/rank = new("!localhost!", R_EVERYTHING, , R_EVERYTHING)
			var/datum/admins/admin = new(rank, ckey, TRUE)
			admin.associate(src)

	//preferences datum - also holds some persistant data for the client (because we may as well keep these datums to a minimum)
	prefs = preferences_datums[ckey]
	if(!prefs || isnull(prefs) || !istype(prefs))
		prefs = new /datum/preferences(src)
		preferences_datums[ckey] = prefs
	prefs.last_ip = address				//these are gonna be used for banning
	prefs.last_id = computer_id			//these are gonna be used for banning

	. = ..()	//calls mob.Login()
	chatOutput.start() // Starts the chat

	if(custom_event_msg && custom_event_msg != "")
		to_chat(src, "<h1 class='alert'>Custom Event</h1>")
		to_chat(src, "<h2 class='alert'>A custom event is taking place. OOC Info:</h2>")
		to_chat(src, "<span class='alert'>[custom_event_msg]</span>")
		to_chat(src, "<br>")

	if( (world.address == address || !address) && !host )
		host = key
		world.update_status()


	GLOB.ahelp_tickets.ClientLogin(src)
	holder = GLOB.admin_datums[ckey]
	if(holder)
		GLOB.admins |= src
		holder.owner = src
		holder.activate()
		if(check_rights(R_ADMIN, FALSE))
			message_admins("Admin login: [key_name_admin(src)].")
		else if(check_rights(R_MENTOR, FALSE))
			message_staff("Mentor login: [key_name_admin(src)].")
	else if(GLOB.deadmins[ckey])
		verbs += /client/proc/readmin

	log_client_to_db()

	send_resources()
	nanomanager.send_resources(src)

	create_clickcatcher()
	apply_clickcatcher()

	if(prefs.lastchangelog != GLOB.changelog_hash) //bolds the changelog button on the interface so we know there are updates.
		winset(src, "rpane.changelog", "background-color=#ED9F9B;font-style=bold")


	if(all_player_details[ckey])
		player_details = all_player_details[ckey]
	else
		player_details = new
		all_player_details[ckey] = player_details

	//////////////
	//DISCONNECT//
	//////////////
/client/Del()
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
	return ..()


/client/Destroy()
	return QDEL_HINT_HARDDEL_NOW


/client/proc/log_client_to_db()

	if ( IsGuestKey(src.key) )
		return

	establish_db_connection()
	if(!dbcon.IsConnected())
		return

	var/sql_ckey = sql_sanitize_text(src.ckey)

	var/DBQuery/query = dbcon.NewQuery("SELECT id, datediff(Now(),firstseen) as age FROM erro_player WHERE ckey = '[sql_ckey]'")
	query.Execute()
	var/sql_id = 0
	player_age = 0	// New players won't have an entry so knowing we have a connection we set this to zero to be updated if their is a record.
	while(query.NextRow())
		sql_id = query.item[1]
		player_age = text2num(query.item[2])
		break

	var/DBQuery/query_ip = dbcon.NewQuery("SELECT ckey FROM erro_player WHERE ip = '[address]'")
	query_ip.Execute()
	related_accounts_ip = ""
	while(query_ip.NextRow())
		related_accounts_ip += "[query_ip.item[1]], "
		break

	var/DBQuery/query_cid = dbcon.NewQuery("SELECT ckey FROM erro_player WHERE computerid = '[computer_id]'")
	query_cid.Execute()
	related_accounts_cid = ""
	while(query_cid.NextRow())
		related_accounts_cid += "[query_cid.item[1]], "
		break

	//Just the standard check to see if it's actually a number
	if(sql_id)
		if(istext(sql_id))
			sql_id = text2num(sql_id)
		if(!isnum(sql_id))
			return

	var/admin_rank = "Player"
	if(src.holder)
		admin_rank = src.holder.rank

	var/sql_ip = sql_sanitize_text(src.address)
	var/sql_computerid = sql_sanitize_text(src.computer_id)
	var/sql_admin_rank = sql_sanitize_text(admin_rank)


	if(sql_id)
		//Player already identified previously, we need to just update the 'lastseen', 'ip' and 'computer_id' variables
		var/DBQuery/query_update = dbcon.NewQuery("UPDATE erro_player SET lastseen = Now(), ip = '[sql_ip]', computerid = '[sql_computerid]', lastadminrank = '[sql_admin_rank]' WHERE id = [sql_id]")
		query_update.Execute()
	else
		//New player!! Need to insert all the stuff
		var/DBQuery/query_insert = dbcon.NewQuery("INSERT INTO erro_player (id, ckey, firstseen, lastseen, ip, computerid, lastadminrank) VALUES (null, '[sql_ckey]', Now(), Now(), '[sql_ip]', '[sql_computerid]', '[sql_admin_rank]')")
		query_insert.Execute()

	//Logging player access
	var/serverip = "[world.internet_address]:[world.port]"
	var/DBQuery/query_accesslog = dbcon.NewQuery("INSERT INTO `erro_connection_log`(`id`,`datetime`,`serverip`,`ckey`,`ip`,`computerid`) VALUES(null,Now(),'[serverip]','[sql_ckey]','[sql_ip]','[sql_computerid]');")
	query_accesslog.Execute()


#undef UPLOAD_LIMIT
#undef MIN_CLIENT_VERSION

//checks if a client is afk
//3000 frames = 5 minutes
/client/proc/is_afk(duration=3000)
	if(inactivity > duration)	return inactivity
	return 0

GLOBAL_LIST_EMPTY(external_rsc_url)
//send resources to the client. It's here in its own proc so we can move it around easiliy if need be
/client/proc/send_resources()
	if(!CONFIG_GET(string/resource_url))
		return
	preload_rsc = GLOB.external_rsc_url

//Hook, override it to run code when dir changes
//Like for /atoms, but clients are their own snowflake FUCK
/client/proc/setDir(newdir)
	dir = newdir

/client/proc/get_offset()
	return max(abs(pixel_x / 32), abs(pixel_y / 32))