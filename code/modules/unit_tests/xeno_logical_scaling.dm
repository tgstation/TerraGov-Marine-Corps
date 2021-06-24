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

	for(var/xenopath in by_xeno)
		var/list/mob/living/carbon/xenomorph/mob_data = by_xeno[xenopath]
		// Each of these values should get larger or stay the same each evolution
		var/list/greater_test_vars = list(
			"max_health" = 0,
			"melee_damage" = 0,
			"plasma_max" = 0,
			"plasma_gain" = 0,
			"upgrade_threshold" = 0
		)
		// Each of these values should get smaller or stay the same each evolution
		var/list/lesser_test_vars = list(
			"speed" = 99,
		)

		// Check for values that are should grow with each level
		for(var/stat in greater_test_vars)
			var/current_value = greater_test_vars[stat]
			var/new_value = initial(mob_data[XENO_UPGRADE_ZERO].vars[stat])
			if(new_value < current_value)
				Fail("Invalid stats on [xenopath]. It's [stat]@[XENO_UPGRADE_ZERO] has [new_value] compared to base value of [current_value] (expected greater)")
			current_value = new_value

			for(var/upgrade in list(XENO_UPGRADE_ONE, XENO_UPGRADE_TWO, XENO_UPGRADE_THREE))
				// We need to ignore upgrade_threshold on the last tier, since its never set
				if(upgrade == XENO_UPGRADE_THREE && stat == "upgrade_threshold")
					continue

				new_value = initial(mob_data[upgrade].vars[stat])
				if(new_value < current_value)
					Fail("Invalid stats on [xenopath]. It's [stat]@[upgrade] has [new_value] compared to previous [current_value] (expected greater)")
				current_value = new_value

		// Test for values that are should shrink with each level
		for(var/stat in lesser_test_vars)
			var/current_value = lesser_test_vars[stat]
			var/new_value = initial(mob_data[XENO_UPGRADE_ZERO].vars[stat])
			if(new_value > current_value)
				Fail("Invalid stats on [xenopath]. It's [stat]@[XENO_UPGRADE_ZERO] has [new_value] compared to base value of [current_value] (expected lower)")
			current_value = new_value

			for(var/upgrade in list(XENO_UPGRADE_ONE, XENO_UPGRADE_TWO, XENO_UPGRADE_THREE))
				new_value = initial(mob_data[upgrade].vars[stat])
				if(new_value > current_value)
					Fail("Invalid stats on [xenopath]. It's [stat]@[upgrade] has [new_value] compared to previous [current_value] (expected lower)")
				current_value = new_value
