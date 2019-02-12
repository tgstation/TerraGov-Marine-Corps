////////////////
//  SECURITY  //
////////////////
#define UPLOAD_LIMIT		1048576	//Restricts client uploads to the server to 1MB, could probably do with being lower.

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
		if(last_message_count >= SPAM_TRIGGER_WARNING)
			to_chat(src, "<span class='danger'>You are nearing the spam filter limit for identical messages.</span>")
			return TRUE
	else
		last_message = message
		last_message_count = 0
		return FALSE


//This stops files larger than UPLOAD_LIMIT being sent from client to server via input(), client.Import() etc.
/client/AllowUpload(filename, filelength)
	if(filelength > UPLOAD_LIMIT)
		to_chat(src, "<font color='red'>Error: AllowUpload(): File Upload too large. Upload Limit: [UPLOAD_LIMIT/1024]KiB.</font>")
		return FALSE
	return TRUE


///////////////
//  CONNECT  //
///////////////
GLOBAL_VAR_INIT(external_rsc_url, TRUE)


/client/New(TopicData)
	chatOutput = new /datum/chatOutput(src)
	TopicData = null							//Prevent calls to client.Topic from connect

	if(!(connection in list("seeker", "web")))					//Invalid connection type.
		return null

	if(!guests_allowed && IsGuestKey(key))
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
		if(check_rights(R_ADMIN, FALSE))
			message_admins("Admin login: [key_name_admin(src)].")
		else if(check_rights(R_MENTOR, FALSE))
			message_staff("Mentor login: [key_name_admin(src)].")
	else if(GLOB.deadmins[ckey])
		verbs += /client/proc/readmin

	//preferences datum - also holds some persistant data for the client (because we may as well keep these datums to a minimum)
	prefs = preferences_datums[ckey]
	if(!prefs || isnull(prefs) || !istype(prefs))
		prefs = new /datum/preferences(src)
		preferences_datums[ckey] = prefs
	prefs.last_ip = address				//these are gonna be used for banning
	prefs.last_id = computer_id			//these are gonna be used for banning


	. = ..()	//calls mob.Login()
	chatOutput.start() // Starts the chat

	if(byond_version >= 512)
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
	else
		to_chat(src, "<span class='userdanger'>Your version of byond is severely out of date.</span>")
		to_chat(src, "<span class='danger'>Please download a new version of byond. If [byond_build] is the latest, you can go to <a href=\"https://secure.byond.com/download/build\">BYOND's website</a> to download other versions.</span>")
		addtimer(CALLBACK(src, qdel(src), 2 SECONDS))
		return

	if(custom_event_msg && custom_event_msg != "")
		to_chat(src, "<h1 class='alert'>Custom Event</h1>")
		to_chat(src, "<h2 class='alert'>A custom event is taking place. OOC Info:</h2>")
		to_chat(src, "<span class='alert'>[custom_event_msg]</span>")
		to_chat(src, "<br>")

	if((world.address == address || !address) && !host)
		host = key
		world.update_status()

	preload_rsc = GLOB.external_rsc_url

	send_assets()
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



//////////////////
//  DISCONNECT  //
//////////////////
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


#undef UPLOAD_LIMIT