#define UPLOAD_LIMIT 1000000	//Restricts client uploads to the server to 1MB
#define UPLOAD_LIMIT_ADMIN 10000000	//Restricts admin uploads to the server to 10MB


#define MIN_RECOMMENDED_CLIENT 1575
#define REQUIRED_CLIENT_MAJOR 514
#define REQUIRED_CLIENT_MINOR 1493

#define LIMITER_SIZE 5
#define CURRENT_SECOND 1
#define SECOND_COUNT 2
#define CURRENT_MINUTE 3
#define MINUTE_COUNT 4
#define ADMINSWARNED_AT 5
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
	*/

//the undocumented 4th argument is for ?[0x\ref] style topic links. hsrc is set to the reference and anything after the ] gets put into hsrc_command
/client/Topic(href, href_list, hsrc, hsrc_command)
	if(!usr || usr != mob) //stops us calling Topic for somebody else's client. Also helps prevent usr=null
		return

#ifndef TESTING
	if (lowertext(hsrc_command) == "_debug") //disable the integrated byond vv in the client side debugging tools since it doesn't respect vv read protections
		return
#endif

	//Asset cache
	var/asset_cache_job
	if(href_list["asset_cache_confirm_arrival"])
		asset_cache_job = asset_cache_confirm_arrival(href_list["asset_cache_confirm_arrival"])
		if (!asset_cache_job)
			return

	// Rate limiting
	var/mtl = CONFIG_GET(number/minute_topic_limit)
	if (!holder && mtl)
		var/minute = round(world.time, 600)
		if (!topiclimiter)
			topiclimiter = new(LIMITER_SIZE)
		if (minute != topiclimiter[CURRENT_MINUTE])
			topiclimiter[CURRENT_MINUTE] = minute
			topiclimiter[MINUTE_COUNT] = 0
		topiclimiter[MINUTE_COUNT] += 1
		if (topiclimiter[MINUTE_COUNT] > mtl)
			var/msg = "Your previous action was ignored because you've done too many in a minute."
			if (minute != topiclimiter[ADMINSWARNED_AT]) //only one admin message per-minute. (if they spam the admins can just boot/ban them)
				topiclimiter[ADMINSWARNED_AT] = minute
				msg += " Administrators have been informed."
				log_game("[key_name(src)] Has hit the per-minute topic limit of [mtl] topic calls in a given game minute")
				message_admins("[ADMIN_LOOKUPFLW(usr)] [ADMIN_KICK(usr)] Has hit the per-minute topic limit of [mtl] topic calls in a given game minute")
			to_chat(src, span_danger("[msg]"))
			return
	var/stl = CONFIG_GET(number/second_topic_limit)
	if (!holder && stl && href_list["window_id"] != "statbrowser")
		var/second = round(world.time, 10)
		if (!topiclimiter)
			topiclimiter = new(LIMITER_SIZE)
		if (second != topiclimiter[CURRENT_SECOND])
			topiclimiter[CURRENT_SECOND] = second
			topiclimiter[SECOND_COUNT] = 0
		topiclimiter[SECOND_COUNT] += 1
		if (topiclimiter[SECOND_COUNT] > stl)
			to_chat(src, span_danger("Your previous action was ignored because you've done too many in a second"))
			return

	if(tgui_Topic(href_list))
		return
	if(href_list["reload_tguipanel"])
		nuke_chat()
	if(href_list["reload_statbrowser"])
		stat_panel.reinitialize()

	//Logs all hrefs.
	log_href("[src] (usr:[usr]\[[COORD(usr)]\]) : [hsrc ? "[hsrc] " : ""][href]")

	//byond bug ID:2256651
	if (asset_cache_job && (asset_cache_job in completed_asset_jobs))
		to_chat(src, span_danger("An error has been detected in how your client is receiving resources. Attempting to correct.... (If you keep seeing these messages you might want to close byond and reconnect)"))
		src << browse("...", "window=asset_cache_browser")
		return
	if (href_list["asset_cache_preload_data"])
		asset_cache_preload_data(href_list["asset_cache_preload_data"])
		return


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
			stack_trace("This code path is no longer valid, migrate this to new TGUI prefs")
		if("vars")
			return view_var_Topic(href, href_list, hsrc)
		if("vote")
			return SSvote.Topic(href, href_list)
		if("codex")
			return SScodex.Topic(href, href_list)

	switch(href_list["action"])
		if("openLink")
			DIRECT_OUTPUT(src, link(href_list["link"]))

	if(hsrc)
		var/datum/real_src = hsrc
		if(QDELETED(real_src))
			return

	#ifdef NULL_CLIENT_BUG_CHECK
	if(QDELETED(usr))
		return
	#endif

	return ..()	//redirect to hsrc.Topic()


