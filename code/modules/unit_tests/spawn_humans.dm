/datum/unit_test/spawn_humans/Run()
	var/locs = block(run_loc_bottom_left, run_loc_top_right)

	var/list/humans = list()

	for(var/I in 1 to 5)
		var/mob/living/carbon/human/H = new /mob/living/carbon/human(pick(locs))
		humans += H

	sleep(50)

	for(var/i in humans)
		qdel(i)

	sleep(10)
