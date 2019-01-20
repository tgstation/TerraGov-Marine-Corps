GLOBAL_LIST_EMPTY(admin_datums)
GLOBAL_PROTECT(admin_datums)
GLOBAL_LIST_EMPTY(protected_admins)
GLOBAL_PROTECT(protected_admins)

GLOBAL_VAR_INIT(href_token, GenerateToken())
GLOBAL_PROTECT(href_token)

var/list/admin_datums = list()

/datum/admins
	var/rank			= "Temporary Admin"
	var/client/owner	= null
	var/rights = 0
	var/fakekey			= null

	var/datum/marked_datum

	var/href_token

/datum/admins/New(initial_rank = "Temporary Admin", initial_rights = 0, ckey)
	if(!ckey)
		stack_trace("Admin datum created without a ckey argument. Datum has been deleted")
		qdel(src)
		return
	rank = initial_rank
	rights = initial_rights
	if (rights & R_DEBUG) //grant profile access
		world.SetConfig("APP/admin", ckey, "role=admin")
	admin_datums[ckey] = src

/datum/admins/proc/associate(client/C)
	if(istype(C))
		owner = C
		owner.holder = src
		owner.add_admin_verbs()	//TODO
		admins |= C

/datum/admins/proc/disassociate()
	if(owner)
		admins -= owner
		owner.remove_admin_verbs()
		owner.holder = null
		owner = null

/*
checks if usr is an admin with at least ONE of the flags in rights_required. (Note, they don't need all the flags)
if rights_required == 0, then it simply checks if they are an admin.
if it doesn't return 1 and show_msg=1 it will prints a message explaining why the check has failed
generally it would be used like so:

proc/admin_proc()
	if(!check_rights(R_ADMIN)) return
	to_chat(world, "you have enough rights!")

NOTE: it checks usr! not src! So if you're checking somebody's rank in a proc which they did not call
you will have to do something like if(client.holder.rights & R_ADMIN) yourself.
*/
/proc/check_rights(rights_required, show_msg=1)
	if(usr && usr.client)
		if(rights_required)
			if(usr.client.holder)
				if(rights_required & usr.client.holder.rights)
					return 1
				else
					if(show_msg)
						to_chat(usr, "<font color='red'>Error: You do not have sufficient rights to do that. You require one of the following flags:[rights2text(rights_required," ")].</font>")
		else
			if(usr.client.holder)
				return 1
			else
				if(show_msg)
					to_chat(usr, "<font color='red'>Error: You are not an admin.</font>")
	return 0

//probably a bit iffy - will hopefully figure out a better solution
/proc/check_if_greater_rights_than(client/other)
	if(usr && usr.client)
		if(usr.client.holder)
			if(!other || !other.holder)
				return 1
			if(usr.client.holder.rights != other.holder.rights)
				if( (usr.client.holder.rights & other.holder.rights) == other.holder.rights )
					return 1	//we have all the rights they have and more
		to_chat(usr, "<font color='red'>Error: Cannot proceed. They have more or equal rights to us.</font>")
	return 0

/client/proc/deadmin()
	admin_datums -= ckey
	if(holder)
		holder.disassociate()
		qdel(holder)
		holder = null
	return 1

/client/proc/readmin()
	//load text from file
	var/list/Lines = file2list("config/admins.txt")

	//process each line seperately
	for(var/line in Lines)
		if(!length(line))
			continue
		if(copytext(line,1,2) == "#")
			continue

		//Split the line at every "-"
		var/list/List = text2list(line, "-")
		if(!List.len)
			continue

		//ckey is before the first "-"
		var/target = ckey(List[1])
		if(!target)
			continue
		if(target != ckey)
			continue

		//rank follows the first "-"
		var/rank = ""
		if(List.len >= 2)
			rank = ckeyEx(List[2])

		//load permissions associated with this rank
		var/rights = admin_ranks[rank]

		//create the admin datum and store it for later use
		var/datum/admins/D = new /datum/admins(rank, rights, target)

		//find the client for a ckey if they are connected and associate them with the new admin datum
		D.associate(directory[target])

/proc/IsAdminAdvancedProcCall()
#ifdef TESTING
	return FALSE
#else
	return usr?.client && GLOB.AdminProcCaller == usr.client.ckey
#endif

/proc/GenerateToken()
	. = ""
	for(var/I in 1 to 32)
		. += "[rand(10)]"

