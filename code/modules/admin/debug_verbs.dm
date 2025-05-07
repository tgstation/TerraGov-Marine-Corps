ADMIN_VERB(delete_all, R_DEBUG, "Delete Instances", "Delete all instances of something", ADMIN_CATEGORY_DEBUG) // todo why does this exist instead of sdql

	var/blocked = list(/obj, /obj/item, /obj/effect, /obj/machinery, /mob, /mob/living, /mob/living/carbon, /mob/living/carbon/xenomorph, /mob/living/carbon/human, /mob/dead, /mob/dead/observer, /mob/living/silicon, /mob/living/silicon/ai)
	var/chosen_deletion = input(user, "Type the path of the object you want to delete", "Delete:") as null|text

	if(!chosen_deletion)
		return

	chosen_deletion = text2path(chosen_deletion)
	if(!ispath(chosen_deletion))
		return

	if(!ispath(/mob) && !ispath(/obj))
		to_chat(user,
			type = MESSAGE_TYPE_DEBUG,
			html = span_warning("Only works for types of /obj or /mob.</span>"))
		return

	var/hsbitem = input(user, "Choose an object to delete.", "Delete:") as null|anything in typesof(chosen_deletion)
	if(!hsbitem)
		return

	var/do_delete = TRUE
	if(hsbitem in blocked)
		if(alert("Are you REALLY sure you wish to delete all instances of [hsbitem]? This will lead to catastrophic results!",,"Yes","No") != "Yes")
			do_delete = FALSE

	var/del_amt = 0
	if(!do_delete)
		return

	for(var/atom/O in world)
		if(istype(O, hsbitem))
			del_amt++
			qdel(O)

	log_admin("[key_name(user)] deleted all instances of [hsbitem] ([del_amt]).")
	message_admins("[ADMIN_TPMONTY(user.mob)] deleted all instances of [hsbitem] ([del_amt]).")

ADMIN_VERB(generate_powernets, R_DEBUG, "Generate Powernets", "Regenerate all powernets.", ADMIN_CATEGORY_DEBUG)
	SSmachines.makepowernets()

	log_admin("[key_name(user)] has remade powernets.")
	message_admins("[ADMIN_TPMONTY(user.mob)] has remade powernets.")


ADMIN_VERB(debug_mob_lists, R_DEBUG, "Debug Mob Lists", "Debug mob globals", ADMIN_CATEGORY_DEBUG)
	var/list/options = list("Players", "Observers", "New Players", "Admins", "Clients", "Mobs", "Living Mobs", "Alive Living Mobs", "Dead Mobs", "Xenos", "Alive Xenos", "Dead Xenos", "Humans", "Alive Humans", "Dead Humans")
	var/choice = tgui_input_list(user, "Which list?", "Global Mob List debugging", options)
	if(!choice)
		return

	var/dat
	switch(choice)
		if("Players")
			for(var/i in GLOB.player_list)
				var/mob/M = i
				dat += "[M] [ADMIN_VV(M)]<br>"
		if("Observers")
			for(var/i in GLOB.observer_list)
				var/mob/M = i
				dat += "[M] [ADMIN_VV(M)]<br>"
		if("New Players")
			for(var/i in GLOB.new_player_list)
				var/mob/M = i
				dat += "[M] [ADMIN_VV(M)]<br>"
		if("Admins")
			for(var/i in GLOB.admins)
				var/mob/M = i
				dat += "[M] [ADMIN_VV(M)]<br>"
		if("Clients")
			for(var/i in GLOB.clients)
				var/mob/M = i
				dat += "[M] [ADMIN_VV(M)]<br>"
		if("Mobs")
			for(var/i in GLOB.mob_list)
				var/mob/M = i
				dat += "[M] [ADMIN_VV(M)]<br>"
		if("Living Mobs")
			for(var/i in GLOB.mob_living_list)
				var/mob/M = i
				dat += "[M] [ADMIN_VV(M)]<br>"
		if("Alive Living Mobs")
			for(var/i in GLOB.alive_living_list)
				var/mob/M = i
				dat += "[M] [ADMIN_VV(M)]<br>"
		if("Dead Mobs")
			for(var/i in GLOB.dead_mob_list)
				var/mob/M = i
				dat += "[M] [ADMIN_VV(M)]<br>"
		if("Xenos")
			for(var/i in GLOB.xeno_mob_list)
				var/mob/M = i
				dat += "[M] [ADMIN_VV(M)]<br>"
		if("Alive Xenos")
			for(var/i in GLOB.alive_xeno_list)
				var/mob/M = i
				dat += "[M] [ADMIN_VV(M)]<br>"
		if("Dead Xenos")
			for(var/i in GLOB.dead_xeno_list)
				var/mob/M = i
				dat += "[M] [ADMIN_VV(M)]<br>"
		if("Humans")
			for(var/i in GLOB.human_mob_list)
				var/mob/M = i
				dat += "[M] [ADMIN_VV(M)]<br>"
		if("Alive Humans")
			for(var/i in GLOB.alive_human_list)
				var/mob/M = i
				dat += "[M] [ADMIN_VV(M)]<br>"
		if("Dead Humans")
			for(var/i in GLOB.dead_human_list)
				var/mob/M = i
				dat += "[M] [ADMIN_VV(M)]<br>"

	var/datum/browser/browser = new(user, "moblists", "<div align='center'>[choice]</div>")
	browser.set_content(dat)
	browser.open(FALSE)

	log_admin("[key_name(user)] is debugging the [choice] list.")
	message_admins("[ADMIN_TPMONTY(user.mob)] is debugging the [choice] list.")


