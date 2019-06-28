/mob/living/carbon/xenomorph/shrike
	caste_base_type = /mob/living/carbon/xenomorph/shrike
	name = "Shrike"
	desc = "A large, lanky alien creature. It seems psychically unstable."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Shrike Walking"
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
	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_ZERO
	xeno_explosion_resistance = 2 //some resistance against explosion stuns.
	job = ROLE_XENO_QUEEN
	var/shrike_flags = SHRIKE_FLAG_PAIN_HUD_ON

	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/plant_weeds,
		/datum/action/xeno_action/lay_egg,
		/datum/action/xeno_action/call_of_the_burrowed,
		/datum/action/xeno_action/choose_resin,
		/datum/action/xeno_action/activable/secrete_resin,
		/datum/action/xeno_action/activable/corrosive_acid,
		/datum/action/xeno_action/activable/psychic_cure,
		/datum/action/xeno_action/psychic_whisper,
		/datum/action/xeno_action/activable/psychic_fling,
		/datum/action/xeno_action/activable/psychic_choke,
		/datum/action/xeno_action/toggle_pheromones
		)
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/vent_crawl,		
		/mob/living/carbon/xenomorph/proc/calldown_dropship
		)

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


// ***************************************
// *********** Pain Hud
// ***************************************
/mob/living/carbon/xenomorph/prepare_huds()
	. = ..()
	var/datum/atom_hud/pain_hud = GLOB.huds[DATA_HUD_MEDICAL_PAIN]
	pain_hud.add_hud_to(src)


/mob/living/carbon/xenomorph/shrike/verb/toggle_shrike_painhud()
	set name = "Toggle Shrike Pain HUD"
	set desc = "Toggles the pain hud appearing above humans."
	set category = "Alien"

	TOGGLE_BITFIELD(shrike_flags, SHRIKE_FLAG_PAIN_HUD_ON)
	xeno_mobhud = !xeno_mobhud
	var/datum/atom_hud/new_hud = GLOB.huds[DATA_HUD_MEDICAL_PAIN]
	if(CHECK_BITFIELD(shrike_flags, SHRIKE_FLAG_PAIN_HUD_ON))
		new_hud.add_hud_to(usr)
	else
		new_hud.remove_hud_from(usr)