/proc/RawHrefToken(forceGlobal = FALSE)
	var/tok = GLOB.href_token
	if(!forceGlobal && usr)
		var/client/C = usr.client
		if(!C)
			CRASH("No client for HrefToken()!")
		var/datum/admins/holder = C.holder
		if(holder)
			tok = holder.href_token
	return tok

/proc/HrefToken(forceGlobal = FALSE)
	return "admin_token=[RawHrefToken(forceGlobal)]"

/proc/HrefTokenFormField(forceGlobal = FALSE)
	return "<input type='hidden' name='admin_token' value='[RawHrefToken(forceGlobal)]'>"

//admin verb groups - They can overlap if you so wish. Only one of each verb will exist in the verbs list regardless
var/list/admin_verbs_default = list(
	/client/proc/toggleadminhelpsound,	/*toggles whether we hear a sound when adminhelps/PMs are used*/
	/client/proc/deadmin_self,			/*destroys our own admin datum so we can play as a regular player*/
	// /client/proc/cmd_mentor_check_new_players
	)
var/list/admin_verbs_admin = list(
	/client/proc/player_panel_new,		/*shows an interface for all players, with links to various panels*/
	/client/proc/invisimin,				/*allows our mob to go invisible/visible*/
	/datum/admins/proc/togglejoin,		/*toggles whether people can join the current game*/
	/datum/admins/proc/toggleguests,	/*toggles whether guests can join the current game*/
	/datum/admins/proc/announce,		/*priority announce something to all clients.*/
	/client/proc/admin_ghost,			/*allows us to ghost/reenter body at will*/
	/client/proc/toggle_view_range,		/*changes how far we can see*/
	/client/proc/getserverlogs,		/*for accessing server logs*/
	/client/proc/getfolderlogs,
	/client/proc/getcurrentlogs,		/*for accessing server logs for the current round*/
	/client/proc/cmd_admin_pm_context,	/*right-click adminPM interface*/
	/client/proc/cmd_admin_pm_panel,	/*admin-pm list*/
	/client/proc/cmd_admin_subtle_message,	/*send an message to somebody as a 'voice in their head'*/
	/client/proc/cmd_admin_delete,		/*delete an instance/object/mob/etc*/
	/client/proc/cmd_admin_check_contents,	/*displays the contents of an instance*/
	/client/proc/jumptocoord,			/*we ghost and jump to a coordinate*/
	/client/proc/Getmob,				/*teleports a mob to our location*/
	/client/proc/Getkey,				/*teleports a mob with a certain ckey to our location*/
	/client/proc/sendmob,				/*sends a mob somewhere*/ //-Removed due to it needing two sorting procs to work, which were executed every time an admin right-clicked. ~Errorage
	/client/proc/Jump,
	/client/proc/jumptokey,				/*allows us to jump to the location of a mob with a certain ckey*/
	/client/proc/jumptomob,				/*allows us to jump to a specific mob*/
	/client/proc/jumptoturf,			/*allows us to jump to a specific turf*/
	/client/proc/cmd_admin_direct_narrate,	/*send text directly to a player with no padding. Useful for narratives and fluff-text*/
	/client/proc/cmd_admin_world_narrate,	/*sends text to all players with no padding*/
	/client/proc/cmd_admin_create_centcom_report, //Messages from TGMC command.
	/client/proc/cmd_admin_create_AI_report,  //Allows creation of IC reports by the ships AI
	/client/proc/cmd_admin_xeno_report,  //Allows creation of IC reports by the Queen Mother
	/client/proc/show_hive_status,
	/client/proc/check_antagonists,
	/client/proc/admin_memo,			/*admin memo system. show/delete/write. +SERVER needed to delete admin memos of others*/
	/client/proc/dsay,					/*talk in deadchat using our ckey/fakekey*/
	/client/proc/toggleprayers,			/*toggles prayers on/off*/
	/client/proc/toggle_hear_radio,		/*toggles whether we hear the radio*/
	// /client/proc/investigate_show,		/*various admintools for investigation. Such as a singulo grief-log*/
	/client/proc/secrets,
	/datum/admins/proc/toggleooc,		/*toggles ooc on/off for everyone*/
	/datum/admins/proc/toggleoocdead,	/*toggles ooc on/off for everyone who is dead*/
	/datum/admins/proc/toggledsay,		/*toggles dsay on/off for everyone*/
	/client/proc/game_panel,			/*game panel, allows to change game-mode etc*/
	/client/proc/cmd_admin_say,			/*admin-only ooc chat*/
	/datum/admins/proc/player_notes_list,
	/datum/admins/proc/player_notes_show,
	/client/proc/cmd_mod_say,
	/client/proc/free_slot,			/*frees slot for chosen job*/
	/client/proc/cmd_admin_change_custom_event,
	/client/proc/cmd_admin_rejuvenate,
	/client/proc/toggleattacklogs,
	/client/proc/toggledebuglogs,
	/client/proc/change_security_level, /* Changes alert levels*/
	/client/proc/toggle_gun_restrictions,
	/client/proc/toggle_synthetic_restrictions,
	/client/proc/adjust_weapon_mult,
	/datum/admins/proc/togglesleep,
	/datum/admins/proc/sleepall,
	/datum/admins/proc/admin_force_distress,
	/datum/admins/proc/admin_force_ERT_shuttle,
	/client/proc/cmd_admin_changekey,
	// /client/proc/response_team, // Response Teams admin verb
	/datum/admins/proc/viewCLFaxes,
	/datum/admins/proc/viewTGMCFaxes,
	/datum/admins/proc/force_predator_round, //Force spawns a predator round.
	/client/proc/check_round_statistics,
	/client/proc/award_medal,
	/client/proc/force_shuttle,
	/client/proc/remove_players_from_vic,
	/client/proc/hide_verbs,			/*hides all our adminverbs*/
	/client/proc/hide_most_verbs,		/*hides all our hideable adminverbs*/
	/client/proc/debug_variables,		/*allows us to -see- the variables of any instance in the game. +VAREDIT needed to modify*/
	/datum/admins/proc/show_player_panel,	/*shows an interface for individual players, with various links (links require additional flags*/
	/datum/admins/proc/viewUnheardMhelps,
	/datum/admins/proc/viewUnheardAhelps,
	/client/proc/cmd_admin_changesquad
)
var/list/admin_verbs_ban = list(
	/client/proc/unban_panel
	// /client/proc/jobbans // Disabled temporarily due to 15-30 second lag spikes. Don't forget the comma in the line above when uncommenting this!
	)
