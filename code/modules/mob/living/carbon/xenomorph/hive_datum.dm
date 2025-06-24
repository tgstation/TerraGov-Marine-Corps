/datum/hive_status
	interaction_flags = INTERACT_UI_INTERACT
	var/name = "Normal"
	var/hivenumber = XENO_HIVE_NORMAL
	///The current ruler of the xeno hive
	var/mob/living/carbon/xenomorph/living_xeno_ruler
	///Timer for caste evolution after the last one died, CASTE = TIMER
	var/list/caste_death_timers = list()
	var/color = null
	var/prefix = ""
	var/hive_flags = NONE
	var/list/xeno_leader_list = list()
	/// /datum/xeno_caste = list(xeno mobs)
	var/list/list/xenos_by_typepath = list()
	var/list/list/xenos_by_tier = list()
	var/list/list/xenos_by_upgrade = list()
	var/list/dead_xenos = list() // xenos that are still assigned to this hive but are dead.
	var/list/list/xenos_by_zlevel = list()
	///list of evo towers
	var/list/obj/structure/xeno/evotower/evotowers = list()
	///list of upgrade towers
	var/list/obj/structure/xeno/psychictower/psychictowers = list()
	///list of phero towers
	var/list/obj/structure/xeno/pherotower/pherotowers = list()
	/// List of recovery pylons.
	var/list/obj/structure/xeno/recovery_pylon/recovery_pylons = list()

	///list of hivemind cores
	var/list/obj/structure/xeno/hivemindcore/hivemindcores = list()
	var/tier3_xeno_limit
	var/tier2_xeno_limit
	/// Queue of all clients wanting to join xeno side
	var/list/client/candidates

	///Reference to upgrades available and purchased by this hive.
	var/datum/hive_purchases/purchases = new
	/// The nuke HUD timer datum, shown on each xeno's screen
	var/atom/movable/screen/text/screen_timer/nuke_hud_timer

// ***************************************
// *********** Init
// ***************************************
/datum/hive_status/New()
	. = ..()
	LAZYINITLIST(candidates)
	/*
	for(var/datum/xeno_caste/caste_type AS in subtypesof(/datum/xeno_caste))
		if(caste_type.upgrade != XENO_UPGRADE_BASETYPE)
			continue
		if(caste_type.type != caste_type.base_strain_type)
			continue
			xenos_by_typepath[caste_type] = list()
	*/

	for(var/datum/xeno_caste/caste_type AS in subtypesof(/datum/xeno_caste))
		if(caste_type.upgrade == XENO_UPGRADE_BASETYPE)
			xenos_by_typepath[caste_type] = list()

	for(var/tier in GLOB.xenotiers)
		xenos_by_tier[tier] = list()

	for(var/upgrade in GLOB.xenoupgradetiers)
		xenos_by_upgrade[upgrade] = list()

	SSdirection.set_leader(hivenumber, null)

	RegisterSignals(SSdcs, list(COMSIG_GLOB_NUKE_START, COMSIG_GLOB_SHIP_SELF_DESTRUCT_ACTIVATED), PROC_REF(setup_nuke_hud_timer))
// ***************************************
// *********** UI for Hive Status
// ***************************************
/datum/hive_status/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "HiveStatus")
		ui.open()

/datum/hive_status/ui_state(mob/user)
	return GLOB.hive_ui_state

/datum/hive_status/ui_assets(mob/user)
	. = ..()
	. += get_asset_datum(/datum/asset/spritesheet/hivestatus)

/datum/hive_status/ui_data(mob/user)
	. = ..()
	.["hive_max_tier_two"] = tier2_xeno_limit
	.["hive_max_tier_three"] = tier3_xeno_limit
	.["hive_minion_count"] = length(xenos_by_tier[XENO_TIER_MINION])

	var/datum/job/xeno_job = SSjob.GetJobType(/datum/job/xenomorph)
	.["hive_larva_current"] = xeno_job.job_points
	.["hive_larva_rate"] = SSsilo.current_larva_spawn_rate
	.["hive_larva_burrowed"] = xeno_job.total_positions - xeno_job.current_positions

	.["hive_strategic_psy_points"] = !isnull(SSpoints.xeno_strategic_points_by_hive[hivenumber]) ? SSpoints.xeno_strategic_points_by_hive[hivenumber] : 0
	.["hive_tactical_psy_points"] = !isnull(SSpoints.xeno_tactical_points_by_hive[hivenumber]) ? SSpoints.xeno_tactical_points_by_hive[hivenumber] : 0

	var/hivemind_countdown = SSticker.mode?.get_hivemind_collapse_countdown()
	.["hive_orphan_collapse"] = !isnull(hivemind_countdown) ? hivemind_countdown : 0
	// Show all the death timers in milliseconds
	.["hive_death_timers"] = list()
	// The key for caste_death_timer is the mob's type
	for(var/datum/xeno_caste/caste AS in caste_death_timers)
		var/timeleft = timeleft(caste_death_timers[caste])
		.["hive_death_timers"] += list(list(
			"caste" = caste.caste_name,
			"time_left" = round(timeleft MILLISECONDS),
			"end_time" = caste.death_evolution_delay MILLISECONDS,
		))

	.["hive_primos"] = list()
	for(var/tier in GLOB.tier_to_primo_upgrade)
		.["hive_primos"] += list(list(
			"tier" = GLOB.tier_as_number[tier],
			"purchased" = purchases.upgrades_by_name[GLOB.tier_to_primo_upgrade[tier]]?.times_bought
		))

	.["hive_structures"] = list()
	// Silos
	for(var/obj/structure/xeno/silo/resin_silo AS in GLOB.xeno_resin_silos_by_hive[hivenumber])
		.["hive_structures"] += list(get_structure_packet(resin_silo))
	// Acid, sticky, and hugger turrets.
	for(var/obj/structure/xeno/xeno_turret/turret AS in GLOB.xeno_resin_turrets_by_hive[hivenumber])
		.["hive_structures"] += list(get_structure_packet(turret))
	// Psychic relays
	for(var/obj/structure/xeno/psychictower/tower AS in GLOB.hive_datums[hivenumber].psychictowers)
		.["hive_structures"] += list(get_structure_packet(tower))
	// Evolution towers (if they're ever built)
	for(var/obj/structure/xeno/evotower/tower AS in GLOB.hive_datums[hivenumber].evotowers)
		.["hive_structures"] += list(get_structure_packet(tower))
	// Pheromone towers
	for(var/obj/structure/xeno/pherotower/tower AS in GLOB.hive_datums[hivenumber].pherotowers)
		.["hive_structures"] += list(get_structure_packet(tower))
	// Hivemind cores
	for(var/obj/structure/xeno/hivemindcore/core AS in GLOB.hive_datums[hivenumber].hivemindcores)
		.["hive_structures"] += list(get_structure_packet(core))
	// Spawners
	for(var/obj/structure/xeno/spawner/spawner AS in GLOB.xeno_spawners_by_hive[hivenumber])
		.["hive_structures"] += list(get_structure_packet(spawner))
	// Acid Jaws
	for(var/obj/structure/xeno/acid_maw/acid_jaws AS in GLOB.xeno_acid_jaws_by_hive[hivenumber])
		.["hive_structures"] += list(get_structure_packet(acid_jaws))

	.["xeno_info"] = list()
	for(var/mob/living/carbon/xenomorph/xeno AS in get_all_xenos())
		if(initial(xeno.tier) == XENO_TIER_MINION)
			continue // Skipping minions
		var/datum/xeno_caste/caste = xeno.xeno_caste
		var/plasma_multi = caste.plasma_regen_limit == 0 ? 1 : caste.plasma_regen_limit // Division by 0 bad.
		var/health = xeno.health > 0 ? xeno.health / xeno.maxHealth : -xeno.health / xeno.get_death_threshold()
		.["xeno_info"] += list(list(
			"ref" = REF(xeno),
			"name" = xeno.name,
			"location" = get_xeno_location(xeno),
			"health" = round(health * 100, 1),
			"plasma" = round((xeno.plasma_stored / (caste.plasma_max * plasma_multi)) * 100, 1),
			"is_leader" = xeno.xeno_flags & XENO_LEADER,
			"is_ssd" = !xeno.client,
			"index" = GLOB.hive_ui_caste_index[caste.base_strain_type],
		))

	var/mob/living/carbon/xenomorph/xeno_user
	if(isxeno(user))
		xeno_user = user

	var/mob/watched = ""
	if(isobserver(user) && !QDELETED(user.orbiting))
		watched = !QDELETED(user.orbiting.parent) ? REF(user.orbiting.parent) : ""
	else if(isxeno(user))
		watched = !QDELETED(xeno_user.observed_xeno) ? REF(xeno_user.observed_xeno) : ""
	.["user_watched_xeno"] = watched

	.["user_evolution"] = isxeno(user) ? xeno_user.evolution_stored : 0

	.["user_maturity"] = isxeno(user) ? xeno_user.upgrade_stored : 0
	.["user_next_mat_level"] = isxeno(user) && xeno_user.upgrade_possible() ? xeno_user.xeno_caste.upgrade_threshold : 0
	.["user_tracked"] = isxeno(user) && !isnull(xeno_user.tracked) ? REF(xeno_user.tracked) : ""

	.["user_show_empty"] = !!(user.client.prefs.status_toggle_flags & HIVE_STATUS_SHOW_EMPTY)
	.["user_show_compact"] = !!(user.client.prefs.status_toggle_flags & HIVE_STATUS_COMPACT_MODE)
	.["user_show_general"] = !!(user.client.prefs.status_toggle_flags & HIVE_STATUS_SHOW_GENERAL)
	.["user_show_population"] = !!(user.client.prefs.status_toggle_flags & HIVE_STATUS_SHOW_POPULATION)
	.["user_show_xeno_list"] = !!(user.client.prefs.status_toggle_flags & HIVE_STATUS_SHOW_XENO_LIST)
	.["user_show_structures"] = !!(user.client.prefs.status_toggle_flags & HIVE_STATUS_SHOW_STRUCTURES)

