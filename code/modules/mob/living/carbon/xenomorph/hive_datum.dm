/datum/hive_status
	var/name = "Normal"
	var/hivenumber = XENO_HIVE_NORMAL
	var/mob/living/carbon/xenomorph/queen/living_xeno_queen
	var/mob/living/carbon/xenomorph/living_xeno_ruler
	var/slashing_allowed = XENO_SLASHING_ALLOWED //This initial var allows the queen to turn on or off slashing. Slashing off means harm intent does much less damage.
	var/xeno_queen_timer
	var/xenos_per_queen = 8 //Minimum number of xenos to support a queen.
	var/hive_orders = "" //What orders should the hive have
	var/color = null
	var/prefix = ""
	var/hive_flags = NONE
	var/list/xeno_leader_list
	var/list/list/xenos_by_typepath
	var/list/list/xenos_by_tier
	var/list/list/xenos_by_upgrade
	var/list/dead_xenos // xenos that are still assigned to this hive but are dead.
	var/list/ssd_xenos
	var/list/list/xenos_by_zlevel
	var/tier3_xeno_limit
	var/tier2_xeno_limit
	///Queue of all observer wanting to join xeno side
	var/list/mob/dead/observer/candidate

// ***************************************
// *********** Init
// ***************************************
/datum/hive_status/New()
	. = ..()
	xeno_leader_list = list()
	xenos_by_typepath = list()
	xenos_by_tier = list()
	xenos_by_upgrade = list()
	dead_xenos = list()
	xenos_by_zlevel = list()
	LAZYINITLIST(candidate)

	for(var/t in subtypesof(/mob/living/carbon/xenomorph))
		var/mob/living/carbon/xenomorph/X = t
		xenos_by_typepath[initial(X.caste_base_type)] = list()

	for(var/tier in GLOB.xenotiers)
		xenos_by_tier[tier] = list()

	for(var/upgrade in GLOB.xenoupgradetiers)
		xenos_by_upgrade[upgrade] = list()

	SSdirection.set_leader(hivenumber, null)


// ***************************************
// *********** Helpers
// ***************************************
/datum/hive_status/proc/get_total_xeno_number() // unsafe for use by gamemode code
	. = 0
	for(var/t in xenos_by_tier)
		. += length(xenos_by_tier[t])

/datum/hive_status/proc/post_add(mob/living/carbon/xenomorph/X)
	X.color = color

/datum/hive_status/proc/post_removal(mob/living/carbon/xenomorph/X)
	X.color = null

// for clean transfers between hives
/mob/living/carbon/xenomorph/proc/transfer_to_hive(hivenumber)
	if (hive.hivenumber == hivenumber)
		return // If we are in that hive already
	if(!GLOB.hive_datums[hivenumber])
		CRASH("invalid hivenumber passed to transfer_to_hive")

	var/datum/hive_status/HS = GLOB.hive_datums[hivenumber]
	if(hivenumber != XENO_HIVE_NONE)
		remove_from_hive()

	add_to_hive(HS)


/datum/hive_status/proc/can_hive_have_a_queen()
	return (get_total_xeno_number() < xenos_per_queen)

/datum/hive_status/normal/can_hive_have_a_queen()
	var/datum/job/xeno_job = SSjob.GetJobType(/datum/job/xenomorph)
	var/stored_larva = xeno_job.total_positions - xeno_job.current_positions
	return ((get_total_xeno_number() + stored_larva) < xenos_per_queen)

/datum/hive_status/proc/get_total_tier_zeros()
	return length(xenos_by_tier[XENO_TIER_ZERO])

/datum/hive_status/normal/get_total_tier_zeros()
	. = ..()
	var/datum/job/xeno_job = SSjob.GetJobType(/datum/job/xenomorph)
	var/stored_larva = xeno_job.total_positions - xeno_job.current_positions
	. += stored_larva

// ***************************************
// *********** List getters
// ***************************************
/datum/hive_status/proc/get_all_xenos(queen = TRUE)
	var/list/xenos = list()
	for(var/typepath in xenos_by_typepath)
		if(!queen && typepath == /mob/living/carbon/xenomorph/queen) // hardcoded check for now
			continue
		xenos += xenos_by_typepath[typepath]
	return xenos

// doing this by type means we get a pseudo sorted list
/datum/hive_status/proc/get_watchable_xenos()
	var/list/xenos = list()
	for(var/typepath in xenos_by_typepath)
		if(typepath == /mob/living/carbon/xenomorph/queen) // hardcoded check for now
			continue
		for(var/i in xenos_by_typepath[typepath])
			var/mob/living/carbon/xenomorph/X = i
			if(is_centcom_level(X.z))
				continue
			xenos += X
	return xenos

// doing this by type means we get a pseudo sorted list
/datum/hive_status/proc/get_leaderable_xenos()
	var/list/xenos = list()
	for(var/typepath in xenos_by_typepath)
		if(typepath == /mob/living/carbon/xenomorph/queen) // hardcoded check for now
			continue
		for(var/i in xenos_by_typepath[typepath])
			var/mob/living/carbon/xenomorph/X = i
			if(is_centcom_level(X.z))
				continue
			if(!(X.xeno_caste.caste_flags & CASTE_CAN_BE_LEADER))
				continue
			xenos += X
	return xenos

/datum/hive_status/proc/get_ssd_xenos(only_away = FALSE)
	var/list/xenos = list()
	for(var/i in ssd_xenos)
		var/mob/living/carbon/xenomorph/ssd_xeno = i
		if(is_centcom_level(ssd_xeno.z))
			continue
		if(isclientedaghost(ssd_xeno)) //To prevent adminghosted xenos to be snatched.
			continue
		if(only_away && ssd_xeno.afk_status == MOB_RECENTLY_DISCONNECTED)
			continue
		xenos += ssd_xeno
	return xenos

// ***************************************
// *********** Adding xenos
// ***************************************
/datum/hive_status/proc/add_xeno(mob/living/carbon/xenomorph/X) // should only be called by add_to_hive below
	if(X.stat == DEAD)
		dead_xenos += X
	else
		add_to_lists(X)

	post_add(X)
	return TRUE

// helper function
/datum/hive_status/proc/add_to_lists(mob/living/carbon/xenomorph/X)
	xenos_by_tier[X.tier] += X
	xenos_by_upgrade[X.upgrade] += X
	LAZYADD(xenos_by_zlevel["[X.z]"], X)
	RegisterSignal(X, COMSIG_MOVABLE_Z_CHANGED, .proc/xeno_z_changed)

	if(!xenos_by_typepath[X.caste_base_type])
		stack_trace("trying to add an invalid typepath into hivestatus list [X.caste_base_type]")
		return FALSE

	if(X.afk_status != MOB_CONNECTED)
		LAZYADD(ssd_xenos, X)

	xenos_by_typepath[X.caste_base_type] += X
	update_tier_limits() //Update our tier limits.

	return TRUE