var/list/admin_verbs_sounds = list(
	/client/proc/play_sound_from_list,
	/client/proc/play_imported_sound
	)
var/list/admin_verbs_fun = list(
	// /client/proc/object_talk,
	/client/proc/cmd_admin_dress,
	/client/proc/cmd_admin_select_mob_rank,
	/client/proc/cmd_admin_gib_self,
	/client/proc/drop_bomb,
    /client/proc/drop_custom_bomb,
	// /client/proc/cmd_admin_add_freeform_ai_law,
	// /client/proc/cmd_admin_add_random_ai_law,
	// /client/proc/make_sound,
	/client/proc/set_ooc_color_global,
	/datum/admins/proc/hostile_lure,
	/client/proc/set_away_timer,
	/client/proc/editappear
	)
var/list/admin_verbs_spawn = list(
	/datum/admins/proc/spawn_atom,		/*allows us to spawn instances*/
	/client/proc/respawn_character
	)
var/list/admin_verbs_server = list(
	/client/proc/Set_Holiday,
	/datum/admins/proc/startnow,
	/datum/admins/proc/restart,
	/datum/admins/proc/delay,
	/datum/admins/proc/toggleaban,
	/datum/admins/proc/toggleatime,
	/datum/admins/proc/end_round,
	/client/proc/toggle_log_hrefs,
	/datum/admins/proc/toggleAI,
	/client/proc/cmd_admin_delete,		/*delete an instance/object/mob/etc*/
	/client/proc/cmd_debug_del_all,
	/datum/admins/proc/adrev,
	/datum/admins/proc/adspawn,
	/datum/admins/proc/adjump
	)
var/list/admin_verbs_debug = list(
	/client/proc/cmd_admin_list_open_jobs,
	/client/proc/Debug2,
	/client/proc/cmd_debug_make_powernets,
	/client/proc/debug_controller,
	/client/proc/cmd_debug_mob_lists,
	/client/proc/cmd_admin_delete,
	/client/proc/cmd_debug_del_all,
	/client/proc/cmd_debug_tog_aliens,
	/client/proc/reload_admins,
	/client/proc/reload_whitelist,
	/client/proc/restart_controller,
	///client/proc/remake_distribution_map,
	///client/proc/show_distribution_map,
	// /client/proc/show_plant_genes,
	/client/proc/enable_debug_verbs,
	/client/proc/callproc,
	/client/proc/callatomproc,
	/client/proc/toggledebuglogs,
	/client/proc/cmd_admin_change_hivenumber,
	/client/proc/spatialagent
	)

