/datum/unit_test/spawn_xenos/Run()
	var/locs = block(run_loc_bottom_left, run_loc_top_right)

	var/list/mob/living/carbon/xenomorph/xenos = list()
	for(var/t in GLOB.xeno_caste_datums)
		xenos += new t(pick(locs))

	sleep(10)
	
	for(var/i in xenos)
		var/mob/living/carbon/xenomorph/X = i
		X.upgrade_xeno(1)

	sleep(10)
	
	for(var/i in xenos)
		var/mob/living/carbon/xenomorph/X = i
		X.upgrade_xeno(2)

	sleep(10)
	
	for(var/i in xenos)
		var/mob/living/carbon/xenomorph/X = i
		X.upgrade_xeno(3)

	sleep(10)
