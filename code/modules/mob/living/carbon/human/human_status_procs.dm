
/mob/living/carbon/human/Stun(amount)
	if(HULK in mutations)	return
	if (isYautja(src)) amount *= 0.5
	..()

/mob/living/carbon/human/KnockDown(amount)
	if(HULK in mutations)	return
	if (isYautja(src)) amount *= 0.5
	..()

/mob/living/carbon/human/KnockOut(amount)
	if(HULK in mutations)	return
	if (isYautja(src)) amount *= 0.5
	..()