var/list/admin_verbs_paranoid_debug = list(
	/client/proc/callproc,
	/client/proc/callatomproc,
	/client/proc/debug_controller
	)

var/list/admin_verbs_possess = list(
	/proc/possess,
	/proc/release
	)
var/list/admin_verbs_permissions = list(
	/client/proc/edit_admin_permissions
	)
var/list/admin_verbs_rejuv = list(
	/client/proc/respawn_character
	)
var/list/admin_verbs_color = list(
	/client/proc/set_ooc_color_self
	)

//verbs which can be hidden - needs work
var/list/admin_verbs_hideable = list(
	/client/proc/set_ooc_color_global,
	/client/proc/set_ooc_color_self,
	/client/proc/deadmin_self,
	/client/proc/toggleprayers,
	/client/proc/toggle_hear_radio,
	/datum/admins/proc/show_traitor_panel,
	/datum/admins/proc/togglejoin,
	/datum/admins/proc/toggleguests,
	/datum/admins/proc/announce,
	/client/proc/admin_ghost,
	/client/proc/toggle_view_range,
	/client/proc/cmd_admin_subtle_message,
	/client/proc/cmd_admin_check_contents,
	/client/proc/cmd_admin_direct_narrate,
	/client/proc/cmd_admin_world_narrate,
	/client/proc/play_sound_from_list,
	/client/proc/play_imported_sound,
	// /client/proc/object_talk,
	/client/proc/cmd_admin_dress,
	/client/proc/cmd_admin_select_mob_rank,
	/client/proc/cmd_admin_gib_self,
	/client/proc/drop_bomb,
	/client/proc/cmd_admin_add_freeform_ai_law,
	/client/proc/cmd_admin_add_random_ai_law,
	/client/proc/cmd_admin_create_centcom_report,
	// /client/proc/make_sound,
	/client/proc/cmd_admin_add_random_ai_law,
	/client/proc/Set_Holiday,
	/datum/admins/proc/startnow,
	/datum/admins/proc/restart,
	/datum/admins/proc/delay,
	/datum/admins/proc/toggleaban,
	/datum/admins/proc/end_round,
	/client/proc/toggle_log_hrefs,
	/client/proc/everyone_random,
	/datum/admins/proc/toggleAI,
	/datum/admins/proc/adrev,
	/datum/admins/proc/adspawn,
	/datum/admins/proc/adjump,
	/client/proc/restart_controller,
	/client/proc/cmd_admin_list_open_jobs,
	/client/proc/callproc,
	/client/proc/callatomproc,
	/client/proc/Debug2,
	/client/proc/reload_admins,
	/client/proc/reload_whitelist,
	/client/proc/cmd_debug_make_powernets,
	/client/proc/debug_controller,
	/client/proc/cmd_debug_mob_lists,
	/client/proc/cmd_debug_del_all,
	/client/proc/cmd_debug_tog_aliens,
	/client/proc/enable_debug_verbs,
	/proc/possess,
	/proc/release,
	/client/proc/remove_players_from_vic
	)
var/list/admin_verbs_mod = list(
	/client/proc/cmd_admin_pm_context,	/*right-click adminPM interface*/
	/client/proc/cmd_admin_pm_panel,	/*admin-pm list*/
	/client/proc/debug_variables,		/*allows us to -see- the variables of any instance in the game.*/
	/client/proc/toggledebuglogs,
	/datum/admins/proc/player_notes_list,
	/datum/admins/proc/player_notes_show,
	/client/proc/admin_ghost,			/*allows us to ghost/reenter body at will*/
	/client/proc/cmd_mod_say,
	/client/proc/player_panel_new,
	/client/proc/dsay,
	/datum/admins/proc/togglesleep,
	/datum/admins/proc/togglejoin,
	/client/proc/toggle_own_ghost_vis,
	/datum/admins/proc/show_player_panel,
	/client/proc/check_antagonists,
	// /client/proc/jobbans // Disabled temporarily due to 15-30 second lag spikes. Don't forget the comma in the line above when uncommenting this!
	// /client/proc/investigate_show,		/*various admintools for investigation. Such as a singulo grief-log*/
	/client/proc/toggleattacklogs,
	/client/proc/toggleffattacklogs,
	/client/proc/toggleendofroundattacklogs,
	/client/proc/getcurrentlogs,		/*for accessing server logs for the current round*/
	/datum/admins/proc/toggleooc,		/*toggles ooc on/off for everyone*/
	/datum/admins/proc/toggleoocdead,	/*toggles ooc on/off for everyone who is dead*/
	/client/proc/cmd_admin_changekey,
	/client/proc/cmd_admin_subtle_message,	/*send an message to somebody as a 'voice in their head'*/
	/client/proc/cmd_admin_xeno_report,  //Allows creation of IC reports by the Queen Mother
	/proc/release,
	/datum/admins/proc/viewUnheardMhelps,
	/datum/admins/proc/viewUnheardAhelps, //Why even have it as a client proc anyway?
	/datum/admins/proc/viewCLFaxes,
	/datum/admins/proc/viewTGMCFaxes
)