ADMIN_VERB(spawn_atom, R_SPAWN, "Spawn", "(atom path) Spawn an atom", ADMIN_CATEGORY_DEBUG, object as text)
	if(!object)
		return
	var/list/preparsed = splittext(object,":")
	var/path = preparsed[1]
	var/amount = 1
	if(length(preparsed) > 1)
		amount = clamp(text2num(preparsed[2]),1,ADMIN_SPAWN_CAP)

	var/chosen = pick_closest_path(path)
	if(!chosen)
		return
	var/turf/T = get_turf(user.mob)

	if(ispath(chosen, /turf))
		T.ChangeTurf(chosen)
	else
		for(var/i in 1 to amount)
			var/atom/A = new chosen(T)
			A.atom_flags |= ADMIN_SPAWNED

	log_admin("[key_name(user)] spawned [amount] x [chosen] at [AREACOORD(user.mob)]")

ADMIN_VERB_AND_CONTEXT_MENU(delete_atom, R_DEBUG, "Delete", ADMIN_VERB_NO_DESCRIPTION, ADMIN_CATEGORY_HIDDEN, atom/target as obj|mob|turf in world)
	if(alert(user, "Are you sure you want to delete: [target]?", "Delete", "Yes", "No") != "Yes")
		return

	if(QDELETED(target))
		return

	var/turf/T = get_turf(target)

	log_admin("[key_name(user)] deleted [target]([target.type]) at [AREACOORD(T)].")
	message_admins("[ADMIN_TPMONTY(user.mob)] deleted [target]([target.type]) at [ADMIN_VERBOSEJMP(T)].")

	if(isturf(target))
		var/turf/deleting_turf = target
		deleting_turf.ScrapeAway()
		return

	qdel(target)

ADMIN_VERB(restart_controller, R_DEBUG, "Restart Controller", "Restart one of the various periodic loop controllers for the game (be careful!)", ADMIN_CATEGORY_DEBUG, controller in list("Master", "Failsafe"))
	switch(controller)
		if("Master")
			Recreate_MC()
			BLACKBOX_LOG_ADMIN_VERB("Restart Master Controller")
		if("Failsafe")
			new /datum/controller/failsafe()
			BLACKBOX_LOG_ADMIN_VERB("Restart Failsafe Controller")

	message_admins("Admin [key_name_admin(user)] has restarted the [controller] controller.")

