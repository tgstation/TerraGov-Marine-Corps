GLOBAL_LIST_EMPTY(human_genitals_cache)

/mob/living/carbon/human/proc/update_genitals()
	remove_overlay(GENITAL_LAYER)
	if(!species?.has_genital_selection)
		return

	if(wear_suit || w_uniform)
		return

	var/datum/ethnicity/ethnodatum = GLOB.ethnicities_list[ethnicity]
	var/ethnoicon = "western"
	var/list/genilist = list()
	if(istype(ethnodatum))
		ethnoicon = ethnodatum.icon_name

	if(ass)
		var/assicon = "[ethnoicon]_ass"
		if(!GLOB.human_genitals_cache[assicon])
			GLOB.human_genitals_cache[assicon] = icon('icons/mob/human_races/r_human_genitals.dmi', "[ethnoicon]_ass")
		genilist += GLOB.human_genitals_cache[assicon]

	if(boobs)
		var/boobicon = "[ethnoicon]_[boobs]"
		if(!GLOB.human_genitals_cache[boobicon])
			GLOB.human_genitals_cache[boobicon] = icon('icons/mob/human_races/r_human_genitals.dmi', "[ethnoicon]_[boobs]")
		genilist += GLOB.human_genitals_cache[boobicon]

	if(cock)
		var/cockicon = "[ethnoicon]_cock"
		if(!GLOB.human_genitals_cache[cockicon])
			GLOB.human_genitals_cache[cockicon] = icon('icons/mob/human_races/r_human_genitals.dmi', "[ethnoicon]_cock")
		genilist += GLOB.human_genitals_cache[cockicon]

	overlays_standing[GENITAL_LAYER] = genilist
	apply_overlay(GENITAL_LAYER)

/mob/living/carbon/human/update_inv_w_uniform()
	. = ..()
	update_genitals()

/mob/living/carbon/human/update_inv_wear_suit()
	. = ..()
	update_genitals()

/mob/living/carbon/human/update_body(update_icons, force_cache_update)
	. = ..()
	update_genitals()
