////////////////////////////// STUN ////////////////////////////////////

/mob/living/proc/IsStun() //If we're stunned
	return has_status_effect(STATUS_EFFECT_STUN)

/mob/living/proc/AmountStun() //How many deciseconds remain in our stun
	var/datum/status_effect/incapacitating/stun/S = IsStun()
	if(S)
		return S.duration - world.time
	return 0

/mob/living/proc/Stun(amount, updating = TRUE, ignore_canstun = FALSE) //Can't go below remaining duration
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_STUN, amount, updating, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(((status_flags & CANSTUN) && !HAS_TRAIT(src, TRAIT_STUNIMMUNE)) || ignore_canstun)
		if(absorb_stun(amount, ignore_canstun))
			return
		var/datum/status_effect/incapacitating/stun/S = IsStun()
		if(S)
			S.duration = max(world.time + amount, S.duration)
		else if(amount > 0)
			S = apply_status_effect(STATUS_EFFECT_STUN, amount, updating)
		return S

/mob/living/proc/SetStun(amount, updating = TRUE, ignore_canstun = FALSE) //Sets remaining duration
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_STUN, amount, updating, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(((status_flags & CANSTUN) && !HAS_TRAIT(src, TRAIT_STUNIMMUNE)) || ignore_canstun)
		var/datum/status_effect/incapacitating/stun/S = IsStun()
		if(amount <= 0)
			if(S)
				qdel(S)
		else
			if(absorb_stun(amount, ignore_canstun))
				return
			if(S)
				S.duration = world.time + amount
			else
				S = apply_status_effect(STATUS_EFFECT_STUN, amount, updating)
		return S

/mob/living/proc/AdjustStun(amount, updating = TRUE, ignore_canstun = FALSE) //Adds to remaining duration
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_STUN, amount, updating, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(((status_flags & CANSTUN) && !HAS_TRAIT(src, TRAIT_STUNIMMUNE)) || ignore_canstun)
		if(absorb_stun(amount, ignore_canstun))
			return
		var/datum/status_effect/incapacitating/stun/S = IsStun()
		if(S)
			S.duration += amount
		else if(amount > 0)
			S = apply_status_effect(STATUS_EFFECT_STUN, amount, updating)
		return S

///////////////////////////////// KNOCKDOWN /////////////////////////////////////

/mob/living/proc/IsKnockdown() //If we're knocked down
	return has_status_effect(STATUS_EFFECT_KNOCKDOWN)

/mob/living/proc/AmountKnockdown() //How many deciseconds remain in our knockdown
	var/datum/status_effect/incapacitating/knockdown/K = IsKnockdown()
	if(K)
		return K.duration - world.time
	return 0

/mob/living/proc/KnockdownNoChain(amount, updating = TRUE, ignore_canstun = FALSE) // knockdown only if not already knockeddown
	if(IsKnockdown())
		return 0
	return Knockdown(amount, updating, ignore_canstun)

/mob/living/proc/Knockdown(amount, updating = TRUE, ignore_canstun = FALSE) //Can't go below remaining duration
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_KNOCKDOWN, amount, updating, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(((status_flags & CANKNOCKDOWN) && !HAS_TRAIT(src, TRAIT_STUNIMMUNE)) || ignore_canstun)
		if(absorb_stun(amount, ignore_canstun))
			return
		var/datum/status_effect/incapacitating/knockdown/K = IsKnockdown()
		if(K)
			K.duration = max(world.time + amount, K.duration)
		else if(amount > 0)
			K = apply_status_effect(STATUS_EFFECT_KNOCKDOWN, amount, updating)
		return K

/mob/living/proc/SetKnockdown(amount, updating = TRUE, ignore_canstun = FALSE) //Sets remaining duration
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_KNOCKDOWN, amount, updating, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(((status_flags & CANKNOCKDOWN) && !HAS_TRAIT(src, TRAIT_STUNIMMUNE)) || ignore_canstun)
		var/datum/status_effect/incapacitating/knockdown/K = IsKnockdown()
		if(amount <= 0)
			if(K)
				qdel(K)
		else
			if(absorb_stun(amount, ignore_canstun))
				return
			if(K)
				K.duration = world.time + amount
			else
				K = apply_status_effect(STATUS_EFFECT_KNOCKDOWN, amount, updating)
		return K