/client/New(TopicData)
	var/tdata = TopicData //save this for later use
	TopicData = null	//Prevent calls to client.Topic from connect

	if(connection != "seeker" && connection != "web")	//Invalid connection type.
		return null

	GLOB.clients += src
	GLOB.directory[ckey] = src

	//On creation of a client, add an entry into the GLOB list of the client with their stats
	GLOB.personal_statistics_list[ckey] = new /datum/personal_statistics

	// Instantiate stat panel
	stat_panel = new(src, "statbrowser")
	stat_panel.subscribe(src, PROC_REF(on_stat_panel_message))

	// Instantiate tgui panel
	tgui_panel = new(src, "browseroutput")

	tgui_say = new(src, "tgui_say")

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
		add_verb(src, /client/proc/readmin)

	//preferences datum - also holds some persistant data for the client (because we may as well keep these datums to a minimum)
	prefs = GLOB.preferences_datums[ckey]
	if(!prefs || isnull(prefs) || !istype(prefs))
		prefs = new /datum/preferences(src)
		GLOB.preferences_datums[ckey] = prefs
	prefs.parent = src
	prefs.last_ip = address				//these are gonna be used for banning
	prefs.last_id = computer_id			//these are gonna be used for banning
	fps = prefs.clientfps

	var/full_version = "[byond_version].[byond_build ? byond_build : "xxx"]"
	log_access("Login: [key_name(src)] from [address ? address : "localhost"]-[computer_id] || BYOND v[full_version]")

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
						message_admins(span_danger("<B>Notice: </B></span><span class='notice'>[key_name_admin(src)] has the same [matches] as [key_name_admin(C)]."))
						log_access("Notice: [key_name(src)] has the same [matches] as [key_name(C)].")
					else
						message_admins(span_danger("<B>Notice: </B></span><span class='notice'>[key_name_admin(src)] has the same [matches] as [key_name_admin(C)] (no longer logged in). "))
						log_access("Notice: [key_name(src)] has the same [matches] as [key_name(C)] (no longer logged in).")

	if(GLOB.player_details[ckey])
		player_details = GLOB.player_details[ckey]
		player_details.byond_version = full_version
	else
		player_details = new
		player_details.byond_version = full_version
		GLOB.player_details[ckey] = player_details

	. = ..()	//calls mob.Login()
	if(length(GLOB.stickybanadminexemptions))
		GLOB.stickybanadminexemptions -= ckey
		if (!length(GLOB.stickybanadminexemptions))
			restore_stickybans()

	if(SSinput.initialized)
		set_macros()

	// Initialize tgui panel
	tgui_panel.initialize()

	tgui_say.initialize()

	// Initialize stat panel
	stat_panel.initialize(
		inline_html = file("html/statbrowser.html"),
		inline_js = file("html/statbrowser.js"),
		inline_css = file("html/statbrowser.css"),
	)
	addtimer(CALLBACK(src, PROC_REF(check_panel_loaded)), 30 SECONDS)

	if(byond_version < REQUIRED_CLIENT_MAJOR || (byond_build && byond_build < REQUIRED_CLIENT_MINOR))
		//to_chat(src, span_userdanger("Your version of byond is severely out of date."))
		to_chat(src, span_userdanger("TGMC now requires the first stable [REQUIRED_CLIENT_MAJOR] build, please update your client to [REQUIRED_CLIENT_MAJOR].[MIN_RECOMMENDED_CLIENT]."))
		to_chat(src, span_danger("Please download a new version of byond. If [byond_build] is the latest, you can go to <a href=\"https://secure.byond.com/download/build\">BYOND's website</a> to download other versions."))
		addtimer(CALLBACK(src, qdel(src), 2 SECONDS))
		return

	if(!byond_build || byond_build < 1386)
		message_admins("[key_name(src)] has been detected as spoofing their byond version. Connection rejected.")
		log_access("Failed Login: [key] - Spoofed byond version")
		qdel(src)
		return

	if(byond_build < MIN_RECOMMENDED_CLIENT)
		to_chat(src, span_userdanger("Your version of byond has known client crash issues, it's recommended you update your version."))
		to_chat(src, span_danger("Please download a new version of byond. You can go to <a href=\"https://secure.byond.com/download/build\">BYOND's website</a> to download 514.[MIN_RECOMMENDED_CLIENT]."))

	if(byond_build < 1555)
		to_chat(src, span_userdanger("Your version of byond might have rendering lag issues, it is recommended you update your version to above Byond version 1555 if you encounter them."))
		to_chat(src, span_danger("You can go to <a href=\"https://secure.byond.com/download/build\">BYOND's website</a> to download other versions."))

	if(num2text(byond_build) in GLOB.blacklisted_builds)
		log_access("Failed login: [key] - blacklisted byond version")
		to_chat(src, span_userdanger("Your version of byond is blacklisted."))
		to_chat(src, span_danger("Byond build [byond_build] ([byond_version].[byond_build]) has been blacklisted for the following reason: [GLOB.blacklisted_builds[num2text(byond_build)]]."))
		to_chat(src, span_danger("Please download a new version of byond. If [byond_build] is the latest, you can go to <a href=\"https://secure.byond.com/download/build\">BYOND's website</a> to download other versions."))
		addtimer(CALLBACK(src, qdel(src), 2 SECONDS))
		return

	if(GLOB.custom_info)
		to_chat(src, "<h1 class='alert'>Custom Information</h1>")
		to_chat(src, "<h2 class='alert'>The following custom information has been set for this round:</h2>")
		to_chat(src, span_alert("[GLOB.custom_info]"))
		to_chat(src, "<br>")

	connection_time = world.time
	connection_realtime = world.realtime
	connection_timeofday = world.timeofday

	winset(src, null, "command=\".configure graphics-hwmode on\"")

	var/cached_player_age = set_client_age_from_db(tdata) //we have to cache this because other shit may change it and we need it's current value now down below.
	if(isnum(cached_player_age) && cached_player_age == -1) //first connection
		player_age = 0
	var/nnpa = CONFIG_GET(number/notify_new_player_age)
	if(isnum(cached_player_age) && cached_player_age == -1) //first connection
		if(nnpa >= 0)
			message_admins("New user: [key_name_admin(src)] is connecting here for the first time.")
	else if(isnum(cached_player_age) && cached_player_age < nnpa)
		message_admins("New user: [key_name_admin(src)] just connected with a DB saved age of [cached_player_age] day[(player_age == 1 ? "" : "s")]")
	if(CONFIG_GET(flag/use_account_age_for_jobs) && account_age >= 0)
		player_age = account_age
	if(account_age >= 0 && account_age < CONFIG_GET(number/notify_new_account_age))
		message_admins("[key_name_admin(src)] (IP: [address], ID: [computer_id]) is a new BYOND account [account_age] day[(account_age == 1 ? "" : "s")] old, created on [account_join_date].")


	get_message_output("watchlist entry", ckey)
	validate_key_in_db()

	send_resources()

	generate_clickcatcher()
	apply_clickcatcher()

	if(prefs.lastchangelog != GLOB.changelog_hash) //bolds the changelog button on the interface so we know there are updates.
		to_chat(src, span_info("You have unread updates in the changelog."))
		if(CONFIG_GET(flag/aggressive_changelog))
			changes()
		else
			winset(src, "infowindow.changelog", "font-style=bold")

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

	var/list/topmenus = GLOB.menulist[/datum/verbs/menu]
	for(var/thing in topmenus)
		var/datum/verbs/menu/topmenu = thing
		var/topmenuname = "[topmenu]"
		if(topmenuname == "[topmenu.type]")
			var/list/tree = splittext(topmenuname, "/")
			topmenuname = tree[length(tree)]
		winset(src, "[topmenu.type]", "parent=menu;name=[url_encode(topmenuname)]")
		var/list/entries = topmenu.Generate_list(src)
		for(var/child in entries)
			winset(src, "[child]", "[entries[child]]")
			if(!ispath(child, /datum/verbs/menu))
				var/procpath/verbpath = child
				if(verbpath.name[1] != "@")
					new child(src)

	for(var/thing in prefs.menuoptions)
		var/datum/verbs/menu/menuitem = GLOB.menulist[thing]
		if(menuitem)
			menuitem.Load_checked(src)


	update_ambience_pref()

	//This is down here because of the browse() calls in tooltip/New()
	if(!tooltips && prefs.tooltips)
		tooltips = new /datum/tooltip(src)

	view_size = new(src, get_screen_size(prefs.widescreenpref))
	view_size.update_pixel_format()
	view_size.update_zoom_mode()

	set_fullscreen(prefs.fullscreen_mode)

	winset(src, null, "mainwindow.title='[CONFIG_GET(string/title)]'")

	Master.UpdateTickRate()



