/datum/xeno_caste/defiler
	caste_name = "Defiler"
	display_name = "Defiler"
	upgrade_name = "Young"
	caste_desc = "A frightening looking, bulky xeno that drips with suspect green fluids."
	caste_type_path = /mob/living/carbon/Xenomorph/Defiler
	tier = 3
	upgrade = 0

	// *** Melee Attacks *** //
	melee_damage_lower = 30
	melee_damage_upper = 35

	// *** Tackle *** //
	tackle_damage = 40

	// *** Speed *** //
	speed = -1

	// *** Plasma *** //
	plasma_max = 400
	plasma_gain = 14

	// *** Health *** //
	max_health = 250

	// *** Evolution *** //
	upgrade_threshold = 400

	deevolves_to = /mob/living/carbon/Xenomorph/Carrier

	// *** Flags *** //
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_EVOLUTION_ALLOWED|CASTE_CAN_BE_GIVEN_PLASMA

	// *** Defense *** //
	armor_deflection = 30

	// *** Defiler Abilities *** //
	bomb_strength = 1 //Used by the dispense neurogas power.
	var/neuro_claws_amount = DEFILER_CLAW_AMOUNT

/datum/xeno_caste/defiler/mature
	upgrade_name = "Mature"
	caste_desc = "A frightening looking, bulky xeno that drips with suspect green fluids. It looks a little more dangerous."

	upgrade = 1

	// *** Melee Attacks *** //
	melee_damage_lower = 35
	melee_damage_upper = 45

	// *** Tackle *** //
	tackle_damage = 45

	// *** Speed *** //
	speed = -1.1

	// *** Plasma *** //
	plasma_max = 500
	plasma_gain = 17

	// *** Health *** //
	max_health = 300

	// *** Evolution *** //
	upgrade_threshold = 800

	// *** Defense *** //
	armor_deflection = 35

	// *** Defiler Abilities *** //
	bomb_strength = 1.5
	neuro_claws_amount = 7

/datum/xeno_caste/defiler/elder
	upgrade_name = "Elder"
	caste_desc = "A frightening looking, bulky xeno that drips with suspect green fluids. It looks pretty strong."

	upgrade = 2

	// *** Melee Attacks *** //
	melee_damage_lower = 40
	melee_damage_upper = 45

	// *** Tackle *** //
	tackle_damage = 50

	// *** Speed *** //
	speed = -1.17

	// *** Plasma *** //
	plasma_max = 550
	plasma_gain = 19

	// *** Health *** //
	max_health = 325

	// *** Evolution *** //
	upgrade_threshold = 1600

	// *** Defense *** //
	armor_deflection = 38

	// *** Defiler Abilities *** //
	bomb_strength = 1.5
	neuro_claws_amount = 7.7

/datum/xeno_caste/defiler/ancient
	upgrade_name = "Ancient"
	caste_desc = "Being within mere eyeshot of this hulking, dripping monstrosity fills you with a deep, unshakeable sense of unease."
	ancient_message = "You are the ultimate alien impregnator. You will infect the marines, see them burst open before you, and hear the gleeful screes of your larvae."
	upgrade = 3

	// *** Melee Attacks *** //
	melee_damage_lower = 45
	melee_damage_upper = 50

	// *** Tackle *** //
	tackle_damage = 55

	// *** Speed *** //
	speed = -1.2

	// *** Plasma *** //
	plasma_max = 575
	plasma_gain = 20

	// *** Health *** //
	max_health = 340

	// *** Evolution *** //
	upgrade_threshold = 1600

	// *** Defense *** //
	armor_deflection = 40

	// *** Defiler Abilities *** //
	bomb_strength = 2
	neuro_claws_amount = 8

/mob/living/carbon/Xenomorph/Defiler
	caste_base_type = /mob/living/carbon/Xenomorph/Defiler
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
	wound_type = "defiler" //used to match appropriate wound overlays
	tier = 3
	upgrade = 0
	var/datum/effect_system/smoke_spread/xeno/smoke_system = null
	var/last_defiler_sting = null
	var/last_emit_neurogas = null
	var/last_use_neuroclaws = null
	var/neuro_claws = FALSE
	var/emitting_gas = FALSE
	var/neuro_claws_dose = DEFILER_CLAW_AMOUNT
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/plant_weeds,
		/datum/action/xeno_action/activable/emit_neurogas,
		/datum/action/xeno_action/activable/defiler_sting,
		/datum/action/xeno_action/neuroclaws,
		)
	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/vent_crawl,
		)

/mob/living/carbon/Xenomorph/Defiler/update_icons()
	if (stat == DEAD)
		icon_state = "Defiler Dead"
	else if (lying)
		if ((resting || sleeping) && (!knocked_down && !knocked_out && health > 0))
			icon_state = "Defiler Sleeping"
		else
			icon_state = "Defiler Knocked Down"
	else
		if (m_intent == MOVE_INTENT_RUN)
			icon_state = "Defiler Running"
		else
			icon_state = "Defiler Walking"

	update_fire() //the fire overlay depends on the xeno's stance, so we must update it.
	update_wounds()

/mob/living/carbon/Xenomorph/Defiler/throw_item(atom/target)
	throw_mode_off()

/mob/living/carbon/Xenomorph/Defiler/hitby(atom/movable/AM as mob|obj,var/speed = 5)
	if(ishuman(AM))
		return
	return ..()

/mob/living/carbon/Xenomorph/Defiler/Bumped(atom/movable/AM as mob|obj)
	if(emitting_gas) //We don't get bumped around
		return
	return ..()
