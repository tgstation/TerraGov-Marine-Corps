////////////////////////////// STUN ////////////////////////////////////

///Returns if stunned
/mob/living/proc/IsStun()
	return has_status_effect(STATUS_EFFECT_STUN)

///Returns remaining stun duration
/mob/living/proc/AmountStun()
	var/datum/status_effect/incapacitating/stun/current_stun = IsStun()
	return current_stun ? current_stun.duration - world.time : 0

///Applies stun from current world time unless existing duration is higher
/mob/living/proc/Stun(amount, ignore_canstun = FALSE)
	if(status_flags & GODMODE)
		return
	if((!(status_flags & CANSTUN) || HAS_TRAIT(src, TRAIT_STUNIMMUNE)) && !ignore_canstun)
		return
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_STUN, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(absorb_stun(amount, ignore_canstun))
		return

	var/datum/status_effect/incapacitating/stun/current_stun = IsStun()
	if(current_stun)
		current_stun.duration = max(world.time + amount, current_stun.duration)
	else if(amount > 0)
		current_stun = apply_status_effect(STATUS_EFFECT_STUN, amount)

	return current_stun

///Used to set stun to a set amount, commonly to remove it
/mob/living/proc/SetStun(amount, ignore_canstun = FALSE)
	var/datum/status_effect/incapacitating/stun/current_stun = IsStun()
	if(amount <= 0)
		if(current_stun)
			qdel(current_stun)
		return
	if(status_flags & GODMODE)
		return
	if((!(status_flags & CANSTUN) || HAS_TRAIT(src, TRAIT_STUNIMMUNE)) && !ignore_canstun)
		return
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_STUN, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(absorb_stun(amount, ignore_canstun))
		return

	if(current_stun)
		current_stun.duration = world.time + amount
	else
		current_stun = apply_status_effect(STATUS_EFFECT_STUN, amount)

	return current_stun

///Applies stun or adds to existing duration
/mob/living/proc/AdjustStun(amount, ignore_canstun = FALSE)
	if(status_flags & GODMODE)
		return
	if((!(status_flags & CANSTUN) || HAS_TRAIT(src, TRAIT_STUNIMMUNE)) && !ignore_canstun)
		return
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_STUN, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(absorb_stun(amount, ignore_canstun))
		return

	var/datum/status_effect/incapacitating/stun/current_stun = IsStun()
	if(current_stun)
		current_stun.duration += amount
	else if(amount > 0)
		current_stun = apply_status_effect(STATUS_EFFECT_STUN, amount)

	return current_stun

///////////////////////////////// KNOCKDOWN /////////////////////////////////////
///Returns if knockeddown
/mob/living/proc/IsKnockdown()
	return has_status_effect(STATUS_EFFECT_KNOCKDOWN)

///Returns remaining knockdown duration
/mob/living/proc/AmountKnockdown()
	var/datum/status_effect/incapacitating/knockdown/current_knockdown = IsKnockdown()
	return current_knockdown ? current_knockdown.duration - world.time : 0

///Applies knockdown only if not currently applied
/mob/living/proc/KnockdownNoChain(amount, ignore_canstun = FALSE)
	if(status_flags & GODMODE)
		return
	if(IsKnockdown())
		return 0
	return Knockdown(amount, ignore_canstun)

///Applies knockdown from current world time unless existing duration is higher
/mob/living/proc/Knockdown(amount, ignore_canstun = FALSE)
	if(status_flags & GODMODE)
		return
	if((!(status_flags & CANKNOCKDOWN) || HAS_TRAIT(src, TRAIT_STUNIMMUNE)) && !ignore_canstun)
		return
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_KNOCKDOWN, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(absorb_stun(amount, ignore_canstun))
		return

	var/datum/status_effect/incapacitating/knockdown/current_knockdown = IsKnockdown()
	if(current_knockdown)
		current_knockdown.duration = max(world.time + amount, current_knockdown.duration)
	else if(amount > 0)
		current_knockdown = apply_status_effect(STATUS_EFFECT_KNOCKDOWN, amount)

	return current_knockdown

///Used to set knockdown to a set amount, commonly to remove it
/mob/living/proc/SetKnockdown(amount, ignore_canstun = FALSE)
	var/datum/status_effect/incapacitating/knockdown/current_knockdown = IsKnockdown()
	if(amount <= 0)
		if(current_knockdown)
			qdel(current_knockdown)
		return
	if(status_flags & GODMODE)
		return
	if((!(status_flags & CANSTUN) || HAS_TRAIT(src, TRAIT_STUNIMMUNE)) && !ignore_canstun)
		return
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_KNOCKDOWN, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(absorb_stun(amount, ignore_canstun))
		return

	if(current_knockdown)
		current_knockdown.duration = world.time + amount
	else
		current_knockdown = apply_status_effect(STATUS_EFFECT_KNOCKDOWN, amount)

	return current_knockdown

