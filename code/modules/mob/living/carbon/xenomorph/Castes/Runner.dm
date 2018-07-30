//Runner Code - Colonial Marines - Last Edit: Apophis775 - 11JUN16

/mob/living/carbon/Xenomorph/Runner
	caste = "Runner"
	name = "Runner"
	desc = "A small red alien that looks like it could run fairly quickly..."
	icon = 'icons/xeno/xenomorph_64x64.dmi' //They are now like, 2x1 or something
	icon_state = "Runner Walking"
	melee_damage_lower = 10
	melee_damage_upper = 20
	health = 100
	maxHealth = 100
	plasma_stored = 50
	plasma_gain = 1
	plasma_max = 100
	evolution_threshold = 200
	upgrade_threshold = 200
	caste_desc = "A fast, four-legged terror, but weak in sustained combat."
	speed = -1.8
	evolves_to = list("Lurker")
	charge_type = 1 //Pounce - Runner
	flags_pass = PASSTABLE
	attack_delay = -4
	tier = 1
	upgrade = 0
	pixel_x = -16  //Needed for 2x2
	old_x = -16
	pull_speed = -1
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/xenohide,
		/datum/action/xeno_action/activable/pounce,
		)
	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/vent_crawl,
		)
