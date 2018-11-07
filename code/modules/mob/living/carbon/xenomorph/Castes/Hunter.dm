//Hunter Code - Colonial Marines - Last Edit: Apophis775 - 11JUN16

/mob/living/carbon/Xenomorph/Hunter
	caste = "Hunter"
	name = "Hunter"
	desc = "A beefy, fast alien with sharp claws."
	icon = 'icons/Xeno/1x1_Xenos.dmi'
	icon_state = "Hunter Running"
	melee_damage_lower = 20
	melee_damage_upper = 30
	tackle_damage = 35
	health = 150
	maxHealth = 150
	plasma_stored = 50
	plasma_gain = 10
	plasma_max = 100
	evolution_threshold = 200
	upgrade_threshold = 200
	caste_desc = "A fast, powerful front line combatant."
	speed = -1.5 //Not as fast as runners, but faster than other xenos
	pixel_x = 0
	old_x = 0
	evolves_to = list("Ravager")
	charge_type = 2 //Pounce - Hunter
	armor_deflection = 10
	attack_delay = -1
	pounce_delay = 150
	tier = 2
	upgrade = 0
	var/stealth_delay = null
	var/last_stealth = null
	var/used_stealth = FALSE
	var/stealth = FALSE
	var/can_sneak_attack = FALSE
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/activable/pounce,
		/datum/action/xeno_action/activable/stealth,
		)
	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/vent_crawl,
		)
