/client
	parent_type = /datum // black magic
	preload_rsc = 0 // This is 0 so we can set it to an URL once the player logs in and have them download the resources from a different server.
	var/datum/chatOutput/chatOutput //Goonchat holder
	var/datum/tooltip/tooltips

	//Admin related
	var/datum/admins/holder = null
	var/ban_cache = null //Used to cache this client's bans to save on DB queries
	var/last_message = "" //Contains the last message sent by this client - used to protect against copy-paste spamming.
	var/last_message_count = 0 //contins a number of how many times a message identical to last_message was sent.
	var/ircreplyamount = 0
	var/datum/player_details/player_details //these persist between logins/logouts during the same round.
	var/ai_interact = FALSE


	//Preferences related
	var/datum/preferences/prefs 	= null
	var/list/keybindings[0]


	//Mob related
	var/list/keys_held = list() // A list of any keys held currently
	// These next two vars are to apply movement for keypresses and releases made while move delayed.
	// Because discarding that input makes the game less responsive.
	var/next_move_dir_add // On next move, add this dir to the move that would otherwise be done
	var/next_move_dir_sub // On next move, subtract this dir from the move that would otherwise be done
	var/datum/click_intercept = null // Needs to implement InterceptClickOn(user,params,atom) proc
	var/move_delay = 0
	var/area = null
	var/obj/screen/click_catcher/void = null
	var/list/char_render_holders			//Should only be a key-value list of north/south/east/west = obj/screen.
	var/mouse_up_icon = null
	var/mouse_down_icon = null

	//Sound related
	var/played = FALSE

	//Security related
	var/list/topiclimiter
	var/list/clicklimiter
	var/lastping = 0
	var/avgping = 0
	var/connection_time //world.time they connected
	var/connection_realtime //world.realtime they connected
	var/connection_timeofday //world.timeofday they connected


	//Database related
	var/player_age = -1	//Used to determine how old the account is - in days.
	var/player_join_date = null //Date that this account was first seen in the server
	var/related_accounts_ip = "Requires database"	//So admins know why it isn't working - Used to determine what other accounts previously logged in from this ip
	var/related_accounts_cid = "Requires database"	//So admins know why it isn't working - Used to determine what other accounts previously logged in from this computer id
	var/account_join_date = null	//Date of byond account creation in ISO 8601 format
	var/account_age = -1	//Age of byond account in days