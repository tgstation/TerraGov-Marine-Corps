/datum/unit_test/xenoaccuracy/Run()
	for(var/accuracy_malus in subtypesof(/datum/xeno_caste))
		if(accuracy_malus >= XENO_DEFAULT_ACCURACY)
			Fail("A xeno accuracy malus of 70 or over was detected, negatives cannot be used in accuracy calculations.")
