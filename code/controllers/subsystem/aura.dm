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

///Use this to start a new emitter with the specified stats. Returns the emitter in question, use stop_emitting() to end early.
/datum/controller/subsystem/aura/proc/add_emitter(atom/center, type, range, strength, duration)
	if(!istype(center))
		return
	if(!type || !range || !strength)
		return
	return new /datum/aura_bearer(center, type, range, strength, duration)

///The thing that actually pushes out auras to nearby mobs.
/datum/aura_bearer
	///What we emit from
	var/atom/center
	///String indicating aura variety
	var/aura_type
	///How far from our center we apply
	var/range
	///Multiplier to aura effectiveness
	var/strength
	///How many ticks we have left, 15 by default.
	var/duration
	///If our aura_type is in this, we'll pulse to humans
	var/list/human_auras = list(AURA_HUMAN_MOVE, AURA_HUMAN_HOLD, AURA_HUMAN_FOCUS)
	///Whether we care about humans
	var/affects_humans = FALSE
	///If our type is in this, we'll pulse to xenos
	var/list/xeno_auras = list(FRENZY, WARDING, RECOVERY)
	///Whether we care about xenos
	var/affects_xenos = FALSE

/datum/aura_bearer/New(atom/aura_center, aura_name, aura_range, aura_strength, aura_duration)
	..()
	center = aura_center
	range = aura_range
	strength = aura_strength
	duration = aura_duration || 15
	aura_type = aura_name
	if(human_auras.Find(aura_type))
		affects_humans = TRUE
	if(xeno_auras.Find(aura_type))
		affects_xenos = TRUE
	RegisterSignal(center, COMSIG_PARENT_QDELETING, .proc/stop_emitting)
	SSaura.active_auras += src

///Center gets destroyed, we run out of duration, or any other reason to finish. Perish immediately.
/datum/aura_bearer/proc/stop_emitting()
	SIGNAL_HANDLER
	SEND_SIGNAL(src, COMSIG_AURA_FINISHED) //For visuals, since mob huds need to track what and when they're personally emitting.
	qdel(src)

/datum/aura_bearer/Destroy()
	if(center)
		UnregisterSignal(center, COMSIG_PARENT_QDELETING)
		center = null
	SSaura.active_auras -= src
	return ..()

/datum/aura_bearer/process()
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
	var/turf/aura_center = get_turf(center)
	if(!istype(aura_center))
		return
	for(var/mob/living/carbon/human/potential_hearer AS in GLOB.humans_by_zlevel["[aura_center.z]"])
		if(get_dist(aura_center, potential_hearer) > range)
			continue
		potential_hearer.recieve_aura(aura_type, strength)

///Send out our aura to all xenos close enough and on the same z-level
/datum/aura_bearer/proc/pulse_xenos()
	var/turf/aura_center = get_turf(center)
	if(!istype(aura_center))
		return
	for(var/mob/living/carbon/xenomorph/potential_hearer AS in GLOB.hive_datums[XENO_HIVE_NORMAL].xenos_by_zlevel["[aura_center.z]"])
		if(get_dist(aura_center, potential_hearer) > range)
			continue
		potential_hearer.recieve_aura(aura_type, strength)
