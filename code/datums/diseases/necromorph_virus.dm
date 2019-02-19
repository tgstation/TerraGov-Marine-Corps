/datum/disease/black_goo/necromorph_virus
	name = "Marker's influence"
	agent = "Unknown Biological Organism X-66"
	survive_mob_death = TRUE //switch to true to make dead infected humans still transform

/datum/disease/black_goo/necromorph_virus/proc/zombie_transform(mob/living/carbon/human/H)
	set waitfor = 0
	zombie_transforming = TRUE
	H.vomit()
	sleep(50)
	H.AdjustStunned(5)
	sleep(20)
	H.Jitter(500)
	sleep(30)
	if(H && H.loc)
		if(H.stat == DEAD) H.revive(TRUE)
		playsound(H.loc, 'sound/hallucinations/wail.ogg', 25, 1)
		H.jitteriness = 0
		H.set_species("Necromorph")
		stage = 5
		zombie_transforming = FALSE