/// Returns a data entry for the "xeno structures" list based on the structure passed
/datum/hive_status/proc/get_structure_packet(obj/structure/xeno/struct)
	return list(
		"ref" = REF(struct),
		"name" = struct.name,
		"integrity" = struct.obj_integrity,
		"max_integrity" = struct.max_integrity,
		"location" = get_xeno_location(struct),
	)

/datum/hive_status/ui_static_data(mob/user)
	. = ..()

	.["static_info"] = GLOB.hive_ui_static_data

	.["hive_name"] = name
	.["hive_orphan_max"] = NUCLEAR_WAR_ORPHAN_HIVEMIND MILLISECONDS

	var/datum/job/xeno_job = SSjob.GetJobType(/datum/job/xenomorph)
	.["hive_larva_threshold"] = xeno_job.job_points_needed

	.["user_ref"] = REF(user)
	.["user_xeno"] = isxeno(user)
	if(isxeno(user))
		var/mob/living/carbon/xenomorph/x = user
		if(x == living_xeno_ruler)
			.["user_ruler"] = user




	.["user_index"] = 0
	if(isxeno(user))
		var/mob/living/carbon/xenomorph/xeno_user = user
		.["user_index"] = GLOB.hive_ui_caste_index[xeno_user.xeno_caste.base_strain_type]

	.["user_purchase_perms"] = FALSE
	if(isxeno(user))
		var/mob/living/carbon/xenomorph/xeno_user = user
		if(xeno_user.actions_by_path[/datum/action/ability/xeno_action/blessing_menu])
			.["user_purchase_perms"] = TRUE

/datum/hive_status/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	/// Actions that don't require you to be a xeno
	switch(action)
		if("ToggleGeneral")
			usr.client.prefs.status_toggle_flags ^= HIVE_STATUS_SHOW_GENERAL
			usr.client.prefs.save_preferences()
		if("ToggleCompact")
			usr.client.prefs.status_toggle_flags ^= HIVE_STATUS_COMPACT_MODE
			usr.client.prefs.save_preferences()
		if("TogglePopulation")
			usr.client.prefs.status_toggle_flags ^= HIVE_STATUS_SHOW_POPULATION
			usr.client.prefs.save_preferences()
		if("ToggleXenoList")
			usr.client.prefs.status_toggle_flags ^= HIVE_STATUS_SHOW_XENO_LIST
			usr.client.prefs.save_preferences()
		if("ToggleStructures")
			usr.client.prefs.status_toggle_flags ^= HIVE_STATUS_SHOW_STRUCTURES
			usr.client.prefs.save_preferences()
		if("ToggleEmpty")
			usr.client.prefs.status_toggle_flags ^= HIVE_STATUS_SHOW_EMPTY

	/// If the action we're sending is to observe, this will be the xeno being observed. Otherwise it's the xeno pressing the button.
	var/mob/living/carbon/xenomorph/xeno_target = locate(params["xeno"])
	if(QDELETED(xeno_target))
		return

	switch(action)
		if("Evolve")
			if(!isxeno(usr))
				return
			GLOB.evo_panel.ui_interact(usr)
		if("Follow")
			if(isobserver(usr))
				var/mob/dead/observer/ghost = usr
				ghost.ManualFollow(xeno_target)
			else if(!isxeno(usr))
				return
			SEND_SIGNAL(usr, COMSIG_XENOMORPH_WATCHXENO, xeno_target)
		if("Deevolve")
			if(!isxenoqueen(usr)) // Queen only. No boys allowed.
				return
			attempt_deevolve(usr, xeno_target)
		if("Leader")
			if(living_xeno_ruler != usr) // Only the current hive ruler can assign leaders
				return
			SEND_SIGNAL(usr, COMSIG_XENOMORPH_LEADERSHIP, xeno_target)
		if("Plasma")
			if(!isxenoqueen(usr)) // Queen only.
				return
			SEND_SIGNAL(usr, COMSIG_XENOMORPH_QUEEN_PLASMA, xeno_target)
		if("Blessings")
			if(!isxeno(usr))
				return
			SEND_SIGNAL(usr, COMSIG_XENOABILITY_BLESSINGSMENU)
		if("Compass")
			var/atom/target = locate(params["target"])
			if(isobserver(usr))
				var/mob/dead/observer/ghost = usr
				ghost.ManualFollow(target)
			if(!isxeno(usr))
				return
			xeno_target.set_tracked(target)