/mob/living/proc/AdjustKnockdown(amount, updating = TRUE, ignore_canstun = FALSE) //Adds to remaining duration
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_KNOCKDOWN, amount, updating, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(((status_flags & CANKNOCKDOWN) && !HAS_TRAIT(src, TRAIT_STUNIMMUNE)) || ignore_canstun)
		if(absorb_stun(amount, ignore_canstun))
			return
		var/datum/status_effect/incapacitating/knockdown/K = IsKnockdown()
		if(K)
			K.duration += amount
		else if(amount > 0)
			K = apply_status_effect(STATUS_EFFECT_KNOCKDOWN, amount, updating)
		return K

///////////////////////////////// PARALYZED //////////////////////////////////
/mob/living/proc/IsParalyzed() //If we're immobilized
	return has_status_effect(STATUS_EFFECT_PARALYZED)

/mob/living/proc/AmountParalyzed() //How many deciseconds remain in our Paralyzed status effect
	var/datum/status_effect/incapacitating/paralyzed/P = IsParalyzed(FALSE)
	if(P)
		return P.duration - world.time
	return 0

/mob/living/proc/ParalyzeNoChain(amount, updating = TRUE, ignore_canstun = FALSE) // knockdown only if not already knockeddown
	if(IsParalyzed())
		return 0
	return Paralyze(amount, updating, ignore_canstun)

/mob/living/proc/Paralyze(amount, updating = TRUE, ignore_canstun = FALSE) //Can't go below remaining duration
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_PARALYZE, amount, updating, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(((status_flags & CANKNOCKDOWN) && !HAS_TRAIT(src, TRAIT_STUNIMMUNE)) || ignore_canstun)
		if(absorb_stun(amount, ignore_canstun))
			return
		var/datum/status_effect/incapacitating/paralyzed/P = IsParalyzed(FALSE)
		if(P)
			P.duration = max(world.time + amount, P.duration)
		else if(amount > 0)
			P = apply_status_effect(STATUS_EFFECT_PARALYZED, amount, updating)
		return P

/mob/living/proc/SetParalyzed(amount, updating = TRUE, ignore_canstun = FALSE) //Sets remaining duration
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_PARALYZE, amount, updating, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(((status_flags & CANKNOCKDOWN) && !HAS_TRAIT(src, TRAIT_STUNIMMUNE)) || ignore_canstun)
		var/datum/status_effect/incapacitating/paralyzed/P = IsParalyzed(FALSE)
		if(amount <= 0)
			if(P)
				qdel(P)
		else
			if(absorb_stun(amount, ignore_canstun))
				return
			if(P)
				P.duration = world.time + amount
			else
				P = apply_status_effect(STATUS_EFFECT_PARALYZED, amount, updating)
		return P

/mob/living/proc/AdjustParalyzed(amount, updating = TRUE, ignore_canstun = FALSE) //Adds to remaining duration
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_PARALYZE, amount, updating, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(((status_flags & CANKNOCKDOWN) && !HAS_TRAIT(src, TRAIT_STUNIMMUNE)) || ignore_canstun)
		if(absorb_stun(amount, ignore_canstun))
			return
		var/datum/status_effect/incapacitating/paralyzed/P = IsParalyzed(FALSE)
		if(P)
			P.duration += amount
		else if(amount > 0)
			P = apply_status_effect(STATUS_EFFECT_PARALYZED, amount, updating)
		return P

/////////////////////////////////// SLEEPING ////////////////////////////////////

/mob/living/proc/IsSleeping() //If we're asleep
	return has_status_effect(STATUS_EFFECT_SLEEPING)

/mob/living/proc/AmountSleeping() //How many deciseconds remain in our sleep
	var/datum/status_effect/incapacitating/sleeping/S = IsSleeping()
	if(S)
		return S.duration - world.time
	return 0

/mob/living/proc/Sleeping(amount, updating = TRUE, ignore_canstun = FALSE) //Can't go below remaining duration
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_SLEEP, amount, updating, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if((!HAS_TRAIT(src, TRAIT_SLEEPIMMUNE)) || ignore_canstun)
		var/datum/status_effect/incapacitating/sleeping/S = IsSleeping()
		if(S)
			S.duration = max(world.time + amount, S.duration)
		else if(amount > 0)
			S = apply_status_effect(STATUS_EFFECT_SLEEPING, amount, updating)
		return S