ADMIN_VERB(debug_controller, R_DEBUG, "Debug Controller", "Debug the various periodic loop controllers for the game (be careful!)", ADMIN_CATEGORY_DEBUG)
	var/list/controllers = list()
	var/list/controller_choices = list()

	for(var/datum/controller/controller)
		if(istype(controller, /datum/controller/subsystem))
			continue
		controllers["[controller] (controller.type)"] = controller //we use an associated list to ensure clients can't hold references to controllers
		controller_choices += "[controller] (controller.type)"

	var/datum/controller/controller_string = input(user, "Select controller to debug", "Debug Controller") as null|anything in controller_choices
	var/datum/controller/controller = controllers[controller_string]

	if(!istype(controller))
		return
	SSadmin_verbs.dynamic_invoke_verb(user, /datum/admin_verb/debug_variables, controller)

	log_admin("[key_name(user)] is debugging the [controller] controller.")
	message_admins("Admin [key_name_admin(user)] is debugging the [controller] controller.")

ADMIN_VERB(reestablish_db_connection, R_DEBUG, "Reestablish DB Connection", "Attempts to (re)establish the DB Connection", ADMIN_CATEGORY_SERVER)
	if(!CONFIG_GET(flag/sql_enabled))
		to_chat(usr, span_adminnotice("The Database is not enabled!"))
		return

	if(SSdbcore.IsConnected(TRUE))
		if(alert("The database is already connected! If you *KNOW* that this is incorrect, you can force a reconnection", "The database is already connected!", "Force Reconnect", "Cancel") != "Force Reconnect")
			return

		SSdbcore.Disconnect()
		log_admin("[key_name(usr)] has forced the database to disconnect")
		message_admins("[ADMIN_TPMONTY(usr)] has forced the database to disconnect!")

	log_admin("[key_name(usr)] is attempting to re-established the DB Connection.")
	message_admins("[ADMIN_TPMONTY(usr)] is attempting to re-established the DB Connection.")

	SSdbcore.failed_connections = 0

	if(!SSdbcore.Connect())
		log_admin("Database connection failed: " + SSdbcore.ErrorMsg())
		message_admins("Database connection failed: " + SSdbcore.ErrorMsg())
	else
		log_admin("Database connection re-established!")
		message_admins("Database connection re-established!")

/// A debug verb to try and re-establish a connection with the TTS server and to refetch TTS voices.
/// Since voices are cached beforehand, this is unlikely to update preferences.
ADMIN_VERB(reestablish_tts_connection, R_DEBUG, "Re-establish Connection To TTS", "Re-establishes connection to the TTS server if possible", ADMIN_CATEGORY_SERVER)
	message_admins("[key_name_admin(user)] attempted to re-establish connection to the TTS HTTP server.")
	log_admin("[key_name(user)] attempted to re-establish connection to the TTS HTTP server.")
	var/success = SStts.establish_connection_to_tts()
	if(!success)
		message_admins("[key_name_admin(user)] failed to re-established the connection to the TTS HTTP server.")
		log_admin("[key_name(user)] failed to re-established the connection to the TTS HTTP server.")
		return
	message_admins("[key_name_admin(user)] successfully re-established the connection to the TTS HTTP server.")
	log_admin("[key_name(user)] successfully re-established the connection to the TTS HTTP server.")

ADMIN_VERB(view_runtimes, R_DEBUG, "View Runtimes", "Opens the runtime viewer.", ADMIN_CATEGORY_DEBUG)
	GLOB.error_cache.show_to(user)

	// The runtime viewer has the potential to crash the server if there's a LOT of runtimes
	// this has happened before, multiple times, so we'll just leave an alert on it
	if(GLOB.total_runtimes >= 50000) // arbitrary number, I don't know when exactly it happens
		var/warning = "There are a lot of runtimes, clicking any button (especially \"linear\") can have the potential to lag or crash the server"
		if(GLOB.total_runtimes >= 100000)
			warning = "There are a TON of runtimes, clicking any button (especially \"linear\") WILL LIKELY crash the server"
		// Not using TGUI alert, because it's view runtimes, stuff is probably broken
		alert(user, "[warning]. Proceed with caution. If you really need to see the runtimes, download the runtime log and view it in a text editor.", "HEED THIS WARNING CAREFULLY MORTAL")

