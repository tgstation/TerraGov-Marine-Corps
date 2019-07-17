/mob/living/carbon/Losebreath(amount, forced = FALSE)
	losebreath = max(amount, losebreath)

/mob/living/carbon/adjust_Losebreath(amount, forced = FALSE)
	losebreath = max(losebreath + amount, 0)

/mob/living/carbon/set_Losebreath(amount, forced = FALSE)
	losebreath = max(amount, 0)

/mob/living/carbon/proc/set_stagger(amount)
	stagger = max(amount, 0)

/mob/living/carbon/proc/set_slowdown(amount)
	slowdown = amount