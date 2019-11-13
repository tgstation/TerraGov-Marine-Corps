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



/mob/living/proc/knock_down(amount, force)
	if((status_flags & CANKNOCKDOWN) || force)
		knocked_down = max(max(knocked_down,amount),0)
		update_canmove()	//updates lying, canmove and icons


/mob/living/proc/set_knocked_down(amount, update = TRUE)
	if(!(status_flags & CANKNOCKDOWN))
		return
	knocked_down = max(amount, 0)
	if(update)
		update_canmove()	//updates lying, canmove and icons


/mob/living/proc/adjust_knocked_down(amount)
	if(status_flags & CANKNOCKDOWN)
		knocked_down = max(knocked_down + amount,0)
		update_canmove()	//updates lying, canmove and icons


/mob/living/proc/knock_out(amount)
	if(status_flags & CANKNOCKOUT)
		knocked_out = max(max(knocked_out,amount),0)
		update_canmove()
	return

/mob/living/proc/set_knocked_out(amount)
	if(status_flags & CANKNOCKOUT)
		knocked_out = max(amount,0)
		update_canmove()
	return

/mob/living/proc/adjust_knockedout(amount)
	if(status_flags & CANKNOCKOUT)
		knocked_out = max(knocked_out + amount,0)
		update_canmove()
	return

/mob/living/proc/sleeping(amount)
	sleeping = max(max(sleeping,amount),0)
	return

/mob/living/proc/set_sleeping(amount)
	sleeping = max(amount,0)
	return

/mob/living/proc/adjust_sleeping(amount)
	sleeping = max(sleeping + amount,0)
	return

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