/// Returns the string location of the xeno
/datum/hive_status/proc/get_xeno_location(atom/xeno)
	. = "Unknown"
	if(is_centcom_level(xeno.z))
		return

	var/area/xeno_area = get_area(xeno)
	if(xeno_area)
		. = xeno_area.name

// ***************************************
// *********** Helpers
// ***************************************
/datum/hive_status/proc/get_total_xeno_number() // unsafe for use by gamemode code
	. = 0
	for(var/t in xenos_by_tier)
		if(t == XENO_TIER_MINION)
			continue
		. += length(xenos_by_tier[t])

///returns a list of all caste members, including other strains of this xeno caste
/datum/hive_status/proc/get_all_caste_members(caste_type)
	RETURN_TYPE(/list)

	ASSERT(ispath(caste_type, /datum/xeno_caste))
	. = list()
	var/list/all_strain_types = get_strain_options(caste_type)
	for(var/strain_type in all_strain_types)
		. += xenos_by_typepath[strain_type]

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

/**
 * The total amount of xenomorphs that are considered for evolving purposes,
 * subtypes also consider stored larva, not just the current amount of living xenos
 */
/datum/hive_status/proc/total_xenos_for_evolving()
	return get_total_xeno_number()

/datum/hive_status/normal/total_xenos_for_evolving()
	var/datum/job/xeno_job = SSjob.GetJobType(/datum/job/xenomorph)
	var/stored_larva = xeno_job.total_positions - xeno_job.current_positions
	return get_total_xeno_number() + stored_larva

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
		if(!queen && typepath == /datum/xeno_caste/queen) // hardcoded check for now // TODO still hardcoded 5 years later...
			continue
		xenos += xenos_by_typepath[typepath]
	return xenos

///Returning all xenos including queen that are not at centcom and not self
/datum/hive_status/proc/get_watchable_xenos(mob/living/carbon/xenomorph/self)
	var/list/xenos = list()
	for(var/typepath in xenos_by_typepath)
		for(var/mob/living/carbon/xenomorph/X AS in xenos_by_typepath[typepath])
			if(X == self || is_centcom_level(X.z))
				continue
			xenos += X
	return xenos

// doing this by type means we get a pseudo sorted list
/datum/hive_status/proc/get_leaderable_xenos()
	var/list/xenos = list()
	for(var/typepath in xenos_by_typepath)
		if(typepath == /datum/xeno_caste/queen) // hardcoded check for now // TODO STILL HARDCODED 5 YEARS LATER BTW
			continue
		for(var/i in xenos_by_typepath[typepath])
			var/mob/living/carbon/xenomorph/X = i
			if(is_centcom_level(X.z))
				continue
			if(!(X.xeno_caste.can_flags & CASTE_CAN_BE_LEADER))
				continue
			xenos += X
	return xenos


///fetches number of bonus evo points given to the hive
/datum/hive_status/proc/get_evolution_boost()
	. = 0
	for(var/obj/structure/xeno/evotower/tower AS in evotowers)
		. += tower.boost_amount

///fetches number of bonus maturity points given to the hive
/datum/hive_status/proc/get_upgrade_boost()
	. = 0
	for(var/obj/structure/xeno/evotower/tower AS in evotowers)
		. += tower.maturty_boost_amount

// ***************************************
// *********** Adding xenos
// ***************************************
/datum/hive_status/proc/add_xeno(mob/living/carbon/xenomorph/X) // should only be called by add_to_hive below
	if(X.stat == DEAD)
		dead_xenos += X
	else
		add_to_lists(X)

	post_add(X)
	nuke_hud_timer?.apply_to(X)
	return TRUE

// helper function
/datum/hive_status/proc/add_to_lists(mob/living/carbon/xenomorph/X)
	xenos_by_tier[X.tier] += X
	xenos_by_upgrade[X.upgrade] += X
	if(X.z)
		LAZYADD(xenos_by_zlevel["[X.z]"], X)
	RegisterSignal(X, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(xeno_z_changed))

	if(!xenos_by_typepath[get_base_caste_type(X.xeno_caste.type)])
		stack_trace("trying to add an invalid typepath into hivestatus list [X.caste_base_type]")
		return FALSE

	xenos_by_typepath[get_base_caste_type(X.xeno_caste.type)] += X
	update_tier_limits() //Update our tier limits.

	return TRUE

/mob/living/carbon/xenomorph/proc/add_to_hive(datum/hive_status/HS, force=FALSE, prevent_ruler=FALSE)
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
	hive.update_ruler()

/mob/living/carbon/xenomorph/hivemind/add_to_hive(datum/hive_status/HS, force = FALSE, prevent_ruler=FALSE)
	. = ..()
	if(!GLOB.xeno_structures_by_hive[HS.hivenumber])
		GLOB.xeno_structures_by_hive[HS.hivenumber] = list()

	var/obj/structure/xeno/hivemindcore/hive_core = get_core()

	if(!hive_core) //how are you even alive then?
		qdel(src)
		return

	GLOB.xeno_structures_by_hive[HS.hivenumber] |= hive_core

	if(!GLOB.xeno_critical_structures_by_hive[HS.hivenumber])
		GLOB.xeno_critical_structures_by_hive[HS.hivenumber] = list()

	GLOB.xeno_critical_structures_by_hive[HS.hivenumber] |= hive_core
	hive_core.hivenumber = HS.hivenumber
	hive_core.name = "[HS.hivenumber == XENO_HIVE_NORMAL ? "" : "[HS.name] "]hivemind core"
	hive_core.color = HS.color

/mob/living/carbon/xenomorph/proc/add_to_hive_by_hivenumber(hivenumber, force=FALSE, prevent_ruler=FALSE) // helper function to add by given hivenumber
	if(!GLOB.hive_datums[hivenumber])
		CRASH("add_to_hive_by_hivenumber called with invalid hivenumber")
	var/datum/hive_status/HS = GLOB.hive_datums[hivenumber]
	add_to_hive(HS, force, prevent_ruler)
	hive.update_tier_limits() //Update our tier limits.

// This is a special proc called only when a xeno is first created to set their hive and name properly
/mob/living/carbon/xenomorph/proc/set_initial_hivenumber(prevent_ruler=FALSE)
	add_to_hive_by_hivenumber(hivenumber, force=TRUE, prevent_ruler=prevent_ruler)

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

	nuke_hud_timer?.remove_from(X)
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

	if(!xenos_by_typepath[get_base_caste_type(X.xeno_caste.type)])
		stack_trace("trying to remove an invalid typepath from hivestatus list")
		return FALSE

	if(!xenos_by_typepath[get_base_caste_type(X.xeno_caste.type)].Remove(X))
		stack_trace("failed to remove a xeno from hive status typepath list, nothing was removed!?")
		return FALSE

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

	if((xeno_flags & XENO_LEADER) || (src in hive.xeno_leader_list))
		hive.remove_leader(src)

	if(hive.living_xeno_ruler == src)
		hive.set_ruler(null)
		hive.update_ruler()

	SSdirection.stop_tracking(hive.hivenumber, src)

	var/datum/hive_status/reference_hive = hive
	hive = null
	hivenumber = XENO_HIVE_NONE // failsafe value
	reference_hive.update_tier_limits() //Update our tier limits.