/mob/living/carbon/xenomorph/proc/add_to_hive(datum/hive_status/HS, force=FALSE)
	if(!force && hivenumber != XENO_HIVE_NONE)
		CRASH("trying to do a dirty add_to_hive")

	if(!istype(HS))
		CRASH("invalid hive_status passed to add_to_hive()")

	if(!HS.add_xeno(src))
		CRASH("failed to add xeno to a hive")

	hive = HS
	hivenumber = HS.hivenumber // just to be sure
	generate_name()

	SSdirection.start_tracking(HS.hivenumber, src)
	hive.update_tier_limits() //Update our tier limits.

/mob/living/carbon/xenomorph/queen/add_to_hive(datum/hive_status/HS, force=FALSE) // override to ensure proper queen/hive behaviour
	. = ..()
	if(HS.living_xeno_queen) // theres already a queen
		return

	HS.living_xeno_queen = src

	HS.update_ruler()


/mob/living/carbon/xenomorph/shrike/add_to_hive(datum/hive_status/HS, force = FALSE) // override to ensure proper queen/hive behaviour
	. = ..()

	if(HS.living_xeno_ruler)
		return
	HS.update_ruler()


/mob/living/carbon/xenomorph/proc/add_to_hive_by_hivenumber(hivenumber, force=FALSE) // helper function to add by given hivenumber
	if(!GLOB.hive_datums[hivenumber])
		CRASH("add_to_hive_by_hivenumber called with invalid hivenumber")
	var/datum/hive_status/HS = GLOB.hive_datums[hivenumber]
	add_to_hive(HS, force)
	hive.update_tier_limits() //Update our tier limits.

// This is a special proc called only when a xeno is first created to set their hive and name properly
/mob/living/carbon/xenomorph/proc/set_initial_hivenumber()
	add_to_hive_by_hivenumber(hivenumber, force=TRUE)

// ***************************************
// *********** Removing xenos
// ***************************************
/datum/hive_status/proc/remove_xeno(mob/living/carbon/xenomorph/X) // should only be called by remove_from_hive
	if(X.stat == DEAD)
		if(!dead_xenos.Remove(X))
			stack_trace("failed to remove a dead xeno from hive status dead list, nothing was removed!?")
			return FALSE
	else
		remove_from_lists(X)

	post_removal(X)
	return TRUE

// helper function
/datum/hive_status/proc/remove_from_lists(mob/living/carbon/xenomorph/X)
	// Remove() returns 1 if it removes an element from a list

	if(!xenos_by_tier[X.tier].Remove(X))
		stack_trace("failed to remove a xeno from hive status tier list, nothing was removed!?")
		return FALSE

	if(!xenos_by_upgrade[X.upgrade].Remove(X))
		stack_trace("trying to remove a xeno from hivestatus upgrade list, nothing was removed!?")
		return FALSE

	if(!xenos_by_typepath[X.caste_base_type])
		stack_trace("trying to remove an invalid typepath from hivestatus list")
		return FALSE

	if(!xenos_by_typepath[X.caste_base_type].Remove(X))
		stack_trace("failed to remove a xeno from hive status typepath list, nothing was removed!?")
		return FALSE

	LAZYREMOVE(ssd_xenos, X)
	LAZYREMOVE(xenos_by_zlevel["[X.z]"], X)

	UnregisterSignal(X, COMSIG_MOVABLE_Z_CHANGED)

	remove_leader(X)
	update_tier_limits() //Update our tier limits.

	return TRUE

/mob/living/carbon/xenomorph/proc/remove_from_hive()
	if(!istype(hive))
		CRASH("tried to remove a xeno from a hive that didnt have a hive to be removed from")

	if(!hive.remove_xeno(src))
		CRASH("failed to remove xeno from a hive")

	if(queen_chosen_lead || (src in hive.xeno_leader_list))
		hive.remove_leader(src)

	SSdirection.stop_tracking(hive.hivenumber, src)

	var/datum/hive_status/reference_hive = hive
	hive = null
	hivenumber = XENO_HIVE_NONE // failsafe value
	reference_hive.update_tier_limits() //Update our tier limits.

/mob/living/carbon/xenomorph/queen/remove_from_hive() // override to ensure proper queen/hive behaviour
	var/datum/hive_status/hive_removed_from = hive
	if(hive_removed_from.living_xeno_queen == src)
		hive_removed_from.living_xeno_queen = null

	. = ..()

	if(hive_removed_from.living_xeno_ruler == src)
		hive_removed_from.set_ruler(null)
		hive_removed_from.update_ruler() //Try to find a successor.



/mob/living/carbon/xenomorph/shrike/remove_from_hive()
	var/datum/hive_status/hive_removed_from = hive

	. = ..()

	if(hive_removed_from.living_xeno_ruler == src)
		hive_removed_from.set_ruler(null)
		hive_removed_from.update_ruler() //Try to find a successor.


// ***************************************
// *********** Xeno leaders
// ***************************************
/datum/hive_status/proc/add_leader(mob/living/carbon/xenomorph/X)
	xeno_leader_list += X
	X.queen_chosen_lead = TRUE
	X.give_rally_hive_ability()

/datum/hive_status/proc/remove_leader(mob/living/carbon/xenomorph/X)
	xeno_leader_list -= X
	X.queen_chosen_lead = FALSE

	if(!isxenoshrike(X) && !isxenoqueen(X) && !isxenohivemind(X)) //These innately have the Rally Hive ability
		X.remove_rally_hive_ability()

/datum/hive_status/proc/update_leader_pheromones() // helper function to easily trigger an update of leader pheromones
	for(var/mob/living/carbon/xenomorph/leader AS in xeno_leader_list)
		leader.handle_xeno_leader_pheromones(living_xeno_queen)

// ***************************************
// *********** Status changes
// ***************************************
/datum/hive_status/proc/on_xeno_logout(mob/living/carbon/xenomorph/ssd_xeno)
	if(ssd_xeno.stat == DEAD)
		return
	LAZYADD(ssd_xenos, ssd_xeno)

/datum/hive_status/proc/on_xeno_login(mob/living/carbon/xenomorph/reconnecting_xeno)
	LAZYREMOVE(ssd_xenos, reconnecting_xeno)

/datum/hive_status/proc/xeno_z_changed(mob/living/carbon/xenomorph/X, old_z, new_z)
	SIGNAL_HANDLER
	LAZYREMOVE(xenos_by_zlevel["[old_z]"], X)
	LAZYADD(xenos_by_zlevel["[new_z]"], X)

