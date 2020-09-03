/datum/unit_test/spawn_humans/Run()
	var/list/outfits_to_test = subtypesof(/datum/outfit/job)
	var/list/humans = list()

	for(var/I in outfits_to_test)
		var/mob/living/carbon/human/H = allocate(/mob/living/carbon/human)
		humans += H

	sleep(50)

	for(var/i in humans)
		if(!length(outfits_to_test))
			break
		var/mob/living/carbon/human/H = i
		H.equipOutfit(outfits_to_test[outfits_to_test.len])
		outfits_to_test.len--

	sleep(10)
