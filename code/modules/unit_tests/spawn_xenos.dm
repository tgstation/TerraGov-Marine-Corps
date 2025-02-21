/datum/unit_test/spawn_xenos/Run()
	var/list/mob/living/carbon/xenomorph/xenos = list()
	GLOB.xeno_stat_multiplicator_buff = 1
	for(var/castetype in GLOB.xeno_caste_datums)
		var/xeno_type = GLOB.xeno_caste_datums[castetype][XENO_UPGRADE_BASETYPE].caste_type_path
		xenos += allocate(xeno_type)

	sleep(1 SECONDS)

	for(var/mob/living/carbon/xenomorph/X AS in xenos)
		X.upgrade_xeno(X.upgrade_next())

	sleep(1 SECONDS)
