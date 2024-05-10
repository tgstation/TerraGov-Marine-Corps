#define TRACKING_ID_MARINE_COMMANDER "marine-commander"
#define TRACKING_ID_SOM_COMMANDER "som-commander"

SUBSYSTEM_DEF(direction)
	name = "Direction"
	priority = FIRE_PRIORITY_DIRECTION
	runlevels = RUNLEVEL_GAME|RUNLEVEL_POSTGAME
	wait = 1 SECONDS

	/// this is a map of defines to mob references, eg; list(FACTION_ID = <mob ref>, FACTION_ID2 = <mob ref>)
	var/list/leader_mapping = list()

	/// this is a two d list of defines to lists of mobs tracking that leader
	/// eg; list(CHARLIE_SL = list(<list of references to squad marines), XENO_NORMAL_QUEEN = list(<list of xeno mob refs))
	var/list/list/processing_mobs = list()

	///Lookup for list(<mob ref> = squad_id)
	var/list/mobs_in_processing = list()





	// the purpose of separating these two things is it avoids having to do anything for mobs tracking a particular
	//  leader when the leader changes, and its cached to avoid looking up via hive/squad datums.
	// it's up to the user of this subsystem to remove themselves via the macros

	var/list/list/currentrun

	///Used as a incrememnted var to create new faction IDs
	var/last_faction_id = 0

/datum/controller/subsystem/direction/Recover()
	leader_mapping = SSdirection.leader_mapping
	processing_mobs = SSdirection.processing_mobs
	mobs_in_processing = SSdirection.mobs_in_processing
	last_faction_id = SSdirection.last_faction_id

/datum/controller/subsystem/direction/Initialize()
	// Static squads/factions can be defined here for tracking
	init_squad(TRACKING_ID_MARINE_COMMANDER)
	init_squad(TRACKING_ID_SOM_COMMANDER)
	for (var/hivenumber in GLOB.hive_datums)
		var/datum/hive_status/HS = GLOB.hive_datums[hivenumber]
		init_squad(hivenumber, HS.living_xeno_ruler)
	return SS_INIT_SUCCESS


/datum/controller/subsystem/direction/stat_entry()
	var/mobcount = 0
	for(var/L in processing_mobs)
		mobcount += length(processing_mobs[L])
	return ..("P:[mobcount]")


/datum/controller/subsystem/direction/fire(resumed = FALSE)
	if(!resumed)
		currentrun = deepCopyList(processing_mobs)

	for(var/squad_id in currentrun)
		var/mob/living/tracked_leader = leader_mapping[squad_id]
		if (QDELETED(tracked_leader) && !isxenohive(squad_id))
			untrack_all_in_squad(squad_id) // clear and reset all the squad members
			continue
		var/mob/living/tracker
		while(length(currentrun[squad_id]))
			tracker = currentrun[squad_id][length(currentrun[squad_id])]
			currentrun[squad_id].len--
			if(QDELETED(tracker))
				stop_tracking(squad_id, tracker)
				continue
			tracker.update_tracking(tracked_leader)
			if(MC_TICK_CHECK)
				return

///Stops all members of this squad from tracking the leader
/datum/controller/subsystem/direction/proc/untrack_all_in_squad(squad_id)
	var/mob/living/tracker
	while(length(currentrun[squad_id]))
		tracker = currentrun[squad_id][length(currentrun[squad_id])]
		currentrun[squad_id].len--
		if(QDELETED(tracker))
			stop_tracking(squad_id, tracker)
			continue
		tracker.clear_leader_tracking()
		if(MC_TICK_CHECK)
			return FALSE
	return TRUE

/**
 * Adds a new mob to a squad so it can track
 * Arguments:
 * * squad_id: string squad ID we want to be tracking
 * * new_tracker: New mob we are adding that wants to track the leader of this squad
 */
/datum/controller/subsystem/direction/proc/start_tracking(squad_id, mob/living/carbon/new_tracker)
	if(!new_tracker)
		CRASH("SSdirection.start_tracking called with a null mob")
	if(mobs_in_processing[new_tracker] == squad_id)
		return TRUE // already tracking this squad leader
	if(mobs_in_processing[new_tracker])
		stop_tracking(mobs_in_processing[new_tracker], new_tracker) // remove from tracking the other squad
	mobs_in_processing[new_tracker] = squad_id
	processing_mobs[squad_id] += new_tracker

/**
 * Removes a new mob drom a squad so it can stop tracking
 * Arguments:
 * * squad_id: string squad ID we want to be tracking
 * * tracker: Mob we are removing from tracking
 */
/datum/controller/subsystem/direction/proc/stop_tracking(squad_id, mob/living/carbon/tracker, force = FALSE)
	if(!mobs_in_processing[tracker])
		return TRUE // already removed
	var/tracking_id = mobs_in_processing[tracker]
	mobs_in_processing -= tracker

	if(tracking_id != squad_id)
		if(!force)
			stack_trace("mismatch in tracking mobs by reference")
		processing_mobs[squad_id] -= tracker

	processing_mobs[tracking_id] -= tracker

///Sets a new leader for a squad
/datum/controller/subsystem/direction/proc/set_leader(squad_id, mob/living/carbon/new_leader)
	if(leader_mapping[squad_id])
		clear_leader(squad_id)
	leader_mapping[squad_id] = new_leader

///Clears the leader for this squad id
/datum/controller/subsystem/direction/proc/clear_leader(squad_id)
	leader_mapping[squad_id] = null

/**
 * Creates a new squad so tat we can start tracking it's leader
 * Arguments:
 * * new_squad_id: string ID for the new squad we are creating, if none is given creates a new id with last faction id
 * * squad_leader_mob: optional; mob that we want to be SL of this squad
 */
/datum/controller/subsystem/direction/proc/init_squad(new_squad_id, mob/squad_leader_mob)
	if(!new_squad_id)
		new_squad_id = "faction_[last_faction_id++]"
	processing_mobs[new_squad_id] = list()
	leader_mapping[new_squad_id] = squad_leader_mob // Unassigned squad leader by default

	return new_squad_id