/mob/living/proc/SetSleeping(amount, updating = TRUE, ignore_canstun = FALSE) //Sets remaining duration
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_SLEEP, amount, updating, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if((!HAS_TRAIT(src, TRAIT_SLEEPIMMUNE)) || ignore_canstun)
		var/datum/status_effect/incapacitating/sleeping/S = IsSleeping()
		if(amount <= 0)
			if(S)
				qdel(S)
		else if(S)
			S.duration = world.time + amount
		else
			S = apply_status_effect(STATUS_EFFECT_SLEEPING, amount, updating)
		return S

/mob/living/proc/AdjustSleeping(amount, updating = TRUE, ignore_canstun = FALSE) //Adds to remaining duration
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_SLEEP, amount, updating, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if((!HAS_TRAIT(src, TRAIT_SLEEPIMMUNE)) || ignore_canstun)
		var/datum/status_effect/incapacitating/sleeping/S = IsSleeping()
		if(S)
			S.duration += amount
		else if(amount > 0)
			S = apply_status_effect(STATUS_EFFECT_SLEEPING, amount, updating)
		return S

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
/mob/living/proc/IsUnconscious() //If we're unconscious
	return has_status_effect(STATUS_EFFECT_UNCONSCIOUS)

/mob/living/proc/AmountUnconscious() //How many deciseconds remain in our unconsciousness
	var/datum/status_effect/incapacitating/unconscious/U = IsUnconscious()
	if(U)
		return U.duration - world.time
	return 0

/mob/living/proc/Unconscious(amount, updating = TRUE, ignore_canstun = FALSE) //Can't go below remaining duration
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_UNCONSCIOUS, amount, updating, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(((status_flags & CANUNCONSCIOUS) && !HAS_TRAIT(src, TRAIT_STUNIMMUNE))  || ignore_canstun)
		var/datum/status_effect/incapacitating/unconscious/U = IsUnconscious()
		if(U)
			U.duration = max(world.time + amount, U.duration)
		else if(amount > 0)
			U = apply_status_effect(STATUS_EFFECT_UNCONSCIOUS, amount, updating)
		return U

/mob/living/proc/SetUnconscious(amount, updating = TRUE, ignore_canstun = FALSE) //Sets remaining duration
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_UNCONSCIOUS, amount, updating, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(((status_flags & CANUNCONSCIOUS) && !HAS_TRAIT(src, TRAIT_STUNIMMUNE)) || ignore_canstun)
		var/datum/status_effect/incapacitating/unconscious/U = IsUnconscious()
		if(amount <= 0)
			if(U)
				qdel(U)
		else if(U)
			U.duration = world.time + amount
		else
			U = apply_status_effect(STATUS_EFFECT_UNCONSCIOUS, amount, updating)
		return U

/mob/living/proc/AdjustUnconscious(amount, updating = TRUE, ignore_canstun = FALSE) //Adds to remaining duration
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_UNCONSCIOUS, amount, updating, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(((status_flags & CANUNCONSCIOUS) && !HAS_TRAIT(src, TRAIT_STUNIMMUNE)) || ignore_canstun)
		var/datum/status_effect/incapacitating/unconscious/U = IsUnconscious()
		if(U)
			U.duration += amount
		else if(amount > 0)
			U = apply_status_effect(STATUS_EFFECT_UNCONSCIOUS, amount, updating)
		return U

//////////////////CONFUSED
/mob/living/proc/IsConfused() //If we're unconscious
	return has_status_effect(STATUS_EFFECT_CONFUSED)

/mob/living/proc/AmountConfused() //How many deciseconds remain in our unconsciousness
	var/datum/status_effect/confused/C = IsConfused()
	if(C)
		return C.duration - world.time
	return 0

/mob/living/proc/Confused(amount, updating = TRUE, ignore_canstun = FALSE) //Can't go below remaining duration
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_CONFUSED, amount, updating, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(((status_flags & CANCONFUSE) && !HAS_TRAIT(src, TRAIT_STUNIMMUNE))  || ignore_canstun)
		var/datum/status_effect/confused/C = IsConfused()
		if(C)
			C.duration = max(world.time + amount, C.duration)
		else if(amount > 0)
			C = apply_status_effect(STATUS_EFFECT_CONFUSED, amount, updating)
		return C