// ***************************************
// *********** Xeno upgrades
// ***************************************
/datum/hive_status/proc/upgrade_xeno(mob/living/carbon/xenomorph/X, oldlevel, newlevel) // called by Xenomorph/proc/upgrade_xeno()
	xenos_by_upgrade[oldlevel] -= X
	xenos_by_upgrade[newlevel] += X

// ***************************************
// *********** Xeno death
// ***************************************
/datum/hive_status/proc/on_xeno_death(mob/living/carbon/xenomorph/X)
	remove_from_lists(X)
	dead_xenos += X

	SEND_SIGNAL(X, COMSIG_HIVE_XENO_DEATH)

	if(X == living_xeno_ruler)
		on_ruler_death(X)

	return TRUE


/datum/hive_status/proc/on_xeno_revive(mob/living/carbon/xenomorph/X)
	dead_xenos -= X
	add_to_lists(X)
	return TRUE


// ***************************************
// *********** Ruler
// ***************************************

/datum/hive_status/proc/on_ruler_death(mob/living/carbon/xenomorph/ruler)
	if(living_xeno_ruler == ruler)
		set_ruler(null)
	var/announce = TRUE
	if(SSticker.current_state == GAME_STATE_FINISHED || SSticker.current_state == GAME_STATE_SETTING_UP)
		announce = FALSE
	if(announce)
		xeno_message("A sudden tremor ripples through the hive... \the [ruler] has been slain! Vengeance!", "xenoannounce", 6, TRUE)
	if(slashing_allowed != XENO_SLASHING_ALLOWED)
		if(announce)
			xeno_message("The slashing of hosts is now permitted.", "xenoannounce", 5, TRUE)
		slashing_allowed = XENO_SLASHING_ALLOWED
	notify_ghosts("\The <b>[ruler]</b> has been slain!", source = ruler, action = NOTIFY_JUMP)
	update_ruler()
	return TRUE


// This proc attempts to find a new ruler to lead the hive.
/datum/hive_status/proc/update_ruler()
	if(living_xeno_ruler)
		return //No succession required.

	var/mob/living/carbon/xenomorph/successor

	var/list/candidates = xenos_by_typepath[/mob/living/carbon/xenomorph/queen]
	if(length(candidates)) //Priority to the queens.
		successor = candidates[1] //First come, first serve.
	else
		candidates = xenos_by_typepath[/mob/living/carbon/xenomorph/shrike]
		if(length(candidates))
			successor = candidates[1]

	var/announce = TRUE
	if(SSticker.current_state == GAME_STATE_FINISHED || SSticker.current_state == GAME_STATE_SETTING_UP)
		announce = FALSE

	set_ruler(successor)

	handle_ruler_timer()

	if(!living_xeno_ruler)
		return //Succession failed.

	if(announce)
		xeno_message("\A [successor] has risen to lead the Hive! Rejoice!", "xenoannounce", 6)
		notify_ghosts("\The [successor] has risen to lead the Hive!", source = successor, action = NOTIFY_ORBIT)


/datum/hive_status/proc/set_ruler(mob/living/carbon/xenomorph/successor)
	SSdirection.clear_leader(hivenumber)
	if(!isnull(successor))
		SSdirection.set_leader(hivenumber, successor)
		SEND_SIGNAL(successor, COMSIG_HIVE_BECOME_RULER)
	living_xeno_ruler = successor


/mob/living/carbon/xenomorph/queen/proc/on_becoming_ruler()
	SIGNAL_HANDLER
	hive.update_leader_pheromones()


/datum/hive_status/proc/handle_ruler_timer()
	return


/datum/hive_status/proc/on_shuttle_hijack(obj/docking_port/mobile/marine_dropship/hijacked_ship)
	return


// safe for use by gamemode code, this allows per hive overrides
/datum/hive_status/proc/end_queen_death_timer()
	xeno_message("The Hive is ready for a new ruler to evolve.", "xenoannounce", 6, TRUE)
	xeno_queen_timer = null


/datum/hive_status/proc/check_ruler()
	return TRUE


/datum/hive_status/normal/check_ruler()
	if(!(SSticker.mode?.flags_round_type & MODE_XENO_RULER))
		return TRUE
	return living_xeno_ruler


// ***************************************
// *********** Queen
// ***************************************

// These are defined for per-hive behaviour
/datum/hive_status/proc/on_queen_death(mob/living/carbon/xenomorph/queen/Q)
	SIGNAL_HANDLER
	if(living_xeno_queen != Q)
		return FALSE
	living_xeno_queen = null
	if(!xeno_queen_timer)
		xeno_queen_timer = addtimer(CALLBACK(src, .proc/end_queen_death_timer), QUEEN_DEATH_TIMER, TIMER_STOPPABLE)
	update_leader_pheromones()

/mob/living/carbon/xenomorph/larva/proc/burrow()
	if(ckey && client)
		return
	hive?.burrow_larva(src)

/datum/hive_status/proc/burrow_larva(mob/living/carbon/xenomorph/larva/L)
	return


// ***************************************
// *********** Xeno messaging
// ***************************************
/datum/hive_status/proc/can_xeno_message() // This is defined for per-hive overrides
	return living_xeno_ruler

/*

This is for hive-wide announcements like the queen dying

The force parameter is for messages that should ignore a dead queen

to_chat will check for valid clients itself already so no need to double check for clients

*/

///Used for Hive Message alerts
/datum/hive_status/proc/xeno_message(message = null, span_class = "xenoannounce", size = 5, force = FALSE, atom/target = null, sound = null, apply_preferences = FALSE, filter_list = null, arrow_type = /obj/screen/arrow/leader_tracker_arrow, arrow_color, report_distance)

	if(!force && !can_xeno_message())
		return

	var/list/final_list = get_all_xenos()

	if(filter_list) //Filter out Xenos in the filter list if applicable
		final_list -= filter_list

	for(var/mob/living/carbon/xenomorph/X AS in final_list)

		if(X.stat) // dead/crit cant hear
			continue

		if(!X.client) // If no client, there's no point; also runtime prevention
			continue

		if(sound) //Play sound if applicable
			X.playsound_local(X, sound, max(size * 20, 60), 0, 1)

		if(target) //Apply tracker arrow to point to the subject of the message if applicable
			var/obj/screen/arrow/arrow_hud = new arrow_type
			//Prepare the tracker object and set its parameters
			arrow_hud.add_hud(X, target)
			if(arrow_color) //Set the arrow to our custom colour if applicable
				arrow_hud.color = arrow_color
			new /obj/effect/temp_visual/xenomorph/xeno_tracker_target(target, target) //Ping the source of our alert

		to_chat(X, "<span class='[span_class]'><font size=[size]> [message][report_distance ? " Distance: [get_dist(X, target)]" : ""]</font></span>")