///Applies knockdown or adds to existing duration
/mob/living/proc/AdjustKnockdown(amount, ignore_canstun = FALSE)
	if(status_flags & GODMODE)
		return
	if((!(status_flags & CANSTUN) || HAS_TRAIT(src, TRAIT_STUNIMMUNE)) && !ignore_canstun)
		return
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_KNOCKDOWN, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(absorb_stun(amount, ignore_canstun))
		return

	var/datum/status_effect/incapacitating/knockdown/current_knockdown = IsKnockdown()
	if(current_knockdown)
		current_knockdown.duration += amount
	else if(amount > 0)
		current_knockdown = apply_status_effect(STATUS_EFFECT_KNOCKDOWN, amount)

	return current_knockdown

///////////////////////////////// IMMOBILIZED /////////////////////////////////////
///Returns if immobilized
/mob/living/proc/IsImmobilized()
	return has_status_effect(STATUS_EFFECT_IMMOBILIZED)

///Returns remaining immobilize duration
/mob/living/proc/AmountImmobilized()
	var/datum/status_effect/incapacitating/immobilized/current_immobilized = IsImmobilized()
	return current_immobilized ? current_immobilized.duration - world.time : 0

///Applies immobilize only if not currently applied
/mob/living/proc/ImmobilizeNoChain(amount, ignore_canstun = FALSE)
	if(status_flags & GODMODE)
		return
	if(IsImmobilized())
		return 0
	return Immobilize(amount, ignore_canstun)

///Applies immobilize from current world time unless existing duration is higher
/mob/living/proc/Immobilize(amount, ignore_canstun = FALSE)
	if(status_flags & GODMODE)
		return
	if((!(status_flags & CANKNOCKDOWN) || HAS_TRAIT(src, TRAIT_STUNIMMUNE)) && !ignore_canstun)
		return
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_IMMOBILIZE, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(absorb_stun(amount, ignore_canstun))
		return

	var/datum/status_effect/incapacitating/immobilized/current_immobilized = IsImmobilized()
	if(current_immobilized)
		current_immobilized.duration = max(world.time + amount, current_immobilized.duration)
	else if(amount > 0)
		current_immobilized = apply_status_effect(STATUS_EFFECT_IMMOBILIZED, amount)

	return current_immobilized

///Used to set immobilize to a set amount, commonly to remove it
/mob/living/proc/SetImmobilized(amount, ignore_canstun = FALSE)
	var/datum/status_effect/incapacitating/immobilized/current_immobilized = IsImmobilized()
	if(amount <= 0)
		if(current_immobilized)
			qdel(current_immobilized)
		return
	if(status_flags & GODMODE)
		return
	if((!(status_flags & CANKNOCKDOWN) || HAS_TRAIT(src, TRAIT_STUNIMMUNE)) && !ignore_canstun)
		return
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_IMMOBILIZE, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(absorb_stun(amount, ignore_canstun))
		return

	if(current_immobilized)
		current_immobilized.duration = world.time + amount
	else
		current_immobilized = apply_status_effect(STATUS_EFFECT_IMMOBILIZED, amount)

	return current_immobilized

///Applies immobilized or adds to existing duration
/mob/living/proc/AdjustImmobilized(amount, ignore_canstun = FALSE)
	if(status_flags & GODMODE)
		return
	if((!(status_flags & CANKNOCKDOWN) || HAS_TRAIT(src, TRAIT_STUNIMMUNE)) && !ignore_canstun)
		return
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_IMMOBILIZE, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(absorb_stun(amount, ignore_canstun))
		return

	var/datum/status_effect/incapacitating/immobilized/current_immobilized = IsImmobilized()
	if(current_immobilized)
		current_immobilized.duration += amount
	else if(amount > 0)
		current_immobilized = apply_status_effect(STATUS_EFFECT_IMMOBILIZED, amount)

	return current_immobilized

///////////////////////////////// PARALYZED //////////////////////////////////
///Returns if paralyzed
/mob/living/proc/IsParalyzed()
	return has_status_effect(STATUS_EFFECT_PARALYZED)

///Returns remaining paralyzed duration
/mob/living/proc/AmountParalyzed()
	var/datum/status_effect/incapacitating/paralyzed/current_paralyzed = IsParalyzed()
	return current_paralyzed ? current_paralyzed.duration - world.time : 0

