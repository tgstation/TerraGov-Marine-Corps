/mob/living/carbon/Losebreath(amount, forced = FALSE)
	losebreath = max(amount, losebreath)

/mob/living/carbon/adjust_Losebreath(amount, forced = FALSE)
	losebreath = max(losebreath + amount, 0)

/mob/living/carbon/set_Losebreath(amount, forced = FALSE)
	losebreath = max(amount, 0)

/mob/living/carbon/proc/set_stagger(amount)
	if(amount > 0 && HAS_TRAIT(src, TRAIT_STAGGERIMMUNE))
		return
	stagger = max(amount, 0)

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
		if(0 to NUTRITION_HUNGRY) //Level where a yellow food pip shows up, aka hunger level 3 at 250 nutrition and under
			add_movespeed_modifier(MOVESPEED_ID_HUNGRY, TRUE, 0, NONE, TRUE, round(1.5 - (nutrition / 250), 0.1)) //From 0.5 to 1.5
		if(NUTRITION_HUNGRY to NUTRITION_OVERFED)
			switch(old_nutrition)
				if(NUTRITION_HUNGRY to NUTRITION_OVERFED)
					return
			remove_movespeed_modifier(MOVESPEED_ID_HUNGRY)
		if(NUTRITION_OVERFED to INFINITY) //Overeating
			if(old_nutrition > NUTRITION_OVERFED)
				return