// This is to simplify the process of talking in hivemind, this will invoke the receive proc of all xenos in this hive
/datum/hive_status/proc/hive_mind_message(mob/living/carbon/xenomorph/sender, message)
	for(var/i in get_all_xenos())
		var/mob/living/carbon/xenomorph/X = i
		X.receive_hivemind_message(sender, message)

///Used for setting the trackers of all xenos in the hive, like when a nuke activates
/datum/hive_status/proc/set_all_xeno_trackers(atom/target)
	for(var/mob/living/carbon/xenomorph/X AS in get_all_xenos())
		X.tracked = target
		to_chat(X, "<span class='notice'> Now tracking [target.name]</span>")

// ***************************************
// *********** Normal Xenos
// ***************************************
/datum/hive_status/normal // subtype for easier typechecking and overrides
	hive_flags = HIVE_CAN_HIJACK

/datum/hive_status/normal/on_queen_death(mob/living/carbon/xenomorph/queen/Q)
	if(living_xeno_queen != Q)
		return FALSE
	return ..()


/datum/hive_status/normal/handle_ruler_timer()
	if(!isinfestationgamemode(SSticker.mode)) //Check just need for unit test
		return
	if(!(SSticker.mode?.flags_round_type & MODE_XENO_RULER))
		return
	var/datum/game_mode/infestation/D = SSticker.mode

	if(living_xeno_ruler)
		if(D.orphan_hive_timer)
			deltimer(D.orphan_hive_timer)
			D.orphan_hive_timer = null
		return

	if(D.orphan_hive_timer)
		return


	D.orphan_hive_timer = addtimer(CALLBACK(D, /datum/game_mode.proc/orphan_hivemind_collapse), 5 MINUTES, TIMER_STOPPABLE)


/datum/hive_status/normal/burrow_larva(mob/living/carbon/xenomorph/larva/L)
	if(!is_ground_level(L.z))
		return
	L.visible_message("<span class='xenodanger'>[L] quickly burrows into the ground.</span>")
	var/datum/job/xeno_job = SSjob.GetJobType(/datum/job/xenomorph)
	xeno_job.add_job_positions(1)
	GLOB.round_statistics.total_xenos_created-- // keep stats sane
	SSblackbox.record_feedback("tally", "round_statistics", -1, "total_xenos_created")
	qdel(L)


// This proc checks for available spawn points and offers a choice if there's more than one.
/datum/hive_status/proc/attempt_to_spawn_larva(mob/xeno_candidate, larva_already_reserved = FALSE)
	if(!xeno_candidate?.client)
		return FALSE

	var/datum/job/xeno_job = SSjob.GetJobType(/datum/job/xenomorph)
	if((xeno_job.total_positions - xeno_job.current_positions) < 0)
		return FALSE

	var/list/possible_mothers = list()
	var/list/possible_silos = list()
	SEND_SIGNAL(src, COMSIG_HIVE_XENO_MOTHER_PRE_CHECK, possible_mothers, possible_silos) //List variable passed by reference, and hopefully populated.
	if(!length(possible_mothers))
		if(length(possible_silos))
			return attempt_to_spawn_larva_in_silo(xeno_candidate, possible_silos, larva_already_reserved)
		if(SSticker.mode?.flags_round_type & MODE_SILO_RESPAWN && !SSsilo.can_fire) // Distress mode & prior to shutters opening, so let the queue bypass silos if needed
			if(!isnewplayer(xeno_candidate) && XENODEATHTIME_CHECK(xeno_candidate))
				if(check_other_rights(xeno_candidate.client, R_ADMIN, FALSE))
					if(tgui_alert(xeno_candidate, "You wouldn't normally qualify for this respawn. Are you sure you want to bypass it with your admin powers?", "Bypass Respawn", list("Yes", "No")) != "Yes")
						log_admin("[key_name(xeno_candidate)] used their admin power to bypass respawn before their timer was over")
						XENODEATHTIME_MESSAGE(xeno_candidate)
						return FALSE
				else
					XENODEATHTIME_MESSAGE(xeno_candidate)
					return FALSE
			return do_spawn_larva(xeno_candidate, pick(GLOB.spawns_by_job[/datum/job/xenomorph]), larva_already_reserved)
		to_chat(xeno_candidate, "<span class='warning'>There are no places currently available to receive new larvas.</span>")
		return FALSE

	var/mob/living/carbon/xenomorph/chosen_mother
	if(length(possible_mothers) > 1)
		chosen_mother = tgui_input_list(xeno_candidate, "Available Mothers", null, possible_mothers)
	else
		chosen_mother = possible_mothers[1]

	if(QDELETED(chosen_mother) || !xeno_candidate?.client)
		return FALSE

	if(!isnewplayer(xeno_candidate) && XENODEATHTIME_CHECK(xeno_candidate))
		if(check_other_rights(xeno_candidate.client, R_ADMIN, FALSE))
			if(tgui_alert(xeno_candidate, "You wouldn't normally qualify for this respawn. Are you sure you want to bypass it with your admin powers?", "Bypass Respawn", list("Yes", "No")) != "Yes")
				log_admin("[key_name(xeno_candidate)] used his admin power to bypass respawn before his timer was over")
				XENODEATHTIME_MESSAGE(xeno_candidate)
				return FALSE
		else
			XENODEATHTIME_MESSAGE(xeno_candidate)
			return FALSE

	return spawn_larva(xeno_candidate, chosen_mother, larva_already_reserved)


/datum/hive_status/proc/attempt_to_spawn_larva_in_silo(mob/xeno_candidate, possible_silos, larva_already_reserved = FALSE)
	var/obj/structure/xeno/resin/silo/chosen_silo
	if(length(possible_silos) > 1)
		chosen_silo = tgui_input_list(xeno_candidate, "Available Egg Silos", "Spawn location", possible_silos)
		if(!chosen_silo)
			return FALSE
		xeno_candidate.forceMove(chosen_silo)
		var/double_check = tgui_alert(xeno_candidate, "Spawn here?", "Spawn location", list("Yes","Pick another silo","Abort"))
		if(double_check == "Pick another silo")
			return attempt_to_spawn_larva_in_silo(xeno_candidate, possible_silos)
		else if(double_check != "Yes")
			return FALSE
	else
		chosen_silo = possible_silos[1]

	if(QDELETED(chosen_silo) || !xeno_candidate?.client)
		return FALSE

	if(!isnewplayer(xeno_candidate) && XENODEATHTIME_CHECK(xeno_candidate))
		if(check_other_rights(xeno_candidate.client, R_ADMIN, FALSE))
			if(tgui_alert(xeno_candidate, "You wouldn't normally qualify for this respawn. Are you sure you want to bypass it with your admin powers?", "Bypass Respawn", list("Yes", "No")) != "Yes")
				log_admin("[key_name(xeno_candidate)] used his admin power to bypass respawn before his timer was over")
				XENODEATHTIME_MESSAGE(xeno_candidate)
				return FALSE
		else
			XENODEATHTIME_MESSAGE(xeno_candidate)
			return FALSE

	return do_spawn_larva(xeno_candidate, chosen_silo.loc, larva_already_reserved)