///Applies paralyze only if not currently applied
/mob/living/proc/ParalyzeNoChain(amount, ignore_canstun = FALSE)
	if(status_flags & GODMODE)
		return
	if(IsParalyzed())
		return 0
	return Paralyze(amount, ignore_canstun)

///Applies paralyze from current world time unless existing duration is higher
/mob/living/proc/Paralyze(amount, ignore_canstun = FALSE)
	if(status_flags & GODMODE)
		return
	if((!(status_flags & CANKNOCKDOWN) || HAS_TRAIT(src, TRAIT_STUNIMMUNE)) && !ignore_canstun)
		return
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_PARALYZE, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(absorb_stun(amount, ignore_canstun))
		return

	var/datum/status_effect/incapacitating/paralyzed/current_paralyzed = IsParalyzed()
	if(current_paralyzed)
		current_paralyzed.duration = max(world.time + amount, current_paralyzed.duration)
	else if(amount > 0)
		current_paralyzed = apply_status_effect(STATUS_EFFECT_PARALYZED, amount)

	return current_paralyzed

/mob/living/carbon/Paralyze(amount, ignore_canstun)
	if(species?.species_flags & PARALYSE_RESISTANT)
		if(amount > MAX_PARALYSE_AMOUNT_FOR_PARALYSE_RESISTANT * 4)
			amount = MAX_PARALYSE_AMOUNT_FOR_PARALYSE_RESISTANT
			return ..()
		amount /= 4
	return ..()

///Used to set paralyzed to a set amount, commonly to remove it
/mob/living/proc/SetParalyzed(amount, ignore_canstun = FALSE)
	var/datum/status_effect/incapacitating/paralyzed/current_paralyzed = IsParalyzed()
	if(amount <= 0)
		if(current_paralyzed)
			qdel(current_paralyzed)
		return
	if(status_flags & GODMODE)
		return
	if((!(status_flags & CANKNOCKDOWN) || HAS_TRAIT(src, TRAIT_STUNIMMUNE)) && !ignore_canstun)
		return
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_PARALYZE, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(absorb_stun(amount, ignore_canstun))
		return

	if(current_paralyzed)
		current_paralyzed.duration = world.time + amount
	else
		current_paralyzed = apply_status_effect(STATUS_EFFECT_PARALYZED, amount)

	return current_paralyzed

///Applies paralyzed or adds to existing duration
/mob/living/proc/AdjustParalyzed(amount, ignore_canstun = FALSE)
	if(status_flags & GODMODE)
		return
	if((!(status_flags & CANKNOCKDOWN) || HAS_TRAIT(src, TRAIT_STUNIMMUNE)) && !ignore_canstun)
		return
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_PARALYZE, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(absorb_stun(amount, ignore_canstun))
		return

	var/datum/status_effect/incapacitating/paralyzed/current_paralyzed = IsParalyzed()
	if(current_paralyzed)
		current_paralyzed.duration += amount
	else if(amount > 0)
		current_paralyzed = apply_status_effect(STATUS_EFFECT_PARALYZED, amount)

	return current_paralyzed

/////////////////////////////////// SLEEPING ////////////////////////////////////
///Returns if sleeping
/mob/living/proc/IsSleeping()
	return has_status_effect(STATUS_EFFECT_SLEEPING)

///Returns remaining sleeping duration
/mob/living/proc/AmountSleeping()
	var/datum/status_effect/incapacitating/sleeping/current_sleeping = IsSleeping()
	return current_sleeping ? current_sleeping.duration - world.time : 0

///Applies sleeping from current world time unless existing duration is higher
/mob/living/proc/Sleeping(amount, ignore_canstun = FALSE)
	if(status_flags & GODMODE)
		return
	if(HAS_TRAIT(src, TRAIT_STUNIMMUNE) && !ignore_canstun)
		return
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_SLEEP, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(absorb_stun(amount, ignore_canstun))
		return

	var/datum/status_effect/incapacitating/sleeping/current_sleeping = IsSleeping()
	if(current_sleeping)
		current_sleeping.duration = max(world.time + amount, current_sleeping.duration)
	else if(amount > 0)
		current_sleeping = apply_status_effect(STATUS_EFFECT_SLEEPING, amount)

	return current_sleeping

