/mob/living/carbon/human/blind_eyes(amount, forced = FALSE)
	if(!forced)
		if(has_vision() && !has_eyes() && stat == CONSCIOUS)
			set_blindness(0, TRUE)
	return ..()

/mob/living/carbon/human/adjust_blindness(amount, forced = FALSE)
	if(!forced)
		if(has_vision() && !has_eyes() && stat == CONSCIOUS)
			set_blindness(0, TRUE)
	return ..()

/mob/living/carbon/human/set_blindness(amount, forced = FALSE)
	if(!forced)
		if(has_vision() && !has_eyes() && stat == CONSCIOUS)
			return
	return ..()

/mob/living/carbon/human/blur_eyes(amount, forced = FALSE)
	if(!forced)
		if(has_vision() && !has_eyes() && stat == CONSCIOUS)
			set_blurriness(0, TRUE)
	return ..()

/mob/living/carbon/human/adjust_blurriness(amount, forced = FALSE)
	if(!forced)
		if(has_vision() && !has_eyes() && stat == CONSCIOUS)
			set_blurriness(0, TRUE)
	return ..()

/mob/living/carbon/human/set_blurriness(amount, forced = FALSE)
	if(!forced)
		if(has_vision() && !has_eyes() && stat == CONSCIOUS)
			return
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

/mob/living/carbon/human/vomit()
	if(species.species_flags & IS_SYNTHETIC)
		return //Machines don't throw up.
	return ..()