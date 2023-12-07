/*
Basics, the most important.
*/
/datum/config_entry/string/server_name	// The name used for the server almost universally.

/datum/config_entry/string/serversqlname	// Short form of the previous used for the DB.

/datum/config_entry/string/server // If you set this location, it sends you there instead of trying to reconnect.

/datum/config_entry/string/title //The title of the main window

/datum/config_entry/string/hostedby // Sets the hosted by name on unix platforms.

/datum/config_entry/string/resource_url

/datum/config_entry/flag/hub	// if the game appears on the hub or not

/datum/config_entry/string/wikiurl

/datum/config_entry/string/forumurl

/datum/config_entry/string/rulesurl

/datum/config_entry/string/githuburl

/datum/config_entry/string/discordurl

/datum/config_entry/string/banappeals

/datum/config_entry/string/dburl

/// URL for the CentCom Galactic Ban DB API
/datum/config_entry/string/centcom_ban_db

/// Host of the webmap
/datum/config_entry/string/webmap_host
	config_entry_value = "https://affectedarc07.co.uk/tgmc.php?m="

/datum/config_entry/string/python_path

/datum/config_entry/string/end_of_round_channel
	config_entry_value = "game-updates"
	protection = CONFIG_ENTRY_LOCKED|CONFIG_ENTRY_HIDDEN

/datum/config_entry/string/restart_message

/datum/config_entry/flag/guest_ban

/*
Administrative related.
*/
/datum/config_entry/flag/localhost_rank
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/flag/admin_legacy_system	//Defines whether the server uses the legacy admin system with admins.txt or the SQL system
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/flag/protect_legacy_admins	//Stops any admins loaded by the legacy system from having their rank edited by the permissions panel
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/flag/protect_legacy_ranks	//Stops any ranks loaded by the legacy system from having their flags edited by the permissions panel
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/flag/load_legacy_ranks_only	//Loads admin ranks only from legacy admin_ranks.txt, while enabled ranks are mirrored to the database
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/flag/log_admin
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/flag/log_adminchat
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/flag/log_hrefs
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/flag/log_ooc

/datum/config_entry/flag/log_xooc

/datum/config_entry/flag/log_mooc

/datum/config_entry/flag/log_looc

/datum/config_entry/flag/log_access

/datum/config_entry/flag/log_say

/datum/config_entry/flag/log_telecomms

/// log speech indicators(started/stopped speaking)
/datum/config_entry/flag/log_speech_indicators

/datum/config_entry/flag/log_hivemind

/datum/config_entry/flag/log_runtime

/datum/config_entry/flag/log_prayer

/datum/config_entry/flag/log_game

/datum/config_entry/flag/log_minimap_drawing

/// log mech data
/datum/config_entry/flag/log_mecha

/datum/config_entry/flag/log_asset

/datum/config_entry/flag/log_vote

/datum/config_entry/flag/log_whisper

/datum/config_entry/flag/log_attack

/datum/config_entry/flag/log_emote

/datum/config_entry/flag/log_world_topic

/datum/config_entry/flag/log_manifest

/// log roundstart divide occupations debug information to a file
/datum/config_entry/flag/log_job_debug

/datum/config_entry/flag/log_timers_on_bucket_reset // logs all timers in buckets on automatic bucket reset (Useful for timer debugging)

/// Log human readable versions of json log entries
/datum/config_entry/flag/log_as_human_readable
	config_entry_value = TRUE

/datum/config_entry/flag/allow_admin_ooccolor // Allows admins to customize their OOC color.

/datum/config_entry/flag/usewhitelist

/datum/config_entry/flag/use_age_restriction_for_jobs	//Do jobs use account age restrictions? --requires database

/datum/config_entry/flag/use_exp_tracking

/datum/config_entry/flag/use_exp_restrictions_admin_bypass

/datum/config_entry/flag/use_exp_restrictions_command

/datum/config_entry/number/use_exp_restrictions_command_hours
	config_entry_value = 0
	integer = FALSE
	min_val = 0

/datum/config_entry/flag/use_exp_restrictions_command_department

/datum/config_entry/flag/use_exp_restrictions_other

/datum/config_entry/flag/prevent_dupe_names

/datum/config_entry/flag/kick_inactive	//force disconnect for inactive players

/datum/config_entry/flag/automute_on	//enables automuting/spam prevention

