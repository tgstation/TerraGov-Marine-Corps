#define DEFAULT_FOOTSTEP_SOUND_RANGE 11

///Footstep element. Plays footsteps at parents location when it is appropriate.
/datum/element/footstep
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY|ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	///A list containing living mobs and the number of steps they have taken since the last time their footsteps were played.
	var/list/steps_for_living = list()
	///volume determines the extra volume of the footstep. This is multiplied by the base volume, should there be one.
	var/volume
	///e_range stands for extra range - aka how far the sound can be heard. This is added to the base value and ignored if there isn't a base value.
	var/e_range
	///footstep_type is a define which determines what kind of sounds should get chosen.
	var/footstep_type
	///This can be a list OR a soundfile OR null. Determines whatever sound gets played.
	var/footstep_sounds
	///Whether or not to add variation to the sounds played
	var/sound_vary = FALSE

/datum/element/footstep/Attach(datum/target, footstep_type = FOOTSTEP_MOB_BAREFOOT, volume = 0.5, e_range = 0, sound_vary = FALSE)
	. = ..()
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE
	src.volume = volume
	src.e_range = e_range
	src.footstep_type = footstep_type
	src.sound_vary = sound_vary
	switch(footstep_type)
		if(FOOTSTEP_MOB_HUMAN)
			if(!ishuman(target))
				return ELEMENT_INCOMPATIBLE
			RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(humanstep_wrapper)) //we don't want the movement signal args
			RegisterSignals(target, list(COMSIG_ELEMENT_JUMP_ENDED, COMSIG_MOVABLE_PATROL_DEPLOYED), PROC_REF(play_humanstep))
			steps_for_living[target] = 0
			return
		if(FOOTSTEP_MOB_SHOE)
			footstep_sounds = GLOB.shoefootstep
		if(FOOTSTEP_MOB_BAREFOOT)
			footstep_sounds = GLOB.barefootstep
		if(FOOTSTEP_XENO_MEDIUM)
			footstep_sounds = GLOB.xenomediumstep
		if(FOOTSTEP_XENO_HEAVY)
			footstep_sounds = GLOB.xenoheavystep
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(simplestep_wrapper))
	RegisterSignals(target, list(COMSIG_ELEMENT_JUMP_ENDED, COMSIG_MOVABLE_PATROL_DEPLOYED), PROC_REF(play_simplestep))
	steps_for_living[target] = 0

/datum/element/footstep/Detach(atom/movable/source)
	UnregisterSignal(source, list(COMSIG_MOVABLE_MOVED, COMSIG_ELEMENT_JUMP_ENDED, COMSIG_MOVABLE_PATROL_DEPLOYED))
	steps_for_living -= source
	return ..()

///Prepares a footstep for living mobs. Determines if it should get played. Returns the turf it should get played on. Note that it is always a /turf/open
/datum/element/footstep/proc/prepare_step(mob/living/source)
	if(HAS_TRAIT(source, TRAIT_SILENT_FOOTSTEPS))
		return

	var/turf/open/turf = get_turf(source)
	if(!istype(turf))
		return

	if(source.buckled || source.throwing || source.is_ventcrawling || source.lying_angle || CHECK_MULTIPLE_BITFIELDS(source.pass_flags, HOVERING) || HAS_TRAIT(source, TRAIT_IMMOBILE))
		return

	if(ishuman(source))
		var/mob/living/carbon/human/human_source = source
		if(!human_source.get_limb(BODY_ZONE_L_LEG) && !human_source.get_limb(BODY_ZONE_R_LEG))
			return

	steps_for_living[source] += 1
	var/steps = steps_for_living[source]

	if(steps >= 6)
		steps_for_living[source] = 0
		steps = 0

	if(steps % 2)
		return

	return turf

///Wrapper for movement triggered footsteps for simplestep
/datum/element/footstep/proc/simplestep_wrapper(mob/living/source)
	SIGNAL_HANDLER

	play_simplestep(source)

///Wrapper for movement triggered footsteps for human step
/datum/element/footstep/proc/humanstep_wrapper(mob/living/source, old_loc, movement_dir, forced, old_locs)
	SIGNAL_HANDLER
	if(!forced)
		play_humanstep(source)