var/list/admin_verbs_mentor = list(
	/client/proc/cmd_admin_pm_context,
	/client/proc/cmd_admin_pm_panel,
	/client/proc/admin_ghost,
	/client/proc/cmd_mod_say,
	/client/proc/dsay,
	/client/proc/cmd_admin_subtle_message,
	/datum/admins/proc/viewUnheardMhelps,
	/datum/admins/proc/viewUnheardAhelps,
	/datum/admins/proc/viewCLFaxes
)

/client/proc/add_admin_verbs()
	if(holder)
		verbs += admin_verbs_default
		if(holder.rights & R_BUILDMODE)		verbs += /client/proc/togglebuildmodeself
		if(holder.rights & R_ADMIN)			verbs += admin_verbs_admin
		if(holder.rights & R_BAN)			verbs += admin_verbs_ban
		if(holder.rights & R_FUN)			verbs += admin_verbs_fun
		if(holder.rights & R_SERVER)		verbs += admin_verbs_server
		if(holder.rights & R_DEBUG)
			verbs += admin_verbs_debug
			if(CONFIG_GET(flag/debugparanoid) && !check_rights(R_ADMIN))
				verbs.Remove(admin_verbs_paranoid_debug)			//Right now it's just callproc but we can easily add others later on.
		if(holder.rights & R_POSSESS)		verbs += admin_verbs_possess
		if(holder.rights & R_PERMISSIONS)	verbs += admin_verbs_permissions
		if(holder.rights & R_STEALTH)		verbs += /client/proc/stealth
		if(holder.rights & R_REJUVINATE)	verbs += admin_verbs_rejuv
		if(holder.rights & R_COLOR)			verbs += admin_verbs_color
		if(holder.rights & R_SOUNDS)		verbs += admin_verbs_sounds
		if(holder.rights & R_SPAWN)			verbs += admin_verbs_spawn
		if(holder.rights & R_MOD)			verbs += admin_verbs_mod
		if(holder.rights & R_MENTOR)		verbs += admin_verbs_mentor

/client/proc/remove_admin_verbs()
	verbs.Remove(
		admin_verbs_default,
		/client/proc/togglebuildmodeself,
		admin_verbs_admin,
		admin_verbs_ban,
		admin_verbs_fun,
		admin_verbs_server,
		admin_verbs_debug,
		admin_verbs_possess,
		admin_verbs_permissions,
		/client/proc/stealth,
		admin_verbs_rejuv,
		admin_verbs_color,
		admin_verbs_sounds,
		admin_verbs_spawn,
		debug_verbs
		)

