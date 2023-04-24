/mob/living/carbon/xenomorph/carrier
	caste_base_type = /mob/living/carbon/xenomorph/carrier
	name = "Carrier"
	desc = "A strange-looking alien creature. It carries a number of scuttling jointed crablike creatures."
	icon = 'icons/Xeno/2x2_Xenos.dmi' //They are now like, 2x2
	icon_state = "Carrier Walking"
	bubble_icon = "alienroyal"
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
		/mob/living/carbon/xenomorph/proc/toggle_playable_facehugger,
	)
	///Facehuggers overlay
	var/mutable_appearance/hugger_overlays_icon

// ***************************************
// *********** Life overrides
// ***************************************
/mob/living/carbon/xenomorph/carrier/Initialize(mapload)
	. = ..()
	hugger_overlays_icon = mutable_appearance('icons/Xeno/2x2_Xenos.dmi',"empty")

/mob/living/carbon/xenomorph/carrier/Stat()
	. = ..()
	if(statpanel("Game"))
		stat("Stored Huggers:", "[huggers] / [xeno_caste.huggers_max]")

//Observers can become playable facehuggers by clicking on the carrier
/mob/living/carbon/xenomorph/carrier/attack_ghost(mob/dead/observer/user)
	. = ..()

	var/datum/hive_status/hive = GLOB.hive_datums[hivenumber]
	if(!hive.can_spawn_as_hugger(user))
		return FALSE

	if(!sentient_huggers)
		balloon_alert(user, "Sentient huggers disabled")
		return FALSE

	if(!huggers)
		balloon_alert(user, "No huggers available")
		return FALSE

	var/mob/living/carbon/xenomorph/facehugger/new_hugger = new(get_turf(src))
	huggers--
	new_hugger.transfer_mob(user)
	return TRUE

//Sentient facehugger can climb on the carrier
/mob/living/carbon/xenomorph/carrier/attack_alien(mob/living/carbon/xenomorph/X, damage_amount, damage_type, damage_flag, effects, armor_penetration, isrightclick)
	. = ..()
	if(!isxenofacehugger(X))
		return
	if(tgui_alert(X, "Do you want to climb on the carrier?", "Climb on the carrier", list("Yes", "No")) != "Yes")
		return
	if(huggers >= xeno_caste.huggers_max)
		balloon_alert(X, "The carrier has no space")
		return

	huggers++
	X.visible_message(span_xenowarning("[X] climb on the [src]."),span_xenonotice("You climb on the [src]."))
	X.ghostize()
	X.death(deathmessage = "climb on the carrier", silent = TRUE)
	qdel(X)

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