/datum/hive_status/proc/setup_nuke_hud_timer(source, thing)
	SIGNAL_HANDLER
	var/obj/machinery/nuclearbomb/nuke = thing
	if(!nuke.timer)
		CRASH("hive_status's setup_nuke_hud_timer called with invalid nuke object")
	nuke_hud_timer = new(null, null, get_all_xenos() , nuke.timer, "Nuke ACTIVE: ${timer}")

/datum/hive_status/Destroy(force, ...)
	. = ..()
	UnregisterSignal(SSdcs, COMSIG_GLOB_NUKE_START)

/mob/living/carbon/xenomorph/hivemind/remove_from_hive()
	var/obj/structure/xeno/hivemindcore/hive_core = get_core()
	GLOB.xeno_structures_by_hive[hivenumber] -= hive_core
	GLOB.xeno_critical_structures_by_hive[hivenumber] -= hive_core
	. = ..()
	if(!QDELETED(src)) //if we aren't dead, somehow?
		hive_core.name = "banished hivemind core"
		hive_core.color = null


// ***************************************
// *********** Xeno leaders
// ***************************************
/datum/hive_status/proc/add_leader(mob/living/carbon/xenomorph/X)
	xeno_leader_list += X
	X.xeno_flags |= XENO_LEADER
	X.give_rally_abilities()
	X.handle_xeno_leader_pheromones(living_xeno_ruler)

/datum/hive_status/proc/remove_leader(mob/living/carbon/xenomorph/X)
	xeno_leader_list -= X
	X.xeno_flags &= ~XENO_LEADER
	X.handle_xeno_leader_pheromones(living_xeno_ruler)

	if(!isxenoshrike(X) && !isxenoqueen(X) && !isxenohivemind(X)) //These innately have the Rally Hive ability
		X.remove_rally_hive_ability()

/datum/hive_status/proc/update_leader_pheromones() // helper function to easily trigger an update of leader pheromones
	for(var/mob/living/carbon/xenomorph/leader AS in xeno_leader_list)
		leader.handle_xeno_leader_pheromones(living_xeno_ruler)

// ***************************************
// *********** Status changes
// ***************************************
/datum/hive_status/proc/xeno_z_changed(mob/living/carbon/xenomorph/X, old_z, new_z)
	SIGNAL_HANDLER
	LAZYREMOVE(xenos_by_zlevel["[old_z]"], X)
	LAZYADD(xenos_by_zlevel["[new_z]"], X)

// ***************************************
// *********** Xeno upgrades
// ***************************************
/// called by Xenomorph/proc/upgrade_xeno() to update xeno_by_upgrade
/datum/hive_status/proc/upgrade_xeno(mob/living/carbon/xenomorph/X, oldlevel, newlevel)
	xenos_by_upgrade[oldlevel] -= X
	xenos_by_upgrade[newlevel] += X

///attempts to have devolver devolve target
/datum/hive_status/proc/attempt_deevolve(mob/living/carbon/xenomorph/devolver, mob/living/carbon/xenomorph/target)
	if(target.is_ventcrawling)
		to_chat(devolver, span_xenonotice("Cannot deevolve, [target] is ventcrawling."))
		return

	if(!isturf(target.loc))
		to_chat(devolver, span_xenonotice("Cannot deevolve [target] here."))
		return

	if((target.health < target.maxHealth) || (target.plasma_stored < (target.xeno_caste.plasma_max * target.xeno_caste.plasma_regen_limit)))
		to_chat(devolver, span_xenonotice("Cannot deevolve, [target] is too weak."))
		return

	if(!target.xeno_caste.deevolves_to)
		to_chat(devolver, span_xenonotice("Cannot deevolve [target]."))
		return
	var/datum/xeno_caste/new_caste = GLOB.xeno_caste_datums[target.xeno_caste.deevolves_to][XENO_UPGRADE_BASETYPE]
	var/confirm = tgui_alert(devolver, "Are you sure you want to deevolve [target] from [target.xeno_caste.caste_name] to [new_caste.caste_name]?", null, list("Yes", "No"))
	if(confirm != "Yes")
		return

	var/reason = stripped_input(devolver, "Provide a reason for deevolving this xenomorph, [target]")
	if(isnull(reason))
		to_chat(devolver, span_xenonotice("De-evolution reason required."))
		return

	if(!devolver.check_concious_state())
		return

	if(target.is_ventcrawling)
		return

	if(!isturf(target.loc))
		return

	if((target.health < target.maxHealth) || (target.plasma_stored < (target.xeno_caste.plasma_max * target.xeno_caste.plasma_regen_limit)))
		return

	target.balloon_alert(target, "Forced deevolution")
	to_chat(target, span_xenowarning("[devolver] deevolved us for the following reason: [reason]."))

	target.do_evolve(new_caste.type, TRUE) // This already handles qdel and statistics.

	log_game("[key_name(devolver)] has deevolved [key_name(target)]. Reason: [reason]")
	message_admins("[ADMIN_TPMONTY(devolver)] has deevolved [ADMIN_TPMONTY(target)]. Reason: [reason]")

// ***************************************
// *********** Xeno death
// ***************************************

///Handles any effects when a xeno dies
/datum/hive_status/proc/on_xeno_death(mob/living/carbon/xenomorph/dead_xeno)
	remove_from_lists(dead_xeno)
	dead_xenos += dead_xeno

	SEND_SIGNAL(dead_xeno, COMSIG_HIVE_XENO_DEATH)

	if(dead_xeno == living_xeno_ruler)
		on_ruler_death(dead_xeno)
	var/datum/xeno_caste/base_caste = GLOB.xeno_caste_datums[get_parent_caste_type(dead_xeno.xeno_caste)][XENO_UPGRADE_BASETYPE]
	if(base_caste.death_evolution_delay <= 0)
		return
	if(!caste_death_timers[base_caste])
		caste_death_timers[base_caste] = addtimer(CALLBACK(src, PROC_REF(end_caste_death_timer), base_caste), base_caste.death_evolution_delay , TIMER_STOPPABLE)

///Handles effects if a xeno is revived
/datum/hive_status/proc/on_xeno_revive(mob/living/carbon/xenomorph/X)
	dead_xenos -= X
	add_to_lists(X)
	return TRUE


// ***************************************
// *********** Ruler
// ***************************************

// The hivemind conduit is the xeno that on death severs the connection to the hivemind for xenos for half the time the death timer exists for.

/// Gets the hivemind conduit's death timer, AKA, the time before a replacement can evolve
/datum/hive_status/proc/get_hivemind_conduit_death_timer()
	return caste_death_timers[GLOB.xeno_caste_datums[/datum/xeno_caste/queen][XENO_UPGRADE_BASETYPE]]

