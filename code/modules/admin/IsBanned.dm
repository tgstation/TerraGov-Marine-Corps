//Blocks an attempt to connect before even creating our client datum thing.

//How many new ckey matches before we revert the stickyban to it's roundstart state
//These are exclusive, so once it goes over one of these numbers, it reverts the ban
#define STICKYBAN_MAX_MATCHES 15
#define STICKYBAN_MAX_EXISTING_USER_MATCHES 3 //ie, users who were connected before the ban triggered
#define STICKYBAN_MAX_ADMIN_MATCHES 1

GLOBAL_VAR(last_connection)

/world/IsBanned(key, address, computer_id, type, real_bans_only=FALSE)

	debug_world_log("isbanned(): '[args.Join("', '")]'")
	if (!key || (!real_bans_only && (!address || !computer_id)))
		if(real_bans_only)
			return FALSE
		log_access("Failed Login (invalid data): [key] [address]-[computer_id]")
		return list("reason"="invalid login data", "desc"="Error: Could not check ban status, Please try again. Error message: Your computer provided invalid or blank information to the server on connection (byond username, IP, and Computer ID.) Provided information for reference: Username:'[key]' IP:'[address]' Computer ID:'[computer_id]'. (If you continue to get this error, please restart byond or contact byond support.)")

	var/admin = FALSE
	var/ckey = ckey(key)

	//IsBanned can get re-called on a user in certain situations, this prevents that leading to repeated messages to admins.
	var/static/list/checkedckeys = list()
	//magic voodo to check for a key in a list while also adding that key to the list without having to do two associated lookups
	var/message = !checkedckeys[ckey]++

	if(GLOB.admin_datums[ckey] || GLOB.deadmins[ckey])
		admin = TRUE

//	if(GLOB.last_connection)
//		if(!admin)
//			if(world.time < GLOB.last_connection + 5 SECONDS)
//				return list("reason"="server congestion", "desc"="Error: The queue is congested. Try connecting again.")

	var/client/C = GLOB.directory[ckey]

	//Whitelist
	if(!real_bans_only && !C && CONFIG_GET(flag/usewhitelist))
		if(!check_whitelist(ckey))
			if (admin)
				log_admin("The admin [key] has been allowed to bypass the whitelist")
				if (message)
					message_admins("<span class='adminnotice'>The admin [key] has been allowed to bypass the whitelist</span>")
					addclientmessage(ckey,"<span class='adminnotice'>I have been allowed to bypass the whitelist</span>")
			else
				log_access("Failed Login: [key] - Not on whitelist")
				return list("reason"="whitelist", "desc" = "\nBecome whitelisted! discord.gg/bx9c7ha5Qk")
