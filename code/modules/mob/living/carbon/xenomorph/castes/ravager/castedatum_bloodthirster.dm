/datum/xeno_caste/ravager/bloodthirster
	caste_name = "Bloodthirster"
	display_name = "Bloodthirster"
	upgrade_name = ""
	caste_desc = "A thirsting fighter that knows no rest."
	caste_type_path = /mob/living/carbon/xenomorph/ravager/bloodthirster
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "ravager" //used to match appropriate wound overlays

	// *** Plasma *** //
	plasma_max = 500
	plasma_gain = 0
	plasma_icon_state = "fury"

	// *** Abilities *** //
	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/charge,
		/datum/action/ability/activable/xeno/ravage,
		/datum/action/ability/xeno_action/endure,
		/datum/action/ability/xeno_action/rage,
		/datum/action/ability/xeno_action/bloodthirst,
	)
	plasma_damage_dealt_mult = 2
	plasma_damage_recieved_mult = 0.75

/datum/xeno_caste/ravager/bloodthirster/normal
	upgrade = XENO_UPGRADE_NORMAL

/datum/xeno_caste/ravager/bloodthirster/primordial
	upgrade_name = "Primordial"
	caste_desc = "A blood caked merciless killer."
	primordial_message = "BLOOD FOR THE BLOOD GOD! SKULLS FOR THE SKULL THRONE!"
	upgrade = XENO_UPGRADE_PRIMO

	// *** Abilities *** //
	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/charge,
		/datum/action/ability/activable/xeno/ravage,
		/datum/action/ability/xeno_action/endure,
		/datum/action/ability/xeno_action/rage,
		/datum/action/ability/xeno_action/bloodthirst,
		/datum/action/ability/xeno_action/deathmark,
	)