///Used to set sleeping to a set amount, commonly to remove it
/mob/living/proc/SetSleeping(amount, ignore_canstun = FALSE)
	var/datum/status_effect/incapacitating/sleeping/current_sleeping = IsSleeping()
	if(amount <= 0)
		if(current_sleeping)
			qdel(current_sleeping)
		return
	if(status_flags & GODMODE)
		return
	if(HAS_TRAIT(src, TRAIT_STUNIMMUNE) && !ignore_canstun)
		return
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_SLEEP, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(absorb_stun(amount, ignore_canstun))
		return

	if(current_sleeping)
		current_sleeping.duration = world.time + amount
	else
		current_sleeping = apply_status_effect(STATUS_EFFECT_SLEEPING, amount)

	return current_sleeping

///Applies sleeping or adds to existing duration
/mob/living/proc/AdjustSleeping(amount, ignore_canstun = FALSE)
	if(status_flags & GODMODE)
		return
	if(HAS_TRAIT(src, TRAIT_STUNIMMUNE) && !ignore_canstun)
		return
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_SLEEP, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(absorb_stun(amount, ignore_canstun))
		return

	var/datum/status_effect/incapacitating/sleeping/current_sleeping = IsSleeping()
	if(current_sleeping)
		current_sleeping.duration += amount
	else if(amount > 0)
		current_sleeping = apply_status_effect(STATUS_EFFECT_SLEEPING, amount)

	return current_sleeping

/////////////////////////////////// ADMIN SLEEP ////////////////////////////////////

/mob/living/proc/IsAdminSleeping()
	return has_status_effect(STATUS_EFFECT_ADMINSLEEP)

/mob/living/proc/ToggleAdminSleep()
	var/datum/status_effect/incapacitating/adminsleep/S = IsAdminSleeping()
	if(S)
		qdel(S)
	else
		S = apply_status_effect(STATUS_EFFECT_ADMINSLEEP)
	return S

/mob/living/proc/SetAdminSleep(remove = FALSE)
	var/datum/status_effect/incapacitating/adminsleep/S = IsAdminSleeping()
	if(remove)
		qdel(S)
	else
		S = apply_status_effect(STATUS_EFFECT_ADMINSLEEP)
	return S

//////////////////UNCONSCIOUS
///Returns if unconscious
/mob/living/proc/IsUnconscious()
	return has_status_effect(STATUS_EFFECT_UNCONSCIOUS)

///Returns remaining unconscious duration
/mob/living/proc/AmountUnconscious()
	var/datum/status_effect/incapacitating/unconscious/current_unconscious = IsUnconscious()
	return current_unconscious ? current_unconscious.duration - world.time : 0

///Applies unconscious from current world time unless existing duration is higher
/mob/living/proc/Unconscious(amount, ignore_canstun = FALSE)
	if(status_flags & GODMODE)
		return
	if((!(status_flags & CANUNCONSCIOUS) || HAS_TRAIT(src, TRAIT_STUNIMMUNE)) && !ignore_canstun)
		return
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_UNCONSCIOUS, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(absorb_stun(amount, ignore_canstun))
		return

	var/datum/status_effect/incapacitating/unconscious/current_unconscious = IsUnconscious()
	if(current_unconscious)
		current_unconscious.duration = max(world.time + amount, current_unconscious.duration)
	else if(amount > 0)
		current_unconscious = apply_status_effect(STATUS_EFFECT_UNCONSCIOUS, amount)

	return current_unconscious

///Used to set unconscious to a set amount, commonly to remove it
/mob/living/proc/SetUnconscious(amount, ignore_canstun = FALSE)
	var/datum/status_effect/incapacitating/unconscious/current_unconscious = IsUnconscious()
	if(amount <= 0)
		if(current_unconscious)
			qdel(current_unconscious)
		return
	if(status_flags & GODMODE)
		return
	if((!(status_flags & CANUNCONSCIOUS) || HAS_TRAIT(src, TRAIT_STUNIMMUNE)) && !ignore_canstun)
		return
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_UNCONSCIOUS, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(absorb_stun(amount, ignore_canstun))
		return

	if(current_unconscious)
		current_unconscious.duration = world.time + amount
	else
		current_unconscious = apply_status_effect(STATUS_EFFECT_UNCONSCIOUS, amount)

	return current_unconscious

///Applies unconscious or adds to existing duration
/mob/living/proc/AdjustUnconscious(amount, ignore_canstun = FALSE)
	if(status_flags & GODMODE)
		return
	if((!(status_flags & CANUNCONSCIOUS) || HAS_TRAIT(src, TRAIT_STUNIMMUNE)) && !ignore_canstun)
		return
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_UNCONSCIOUS, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(absorb_stun(amount, ignore_canstun))
		return

	var/datum/status_effect/incapacitating/unconscious/current_unconscious = IsUnconscious()
	if(current_unconscious)
		current_unconscious.duration += amount
	else if(amount > 0)
		current_unconscious = apply_status_effect(STATUS_EFFECT_UNCONSCIOUS, amount)

	return current_unconscious

