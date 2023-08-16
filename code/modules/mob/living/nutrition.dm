//This file handles most Nutrition stuff.
/mob/living/proc/handle_nutrition()
	return


// Takes care blood loss and regeneration
/mob/living/carbon/human/handle_nutrition()
	if(species.species_flags & NO_BLOOD)
		return

	if(stat != DEAD && bodytemperature >= 170)	//Dead or cryosleep people do not pump the blood.
		if(nutrition > NUTRITION_MAXIMUM) //Warning: contents under pressure.
			var/spare_nutrition = nutrition - ((NUTRITION_MAXIMUM + NUTRITION_OVERFED) / 2 + 40) //Knock you to the midpoint between max and normal to not spam.
			switch(spare_nutrition)
				if(0 to 30) //20 is the functional minimum due to midpoint calc
					to_chat(src, span_notice("Your overfilled stomach regurgitates food."))
					do_vomit()
				if(30 to 100)
					to_chat(src, span_notice("Spare food gushes out of mouth. Must've had too much."))
					do_vomit()
				if(100 to INFINITY)
					visible_message(span_notice("A violent stream of puke shoots out of [src]'s mouth. How'd [p_they()] do that?"), \
						span_notice("A violent flood of puke spews out of your mouth. You feel like your stomach isn't going to burst anymore."))
					do_vomit()

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
		if(NUTRITION_HUNGRY to INFINITY)
			switch(old_nutrition)
				if(NUTRITION_HUNGRY to NUTRITION_OVERFED)
					return
			remove_movespeed_modifier(MOVESPEED_ID_HUNGRY)
