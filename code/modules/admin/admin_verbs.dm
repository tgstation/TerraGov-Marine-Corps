//admin verb groups - They can overlap if you so wish. Only one of each verb will exist in the verbs list regardless
var/list/admin_verbs_default = list(
	/datum/admins/proc/show_player_panel,	/*shows an interface for individual players, with various links (links require additional flags*/
	/client/proc/toggleadminhelpsound,	/*toggles whether we hear a sound when adminhelps/PMs are used*/
	/client/proc/deadmin_self,			/*destroys our own admin datum so we can play as a regular player*/
	/client/proc/hide_verbs,			/*hides all our adminverbs*/
	/client/proc/hide_most_verbs,		/*hides all our hideable adminverbs*/
	/client/proc/debug_variables,		/*allows us to -see- the variables of any instance in the game. +VAREDIT needed to modify*/
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
	/datum/admins/proc/view_txt_log,	/*shows the server log (diary) for today*/
	/client/proc/cmd_admin_pm_context,	/*right-click adminPM interface*/
	/client/proc/cmd_admin_pm_panel,	/*admin-pm list*/
	/client/proc/cmd_admin_subtle_message,	/*send an message to somebody as a 'voice in their head'*/
	/client/proc/cmd_admin_delete,		/*delete an instance/object/mob/etc*/
	/client/proc/cmd_admin_check_contents,	/*displays the contents of an instance*/
	/client/proc/giveruntimelog,		/*allows us to give access to runtime logs to somebody*/
	/client/proc/getserverlog,			/*allows us to fetch server logs (diary) for other days*/
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
	/client/proc/cmd_admin_create_centcom_report, //Messages from USCM command.
	/client/proc/cmd_admin_create_AI_report,  //Allows creation of IC reports by the ships AI
	/client/proc/cmd_admin_xeno_report,  //Allows creation of IC reports by the Queen Mother
	/client/proc/show_hive_status,
	// /client/proc/check_ai_laws,			/*shows AI and borg laws*/
	/client/proc/check_antagonists,
	/client/proc/admin_memo,			/*admin memo system. show/delete/write. +SERVER needed to delete admin memos of others*/
	/client/proc/dsay,					/*talk in deadchat using our ckey/fakekey*/
	/client/proc/toggleprayers,			/*toggles prayers on/off*/
	/client/proc/toggle_hear_radio,		/*toggles whether we hear the radio*/
	// /client/proc/investigate_show,		/*various admintools for investigation. Such as a singulo grief-log*/
	/client/proc/secrets,
	/datum/admins/proc/toggleooc,		/*toggles ooc on/off for everyone*/
	/datum/admins/proc/togglelooc,		/*toggles ooc on/off for everyone*/
	/datum/admins/proc/toggleoocdead,	/*toggles ooc on/off for everyone who is dead*/
	/datum/admins/proc/toggleloocdead,	/*toggles looc on/off for everyone who is dead*/
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
	// /client/proc/toggleghostwriters,
	/client/proc/toggledrones,
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
	/client/proc/allow_character_respawn,    /* Allows a ghost to respawn */
	/datum/admins/proc/viewCLFaxes,
	/datum/admins/proc/viewUSCMFaxes,
	/datum/admins/proc/force_predator_round, //Force spawns a predator round.
	/client/proc/check_round_statistics,
	/client/proc/award_medal,
	/client/proc/force_shuttle,
	/client/proc/remove_players_from_vic
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
	/client/proc/ToRban,
	/datum/admins/proc/startnow,
	/datum/admins/proc/restart,
	/datum/admins/proc/delay,
	/datum/admins/proc/toggleaban,
	/datum/admins/proc/end_round,
	/client/proc/toggle_log_hrefs,
	/datum/admins/proc/toggleAI,
	/client/proc/cmd_admin_delete,		/*delete an instance/object/mob/etc*/
	/client/proc/cmd_debug_del_all,
	/datum/admins/proc/adrev,
	/datum/admins/proc/adspawn,
	/datum/admins/proc/adjump,
	/client/proc/forceNextMap,
	/client/proc/cancelMapVote,
	/client/proc/killMapDaemon,
	/client/proc/editVotableMaps,
	/client/proc/showVotableMaps,
	/client/proc/forceMDMapVote,
	/client/proc/reviveMapDaemon
	)
