/datum/unit_test/weed_ability

/datum/unit_test/weed_ability/Run()
	var/mob/living/carbon/xenomorph/drone/drone = new(run_loc_floor_bottom_left)
	var/datum/action/ability/activable/xeno/plant_weeds/weed = drone.actions_by_path[/datum/action/ability/activable/xeno/plant_weeds]
	if(!weed.can_use_action())
		Fail("Drone could not activate weed ability!")

	weed.action_activate()
	if(!(locate(/obj/alien/weeds/node) in drone.loc))
		Fail("Weed action_activate did not spawn weeds under a drone!")
	drone.plasma_stored = 0
	if(weed.can_use_action())
		Fail("Drone succeded in using weed ability while having no plasma!")

