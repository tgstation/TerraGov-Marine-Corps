/*
Basics, the most important.
*/
/datum/config_entry/string/server_name	// The name used for the server almost universally.

/datum/config_entry/string/serversqlname	// Short form of the previous used for the DB.

/datum/config_entry/string/server // If you set this location, it sends you there instead of trying to reconnect.

/datum/config_entry/flag/hub	// Does the server appear on the hub?

/datum/config_entry/string/hostedby // Sets the hosted by name on unix platforms.

/datum/config_entry/string/resource_url

/datum/config_entry/string/hubpassword
	config_entry_value = "kMZy3U5jJHSiBQjr"

/datum/config_entry/string/wikiurl
	config_entry_value = "https://tgstation13.org/wiki/TGMC"

/datum/config_entry/string/forumurl
	config_entry_value = "http://tgstation13.org/phpBB/index.php"

/datum/config_entry/string/rulesurl
	config_entry_value = "http://www.tgstation13.org/wiki/TGMC:Rules"

/datum/config_entry/string/githuburl
	config_entry_value = "https://github.com/tgstation/TerraGov-Marine-Corps"

/datum/config_entry/string/discordurl
	config_entry_value = "https://discord.gg/2dFpfNE"

/datum/config_entry/string/banappeals
	config_entry_value = "https://tgstation13.org/phpBB/viewforum.php?f=70"

/datum/config_entry/string/donationurl

/datum/config_entry/string/shipurl
	config_entry_value = "https://affectedarc07.github.io/SS13WebMap/TGMC/Almayer/index.html"

/datum/config_entry/string/lv624url
	config_entry_value = "https://affectedarc07.github.io/SS13WebMap/TGMC/LV624/index.html"

/datum/config_entry/string/icecolonyurl
	config_entry_value = "https://affectedarc07.github.io/SS13WebMap/TGMC/IceColony/index.html"

/datum/config_entry/string/bigredurl
	config_entry_value = "https://affectedarc07.github.io/SS13WebMap/TGMC/BigRed/index.html"

/datum/config_entry/string/prisonstationurl
	config_entry_value = "https://affectedarc07.github.io/SS13WebMap/TGMC/PrisonStation/index.html"

/datum/config_entry/string/whiskeyoutposturl
	config_entry_value = "https://affectedarc07.github.io/SS13WebMap/TGMC/WhiskeyOutpost/index.html"

/datum/config_entry/string/python_path

/datum/config_entry/flag/guest_ban

/datum/config_entry/flag/continous_rounds

/*
Administrative related.
*/
/datum/config_entry/flag/localhost_rank

/datum/config_entry/flag/ban_legacy_system
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/flag/admin_legacy_system	//Defines whether the server uses the legacy admin system with admins.txt or the SQL system
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/flag/log_admin
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/flag/log_adminchat
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/flag/log_hrefs
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/flag/log_ooc

/datum/config_entry/flag/log_access

/datum/config_entry/flag/log_say

/datum/config_entry/flag/log_hivemind

/datum/config_entry/flag/log_runtime

/datum/config_entry/flag/log_prayer

/datum/config_entry/flag/log_game

/datum/config_entry/flag/log_vote

/datum/config_entry/flag/log_whisper

/datum/config_entry/flag/log_attack

/datum/config_entry/flag/log_emote

/datum/config_entry/flag/log_world_topic

/datum/config_entry/flag/log_manifest

/datum/config_entry/flag/allow_admin_ooccolor // Allows admins to customize their OOC color.

/datum/config_entry/flag/admin_irc

/datum/config_entry/flag/guest_jobban

/datum/config_entry/flag/usewhitelist

/datum/config_entry/flag/use_age_restriction_for_jobs	//Do jobs use account age restrictions? --requires database

/datum/config_entry/flag/kick_inactive	//force disconnect for inactive players

/datum/config_entry/flag/automute_on	//enables automuting/spam prevention

/datum/config_entry/flag/autooocmute

/*
Voting
*/
/datum/config_entry/flag/allow_vote_restart

/datum/config_entry/flag/allow_vote_mode

/datum/config_entry/number/vote_delay	// Minimum time between voting sessions. (deciseconds, 10 minute default)
	config_entry_value = 6000
	integer = FALSE
	min_val = 0

/datum/config_entry/number/vote_period  // length of voting period (deciseconds, default 1 minute)
	config_entry_value = 600
	integer = FALSE
	min_val = 0

/datum/config_entry/flag/vote_no_default

/datum/config_entry/flag/vote_no_dead

/datum/config_entry/number/vote_autogamemode_timeleft

/datum/config_entry/flag/allow_metadata	// Metadata is supported.

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

/datum/config_entry/number/tick_limit_mc_init	//SSinitialization throttling
	config_entry_value = TICK_LIMIT_MC_INIT_DEFAULT
	min_val = 0 //oranges warned us
	integer = FALSE

/datum/config_entry/flag/resume_after_initializations

/datum/config_entry/flag/resume_after_initializations/ValidateAndSet(str_val)
	. = ..()
	if(. && Master.current_runlevel)
		world.sleep_offline = !config_entry_value

/datum/config_entry/flag/tickcomp

/datum/config_entry/flag/use_recursive_explosions

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

/*
Not yet implemented.
*/
/datum/config_entry/flag/norespawn

/*
Legacy - work on reworking/removing these.
*/
/datum/config_entry/number/max_maint_drones

/datum/config_entry/flag/allow_drone_spawn

/datum/config_entry/number/drone_build_time

/datum/config_entry/flag/usealienwhitelist

/datum/config_entry/flag/load_legacy_ranks_only