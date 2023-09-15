/mob/living/carbon/xenomorph/generic_evolution_checks()
	if(HAS_TRAIT(src, TRAIT_BANISHED))
		balloon_alert(src, span_warning("You are banished and cannot reach the hivemind."))
		return FALSE
	return ..()

/mob/living/carbon/xenomorph/caste_evolution_checks(new_mob_type, castepick, regression)
	for(var/forbid_info in hive.hive_forbiden_castes)
		if(forbid_info["type_path"] == new_mob_type && forbid_info["is_forbid"])
			balloon_alert(src, "We can't evolve to forbided caste")
			return FALSE
	return ..()