//////////////////
//  DISCONNECT  //
//////////////////
/client/Del()
	if(!gc_destroyed)
		gc_destroyed = world.time
		if (!QDELING(src))
			stack_trace("Client does not purport to be QDELING, this is going to cause bugs in other places!")

		// Yes this is the same as what's found in qdel(). Yes it does need to be here
		// Get off my back
		SEND_SIGNAL(src, COMSIG_QDELETING, TRUE)
		Destroy()
	return ..()


/client/Destroy()
	SEND_SIGNAL(src, COMSIG_CLIENT_DISCONNECTED)
	log_access("Logout: [key_name(src)]")
	if(obj_window)
		QDEL_NULL(obj_window)
	if(holder)
		if(check_rights(R_ADMIN, FALSE))
			message_admins("Admin logout: [key_name(src)].")
		else if(check_rights(R_MENTOR, FALSE))
			message_staff("Mentor logout: [key_name(src)].")
		holder.owner = null
		GLOB.admins -= src
		if (!length(GLOB.admins) && SSticker.IsRoundInProgress()) //Only report this stuff if we are currently playing.
			var/cheesy_message = pick(
				"I have no admins online!",\
				"I'm all alone :(",\
				"I'm feeling lonely :(",\
				"I'm so lonely :(",\
				"Why does nobody love me? :(",\
				"I want a man :(",\
				"Where has everyone gone?",\
				"I need a hug :(",\
				"Someone come hold me :(",\
				"I need someone on me :(",\
				"What happened? Where has everyone gone?",\
				"Forever alone :("\
			)
			send2adminchat("Server", "[cheesy_message] (No staff online)")
	if(mob)
		mob.become_uncliented()
	GLOB.ahelp_tickets.ClientLogout(src)
	GLOB.directory -= ckey
	GLOB.clients -= src
	seen_messages = null
	QDEL_LIST_ASSOC_VAL(char_render_holders)
	SSping.currentrun -= src
	QDEL_NULL(tooltips)
	Master.UpdateTickRate()
	SSambience.ambience_listening_clients -= src
	..() //Even though we're going to be hard deleted there are still some things like signals that want to know the destroy is happening
	return QDEL_HINT_HARDDEL_NOW

