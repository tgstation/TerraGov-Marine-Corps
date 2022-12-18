/mob/living/carbon/xenomorph/carrier
	caste_base_type = /mob/living/carbon/xenomorph/carrier
	name = "Carrier"
	desc = "A strange-looking alien creature. It carries a number of scuttling jointed crablike creatures."
	icon = 'icons/Xeno/2x2_Xenos.dmi' //They are now like, 2x2
	icon_state = "Carrier Walking"
	health = 200
	maxHealth = 200
	plasma_stored = 50
	///Number of huggers the carrier is currently carrying
	var/huggers = 0
	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_ZERO
	pixel_x = -16 //Needed for 2x2
	old_x = -16
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/vent_crawl,
	)

	var/list/hugger_image_index = list()
	var/mutable_appearance/hugger_overlays_icon

// ***************************************
// *********** Life overrides
// ***************************************
/mob/living/carbon/xenomorph/carrier/Stat()
	. = ..()

	if(statpanel("Game"))
		stat("Stored Huggers:", "[huggers] / [xeno_caste.huggers_max]")

/mob/living/carbon/xenomorph/carrier/update_icons()
	. = ..()

	update_hugger_overlays()

/mob/living/carbon/xenomorph/carrier/proc/update_hugger_overlays()
	if(!hugger_overlays_icon)
		return

	overlays -= hugger_overlays_icon
	hugger_overlays_icon.overlays.Cut()

	if(!huggers)
		hugger_image_index.Cut()
		return

	update_icon_maths(round(( huggers / xeno_caste.huggers_max ) * 3.999) + 1)

	for(var/i in hugger_image_index)
		if(stat == DEAD)
			hugger_overlays_icon.overlays += icon(icon, "clinger_[i] Knocked Down")
		else if(lying_angle)
			if((resting || IsSleeping()) && (!IsParalyzed() && !IsUnconscious() && health > 0))
				hugger_overlays_icon.overlays += icon(icon, "clinger_[i] Sleeping")
			else
				hugger_overlays_icon.overlays +=icon(icon, "clinger_[i] Knocked Down")
		else
			hugger_overlays_icon.overlays +=icon(icon, "clinger_[i]")

	overlays += hugger_overlays_icon

/mob/living/carbon/xenomorph/carrier/proc/update_icon_maths(number)
	var/funny_list = list(1,2,3,4)
	if(length(hugger_image_index) != number)
		if(length(hugger_image_index) > number)
			while(length(hugger_image_index) != number)
				hugger_image_index -= hugger_image_index[length(hugger_image_index)]
		else
			while(length(hugger_image_index) != number)
				for(var/i in hugger_image_index)
					if(locate(i) in funny_list)
						funny_list -= i
				hugger_image_index += funny_list[rand(1,length(funny_list))]

/mob/living/carbon/xenomorph/carrier/Initialize(mapload, h_number)
	. = ..()

	hugger_overlays_icon = mutable_appearance('icons/Xeno/2x2_Xenos.dmi',"empty")