/// Gets the total time that the death timer for the hivemind conduit will last
/datum/hive_status/proc/get_total_hivemind_conduit_time()
	var/datum/xeno_caste/xeno = GLOB.xeno_caste_datums[/datum/xeno_caste/queen][XENO_UPGRADE_BASETYPE]
	return initial(xeno.death_evolution_delay)

/datum/hive_status/proc/on_ruler_death(mob/living/carbon/xenomorph/ruler)
	set_ruler(null)
	var/announce = TRUE
	if(SSticker.current_state == GAME_STATE_FINISHED || SSticker.current_state == GAME_STATE_SETTING_UP)
		announce = FALSE
	if(announce)
		xeno_message("A sudden tremor ripples through the hive... \the [ruler] has been slain! Vengeance!", "xenoannounce", 6, TRUE)
	notify_ghosts("\The <b>[ruler]</b> has been slain!", source = ruler, action = NOTIFY_JUMP)
	update_leader_pheromones()
	for(var/mob/living/carbon/xenomorph/leader AS in xeno_leader_list)
		remove_leader(leader)
		leader.hud_set_queen_overwatch()
	ruler.hud_set_queen_overwatch()
	update_ruler()
	return TRUE

/// If the current ruler devolves or caste_swaps we want to properly handle it
/datum/hive_status/proc/on_missing_ruler(mob/living/carbon/xenomorph/old_mob, mob/living/carbon/xenomorph/new_mob)
	SIGNAL_HANDLER
	if(old_mob == living_xeno_ruler)
		living_xeno_ruler = null
	update_leader_pheromones()
	for(var/mob/living/carbon/xenomorph/leader AS in xeno_leader_list)
		remove_leader(leader)
		leader.hud_set_queen_overwatch()
		leader.update_leader_icon(FALSE)
	if(living_xeno_ruler)
		living_xeno_ruler.remove_ruler_abilities()
		UnregisterSignal(living_xeno_ruler, list(COMSIG_XENOMORPH_EVOLVED, COMSIG_XENOMORPH_DEEVOLVED))
	set_ruler(null)
	update_ruler(old_mob)

/// This proc attempts to find a new ruler to lead the hive.
/datum/hive_status/proc/update_ruler(mob/living/carbon/xenomorph/previous_ruler)
	SIGNAL_HANDLER
	if(isxenoqueen(living_xeno_ruler))
		return

	var/mob/living/carbon/xenomorph/successor
	var/list/mob/living/carbon/xenomorph/prio_candidates = xenos_by_tier[XENO_TIER_FOUR]
	var/list/mob/living/carbon/xenomorph/seco_candidates = xenos_by_tier[XENO_TIER_THREE]

	for(var/mob/living/carbon/xenomorph/potential_successor in prio_candidates)
		successor = potential_successor
		if(isxenoqueen(potential_successor))
			break

	if(!successor)
		for(var/mob/living/carbon/xenomorph/potential_successor in seco_candidates)
			if(potential_successor.xeno_caste.can_flags & CASTE_CAN_BE_RULER && !living_xeno_ruler)
				if(previous_ruler == potential_successor)
					continue
				successor = potential_successor

	if(!successor || living_xeno_ruler == successor)
		return

	var/announce = TRUE
	if(SSticker.current_state == GAME_STATE_FINISHED || SSticker.current_state == GAME_STATE_SETTING_UP)
		announce = FALSE

	if(living_xeno_ruler) /// Remove the old ruler if T4 or queen is taking over
		living_xeno_ruler.remove_ruler_abilities()
		living_xeno_ruler.update_leader_icon(FALSE)
		UnregisterSignal(living_xeno_ruler, list(COMSIG_XENOMORPH_EVOLVED, COMSIG_XENOMORPH_DEEVOLVED))

	var/mob/living/carbon/xenomorph/prev = living_xeno_ruler // ref to the ruler we're replacing
	remove_leader(successor)
	set_ruler(successor)
	successor.give_ruler_abilities()
	successor.hud_set_queen_overwatch()
	if(prev)
		prev.hud_set_queen_overwatch() // we want to remove the ruler star from the previous ruler
		prev = null // instantly null it
		successor.update_leader_icon(FALSE) // We dont want to call this if its the first xeno

	handle_ruler_timer()
	update_leader_pheromones()
	if(announce)
		xeno_message("\A [successor] has risen to lead the Hive! Rejoice!", "xenoannounce", 6)
		notify_ghosts("\The [successor] has risen to lead the Hive!", source = successor, action = NOTIFY_ORBIT)


/datum/hive_status/proc/set_ruler(mob/living/carbon/xenomorph/successor)
	SSdirection.clear_leader(hivenumber)
	if(!isnull(successor))
		SSdirection.set_leader(hivenumber, successor)
		RegisterSignals(successor, list(COMSIG_XENOMORPH_EVOLVED, COMSIG_XENOMORPH_DEEVOLVED), PROC_REF(on_missing_ruler), TRUE)
	living_xeno_ruler = successor
	handle_ruler_timer()


/datum/hive_status/proc/handle_ruler_timer()
	return


/datum/hive_status/proc/on_shuttle_hijack(obj/docking_port/mobile/marine_dropship/hijacked_ship)
	return


///Allows death delay caste to evolve. Safe for use by gamemode code, this allows per hive overrides
/datum/hive_status/proc/end_caste_death_timer(datum/xeno_caste/caste)
	xeno_message("The Hive is ready for a new [caste.caste_name] to evolve.", "xenoannounce", 6, TRUE)
	caste_death_timers[caste] = null

/datum/hive_status/proc/check_ruler()
	return TRUE


/datum/hive_status/normal/check_ruler()
	if(!(SSticker.mode?.round_type_flags & MODE_XENO_RULER))
		return TRUE
	return living_xeno_ruler


// ***************************************
// *********** Queen
// ***************************************

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
/datum/hive_status/proc/xeno_message(message = null, span_class = "xenoannounce", size = 5, force = FALSE, atom/target = null, sound = null, apply_preferences = FALSE, filter_list = null, arrow_type = /atom/movable/screen/arrow/leader_tracker_arrow, arrow_color, report_distance)

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
			var/atom/movable/screen/arrow/arrow_hud = new arrow_type
			//Prepare the tracker object and set its parameters
			arrow_hud.add_hud(X, target)
			if(arrow_color) //Set the arrow to our custom colour if applicable
				arrow_hud.color = arrow_color
			new /obj/effect/temp_visual/xenomorph/xeno_tracker_target(target, target) //Ping the source of our alert

		to_chat(X, "<span class='[span_class]'><font size=[size]> [message][report_distance ? " Distance: [get_dist(X, target)]" : ""]</font></span>")

///Used for setting the trackers of all xenos in the hive, like when a nuke activates
/datum/hive_status/proc/set_all_xeno_trackers(atom/target)
	for(var/mob/living/carbon/xenomorph/X AS in get_all_xenos())
		X.set_tracked(target)
		to_chat(X, span_notice("Now tracking [target.name]"))

