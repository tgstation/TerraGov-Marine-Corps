/mob/living/carbon/xenomorph/warrior
	caste_base_type = /mob/living/carbon/xenomorph/warrior
	name = "Warrior"
	desc = "A beefy, alien with an armored carapace."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Warrior Walking"
	health = 200
	maxHealth = 200
	plasma_stored = 50
	pixel_x = -16
	old_x = -16
	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_ZERO

// ***************************************
// *********** Icons
// ***************************************
/mob/living/carbon/xenomorph/warrior/handle_special_state()
	if(agility)
		icon_state = "Warrior Agility"
		return TRUE
	return FALSE

/mob/living/carbon/xenomorph/warrior/handle_special_wound_states()
	. = ..()
	if(agility)
		return image("icon"='icons/Xeno/wound_overlays.dmi', "icon_state"="warrior_wounded_agility", "layer"=-X_WOUND_LAYER)

// ***************************************
// *********** Mob overrides
// ***************************************

/mob/living/carbon/xenomorph/warrior/start_pulling(atom/movable/AM, suppress_message = FALSE)
	if(agility)
		return FALSE
	return ..()
