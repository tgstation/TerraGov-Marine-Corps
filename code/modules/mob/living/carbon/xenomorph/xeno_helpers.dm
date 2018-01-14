


/mob/living/carbon/Xenomorph/can_ventcrawl()
	return (mob_size != MOB_SIZE_BIG)

/mob/living/carbon/Xenomorph/ventcrawl_carry()
	return 1


/mob/living/carbon/Xenomorph/can_inject()
	return FALSE




//These don't do much currently. Or anything? Only around for legacy code.
/mob/living/carbon/Xenomorph/is_mob_restrained()
	return 0
