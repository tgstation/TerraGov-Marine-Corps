/client
	parent_type = /datum // black magic
		////////////////
		//ADMIN THINGS//
		////////////////
	var/datum/admins/holder = null
	var/buildmode		= FALSE

	var/ban_cache = null //Used to cache this client's bans to save on DB queries
	var/last_message	= "" //Contains the last message sent by this client - used to protect against copy-paste spamming.
	var/last_message_count = 0 //contins a number of how many times a message identical to last_message was sent.
	var/forumlinklimit = 0
		/////////
		//OTHER//
		/////////
	var/datum/preferences/prefs 	= null
	var/move_delay			= 0
	var/next_movement		= 0
	var/moving			= null
	var/adminobs			= null
	var/area			= null
	var/time_died_as_mouse 		= null //when the client last died as a mouse

	var/obj/screen/click_catcher/void

		///////////////
		//SOUND STUFF//
		///////////////
	var/ambience_playing= null
	var/played			= 0
	var/midi_silenced	= 0

		////////////
		//SECURITY//
		////////////
	var/next_allowed_topic_time = 10
	// comment out the line below when debugging locally to enable the options & messages menu
	//control_freak = 1

	var/received_irc_pm = -99999
	var/irc_admin			//IRC admin that spoke with them last.
	var/mute_irc = 0


	////////////////////////////////////
	//things that require the database//
	////////////////////////////////////
	var/player_age = -1	//Used to determine how old the account is - in days.
	var/player_join_date = null //Date that this account was first seen in the server
	var/related_accounts_ip = "Requires database"	//So admins know why it isn't working - Used to determine what other accounts previously logged in from this ip
	var/related_accounts_cid = "Requires database"	//So admins know why it isn't working - Used to determine what other accounts previously logged in from this computer id
	var/account_join_date = null	//Date of byond account creation in ISO 8601 format
	var/account_age = -1	//Age of byond account in days
	var/datum/player_details/player_details //these persist between logins/logouts during the same round.


	preload_rsc = 0 // This is 0 so we can set it to an URL once the player logs in and have them download the resources from a different server.

	var/datum/chatOutput/chatOutput

	// This gets set by goonchat.
	var/encoding = "1252"

	var/list/char_render_holders			//Should only be a key-value list of north/south/east/west = obj/screen.