///Plays footsteps for anything that isn't human
/datum/element/footstep/proc/play_simplestep(mob/living/source, force_play = FALSE, volume_multiplier = 1, range_adjustment = 0)
	SIGNAL_HANDLER

	var/turf/open/source_loc
	if(force_play)
		source_loc = get_turf(source)
		if(!istype(source_loc))
			return
	else
		source_loc = prepare_step(source)

	if(!source_loc)
		return

	if(HAS_TRAIT(source, TRAIT_HEAVY_STEP))
		volume_multiplier += 0.3
		range_adjustment += 3

	if(HAS_TRAIT(source, TRAIT_LIGHT_STEP))
		volume_multiplier -= 0.5
		range_adjustment += -3

	if(source.m_intent == MOVE_INTENT_WALK)
		volume_multiplier -= 0.5
		range_adjustment += -3


	if(isfile(footstep_sounds) || istext(footstep_sounds))
		playsound(source_loc, footstep_sounds, volume * volume_multiplier, sound_vary, DEFAULT_FOOTSTEP_SOUND_RANGE + e_range + range_adjustment)
		return

	var/turf_footstep

	var/override_sound = source_loc.get_footstep_override()
	if(override_sound)
		turf_footstep = override_sound
	else switch(footstep_type)
		if(FOOTSTEP_XENO_MEDIUM)
			turf_footstep = source_loc.mediumxenofootstep
		if(FOOTSTEP_XENO_HEAVY)
			turf_footstep = source_loc.heavyxenofootstep
		if(FOOTSTEP_MOB_BAREFOOT)
			turf_footstep = source_loc.barefootstep
		if(FOOTSTEP_MOB_SHOE)
			turf_footstep = source_loc.shoefootstep
	if(!turf_footstep)
		return
	playsound(
		source_loc,
		pick(footstep_sounds[turf_footstep][1]),
		footstep_sounds[turf_footstep][2] * volume * volume_multiplier,
		sound_vary,
		DEFAULT_FOOTSTEP_SOUND_RANGE + footstep_sounds[turf_footstep][3] + e_range + range_adjustment,
	)

///Plays footsteps for humans
/datum/element/footstep/proc/play_humanstep(mob/living/carbon/human/source, force_play = FALSE, volume_multiplier = 1, range_adjustment = 0)
	SIGNAL_HANDLER

	var/turf/open/source_loc
	if(force_play)
		source_loc = get_turf(source)
		if(!istype(source_loc))
			return
	else
		source_loc = prepare_step(source)

	if(!source_loc)
		return

	if(HAS_TRAIT(source, TRAIT_HEAVY_STEP))
		volume_multiplier += 0.3
		range_adjustment += 3

	if(HAS_TRAIT(source, TRAIT_LIGHT_STEP))
		volume_multiplier -= 0.5
		range_adjustment += -3

	if(source.m_intent == MOVE_INTENT_WALK)
		volume_multiplier -= 0.5
		range_adjustment += -3

	var/override_sound = source_loc.get_footstep_override()
	var/footstep_type

	if((source.wear_suit?.armor_protection_flags | source.w_uniform?.armor_protection_flags | source.shoes?.armor_protection_flags) & FEET) //We are not disgusting barefoot bandits
		var/static/list/footstep_sounds = GLOB.shoefootstep //static is faster
		footstep_type = override_sound ? override_sound : source_loc.shoefootstep
		playsound(
			source_loc,
			pick(footstep_sounds[footstep_type][1]),
			footstep_sounds[footstep_type][2] * volume * volume_multiplier,
			sound_vary,
			DEFAULT_FOOTSTEP_SOUND_RANGE + footstep_sounds[footstep_type][3] + e_range + range_adjustment,
		)
	else
		var/static/list/bare_footstep_sounds = GLOB.barefootstep
		footstep_type = override_sound ? override_sound : source_loc.barefootstep
		playsound(
			source_loc,
			pick(GLOB.barefootstep[footstep_type][1]),
			GLOB.barefootstep[footstep_type][2] * volume * volume_multiplier,
			sound_vary,
			DEFAULT_FOOTSTEP_SOUND_RANGE + GLOB.barefootstep[footstep_type][3] + e_range + range_adjustment,
		)