//////////////////CONFUSED
///Returns if confused
/mob/living/proc/IsConfused()
	return has_status_effect(STATUS_EFFECT_CONFUSED)

///Returns remaining confused duration
/mob/living/proc/AmountConfused()
	var/datum/status_effect/incapacitating/confused/current_confused = IsConfused()
	return current_confused ? current_confused.duration - world.time : 0

///Applies confused from current world time unless existing duration is higher
/mob/living/proc/Confused(amount, ignore_canstun = FALSE)
	if(status_flags & GODMODE)
		return
	if((!(status_flags & CANCONFUSE) || HAS_TRAIT(src, TRAIT_STUNIMMUNE)) && !ignore_canstun)
		return
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_CONFUSED, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(absorb_stun(amount, ignore_canstun))
		return

	var/datum/status_effect/incapacitating/confused/current_confused = IsConfused()
	if(current_confused)
		current_confused.duration = max(world.time + amount, current_confused.duration)
	else if(amount > 0)
		current_confused = apply_status_effect(STATUS_EFFECT_CONFUSED, amount)

	return current_confused

///Used to set confused to a set amount, commonly to remove it
/mob/living/proc/SetConfused(amount, ignore_canstun = FALSE)
	var/datum/status_effect/incapacitating/confused/current_confused = IsConfused()
	if(amount <= 0)
		if(current_confused)
			qdel(current_confused)
		return
	if(status_flags & GODMODE)
		return
	if((!(status_flags & CANCONFUSE) || HAS_TRAIT(src, TRAIT_STUNIMMUNE)) && !ignore_canstun)
		return
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_CONFUSED, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(absorb_stun(amount, ignore_canstun))
		return

	if(current_confused)
		current_confused.duration = world.time + amount
	else
		current_confused = apply_status_effect(STATUS_EFFECT_CONFUSED, amount)

	return current_confused

///Applies confused or adds to existing duration
/mob/living/proc/AdjustConfused(amount, ignore_canstun = FALSE)
	if(status_flags & GODMODE)
		return
	if((!(status_flags & CANCONFUSE) || HAS_TRAIT(src, TRAIT_STUNIMMUNE)) && !ignore_canstun)
		return
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_CONFUSED, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(absorb_stun(amount, ignore_canstun))
		return

	var/datum/status_effect/incapacitating/confused/current_confused = IsConfused()
	if(current_confused)
		current_confused.duration += amount
	else if(amount > 0)
		current_confused = apply_status_effect(STATUS_EFFECT_CONFUSED, amount)

	return current_confused

///////////////////////////////////// STUN ABSORPTION /////////////////////////////////////

/mob/living/proc/add_stun_absorption(key, duration, priority, message, self_message, examine_message)
//adds a stun absorption with a key, a duration in deciseconds, its priority, and the messages it makes when you're stun/examined, if any
	if(!islist(stun_absorption))
		stun_absorption = list()
	if(stun_absorption[key])
		stun_absorption[key]["end_time"] = world.time + duration
		stun_absorption[key]["priority"] = priority
		stun_absorption[key]["stuns_absorbed"] = 0
	else
		stun_absorption[key] = list("end_time" = world.time + duration, "priority" = priority, "stuns_absorbed" = 0, \
		"visible_message" = message, "self_message" = self_message, "examine_message" = examine_message)

/mob/living/proc/absorb_stun(amount, ignoring_flag_presence)
	if(amount < 0 || stat || ignoring_flag_presence || !islist(stun_absorption))
		return FALSE
	if(!amount)
		amount = 0
	var/priority_absorb_key
	var/highest_priority
	for(var/i in stun_absorption)
		if(stun_absorption[i]["end_time"] > world.time && (!priority_absorb_key || stun_absorption[i]["priority"] > highest_priority))
			priority_absorb_key = stun_absorption[i]
			highest_priority = priority_absorb_key["priority"]
	if(priority_absorb_key)
		if(amount) //don't spam up the chat for continuous stuns
			if(priority_absorb_key["visible_message"] || priority_absorb_key["self_message"])
				if(priority_absorb_key["visible_message"] && priority_absorb_key["self_message"])
					visible_message(span_warning("[src][priority_absorb_key["visible_message"]]"), span_boldwarning("[priority_absorb_key["self_message"]]"))
				else if(priority_absorb_key["visible_message"])
					visible_message(span_warning("[src][priority_absorb_key["visible_message"]]"))
				else if(priority_absorb_key["self_message"])
					to_chat(src, span_boldwarning("[priority_absorb_key["self_message"]]"))
			priority_absorb_key["stuns_absorbed"] += amount
		return TRUE

