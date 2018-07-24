/mob/living/carbon/Xenomorph/Warrior
	caste = "Warrior"
	name = "Warrior"
	desc = "A beefy, alien with an armored carapace."
	icon = 'icons/Xeno/xenomorph_64x64.dmi'
	icon_state = "Warrior Walking"
	melee_damage_lower = 30
	melee_damage_upper = 35
	health = 200
	maxHealth = 200
	plasma_stored = 50
	plasma_gain = 8
	plasma_max = 100
	evolution_threshold = 500
	upgrade_threshold = 500
	caste_desc = "A powerful front line combatant."
	speed = -0.8
	pixel_x = -16
	old_x = -16
	evolves_to = list("Praetorian", "Crusher")
	armor_deflection = 30
	tier = 2
	upgrade = 0
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/activable/toggle_agility,
		/datum/action/xeno_action/activable/fling,
		/datum/action/xeno_action/activable/lunge,
		/datum/action/xeno_action/activable/punch
		)
	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/vent_crawl,
		)

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

/mob/living/carbon/Xenomorph/Warrior/throw_item(atom/target)
	throw_mode_off()


/mob/living/carbon/Xenomorph/Warrior/stop_pulling()
	if(isliving(pulling))
		var/mob/living/L = pulling
		L.SetStunned(0)
	..()


/mob/living/carbon/Xenomorph/Warrior/start_pulling(atom/movable/AM, lunge, no_msg)
	if (!check_state() || agility)
		return FALSE

	if(!isliving(AM))
		return FALSE
	var/mob/living/L = AM

	if(!isXeno(AM))
		if (used_lunge && !lunge)
			src << "<span class='xenowarning'>You must gather your strength before neckgrabbing again.</span>"
			return FALSE

		if (!check_plasma(10))
			return FALSE

		if(!lunge)
			used_lunge = 1

	. = ..(AM, lunge, TRUE) //no_msg = true because we don't want to show the defaul pull message

	if(.) //successful pull
		if(!isXeno(AM))
			use_plasma(10)

		if(!isXeno(L) && !isYautja(L))
			round_statistics.warrior_grabs++
			grab_level = GRAB_NECK
			L.drop_held_items()
			L.Stun(5)
			visible_message("<span class='xenowarning'>\The [src] grabs [L] by the throat!</span>", \
			"<span class='xenowarning'>You grab [L] by the throat!</span>")

	if(!lunge && !isXeno(AM))
		spawn(lunge_cooldown)
			used_lunge = 0
			src << "<span class='notice'>You get ready to lunge again.</span>"
			for(var/X in actions)
				var/datum/action/act = X
				act.update_button_icon()

/mob/living/carbon/Xenomorph/Warrior/hitby(atom/movable/AM as mob|obj,var/speed = 5)
	if(ishuman(AM))
		return
	..()
