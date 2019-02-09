/mob/living/proc/update_tint()
	return

/mob/living/proc/blind_eyes(amount, forced = FALSE)
	if(has_extravision() && !forced)
		return
	if(amount>0)
		var/old_eye_blind = eye_blind
		eye_blind = max(eye_blind, amount)
		if(!old_eye_blind)
			overlay_fullscreen("blind", /obj/screen/fullscreen/blind)

/mob/living/proc/adjust_blindness(amount, forced = FALSE)
	if(has_extravision() && !forced)
		return
	if(amount>0)
		var/old_eye_blind = eye_blind
		eye_blind += amount
		if(!old_eye_blind)
			overlay_fullscreen("blind", /obj/screen/fullscreen/blind)
	else if(eye_blind)
		var/blind_minimum = 0
		if(stat != CONSCIOUS)
			blind_minimum = 1
		if(!has_vision())
			blind_minimum = 1
		eye_blind = max(eye_blind+amount, blind_minimum)
		if(!eye_blind)
			clear_fullscreen("blind")

/mob/living/proc/set_blindness(amount, forced = FALSE)
	if(has_extravision() && !forced)
		return
	if(amount>0)
		var/old_eye_blind = eye_blind
		eye_blind = amount
		if(client && !old_eye_blind)
			overlay_fullscreen("blind", /obj/screen/fullscreen/blind)
	else if(eye_blind)
		var/blind_minimum = 0
		if(stat != CONSCIOUS)
			blind_minimum = 1
		if(!has_vision())
			blind_minimum = 1
		eye_blind = blind_minimum
		if(!eye_blind)
			clear_fullscreen("blind")

/mob/living/proc/blur_eyes(amount, forced = FALSE)
	if(has_extravision() && !forced)
		return
	if(amount>0)
		var/old_eye_blurry = eye_blurry
		eye_blurry = max(amount, eye_blurry)
		if(!old_eye_blurry)
			overlay_fullscreen("blurry", /obj/screen/fullscreen/blurry)

/mob/living/proc/adjust_blurriness(amount, forced = FALSE)
	if(has_extravision() && !forced)
		return
	var/old_eye_blurry = eye_blurry
	eye_blurry = max(eye_blurry+amount, 0)
	if(amount>0)
		if(!old_eye_blurry)
			overlay_fullscreen("blurry", /obj/screen/fullscreen/blurry)
	else if(old_eye_blurry && !eye_blurry)
		clear_fullscreen("blurry")

/mob/living/proc/set_blurriness(amount, forced = FALSE)
	if(has_extravision() && !forced)
		return
	var/old_eye_blurry = eye_blurry
	eye_blurry = max(amount, 0)
	if(amount>0)
		if(!old_eye_blurry)
			overlay_fullscreen("blurry", /obj/screen/fullscreen/blurry)
	else if(old_eye_blurry)
		clear_fullscreen("blurry")

////////////////////////////////////NUTRITION///////////////////////////////////////

/mob/living/proc/adjust_nutrition(amount, min_nutri = 0, max_nutri = NUTRITION_LEVEL_MAX, forced = FALSE)
	nutrition = max(0, nutrition)
	if(ISINRANGE(nutrition, min_nutri,max_nutri))
		nutrition = CLAMP(nutrition + amount, min_nutri, max_nutri)

/mob/living/proc/set_nutrition(amount, forced = FALSE)
	nutrition = CLAMP(amount, 0, NUTRITION_LEVEL_MAX)

/mob/living/proc/adjust_overeating(amount, min_binge = 0, max_binge = OVEREATING_LEVEL_MAX, forced = FALSE)
	overeatduration = max(0, overeatduration)
	if(ISINRANGE(overeatduration, min_binge, max_binge))
		overeatduration = CLAMP(nutrition + amount, min_binge, max_binge)

/mob/living/proc/set_overeating(amount, forced = FALSE)
	overeatduration = CLAMP(amount, 0, OVEREATING_LEVEL_MAX)