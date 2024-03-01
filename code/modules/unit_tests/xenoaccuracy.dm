/datum/unit_test/xenoaccuracy

/datum/unit_test/xenoaccuracy/Run()
	for(var/datum/xeno_caste/caste AS in subtypesof(/datum/xeno_caste))
		if(initial(caste.accuracy_malus) >= XENO_DEFAULT_ACCURACY)
			Fail("A xeno accuracy malus of 70 or over was detected, negatives cannot be used in accuracy calculations.")