/client/proc/hide_most_verbs()//Allows you to keep some functionality while hiding some verbs
	set name = "Adminverbs - Hide Most"
	set category = "Admin"

	verbs.Remove(/client/proc/hide_most_verbs, admin_verbs_hideable)
	verbs += /client/proc/show_verbs

	to_chat(src, "<span class='interface'>Most of your adminverbs have been hidden.</span>")
	feedback_add_details("admin_verb","HMV") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/hide_verbs()
	set name = "Adminverbs - Hide All"
	set category = "Admin"

	remove_admin_verbs()
	verbs += /client/proc/show_verbs

	to_chat(src, "<span class='interface'>Almost all of your adminverbs have been hidden.</span>")
	feedback_add_details("admin_verb","TAVVH") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/show_verbs()
	set name = "Adminverbs - Show"
	set category = "Admin"

	verbs -= /client/proc/show_verbs
	add_admin_verbs()

	to_chat(src, "<span class='interface'>All of your adminverbs are now visible.</span>")
	feedback_add_details("admin_verb","TAVVS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!



var/list/debug_verbs = list(
        /client/proc/do_not_use_these,
        /client/proc/camera_view,
        /client/proc/sec_camera_report,
        /client/proc/intercom_view,
        /client/proc/atmosscan,
        /client/proc/powerdebug,
        /client/proc/count_objects_on_z_level,
        /client/proc/count_objects_all,
        /client/proc/cmd_assume_direct_control,
        /client/proc/ticklag,
        /client/proc/cmd_admin_grantfullaccess,
        /client/proc/cmd_admin_grantallskills,
        /client/proc/cmd_admin_areatest,
        /datum/admins/proc/show_traitor_panel,
        /client/proc/forceEvent,
        /client/proc/break_all_air_groups,
        /client/proc/regroup_all_air_groups,
        /client/proc/kill_pipe_processing,
        /client/proc/kill_air_processing,
        /client/proc/disable_communication,
        /client/proc/disable_movement,
        /client/proc/hide_debug_verbs,
        /client/proc/view_power_update_stats_area,
        /client/proc/view_power_update_stats_machines,
        /client/proc/toggle_power_update_profiling,
        /client/proc/atmos_toggle_debug,
		/client/proc/nanomapgen_DumpImage
		)


/client/proc/enable_debug_verbs()
	set category = "Debug"
	set name = "*Debug Verbs - Show*"

	if(!check_rights(R_DEBUG)) return

	verbs += debug_verbs
	verbs -= /client/proc/enable_debug_verbs

	feedback_add_details("admin_verb","mDV") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/hide_debug_verbs()
	set category = "Debug"
	set name = "*Debug Verbs - Hide*"

	if(!check_rights(R_DEBUG)) return

	verbs -= debug_verbs
	verbs += /client/proc/enable_debug_verbs

	feedback_add_details("admin_verb","hDV") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/proc/is_mentor(client/C)

	if(!istype(C))
		return 0
	if(!C.holder)
		return 0

	if(C.holder.rights == R_MENTOR)
		return 1
	return 0



/proc/ishost(whom)
	if(!whom)
		return 0
	var/client/C
	var/mob/M
	if(istype(whom, /client))
		C = whom
	else if(istype(whom, /mob))
		M = whom
		C = M.client
	else
		return 0
	if(R_HOST & C.holder.rights)
		return 1
	else
		return 0

/proc/message_admins(var/msg) // +ADMIN and above
	msg = "<span class=\"admin\"><span class=\"prefix\">ADMIN LOG:</span> <span class=\"message\">[msg]</span></span>"
	log_admin_private(msg)
	for(var/client/C in admins)
		if(R_ADMIN & C.holder.rights)
			to_chat(C, msg)

/proc/message_mods(var/msg) // +MOD and above (not Mentors)
	msg = "<span class=\"admin\"><span class=\"prefix\">MOD LOG:</span> <span class=\"message\">[msg]</span></span>"
	log_admin_private(msg)
	for(var/client/C in admins)
		if(R_MOD & C.holder.rights)
			to_chat(C, msg)

/proc/message_staff(var/msg) // ALL staff - including Mentors
	msg = "<span class=\"admin\"><span class=\"prefix\">STAFF LOG:</span> <span class=\"message\">[msg]</span></span>"
	log_admin_private(msg)
	for(var/client/C in admins)
		if(C.holder.rights)
			to_chat(C, msg)

/proc/msg_admin_attack(var/text) //Toggleable Attack Messages
	log_attack(text)
	var/rendered = "<span class=\"admin\"><span class=\"prefix\">ATTACK:</span> <span class=\"message\">[text]</span></span>"
	for(var/client/C in admins)
		if(R_MOD & C.holder.rights)
			if((C.prefs.toggles_chat & CHAT_ATTACKLOGS) && !((ticker.current_state == GAME_STATE_FINISHED) && (C.prefs.toggles_chat & CHAT_ENDROUNDLOGS)))
				var/msg = rendered
				to_chat(C, msg)

/proc/msg_admin_ff(var/text)
	log_attack(text) //Do everything normally BUT IN GREEN SO THEY KNOW
	var/rendered = "<span class=\"admin\"><span class=\"prefix\">ATTACK:</span> <font color=#00ff00><b>[text]</b></font></span>" //I used <font> because I never learned html correctly, fix this if you want

	for(var/client/C in admins)
		if(R_MOD & C.holder.rights)
			if((C.prefs.toggles_chat & CHAT_FFATTACKLOGS) && !((ticker.current_state == GAME_STATE_FINISHED) && (C.prefs.toggles_chat & CHAT_ENDROUNDLOGS)))
				var/msg = rendered
				to_chat(C, msg)