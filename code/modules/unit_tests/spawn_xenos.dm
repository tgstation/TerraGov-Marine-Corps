/datum/unit_test/spawn_xenos/Run()
	var/list/mob/living/carbon/xenomorph/xenos = list()
	GLOB.xeno_stat_multiplicator_buff = 1
	for(var/xeno_type in GLOB.xeno_caste_datums)
		xenos += allocate(xeno_type)

	sleep(1 SECONDS)

	for(var/i in xenos)
		var/mob/living/carbon/xenomorph/X = i
		X.upgrade_xeno(X.upgrade_next())

	sleep(1 SECONDS)
