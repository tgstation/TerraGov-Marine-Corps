/datum/xeno_caste/sentinel/retrograde
	caste_type_path = /mob/living/carbon/xenomorph/sentinel/retrograde
	upgrade_name = ""
	caste_name = "Retrograde Sentinel"
	display_name = "Sentinel"
	upgrade = XENO_UPGRADE_BASETYPE
	caste_desc = "A weak ranged combat alien. This one seems to have a different kind of spit."

		// *** Ranged Attack *** //
	spit_delay = 1 SECONDS
	spit_types = list(/datum/ammo/xeno/toxin, /datum/ammo/xeno/acid/passthrough)

	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/corrosive_acid/drone,
		/datum/action/ability/activable/xeno/neurotox_sting,
		/datum/action/ability/activable/xeno/xeno_spit,
	)

	buyable_mutations = list()

/datum/xeno_caste/sentinel/retrograde/normal
	upgrade = XENO_UPGRADE_NORMAL

/datum/xeno_caste/sentinel/retrograde/primordial
	upgrade_name = "Primordial"
	upgrade = XENO_UPGRADE_PRIMO
	caste_desc = "A neurotoxic nightmare. It's stingers drip with poison."

	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/corrosive_acid/drone,
		/datum/action/ability/activable/xeno/neurotox_sting,
		/datum/action/ability/activable/xeno/xeno_spit,
		/datum/action/ability/activable/xeno/toxic_grenade/neuro
	)
