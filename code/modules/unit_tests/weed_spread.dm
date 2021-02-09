/datum/unit_test/weed_spread/Run()
	var/obj/effect/alien/weeds/node/node = new(locate(run_loc_bottom_left.x+1, run_loc_bottom_left.y+1, run_loc_bottom_left.z))
	sleep(60)
	var/found = FALSE
	var/turf/origin = get_turf(node)
	for(var/dir in GLOB.cardinals)
		if(locate(/obj/effect/alien/weeds) in get_step(origin, dir))
			found = TRUE
	TEST_ASSERT(found, "No weeds found in neighbouring tiles after 5 seconds!")
	qdel(node)
	sleep(60)
	var/notfound = FALSE
	for(var/dir in GLOB.cardinals)
		if(!locate(/obj/effect/alien/weeds) in get_step(origin, dir))
			notfound = TRUE
			break
	TEST_ASSERT(notfound, "No weeds were removed 5 seconds after node was deleted!")

