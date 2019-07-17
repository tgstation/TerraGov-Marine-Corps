/mob/living/proc/stun(amount)
	if(status_flags & CANSTUN)
		stunned = max(max(stunned, amount), 0) //can't go below 0, getting a low amount of stun doesn't lower your current stun
		update_canmove()


/mob/living/proc/set_stunned(amount) //if you REALLY need to set stun to a set amount without the whole "can't go below current stunned"
	if(status_flags & CANSTUN)
		stunned = max(amount, 0)
		update_canmove()


/mob/living/proc/adjust_stunned(amount)
	if(status_flags & CANSTUN)
		stunned = max(stunned + amount,0)
		update_canmove()


/mob/living/proc/knock_down(amount, force)
	if((status_flags & CANKNOCKDOWN) || force)
		knocked_down = max(max(knocked_down,amount),0)
		update_canmove()	//updates lying, canmove and icons


/mob/living/proc/set_knocked_down(amount)
	if(status_flags & CANKNOCKDOWN)
		knocked_down = max(amount,0)
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

/mob/living/proc/update_tint()
	return

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


/mob/living/proc/setEarDamage(damage, deaf)
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


/mob/living/proc/adjust_bodytemperature(amount,min_temp=0,max_temp=INFINITY)
	if(bodytemperature >= min_temp && bodytemperature <= max_temp)
		bodytemperature = CLAMP(bodytemperature + amount,min_temp,max_temp)