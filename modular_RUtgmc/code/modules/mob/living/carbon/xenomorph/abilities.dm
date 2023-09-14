// ***************************************
// *********** Universal abilities
// ***************************************
// Resting
/datum/action/xeno_action/xeno_resting
	use_state_flags = XACT_USE_LYING|XACT_USE_CRESTED|XACT_USE_AGILITY|XACT_USE_CLOSEDTURF|XACT_USE_STAGGERED|XACT_USE_INCAP

// Secrete Resin
/datum/action/xeno_action/activable/secrete_resin
	buildable_structures = list(
		/turf/closed/wall/resin/regenerating,
		/obj/alien/resin/sticky,
		/obj/structure/mineral_door/resin,
		/obj/structure/bed/nest,
		)

/datum/action/xeno_action/activable/secrete_resin/preshutter_build_resin(turf/T)
	for(var/mob/living/carbon/human AS in cheap_get_humans_near(T, 7))
		if(human.client && human.stat != DEAD)
			owner.balloon_alert(owner, "Somebody humanlike is alive nearby!")
			return

	var/mob/living/carbon/xenomorph/X = owner
	if(X.selected_resin == /obj/structure/bed/nest)
		for(var/obj/structure/bed/nest/xeno_nest in range (2,T))
			owner.balloon_alert(owner, span_notice("Another nest is too close!"))
			return

	return ..()


/datum/action/xeno_action/activable/secrete_resin/build_resin(turf/T)
	var/mob/living/carbon/xenomorph/X = owner
	if(X.selected_resin == /obj/structure/bed/nest)
		for(var/obj/structure/bed/nest/xeno_nest in range (2,T))
			owner.balloon_alert(owner, span_notice("Another nest is too close!"))
			return

	return ..()
