//Spitter Code - Colonial Marines - Last Edit: Apophis775 - 11JUN16

/mob/living/carbon/Xenomorph/Spitter
	caste = "Spitter"
	name = "Spitter"
	desc = "A gross, oozing alien of some kind."
	icon = 'icons/Xeno/1x1_Xenos.dmi'
	icon_state = "Spitter Walking"
	melee_damage_lower = 15
	melee_damage_upper = 25
	tackle_damage = 30
	health = 180
	maxHealth = 180
	plasma_stored = 150
	plasma_gain = 25
	plasma_max = 800
	spit_delay = 10
	evolution_threshold = 200
	upgrade_threshold = 200
	spit_types = list(/datum/ammo/xeno/acid/heavy) //Gotta give them their own version of heavy acid; kludgy but necessary as 100 plasma is way too costly.
	speed = -0.5
	caste_desc = "Ptui!"
	pixel_x = 0
	old_x = 0
	evolves_to = list("Boiler")
	armor_deflection = 20
	tier = 2
	upgrade = 0
	acid_cooldown = 0
	acid_delay = 300 //30 second delay on acid spray. Reduced by -3/-2/-1 per upgrade.
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/activable/corrosive_acid,
		/datum/action/xeno_action/activable/xeno_spit,
		/datum/action/xeno_action/activable/spray_acid,
		)
	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/vent_crawl,
		)

