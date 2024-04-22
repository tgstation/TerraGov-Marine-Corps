///Footstep component. Plays footsteps at parents location when it is appropriate.
/datum/component/footstep
	///How many steps the parent has taken since the last time a footstep was played.
	var/steps = 0
	///volume determines the extra volume of the footstep. This is multiplied by the base volume, should there be one.
	var/volume
	///e_range stands for extra range - aka how far the sound can be heard. This is added to the base value and ignored if there isn't a base value.
	var/e_range
	///footstep_type is a define which determines what kind of sounds should get chosen.
	var/footstep_type
	///This can be a list OR a soundfile OR null. Determines whatever sound gets played.
	var/footstep_sounds
	var/last_sound

/datum/component/footstep/Initialize(footstep_type_ = FOOTSTEP_MOB_BAREFOOT, volume_ = 0.5, e_range_ = -1)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	volume = volume_
	e_range = e_range_
	footstep_type = footstep_type_
	switch(footstep_type)
		if(FOOTSTEP_MOB_HUMAN)
			if(!ishuman(parent))
				return COMPONENT_INCOMPATIBLE
			RegisterSignal(parent, list(COMSIG_MOVABLE_MOVED), PROC_REF(play_humanstep))
			return
		if(FOOTSTEP_MOB_CLAW)
			footstep_sounds = GLOB.clawfootstep
		if(FOOTSTEP_MOB_BAREFOOT)
			footstep_sounds = GLOB.barefootstep
		if(FOOTSTEP_MOB_HEAVY)
			footstep_sounds = GLOB.heavyfootstep
		if(FOOTSTEP_MOB_SHOE)
			footstep_sounds = GLOB.footstep
		if(FOOTSTEP_MOB_SLIME)
			footstep_sounds = 'sound/blank.ogg'
	RegisterSignal(parent, list(COMSIG_MOVABLE_MOVED), PROC_REF(play_simplestep)) //Note that this doesn't get called for humans.

///Prepares a footstep. Determines if it should get played. Returns the turf it should get played on. Note that it is always a /turf/open
/datum/component/footstep/proc/prepare_step()
	var/turf/open/T = get_turf(parent)
	if(!istype(T))
		return

	var/mob/living/LM = parent
	if(!T.footstep || LM.buckled || LM.lying || !CHECK_MULTIPLE_BITFIELDS(LM.mobility_flags, MOBILITY_STAND | MOBILITY_MOVE) || LM.throwing || LM.movement_type & (VENTCRAWLING | FLYING))
		if (LM.lying && !LM.buckled && !(!T.footstep || LM.movement_type & (VENTCRAWLING | FLYING))) //play crawling sound if we're lying
			playsound(T, 'sound/blank.ogg', 15 * volume)
		return

	if(iscarbon(LM))
		var/mob/living/carbon/C = LM
		if(!C.get_bodypart(BODY_ZONE_L_LEG) && !C.get_bodypart(BODY_ZONE_R_LEG))
			return
		if(C.m_intent == MOVE_INTENT_SNEAK && !T.footstepstealth)
			return// stealth
	steps++

	if(steps >= 6)
		steps = 0

	if(steps % 2)
		return

	if(steps != 0 && !LM.has_gravity(T)) // don't need to step as often when you hop around
		return
	return T

/datum/component/footstep/proc/play_simplestep()
	var/turf/open/T = prepare_step()
	if(!T)
		return
	if(isfile(footstep_sounds) || istext(footstep_sounds))
		playsound(T, footstep_sounds, volume)
		return
	var/turf_footstep
	switch(footstep_type)
		if(FOOTSTEP_MOB_CLAW)
			turf_footstep = T.clawfootstep
		if(FOOTSTEP_MOB_BAREFOOT)
			turf_footstep = T.barefootstep
		if(FOOTSTEP_MOB_HEAVY)
			turf_footstep = T.heavyfootstep
		if(FOOTSTEP_MOB_SHOE)
			turf_footstep = T.footstep
	if(!turf_footstep)
		return
	//SANITY CHECK, WILL NOT PLAY A SOUND IF THE LIST IS INVALID
	if(!footstep_sounds[turf_footstep] || (LAZYLEN(footstep_sounds) < 3))
		testing("SOME RETARD GAVE AN INVALID FOOTSTEP [footstep_type] VALUE ([turf_footstep]) TO [T.type]!!! FIX THIS SHIT!!!")
		return
	playsound(T, pick(footstep_sounds[turf_footstep][1]), footstep_sounds[turf_footstep][2], FALSE, footstep_sounds[turf_footstep][3] + e_range)

/datum/component/footstep/proc/play_humanstep()
	var/turf/open/T = prepare_step()
	if(!T)
		return
	var/mob/living/carbon/human/H = parent
	var/feetCover = (H.wear_armor && (H.wear_armor.body_parts_covered & FEET)) || (H.wear_pants && (H.wear_pants.body_parts_covered & FEET))

	var/used_sound
	var/list/used_footsteps

	if(H.shoes || feetCover) //are we wearing shoes
		//SANITY CHECK, WILL NOT PLAY A SOUND IF THE LIST IS INVALID
		if(!GLOB.footstep[T.footstep] || (LAZYLEN(GLOB.footstep[T.footstep]) < 3))
			testing("SOME RETARD GAVE AN INVALID FOOTSTEP VALUE ([T.footstep]) TO [T.type]!!! FIX THIS SHIT!!!")
			return
		used_footsteps = GLOB.footstep[T.footstep][1]
		used_footsteps = used_footsteps.Copy()
		used_sound = pick_n_take(used_footsteps)
		if(used_sound == last_sound)
			if(used_footsteps.len)
				used_sound = pick(used_footsteps)
		if(!used_sound)
			used_sound = last_sound
		last_sound = used_sound
		playsound(T, used_sound,
			GLOB.footstep[T.footstep][2],
			FALSE,
			GLOB.footstep[T.footstep][3] + e_range)
	else
		//SANITY CHECK, WILL NOT PLAY A SOUND IF THE LIST IS INVALID
		if(!GLOB.barefootstep[T.barefootstep] || (LAZYLEN(GLOB.barefootstep[T.barefootstep]) < 3))
			testing("SOME RETARD GAVE AN INVALID BAREFOOTSTEP VALUE ([T.barefootstep]) TO [T.type]!!! FIX THIS SHIT!!!")
			return
		used_footsteps = GLOB.barefootstep[T.barefootstep][1]
		used_footsteps = used_footsteps.Copy()
		used_sound = pick_n_take(used_footsteps)
		if(used_sound == last_sound)
			used_sound = pick(used_footsteps)
		if(!used_sound)
			used_sound = last_sound
		last_sound = used_sound
		playsound(T, used_sound,
			GLOB.barefootstep[T.barefootstep][2],
			TRUE,
			GLOB.barefootstep[T.barefootstep][3] + e_range)
