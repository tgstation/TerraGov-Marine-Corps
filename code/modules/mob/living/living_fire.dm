///Returns true if actually on fire of any kind
/mob/living/proc/is_on_fire()
	if(has_status_effect(STATUS_EFFECT_MELTING_FIRE))
		return TRUE
	var/datum/status_effect/stacking/fire/current_burning = has_status_effect(STATUS_EFFECT_BURNING)
	if(!current_burning)
		return FALSE
	if(current_burning.is_ignited && current_burning.stacks > 0)
		return TRUE

///sets the mob on fire, if they already have fire stacks
/mob/living/proc/IgniteMob()
	if(!can_ignite())
		return FALSE
	var/datum/status_effect/stacking/fire/current_burning = has_burning()
	if(!current_burning)
		return FALSE
	if(current_burning.is_ignited)
		return FALSE
	if(current_burning.stacks <= 0)
		return FALSE
	current_burning.do_ignite()
	return TRUE

///Checks if the mob can be set on fire
/mob/living/proc/can_ignite()
	if(status_flags & GODMODE)
		return FALSE
	if(HAS_TRAIT(src, TRAIT_NON_FLAMMABLE))
		return FALSE
	if(soft_armor?.getRating(FIRE) >= 100)
		return FALSE
	if(!CHECK_BITFIELD(datum_flags, DF_ISPROCESSING))
		return FALSE
	return TRUE

///Effects when set on fire
/mob/living/proc/on_ignite()
	return

///Puts out any fire on the mob
/mob/living/proc/extinguish_mob()
	remove_status_effect(STATUS_EFFECT_MELTING_FIRE)
	if(amount_burning() > 0)
		remove_status_effect(STATUS_EFFECT_BURNING)

///Updates fire visuals
/mob/living/proc/update_fire()
	return

///effects of being on fire
/mob/living/proc/handle_fire(stacks)
	SEND_SIGNAL(src, COMSIG_LIVING_HANDLE_FIRE)