/datum/config_entry/flag/autooocmute

/datum/config_entry/flag/looc_enabled

/datum/config_entry/number/lobby_countdown
	config_entry_value = 180

/datum/config_entry/number/mission_end_countdown
	config_entry_value = 120

/datum/config_entry/flag/see_own_notes

/datum/config_entry/number/note_fresh_days
	config_entry_value = 30
	min_val = 0
	integer = FALSE

/datum/config_entry/number/note_stale_days
	config_entry_value = 180
	min_val = 0
	integer = FALSE

/datum/config_entry/flag/use_account_age_for_jobs

/datum/config_entry/number/notify_new_player_age
	min_val = -1

/datum/config_entry/number/notify_new_account_age
	min_val = -1

/datum/config_entry/flag/allow_shutdown
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/string/tgs3_commandline_path
	protection = CONFIG_ENTRY_LOCKED | CONFIG_ENTRY_HIDDEN
	config_entry_value = "C:\\Program Files (x86)\\TG Station Server\\TGCommandLine.exe"

/datum/config_entry/number/minute_topic_limit
	config_entry_value = 250
	min_val = 0

/datum/config_entry/number/second_topic_limit
	config_entry_value = 15
	min_val = 0

/datum/config_entry/number/minute_click_limit
	config_entry_value = 400
	min_val = 0

/datum/config_entry/number/second_click_limit
	config_entry_value = 15
	min_val = 0

/datum/config_entry/number/afk_period	//time in ds until a player is considered inactive
	config_entry_value = 3000
	integer = FALSE
	min_val = 0

/datum/config_entry/number/glide_size_mod
	config_entry_value = 80
/*
Voting
*/
/datum/config_entry/flag/allow_vote_restart

/datum/config_entry/flag/allow_vote_mode

/datum/config_entry/flag/allow_vote_groundmap

/datum/config_entry/flag/allow_vote_shipmap

/datum/config_entry/flag/default_no_vote

/datum/config_entry/flag/no_dead_vote

/datum/config_entry/number/rounds_until_hard_restart
	config_entry_value = -1 // -1 is disabled by default, 0 is every round, x is after so many rounds

/datum/config_entry/number/vote_delay	// Minimum time between voting sessions. (deciseconds, 10 minute default)
	config_entry_value = 6000
	integer = FALSE
	min_val = 0

/datum/config_entry/number/vote_period  // length of voting period (deciseconds, default 1 minute)
	config_entry_value = 600
	integer = FALSE
	min_val = 0

/// Gives the ability to send players a maptext popup.
/datum/config_entry/flag/popup_admin_pm

/*
Master controller and performance related.
*/
/datum/config_entry/number/mc_tick_rate/base_mc_tick_rate
	integer = FALSE
	config_entry_value = 1

/datum/config_entry/number/mc_tick_rate/high_pop_mc_tick_rate
	integer = FALSE
	config_entry_value = 1.1

/datum/config_entry/number/mc_tick_rate/high_pop_mc_mode_amount
	config_entry_value = 65

/datum/config_entry/number/mc_tick_rate/disable_high_pop_mc_mode_amount
	config_entry_value = 60

/datum/config_entry/number/mc_tick_rate
	abstract_type = /datum/config_entry/number/mc_tick_rate

/datum/config_entry/number/mc_tick_rate/ValidateAndSet(str_val)
	. = ..()
	if(.)
		Master.UpdateTickRate()

/datum/config_entry/number/fps
	config_entry_value = 20
	integer = FALSE
	min_val = 1
	max_val = 100   //byond will start crapping out at 50, so this is just ridic
	var/sync_validate = FALSE

/datum/config_entry/number/fps/ValidateAndSet(str_val)
	. = ..()
	if(.)
		sync_validate = TRUE
		var/datum/config_entry/number/ticklag/TL = config.entries_by_type[/datum/config_entry/number/ticklag]
		if(!TL.sync_validate)
			TL.ValidateAndSet(10 / config_entry_value)
		sync_validate = FALSE

/datum/config_entry/number/ticklag
	config_entry_value = 0.5
	integer = FALSE
	var/sync_validate = FALSE

/datum/config_entry/number/ticklag/New()	//ticklag weirdly just mirrors fps
	var/datum/config_entry/CE = /datum/config_entry/number/fps
	config_entry_value = 10 / initial(CE.config_entry_value)
	return ..()