// ***************************************
// *********** Normal Xenos
// ***************************************
/datum/hive_status/normal // subtype for easier typechecking and overrides
	hive_flags = HIVE_CAN_HIJACK
	/// Timer ID for the orphan hive timer
	var/atom/movable/screen/text/screen_timer/orphan_hud_timer

/datum/hive_status/normal/add_xeno(mob/living/carbon/xenomorph/X)
	. = ..()
	orphan_hud_timer?.apply_to(X)

/datum/hive_status/normal/remove_xeno(mob/living/carbon/xenomorph/X)
	. = ..()
	orphan_hud_timer?.remove_from(X)

/datum/hive_status/normal/handle_ruler_timer()
	if(!isinfestationgamemode(SSticker.mode)) //Check just need for unit test
		return
	if(!(SSticker.mode?.round_type_flags & MODE_XENO_RULER))
		return
	if(SSmonitor.gamestate == SHUTTERS_CLOSED) //don't trigger orphan hivemind if the shutters are closed
		return
	var/datum/game_mode/infestation/D = SSticker.mode

	if(living_xeno_ruler)
		if(D.orphan_hive_timer)
			deltimer(D.orphan_hive_timer)
			D.orphan_hive_timer = null
			QDEL_NULL(orphan_hud_timer)
		return

	if(D.orphan_hive_timer)
		return

	D.orphan_hive_timer = addtimer(CALLBACK(D, TYPE_PROC_REF(/datum/game_mode, orphan_hivemind_collapse)), NUCLEAR_WAR_ORPHAN_HIVEMIND, TIMER_STOPPABLE)

	orphan_hud_timer = new(null, null, get_all_xenos(), D.orphan_hive_timer, "Orphan Hivemind Collapse: ${timer}", 150, -80)

/datum/hive_status/normal/burrow_larva(mob/living/carbon/xenomorph/larva/L)
	if(!is_ground_level(L.z))
		return
	L.visible_message(span_xenodanger("[L] quickly burrows into the ground."))
	var/datum/job/xeno_job = SSjob.GetJobType(/datum/job/xenomorph)
	xeno_job.add_job_positions(1)
	update_tier_limits()
	GLOB.round_statistics.total_xenos_created-- // keep stats sane
	SSblackbox.record_feedback("tally", "round_statistics", -1, "total_xenos_created")
	qdel(L)


// This proc checks for available spawn points and offers a choice if there's more than one.
/datum/hive_status/proc/attempt_to_spawn_larva(client/xeno_candidate, larva_already_reserved = FALSE)
	if(isnull(xeno_candidate))
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
		if(SSticker.mode?.round_type_flags & MODE_SILO_RESPAWN && !SSsilo.can_fire) // Distress mode & prior to shutters opening, so let the queue bypass silos if needed
			return do_spawn_larva(xeno_candidate, pick(GLOB.spawns_by_job[/datum/job/xenomorph]), larva_already_reserved)
		to_chat(xeno_candidate, span_warning("There are no places currently available to receive new larvas."))
		return FALSE

	var/mob/living/carbon/xenomorph/chosen_mother
	if(length(possible_mothers) > 1)
		chosen_mother = tgui_input_list(xeno_candidate.mob, "Available Mothers", null, possible_mothers)
	else
		chosen_mother = possible_mothers[1]

	if(QDELETED(chosen_mother) || isnull(xeno_candidate))
		return FALSE

	return spawn_larva(xeno_candidate, chosen_mother, larva_already_reserved)


/datum/hive_status/proc/attempt_to_spawn_larva_in_silo(client/xeno_candidate, possible_silos, larva_already_reserved = FALSE)
	xeno_candidate.mob.playsound_local(xeno_candidate, 'sound/ambience/votestart.ogg', 50)
	window_flash(xeno_candidate)
	var/obj/structure/xeno/silo/chosen_silo
	if(length(possible_silos) > 1)
		chosen_silo = tgui_input_list(xeno_candidate.mob, "Available Egg Silos", "Spawn location", possible_silos, timeout = 20 SECONDS)
		if(!chosen_silo || isnull(xeno_candidate))
			return FALSE
		xeno_candidate.mob.reset_perspective(chosen_silo)
		var/double_check = tgui_alert(xeno_candidate.mob, "Spawn here?", "Spawn location", list("Yes","Pick another silo","Abort"), timeout = 20 SECONDS)
		if(double_check == "Pick another silo")
			return attempt_to_spawn_larva_in_silo(xeno_candidate, possible_silos, larva_already_reserved)
		else if(double_check != "Yes")
			xeno_candidate.mob.reset_perspective(null)
			remove_from_larva_candidate_queue(xeno_candidate)
			return FALSE
	else
		chosen_silo = possible_silos[1]
		xeno_candidate.mob.reset_perspective(chosen_silo)
		var/check = tgui_alert(xeno_candidate, "Spawn as a xeno?", "Spawn location", list("Yes", "Abort"), timeout = 20 SECONDS)
		if(check != "Yes")
			xeno_candidate.mob.reset_perspective(null)
			remove_from_larva_candidate_queue(xeno_candidate)
			return FALSE

	if(QDELETED(chosen_silo) || isnull(xeno_candidate))
		return FALSE

	xeno_candidate.mob.reset_perspective(null)
	return do_spawn_larva(xeno_candidate, chosen_silo.loc, larva_already_reserved)


/datum/hive_status/proc/spawn_larva(client/xeno_candidate, mob/living/carbon/xenomorph/mother, larva_already_reserved = FALSE)
	if(!xeno_candidate?.mob?.mind)
		return FALSE

	if(QDELETED(mother) || !istype(mother))
		to_chat(xeno_candidate.mob, span_warning("Something went awry with mom. Can't spawn at the moment."))
		return FALSE

	if(!larva_already_reserved)
		var/datum/job/xeno_job = SSjob.GetJobType(/datum/job/xenomorph)
		var/stored_larva = xeno_job.total_positions - xeno_job.current_positions
		if(!stored_larva)
			to_chat(xeno_candidate.mob, span_warning("There are no longer burrowed larvas available."))
			return FALSE

	var/list/possible_mothers = list()
	SEND_SIGNAL(src, COMSIG_HIVE_XENO_MOTHER_CHECK, possible_mothers) //List variable passed by reference, and hopefully populated.

	if(!(mother in possible_mothers))
		to_chat(xeno_candidate.mob, span_warning("This mother is not in a state to receive us."))
		return FALSE
	return do_spawn_larva(xeno_candidate, get_turf(mother), larva_already_reserved)