/datum/hive_status/proc/spawn_larva(mob/xeno_candidate, mob/living/carbon/xenomorph/mother, larva_already_reserved = FALSE)
	if(!xeno_candidate?.mind)
		return FALSE

	if(QDELETED(mother) || !istype(mother))
		to_chat(xeno_candidate, "<span class='warning'>Something went awry with mom. Can't spawn at the moment.</span>")
		return FALSE

	if(!larva_already_reserved)
		var/datum/job/xeno_job = SSjob.GetJobType(/datum/job/xenomorph)
		var/stored_larva = xeno_job.total_positions - xeno_job.current_positions
		if(!stored_larva)
			to_chat(xeno_candidate, "<span class='warning'>There are no longer burrowed larvas available.</span>")
			return FALSE

	var/list/possible_mothers = list()
	SEND_SIGNAL(src, COMSIG_HIVE_XENO_MOTHER_CHECK, possible_mothers) //List variable passed by reference, and hopefully populated.

	if(!(mother in possible_mothers))
		to_chat(xeno_candidate, "<span class='warning'>This mother is not in a state to receive us.</span>")
		return FALSE
	return do_spawn_larva(xeno_candidate, get_turf(mother), larva_already_reserved)


/datum/hive_status/proc/do_spawn_larva(mob/xeno_candidate, turf/spawn_point, larva_already_reserved = FALSE)
	if(is_banned_from(xeno_candidate.ckey, ROLE_XENOMORPH))
		to_chat(xeno_candidate, "<span class='warning'>You are jobbaned from the [ROLE_XENOMORPH] role.</span>")
		return FALSE

	var/mob/living/carbon/xenomorph/larva/new_xeno = new /mob/living/carbon/xenomorph/larva(spawn_point)
	new_xeno.visible_message("<span class='xenodanger'>A larva suddenly burrows out of the ground!</span>",
	"<span class='xenodanger'>We burrow out of the ground and awaken from our slumber. For the Hive!</span>")

	log_game("[key_name(xeno_candidate)] has joined as [new_xeno] at [AREACOORD(new_xeno.loc)].")
	message_admins("[key_name(xeno_candidate)] has joined as [ADMIN_TPMONTY(new_xeno)].")

	xeno_candidate.mind.transfer_to(new_xeno, TRUE)
	new_xeno.playsound_local(new_xeno, 'sound/effects/xeno_newlarva.ogg')
	to_chat(new_xeno, "<span class='xenoannounce'>We are a xenomorph larva awakened from slumber!</span>")
	if(!larva_already_reserved)
		var/datum/job/xeno_job = SSjob.GetJobType(/datum/job/xenomorph)
		xeno_job.occupy_job_positions(1)
	return new_xeno


/datum/hive_status/normal/on_shuttle_hijack(obj/docking_port/mobile/marine_dropship/hijacked_ship)
	handle_silo_death_timer()
	xeno_message("Our Ruler has commanded the metal bird to depart for the metal hive in the sky! Run and board it to avoid a cruel death!")
	RegisterSignal(hijacked_ship, COMSIG_SHUTTLE_SETMODE, .proc/on_hijack_depart)

	for(var/obj/structure/xeno/resin/silo/silo AS in GLOB.xeno_resin_silos)
		if(!is_ground_level(silo.z))
			continue
		qdel(silo)

	if(SSticker.mode?.flags_round_type & MODE_PSY_POINTS_ADVANCED)
		SSpoints.xeno_points_by_hive[hivenumber] = SILO_PRICE + XENO_TURRET_PRICE //Give a free silo when going shipside and a turret


/datum/hive_status/normal/proc/on_hijack_depart(datum/source, new_mode)
	SIGNAL_HANDLER
	if(new_mode != SHUTTLE_CALL)
		return
	UnregisterSignal(source, COMSIG_SHUTTLE_SETMODE)

	// Add extra xenos based on the difference of xenos / marines
	var/players = SSticker.mode.count_humans_and_xenos()
	var/difference = round(players[2] - (players[1] * 0.5)) // no of xenos - half the no of players

	var/left_behind = 0
	for(var/i in get_all_xenos())
		var/mob/living/carbon/xenomorph/boarder = i
		if(isdropshiparea(get_area(boarder)))
			continue
		if(!is_ground_level(boarder.z))
			continue
		INVOKE_ASYNC(boarder, /mob/living.proc/gib)
		left_behind++
	var/datum/job/xeno_job = SSjob.GetJobType(/datum/job/xenomorph)
	if(left_behind)
		xeno_message("[left_behind > 1 ? "[left_behind] sisters" : "One sister"] perished due to being too slow to board the bird. The freeing of their psychic link allows us to call burrowed, at least.")
		xeno_job.add_job_positions(left_behind)
	if(difference < 0)
		if(xeno_job.total_positions < (-difference + xeno_job.current_positions))
			xeno_job.set_job_positions(-difference + xeno_job.current_positions)

// ***************************************
// *********** Corrupted Xenos
// ***************************************
/datum/hive_status/corrupted
	name = "Corrupted"
	hivenumber = XENO_HIVE_CORRUPTED
	prefix = "Corrupted "
	color = "#00ff80"

// Make sure they can understand english
/datum/hive_status/corrupted/post_add(mob/living/carbon/xenomorph/X)
	. = ..()
	X.grant_language(/datum/language/common)

/datum/hive_status/corrupted/post_removal(mob/living/carbon/xenomorph/X)
	. = ..()
	X.remove_language(/datum/language/common)

/datum/hive_status/corrupted/can_xeno_message()
	return TRUE // can always talk in hivemind

/mob/living/carbon/xenomorph/queen/Corrupted
	hivenumber = XENO_HIVE_CORRUPTED

/mob/living/carbon/xenomorph/boiler/Corrupted
	hivenumber = XENO_HIVE_CORRUPTED

/mob/living/carbon/xenomorph/bull/Corrupted
	hivenumber = XENO_HIVE_CORRUPTED

/mob/living/carbon/xenomorph/carrier/Corrupted
	hivenumber = XENO_HIVE_CORRUPTED

/mob/living/carbon/xenomorph/crusher/Corrupted
	hivenumber = XENO_HIVE_CORRUPTED

/mob/living/carbon/xenomorph/defender/Corrupted
	hivenumber = XENO_HIVE_CORRUPTED

/mob/living/carbon/xenomorph/Defiler/Corrupted
	hivenumber = XENO_HIVE_CORRUPTED