/datum/config_entry/number/ticklag/ValidateAndSet(str_val)
	. = text2num(str_val) > 0 && ..()
	if(.)
		sync_validate = TRUE
		var/datum/config_entry/number/fps/FPS = config.entries_by_type[/datum/config_entry/number/fps]
		if(!FPS.sync_validate)
			FPS.ValidateAndSet(10 / config_entry_value)
		sync_validate = FALSE

/datum/config_entry/flag/resume_after_initializations

/datum/config_entry/flag/resume_after_initializations/ValidateAndSet(str_val)
	. = ..()
	if(. && MC_RUNNING())
		world.sleep_offline = !config_entry_value

/datum/config_entry/flag/tickcomp

/*
System command that invokes youtube-dl, used by Play Internet Sound.
You can install youtube-dl with
"pip install youtube-dl" if you have pip installed
from https://github.com/rg3/youtube-dl/releases
or your package manager
The default value assumes youtube-dl is in your system PATH
*/
/datum/config_entry/string/invoke_youtubedl
	protection = CONFIG_ENTRY_LOCKED | CONFIG_ENTRY_HIDDEN


/datum/config_entry/number/error_cooldown	// The "cooldown" time for each occurrence of a unique error
	config_entry_value = 600
	integer = FALSE
	min_val = 0


/datum/config_entry/number/error_limit	// How many occurrences before the next will silence them
	config_entry_value = 50


/datum/config_entry/number/error_silence_time	// How long a unique error will be silenced for
	config_entry_value = 6000
	integer = FALSE


/datum/config_entry/number/error_msg_delay	// How long to wait between messaging admins about occurrences of a unique error
	config_entry_value = 50
	integer = FALSE


/datum/config_entry/number/soft_popcap
	min_val = 0


/datum/config_entry/number/hard_popcap
	min_val = 0


/datum/config_entry/number/extreme_popcap
	min_val = 0


/datum/config_entry/string/soft_popcap_message
	config_entry_value = "The server is currently serving a high number of users, joining the round may get disabled soon."


/datum/config_entry/string/hard_popcap_message
	config_entry_value = "The server is currently serving a high number of users, You cannot currently join, but you can observe or wait for the number of living crew to decline."


/datum/config_entry/string/extreme_popcap_message
	config_entry_value = "The server is currently serving a high number of users, joining the server has been disabled."


/datum/config_entry/flag/byond_member_bypass_popcap


/datum/config_entry/flag/panic_bunker


/datum/config_entry/string/panic_server_name

///living time in minutes that a player needs to pass the panic bunker
/datum/config_entry/number/panic_bunker_living

/datum/config_entry/string/panic_server_name/ValidateAndSet(str_val)
	return str_val != "\[Put the name here\]" && ..()


/datum/config_entry/string/panic_server_address	//Reconnect a player this linked server if this server isn't accepting new players


/datum/config_entry/string/panic_server_address/ValidateAndSet(str_val)
	return str_val != "byond://address:port" && ..()


/datum/config_entry/string/panic_bunker_message
	config_entry_value = "Sorry but the server is currently not accepting connections from never before seen players."

/datum/config_entry/flag/check_randomizer

/datum/config_entry/string/default_view
	config_entry_value = "15x15"

/datum/config_entry/string/default_view_square
	config_entry_value = "15x15"

/*
This maintains a list of ip addresses that are able to bypass topic filtering.
*/
/datum/config_entry/keyed_list/topic_filtering_whitelist
	key_mode = KEY_MODE_TEXT
	value_mode = VALUE_MODE_FLAG
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/number/ff_damage_threshold
	min_val = 0
	config_entry_value = 250

/datum/config_entry/number/ff_damage_reset
	min_val = 0
	config_entry_value = 30 SECONDS

/datum/config_entry/flag/is_automatic_balance_on
	config_entry_value = TRUE

/datum/config_entry/number/hard_deletes_overrun_threshold
	integer = FALSE
	min_val = 0
	config_entry_value = 0.5

/datum/config_entry/number/hard_deletes_overrun_limit
	config_entry_value = 0
	min_val = 0

/datum/config_entry/number/ai_anti_stuck_lag_time_dilation_threshold
	config_entry_value = 20
	min_val = 0

/datum/config_entry/flag/cache_assets
	default = TRUE

/datum/config_entry/flag/save_spritesheets
	default = FALSE
