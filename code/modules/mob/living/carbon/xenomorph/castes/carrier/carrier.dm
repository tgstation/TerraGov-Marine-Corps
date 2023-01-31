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
	bubble_icon = "alienroyal"
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/vent_crawl,
		/mob/living/carbon/xenomorph/proc/toggle_playable_facehugger,
	)

// ***************************************
// *********** Life overrides
// ***************************************
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
		to_chat(user, span_warning("The carrier did not allow possession."))
		return FALSE

	if(!huggers)
		to_chat(user, span_warning("The carrier doesn't have available huggers."))
		return FALSE

	var/mob/living/carbon/xenomorph/facehugger/new_hugger = new /mob/living/carbon/xenomorph/facehugger(get_turf(src))
	huggers--
	new_hugger.transfer_mob(user)
	log_admin("[user.key] took control of [new_hugger.name] from a [name] at [AREACOORD(src)].")
	return TRUE

//Sentient facehugger can climb on the carrier
/mob/living/carbon/xenomorph/carrier/attack_facehugger(mob/living/carbon/xenomorph/facehugger/F, damage_amount, damage_type, damage_flag, effects, armor_penetration, isrightclick)
	. = ..()

	if(alert("Do you want to climb on the carrier?", "Climb on the carrier", "Yes", "No") != "Yes")
		return

	if(huggers >= xeno_caste.huggers_max)
		F.balloon_alert(F, "The carrier has no space")
		return

	huggers++
	F.visible_message(span_xenowarning("[F] climb on the [src]."),span_xenonotice("You climb on the [src]."))
	F.ghostize(FALSE)
	F.death(deathmessage = "climb on the carrier", silent = TRUE)
	qdel(F)