/mob/living/proc/jitter(amount)
	jitteriness = clamp(jitteriness + amount,0, 1000)

/mob/living/proc/dizzy(amount)
	return // For the time being, only carbons get dizzy.

/mob/living/proc/blind_eyes(amount)
	if(amount>0)
		var/old_eye_blind = eye_blind
		eye_blind = max(eye_blind, amount)
		if(!old_eye_blind)
			overlay_fullscreen("blind", /atom/movable/screen/fullscreen/blind)

/mob/living/proc/adjust_blindness(amount)
	if(amount>0)
		var/old_eye_blind = eye_blind
		eye_blind += amount
		if(!old_eye_blind)
			overlay_fullscreen("blind", /atom/movable/screen/fullscreen/blind)
	else if(eye_blind)
		var/blind_minimum = 0
		if(stat != CONSCIOUS)
			blind_minimum = 1
		if(isliving(src))
			var/mob/living/L = src
			if(!L.has_vision())
				blind_minimum = 1
		eye_blind = max(eye_blind+amount, blind_minimum)
		if(!eye_blind)
			clear_fullscreen("blind")

/mob/living/proc/set_blindness(amount)
	if(amount>0)
		var/old_eye_blind = eye_blind
		eye_blind = amount
		if(client && !old_eye_blind)
			overlay_fullscreen("blind", /atom/movable/screen/fullscreen/blind)
	else if(eye_blind)
		var/blind_minimum = 0
		if(stat != CONSCIOUS)
			blind_minimum = 1
		if(isliving(src))
			var/mob/living/L = src
			if(!L.has_vision())
				blind_minimum = 1
		eye_blind = blind_minimum
		if(!eye_blind)
			clear_fullscreen("blind")

/mob/living/proc/blur_eyes(amount)
	if(amount>0)
		eye_blurry = max(amount, eye_blurry)
	update_eye_blur()

/mob/living/proc/adjust_blurriness(amount)
	eye_blurry = max(eye_blurry+amount, 0)
	update_eye_blur()

/mob/living/proc/set_blurriness(amount)
	eye_blurry = max(amount, 0)
	update_eye_blur()

// todo replace this shit with tg's style status effect for this
/mob/living/proc/update_eye_blur()
	if(!client)
		return
	if(SEND_SIGNAL(src, COMSIG_LIVING_UPDATE_PLANE_BLUR) & COMPONENT_CANCEL_BLUR)
		return
	var/atom/movable/plane_master_controller/game_plane_master_controller = hud_used.plane_master_controllers[PLANE_MASTERS_GAME]
	if(eye_blurry <= 0)
		game_plane_master_controller.remove_filter("eye_blur")
	else
		game_plane_master_controller.add_filter("eye_blur", 1, gauss_blur_filter(clamp(eye_blurry * 0.1, 0.6, 3)))

/mob/living/proc/adjust_ear_damage(damage = 0, deaf = 0)
	ear_damage = max(0, ear_damage + damage)
	ear_deaf = max((disabilities & DEAF|| ear_damage >= 100) ? 1 : 0, ear_deaf + deaf)


/mob/living/proc/set_ear_damage(damage = 0, deaf = 0)
	if(!isnull(damage))
		ear_damage = damage
	if(!isnull(deaf))
		ear_deaf = max((disabilities & DEAF|| ear_damage >= 100) ? 1 : 0, deaf)

///Modify mob's drugginess in either direction, minimum zero. Adds or removes druggy overlay as appropriate.
/mob/living/proc/adjust_drugginess(amount)
	druggy = max(druggy + amount, 0)
	if(druggy)
		overlay_fullscreen("high", /atom/movable/screen/fullscreen/high)
	else
		clear_fullscreen("high")

///Sets mob's drugginess to provided amount, minimum 0. Adds or removes druggy overlay as appropriate.
/mob/living/proc/set_drugginess(amount)
	druggy = max(amount, 0)
	if(druggy)
		overlay_fullscreen("high", /atom/movable/screen/fullscreen/high)
	else
		clear_fullscreen("high")


/mob/living/proc/adjust_bodytemperature(amount, min_temp = 0, max_temp = INFINITY)
	if(bodytemperature < min_temp || bodytemperature > max_temp)
		return
	. = bodytemperature
	bodytemperature = clamp(bodytemperature + amount, min_temp, max_temp)


