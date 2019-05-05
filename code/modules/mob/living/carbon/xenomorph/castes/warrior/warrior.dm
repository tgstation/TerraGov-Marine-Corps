/mob/living/carbon/Xenomorph/Warrior
	caste_base_type = /mob/living/carbon/Xenomorph/Warrior
	name = "Warrior"
	desc = "A beefy, alien with an armored carapace."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Warrior Walking"
	health = 200
	maxHealth = 200
	plasma_stored = 50
	speed = -0.3
	pixel_x = -16
	old_x = -16
	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_ZERO
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/activable/toggle_agility,
		/datum/action/xeno_action/activable/fling,
		/datum/action/xeno_action/activable/lunge,
		/datum/action/xeno_action/activable/punch
		)

// ***************************************
// *********** Icons
// ***************************************
/mob/living/carbon/Xenomorph/Warrior/handle_special_state()
	if(agility)
		icon_state = "Warrior Agility"
		return TRUE
	return FALSE

/mob/living/carbon/Xenomorph/Warrior/handle_special_wound_states()
	. = ..()
	if(agility)
		return image("icon"='icons/Xeno/wound_overlays.dmi', "icon_state"="warrior_wounded_agility", "layer"=-X_WOUND_LAYER)

// ***************************************
// *********** Mob overrides
// ***************************************
/mob/living/carbon/Xenomorph/Warrior/throw_item(atom/target)
	throw_mode_off()

/mob/living/carbon/Xenomorph/Warrior/stop_pulling()
	if(isliving(pulling))
		var/mob/living/L = pulling
		grab_resist_level = 0 //zero it out
		L.SetStunned(0)
	..()

/mob/living/carbon/Xenomorph/Warrior/start_pulling(atom/movable/AM, lunge, no_msg)
	if (!check_state() || agility || !isliving(AM))
		return FALSE

	var/mob/living/L = AM

	if(!isxeno(AM))
		if (used_lunge && !lunge)
			to_chat(src, "<span class='xenowarning'>You must gather your strength before neckgrabbing again.</span>")
			return FALSE

		if (!check_plasma(10))
			return FALSE

		if(!lunge)
			used_lunge = TRUE

	. = ..(AM, lunge, TRUE) //no_msg = true because we don't want to show the defaul pull message

	if(.) //successful pull
		if(!isxeno(AM))
			use_plasma(10)

		if(!isxeno(L))
			round_statistics.warrior_grabs++
			grab_level = GRAB_NECK
			L.drop_all_held_items()
			L.KnockDown(1)
			visible_message("<span class='xenowarning'>\The [src] grabs [L] by the throat!</span>", \
			"<span class='xenowarning'>You grab [L] by the throat!</span>")

	if(!lunge && !isxeno(AM))
		var/datum/action/xeno_action/lun = actions_by_path[/datum/action/xeno_action/activable/lunge]
		lun?.add_cooldown()

/mob/living/carbon/Xenomorph/Warrior/hitby(atom/movable/AM as mob|obj,var/speed = 5)
	if(ishuman(AM))
		return
	..()
