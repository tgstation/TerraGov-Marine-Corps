/mob/living/carbon/Losebreath(amount, forced = FALSE)
	losebreath = max(amount, losebreath)

/mob/living/carbon/adjust_Losebreath(amount, forced = FALSE)
	losebreath = max(losebreath + amount, 0)

/mob/living/carbon/set_Losebreath(amount, forced = FALSE)
	losebreath = max(amount, 0)

/mob/living/carbon/proc/set_stagger(amount)
	stagger = max(amount, 0)


/mob/living/carbon/proc/set_slowdown(amount)
	if(slowdown == amount)
		return
	slowdown = amount
	if(slowdown)
		add_movespeed_modifier(MOVESPEED_ID_STAGGERSTUN, TRUE, 0, NONE, TRUE, slowdown)
		return
	remove_movespeed_modifier(MOVESPEED_ID_STAGGERSTUN)

/mob/living/carbon/proc/adjust_slowdown(amount)
	if(amount > 0)
		set_slowdown(max(slowdown, amount)) //Slowdown overlaps rather than stacking.
	else
		set_slowdown(max(slowdown + amount, 0))
	return slowdown

/mob/living/carbon/add_slowdown(amount)
	adjust_slowdown(amount * STANDARD_SLOWDOWN_REGEN)

/mob/living/carbon/xenomorph/add_slowdown(amount)
	if(is_charging >= CHARGE_ON) //If we're charging we're immune to slowdown.
		return
	adjust_slowdown(amount * XENO_SLOWDOWN_REGEN)


/mob/living/carbon/proc/adjust_nutrition(amount)
	. = nutrition
	nutrition = max(nutrition + amount, 0)
	adjust_nutrition_speed(nutrition, .)

/mob/living/carbon/proc/set_nutrition(amount)
	. = nutrition
	nutrition = max(amount, 0)
	adjust_nutrition_speed(.)

/mob/living/carbon/proc/adjust_nutrition_speed(old_nutrition)
	switch(nutrition)
		if(0 to 250) //Level where a yellow food pip shows up, aka hunger level 3 at 250 nutrition and under
			if(old_nutrition <= 250)
				return
			add_movespeed_modifier(MOVESPEED_ID_HUNGRY, TRUE, 0, NONE, TRUE, round(1.5 - (nutrition / 250), 0.1)) //From 0.5 to 1.5
		if(250 to 400)
			if(old_nutrition > 250 || old_nutrition <= 400)
				return
			remove_movespeed_modifier(MOVESPEED_ID_HUNGRY)
		if(400 to INFINITY) //Overeating
			if(old_nutrition > 400)
				return
			add_movespeed_modifier(MOVESPEED_ID_HUNGRY, TRUE, 0, NONE, TRUE, 0.5)

/mob/living/carbon/proc/set_nutrition_speed()
	switch(nutrition)
		if(0 to 250)
			add_movespeed_modifier(MOVESPEED_ID_HUNGRY, TRUE, 0, NONE, TRUE, round(1.5 - (nutrition / 250), 0.1)) //From 0.5 to 1.5
		if(250 to 400) //400 is the threshold before overeating.
			return
		if(400 to INFINITY)
			add_movespeed_modifier(MOVESPEED_ID_HUNGRY, TRUE, 0, NONE, TRUE, 0.5)
