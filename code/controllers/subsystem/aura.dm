/// Tracks aura emitters and tells them to pulse. Also used for creating new ones.
SUBSYSTEM_DEF(aura)
	name = "Auras"
	wait = 2 SECONDS
	flags = SS_NO_INIT
	///Stores currently active aura_bearer datums
	var/list/active_auras = list() //We can't use a normal subsystem processing list because as soon as an aura_bearer leaves the list it needs to die
	///Stores what the current aura processing stage was working on for if it is paused.
	var/list/current_cache = list()
	///Auras go through three stages. Pulse auras -> finish xeno cycles -> finish human cycles. Depending on where it was paused, this tells it where to resume fire()
	var/stage = 1

/datum/controller/subsystem/aura/fire(resumed)
	var/current_resume = FALSE
	if(resumed)
		current_resume = TRUE
	if(stage == 1)
		if(!current_resume)
			current_cache = active_auras.Copy()
		current_resume = FALSE
		while(length(current_cache))
			var/datum/aura_bearer/bearer = current_cache[length(current_cache)]
			current_cache.len--
			if(QDELETED(bearer))
				continue
			bearer.process()
			if(MC_TICK_CHECK)
				return
		stage = 2
	if(stage == 2)
		if(!current_resume)
			current_cache = GLOB.xeno_mob_list.Copy()
		current_resume = FALSE
		while(length(current_cache))
			var/mob/living/carbon/xenomorph/xeno = current_cache[length(current_cache)]
			current_cache.len--
			if(QDELETED(xeno))
				continue
			xeno.finish_aura_cycle()
			if(MC_TICK_CHECK)
				return
		stage = 3
	if(stage == 3)
		if(!current_resume)
			current_cache = GLOB.human_mob_list.Copy()
		current_resume = FALSE
		while(length(current_cache))
			var/mob/living/carbon/human/human = current_cache[length(current_cache)]
			current_cache.len--
			if(QDELETED(human))
				continue
			human.finish_aura_cycle()
			if(MC_TICK_CHECK)
				return
		stage = 1

///Use this to start a new emitter with the specified stats. Returns the emitter in question, just qdel it to end early.
/datum/controller/subsystem/aura/proc/add_emitter(atom/center, type, range, strength, duration, faction, hivenumber)
	if(!istype(center))
		return
	if(!type || !range || !strength || !duration || !faction)
		return
	. = new /datum/aura_bearer(center, type, range, strength, duration, faction, hivenumber)
	active_auras += .

///The thing that actually pushes out auras to nearby mobs.
/datum/aura_bearer
	///What we emit from
	var/atom/emitter
	///List containing aura varieties as strings - see AURA entries in _DEFINES/mobs.dm
	var/list/aura_types
	///When did this last tick?
	var/last_tick = 0
	///How far from our center we apply
	var/range = 0
	///Multiplier to aura effectiveness
	var/strength = 0
	///How many subsystem fires we have left, negative means infinite duration
	var/duration = 1
	///Aura is only applied to mobs in this faction
	var/faction = FACTION_NEUTRAL
	///List of aura defines that mean we care about humans
	var/static/list/human_auras = list(AURA_HUMAN_MOVE, AURA_HUMAN_HOLD, AURA_HUMAN_FOCUS)
	///Whether we care about humans - at least one relevant aura is enough if we have multiple.
	var/affects_humans = FALSE
	///List of aura defines that mean we care about xenos
	var/static/list/xeno_auras = list(AURA_XENO_FRENZY, AURA_XENO_WARDING, AURA_XENO_RECOVERY)
	///Whether we care about xenos - at least one relevant aura is enough if we have multiple.
	var/affects_xenos = FALSE
	///Which hives this aura should affect?
	var/hive_number = XENO_HIVE_NORMAL
	///Whether we should skip the next tick. Set to false after skipping once. Won't pulse to targets or reduce duration.
	var/suppressed = FALSE

/datum/aura_bearer/New(atom/aura_emitter, aura_names, aura_range, aura_strength, aura_duration, aura_faction, aura_hivenumber)
	..()
	emitter = aura_emitter
	range = aura_range
	strength = aura_strength
	duration = aura_duration
	faction = aura_faction
	hive_number = aura_hivenumber
	last_tick = world.time
	if(!islist(aura_names))
		aura_types = list(aura_names)
	else
		aura_types = aura_names

	for(var/aura_type in aura_types)
		if(human_auras.Find(aura_type))
			affects_humans = TRUE
		if(xeno_auras.Find(aura_type))
			affects_xenos = TRUE

	SEND_SIGNAL(emitter, COMSIG_AURA_STARTED, aura_types)
	RegisterSignal(emitter, COMSIG_QDELETING, PROC_REF(stop_emitting))

///Center gets destroyed, we run out of duration, or any other reason to finish. Perish immediately.
/datum/aura_bearer/proc/stop_emitting()
	SIGNAL_HANDLER
	qdel(src)

/datum/aura_bearer/Destroy()
	SEND_SIGNAL(emitter, COMSIG_AURA_FINISHED, aura_types) //For visuals, since mob huds need to track what and when they're personally emitting.
	emitter = null
	SSaura.active_auras -= src
	return ..()

/datum/aura_bearer/process()
	if(suppressed)
		suppressed = FALSE
		last_tick = world.time
		return
	if(affects_humans)
		pulse_humans()
	if(affects_xenos)
		pulse_xenos()
	if(duration < 0) //Negative duration means infinite. Usually for pheromones.
		return
	duration -= (world.time - last_tick)
	last_tick = world.time
	if(duration <= 0)
		stop_emitting()

///Send out our aura to all humans close enough and on the same z-level
/datum/aura_bearer/proc/pulse_humans()
	var/turf/aura_center = get_turf(emitter)
	if(!istype(aura_center))
		return
	for(var/mob/living/carbon/human/potential_hearer AS in GLOB.humans_by_zlevel["[aura_center.z]"])
		if(get_dist(aura_center, potential_hearer) > range)
			continue
		if(potential_hearer.faction != faction)
			continue
		for(var/aura in aura_types)
			if(!potential_hearer.can_receive_aura(aura, emitter, src))
				continue
			potential_hearer.receive_aura(aura, strength)

///Send out our aura to all xenos close enough and on the same z-level
/datum/aura_bearer/proc/pulse_xenos()
	var/turf/aura_center = get_turf(emitter)
	if(!istype(aura_center))
		return
	for(var/mob/living/carbon/xenomorph/potential_hearer AS in GLOB.hive_datums[hive_number].xenos_by_zlevel["[aura_center.z]"])
		if(get_dist(aura_center, potential_hearer) > range)
			continue
		for(var/aura in aura_types)
			if(!potential_hearer.can_receive_aura(aura, emitter, src))
				continue
			potential_hearer.receive_aura(aura, strength)
