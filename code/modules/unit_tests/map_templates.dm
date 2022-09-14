/datum/unit_test/map_templates
	///list of exemptions for parent type map templates that we will NEVER EVER SPAWN
	var/list/exceptions = list(
		/datum/map_template/shuttle,
		/datum/map_template/modular,
		/datum/map_template/modular/lv624,
		/datum/map_template/modular/prison,
		/datum/map_template/modular/bigred,
		/datum/map_template/modular/end_of_round,
	)

/datum/unit_test/map_templates/Run()
	for(var/path AS in subtypesof(/datum/map_template)-exceptions)
		var/datum/map_template/instance = new path
		if(!fexists(instance.mappath))
			TEST_FAIL("[path] has an invalid mappath ([instance.mappath])")
