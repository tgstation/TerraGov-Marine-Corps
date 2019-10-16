/mob/living/carbon/human/proc/handle_pulse()
	if(species && species.species_flags & NO_BLOOD)
		return PULSE_NONE //No blood, no pulse.

	if(stat == DEAD)
		return PULSE_NONE //That's it, you're dead, nothing can influence your pulse

	. = PULSE_NORM

	if(status_flags & FAKEDEATH)
		. = PULSE_NONE		//pretend that we're dead. unlike actual death, can be inflienced by meds

	else if(round(blood_volume) <= BLOOD_VOLUME_BAD) //How much blood do we have
		. = PULSE_THREADY	//not enough :(

	//Handles different chems' influence on pulse
	for(var/i in reagents.reagent_list)
		var/datum/reagent/R = i
		if(R.trait_flags & HEARTSTOPPER) //To avoid using fakedeath
			. = PULSE_NONE
			break
		if(R.trait_flags & CHEARTSTOPPER && (R.volume >= R.overdose_threshold)) //Conditional heart-stoppage
			. = PULSE_NONE
			break
		if(R.trait_flags & BRADYCARDICS && (. <= PULSE_THREADY && . >= PULSE_NORM))
			.--
		if(R.trait_flags & TACHYCARDIC && (. <= PULSE_FAST && . >= PULSE_NONE))
			.++
