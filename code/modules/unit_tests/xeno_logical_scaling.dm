/datum/unit_test/xeno_logical_scaling/Run()
	var/list/by_xeno = list()
	for(var/i in subtypesof(/datum/xeno_caste))
		var/datum/xeno_caste/caste = i
		var/typepath = initial(caste.caste_type_path)
		var/upgrade = initial(caste.upgrade)
		if(isnull(typepath))
			Fail("[i] has a null caste_type_path")
			continue
		if(upgrade == "basetype")
			continue
		if(isnull(upgrade))
			Fail("[i] has a null upgrade")
			continue
		if(!("[typepath]" in by_xeno))
			by_xeno["[typepath]"] = list()
		by_xeno["[typepath]"] += list("[upgrade]" = caste)
	var/datum/xeno_caste/caste
	for(var/xenopath in by_xeno)
		var/list/mob_data = by_xeno[xenopath]
		// Each of these values should get larger or stay the same each evolution
		var/list/greater_test_vars = list(
			"max_health" = 0,
			"melee_damage" = 0,
			"plasma_max" = 0,
			"plasma_gain" = 0,
		)
		// Each of these values should get smaller or stay the same each evolution
		var/list/lesser_test_vars = list(
			"speed" = 99,
		)
		for(var/upgradepath in mob_data)
			var/typepath = mob_data[upgradepath]
			caste = new typepath
			// Check for values that are should grow with each level
			for(var/stat in greater_test_vars)
				if(caste.vars[stat] < greater_test_vars[stat])
					Fail("Invalid stats on [xenopath]. It's [stat]@[upgradepath] has [caste.vars[stat]] compared to base value of [greater_test_vars[stat]] (expected greater)")
				greater_test_vars[stat] = caste.vars[stat]
			// Test for values that are should shrink with each level
			for(var/stat in lesser_test_vars)
				if(caste.vars[stat] > lesser_test_vars[stat])
					Fail("Invalid stats on [xenopath]. It's [stat]@[XENO_UPGRADE_NORMAL] has [caste.vars[stat]] compared to base value of [lesser_test_vars[stat]] (expected lower)")
				lesser_test_vars[stat] = caste.vars[stat]
