/datum/xeno_caste/defender
	caste_name = "Defender"
	display_name = "Defender"
	upgrade_name = "Young"
	caste_desc = "A sturdy front line combatant."

	caste_type_path = /mob/living/carbon/Xenomorph/Defender

	tier = 1
	upgrade = 0

	// *** Melee Attacks *** //
	melee_damage_lower = 15
	melee_damage_upper = 25

	// *** Tackle *** //
	tackle_damage = 30

	// *** Speed *** //
	speed = -0.2

	// *** Plasma *** //
	plasma_max = 150
	plasma_gain = 10

	// *** Health *** //
	max_health = 250

	// *** Evolution *** //
	evolution_threshold = 100
	upgrade_threshold = 100

	evolves_to = list(/mob/living/carbon/Xenomorph/Warrior)

	// *** Flags *** //
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_EVOLUTION_ALLOWED|CASTE_CAN_BE_GIVEN_PLASMA
	
	// *** Defense *** //
	armor_deflection = 20

	// *** Ranged Attack *** //
	charge_type = 2 //Pounce - Hunter

	// *** Defender Abilities *** //
	headbutt_cooldown = 4 SECONDS
	tail_sweep_cooldown = 12 SECONDS
	crest_defense_cooldown = 1 SECONDS
	fortify_cooldown = 200
	crest_defense_armor = 35
	fortify_armor = 70
	cresttoss_cooldown = 6 SECONDS

/datum/xeno_caste/defender/mature
	upgrade_name = "Mature"
	caste_desc = "An alien with an armored head crest. It looks a little more dangerous."
	upgrade = 1

	// *** Melee Attacks *** //	
	melee_damage_lower = 20
	melee_damage_upper = 30

	// *** Tackle *** //
	tackle_damage = 35

	// *** Speed *** //
	speed = -0.3

	// *** Plasma *** //
	plasma_max = 175
	plasma_gain = 13

	// *** Health *** //
	max_health = 275

	// *** Evolution *** //
	upgrade_threshold = 200

	// *** Defense *** //
	armor_deflection = 25

	// *** Defender Abilities *** //
	crest_defense_armor = 40
	fortify_armor = 80

/datum/xeno_caste/defender/elder
	upgrade_name = "Elder"
	caste_desc = "An alien with an armored head crest. It looks pretty strong."
	upgrade = 2

	// *** Melee Attacks *** //	
	melee_damage_lower = 23
	melee_damage_upper = 33

	// *** Tackle *** //
	tackle_damage = 35

	// *** Speed *** //
	speed = -0.4

	// *** Plasma *** //
	plasma_max = 190
	plasma_gain = 14

	// *** Health *** //
	max_health = 290

	// *** Evolution *** //
	upgrade_threshold = 400

	// *** Defense *** //
	armor_deflection = 28

	// *** Defender Abilities *** //
	crest_defense_armor = 43
	fortify_armor = 87

/datum/xeno_caste/defender/ancient
	upgrade_name = "Ancient"
	caste_desc = "An unstoppable force that remains when others would fall."
	upgrade = 3
	ancient_message = "You are a incredibly resilient, you can control the battle through sheer force."

	// *** Melee Attacks *** //	
	melee_damage_lower = 26
	melee_damage_upper = 36

	// *** Tackle *** //
	tackle_damage = 35

	// *** Speed *** //
	speed = -0.4

	// *** Plasma *** //
	plasma_max = 200
	plasma_gain = 15

	// *** Health *** //
	max_health = 300

	// *** Evolution *** //
	upgrade_threshold = 400

	// *** Defense *** //
	armor_deflection = 30

	// *** Defender Abilities *** //
	crest_defense_armor = 45
	fortify_armor = 90

/mob/living/carbon/Xenomorph/Defender
	caste_base_type = /mob/living/carbon/Xenomorph/Defender
	name = "Defender"
	desc = "A alien with an armored head crest."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Defender Walking"
	health = 250
	maxHealth = 250
	plasma_stored = 50
	speed = -0.2
	pixel_x = -16
	old_x = -16
	tier = 1
	upgrade = 0
	pull_speed = -2
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/activable/toggle_crest_defense,
		/datum/action/xeno_action/activable/fortify,
		/datum/action/xeno_action/activable/headbutt,
		/datum/action/xeno_action/activable/tail_sweep
		)

/mob/living/carbon/Xenomorph/Defender/update_icons()
	if (stat == DEAD)
		icon_state = "Defender Dead"
	else if (lying)
		if ((resting || sleeping) && (!knocked_down && !knocked_out && health > 0))
			icon_state = "Defender Sleeping"
		else
			icon_state = "Defender Knocked Down"
	else if (fortify)
		icon_state = "Defender Fortify"
	else if (crest_defense)
		icon_state = "Defender Crest"
	else
		if (m_intent == MOVE_INTENT_RUN)
			icon_state = "Defender Running"
		else
			icon_state = "Defender Walking"

	update_fire() //the fire overlay depends on the xeno's stance, so we must update it.
