/datum/unit_test/xeno_logical_scaling/Run()
	var/list/by_xeno = list()
	for(var/i in subtypesof(/datum/xeno_caste))
		var/datum/xeno_caste/caste = i
		var/typepath = initial(caste.caste_type_path)
		var/upgrade = initial(caste.upgrade)
		if(isnull(typepath))
			Fail("[i] has a null caste_type_path")
			continue
		if(isnull(upgrade))
			Fail("[i] has a null upgrade")
			continue
		if(!("[typepath]" in by_xeno))
			by_xeno["[typepath]"] = list()
		by_xeno["[typepath]"]["[upgrade]"] = caste

	for(var/castepath in by_xeno)
		var/xeno_path = by_xeno[castepath]
		// Each of these values should get larger or stay the same each evolution
		var/list/greater_test_vars = list(
			"max_health" = 0,
			"melee_damage" = 0,
			"tackle_damage" = 0,
			"plasma_max" = 0,
			"plasma_gain" = 0,
			"upgrade_threshold" = 0
		)
		// Each of these values should get smaller or stay the same each evolution
		var/list/lesser_test_vars = list(
			"speed" = 99,
		)
		for(var/upgradepath in by_xeno[xeno_path])
			var/mob/living/carbon/xenomorph/xeno_mob = new xeno_path[upgradepath]
			// Check for values that are should grow with each level
			for(var/stat in greater_test_vars)
				var/new_value = xeno_mob.vars[stat]
				if(new_value < greater_test_vars[stat])
					Fail("Invalid stats on [xeno_path]. It's [stat]@[upgradepath] has [new_value] compared to base value of [greater_test_vars[stat]] (expected greater)")
				greater_test_vars[stat] = new_value
				world.log << greater_test_vars[stat]

			// Test for values that are should shrink with each level
			for(var/stat in lesser_test_vars)
				var/new_value =  xeno_mob.vars[stat]
				if(new_value > lesser_test_vars[stat])
					Fail("Invalid stats on [xeno_path]. It's [stat]@[XENO_UPGRADE_ZERO] has [new_value] compared to base value of [lesser_test_vars[stat]] (expected lower)")
				lesser_test_vars[stat] = new_value
