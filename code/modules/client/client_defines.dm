/client
	parent_type = /datum // black magic
	preload_rsc = PRELOAD_RSC // This is 0 so we can set it to an URL once the player logs in and have them download the resources from a different server.
	view = WORLD_VIEW
	var/datum/tooltip/tooltips

	//Admin related
	var/datum/admins/holder = null
	var/ban_cache = null //Used to cache this client's bans to save on DB queries
	var/last_message = "" //Contains the last message sent by this client - used to protect against copy-paste spamming.
	var/last_message_time = 0 //The world.time when last message was sent.
	var/total_message_count = 0 //The total amount of messages sent per a time period.
	var/total_message_weight = 0 //The total weight of the messages sent per a time period.
	var/externalreplyamount = 0 //Internal counter for clients sending external (IRC/Discord) relay messages via ahelp to prevent spamming. Set to a number every time an admin reply is sent, decremented for every client send.
	var/datum/player_details/player_details //these persist between logins/logouts during the same round.

	//Preferences related
	var/datum/preferences/prefs = null
	var/inprefs = FALSE


	//Mob related
	var/list/keys_held = list() // A list of any keys held currently
	var/current_key_address = 0
	// These next two vars are to apply movement for keypresses and releases made while move delayed.
	// Because discarding that input makes the game less responsive.
	var/next_move_dir_add // On next move, add this dir to the move that would otherwise be done
	var/next_move_dir_sub // On next move, subtract this dir from the move that would otherwise be done
	var/datum/click_intercept = null // Needs to implement InterceptClickOn(user,params,atom) proc
	var/move_delay = 0
	var/area = null
	var/atom/movable/screen/click_catcher/void = null
	var/list/char_render_holders			//Should only be a key-value list of north/south/east/west = atom/movable/screen.
	var/mouse_up_icon = null
	var/mouse_down_icon = null
	var/click_intercepted = FALSE //Check if current click was intercepted. Reset and return if TRUE. This is because there's no communication between Click(), MouseDown() and MouseUp().

	//Security related
	var/list/topiclimiter
	var/list/clicklimiter
	var/lastping = 0
	var/avgping = 0
	var/connection_time //world.time they connected
	var/connection_realtime //world.realtime they connected
	var/connection_timeofday //world.timeofday they connected
	var/middragtime = 0 //MMB exploit detection
	var/atom/middragatom //MMB exploit detection

	/// datum wrapper for client view
	var/datum/view_data/view_size

	/// our current tab
	var/stat_tab

	/// list of all tabs
	var/list/panel_tabs = list()
	/// list of tabs containing spells and abilities
	var/list/spell_tabs = list()
	///A lazy list of atoms we've examined in the last RECENT_EXAMINE_MAX_WINDOW (default 2) seconds, so that we will call [/atom/proc/examine_more] instead of [/atom/proc/examine] on them when examining
	var/list/recent_examines
	///Our object window datum. It stores info about and handles behavior for the object tab
	var/datum/object_window_info/obj_window

	//Database related
	var/player_age = -1	//Used to determine how old the account is - in days.
	var/player_join_date = null //Date that this account was first seen in the server
	var/related_accounts_ip = "Requires database"	//So admins know why it isn't working - Used to determine what other accounts previously logged in from this ip
	var/related_accounts_cid = "Requires database"	//So admins know why it isn't working - Used to determine what other accounts previously logged in from this computer id
	var/account_join_date = null	//Date of byond account creation in ISO 8601 format
	var/account_age = -1	//Age of byond account in days

	// List of all asset filenames sent to this client by the asset cache, along with their assoicated md5s
	var/list/sent_assets = list()
	/// List of all completed blocking send jobs awaiting acknowledgement by send_asset
	var/list/completed_asset_jobs = list()
	/// Last asset send job id.
	var/last_asset_job = 0
	var/last_completed_asset_job = 0

	//Codex
	var/codex_on_cooldown = FALSE
	var/const/max_codex_entries_shown = 10

	//screen_text vars
	///lazylist of screen_texts for this client, first in this list is the one playing
	var/list/atom/movable/screen/text/screen_text/screen_texts

	///Amount of keydowns in the last keysend checking interval
	var/client_keysend_amount = 0
	///World tick time where client_keysend_amount will reset
	var/next_keysend_reset = 0
	///World tick time where keysend_tripped will reset back to false
	var/next_keysend_trip_reset = 0
	///When set to true, user will be autokicked if they trip the keysends in a second limit again
	var/keysend_tripped = FALSE
	///custom movement keys for this client
	var/list/movement_keys = list()

	var/list/parallax_layers
	var/list/parallax_layers_cached
	var/atom/movable/movingmob
	var/turf/previous_turf
	///world.time of when we can state animate()ing parallax again
	var/dont_animate_parallax
	///world.time of last parallax update
	var/last_parallax_shift
	///ds between parallax updates
	var/parallax_throttle = 0
	var/parallax_movedir = 0
	var/parallax_layers_max = 4
	var/parallax_animate_timer

	/**
	 * Assoc list with all the active maps - when a screen obj is added to
	 * a map, it's put in here as well.
	 *
	 * Format: list(<mapname> = list(/atom/movable/screen))
	 */
	var/list/screen_maps = list()

	/// Messages currently seen by this client
	var/list/seen_messages

	show_popup_menus = TRUE // right click menu no longer shows up
	control_freak = CONTROL_FREAK_MACROS
