/mob/living/carbon/human/Stun(amount)
	if(!(HULK in mutations))
		return ..()

/mob/living/carbon/human/KnockDown(amount)
	if(!(HULK in mutations))
		return ..()

/mob/living/carbon/human/KnockOut(amount)
	if(!(HULK in mutations))
		return ..()

/mob/living/carbon/human/adjust_nutrition(amount, min_nutri = 0, max_nutri = NUTRITION_LEVEL_MAX, forced = FALSE)
	if(!(species.species_flags & NO_HUNGER) || forced)
		return ..()

/mob/living/carbon/human/set_nutrition(amount, forced = FALSE)
	if(!(species.species_flags & NO_HUNGER) || forced)
		return ..()

/mob/living/carbon/human/adjust_overeating(amount, min_binge = 0, max_binge = OVEREATING_LEVEL_MAX, forced = FALSE)
	if(!(species.species_flags & NO_HUNGER) || forced)
		return ..()

/mob/living/carbon/human/set_overeating(amount, forced = FALSE)
	if(!(species.species_flags & NO_HUNGER) || forced)
		return ..()

/mob/living/carbon/human/Losebreath(amount, forced = FALSE)
	if(!(species.species_flags & NO_BREATHE) || forced)
		return ..()

/mob/living/carbon/human/adjust_Losebreath(amount, forced = FALSE)
	if(!(species.species_flags & NO_BREATHE) || forced)
		return ..()

/mob/living/carbon/human/set_Losebreath(amount, forced = FALSE)
	if(!(species.species_flags & NO_BREATHE) || forced)
		return ..()