var/list/admin_verbs_debug = list(
    /client/proc/getruntimelog,                     /*allows us to access runtime logs to somebody*/
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
	/datum/proc/ta_diagnose,
	/datum/proc/ra_diagnose,
	/datum/proc/ta_purge,
	/datum/proc/ra_purge,
	/client/proc/scheduler,
	/client/proc/cmd_admin_change_hivenumber
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
	/datum/admins/proc/view_txt_log,
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
	/client/proc/ToRban,
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
	/client/proc/startSinglo,
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
	/datum/admins/proc/view_txt_log,
	/datum/admins/proc/toggleooc,		/*toggles ooc on/off for everyone*/
	/datum/admins/proc/toggleoocdead,	/*toggles ooc on/off for everyone who is dead*/
	/datum/admins/proc/toggleloocdead,	/*toggles looc on/off for everyone who is dead*/
	/client/proc/cmd_admin_changekey,
	/client/proc/cmd_admin_subtle_message,	/*send an message to somebody as a 'voice in their head'*/
	/client/proc/cmd_admin_xeno_report,  //Allows creation of IC reports by the Queen Mother
	/proc/release,
	/datum/admins/proc/viewUnheardAhelps, //Why even have it as a client proc anyway?  �\_("/)_/�
	/datum/admins/proc/viewCLFaxes,
	/datum/admins/proc/viewUSCMFaxes
)