/datum/hive_status/proc/do_spawn_larva(client/xeno_candidate, turf/spawn_point, larva_already_reserved = FALSE)
	if(is_banned_from(xeno_candidate.ckey, ROLE_XENOMORPH))
		to_chat(xeno_candidate.mob, span_warning("You are jobbaned from the [ROLE_XENOMORPH] role."))
		return FALSE

	var/mob/living/carbon/xenomorph/larva/new_xeno = new /mob/living/carbon/xenomorph/larva(spawn_point)
	new_xeno.visible_message(span_xenodanger("A larva suddenly burrows out of the ground!"),
	span_xenodanger("We burrow out of the ground and awaken from our slumber. For the Hive!"))

	log_game("[key_name(xeno_candidate)] has joined as [new_xeno] at [AREACOORD(new_xeno.loc)].")
	var/datum/job/xeno_job = SSjob.GetJobType(/datum/job/xenomorph)
	message_admins("[key_name(xeno_candidate)] has joined as [ADMIN_TPMONTY(new_xeno)].")

	xeno_candidate.mob.mind.transfer_to(new_xeno, TRUE)
	new_xeno.playsound_local(new_xeno, 'sound/effects/alien/new_larva.ogg')
	to_chat(new_xeno, span_xenoannounce("We are a xenomorph larva awakened from slumber!"))
	if(!larva_already_reserved)
		xeno_job.occupy_job_positions(1)
	return new_xeno


/datum/hive_status/normal/on_shuttle_hijack(obj/docking_port/mobile/marine_dropship/hijacked_ship)
	GLOB.xeno_enter_allowed = FALSE
	xeno_message("Our Ruler has commanded the metal bird to depart for the metal hive in the sky! Run and board it to avoid a cruel death!")
	RegisterSignal(hijacked_ship, COMSIG_SHUTTLE_SETMODE, PROC_REF(on_hijack_depart))

	for(var/obj/structure/xeno/structure AS in GLOB.xeno_structures_by_hive[XENO_HIVE_NORMAL])
		if(!is_ground_level(structure.z) || structure.xeno_structure_flags & DEPART_DESTRUCTION_IMMUNE)
			continue
		qdel(structure)

	if(SSticker.mode?.round_type_flags & MODE_PSY_POINTS_ADVANCED)
		SSpoints.xeno_strategic_points_by_hive[hivenumber] = SILO_PRICE //Give a free silo when going shipside and a turret
		SSpoints.xeno_tactical_points_by_hive[hivenumber] = (XENO_TURRET_PRICE*4)


/datum/hive_status/normal/proc/on_hijack_depart(datum/source, new_mode)
	SIGNAL_HANDLER
	if(new_mode != SHUTTLE_CALL)
		return
	UnregisterSignal(source, COMSIG_SHUTTLE_SETMODE)

	// Add extra xenos based on the difference of xenos / marines
	var/players = SSticker.mode.count_humans_and_xenos()
	var/difference = round(players[2] - (players[1] * 0.5)) // no of xenos - half the no of players

	var/left_behind = 0
	for(var/mob/living/carbon/xenomorph/boarder AS in get_all_xenos())
		if(isdropshiparea(get_area(boarder)))
			continue
		if(!is_ground_level(boarder.z))
			continue
		if(isxenohivemind(boarder))
			continue
		INVOKE_ASYNC(boarder, TYPE_PROC_REF(/mob/living, gib))
		if(boarder.xeno_caste.tier == XENO_TIER_MINION)
			continue
		left_behind++
	var/datum/job/xeno_job = SSjob.GetJobType(/datum/job/xenomorph)
	if(left_behind)
		xeno_message("[left_behind > 1 ? "[left_behind] sisters" : "One sister"] perished due to being too slow to board the bird. The freeing of their psychic link allows us to call burrowed, at least.")
		xeno_job.add_job_positions(left_behind)
	if(difference < 0)
		if(xeno_job.total_positions < (-difference + xeno_job.current_positions))
			xeno_job.set_job_positions(-difference + xeno_job.current_positions)
	update_tier_limits()

/**
 * Add a client to the candidate queue, the first clients of the queue will have priority on new larva spots
 * return TRUE if the client was added, FALSE if it was removed
 */
/datum/hive_status/proc/add_to_larva_candidate_queue(client/waiter)
	var/datum/job/xeno_job = SSjob.GetJobType(/datum/job/xenomorph)
	var/stored_larva = xeno_job.total_positions - xeno_job.current_positions
	var/list/possible_mothers = list()
	var/list/possible_silos = list()
	SEND_SIGNAL(src, COMSIG_HIVE_XENO_MOTHER_PRE_CHECK, possible_mothers, possible_silos)
	if(stored_larva > 0 && !LAZYLEN(candidates) && !XENODEATHTIME_CHECK(waiter.mob) && (length(possible_mothers) || length(possible_silos) || (SSticker.mode?.round_type_flags & MODE_SILO_RESPAWN && SSmonitor.gamestate == SHUTTERS_CLOSED)))
		xeno_job.occupy_job_positions(1)
		if(!attempt_to_spawn_larva(waiter, TRUE))
			xeno_job.free_job_positions(1)
			return FALSE
		return TRUE
	if(LAZYFIND(candidates, waiter))
		remove_from_larva_candidate_queue(waiter)
		return FALSE
	LAZYADD(candidates, waiter)
	RegisterSignal(waiter, COMSIG_QDELETING, PROC_REF(cleanup_waiter))
	var/new_position = LAZYLEN(candidates)
	SEND_SIGNAL(waiter, COMSIG_CLIENT_SET_LARVA_QUEUE_POSITION, new_position)
	to_chat(waiter, span_warning("There are either no burrowed larva, you are on your xeno respawn timer, or there are no silos. You are in position [new_position] to become a Xenomorph."))
	give_larva_to_next_in_queue() //Updates the queue for xeno respawn timer
	return TRUE

/// Remove a client from the larva candidate queue
/datum/hive_status/proc/remove_from_larva_candidate_queue(client/waiter)
	var/larva_position = SEND_SIGNAL(waiter, COMSIG_CLIENT_GET_LARVA_QUEUE_POSITION)
	if (!larva_position)
		return // We weren't in the queue
	LAZYREMOVE(candidates, waiter)
	UnregisterSignal(waiter, COMSIG_QDELETING)
	SEND_SIGNAL(waiter, COMSIG_CLIENT_SET_LARVA_QUEUE_POSITION, 0)
	to_chat(waiter, span_warning("You left the Larva queue."))
	var/client/client_in_queue
	for(var/i in 1 to LAZYLEN(candidates))
		client_in_queue = LAZYACCESS(candidates, i)
		SEND_SIGNAL(client_in_queue, COMSIG_CLIENT_SET_LARVA_QUEUE_POSITION, i)

