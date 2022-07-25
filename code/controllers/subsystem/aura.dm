/// Tracks aura emitters and tells them to pulse. Also used for creating new ones.
SUBSYSTEM_DEF(aura)
	name = "Auras"
	wait = 2 SECONDS
	flags = SS_NO_INIT
	///Stores currently active aura_bearer datums
	var/list/active_auras = list() //We can't use a normal subsystem processing list because as soon as an aura_bearer leaves the list it needs to die

/datum/controller/subsystem/aura/fire(resumed)
	for(var/datum/aura_bearer/bearer AS in active_auras)
		bearer.process()

///Use this to start a new emitter with the specified stats. Returns the emitter in question, just qdel it to end early.
/datum/controller/subsystem/aura/proc/add_emitter(atom/center, type, range, strength, duration, faction)
	if(!istype(center))
		return
	if(!type || !range || !strength || !duration || !faction)
		return
	. =  new /datum/aura_bearer(center, type, range, strength, duration, faction)
	active_auras += .

///The thing that actually pushes out auras to nearby mobs.
/datum/aura_bearer
	///What we emit from
	var/atom/emitter
	///List containing aura varieties as strings - see AURA entries in _DEFINES/mobs.dm
	var/list/aura_types
	///How far from our center we apply
	var/range
	///Multiplier to aura effectiveness
	var/strength
	///How many subsystem fires we have left, negative means infinite duration
	var/duration
	///Aura is only applied to mobs in this faction
	var/faction
	///List of aura defines that mean we care about humans
	var/static/list/human_auras = list(AURA_HUMAN_MOVE, AURA_HUMAN_HOLD, AURA_HUMAN_FOCUS)
	///Whether we care about humans - at least one relevant aura is enough if we have multiple.
	var/affects_humans = FALSE
	///List of aura defines that mean we care about xenos
	var/static/list/xeno_auras = list(AURA_XENO_FRENZY, AURA_XENO_WARDING, AURA_XENO_RECOVERY)
	///Whether we care about xenos - at least one relevant aura is enough if we have multiple.
	var/affects_xenos = FALSE
	///Whether we should skip the next tick. Set to false after skipping once. Won't pulse to targets or reduce duration.
	var/suppressed = FALSE

/datum/aura_bearer/New(atom/aura_emitter, aura_names, aura_range, aura_strength, aura_duration, aura_faction)
	..()
	emitter = aura_emitter
	range = aura_range
	strength = aura_strength
	duration = aura_duration
	faction = aura_faction
	if(!islist(aura_names))
		aura_types = list(aura_names)
	else
		aura_types = aura_names
	for(var/aura_type in aura_types)
		if(human_auras.Find(aura_type))
			affects_humans = TRUE
		if(xeno_auras.Find(aura_type))
			affects_xenos = TRUE
		if(affects_xenos && affects_humans) //aura_types should never be a long enough list that this is actually worth checking, but.
			break
	RegisterSignal(emitter, COMSIG_PARENT_QDELETING, .proc/stop_emitting)

///Center gets destroyed, we run out of duration, or any other reason to finish. Perish immediately.
/datum/aura_bearer/proc/stop_emitting()
	SIGNAL_HANDLER
	qdel(src)

/datum/aura_bearer/Destroy()
	SEND_SIGNAL(src, COMSIG_AURA_FINISHED) //For visuals, since mob huds need to track what and when they're personally emitting.
	emitter = null
	SSaura.active_auras -= src
	return ..()

/datum/aura_bearer/process()
	if(suppressed)
		suppressed = FALSE
		return
	if(affects_humans)
		pulse_humans()
	if(affects_xenos)
		pulse_xenos()
	if(duration < 0) //Negative duration means infinite. Usually for pheromones.
		return
	duration--
	if(!duration)
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
			potential_hearer.receive_aura(aura, strength)

///Send out our aura to all xenos close enough and on the same z-level
/datum/aura_bearer/proc/pulse_xenos()
	var/turf/aura_center = get_turf(emitter)
	if(!istype(aura_center))
		return
	for(var/mob/living/carbon/xenomorph/potential_hearer AS in GLOB.hive_datums[XENO_HIVE_NORMAL].xenos_by_zlevel["[aura_center.z]"])
		if(get_dist(aura_center, potential_hearer) > range)
			continue
		if(potential_hearer.faction != faction)
			continue
		for(var/aura in aura_types)
			potential_hearer.receive_aura(aura, strength)