/mob/living/carbon/human/adjust_bodytemperature(amount, min_temp = 0, max_temp = INFINITY)
	. = ..()
	adjust_bodytemperature_speed_mod(.)


/mob/living/carbon/human/proc/adjust_bodytemperature_speed_mod(old_temperature)
	if(bodytemperature < species.cold_level_1)
		if(old_temperature < species.cold_level_1)
			return
		add_movespeed_modifier(MOVESPEED_ID_COLD, TRUE, 0, NONE, TRUE, 2)
	else if(old_temperature < species.cold_level_1)
		remove_movespeed_modifier(MOVESPEED_ID_COLD)

////////////////////////////// STAGGER ////////////////////////////////////

///Returns if staggered
/mob/living/proc/IsStaggered()
	return has_status_effect(STATUS_EFFECT_STAGGER)

///Returns remaining stagger duration
/mob/living/proc/AmountStaggered()
	var/datum/status_effect/incapacitating/stagger/current_stagger = IsStaggered()
	return current_stagger ? current_stagger.duration - world.time : 0

///Applies stagger from current world time unless existing duration is higher
/mob/living/proc/Stagger(amount, ignore_canstun = FALSE)
	if(status_flags & GODMODE)
		return
	if((!(status_flags & CANSTUN) || HAS_TRAIT(src, TRAIT_STAGGERIMMUNE)) && !ignore_canstun)
		return
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_STAGGER, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(absorb_stun(amount, ignore_canstun))
		return

	var/datum/status_effect/incapacitating/stagger/current_stagger = IsStaggered()
	if(current_stagger)
		current_stagger.duration = max(world.time + amount, current_stagger.duration)
	else if(amount > 0)
		current_stagger = apply_status_effect(STATUS_EFFECT_STAGGER, amount)

	return current_stagger

///Used to set stagger to a set amount, commonly to remove it
/mob/living/proc/set_stagger(amount, ignore_canstun = FALSE)
	var/datum/status_effect/incapacitating/stagger/current_stagger = IsStaggered()
	if(amount <= 0)
		if(current_stagger)
			qdel(current_stagger)
		return
	if(status_flags & GODMODE)
		return
	if((!(status_flags & CANSTUN) || HAS_TRAIT(src, TRAIT_STAGGERIMMUNE)) && !ignore_canstun)
		return
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_STAGGER, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(absorb_stun(amount, ignore_canstun))
		return

	if(current_stagger)
		current_stagger.duration = world.time + amount
	else
		current_stagger = apply_status_effect(STATUS_EFFECT_STAGGER, amount)

	return current_stagger

///Applies stagger or adds to existing duration
/mob/living/proc/adjust_stagger(amount, ignore_canstun = FALSE)
	if(status_flags & GODMODE)
		return
	if((!(status_flags & CANSTUN) || HAS_TRAIT(src, TRAIT_STAGGERIMMUNE)) && !ignore_canstun)
		return
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_STAGGER, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(absorb_stun(amount, ignore_canstun))
		return

	var/datum/status_effect/incapacitating/stagger/current_stagger = IsStaggered()
	if(current_stagger)
		current_stagger.duration += amount
	else if(amount > 0)
		current_stagger = apply_status_effect(STATUS_EFFECT_STAGGER, amount)

	return current_stagger

////////////////////////////// SLOW ////////////////////////////////////

///Returns number of slowdown stacks if any
/mob/living/proc/IsSlowed() //If we're slowed
	return slowdown

///Where the magic happens. Actually applies slow stacks.
/mob/living/proc/set_slowdown(amount)
	if(slowdown == amount)
		return
	if(amount > 0 && HAS_TRAIT(src, TRAIT_SLOWDOWNIMMUNE)) //We're immune to slowdown
		return
	SEND_SIGNAL(src, COMSIG_LIVING_STATUS_SLOWDOWN, amount)
	slowdown = amount
	if(slowdown)
		add_movespeed_modifier(MOVESPEED_ID_STAGGERSTUN, TRUE, 0, NONE, TRUE, slowdown)
		return
	remove_movespeed_modifier(MOVESPEED_ID_STAGGERSTUN)

///This is where we normalize the set_slowdown input to be at least 0
/mob/living/proc/adjust_slowdown(amount)
	if(amount > 0)
		if(HAS_TRAIT(src, TRAIT_SLOWDOWNIMMUNE))
			return slowdown
		set_slowdown(max(slowdown, amount)) //Slowdown overlaps rather than stacking.
	else
		set_slowdown(max(slowdown + amount, 0))
	return slowdown

