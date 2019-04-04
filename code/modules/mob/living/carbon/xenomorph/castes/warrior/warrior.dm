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
/mob/living/carbon/Xenomorph/Warrior/update_icons()
	if (stat == DEAD)
		icon_state = "Warrior Dead"
	else if (lying)
		if ((resting || sleeping) && (!knocked_down && !knocked_out && health > 0))
			icon_state = "Warrior Sleeping"
		else
			icon_state = "Warrior Knocked Down"
	else if (agility)
		icon_state = "Warrior Agility"
	else
		if (m_intent == MOVE_INTENT_RUN)
			icon_state = "Warrior Running"
		else
			icon_state = "Warrior Walking"

	update_fire() //the fire overlay depends on the xeno's stance, so we must update it.
	update_wounds()

// ***************************************
// *********** Mob overrides
// ***************************************
/mob/living/carbon/Xenomorph/Warrior/throw_item(atom/target)
	throw_mode_off()

/mob/living/carbon/Xenomorph/Warrior/stop_pulling()
	if(isliving(pulling))
		var/mob/living/L = pulling
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
		addtimer(CALLBACK(src, .proc/lunge_reset), WARRIOR_LUNGE_COOLDOWN)

/mob/living/carbon/Xenomorph/Warrior/hitby(atom/movable/AM as mob|obj,var/speed = 5)
	if(ishuman(AM))
		return
	..()

// ***************************************
// *********** Death
// ***************************************
/mob/living/carbon/Xenomorph/Warrior/update_wounds()
	remove_overlay(X_WOUND_LAYER)
	if(health < maxHealth * 0.5) //Injuries appear at less than 50% health
		var/image/I
		if(resting)
			I = image("icon"='icons/Xeno/wound_overlays.dmi', "icon_state"="warrior_wounded_resting", "layer"=-X_WOUND_LAYER)
		else if(sleeping || stat == DEAD)
			I = image("icon"='icons/Xeno/wound_overlays.dmi', "icon_state"="warrior_wounded_sleeping", "layer"=-X_WOUND_LAYER)
		else if(agility)
			I = image("icon"='icons/Xeno/wound_overlays.dmi', "icon_state"="warrior_wounded_agility", "layer"=-X_WOUND_LAYER)
		else
			I = image("icon"='icons/Xeno/wound_overlays.dmi', "icon_state"="warrior_wounded", "layer"=-X_WOUND_LAYER)

		overlays_standing[X_WOUND_LAYER] = I
		apply_overlay(X_WOUND_LAYER)