/mob/living/carbon/xenomorph/drone/Corrupted
	hivenumber = XENO_HIVE_CORRUPTED

/mob/living/carbon/xenomorph/hivelord/Corrupted
	hivenumber = XENO_HIVE_CORRUPTED

/mob/living/carbon/xenomorph/hivemind/Corrupted
	hivenumber = XENO_HIVE_CORRUPTED

/mob/living/carbon/xenomorph/hunter/Corrupted
	hivenumber = XENO_HIVE_CORRUPTED

/mob/living/carbon/xenomorph/larva/Corrupted
	hivenumber = XENO_HIVE_CORRUPTED

/mob/living/carbon/xenomorph/praetorian/Corrupted
	hivenumber = XENO_HIVE_CORRUPTED

/mob/living/carbon/xenomorph/ravager/Corrupted
	hivenumber = XENO_HIVE_CORRUPTED

/mob/living/carbon/xenomorph/runner/Corrupted
	hivenumber = XENO_HIVE_CORRUPTED

/mob/living/carbon/xenomorph/sentinel/Corrupted
	hivenumber = XENO_HIVE_CORRUPTED

/mob/living/carbon/xenomorph/shrike/Corrupted
	hivenumber = XENO_HIVE_CORRUPTED

/mob/living/carbon/xenomorph/spitter/Corrupted
	hivenumber = XENO_HIVE_CORRUPTED

/mob/living/carbon/xenomorph/warrior/Corrupted
	hivenumber = XENO_HIVE_CORRUPTED

/mob/living/carbon/xenomorph/wraith/Corrupted
	hivenumber = XENO_HIVE_CORRUPTED

/mob/living/carbon/xenomorph/king/Corrupted
	hivenumber = XENO_HIVE_CORRUPTED

// ***************************************
// *********** Misc Xenos
// ***************************************
/datum/hive_status/alpha
	name = "Alpha"
	hivenumber = XENO_HIVE_ALPHA
	prefix = "Alpha "
	color = "#cccc00"

/mob/living/carbon/xenomorph/queen/Alpha
	hivenumber = XENO_HIVE_ALPHA

/mob/living/carbon/xenomorph/boiler/Alpha
	hivenumber = XENO_HIVE_ALPHA

/mob/living/carbon/xenomorph/bull/Alpha
	hivenumber = XENO_HIVE_ALPHA

/mob/living/carbon/xenomorph/carrier/Alpha
	hivenumber = XENO_HIVE_ALPHA

/mob/living/carbon/xenomorph/crusher/Alpha
	hivenumber = XENO_HIVE_ALPHA

/mob/living/carbon/xenomorph/defender/Alpha
	hivenumber = XENO_HIVE_ALPHA

/mob/living/carbon/xenomorph/Defiler/Alpha
	hivenumber = XENO_HIVE_ALPHA

/mob/living/carbon/xenomorph/drone/Alpha
	hivenumber = XENO_HIVE_ALPHA

/mob/living/carbon/xenomorph/hivelord/Alpha
	hivenumber = XENO_HIVE_ALPHA

/mob/living/carbon/xenomorph/hivemind/Alpha
	hivenumber = XENO_HIVE_ALPHA

/mob/living/carbon/xenomorph/hunter/Alpha
	hivenumber = XENO_HIVE_ALPHA

/mob/living/carbon/xenomorph/larva/Alpha
	hivenumber = XENO_HIVE_ALPHA

/mob/living/carbon/xenomorph/praetorian/Alpha
	hivenumber = XENO_HIVE_ALPHA

/mob/living/carbon/xenomorph/ravager/Alpha
	hivenumber = XENO_HIVE_ALPHA

/mob/living/carbon/xenomorph/runner/Alpha
	hivenumber = XENO_HIVE_ALPHA

/mob/living/carbon/xenomorph/sentinel/Alpha
	hivenumber = XENO_HIVE_ALPHA

/mob/living/carbon/xenomorph/shrike/Alpha
	hivenumber = XENO_HIVE_ALPHA

/mob/living/carbon/xenomorph/spitter/Alpha
	hivenumber = XENO_HIVE_ALPHA

/mob/living/carbon/xenomorph/warrior/Alpha
	hivenumber = XENO_HIVE_ALPHA

/mob/living/carbon/xenomorph/wraith/Alpha
	hivenumber = XENO_HIVE_ALPHA

/mob/living/carbon/xenomorph/king/Alpha
	hivenumber = XENO_HIVE_ALPHA

/datum/hive_status/beta
	name = "Beta"
	hivenumber = XENO_HIVE_BETA
	prefix = "Beta "
	color = "#9999ff"

/mob/living/carbon/xenomorph/queen/Beta
	hivenumber = XENO_HIVE_BETA

/mob/living/carbon/xenomorph/boiler/Beta
	hivenumber = XENO_HIVE_BETA

/mob/living/carbon/xenomorph/bull/Beta
	hivenumber = XENO_HIVE_BETA

/mob/living/carbon/xenomorph/carrier/Beta
	hivenumber = XENO_HIVE_BETA

/mob/living/carbon/xenomorph/crusher/Beta
	hivenumber = XENO_HIVE_BETA

/mob/living/carbon/xenomorph/defender/Beta
	hivenumber = XENO_HIVE_BETA

/mob/living/carbon/xenomorph/Defiler/Beta
	hivenumber = XENO_HIVE_BETA

/mob/living/carbon/xenomorph/drone/Beta
	hivenumber = XENO_HIVE_BETA

/mob/living/carbon/xenomorph/hivelord/Beta
	hivenumber = XENO_HIVE_BETA

/mob/living/carbon/xenomorph/hivemind/Beta
	hivenumber = XENO_HIVE_BETA

/mob/living/carbon/xenomorph/hunter/Beta
	hivenumber = XENO_HIVE_BETA

/mob/living/carbon/xenomorph/larva/Beta
	hivenumber = XENO_HIVE_BETA

/mob/living/carbon/xenomorph/praetorian/Beta
	hivenumber = XENO_HIVE_BETA

/mob/living/carbon/xenomorph/ravager/Beta
	hivenumber = XENO_HIVE_BETA

/mob/living/carbon/xenomorph/runner/Beta
	hivenumber = XENO_HIVE_BETA

/mob/living/carbon/xenomorph/sentinel/Beta
	hivenumber = XENO_HIVE_BETA

/mob/living/carbon/xenomorph/shrike/Beta
	hivenumber = XENO_HIVE_BETA

/mob/living/carbon/xenomorph/spitter/Beta
	hivenumber = XENO_HIVE_BETA

/mob/living/carbon/xenomorph/warrior/Beta
	hivenumber = XENO_HIVE_BETA

/mob/living/carbon/xenomorph/wraith/Beta
	hivenumber = XENO_HIVE_BETA