/mob/living/proc/SetConfused(amount, updating = TRUE, ignore_canstun = FALSE) //Sets remaining duration
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_CONFUSED, amount, updating, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(((status_flags & CANCONFUSE) && !HAS_TRAIT(src, TRAIT_STUNIMMUNE)) || ignore_canstun)
		var/datum/status_effect/confused/C = IsConfused()
		if(amount <= 0)
			if(C)
				qdel(C)
		else if(C)
			C.duration = world.time + amount
		else
			C = apply_status_effect(STATUS_EFFECT_CONFUSED, amount, updating)
		return C

/mob/living/proc/AdjustConfused(amount, updating = TRUE, ignore_canstun = FALSE) //Adds to remaining duration
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_CONFUSED, amount, updating, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(((status_flags & CANCONFUSE) && !HAS_TRAIT(src, TRAIT_STUNIMMUNE)) || ignore_canstun)
		var/datum/status_effect/confused/C = IsConfused()
		if(C)
			C.duration += amount
		else if(amount > 0)
			C = apply_status_effect(STATUS_EFFECT_CONFUSED, amount, updating)
		return C

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
					visible_message("<span class='warning'>[src][priority_absorb_key["visible_message"]]</span>", "<span class='boldwarning'>[priority_absorb_key["self_message"]]</span>")
				else if(priority_absorb_key["visible_message"])
					visible_message("<span class='warning'>[src][priority_absorb_key["visible_message"]]</span>")
				else if(priority_absorb_key["self_message"])
					to_chat(src, "<span class='boldwarning'>[priority_absorb_key["self_message"]]</span>")
			priority_absorb_key["stuns_absorbed"] += amount
		return TRUE

/mob/living/proc/set_frozen(freeze = TRUE)
	frozen = freeze
	return TRUE

/mob/living/proc/adjust_drugginess(amount)
	return

/mob/living/proc/set_drugginess(amount)
	return

/mob/living/proc/jitter(amount)
	jitteriness = CLAMP(jitteriness + amount,0, 1000)

/mob/living/proc/dizzy(amount)
	return // For the time being, only carbons get dizzy.

/mob/living/proc/blind_eyes(amount)
	if(amount>0)
		var/old_eye_blind = eye_blind
		eye_blind = max(eye_blind, amount)
		if(!old_eye_blind)
			overlay_fullscreen("blind", /obj/screen/fullscreen/blind)

/mob/living/proc/adjust_blindness(amount)
	if(amount>0)
		var/old_eye_blind = eye_blind
		eye_blind += amount
		if(!old_eye_blind)
			overlay_fullscreen("blind", /obj/screen/fullscreen/blind)
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
			overlay_fullscreen("blind", /obj/screen/fullscreen/blind)
	else if(!eye_blind)
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
	else
		eye_blind = max(eye_blind, 0)
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

/mob/living/proc/update_eye_blur()
	if(!client)
		return
	var/obj/screen/plane_master/floor/OT = locate(/obj/screen/plane_master/floor) in client.screen
	var/obj/screen/plane_master/game_world/GW = locate(/obj/screen/plane_master/game_world) in client.screen
	GW.backdrop(src)
	OT.backdrop(src)

/mob/living/proc/adjust_ear_damage(damage = 0, deaf = 0)
	ear_damage = max(0, ear_damage + damage)
	ear_deaf = max((disabilities & DEAF|| ear_damage >= 100) ? 1 : 0, ear_deaf + deaf)


/mob/living/proc/set_ear_damage(damage = 0, deaf = 0)
	if(!isnull(damage))
		ear_damage = damage
	if(!isnull(deaf))
		ear_deaf = max((disabilities & DEAF|| ear_damage >= 100) ? 1 : 0, deaf)


/mob/living/adjust_drugginess(amount)
	druggy = max(druggy + amount, 0)
	if(druggy)
		overlay_fullscreen("high", /obj/screen/fullscreen/high)
	else
		clear_fullscreen("high")


/mob/living/set_drugginess(amount)
	druggy = max(amount, 0)
	if(druggy)
		overlay_fullscreen("high", /obj/screen/fullscreen/high)
	else
		clear_fullscreen("high")


/mob/living/proc/adjust_bodytemperature(amount, min_temp = 0, max_temp = INFINITY)
	if(bodytemperature < min_temp || bodytemperature > max_temp)
		return
	. = bodytemperature
	bodytemperature = CLAMP(bodytemperature + amount, min_temp, max_temp)


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
