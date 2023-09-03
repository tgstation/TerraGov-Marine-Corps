/mob/living/carbon/xenomorph/carrier
	///The number of huggers the carrier reserves against observer possession.
	var/huggers_reserved = 0

//Observers can become playable facehuggers by clicking on the carrier
/mob/living/carbon/xenomorph/carrier/attack_ghost(mob/dead/observer/user)
	. = ..()

	var/datum/hive_status/hive = GLOB.hive_datums[hivenumber]
	if(!hive.can_spawn_as_hugger(user))
		return FALSE

	if(huggers_reserved >= huggers)
		balloon_alert(user, "No facehuggers available.")
		return FALSE

	var/mob/living/carbon/xenomorph/facehugger/new_hugger = new(get_turf(src))
	huggers--
	new_hugger.transfer_mob(user)
	return TRUE

//Sentient facehugger can climb on the carrier
/mob/living/carbon/xenomorph/carrier/attack_facehugger(mob/living/carbon/xenomorph/facehugger/F, damage_amount, damage_type, damage_flag, effects, armor_penetration, isrightclick)
	. = ..()
	if(tgui_alert(F, "Do you want to climb on the carrier?", "Climb on the carrier", list("Yes", "No")) != "Yes")
		return
	if(huggers >= xeno_caste.huggers_max)
		balloon_alert(F, "The carrier has no space")
		return

	huggers++
	F.visible_message(span_xenowarning("[F] climb on the [src]."),span_xenonotice("You climb on the [src]."))
	F.ghostize()
	F.death(deathmessage = "climb on the carrier", silent = TRUE)
	qdel(F)
