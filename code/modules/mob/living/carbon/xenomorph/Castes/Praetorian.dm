//Praetorian Code - Colonial Marines - Last Edit: Apophis775 - 11JUN16

/mob/living/carbon/Xenomorph/Praetorian
	caste = "Praetorian"
	name = "Praetorian"
	desc = "A huge, looming beast of an alien."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Praetorian Walking"
	melee_damage_lower = 20
	melee_damage_upper = 25
	tackle_damage = 40
	health = 210
	maxHealth = 210
	plasma_stored = 200
	plasma_gain = 25
	plasma_max = 800
	upgrade_threshold = 400
	evolution_allowed = FALSE
	spit_delay = 20
	spit_types = list(/datum/ammo/xeno/toxin/heavy, /datum/ammo/xeno/acid/heavy, /datum/ammo/xeno/sticky)
	speed = -0.1
	pixel_x = -16
	old_x = -16
	caste_desc = "Ptui!"
	armor_deflection = 35
	mob_size = MOB_SIZE_BIG
	drag_delay = 6 //pulling a big dead xeno is hard
	tier = 3
	upgrade = 0
	aura_strength = 1.5 //Praetorian's aura starts strong. They are the Queen's right hand. Climbs by 1 to 4.5
	var/sticky_cooldown = 0
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/activable/corrosive_acid,
		/datum/action/xeno_action/emit_pheromones,
		/datum/action/xeno_action/shift_spits,
		/datum/action/xeno_action/activable/xeno_spit,
		/datum/action/xeno_action/activable/spray_acid
		)
