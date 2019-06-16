/mob/living/carbon/xenomorph/Defiler
	caste_base_type = /mob/living/carbon/xenomorph/Defiler
	name = "Defiler"
	desc = "A large, powerfully muscled xeno replete with dripping spines and gas leaking dorsal vents."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Defiler Walking"
	health = 225
	maxHealth = 225
	plasma_stored = 400
	speed = -1
	pixel_x = -16
	old_x = -16
	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_ZERO
	var/datum/effect_system/smoke_spread/smoke_system
	var/neuro_claws = FALSE
	var/emitting_gas = FALSE
	var/neuro_claws_dose = DEFILER_CLAW_AMOUNT
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/plant_weeds,
		/datum/action/xeno_action/activable/larval_growth_sting/defiler,
		/datum/action/xeno_action/activable/neurotox_sting,
		/datum/action/xeno_action/activable/emit_neurogas,
		/datum/action/xeno_action/neuroclaws
		)
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/vent_crawl
		)

// ***************************************
// *********** Mob overrides
// ***************************************
/mob/living/carbon/xenomorph/Defiler/throw_item(atom/target)
	throw_mode_off()

/mob/living/carbon/xenomorph/Defiler/hitby(atom/movable/AM as mob|obj,var/speed = 5)
	if(ishuman(AM))
		return
	return ..()

/mob/living/carbon/xenomorph/Defiler/Bumped(atom/movable/AM as mob|obj)
	if(emitting_gas) //We don't get bumped around
		return
	return ..()

// ***************************************
// *********** Neuroclaws router
// ***************************************
/mob/living/carbon/xenomorph/Defiler/neuroclaw_router(mob/living/carbon/human/H)
	if(!check_plasma(50) || !neuro_claws || !H)
		return
	use_plasma(50)
	H.reagents.add_reagent("xeno_toxin", neuro_claws_dose)
	to_chat(src, "<span class='xenowarning'>Your claw spines inject your victim with neurotoxin!</span>")

// ***************************************
// *********** Datum override
// ***************************************
/mob/living/carbon/xenomorph/Defiler/set_datum()
	. = ..()
	neuro_claws_dose = xeno_caste.neuro_claws_amount
