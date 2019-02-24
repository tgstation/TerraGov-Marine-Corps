#define SLDIR_DEBUG

SUBSYSTEM_DEF(direction)
	name = "Direction"
	priority = FIRE_PRIORITY_DIRECTION
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	wait = 1 SECONDS

	// this is a map of defines to mob references, eg; list(CHARLIE_SL = <mob ref>, XENO_NORMAL_QUEEN = <mob ref>)
	var/list/leader_mapping = list()

	// this is a two d list of defines to lists of mobs tracking that leader
	// eg; list(CHARLIE_SL = list(<list of references to squad marines), XENO_NORMAL_QUEEN = list(<list of xeno mob refs))
	var/list/processing_mobs = list()

	#ifdef SLDIR_DEBUG
	var/list/mobs_in_processing = list()
	#endif

	// the purpose of separating these two things is it avoids having to do anything for mobs tracking a particular
	//  leader when the leader changes, and its cached to avoid looking up via hive/squad datums.
	// it's up to the user of this subsystem to remove themselves via the macros
	// Though currently this doesn't support use for xenos.

	var/list/currentrun

/datum/controller/subsystem/direction/Initialize(start_timeofday)
	leader_mapping = list(TRACK_ALPHA_SQUAD,TRACK_BRAVO_SQUAD,TRACK_CHARLIE_SQUAD,TRACK_DELTA_SQUAD)
	for(var/a in leader_mapping)
		processing_mobs.Add(a)
		processing_mobs[a] = list()
	return ..()

/datum/controller/subsystem/direction/stat_entry()
	var/mobcount = 0
	for(var/L in processing_mobs)
		mobcount += length(processing_mobs[L])
	return ..("P:[mobcount]")

/datum/controller/subsystem/direction/fire(resumed = FALSE)
	if(!resumed)
		currentrun = deepCopyList(processing_mobs)

	for(var/L in currentrun)
		var/mob/living/carbon/human/H
		if(iscarbon(leader_mapping[L]))
			var/mob/living/carbon/C = leader_mapping[L]
			while(currentrun[L].len)
				H = currentrun[L][currentrun[L].len]
				currentrun[L].len--
				if(!H)
					stack_trace("null in squad tracking")
					continue
				H.update_leader_tracking(C)
				if(MC_TICK_CHECK)
					return
		else
			while(currentrun[L].len)
				H = currentrun[L][currentrun[L].len]
				currentrun[L].len--
				H.clear_leader_tracking()
				if(MC_TICK_CHECK)
					return	

/datum/controller/subsystem/direction/proc/start_tracking(squad_id, mob/living/carbon/human/H)
	if(!H)
		stack_trace("SSdirection.start_tracking called with a null mob")
		return
	#ifdef SLDIR_DEBUG
	if(mobs_in_processing[H])
		stack_trace("trying to add a mob already being tracked")
		return
	mobs_in_processing[H] = TRUE
	#endif
	processing_mobs[squad_id].Add(H)

/datum/controller/subsystem/direction/proc/stop_tracking(squad_id, mob/living/carbon/human/H, deep=FALSE)
	#ifdef SLDIR_DEBUG
	mobs_in_processing[H] = FALSE
	#endif
	if(!deep)
		processing_mobs[squad_id].Remove(H)
		return
	for(var/A in processing_mobs)
		if(islist(processing_mobs[A]))
			processing_mobs[A].Remove(H)

/datum/controller/subsystem/direction/proc/set_leader(squad_id, mob/living/carbon/human/H)
	if(leader_mapping[squad_id])
		clear_leader(squad_id)
	leader_mapping[squad_id] = H

/datum/controller/subsystem/direction/proc/clear_leader(squad_id)
	leader_mapping[squad_id] = null
