/mob/living/carbon/xenomorph/carrier
	caste_base_type = /mob/living/carbon/xenomorph/carrier
	name = "Carrier"
	desc = "A strange-looking alien creature. It carries a number of scuttling jointed crablike creatures."
	icon = 'icons/Xeno/castes/carrier.dmi' //They are now like, 2x2
	icon_state = "Carrier Walking"
	bubble_icon = "alienroyal"
	health = 200
	maxHealth = 200
	plasma_stored = 50
	///Number of huggers the carrier is currently carrying
	var/huggers = 0
	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_NORMAL
	pixel_x = -16 //Needed for 2x2
	old_x = -16
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/vent_crawl,
	)
	///Facehuggers overlay
	var/mutable_appearance/hugger_overlays_icon

// ***************************************
// *********** Life overrides
// ***************************************
/mob/living/carbon/xenomorph/carrier/Initialize(mapload)
	. = ..()
	hugger_overlays_icon = mutable_appearance('icons/Xeno/castes/carrier.dmi',"empty")

/mob/living/carbon/xenomorph/carrier/get_status_tab_items()
	. = ..()
	. += "Stored Huggers: [huggers] / [xeno_caste.huggers_max]"

/mob/living/carbon/xenomorph/carrier/update_icons()
	. = ..()

	if(!hugger_overlays_icon)
		return

	overlays -= hugger_overlays_icon
	hugger_overlays_icon.overlays.Cut()

	if(!huggers)
		return

	///Dispayed number of huggers
	var/displayed = round(( huggers / xeno_caste.huggers_max ) * 3.999) + 1

	for(var/i = 1; i <= displayed; i++)
		if(stat == DEAD)
			hugger_overlays_icon.overlays += mutable_appearance(icon, "clinger_[i] Knocked Down")
		else if(lying_angle)
			if((resting || IsSleeping()) && (!IsParalyzed() && !IsUnconscious() && health > 0))
				hugger_overlays_icon.overlays += mutable_appearance(icon, "clinger_[i] Sleeping")
			else
				hugger_overlays_icon.overlays +=mutable_appearance(icon, "clinger_[i] Knocked Down")
		else
			hugger_overlays_icon.overlays +=mutable_appearance(icon, "clinger_[i]")

	overlays += hugger_overlays_icon
