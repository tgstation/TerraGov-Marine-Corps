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