/client/Click(atom/object, atom/location, control, params)
	if(click_intercepted)
		if(click_intercepted >= world.time)
			click_intercepted = 0 //Reset and return. Next click should work, but not this one.
			return
		click_intercepted = 0 //Just reset. Let's not keep re-checking forever.
	var/ab = FALSE
	var/list/modifiers = params2list(params)

	var/button_clicked = LAZYACCESS(modifiers, "button")

	var/dragged = LAZYACCESS(modifiers, "drag")
	if(dragged && button_clicked != dragged)
		return

	if(object && object == middragatom && button_clicked == "left")
		ab = max(0, 5 SECONDS - (world.time - middragtime) * 0.1)

	var/mcl = CONFIG_GET(number/minute_click_limit)
	if(mcl && !check_rights(R_ADMIN, FALSE))
		var/minute = round(world.time, 600)
		if(!clicklimiter)
			clicklimiter = new(LIMITER_SIZE)
		if(minute != clicklimiter[CURRENT_MINUTE])
			clicklimiter[CURRENT_MINUTE] = minute
			clicklimiter[MINUTE_COUNT] = 0
		clicklimiter[MINUTE_COUNT] += 1+(ab)
		if(clicklimiter[MINUTE_COUNT] > mcl)
			var/msg = "Your previous click was ignored because you've done too many in a minute."
			if(minute != clicklimiter[ADMINSWARNED_AT]) //only one admin message per-minute. (if they spam the admins can just boot/ban them)
				clicklimiter[ADMINSWARNED_AT] = minute
				log_admin_private("[key_name(src)] has hit the per-minute click limit of [mcl].")
				message_admins("[ADMIN_TPMONTY(mob)] has hit the per-minute click limit of [mcl].")
				if(ab)
					log_admin_private("[key_name(src)] is likely using the middle click aimbot exploit.")
					message_admins("[ADMIN_TPMONTY(mob)] is likely using the middle click aimbot exploit.")
			to_chat(src, span_danger("[msg]"))
			return

	var/scl = CONFIG_GET(number/second_click_limit)
	if(scl && !check_rights(R_ADMIN, FALSE))
		var/second = round(world.time, 10)
		if(!clicklimiter)
			clicklimiter = new(LIMITER_SIZE)
		if(second != clicklimiter[CURRENT_SECOND])
			clicklimiter[CURRENT_SECOND] = second
			clicklimiter[SECOND_COUNT] = 0
		clicklimiter[SECOND_COUNT] += 1+(!!ab)
		if(clicklimiter[SECOND_COUNT] > scl)
			to_chat(src, span_danger("Your previous click was ignored because you've done too many in a second"))
			return

	return ..()

//checks if a client is afk
//3000 frames = 5 minutes
/client/proc/is_afk(duration = 5 MINUTES)
	if(inactivity > duration)
		return inactivity
	return FALSE


/// Send resources to the client. Sends both game resources and browser assets.
/client/proc/send_resources()
#if (PRELOAD_RSC == 0)
	var/static/next_external_rsc = 0
	var/list/external_rsc_urls = CONFIG_GET(keyed_list/external_rsc_urls)
	if(length(external_rsc_urls))
		next_external_rsc = WRAP(next_external_rsc+1, 1, length(external_rsc_urls) + 1)
		preload_rsc = external_rsc_urls[next_external_rsc]
#endif

	spawn (10) //removing this spawn causes all clients to not get verbs.

		//load info on what assets the client has
		src << browse('code/modules/asset_cache/validate_assets.html', "window=asset_cache_browser")

		//Precache the client with all other assets slowly, so as to not block other browse() calls
		if (CONFIG_GET(flag/asset_simple_preload))
			addtimer(CALLBACK(SSassets.transport, TYPE_PROC_REF(/datum/asset_transport, send_assets_slow), src, SSassets.transport.preload), 5 SECONDS)

		#if (PRELOAD_RSC == 0)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/client, preload_vox)), 1 MINUTES)
		#endif

#if (PRELOAD_RSC == 0)
/client/proc/preload_vox()
	for (var/name in GLOB.vox_sounds)
		var/file = GLOB.vox_sounds[name]
		Export("##action=load_rsc", file)
		stoplag()
#endif

//Hook, override it to run code when dir changes
//Like for /atoms, but clients are their own snowflake FUCK
/client/proc/setDir(newdir)
	dir = newdir


/client/proc/show_character_previews(mutable_appearance/MA)
	var/pos = 0
	for(var/D in GLOB.cardinals)
		pos++
		var/atom/movable/screen/O = LAZYACCESS(char_render_holders, "[D]")
		if(!O)
			O = new
			LAZYSET(char_render_holders, "[D]", O)
			screen |= O
		O.appearance = MA
		O.dir = D
		O.screen_loc = "player_pref_map:[pos],1"


/client/proc/clear_character_previews()
	for(var/index in char_render_holders)
		var/atom/movable/screen/S = char_render_holders[index]
		screen -= S
		qdel(S)
	char_render_holders = null


