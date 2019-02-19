/mob/living/carbon/proc/Losebreath(amount, forced = FALSE)
	losebreath = max(amount, losebreath)

/mob/living/carbon/proc/adjust_Losebreath(amount, forced = FALSE)
	losebreath = max(losebreath + amount, 0)

/mob/living/carbon/proc/set_Losebreath(amount, forced = FALSE)
	losebreath = max(amount, 0)