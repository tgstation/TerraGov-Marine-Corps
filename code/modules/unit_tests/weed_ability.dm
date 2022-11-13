/datum/unit_test/weed_ability
	var/turf/open/open_tile
	var/turf/claimed_tile

/datum/unit_test/weed_ability/New()
	..()

	//create a tile so we can drop the weeds
	claimed_tile = run_loc_bottom_left
	open_tile = new(locate(run_loc_bottom_left.x, run_loc_bottom_left.y, run_loc_bottom_left.z))


/datum/unit_test/weed_ability/Destroy()
	open_tile.copyTurf(claimed_tile)
	return ..()

/datum/unit_test/weed_ability/Run()
	var/mob/living/carbon/xenomorph/drone/drone = new(open_tile)
	var/datum/action/xeno_action/activable/plant_weeds/weed = drone.actions_by_path[/datum/action/xeno_action/activable/plant_weeds]
	if(!weed.can_use_action())
		Fail("Drone could not activate weed ability!")

	weed.action_activate()
	if(!(locate(/obj/alien/weeds/node) in drone.loc))
		Fail("Weed action_activate did not spawn weeds under a drone!")
	drone.plasma_stored = 0
	if(weed.can_use_action())
		Fail("Drone succeded in using weed ability while having no plasma!")

