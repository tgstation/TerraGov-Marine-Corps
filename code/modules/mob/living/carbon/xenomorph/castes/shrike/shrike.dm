/mob/living/carbon/xenomorph/shrike
	caste_base_type = /mob/living/carbon/xenomorph/shrike
	name = "Shrike"
	desc = "A large, lanky alien creature. It seems psychically unstable."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Queen Walking"
	attacktext = "bites"
	attack_sound = null
	friendly = "nuzzles"
	wall_smash = FALSE
	health = 240
	maxHealth = 240
	plasma_stored = 300
	speed = -0.2
	pixel_x = -16
	old_x = -16
	drag_delay = 3 //pulling a medium dead xeno is hard
	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_ZERO
	xeno_explosion_resistance = 2 //some resistance against explosion stuns.
	job = ROLE_XENO_QUEEN
	var/calling_larvas = FALSE

	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/plant_weeds,
		/datum/action/xeno_action/lay_egg,
		/datum/action/xeno_action/choose_resin,
		/datum/action/xeno_action/activable/secrete_resin,
		/datum/action/xeno_action/activable/corrosive_acid,
		/datum/action/xeno_action/psychic_whisper,
		/datum/action/xeno_action/toggle_pheromones
		)
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/vent_crawl
		)

// ***************************************
// *********** Init
// ***************************************
/mob/living/carbon/xenomorph/shrike/Initialize()
	. = ..()
	if(is_centcom_level(z))//so admins can safely spawn queens in Thunderdome for tests.
		return
	if(!hive.living_xeno_shrike)
		hive.living_xeno_shrike = src
	if(!hive.living_xeno_ruler)
		hive.update_ruler()

// ***************************************
// *********** Life overrides
// ***************************************
/mob/living/carbon/xenomorph/shrike/handle_decay()
	if(prob(20+abs(3*upgrade_as_number())))
		use_plasma(min(rand(1,2), plasma_stored))


// ***************************************
// *********** Name
// ***************************************
/mob/living/carbon/xenomorph/shrike/generate_name()
	name = "[hive.prefix][xeno_caste.upgrade_name] [xeno_caste.display_name]" //No number, shrikes are unique.

	//Update linked data so they show up properly
	real_name = name
	if(mind)
		mind.name = name