var/list/admin_verbs_mentor = list(
	/client/proc/cmd_admin_pm_context,
	/client/proc/cmd_admin_pm_panel,
	/datum/admins/proc/player_notes_list,
	/datum/admins/proc/player_notes_show,
	/client/proc/admin_ghost,
	/client/proc/cmd_mod_say,
	/client/proc/dsay,
	/datum/admins/proc/togglesleep,
	/client/proc/cmd_admin_subtle_message,
	/datum/admins/proc/viewUnheardAhelps,
	/datum/admins/proc/viewCLFaxes,
	/datum/admins/proc/viewUSCMFaxes
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
			if(config.debugparanoid && !check_rights(R_ADMIN))
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

	src << "<span class='interface'>Most of your adminverbs have been hidden.</span>"
	feedback_add_details("admin_verb","HMV") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/hide_verbs()
	set name = "Adminverbs - Hide All"
	set category = "Admin"

	remove_admin_verbs()
	verbs += /client/proc/show_verbs

	src << "<span class='interface'>Almost all of your adminverbs have been hidden.</span>"
	feedback_add_details("admin_verb","TAVVH") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/show_verbs()
	set name = "Adminverbs - Show"
	set category = "Admin"

	verbs -= /client/proc/show_verbs
	add_admin_verbs()

	src << "<span class='interface'>All of your adminverbs are now visible.</span>"
	feedback_add_details("admin_verb","TAVVS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!





/client/proc/admin_ghost()
	set category = "Admin"
	set name = "Aghost"
	if(!holder)	return
	if(istype(mob,/mob/dead/observer))
		//re-enter
		var/mob/dead/observer/ghost = mob
		if(!is_mentor(usr.client))
			ghost.can_reenter_corpse = 1
		if(ghost.can_reenter_corpse)
			ghost.reenter_corpse()
		else
			ghost << "<font color='red'>Error:  Aghost:  Can't reenter corpse, mentors that use adminHUD while aghosting are not permitted to enter their corpse again</font>"
			return

		feedback_add_details("admin_verb","P") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	else if(istype(mob,/mob/new_player))
		src << "<font color='red'>Error: Aghost: Can't admin-ghost whilst in the lobby. Join or Observe first.</font>"
	else
		//ghostize
		log_admin("[key_name(usr)] admin ghosted.")
		var/mob/body = mob
		body.ghostize(1)
		if(body && !body.key)
			body.key = "@[key]"	//Haaaaaaaack. But the people have spoken. If it breaks; blame adminbus
			if(body.client) body.client.change_view(world.view) //reset view range to default.
		feedback_add_details("admin_verb","O") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/invisimin()
	set name = "Invisimin"
	set category = "Admin"
	set desc = "Toggles ghost-like invisibility (Don't abuse this)"
	if(holder && mob)
		if(mob.invisibility == INVISIBILITY_OBSERVER)
			mob.invisibility = initial(mob.invisibility)
			mob << "\red <b>Invisimin off. Invisibility reset.</b>"
			mob.alpha = max(mob.alpha + 100, 255)
			mob.add_to_all_mob_huds()
		else
			mob.invisibility = INVISIBILITY_OBSERVER
			mob << "\blue <b>Invisimin on. You are now as invisible as a ghost.</b>"
			mob.alpha = max(mob.alpha - 100, 0)
			mob.remove_from_all_mob_huds()


/*
/client/proc/player_panel()
	set name = "Player Panel"
	set category = "Admin"
	if(holder)
		holder.player_panel_old()
	feedback_add_details("admin_verb","PP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return
*/

/client/proc/player_panel_new()
	set name = "Player Panel"
	set category = "Admin"
	if(holder)
		holder.player_panel_new()
	feedback_add_details("admin_verb","PPN") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/check_antagonists()
	set name = "Check Antagonists"
	set category = "Admin"
	if(holder)
		holder.check_antagonists()
		log_admin("[key_name(usr)] checked antagonists.")	//for tsar~
	feedback_add_details("admin_verb","CHA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/jobbans()
	set name = "Display Job Bans"
	set category = "Admin"
	if(holder)
		if(config.ban_legacy_system)
			holder.Jobbans()
		else
			holder.DB_ban_panel()
	feedback_add_details("admin_verb","VJB") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/unban_panel()
	set name = "Unban Panel"
	set category = "Admin"
	if(holder)
		if(config.ban_legacy_system)
			holder.unbanpanel()
		else
			holder.DB_ban_panel()
	feedback_add_details("admin_verb","UBP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/game_panel()
	set name = "Game Panel"
	set category = "Admin"
	if(holder)
		holder.Game()
	feedback_add_details("admin_verb","GP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/secrets()
	set name = "Secrets Panel"
	set category = "Admin"
	if (holder)
		holder.Secrets()
	feedback_add_details("admin_verb","S") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/set_ooc_color_self()
	set category = "OOC"
	set name = "OOC Text Color - Self"
	if(!holder && !donator)	return
	var/new_ooccolor = input(src, "Please select your OOC colour.", "OOC colour") as color|null
	if(new_ooccolor)
		prefs.ooccolor = new_ooccolor
		prefs.save_preferences()
	feedback_add_details("admin_verb","OC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/stealth()
	set category = "Admin"
	set name = "Stealth Mode"
	if(holder)
		if(holder.fakekey)
			holder.fakekey = null
		else
			var/new_key = ckeyEx(input("Enter your desired display name.", "Fake Key", key) as text|null)
			if(!new_key)	return
			if(length(new_key) >= 26)
				new_key = copytext(new_key, 1, 26)
			holder.fakekey = new_key
		log_admin("[key_name(usr)] has turned stealth mode [holder.fakekey ? "ON" : "OFF"]")
		message_admins("[key_name_admin(usr)] has turned stealth mode [holder.fakekey ? "ON" : "OFF"]", 1)
	feedback_add_details("admin_verb","SM") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

#define MAX_WARNS 3
#define AUTOBANTIME 10

/client/proc/warn(warned_ckey)
	if(!check_rights(R_ADMIN))	return

	if(!warned_ckey || !istext(warned_ckey))	return
	if(warned_ckey in admin_datums)
		usr << "<font color='red'>Error: warn(): You can't warn admins.</font>"
		return

	var/datum/preferences/D
	var/client/C = directory[warned_ckey]
	if(C)	D = C.prefs
	else	D = preferences_datums[warned_ckey]

	if(!D)
		src << "<font color='red'>Error: warn(): No such ckey found.</font>"
		return

	if(++D.warns >= MAX_WARNS)					//uh ohhhh...you'reee iiiiin trouuuubble O:)
		ban_unban_log_save("[ckey] warned [warned_ckey], resulting in a [AUTOBANTIME] minute autoban.")
		if(C)
			message_admins("[key_name_admin(src)] has warned [key_name_admin(C)] resulting in a [AUTOBANTIME] minute ban.")
			C << "<font color='red'><BIG><B>You have been autobanned due to a warning by [ckey].</B></BIG><br>This is a temporary ban, it will be removed in [AUTOBANTIME] minutes."
			cdel(C)
		else
			message_admins("[key_name_admin(src)] has warned [warned_ckey] resulting in a [AUTOBANTIME] minute ban.")
		AddBan(warned_ckey, D.last_id, "Autobanning due to too many formal warnings", ckey, 1, AUTOBANTIME)
		feedback_inc("ban_warn",1)
	else
		if(C)
			C << "<font color='red'><BIG><B>You have been formally warned by an administrator.</B></BIG><br>Further warnings will result in an autoban.</font>"
			message_admins("[key_name_admin(src)] has warned [key_name_admin(C)]. They have [MAX_WARNS-D.warns] strikes remaining.")
		else
			message_admins("[key_name_admin(src)] has warned [warned_ckey] (DC). They have [MAX_WARNS-D.warns] strikes remaining.")

	feedback_add_details("admin_verb","WARN") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

#undef MAX_WARNS
#undef AUTOBANTIME

/client/proc/drop_bomb() // Some admin dickery that can probably be done better -- TLE
	set category = "Fun"
	set name = "Drop Bomb"
	set desc = "Cause an explosion of varying strength at your location."

	var/turf/epicenter = mob.loc
	var/list/choices = list("CANCEL", "Small Bomb", "Medium Bomb", "Big Bomb", "Custom Bomb")
	var/choice = input("What size explosion would you like to produce?") in choices
	switch(choice)
		if("CANCEL")
			return 0
		if("Small Bomb")
			explosion(epicenter, 1, 2, 3, 3)
		if("Medium Bomb")
			explosion(epicenter, 2, 3, 4, 4)
		if("Big Bomb")
			explosion(epicenter, 3, 5, 7, 5)
		if("Custom Bomb")
			var/devastation_range = input("Devastation range (in tiles):") as num
			var/heavy_impact_range = input("Heavy impact range (in tiles):") as num
			var/light_impact_range = input("Light impact range (in tiles):") as num
			var/flash_range = input("Flash range (in tiles):") as num
			explosion(epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range)
	message_admins("\blue [ckey] used 'Drop Bomb' at [epicenter.loc].")
	feedback_add_details("admin_verb","DB") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/give_spell(mob/T as mob in mob_list) // -- Urist
	set category = "Fun"
	set name = "Give Spell"
	set desc = "Gives a spell to a mob."
	var/list/spell_names = list()
	for(var/v in spells)
	//	"/obj/effect/proc_holder/spell/" 30 symbols ~Intercross21
		spell_names.Add(copytext("[v]", 31, 0))
	var/S = input("Choose the spell to give to that guy", "ABRAKADABRA") as null|anything in spell_names
	if(!S) return
	var/path = text2path("/obj/effect/proc_holder/spell/[S]")
	T.spell_list += new path
	feedback_add_details("admin_verb","GS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(usr)] gave [key_name(T)] the spell [S].")
	message_admins("\blue [key_name_admin(usr)] gave [key_name(T)] the spell [S].", 1)

/client/proc/give_disease(mob/T as mob in mob_list) // -- Giacom
	set category = "Fun"
	set name = "Give Disease (old)"
	set desc = "Gives a (tg-style) Disease to a mob."
	var/list/disease_names = list()
	for(var/v in diseases)
	//	"/datum/disease/" 15 symbols ~Intercross
		disease_names.Add(copytext("[v]", 16, 0))
	var/datum/disease/D = input("Choose the disease to give to that guy", "ACHOO") as null|anything in disease_names
	if(!D) return
	var/path = text2path("/datum/disease/[D]")
	T.contract_disease(new path, 1)
	feedback_add_details("admin_verb","GD") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(usr)] gave [key_name(T)] the disease [D].")
	message_admins("\blue [key_name_admin(usr)] gave [key_name(T)] the disease [D].", 1)

/client/proc/make_sound(var/obj/O in object_list) // -- TLE
	set category = "Special Verbs"
	set name = "Make Sound"
	set desc = "Display a message to everyone who can hear the target"
	if(O)
		var/message = input("What do you want the message to be?", "Make Sound") as text|null
		if(!message)
			return
		for (var/mob/V in hearers(O))
			V.show_message(message, 2)
		log_admin("[key_name(usr)] made [O] at [O.x], [O.y], [O.z]. make a sound")
		message_admins("\blue [key_name_admin(usr)] made [O] at [O.x], [O.y], [O.z]. make a sound", 1)
		feedback_add_details("admin_verb","MS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/togglebuildmodeself()
	set name = "Toggle Build Mode Self"
	set category = "Fun"
	if(src.mob)
		togglebuildmode(src.mob)
	feedback_add_details("admin_verb","TBMS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/object_talk(var/msg as text) // -- TLE
	set category = "Special Verbs"
	set name = "Object Say"
	set desc = "Display a message to everyone who can hear the target"
	if(mob.control_object)
		if(!msg)
			return
		for (var/mob/V in hearers(mob.control_object))
			V.show_message("<b>[mob.control_object.name]</b> says: \"" + msg + "\"", 2)
	feedback_add_details("admin_verb","OT") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/*
/client/proc/kill_air() // -- TLE
	set category = "Debug"
	set name = "Kill Air"
	set desc = "Toggle Air Processing"
	if(air_processing_killed)
		air_processing_killed = 0
		usr << "<b>Enabled air processing.</b>"
	else
		air_processing_killed = 1
		usr << "<b>Disabled air processing.</b>"
	feedback_add_details("admin_verb","KA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(usr)] used 'kill air'.")
	message_admins("\blue [key_name_admin(usr)] used 'kill air'.", 1)
*/

/client/proc/deadmin_self()
	set name = "De-Admin Self"
	set category = "Admin"

	if(holder)
		if(alert("Confirm deadmin? This procedure can be reverted at any time and will not carry over to next round, but you will lose all your admin powers in the meantime.", , "Yes", "No") == "Yes")
			log_admin("[src] deadmined themselves.")
			message_admins("[src] deadmined themselves.", 1)
			verbs += /client/proc/readmin_self
			deadmin()
			src << "<br><br><span class='centerbold'><big>You are now a normal player. You can ascend back to adminhood at any time using the 'Re-admin Self' verb in your Admin panel.</big></span><br>"
	feedback_add_details("admin_verb", "DAS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/readmin_self()
	set name = "Re-admin Self"
	set category = "Admin"

	load_admins() //A bit ugly, but hey
	verbs -= /client/proc/readmin_self
	src << "<br><br><span class='centerbold'><big>You have ascended back to adminhood. All your verbs should be back where you left them.</big></span><br>"
	log_admin("[src] readmined themselves.")
	message_admins("[src] readmined themselves.", 1)
	feedback_add_details("admin_verb", "RAS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/toggle_log_hrefs()
	set name = "Toggle href Logging"
	set category = "Server"
	if(!holder)	return
	if(config)
		if(config.log_hrefs)
			config.log_hrefs = 0
			src << "<b>Stopped logging hrefs</b>"
		else
			config.log_hrefs = 1
			src << "<b>Started logging hrefs</b>"

/client/proc/check_ai_laws()
	set name = "Check AI Laws"
	set category = "Admin"
	if(holder)
		src.holder.output_ai_laws()


//---- bs12 verbs ----

/client/proc/mod_panel()
	set name = "Moderator Panel"
	set category = "Admin"
/*	if(holder)
		holder.mod_panel()*/
//	feedback_add_details("admin_verb","MP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/editappear(mob/living/carbon/human/M as mob in mob_list)
	set name = "Edit Appearance"
	set category = null

	if(!check_rights(R_FUN))	return

	if(!istype(M, /mob/living/carbon/human))
		usr << "\red You can only do this to humans!"
		return
	switch(alert("Are you sure you wish to edit this mob's appearance? Skrell, Unathi, Vox and Tajaran can result in unintended consequences.",,"Yes","No"))
		if("No")
			return
	var/new_facial = input("Please select facial hair color.", "Character Generation") as color
	if(new_facial)
		M.r_facial = hex2num(copytext(new_facial, 2, 4))
		M.g_facial = hex2num(copytext(new_facial, 4, 6))
		M.b_facial = hex2num(copytext(new_facial, 6, 8))

	var/new_hair = input("Please select hair color.", "Character Generation") as color
	if(new_facial)
		M.r_hair = hex2num(copytext(new_hair, 2, 4))
		M.g_hair = hex2num(copytext(new_hair, 4, 6))
		M.b_hair = hex2num(copytext(new_hair, 6, 8))

	var/new_eyes = input("Please select eye color.", "Character Generation") as color
	if(new_eyes)
		M.r_eyes = hex2num(copytext(new_eyes, 2, 4))
		M.g_eyes = hex2num(copytext(new_eyes, 4, 6))
		M.b_eyes = hex2num(copytext(new_eyes, 6, 8))

	var/new_skin = input("Please select body color. This is for Tajaran, Unathi, and Skrell only!", "Character Generation") as color
	if(new_skin)
		M.r_skin = hex2num(copytext(new_skin, 2, 4))
		M.g_skin = hex2num(copytext(new_skin, 4, 6))
		M.b_skin = hex2num(copytext(new_skin, 6, 8))


	// hair
	var/new_hstyle = input(usr, "Select a hair style", "Grooming")  as null|anything in hair_styles_list
	if(new_hstyle)
		M.h_style = new_hstyle

	// facial hair
	var/new_fstyle = input(usr, "Select a facial hair style", "Grooming")  as null|anything in facial_hair_styles_list
	if(new_fstyle)
		M.f_style = new_fstyle

	var/new_gender = alert(usr, "Please select gender.", "Character Generation", "Male", "Female")
	if (new_gender)
		if(new_gender == "Male")
			M.gender = MALE
		else
			M.gender = FEMALE
	M.update_hair()
	M.update_body()
	M.check_dna(M)

/client/proc/player_notes_list()
	set name = "Player Notes List"
	set category = "Admin"
	if(holder)
		holder.player_notes_list()
	return

/client/proc/free_slot()
	set name = "Job Slots - Free"
	set category = "Admin"
	if(holder)
		var/roles[] = new
		var/i
		var/datum/job/J
		for (i in RoleAuthority.roles_for_mode) //All the roles in the game.
			J = RoleAuthority.roles_for_mode[i]
			if(J.total_positions != -1 && J.get_total_positions(1) <= J.current_positions) roles += i
		if (!roles.len)
			usr << "There are no fully staffed roles."
			return
		var/role = input("Please select role slot to free", "Free role slot")  as null|anything in roles
		RoleAuthority.free_role(RoleAuthority.roles_for_mode[role])

/client/proc/toggleattacklogs()
	set name = "Toggle Attack Log Messages"
	set category = "Preferences"

	prefs.toggles_chat ^= CHAT_ATTACKLOGS
	if (prefs.toggles_chat & CHAT_ATTACKLOGS)
		usr << "<span class='boldnotice'>You will now get attack log messages.</span>"
	else
		usr << "<span class='boldnotice'>You will no longer get attack log messages.</span>"

/client/proc/toggleffattacklogs()
	set name = "Toggle FF Attack Log Messages"
	set category = "Preferences"

	prefs.toggles_chat ^= CHAT_FFATTACKLOGS
	if (prefs.toggles_chat & CHAT_FFATTACKLOGS)
		usr << "<span class='boldnotice'>You will now get friendly fire attack log messages.</span>"
	else
		usr << "<span class='boldnotice'>You will no longer get friendly fire attack log messages.</span>"


/client/proc/toggleghostwriters()
	set name = "Toggle Ghost Blood Writing"
	set category = "Server"
	if(!holder)	return
	if(config)
		if(config.cult_ghostwriter)
			config.cult_ghostwriter = 0
			src << "<b>Disallowed ghost writers.</b>"
			message_admins("Admin [key_name_admin(usr)] has disabled ghost writers.", 1)
		else
			config.cult_ghostwriter = 1
			src << "<b>Enabled ghost writers.</b>"
			message_admins("Admin [key_name_admin(usr)] has enabled ghost writers.", 1)

/client/proc/toggledrones()
	set name = "Toggle Maintenance Drones"
	set category = "Server"
	if(!holder)	return
	if(config)
		if(config.allow_drone_spawn)
			config.allow_drone_spawn = 0
			src << "<b>Disallowed maint drones.</b>"
			message_admins("Admin [key_name_admin(usr)] has disabled maint drones.", 1)
		else
			config.allow_drone_spawn = 1
			src << "<b>Enabled maint drones.</b>"
			message_admins("Admin [key_name_admin(usr)] has enabled maint drones.", 1)

/client/proc/toggledebuglogs()
	set name = "Toggle Debug Log Messages"
	set category = "Preferences"

	prefs.toggles_chat ^= CHAT_DEBUGLOGS
	if(prefs.toggles_chat & CHAT_DEBUGLOGS)
		usr << "<span class='boldnotice'>You will now get debug log messages.</span>"
	else
		usr << "<span class='boldnotice'>You will no longer get debug log messages.</span>"

/* Commenting this stupid shit out
/client/proc/man_up(mob/T as mob in mob_list)
	set category = "Fun"
	set name = "Man Up"
	set desc = "Tells mob to man up and deal with it."

	T << "<span class='notice'><b><font size=3>Man up and deal with it.</font></b></span>"
	T << "<span class='notice'>Move on.</span>"

	log_admin("[key_name(usr)] told [key_name(T)] to man up and deal with it.")
	message_admins("\blue [key_name_admin(usr)] told [key_name(T)] to man up and deal with it.", 1)

/client/proc/global_man_up()
	set category = "Fun"
	set name = "Man Up Global"
	set desc = "Tells everyone to man up and deal with it."

	for (var/mob/T as mob in mob_list)
		T << "<br><center><span class='notice'><b><font size=4>Man up.<br> Deal with it.</font></b><br>Move on.</span></center><br>"
		T << 'sound/voice/ManUp1.ogg'

	log_admin("[key_name(usr)] told everyone to man up and deal with it.")
	message_admins("\blue [key_name_admin(usr)] told everyone to man up and deal with it.", 1)
*/

/client/proc/change_security_level()
	set name = "Set Security Level"
	set desc = "Sets the station security level"
	set category = "Fun"

	if(!check_rights(R_ADMIN))	return
	var sec_level = input(usr, "It's currently code [get_security_level()].", "Select Security Level")  as null|anything in (list("green","blue","red","delta")-get_security_level())
	if(sec_level && alert("Switch from code [get_security_level()] to code [sec_level]?","Change security level?","Yes","No") == "Yes")
		set_security_level(sec_level)
		log_admin("[key_name(usr)] changed the security level to code [sec_level].")

/client/proc/toggle_gun_restrictions()
	set name = "Toggle Gun Restrictions"
	set desc = "Toggling to on will allow anyone to use restricted WY superguns. Leave this alone unless you know what you're doing."
	set category = "Server"

	if(!holder)	return
	if(config)
		if(config.remove_gun_restrictions)
			src << "<b>Enabled gun restrictions.</b>"
			message_admins("Admin [key_name_admin(usr)] has enabled WY gun restrictions.", 1)
			log_admin("[key_name(src)] enabled WY gun restrictions.")
		else
			src << "<b>Disabled gun restrictions.</b>"
			message_admins("Admin [key_name_admin(usr)] has disabled WY gun restrictions.", 1)
			log_admin("[key_name(src)] disabled WY gun restrictions.")
		config.remove_gun_restrictions = !config.remove_gun_restrictions

/client/proc/toggle_synthetic_restrictions()
	set name = "Toggle Synthetic Gun Use"
	set desc = "Toggling to on will allow synthetics to fire guns. Leave this alone unless you know what you're doing."
	set category = "Server"

	if(!holder)	return
	if(config)
		if(config.allow_synthetic_gun_use)
			src << "<b>Synthetic gun use allowed.</b>"
			message_admins("Admin [key_name_admin(usr)] has disabled synthetic gun use.", 1)
			log_admin("[key_name(src)] disabled synthetic gun use.")
		else
			src << "<b>Synthetic gun use disallowed.</b>"
			message_admins("Admin [key_name_admin(usr)] has synthetic gun use.", 1)
			log_admin("[key_name(src)] allowed synthetic gun use.")
		config.allow_synthetic_gun_use = !config.allow_synthetic_gun_use

/client/proc/adjust_weapon_mult()
	set name = "Adjust Weapon Multipliers"
	set desc = "Using this allow to change how much accuracy and damage are changed. 1 is the normal number, anything higher will increase damage and/or accuracy."
	set category = "Fun"

	if(!holder)	return
	if(config)
		var/acc = input("Select the new accuracy multiplier.","ACCURACY MULTIPLIER", 1) as num
		var/dam = input("Select the new damage multiplier.","DAMAGE MULTIPLIER", 1) as num
		if(acc && dam)
			config.proj_base_accuracy_mult = acc * 0.01
			config.proj_base_damage_mult = dam * 0.01
			log_admin("Admin [key_name_admin(usr)] changed global accuracy to <b>[acc]</b> and global damage to <b>[dam]</b>.", 1)
			log_debug("<b>[key_name(src)]</b> changed global accuracy to <b>[acc]</b> and global damage to <b>[dam]</b>.")

/client/proc/set_away_timer()
	set name = "Set Xeno Away Timer in View"
	set desc = "Set the away_timer of all clientless Xenos in view to 300 to allow players to become them."
	set category = "Fun"
	if(!holder)	return

	if(alert("Are you sure you want to set the away_timer of all visible Xenos to 300? Make sure there aren't any visible AFK Xenos with players that might return!",, "Confirm", "Cancel") == "Cancel") return

	for(var/mob/living/carbon/Xenomorph/X in view())
		if(X.client) continue
		X.away_timer = 300

	log_admin("Admin [key_name_admin(usr)] set the away_timer of nearby clientless Xenos to 300.", 1)
	message_admins("<b>[key_name(src)]</b> set the away_timer of nearby clientless Xenos to 300.", 1)
