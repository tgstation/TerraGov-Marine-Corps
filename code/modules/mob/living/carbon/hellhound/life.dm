/mob/living/carbon/hellhound/Life()
	set invisibility = 0
	set background = 1

	..()

	// Grabbing
	for(var/obj/item/grab/G in src)
		G.process()

	update_icons()

/mob/living/carbon/hellhound/handle_organs()
	. = ..()

	if(reagents && reagents.reagent_list.len)
		reagents.metabolize(src, 0, can_overdose = FALSE) //set it to true for hyperzine craving dog

/mob/living/carbon/hellhound/handle_status_effects()
	. = ..()

	if(confused)
		confused = 0

	if(resting)
		dizziness = 0

	//They heal quickly.
	see_in_dark = 8
	adjustBruteLoss(-5)
	adjustFireLoss(-5)
	if(health > 0)
		adjustOxyLoss(-10)
	adjustToxLoss(-50)