/mob/living/carbon/xenomorph/king/Beta
	hivenumber = XENO_HIVE_BETA

/datum/hive_status/zeta
	name = "Zeta"
	hivenumber = XENO_HIVE_ZETA
	prefix = "Zeta "
	color = "#606060"

/mob/living/carbon/xenomorph/queen/Zeta
	hivenumber = XENO_HIVE_ZETA

/mob/living/carbon/xenomorph/boiler/Zeta
	hivenumber = XENO_HIVE_ZETA

/mob/living/carbon/xenomorph/bull/Zeta
	hivenumber = XENO_HIVE_ZETA

/mob/living/carbon/xenomorph/carrier/Zeta
	hivenumber = XENO_HIVE_ZETA

/mob/living/carbon/xenomorph/crusher/Zeta
	hivenumber = XENO_HIVE_ZETA

/mob/living/carbon/xenomorph/defender/Zeta
	hivenumber = XENO_HIVE_ZETA

/mob/living/carbon/xenomorph/Defiler/Zeta
	hivenumber = XENO_HIVE_ZETA

/mob/living/carbon/xenomorph/drone/Zeta
	hivenumber = XENO_HIVE_ZETA

/mob/living/carbon/xenomorph/hivelord/Zeta
	hivenumber = XENO_HIVE_ZETA

/mob/living/carbon/xenomorph/hivemind/Zeta
	hivenumber = XENO_HIVE_ZETA

/mob/living/carbon/xenomorph/hunter/Zeta
	hivenumber = XENO_HIVE_ZETA

/mob/living/carbon/xenomorph/larva/Zeta
	hivenumber = XENO_HIVE_ZETA

/mob/living/carbon/xenomorph/praetorian/Zeta
	hivenumber = XENO_HIVE_ZETA

/mob/living/carbon/xenomorph/ravager/Zeta
	hivenumber = XENO_HIVE_ZETA

/mob/living/carbon/xenomorph/runner/Zeta
	hivenumber = XENO_HIVE_ZETA

/mob/living/carbon/xenomorph/sentinel/Zeta
	hivenumber = XENO_HIVE_ZETA

/mob/living/carbon/xenomorph/shrike/Zeta
	hivenumber = XENO_HIVE_ZETA

/mob/living/carbon/xenomorph/spitter/Zeta
	hivenumber = XENO_HIVE_ZETA

/mob/living/carbon/xenomorph/warrior/Zeta
	hivenumber = XENO_HIVE_ZETA

/mob/living/carbon/xenomorph/wraith/Zeta
	hivenumber = XENO_HIVE_ZETA

/mob/living/carbon/xenomorph/king/Zeta
	hivenumber = XENO_HIVE_ZETA

/datum/hive_status/admeme
	name = "Admeme"
	hivenumber = XENO_HIVE_ADMEME
	prefix = "Admeme "

/mob/living/carbon/xenomorph/queen/admeme
	hivenumber = XENO_HIVE_ADMEME

/mob/living/carbon/xenomorph/king/admeme
	hivenumber = XENO_HIVE_ADMEME

// ***************************************
// *********** Xeno hive compare helpers
// ***************************************

// Everything below can have a hivenumber set and these ensure easy hive comparisons can be made

// atom level because of /obj/projectile/var/atom/firer
/atom/proc/issamexenohive(atom/A)
	if(!get_xeno_hivenumber() || !A?.get_xeno_hivenumber())
		return FALSE
	return get_xeno_hivenumber() == A.get_xeno_hivenumber()

/atom/proc/get_xeno_hivenumber()
	return FALSE

/obj/effect/alien/egg/get_xeno_hivenumber()
	return hivenumber

/obj/item/xeno_egg/get_xeno_hivenumber()
	return hivenumber

/obj/item/alien_embryo/get_xeno_hivenumber()
	return hivenumber

/obj/item/clothing/mask/facehugger/get_xeno_hivenumber()
	return hivenumber

/mob/living/carbon/xenomorph/get_xeno_hivenumber()
	return hivenumber

/obj/structure/xeno/tunnel/get_xeno_hivenumber()
	return hivenumber

/obj/structure/xeno/resin/xeno_turret/get_xeno_hivenumber()
	return associated_hive.hivenumber

/datum/hive_status/ui_state(mob/user)
	return GLOB.xeno_state

/// Controls the evolution UI
/datum/hive_status/ui_interact(mob/user, datum/tgui/ui)
	// Xeno only screen
	if(!isxeno(user))
		return

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "HiveEvolveScreen")
		ui.open()

/// Static data provided once when the ui is opened
/datum/hive_status/ui_static_data(mob/living/carbon/xenomorph/xeno)
	. = list()
	.["name"] = xeno.xeno_caste.display_name
	.["abilities"] = list()
	for(var/ability in xeno.xeno_caste.actions)
		var/datum/action/xeno_action/xeno_ability = ability
		if(!(SSticker.mode.flags_xeno_abilities & initial(xeno_ability.gamemode_flags)))
			continue
		.["abilities"]["[ability]"] = list(
			"name" = initial(xeno_ability.name),
			"desc" = initial(xeno_ability.mechanics_text),
			"cost" = initial(xeno_ability.plasma_cost),
			"cooldown" = (initial(xeno_ability.cooldown_timer) / 10)
		)
	.["evolves_to"] = list()
	for(var/evolves_into in xeno.xeno_caste.evolves_to)
		var/datum/xeno_caste/caste = GLOB.xeno_caste_datums[evolves_into][XENO_UPGRADE_BASETYPE]
		var/list/caste_data = list("type_path" = caste.caste_type_path, "name" = caste.display_name, "abilities" = list())
		for(var/ability in caste.actions)
			var/datum/action/xeno_action/xeno_ability = ability
			if(!(SSticker.mode.flags_xeno_abilities & initial(xeno_ability.gamemode_flags)))
				continue
			caste_data["abilities"]["[ability]"] = list(
				"name" = initial(xeno_ability.name),
				"desc" = initial(xeno_ability.mechanics_text),
				"cost" = initial(xeno_ability.plasma_cost),
				"cooldown" = (initial(xeno_ability.cooldown_timer) / 10)
			)
		.["evolves_to"]["[caste.caste_type_path]"] = caste_data

/// Some data to update the UI with the current evolution status
/datum/hive_status/ui_data(mob/living/carbon/xenomorph/xeno)
	. = list()

	.["can_evolve"] = !xeno.is_ventcrawling && \
		!xeno.incapacitated(TRUE) && \
		xeno.health >= xeno.maxHealth && \
		xeno.plasma_stored >= xeno.xeno_caste.plasma_max

	if(isxenolarva(xeno))
		.["evolution"] = list(
			"current" = xeno.amount_grown,
			"max" = xeno.max_grown
		)
		return
	.["evolution"] = list(
		"current" = xeno.evolution_stored,
		"max" = xeno.xeno_caste.evolution_threshold
	)