ADMIN_VERB(spatial_agent, R_FUN, "Spatial Agent", "Become a spatial agent", ADMIN_CATEGORY_DEBUG)
	var/mob/M = user.mob
	var/mob/living/carbon/human/H
	var/spatial = FALSE
	if(ishuman(M))
		H = M
		var/datum/job/J = H.job
		spatial = istype(J, /datum/job/spatial_agent)

	if(spatial)
		log_admin("[key_name(M)] stopped being a spatial agent.")
		message_admins("[ADMIN_TPMONTY(M)] stopped being a spatial agent.")
		qdel(M)
	else
		H = new(get_turf(M))
		M.client.prefs.copy_to(H)
		M.mind.transfer_to(H, TRUE)
		var/datum/job/J = SSjob.GetJobType(/datum/job/spatial_agent)
		H.apply_assigned_role_to_spawn(J)
		J.after_spawn(H)
		qdel(M)

		log_admin("[key_name(H)] became a spatial agent.")
		message_admins("[ADMIN_TPMONTY(H)] became a spatial agent.")

ADMIN_VERB(check_bomb_impacts, R_DEBUG, "Check Bomb Impact", "Show the impact of a bomb with overlays", ADMIN_CATEGORY_DEBUG)
	var/devastation_range = 0
	var/heavy_impact_range = 0
	var/light_impact_range = 0
	var/choice = input(user, "Bomb Size?") in list("Small Bomb", "Medium Bomb", "Big Bomb", "Maxcap", "Custom Bomb", "Check Range")
	switch(choice)
		if("Small Bomb")
			devastation_range = 1
			heavy_impact_range = 2
			light_impact_range = 3
		if("Medium Bomb")
			devastation_range = 2
			heavy_impact_range = 3
			light_impact_range = 4
		if("Big Bomb")
			devastation_range = 3
			heavy_impact_range = 5
			light_impact_range = 7
		if("Maxcap")
			devastation_range = GLOB.MAX_EX_DEVESTATION_RANGE
			heavy_impact_range = GLOB.MAX_EX_HEAVY_RANGE
			light_impact_range = GLOB.MAX_EX_LIGHT_RANGE
		if("Custom Bomb")
			devastation_range = input(user, "Devastation range (Tiles):") as num
			heavy_impact_range = input(user, "Heavy impact range (Tiles):") as num
			light_impact_range = input(user, "Light impact range (Tiles):") as num
		else
			return

	var/turf/epicenter = get_turf(usr)
	if(!epicenter)
		return

	var/max_range = max(devastation_range, heavy_impact_range, light_impact_range)

	var/list/turfs_in_range = block(
		locate(
			max(epicenter.x - max_range, 1),
			max(epicenter.y - max_range, 1),
			epicenter.z
			),
		locate(
			min(epicenter.x + max_range, world.maxx),
			min(epicenter.y + max_range, world.maxy),
			epicenter.z
			)
		)

	var/current_exp_block = epicenter.density ? epicenter.explosion_block : 0
	for(var/obj/blocking_object in epicenter)
		if(!blocking_object.density)
			continue
		current_exp_block += ( (blocking_object.explosion_block == EXPLOSION_BLOCK_PROC) ? blocking_object.GetExplosionBlock(0) : blocking_object.explosion_block ) //0 is the result of get_dir between two atoms on the same tile.

	var/list/turfs_by_dist = list()
	turfs_by_dist[epicenter] = current_exp_block
	turfs_in_range[epicenter] = current_exp_block

	if(devastation_range > 0)
		epicenter.color = "blue"
		epicenter.maptext = "D (E) ([current_exp_block])"
	else if(heavy_impact_range > 0)
		epicenter.color = "red"
		epicenter.maptext = "H (E) ([current_exp_block])"
	else if(light_impact_range > 0)
		epicenter.color = "yellow"
		epicenter.maptext = "L  (E) ([current_exp_block])"
	else
		return
	var/list/wipe_colours = list(epicenter)

	for(var/t in turfs_in_range)
		if(!isnull(turfs_by_dist[t])) //Already processed.
			continue

		var/turf/affected_turf = t
		var/dist = turfs_in_range[epicenter]
		var/turf/expansion_wave_loc = epicenter

		do
			var/expansion_dir = get_dir(expansion_wave_loc, affected_turf)
			if(ISDIAGONALDIR(expansion_dir)) //If diagonal we'll try to choose the easy path, even if it might be longer. Damn, we're lazy.
				var/turf/step_NS = get_step(expansion_wave_loc, expansion_dir & (NORTH|SOUTH))
				if(!turfs_in_range[step_NS])
					current_exp_block = step_NS.density ? step_NS.explosion_block : 0
					for(var/obj/blocking_object in step_NS)
						if(!blocking_object.density)
							continue
						current_exp_block += ( (blocking_object.explosion_block == EXPLOSION_BLOCK_PROC) ? blocking_object.GetExplosionBlock(get_dir(epicenter, expansion_wave_loc)) : blocking_object.explosion_block )
					turfs_in_range[step_NS] = current_exp_block

				var/turf/step_EW = get_step(expansion_wave_loc, expansion_dir & (EAST|WEST))
				if(!turfs_in_range[step_EW])
					current_exp_block = step_EW.density ? step_EW.explosion_block : 0
					for(var/obj/blocking_object in step_EW)
						if(!blocking_object.density)
							continue
						current_exp_block += ( (blocking_object.explosion_block == EXPLOSION_BLOCK_PROC) ? blocking_object.GetExplosionBlock(get_dir(epicenter, expansion_wave_loc)) : blocking_object.explosion_block )
					turfs_in_range[step_EW] = current_exp_block

				if(turfs_in_range[step_NS] < turfs_in_range[step_EW])
					expansion_wave_loc = step_NS
				else if(turfs_in_range[step_NS] > turfs_in_range[step_EW])
					expansion_wave_loc = step_EW
				else if(abs(expansion_wave_loc.x - affected_turf.x) < abs(expansion_wave_loc.y - affected_turf.y)) //Both directions offer the same resistance. Lets check if the direction pends towards either cardinal.
					expansion_wave_loc = step_NS
				else //Either perfect diagonal, in which case it doesn't matter, or leaning towards the X axis.
					expansion_wave_loc = step_EW
			else
				expansion_wave_loc = get_step(expansion_wave_loc, expansion_dir)

			dist++

			if(isnull(turfs_in_range[expansion_wave_loc]))
				current_exp_block = expansion_wave_loc.density ? expansion_wave_loc.explosion_block : 0
				for(var/obj/blocking_object in expansion_wave_loc)
					if(!blocking_object.density)
						continue
					current_exp_block += ( (blocking_object.explosion_block == EXPLOSION_BLOCK_PROC) ? blocking_object.GetExplosionBlock(get_dir(epicenter, expansion_wave_loc)) : blocking_object.explosion_block )
				turfs_in_range[expansion_wave_loc] = current_exp_block

			if(isnull(turfs_by_dist[expansion_wave_loc]))
				wipe_colours += expansion_wave_loc
				turfs_by_dist[expansion_wave_loc] = dist
				if(devastation_range > dist)
					expansion_wave_loc.color = "blue"
					expansion_wave_loc.maptext = "D ([dist])"
				else if(heavy_impact_range > dist)
					expansion_wave_loc.color = "red"
					expansion_wave_loc.maptext = "H ([dist])"
				else if(light_impact_range > dist)
					expansion_wave_loc.color = "yellow"
					expansion_wave_loc.maptext = "L ([dist])"
				else
					expansion_wave_loc.color = "green"
					expansion_wave_loc.maptext = "N ([dist])"
					break //Explosion ran out of gas, no use continuing.
			else if(turfs_by_dist[expansion_wave_loc] > dist)
				expansion_wave_loc.color = "purple"
				expansion_wave_loc.maptext = "D (Diff: [dist] vs [turfs_by_dist[expansion_wave_loc]])"
				turfs_by_dist[expansion_wave_loc] = dist

			dist += turfs_in_range[expansion_wave_loc]

			if(dist >= max_range)
				break //Explosion ran out of gas, no use continuing.

		while(expansion_wave_loc != affected_turf)

		if(isnull(turfs_by_dist[affected_turf]))
			wipe_colours += affected_turf
			turfs_by_dist[affected_turf] = 9999
			affected_turf.maptext = "N (null)"

	addtimer(CALLBACK(GLOBAL_PROC, PROC_REF(wipe_color_and_text), wipe_colours), 10 SECONDS)

