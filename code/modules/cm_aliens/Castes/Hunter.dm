//Hunter Code - Colonial Marines - Last Edit: Apophis775 - 11JUN16

/mob/living/carbon/Xenomorph/Hunter
	caste = "Hunter"
	name = "Hunter"
	desc = "A beefy, fast alien with sharp claws."
	icon_state = "Hunter Walking"
	melee_damage_lower = 20
	melee_damage_upper = 30
	health = 150
	maxHealth = 150
	storedplasma = 50
	plasma_gain = 8
	maxplasma = 100
	evolution_threshold = 500
	caste_desc = "A fast, powerful front line combatant."
	speed = -1.5 //Not as fast as runners, but faster than other xenos
	evolves_to = list("Ravager", "Crusher")
	charge_type = 2 //Pounce - Hunter
	armor_deflection = 15
	attack_delay = -2
	tier = 2
	upgrade = 0
	actions = list(
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/activable/tail_attack,
		/datum/action/xeno_action/activable/pounce,
		)