/mob/living/proc/add_slowdown(amount, capped = 0)
	if(HAS_TRAIT(src, TRAIT_SLOWDOWNIMMUNE))
		return
	adjust_slowdown(amount * STANDARD_SLOWDOWN_REGEN)

///Standard slowdown regen called by life.dm
/mob/living/proc/handle_slowdown()
	if(slowdown)
		adjust_slowdown(-STANDARD_SLOWDOWN_REGEN)
	return slowdown

/mob/living/carbon/xenomorph/add_slowdown(amount)
	if(HAS_TRAIT(src, TRAIT_SLOWDOWNIMMUNE) || is_charging >= CHARGE_ON)
		return
	adjust_slowdown(amount * XENO_SLOWDOWN_REGEN)

////////////////////////////// MUTE ////////////////////////////////////

///Checks to see if we're muted
/mob/living/proc/IsMute()
	return has_status_effect(STATUS_EFFECT_MUTED)

///Checks the duration left on our mute status effect
/mob/living/proc/AmountMute()
	var/datum/status_effect/mute/M = IsMute()
	if(M)
		return M.duration - world.time
	return 0

///Mutes the target for the stated duration
/mob/living/proc/Mute(amount) //Can't go below remaining duration
	if(status_flags & GODMODE)
		return
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_MUTE, amount) & COMPONENT_NO_MUTE)
		return
	var/datum/status_effect/mute/M = IsMute()
	if(M)
		M.duration = max(world.time + amount, M.duration)
	else if(amount > 0)
		M = apply_status_effect(STATUS_EFFECT_MUTED, amount)
	return M

//Sets remaining mute duration
/mob/living/proc/SetMute(amount)
	if(status_flags & GODMODE)
		return
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_MUTE, amount) & COMPONENT_NO_MUTE)
		return
	var/datum/status_effect/mute/M = IsMute()

	if(M)
		if(amount <= 0)
			qdel(M)
			return

		M.duration = world.time + amount
		return

	M = apply_status_effect(STATUS_EFFECT_MUTED, amount)
	return M

///Adds to remaining mute duration
/mob/living/proc/AdjustMute(amount)
	if(!amount)
		return
	if(status_flags & GODMODE)
		return
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_MUTE, amount) & COMPONENT_NO_MUTE)
		return

	var/datum/status_effect/mute/M = IsMute()
	if(M)
		M.duration += amount
	else if(amount > 0)
		M = apply_status_effect(STATUS_EFFECT_MUTED, amount)
	return M

///////////////////////////////// Irradiated //////////////////////////////////

///Returns whether the mob is irradiated or not
/mob/living/proc/is_irradiated()
	return has_status_effect(STATUS_EFFECT_IRRADIATED)

///How many deciseconds remain in our irradiated status effect
/mob/living/proc/amount_irradiated()
	var/datum/status_effect/incapacitating/irradiated/irradiated = is_irradiated()
	if(irradiated)
		return irradiated.duration - world.time
	return 0

///Applies irradiation from a source
/mob/living/proc/irradiate(amount, ignore_canstun = FALSE) //Can't go below remaining duration
	if(status_flags & GODMODE)
		return
	var/datum/status_effect/incapacitating/irradiated/irradiated = is_irradiated()
	if(irradiated)
		irradiated.duration = max(world.time + amount, irradiated.duration)
	else if(amount > 0)
		irradiated = apply_status_effect(STATUS_EFFECT_IRRADIATED, amount)
	return irradiated

///Sets irradiation  duration
/mob/living/proc/set_radiation(amount, ignore_canstun = FALSE)
	if(status_flags & GODMODE)
		return
	var/datum/status_effect/incapacitating/irradiated/irradiated = is_irradiated()
	if(amount <= 0)
		if(irradiated)
			qdel(irradiated)
	else
		if(irradiated)
			irradiated.duration = world.time + amount
		else
			irradiated = apply_status_effect(STATUS_EFFECT_IRRADIATED, amount)
	return irradiated

///Modifies irradiation duration
/mob/living/proc/adjust_radiation(amount, ignore_canstun = FALSE)
	if(status_flags & GODMODE)
		return
	var/datum/status_effect/incapacitating/irradiated/irradiated = is_irradiated()
	if(irradiated)
		irradiated.duration += amount
	else if(amount > 0)
		irradiated = apply_status_effect(STATUS_EFFECT_IRRADIATED, amount)
	return irradiated

///Returns whether the mob has been recently hit by a sniper round
/mob/living/proc/is_recently_sniped()
	return has_status_effect(STATUS_EFFECT_SNIPED)