/proc/wipe_color_and_text(list/atom/wiping)
	for(var/i in wiping)
		var/atom/atom_to_clean = i
		atom_to_clean.color = null
		atom_to_clean.maptext = ""

ADMIN_VERB(cmd_display_del_log, R_DEBUG, "Display del() Log", "Display del's log of everything that's passed through it.", ADMIN_CATEGORY_DEBUG)
	var/list/dellog = list("<B>List of things that have gone through qdel this round</B><BR><BR><ol>")
	sortTim(SSgarbage.items, cmp=/proc/cmp_qdel_item_time, associative = TRUE)
	for(var/path in SSgarbage.items)
		var/datum/qdel_item/I = SSgarbage.items[path]
		dellog += "<li><u>[path]</u><ul>"
		if (I.qdel_flags & QDEL_ITEM_SUSPENDED_FOR_LAG)
			dellog += "<li>SUSPENDED FOR LAG</li>"
		if (I.failures)
			dellog += "<li>Failures: [I.failures]</li>"
		dellog += "<li>qdel() Count: [I.qdels]</li>"
		dellog += "<li>Destroy() Cost: [I.destroy_time]ms</li>"
		if (I.hard_deletes)
			dellog += "<li>Total Hard Deletes [I.hard_deletes]</li>"
			dellog += "<li>Time Spent Hard Deleting: [I.hard_delete_time]ms</li>"
			dellog += "<li>Highest Time Spent Hard Deleting: [I.hard_delete_max]ms</li>"
			if (I.hard_deletes_over_threshold)
				dellog += "<li>Hard Deletes Over Threshold: [I.hard_deletes_over_threshold]</li>"
		if (I.slept_destroy)
			dellog += "<li>Sleeps: [I.slept_destroy]</li>"
		if (I.no_respect_force)
			dellog += "<li>Ignored force: [I.no_respect_force]</li>"
		if (I.no_hint)
			dellog += "<li>No hint: [I.no_hint]</li>"
		dellog += "</ul></li>"

	dellog += "</ol>"

	var/datum/browser/browser = new(usr, "dellog", "Del Log", 00, 400)
	browser.set_content(dellog.Join())
	browser.open()


