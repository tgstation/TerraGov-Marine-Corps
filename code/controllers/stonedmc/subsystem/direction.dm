SUBSYSTEM_DEF(direction)
	name = "Direction"
	priority = FIRE_PRIORITY_DIRECTION
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	wait = 1 SECONDS

	// this is a map of defines to mob references, eg; list(FACTION_ID = <mob ref>, FACTION_ID2 = <mob ref>)
	var/list/leader_mapping = list()

	// this is a two d list of defines to lists of mobs tracking that leader
	// eg; list(CHARLIE_SL = list(<list of references to squad marines), XENO_NORMAL_QUEEN = list(<list of xeno mob refs))
	var/list/list/processing_mobs = list()

	var/list/mobs_in_processing = list() // reference lookup

	// the purpose of separating these two things is it avoids having to do anything for mobs tracking a particular
	//  leader when the leader changes, and its cached to avoid looking up via hive/squad datums.
	// it's up to the user of this subsystem to remove themselves via the macros

	var/list/list/currentrun

	var/last_faction_id = 0 // use to create unique faction ids


/datum/controller/subsystem/direction/Initialize(start_timeofday)
	. = ..()
	// Static squads/factions can be defined here for tracking
	init_squad(null, null, "marine-sl")
	for (var/hivenumber in GLOB.hive_datums)
		var/datum/hive_status/HS = GLOB.hive_datums[hivenumber]
		init_squad(null, HS.living_xeno_ruler, hivenumber)

/datum/controller/subsystem/direction/stat_entry()
	var/mobcount = 0
	for(var/L in processing_mobs)
		mobcount += length(processing_mobs[L])
	return ..("P:[mobcount]")

/datum/controller/subsystem/direction/fire(resumed = FALSE)
	if(!resumed)
		currentrun = deepCopyList(processing_mobs)

	for(var/squad_id in currentrun)
		var/mob/living/L
		var/mob/living/SL = leader_mapping[squad_id]
		if (QDELETED(SL))
			clear_run(squad_id) // clear and reset all the squad members
			continue
		while(currentrun[squad_id].len)
			L = currentrun[squad_id][currentrun[squad_id].len]
			currentrun[squad_id].len--
			if(QDELETED(L))
				stop_tracking(squad_id, L)
				continue
			L.update_leader_tracking(SL)
			if(MC_TICK_CHECK)
				return

/datum/controller/subsystem/direction/proc/clear_run(squad_id)
	var/mob/living/L
	while(currentrun[squad_id].len)
		L = currentrun[squad_id][currentrun[squad_id].len]
		currentrun[squad_id].len--
		if(QDELETED(L))
			stop_tracking(squad_id, L)
			continue
		L.clear_leader_tracking()
		if(MC_TICK_CHECK)
			return FALSE
	return TRUE

/datum/controller/subsystem/direction/proc/start_tracking(squad_id, mob/living/carbon/C)
	if(!C)
		stack_trace("SSdirection.start_tracking called with a null mob")
		return FALSE
	if(mobs_in_processing[C] == squad_id)
		return TRUE // already tracking this squad leader
	if(mobs_in_processing[C])
		stop_tracking(mobs_in_processing[C], C) // remove from tracking the other squad
	mobs_in_processing[C] = squad_id
	processing_mobs[squad_id].Add(C)

/datum/controller/subsystem/direction/proc/stop_tracking(squad_id, mob/living/carbon/C)
	if(!mobs_in_processing[C])
		return TRUE // already removed
	var/tracking_id = mobs_in_processing[C]
	mobs_in_processing[C] = FALSE

	if(tracking_id != squad_id)
		stack_trace("mismatch in tracking mobs by reference")
		processing_mobs[squad_id].Remove(C)

	processing_mobs[tracking_id].Remove(C)

/datum/controller/subsystem/direction/proc/set_leader(squad_id, mob/living/carbon/C)
	if(leader_mapping[squad_id])
		clear_leader(squad_id)
	leader_mapping[squad_id] = C

/datum/controller/subsystem/direction/proc/clear_leader(squad_id)
	leader_mapping[squad_id] = null

/datum/controller/subsystem/direction/proc/init_squad(datum/squad/S, mob/L, tracking_id)
	if(!tracking_id)
		tracking_id = "faction_[last_faction_id++]"
	processing_mobs[tracking_id] = list()
	leader_mapping[tracking_id] = L // Unassigned squad leader by default

	return tracking_id

