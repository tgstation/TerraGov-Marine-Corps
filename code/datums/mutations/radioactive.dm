/datum/mutation/human/radioactive
	name = "Radioactivity"
	desc = ""
	quality = NEGATIVE
	text_gain_indication = "<span class='warning'>I can feel it in your bones!</span>"
	time_coeff = 5
	instability = 5
	difficulty = 8
	power_coeff = 1


/datum/mutation/human/radioactive/on_life()
	radiation_pulse(owner, 20 * GET_MUTATION_POWER(src))

/datum/mutation/human/radioactive/New(class_ = MUT_OTHER, timer, datum/mutation/human/copymut)
	..()
	if(!(type in visual_indicators))
		visual_indicators[type] = list(mutable_appearance('icons/effects/genetics.dmi', "radiation", -MUTATIONS_LAYER))

/datum/mutation/human/radioactive/get_visual_indicator()
	return visual_indicators[type][1]
