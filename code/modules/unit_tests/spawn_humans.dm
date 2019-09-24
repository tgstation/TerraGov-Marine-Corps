/datum/unit_test/spawn_humans/Run()
	var/locs = block(run_loc_bottom_left, run_loc_top_right)

	var/list/outfits_to_test = list(
		/datum/outfit/job/mercenaries/heavy,
		/datum/outfit/job/mercenaries/miner,
		/datum/outfit/job/mercenaries/engineer,
		/datum/outfit/job/pmc/standard,
		/datum/outfit/job/requisitions/officer,
		/datum/outfit/job/som/standard,
		/datum/outfit/job/upp/leader,
		/datum/outfit/job/imperial/sergeant,
		/datum/outfit/job/freelancer/medic,
		/datum/outfit/job/deathsquad/standard,
		/datum/outfit/job/clf/standard
	)
	var/list/humans = list()

	for(var/I in outfits_to_test)
		var/mob/living/carbon/human/H = new /mob/living/carbon/human(pick(locs))
		humans += H

	sleep(50)

	for(var/i in humans)
		if(!length(outfits_to_test))
			break
		var/mob/living/carbon/human/H = i
		H.equipOutfit(outfits_to_test[outfits_to_test.len])
		outfits_to_test.len--
	
	sleep(10)

	for(var/i in humans)
		qdel(i)

	sleep(10)
