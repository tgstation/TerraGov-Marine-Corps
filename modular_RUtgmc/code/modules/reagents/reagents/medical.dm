/datum/reagent/medicine/spaceacillin
	purge_list = list(/datum/reagent/medicine/xenojelly)
	purge_rate = 5

/datum/reagent/medicine/larvaway
	purge_list = list(/datum/reagent/medicine/xenojelly)
	purge_rate = 5

/datum/reagent/medicine/research/medicalnanites/reaction_mob(mob/living/L, method = TOUCH, volume, show_message = TRUE, touch_protection = 0)
	if(ishuman(L))
		if(L.reagents.get_reagent_amount(/datum/reagent/medicine/research/medicalnanites))
			if(L.getCloneLoss() < 100 && L.stat != DEAD)
				to_chat(L, span_userdanger("You feel terrible!"))
				L.adjustCloneLoss(volume)
	return ..()