/// Propose larvas until their is no more candidates, or no more burrowed
/datum/hive_status/proc/give_larva_to_next_in_queue()
	var/list/possible_mothers = list()
	var/list/possible_silos = list()
	SEND_SIGNAL(src, COMSIG_HIVE_XENO_MOTHER_PRE_CHECK, possible_mothers, possible_silos)
	if(!length(possible_mothers) && !length(possible_silos) && (!(SSticker.mode?.round_type_flags & MODE_SILO_RESPAWN) || SSsilo.can_fire))
		return
	var/datum/job/xeno_job = SSjob.GetJobType(/datum/job/xenomorph)
	var/stored_larva = round(xeno_job.total_positions - xeno_job.current_positions)
	var/slot_occupied = min(stored_larva, LAZYLEN(candidates))
	if(slot_occupied < 1)
		return
	var/slot_really_taken = 0
	if(!xeno_job.occupy_job_positions(slot_occupied))
		return
	var/client/client_in_queue
	var/oldest_death = 0
	while(stored_larva > 0 && LAZYLEN(candidates))
		for(var/i in 1 to LAZYLEN(candidates))
			client_in_queue = LAZYACCESS(candidates, i)
			if(!XENODEATHTIME_CHECK(client_in_queue.mob))
				break
			var/candidate_death_time = (GLOB.key_to_time_of_xeno_death[client_in_queue.key] + SSticker.mode?.xenorespawn_time) - world.time
			if(oldest_death > candidate_death_time || !oldest_death)
				oldest_death = candidate_death_time
			client_in_queue = null // Deathtimer still running

		if(!client_in_queue) // No valid candidates in the queue
			if(oldest_death)
				// Will update the queue once timer is up, spawning them in if there is a burrowed
				addtimer(CALLBACK(src, PROC_REF(give_larva_to_next_in_queue)), oldest_death + 1 SECONDS)
			break

		LAZYREMOVE(candidates, client_in_queue)
		UnregisterSignal(client_in_queue, COMSIG_QDELETING)
		if(try_to_give_larva(client_in_queue))
			stored_larva--
			slot_really_taken++

	if(slot_occupied - slot_really_taken > 0)
		xeno_job.free_job_positions(slot_occupied - slot_really_taken)
	for(var/i in 1 to LAZYLEN(candidates))
		client_in_queue = LAZYACCESS(candidates, i)
		SEND_SIGNAL(client_in_queue, COMSIG_CLIENT_SET_LARVA_QUEUE_POSITION, i)

/// Remove ref to avoid hard del and null error
/datum/hive_status/proc/cleanup_waiter(datum/source)
	SIGNAL_HANDLER
	LAZYREMOVE(candidates, source)

///Attempt to give a larva to the next in line, if not possible, free the xeno position and propose it to another candidate
/datum/hive_status/proc/try_to_give_larva(client/next_in_line)
	SEND_SIGNAL(next_in_line, COMSIG_CLIENT_SET_LARVA_QUEUE_POSITION, 0)
	if(!attempt_to_spawn_larva(next_in_line, TRUE))
		to_chat(next_in_line, span_warning("You failed to qualify to become a larva, you must join the queue again."))
		return FALSE
	return TRUE

///updates and sets the t2 and t3 xeno limits
/datum/hive_status/proc/update_tier_limits()
	var/zeros = get_total_tier_zeros()
	var/ones = length(xenos_by_tier[XENO_TIER_ONE])
	var/twos = length(xenos_by_tier[XENO_TIER_TWO])
	var/threes = length(xenos_by_tier[XENO_TIER_THREE])
	var/fours = length(xenos_by_tier[XENO_TIER_FOUR])

	tier3_xeno_limit = max(threes, FLOOR((zeros + ones + twos + fours + threes*SSticker.mode.tier_three_inclusion) / 3 + length(psychictowers) + 1  - SSticker.mode.tier_three_penalty, 1))
	tier2_xeno_limit = max(twos, (zeros + ones + fours) + length(psychictowers) * 2 + 1 - threes)

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

/mob/living/carbon/xenomorph/gorger/Corrupted
	hivenumber = XENO_HIVE_CORRUPTED

/mob/living/carbon/xenomorph/defender/Corrupted
	hivenumber = XENO_HIVE_CORRUPTED

/mob/living/carbon/xenomorph/defiler/Corrupted
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

/mob/living/carbon/xenomorph/behemoth/Corrupted
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

/mob/living/carbon/xenomorph/gorger/Alpha
	hivenumber = XENO_HIVE_ALPHA

/mob/living/carbon/xenomorph/defender/Alpha
	hivenumber = XENO_HIVE_ALPHA

/mob/living/carbon/xenomorph/defiler/Alpha
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

/mob/living/carbon/xenomorph/behemoth/Alpha
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

/mob/living/carbon/xenomorph/gorger/Beta
	hivenumber = XENO_HIVE_BETA

/mob/living/carbon/xenomorph/defender/Beta
	hivenumber = XENO_HIVE_BETA

/mob/living/carbon/xenomorph/defiler/Beta
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

/mob/living/carbon/xenomorph/behemoth/Beta
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

/mob/living/carbon/xenomorph/gorger/Zeta
	hivenumber = XENO_HIVE_ZETA

/mob/living/carbon/xenomorph/defender/Zeta
	hivenumber = XENO_HIVE_ZETA

/mob/living/carbon/xenomorph/defiler/Zeta
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

/mob/living/carbon/xenomorph/behemoth/Zeta
	hivenumber = XENO_HIVE_ZETA

/datum/hive_status/admeme
	name = "Admeme"
	hivenumber = XENO_HIVE_ADMEME
	prefix = "Admeme "

/mob/living/carbon/xenomorph/queen/admeme
	hivenumber = XENO_HIVE_ADMEME

/mob/living/carbon/xenomorph/king/admeme
	hivenumber = XENO_HIVE_ADMEME

/datum/hive_status/corrupted/fallen
	name = "Fallen"
	hivenumber = XENO_HIVE_FALLEN
	prefix = "Fallen "
	color = "#8046ba"

/datum/hive_status/corrupted/fallen/can_xeno_message()
	return FALSE

/mob/living/carbon/xenomorph/queen/Corrupted/fallen
	hivenumber = XENO_HIVE_FALLEN

/mob/living/carbon/xenomorph/king/Corrupted/fallen
	hivenumber = XENO_HIVE_FALLEN

// ***************************************
// *********** Xeno hive compare helpers
// ***************************************

// Everything below can have a hivenumber set and these ensure easy hive comparisons can be made

// atom level because of /atom/movable/projectile/var/atom/firer
/atom/proc/issamexenohive(atom/A)
	if(!get_xeno_hivenumber() || !A?.get_xeno_hivenumber())
		return FALSE
	return get_xeno_hivenumber() == A.get_xeno_hivenumber()

/atom/proc/get_xeno_hivenumber()
	return FALSE

/obj/alien/egg/get_xeno_hivenumber()
	return hivenumber

/obj/item/alien_embryo/get_xeno_hivenumber()
	return hivenumber

/obj/item/clothing/mask/facehugger/get_xeno_hivenumber()
	return hivenumber

/mob/living/carbon/xenomorph/get_xeno_hivenumber()
	return hivenumber

/mob/illusion/xeno/get_xeno_hivenumber()
	var/mob/living/carbon/xenomorph/original_xeno = original_mob
	return original_xeno.hivenumber

/obj/structure/xeno/get_xeno_hivenumber()
	if(hivenumber)
		return hivenumber
	return ..()

/obj/structure/xeno/trap/get_xeno_hivenumber()
	if(hugger)
		return hugger.hivenumber
	return ..()

/mob/living/carbon/human/get_xeno_hivenumber()
	if(faction == FACTION_ZOMBIE)
		return FACTION_ZOMBIE
	return FALSE
