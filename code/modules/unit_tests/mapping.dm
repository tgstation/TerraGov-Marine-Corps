/// Conveys all log_mapping messages as unit test failures, as they all indicate mapping problems.
/datum/unit_test/log_mapping
	// Happen before all other tests, to make sure we only capture normal mapping logs.
	priority = TEST_PRE

/datum/unit_test/log_mapping/Run()
	// var/static/regex/test_areacoord_regex = regex(@"\(-?\d+,-?\d+,(-?\d+)\)")

	for(var/log_entry in GLOB.unit_test_mapping_logs)
		// Only fail if AREACOORD was conveyed, and it's a ship or ground z-level.
		// This is due to mapping errors don't have coords being impossible to diagnose as a unit test,
		// and various other zlevels frequently intentionally do non-standard things.

		/* hey, this is disabled because we use log_mapping for errors only atm and
		I cant be bothered to make the TG version of areacoord work with ours.
		if you port it make sure to uncomment this

		if(!test_areacoord_regex.Find(log_entry))
			continue
		var/z = text2num(test_areacoord_regex.group[1])
		if(!is_gameplay_level(z))
			continue
		*/
		Fail(log_entry)