/client/proc/set_client_age_from_db(connectiontopic)
	if(IsGuestKey(key))
		return
	if(!SSdbcore.Connect())
		return
	var/datum/db_query/query_get_related_ip = SSdbcore.NewQuery(
		"SELECT ckey FROM [format_table_name("player")] WHERE ip = INET_ATON(:address) AND ckey != :ckey",
		list("address" = address, "ckey" = ckey)
	)
	if(!query_get_related_ip.Execute())
		qdel(query_get_related_ip)
		return
	related_accounts_ip = ""
	while(query_get_related_ip.NextRow())
		related_accounts_ip += "[query_get_related_ip.item[1]], "
	qdel(query_get_related_ip)
	var/datum/db_query/query_get_related_cid = SSdbcore.NewQuery(
		"SELECT ckey FROM [format_table_name("player")] WHERE computerid = :computerid AND ckey != :ckey",
		list("computerid" = computer_id, "ckey" = ckey)
	)
	if(!query_get_related_cid.Execute())
		qdel(query_get_related_cid)
		return
	related_accounts_cid = ""
	while (query_get_related_cid.NextRow())
		related_accounts_cid += "[query_get_related_cid.item[1]], "
	qdel(query_get_related_cid)
	var/admin_rank = "Player"
	if (holder?.rank)
		admin_rank = holder.rank.name
	else
		if (!GLOB.deadmins[ckey] && check_randomizer(connectiontopic))
			return
	var/new_player
	var/datum/db_query/query_client_in_db = SSdbcore.NewQuery(
		"SELECT 1 FROM [format_table_name("player")] WHERE ckey = :ckey",
		list("ckey" = ckey)
	)
	if(!query_client_in_db.Execute())
		qdel(query_client_in_db)
		return
	var/client_is_in_db = query_client_in_db.NextRow()
	//If we aren't an admin, and the flag is set
	if(CONFIG_GET(flag/panic_bunker) && !holder && !GLOB.deadmins[ckey])
		var/living_recs = CONFIG_GET(number/panic_bunker_living)
		//Relies on pref existing, but this proc is only called after that occurs, so we're fine.
		var/minutes = get_exp_living(pure_numeric = TRUE)
		if((minutes < living_recs) || (!living_recs && !client_is_in_db))
			var/reject_message = "Failed Login: [key] - [client_is_in_db ? "":"New "]Account attempting to connect during panic bunker, but\
			[living_recs ? "they do not have the required living time [minutes]/[living_recs]": "was rejected"]"
			log_access(reject_message)
			message_admins(span_adminnotice("[reject_message]"))
			var/message = CONFIG_GET(string/panic_bunker_message)
			message = replacetext(message, "%minutes%", living_recs)
			to_chat(src, message)
			var/list/connectiontopic_a = params2list(connectiontopic)
			var/list/panic_addr = CONFIG_GET(string/panic_server_address)
			if(panic_addr && !connectiontopic_a["redirect"])
				var/panic_name = CONFIG_GET(string/panic_server_name)
				to_chat(src, span_notice("Sending you to [panic_name ? panic_name : panic_addr]."))
				winset(src, null, "command=.options")
				src << link("[panic_addr]?redirect=1")
			qdel(query_client_in_db)
			qdel(src)
			return

	if(!client_is_in_db)
		new_player = 1
		account_join_date = findJoinDate()
		var/datum/db_query/query_add_player = SSdbcore.NewQuery({"
			INSERT INTO [format_table_name("player")] (`ckey`, `byond_key`, `firstseen`, `firstseen_round_id`, `lastseen`, `lastseen_round_id`, `ip`, `computerid`, `lastadminrank`, `accountjoindate`)
			VALUES (:ckey, :key, Now(), :round_id, Now(), :round_id, INET_ATON(:ip), :computerid, :adminrank, :account_join_date)
		"}, list("ckey" = ckey, "key" = key, "round_id" = GLOB.round_id, "ip" = address, "computerid" = computer_id, "adminrank" = admin_rank, "account_join_date" = account_join_date || null))
		if(!query_add_player.Execute())
			qdel(query_client_in_db)
			qdel(query_add_player)
			return
		qdel(query_add_player)
		if(!account_join_date)
			account_join_date = "Error"
			account_age = -1
	qdel(query_client_in_db)
	var/datum/db_query/query_get_client_age = SSdbcore.NewQuery(
		"SELECT firstseen, DATEDIFF(Now(),firstseen), accountjoindate, DATEDIFF(Now(),accountjoindate) FROM [format_table_name("player")] WHERE ckey = :ckey",
		list("ckey" = ckey)
	)
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
				account_join_date = findJoinDate()
				if(!account_join_date)
					account_age = -1
				else
					var/datum/db_query/query_datediff = SSdbcore.NewQuery(
						"SELECT DATEDIFF(Now(), :account_join_date)",
						list("account_join_date" = account_join_date)
					)
					if(!query_datediff.Execute())
						qdel(query_datediff)
						return
					if(query_datediff.NextRow())
						account_age = text2num(query_datediff.item[1])
					qdel(query_datediff)
	qdel(query_get_client_age)
	if(!new_player)
		var/datum/db_query/query_log_player = SSdbcore.NewQuery(
			"UPDATE [format_table_name("player")] SET lastseen = Now(), lastseen_round_id = :round_id, ip = INET_ATON(:ip), computerid = :computerid, lastadminrank = :admin_rank, accountjoindate = :account_join_date WHERE ckey = :ckey",
			list("round_id" = GLOB.round_id, "ip" = address, "computerid" = computer_id, "admin_rank" = admin_rank, "account_join_date" = account_join_date || null, "ckey" = ckey)
		)
		if(!query_log_player.Execute())
			qdel(query_log_player)
			return
		qdel(query_log_player)
	if(!account_join_date)
		account_join_date = "Error"
	var/datum/db_query/query_log_connection = SSdbcore.NewQuery({"
		INSERT INTO `[format_table_name("connection_log")]` (`id`,`datetime`,`server_ip`,`server_port`,`round_id`,`ckey`,`ip`,`computerid`)
		VALUES(null,Now(),INET_ATON(:internet_address),:port,:round_id,:ckey,INET_ATON(:ip),:computerid)
	"}, list("internet_address" = world.internet_address || "0", "port" = world.port, "round_id" = GLOB.round_id, "ckey" = ckey, "ip" = address, "computerid" = computer_id))
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
	var/sql_key
	var/datum/db_query/query_check_byond_key = SSdbcore.NewQuery(
		"SELECT byond_key FROM [format_table_name("player")] WHERE ckey = :ckey",
		list("ckey" = ckey)
	)
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
				var/web_key = R.group[1]
				var/datum/db_query/query_update_byond_key = SSdbcore.NewQuery(
					"UPDATE [format_table_name("player")] SET byond_key = :byond_key WHERE ckey = :ckey",
					list("byond_key" = web_key, "ckey" = ckey)
				)
				query_update_byond_key.Execute()
				qdel(query_update_byond_key)
			else
				CRASH("Key check regex failed for [ckey]")

/client/proc/check_randomizer(topic)
	. = FALSE
	if (connection != "seeker")
		return
	topic = params2list(topic)
	if (!CONFIG_GET(flag/check_randomizer))
		return
	var/static/cidcheck = list()
	var/static/tokens = list()
	var/static/cidcheck_failedckeys = list() //to avoid spamming the admins if the same guy keeps trying.
	var/static/cidcheck_spoofckeys = list()
	var/datum/db_query/query_cidcheck = SSdbcore.NewQuery(
		"SELECT computerid FROM [format_table_name("player")] WHERE ckey = :ckey",
		list("ckey" = ckey)
	)
	query_cidcheck.Execute()

	var/lastcid
	if (query_cidcheck.NextRow())
		lastcid = query_cidcheck.item[1]
	qdel(query_cidcheck)
	var/oldcid = cidcheck[ckey]

	if (oldcid)
		if (!topic || !topic["token"] || !tokens[ckey] || topic["token"] != tokens[ckey])
			if (!cidcheck_spoofckeys[ckey])
				message_admins(span_adminnotice("[key_name(src)] appears to have attempted to spoof a cid randomizer check."))
				cidcheck_spoofckeys[ckey] = TRUE
			cidcheck[ckey] = computer_id
			tokens[ckey] = cid_check_reconnect()

			sleep(15 SECONDS) //Longer sleep here since this would trigger if a client tries to reconnect manually because the inital reconnect failed

			//we sleep after telling the client to reconnect, so if we still exist something is up
			log_access("Forced disconnect: [key] [computer_id] [address] - CID randomizer check")

			qdel(src)
			return TRUE

		if (oldcid != computer_id && computer_id != lastcid) //IT CHANGED!!!
			cidcheck -= ckey //so they can try again after removing the cid randomizer.

			to_chat(src, span_userdanger("Connection Error:"))
			to_chat(src, span_danger("Invalid ComputerID(spoofed). Please remove the ComputerID spoofer from your byond installation and try again."))

			if (!cidcheck_failedckeys[ckey])
				message_admins(span_adminnotice("[key_name(src)] has been detected as using a cid randomizer. Connection rejected."))
				send2tgs_adminless_only("CidRandomizer", "[key_name(src)] has been detected as using a cid randomizer. Connection rejected.")
				cidcheck_failedckeys[ckey] = TRUE
				note_randomizer_user()

			log_access("Failed Login: [key] [computer_id] [address] - CID randomizer confirmed (oldcid: [oldcid])")

			qdel(src)
			return TRUE
		else
			if (cidcheck_failedckeys[ckey])
				message_admins(span_adminnotice("[key_name_admin(src)] has been allowed to connect after showing they removed their cid randomizer"))
				send2tgs_adminless_only("CidRandomizer", "[key_name(src)] has been allowed to connect after showing they removed their cid randomizer.")
				cidcheck_failedckeys -= ckey
			if (cidcheck_spoofckeys[ckey])
				message_admins(span_adminnotice("[key_name_admin(src)] has been allowed to connect after appearing to have attempted to spoof a cid randomizer check because it <i>appears</i> they aren't spoofing one this time"))
				cidcheck_spoofckeys -= ckey
			cidcheck -= ckey
	else if (computer_id != lastcid)
		cidcheck[ckey] = computer_id
		tokens[ckey] = cid_check_reconnect()

		sleep(5 SECONDS) //browse is queued, we don't want them to disconnect before getting the browse() command.

		//we sleep after telling the client to reconnect, so if we still exist something is up
		log_access("Forced disconnect: [key] [computer_id] [address] - CID randomizer check")

		qdel(src)
		return TRUE

/client/proc/cid_check_reconnect()
	var/token = md5("[rand(0,9999)][world.time][rand(0,9999)][ckey][rand(0,9999)][address][rand(0,9999)][computer_id][rand(0,9999)]")
	. = token
	log_access("Failed Login: [key] [computer_id] [address] - CID randomizer check")
	var/url = winget(src, null, "url")
	//special javascript to make them reconnect under a new window.
	src << browse({"<a id='link' href="byond://[url]?token=[token]">byond://[url]?token=[token]</a><script type="text/javascript">document.getElementById("link").click();window.location="byond://winset?command=.quit"</script>"}, "border=0;titlebar=0;size=1x1;window=redirect")
	to_chat(src, {"<a href="byond://[url]?token=[token]">You will be automatically taken to the game, if not, click here to be taken manually</a>"})

/client/proc/note_randomizer_user()
	create_message("note", ckey(key), "SYSTEM", "Triggered automatic CID randomizer detection.", null, null, FALSE, FALSE, null, FALSE, "High")

/client/proc/rescale_view(change, min, max)
	view_size.set_view_radius_to(clamp(change, min, max), clamp(change, min, max))

/**
 * Updates the keybinds for special keys
 *
 * Handles adding macros for the keys that need it
 * And adding movement keys to the clients movement_keys list
 * At the time of writing this, communication(OOC, Say, IC, ASAY, MSAY) require macros
 * Arguments:
 * * direct_prefs - the preference we're going to get keybinds from
 */
/client/proc/update_special_keybinds(datum/preferences/direct_prefs)
	var/datum/preferences/D = prefs || direct_prefs
	if(!D?.key_bindings)
		return
	movement_keys = list()
	for(var/key in D.key_bindings)
		for(var/kb_name in D.key_bindings[key])
			switch(kb_name)
				if("North")
					movement_keys[key] = NORTH
				if("East")
					movement_keys[key] = EAST
				if("West")
					movement_keys[key] = WEST
				if("South")
					movement_keys[key] = SOUTH
				if(SAY_CHANNEL)
					var/say = tgui_say_create_open_command(SAY_CHANNEL)
					winset(src, "default-[REF(key)]", "parent=default;name=[key];command=[say]")
				if(RADIO_CHANNEL)
					var/radio = tgui_say_create_open_command(RADIO_CHANNEL)
					winset(src, "default-[REF(key)]", "parent=default;name=[key];command=[radio]")
				if(ME_CHANNEL)
					var/me = tgui_say_create_open_command(ME_CHANNEL)
					winset(src, "default-[REF(key)]", "parent=default;name=[key];command=[me]")
				if(OOC_CHANNEL)
					var/ooc = tgui_say_create_open_command(OOC_CHANNEL)
					winset(src, "default-[REF(key)]", "parent=default;name=[key];command=[ooc]")
				if(LOOC_CHANNEL)
					var/looc = tgui_say_create_open_command(LOOC_CHANNEL)
					winset(src, "default-[REF(key)]", "parent=default;name=[key];command=[looc]")
				if(MOOC_CHANNEL)
					var/mooc = tgui_say_create_open_command(MOOC_CHANNEL)
					winset(src, "default-[REF(key)]", "parent=default;name=[key];command=[mooc]")
				if(XOOC_CHANNEL)
					var/xooc = tgui_say_create_open_command(XOOC_CHANNEL)
					winset(src, "default-[REF(key)]", "parent=default;name=[key];command=[xooc]")
				if(ADMIN_CHANNEL)
					if(holder)
						var/asay = tgui_say_create_open_command(ADMIN_CHANNEL)
						winset(src, "default-[REF(key)]", "parent=default;name=[key];command=[asay]")
					else
						winset(src, "default-[REF(key)]", "parent=default;name=[key];command=")
				if(MENTOR_CHANNEL)
					if(holder)
						var/msay = tgui_say_create_open_command(MENTOR_CHANNEL)
						winset(src, "default-[REF(key)]", "parent=default;name=[key];command=[msay]")
					else
						winset(src, "default-[REF(key)]", "parent=default;name=[key];command=")

/client/proc/change_view(new_size)
	if(isnull(new_size))
		CRASH("change_view called without argument.")
	if(isnum(new_size))
		CRASH("change_view called with a number argument. Use the string format instead.")

	if(prefs && !prefs.widescreenpref && new_size == CONFIG_GET(string/default_view))
		new_size = CONFIG_GET(string/default_view_square)

	view = new_size
	apply_clickcatcher()
	mob.reload_fullscreens()
	if(prefs.auto_fit_viewport)
		INVOKE_NEXT_TICK(src, VERB_REF(fit_viewport), 1 SECONDS) //Delayed to avoid wingets from Login calls.

///Change the fullscreen setting of the client
/client/proc/set_fullscreen(fullscreen_mode)
	if(fullscreen_mode)
		winset(src, "mainwindow", "is-maximized=false;can-resize=false;titlebar=false")
		winset(src, "mainwindow", "menu=null;statusbar=false")
		winset(src, "mainwindow.split", "pos=0x0")
		winset(src, "mainwindow", "is-maximized=true")
		return
	winset(src, "mainwindow", "is-maximized=false;can-resize=true;titlebar=true")
	winset(src, "mainwindow", "menu=menu;statusbar=true")
	winset(src, "mainwindow.split", "pos=3x0")
	winset(src, "mainwindow", "is-maximized=true")


/client/proc/generate_clickcatcher()
	if(void)
		return
	void = new()
	screen += void


/client/proc/apply_clickcatcher()
	generate_clickcatcher()
	var/list/actualview = getviewsize(view)
	void.UpdateGreed(actualview[1], actualview[2])


//This stops files larger than UPLOAD_LIMIT being sent from client to server via input(), client.Import() etc.
/client/AllowUpload(filename, filelength)
	if(holder)
		if(filelength > UPLOAD_LIMIT_ADMIN)
			to_chat(src, "<font color='red'>Error: AllowUpload(): File Upload too large. Upload Limit: [UPLOAD_LIMIT_ADMIN/1024]KiB.</font>")
			return FALSE
	else if(filelength > UPLOAD_LIMIT)
		to_chat(src, "<font color='red'>Error: AllowUpload(): File Upload too large. Upload Limit: [UPLOAD_LIMIT/1024]KiB.</font>")
		return FALSE
	return TRUE

GLOBAL_VAR_INIT(automute_on, null)
/client/proc/handle_spam_prevention(message, mute_type, special_message_flag)
	//Performance
	if(isnull(GLOB.automute_on))
		GLOB.automute_on = CONFIG_GET(flag/automute_on)

	if((special_message_flag & MESSAGE_FLAG_MENTOR) && check_rights(R_MENTOR, FALSE))
		return //Please stop muting me in my own responses.

	if((special_message_flag & MESSAGE_FLAG_ADMIN) && check_rights(R_ADMIN, FALSE))
		return //Technically not needed due to admin bypasses later in this proc, but I'll throw it in if for some reason someone changes their immunity.

	total_message_count += 1

	var/weight = SPAM_TRIGGER_WEIGHT_FORMULA(message)
	total_message_weight += weight

	var/message_cache = total_message_count
	var/weight_cache = total_message_weight

	if(last_message_time && world.time > last_message_time)
		last_message_time = 0
		total_message_count = 0
		total_message_weight = 0

	else if(!last_message_time)
		last_message_time = world.time + SPAM_TRIGGER_TIME_PERIOD

	last_message = message

	var/mute = message_cache >= SPAM_TRIGGER_AUTOMUTE || (weight_cache > SPAM_TRIGGER_WEIGHT_AUTOMUTE && message_cache != 1)
	var/warning = message_cache >= SPAM_TRIGGER_WARNING || (weight_cache > SPAM_TRIGGER_WEIGHT_WARNING && message_cache != 1)

	if(mute)
		if(GLOB.automute_on && !check_rights(R_ADMIN, FALSE))
			to_chat(src, span_danger("You have exceeded the spam filter. An auto-mute was applied."))
			create_message("note", ckey(key), "SYSTEM", "Automuted due to spam. Last message: '[last_message]'", null, null, FALSE, TRUE, null, FALSE, "Minor")
			mute(src, mute_type, TRUE)
		return TRUE

	if(warning && GLOB.automute_on && !check_rights(R_ADMIN, FALSE))
		to_chat(src, span_danger("You are nearing the spam filter limit."))

/client/vv_edit_var(var_name, var_value)
	switch(var_name)
		if("holder")
			return FALSE
		if("ckey")
			return FALSE
		if("key")
			return FALSE
		if("view")
			view_size.set_view_radius_to(var_value)
			return TRUE
	return ..()

/client/proc/open_filter_editor(atom/in_atom)
	if(holder)
		holder.filteriffic = new /datum/filter_editor(in_atom)
		holder.filteriffic.ui_interact(mob)

///opens the particle editor UI for the in_atom object for this client
/client/proc/open_particle_editor(atom/movable/in_atom)
	if(holder)
		holder.particle_test = new /datum/particle_editor(in_atom)
		holder.particle_test.ui_interact(mob)

///updates with the ambience preferrences of the user
/client/proc/update_ambience_pref()
	if(prefs.toggles_sound & SOUND_AMBIENCE)
		if(SSambience.ambience_listening_clients[src] > world.time)
			return // If already properly set we don't want to reset the timer.
		SSambience.ambience_listening_clients[src] = world.time + 10 SECONDS //Just wait 10 seconds before the next one aight mate? cheers.
	else
		SSambience.ambience_listening_clients -= src

/// compiles a full list of verbs and sends it to the browser
/client/proc/init_verbs()
	if(IsAdminAdvancedProcCall())
		return
	var/list/verblist = list()
	var/list/verbstoprocess = verbs.Copy()
	if(mob)
		verbstoprocess += mob.verbs
		for(var/atom/movable/thing as anything in mob.contents)
			verbstoprocess += thing.verbs
	panel_tabs.Cut() // panel_tabs get reset in init_verbs on JS side anyway
	for(var/procpath/verb_to_init as anything in verbstoprocess)
		if(!verb_to_init)
			continue
		if(verb_to_init.hidden)
			continue
		if(!istext(verb_to_init.category))
			continue
		panel_tabs |= verb_to_init.category
		verblist[++verblist.len] = list(verb_to_init.category, verb_to_init.name)
	src.stat_panel.send_message("init_verbs", list(panel_tabs = panel_tabs, verblist = verblist))

/client/proc/check_panel_loaded()
	if(stat_panel.is_ready())
		return
	to_chat(src, span_userdanger("Statpanel failed to load, click <a href='?src=[REF(src)];reload_statbrowser=1'>here</a> to reload the panel "))

/**
 * Handles incoming messages from the stat-panel TGUI.
 */
/client/proc/on_stat_panel_message(type, payload)
	switch(type)
		if("Update-Verbs")
			init_verbs()
		if("Remove-Tabs")
			panel_tabs -= payload["tab"]
		if("Send-Tabs")
			panel_tabs |= payload["tab"]
		if("Reset-Tabs")
			panel_tabs = list()
		if("Set-Tab")
			stat_tab = payload["tab"]
			SSstatpanels.immediate_send_stat_data(src)
