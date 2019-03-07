/datum/xeno_caste/necromorph
	caste_name = "Necromorph"
	display_name = "Necromorph"
	upgrade_name = "Bloody"
	caste_desc = "A reinimated iteration of a human, looks like a hackjob."
	caste_type_path = /mob/living/carbon/Xenomorph/Necromorph
	tier = 0
	upgrade = 0

	// *** Melee Attacks *** //
	melee_damage_lower = 20
	melee_damage_upper = 30
	attack_delay = -2

	// *** Tackle *** //
	tackle_damage = 30

	// *** Speed *** //
	speed = -1

	// *** Plasma *** //
	plasma_max = 0 //default is 10

	// *** Health *** //
	max_health = 155

	// *** Flags *** //
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED //I figure might as well allow the queen to have em soak more damage.

	// *** Defense *** //
	armor_deflection = 10

/mob/living/carbon/Xenomorph/Necromorph
	caste_base_type = /mob/living/carbon/Xenomorph/Necromorph
	icon = 'icons/Xeno/48x48_Xenos.dmi'
	icon_state = "Necromorph Walking"
	maxHealth = 155
	health = 155
	away_timer = 2 MINUTES // These aren't as potent/important as other xenomorphs, you get two minutes, chances are more of these will pop up all the time.
	tier = 0
	upgrade = -1
	pixel_x = -12
	old_x = -12
	wound_type = ""
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		)