/*
#ifdef MATURESERVER
	if(!check_whitelist(ckey))
		var/num = get_roundsplayed(ckey)
		if(num >= 10)
			if(check_patreon_lvl(ckey) < 2)
				log_access("Failed Login: [key] - TrialExpire")
				return list("reason"="trialexpire", "desc" = "\nBecome whitelisted to continue playing here! discord.gg/6UzZQYqVHT")
#endif
*/
/*	//Blacklist
	if(!real_bans_only && !C && CONFIG_GET(flag/useblacklist))
		if(check_blacklist(ckey))
			if (admin)
				log_admin("The admin [key] has been allowed to bypass the blacklist")
				if (message)
					message_admins("<span class='adminnotice'>The admin [key] has been allowed to bypass the blacklist</span>")
					addclientmessage(ckey,"<span class='adminnotice'>I have been allowed to bypass the blacklist</span>")
			else
				log_access("Failed Login: [key] - Blacklisted")
				return list("reason"="blacklist", "desc" = "\nSomething went wrong. Contact the Game Master.")
*/


	if(!real_bans_only && !C)
		if (!admin)
			if(get_playerquality(ckey) <= -100)
				log_access("Failed Login: [ckey] - PQ at -100")
				return list("reason"="pqlow", "desc"="\nYou have completed the game!")

	//Guest Checking
	if(!real_bans_only && !C && IsGuestKey(key))
		if (CONFIG_GET(flag/guest_ban))
			log_access("Failed Login: [key] - Guests not allowed")
			return list("reason"="guest", "desc"="\nReason: Guests not allowed. Please sign in with a byond account.")
		if (CONFIG_GET(flag/panic_bunker) && SSdbcore.Connect())
			log_access("Failed Login: [key] - Guests not allowed during panic bunker")
			return list("reason"="guest", "desc"="\nReason: Sorry but the server is currently not accepting connections from never before seen players or guests. If you have played on this server with a byond account before, please log in to the byond account you have played from.")

	//Population Cap Checking
	var/extreme_popcap = CONFIG_GET(number/extreme_popcap)
	if(!real_bans_only && !C && extreme_popcap && !admin)
		var/popcap_value = GLOB.clients.len
		if(popcap_value >= extreme_popcap && !GLOB.joined_player_list.Find(ckey))
			if(!IsPatreon(ckey))
				log_access("Failed Login: [key] - Population cap reached")
				return list("reason"="popcap", "desc"= "\nReason: [CONFIG_GET(string/extreme_popcap_message)]")

	if(CONFIG_GET(flag/sql_enabled))
		if(!SSdbcore.Connect())
			var/msg = "Ban database connection failure. Key [ckey] not checked"
			log_world(msg)
			if (message)
				message_admins(msg)
		else
			var/list/ban_details = is_banned_from_with_details(ckey, address, computer_id, "Server")
			for(var/i in ban_details)
				if(admin)
					if(text2num(i["applies_to_admins"]))
						var/msg = "Admin [key] is admin banned, and has been disallowed access."
						log_admin(msg)
						if (message)
							message_admins(msg)
					else
						var/msg = "Admin [key] has been allowed to bypass a matching non-admin ban on [i["key"]] [i["ip"]]-[i["computerid"]]."
						log_admin(msg)
						if (message)
							message_admins(msg)
							addclientmessage(ckey,"<span class='adminnotice'>Admin [key] has been allowed to bypass a matching non-admin ban on [i["key"]] [i["ip"]]-[i["computerid"]].</span>")
						continue
				var/expires = "This is a permanent ban."
				if(i["expiration_time"])
					expires = " The ban is for [DisplayTimeText(text2num(i["duration"]) MINUTES)] and expires on [i["expiration_time"]] (server time)."
				var/desc = {"You, or another user of this computer or connection ([i["key"]]) is banned from playing here.
				The ban reason is: [i["reason"]]
				This ban (BanID #[i["id"]]) was applied by [i["admin_key"]] on [i["bantime"]] during round ID [i["round_id"]].
				[expires]"}
				log_access("Failed Login: [key] [computer_id] [address] - Banned (#[i["id"]])")
				return list("reason"="Banned","desc"="[desc]")
	if (admin)
		if (GLOB.directory[ckey])
			return

		//oh boy, so basically, because of a bug in byond, sometimes stickyban matches don't trigger here, so we can't exempt admins.
		//	Whitelisting the ckey with the byond whitelist field doesn't work.
		//	So we instead have to remove every stickyban than later re-add them.
		if (!length(GLOB.stickybanadminexemptions))
			for (var/banned_ckey in world.GetConfig("ban"))
				GLOB.stickybanadmintexts[banned_ckey] = world.GetConfig("ban", banned_ckey)
				world.SetConfig("ban", banned_ckey, null)
		if (!SSstickyban.initialized)
			return
		GLOB.stickybanadminexemptions[ckey] = world.time
		stoplag() // sleep a byond tick
		GLOB.stickbanadminexemptiontimerid = addtimer(CALLBACK(GLOBAL_PROC, /proc/restore_stickybans), 5 SECONDS, TIMER_STOPPABLE|TIMER_UNIQUE|TIMER_OVERRIDE)
		return
	var/list/ban = ..()	//default pager ban stuff

	if (ban)
		if (!admin)
			. = ban
		if (real_bans_only)
			return
		var/bannedckey = "ERROR"
		if (ban["ckey"])
			bannedckey = ban["ckey"]

		var/newmatch = FALSE
		var/list/cachedban = SSstickyban.cache[bannedckey]
		//rogue ban in the process of being reverted.
		if (cachedban && (cachedban["reverting"] || cachedban["timeout"]))
			world.SetConfig("ban", bannedckey, null)
			return null

		if (cachedban && ckey != bannedckey)
			newmatch = TRUE
			if (cachedban["keys"])
				if (cachedban["keys"][ckey])
					newmatch = FALSE
			if (cachedban["matches_this_round"][ckey])
				newmatch = FALSE

		if (newmatch && cachedban)
			var/list/newmatches = cachedban["matches_this_round"]
			var/list/pendingmatches = cachedban["matches_this_round"]
			var/list/newmatches_connected = cachedban["existing_user_matches_this_round"]
			var/list/newmatches_admin = cachedban["admin_matches_this_round"]

			if (C)
				newmatches_connected[ckey] = ckey
				newmatches_connected = cachedban["existing_user_matches_this_round"]
				pendingmatches[ckey] = ckey
				sleep(STICKYBAN_ROGUE_CHECK_TIME)
				pendingmatches -= ckey
			if (admin)
				newmatches_admin[ckey] = ckey

			if (cachedban["reverting"] || cachedban["timeout"])
				return null

			newmatches[ckey] = ckey


			if (\
				newmatches.len+pendingmatches.len > STICKYBAN_MAX_MATCHES || \
				newmatches_connected.len > STICKYBAN_MAX_EXISTING_USER_MATCHES || \
				newmatches_admin.len > STICKYBAN_MAX_ADMIN_MATCHES \
			)

				var/action
				if (ban["fromdb"])
					cachedban["timeout"] = TRUE
					action = "putting it on timeout for the remainder of the round"
				else
					cachedban["reverting"] = TRUE
					action = "reverting to its roundstart state"

				world.SetConfig("ban", bannedckey, null)

				//we always report this
				log_game("Stickyban on [bannedckey] detected as rogue, [action]")
				message_admins("Stickyban on [bannedckey] detected as rogue, [action]")
				//do not convert to timer.
				spawn (5)
					world.SetConfig("ban", bannedckey, null)
					sleep(1)
					world.SetConfig("ban", bannedckey, null)
					if (!ban["fromdb"])
						cachedban = cachedban.Copy() //so old references to the list still see the ban as reverting
						cachedban["matches_this_round"] = list()
						cachedban["existing_user_matches_this_round"] = list()
						cachedban["admin_matches_this_round"] = list()
						cachedban -= "reverting"
						SSstickyban.cache[bannedckey] = cachedban
						world.SetConfig("ban", bannedckey, list2stickyban(cachedban))
				return null

		if (ban["fromdb"])
			if(SSdbcore.Connect())
				INVOKE_ASYNC(SSdbcore, /datum/controller/subsystem/dbcore/proc.QuerySelect, list(
					SSdbcore.NewQuery("INSERT INTO [format_table_name("stickyban_matched_ckey")] (matched_ckey, stickyban) VALUES ('[sanitizeSQL(ckey)]', '[sanitizeSQL(bannedckey)]') ON DUPLICATE KEY UPDATE last_matched = now()"),
					SSdbcore.NewQuery("INSERT INTO [format_table_name("stickyban_matched_ip")] (matched_ip, stickyban) VALUES ( INET_ATON('[sanitizeSQL(address)]'), '[sanitizeSQL(bannedckey)]') ON DUPLICATE KEY UPDATE last_matched = now()"),
					SSdbcore.NewQuery("INSERT INTO [format_table_name("stickyban_matched_cid")] (matched_cid, stickyban) VALUES ('[sanitizeSQL(computer_id)]', '[sanitizeSQL(bannedckey)]') ON DUPLICATE KEY UPDATE last_matched = now()")
				), FALSE, TRUE)


		//byond will not trigger isbanned() for "global" host bans,
		//ie, ones where the "apply to this game only" checkbox is not checked (defaults to not checked)
		//So it's safe to let admins walk thru host/sticky bans here
		if (admin)
			log_admin("The admin [key] has been allowed to bypass a matching host/sticky ban on [bannedckey]")
			if (message)
				message_admins("<span class='adminnotice'>The admin [key] has been allowed to bypass a matching host/sticky ban on [bannedckey]</span>")
				addclientmessage(ckey,"<span class='adminnotice'>I have been allowed to bypass a matching host/sticky ban on [bannedckey]</span>")
			return null

		if (C) //user is already connected!.
			to_chat(C, "<span class='redtext'>I are about to get disconnected for matching a sticky ban after you connected. If this turns out to be the ban evasion detection system going haywire, we will automatically detect this and revert the matches. if you feel that this is the case, please wait EXACTLY 6 seconds then reconnect using file -> reconnect to see if the match was automatically reversed.</span>")

		var/desc = ""
		. = list("reason" = "Stickyban", "desc" = desc)
		log_access("Failed Login: [key] [computer_id] [address] - StickyBanned [ban["message"]] Target Username: [bannedckey] Placed by [ban["admin"]]")

	if(!.)
		GLOB.last_connection = world.time

	return .

/proc/IsPatreon(ckey)
	if(ckey in GLOB.allpatreons)
		return TRUE
	else
		return FALSE

/proc/restore_stickybans()
	for (var/banned_ckey in GLOB.stickybanadmintexts)
		world.SetConfig("ban", banned_ckey, GLOB.stickybanadmintexts[banned_ckey])
	GLOB.stickybanadminexemptions = list()
	GLOB.stickybanadmintexts = list()
	if (GLOB.stickbanadminexemptiontimerid)
		deltimer(GLOB.stickbanadminexemptiontimerid)
	GLOB.stickbanadminexemptiontimerid = null

/client/proc/is_new_player()
#ifdef ALLOWPLAY
	return FALSE
#endif
#ifdef TESTSERVER
	return FALSE
#endif
	if(!check_whitelist(ckey))
//		if(text2num(CheckJoinDate(ckey)) > 2021)
		if(holder)
			return FALSE
		else
			if(!check_bypassage(ckey))
				var/plevel = patreonlevel()
				if(plevel < 1 || !plevel)
					if(!discord_name())
						return TRUE

#undef STICKYBAN_MAX_MATCHES
#undef STICKYBAN_MAX_EXISTING_USER_MATCHES
#undef STICKYBAN_MAX_ADMIN_MATCHES