ADMIN_VERB(debug_plane_masters, R_DEBUG, "Edit/Debug Planes", "Edit and visualize plane masters and their connections (relays).", ADMIN_CATEGORY_DEBUG)
	user.edit_plane_masters()

/client/proc/edit_plane_masters(mob/debug_on)
	if(!holder)
		return
	if(debug_on)
		holder.plane_debug.set_mirroring(TRUE)
		holder.plane_debug.set_target(debug_on)
	else
		holder.plane_debug.set_mirroring(FALSE)
	holder.plane_debug.ui_interact(mob)

ADMIN_VERB(debug_statpanel, R_DEBUG, "Debug Stat Panel", "Toggles local debug of the stat panel", ADMIN_CATEGORY_DEBUG)
	user.stat_panel.send_message("create_debug")

ADMIN_VERB(display_sendmaps, R_DEBUG, "Send Maps Profile", "View the profile.", ADMIN_CATEGORY_DEBUG)
	user << link("?debug=profile&type=sendmaps&window=test")

ADMIN_VERB(allow_browser_inspect, R_DEBUG, "Allow Browser Inspect", "Allow browser debugging via inspect", ADMIN_CATEGORY_DEBUG)
	if(user.byond_version < 516)
		to_chat(user, span_warning("You can only use this on 516!"))
		return

	to_chat(user, span_notice("You can now right click to use inspect on browsers."))
	winset(user, null, list("browser-options" = "+devtools"))

#ifdef TESTING
GLOBAL_LIST_EMPTY(dirty_vars)

ADMIN_VERB_VISIBILITY(see_dirty_varedits, ADMIN_VERB_VISIBLITY_FLAG_MAPPING_DEBUG)
ADMIN_VERB(see_dirty_varedits, R_DEBUG, "Dirty Varedits", "Shows all dirty varedits.", ADMIN_CATEGORY_DEBUG)
	var/list/dat = list()
	dat += "<h3>Abandon all hope ye who enter here</h3><br><br>"
	for(var/thing in GLOB.dirty_vars)
		dat += "[thing]<br>"
		CHECK_TICK
	var/datum/browser/popup = new(user, "dirty_vars", "Dirty Varedits", 900, 750)
	popup.set_content(dat.Join())
	popup.open()
#endif
