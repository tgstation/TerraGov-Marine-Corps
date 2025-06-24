/mob/living/carbon/Losebreath(amount, forced = FALSE)
	losebreath = max(amount, losebreath)

/mob/living/carbon/adjust_Losebreath(amount, forced = FALSE)
	losebreath = max(losebreath + amount, 0)

/mob/living/carbon/set_Losebreath(amount, forced = FALSE)
	losebreath = max(amount, 0)

/mob/living/carbon/proc/adjust_nutrition(amount)
	. = nutrition
	nutrition = max(nutrition + amount, 0)
	adjust_nutrition_speed(.)

/mob/living/carbon/proc/set_nutrition(amount)
	. = nutrition
	nutrition = max(amount, 0)
	adjust_nutrition_speed(.)

/mob/living/carbon/proc/adjust_nutrition_speed(old_nutrition)
	switch(nutrition)
		if(0 to NUTRITION_HUNGRY)
			add_movespeed_modifier(MOVESPEED_ID_HUNGRY, TRUE, 0, NONE, TRUE, round(1.5 - (nutrition / 250), 0.1)) //From 0.5 to 1.5
			if(nutrition < NUTRITION_HUNGRY && nutrition > NUTRITION_STARVING)
				throw_alert(ALERT_NUTRITION, /atom/movable/screen/alert/hungry)
			else if(nutrition < NUTRITION_STARVING)
				throw_alert(ALERT_NUTRITION, /atom/movable/screen/alert/starving)
		if(NUTRITION_HUNGRY to NUTRITION_OVERFED)
			clear_alert(ALERT_NUTRITION)
			remove_movespeed_modifier(MOVESPEED_ID_HUNGRY)
		if(NUTRITION_OVERFED to INFINITY) //Overeating
			if(old_nutrition > NUTRITION_OVERFED)
				return
			add_movespeed_modifier(MOVESPEED_ID_HUNGRY, TRUE, 0, NONE, TRUE, 0.5)
			throw_alert(ALERT_NUTRITION, /atom/movable/screen/alert/stuffed)

/mob/living/carbon/handle_fire()
	. = ..()
	if(.)
		clear_alert(ALERT_FIRE)
		return
	throw_alert(ALERT_FIRE, /atom/movable/screen/alert/fire)