/// Handles actuually evolving
/datum/hive_status/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	var/mob/living/carbon/xenomorph/xeno = usr
	switch(action)
		if("evolve")
			SStgui.close_user_uis(usr, src, "main")
			var/datum/xeno_caste/caste = GLOB.xeno_caste_datums[text2path(params["path"])][XENO_UPGRADE_BASETYPE]
			xeno.do_evolve(caste.caste_type_path, caste.display_name) // All the checks for can or can't are handled inside do_evolve
			return TRUE

/datum/hive_status/proc/update_tier_limits()
	tier3_xeno_limit = max(length(xenos_by_tier[XENO_TIER_THREE]),FLOOR((length(xenos_by_tier[XENO_TIER_ZERO])+length(xenos_by_tier[XENO_TIER_ONE])+length(xenos_by_tier[XENO_TIER_TWO])+length(xenos_by_tier[XENO_TIER_FOUR]))/3+1,1))
	tier2_xeno_limit = max(length(xenos_by_tier[XENO_TIER_TWO]),length(xenos_by_tier[XENO_TIER_ZERO]) + length(xenos_by_tier[XENO_TIER_ONE]) + length(xenos_by_tier[XENO_TIER_FOUR])+1 - length(xenos_by_tier[XENO_TIER_THREE]))

///Handles the timer when all silos are destroyed
/datum/hive_status/proc/handle_silo_death_timer()
	return

/datum/hive_status/normal/handle_silo_death_timer()
	if(!isdistressgamemode(SSticker.mode))
		return
	if(world.time < MINIMUM_TIME_SILO_LESS_COLLAPSE)
		return
	var/datum/game_mode/infestation/distress/D = SSticker.mode
	if(D.round_stage != INFESTATION_MARINE_DEPLOYMENT)
		if(D?.siloless_hive_timer)
			deltimer(D.siloless_hive_timer)
			D.siloless_hive_timer = null
		return
	if(GLOB.xeno_resin_silos.len)
		if(D?.siloless_hive_timer)
			deltimer(D.siloless_hive_timer)
			D.siloless_hive_timer = null
		return

	if(D?.siloless_hive_timer)
		return

	xeno_message("We don't have any silos! The hive will collapse if nothing is done", "xenoannounce", 6, TRUE)
	D.siloless_hive_timer = addtimer(CALLBACK(D, /datum/game_mode.proc/siloless_hive_collapse), 5 MINUTES, TIMER_STOPPABLE)

/**
 * Add a mob to the candidate queue, the first mobs of the queue will have priority on new larva spots
 * return TRUE if the observer was added, FALSE if it was removed
 */
/datum/hive_status/proc/add_to_larva_candidate_queue(mob/dead/observer/observer)
	var/datum/job/xeno_job = SSjob.GetJobType(/datum/job/xenomorph)
	var/stored_larva = xeno_job.total_positions - xeno_job.current_positions
	var/list/possible_mothers = list()
	var/list/possible_silos = list()
	SEND_SIGNAL(src, COMSIG_HIVE_XENO_MOTHER_PRE_CHECK, possible_mothers, possible_silos)
	if(stored_larva > 0 && !LAZYLEN(candidate) && (length(possible_mothers) || length(possible_silos) || (SSticker.mode?.flags_round_type & MODE_SILO_RESPAWN && !SSsilo.can_fire)))
		attempt_to_spawn_larva(observer)
		return
	if(LAZYFIND(candidate, observer))
		remove_from_larva_candidate_queue(observer)
		return FALSE
	LAZYADD(candidate, observer)
	RegisterSignal(observer, COMSIG_PARENT_QDELETING, .proc/clean_observer)
	observer.larva_position =  LAZYLEN(candidate)
	to_chat(observer, "<span class='warning'>There are no burrowed Larvae or no silos. You are in position [observer.larva_position] to become a Xenomorph.</span>")
	return TRUE

/// Remove an observer from the larva candidate queue
/datum/hive_status/proc/remove_from_larva_candidate_queue(mob/dead/observer/observer)
	LAZYREMOVE(candidate, observer)
	UnregisterSignal(observer, COMSIG_PARENT_QDELETING)
	to_chat(observer, "<span class='warning'>You left the Larva queue.</span>")
	var/mob/dead/observer/observer_in_queue
	for(var/i in 1 to LAZYLEN(candidate))
		observer_in_queue = candidate[i]
		observer_in_queue.larva_position = i

///Propose larvas until their is no more candidates, or no more burrowed
/datum/hive_status/proc/give_larva_to_next_in_queue()
	var/list/possible_mothers = list()
	var/list/possible_silos = list()
	SEND_SIGNAL(src, COMSIG_HIVE_XENO_MOTHER_PRE_CHECK, possible_mothers, possible_silos)
	if(!length(possible_mothers) && !length(possible_silos) && (!(SSticker.mode?.flags_round_type & MODE_SILO_RESPAWN) || SSsilo.can_fire))
		return
	var/datum/job/xeno_job = SSjob.GetJobType(/datum/job/xenomorph)
	var/stored_larva = round(xeno_job.total_positions - xeno_job.current_positions)
	var/slot_occupied = min(stored_larva, LAZYLEN(candidate))
	if(slot_occupied < 1)
		return
	var/slot_really_taken = 0
	if(!xeno_job.occupy_job_positions(slot_occupied))
		return
	var/mob/dead/observer/observer_in_queue
	while(stored_larva > 0 && LAZYLEN(candidate))
		observer_in_queue = LAZYACCESS(candidate, 1)
		LAZYREMOVE(candidate, observer_in_queue)
		UnregisterSignal(observer_in_queue, COMSIG_PARENT_QDELETING)
		if(try_to_give_larva(observer_in_queue))
			stored_larva--
			slot_really_taken++
	if(slot_occupied - slot_really_taken > 0)
		xeno_job.free_job_positions(slot_occupied - slot_really_taken)
	for(var/i in 1 to LAZYLEN(candidate))
		observer_in_queue = LAZYACCESS(candidate, i)
		observer_in_queue.larva_position = i

/// Remove ref to avoid hard del and null error
/datum/hive_status/proc/clean_observer(datum/source)
	SIGNAL_HANDLER
	LAZYREMOVE(candidate, source)

///Attempt to give a larva to the next in line, if not possible, free the xeno position and propose it to another candidate
/datum/hive_status/proc/try_to_give_larva(mob/dead/observer/next_in_line)
	next_in_line.larva_position = 0
	if(!attempt_to_spawn_larva(next_in_line, TRUE))
		to_chat(next_in_line, "<span class='warning'>You failed to qualify to become a larva, you must join the queue again.</span>")
		return FALSE
	return TRUE
