#define START_TRACK_LEADER(squad, mob) \
	SSdirection.processing[squad].Add(mob);

#define STOP_TRACK_LEADER(squad, mob) \
	SSdirection.processing[squad].Remove(mob);

#define SET_TRACK_LEADER(squad, mob) \
	SSdirection.leader_mapping[squad] = mob;

#define CLEAR_TRACK_LEADER(squad) \
	SSdirection.leader_mapping[squad] = null;

#define SETUP_LEADER_MAP(squad) \
	SSdirection.leader_mapping.Add(squad);

SUBSYSTEM_DEF(direction)
	name = "Direction"
	priority = FIRE_PRIORITY_DIRECTION
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	// this is a map of defines to mob references, eg; list(CHARLIE_SL = <mob ref>, XENO_NORMAL_QUEEN = <mob ref>)
	var/list/leader_mapping = list()

	// this is a two d list of defines to lists of mobs tracking that leader
	// eg; list(CHARLIE_SL = list(<list of references to squad marines), XENO_NORMAL_QUEEN = list(<list of xeno mob refs))
	var/list/processing = list()

	// the purpose of separating these two things is it avoids having to do anything for mobs tracking a particular
	//  leader when the leader changes, and its cached to avoid looking up via hive/squad datums.
	// it's up to the user of this subsystem to remove themselves via the macros
	// Though currently this doesn't support use for xenos.

	var/list/currentrun

/datum/controller/subsystem/direction/Initialize(start_timeofday)
	leader_mapping = list(TRACK_ALPHA_SQUAD,TRACK_BRAVO_SQUAD,TRACK_CHARLIE_SQUAD,TRACK_DELTA_SQUAD)
	for(var/a in leader_mapping)
		processing.Add(a)
		processing[a] = list()
	return ..()

/datum/controller/subsystem/direction/stat_entry()
	var/mobs = 0
	for(var/L in processing)
		mobs += length(processing[L])
	..("P:[mobs]")

/datum/controller/subsystem/direction/fire(resumed = FALSE)
	if(!resumed)
		currentrun = processing.Copy()

	for(var/L in currentrun)
		if(!currentrun[L])
			continue
		var/mob/living/carbon/human/H
		if(iscarbon(leader_mapping[L]))
			var/mob/living/carbon/C = leader_mapping[L]
			while(currentrun[L].len)
				H = currentrun[L][currentrun[L].len]
				currentrun[L].len--
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
