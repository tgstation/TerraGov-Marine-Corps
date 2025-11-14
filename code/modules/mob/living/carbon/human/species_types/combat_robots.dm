/datum/species/robot
	name = "Combat Robot"
	species_type = SPECIES_COMBAT_ROBOT
	icobase = 'icons/mob/human_races/r_robot.dmi'
	damage_mask_icon = 'icons/mob/dam_mask_robot.dmi'
	brute_damage_icon_state = "robot_brute"
	burn_damage_icon_state = "robot_burn"
	eyes = "blank_eyes"
	default_language_holder = /datum/language_holder/robot
	namepool = /datum/namepool/robotic

	unarmed_type = /datum/unarmed_attack/punch/strong
	total_health = 100
	slowdown = SHOES_SLOWDOWN //because they don't wear boots

	cold_level_1 = -1
	cold_level_2 = -1
	cold_level_3 = -1

	heat_level_1 = 500
	heat_level_2 = 1000
	heat_level_3 = 2000

	body_temperature = 350

	inherent_traits = list(TRAIT_IMMEDIATE_DEFIB, TRAIT_CRIT_IS_DEATH)
	species_flags = NO_BREATHE|NO_BLOOD|NO_POISON|NO_PAIN|NO_CHEM_METABOLIZATION|NO_STAMINA|DETACHABLE_HEAD|HAS_NO_HAIR|ROBOTIC_LIMBS|IS_INSULATED

	no_equip = list(
		SLOT_W_UNIFORM,
		SLOT_HEAD,
		SLOT_WEAR_MASK,
		SLOT_WEAR_SUIT,
		SLOT_SHOES,
		SLOT_GLOVES,
		SLOT_GLASSES,
	)
	blood_color = "#2d2055" //an oil-like color - a little note, robots cannot shed blood in any way, due to their flags
	hair_color = "#00000000"
	has_organ = list()


	screams = list(MALE = SFX_ROBOT_SCREAM, FEMALE = SFX_ROBOT_SCREAM, PLURAL = SFX_ROBOT_SCREAM, NEUTER = SFX_ROBOT_SCREAM)
	paincries = list(MALE = SFX_ROBOT_PAIN, FEMALE = SFX_ROBOT_PAIN, PLURAL = SFX_ROBOT_PAIN, NEUTER = SFX_ROBOT_PAIN)
	goredcries = list(MALE = SFX_ROBOT_SCREAM, FEMALE = SFX_ROBOT_SCREAM, PLURAL = SFX_ROBOT_SCREAM, NEUTER = SFX_ROBOT_SCREAM)
	warcries = list(MALE = SFX_ROBOT_WARCRY, FEMALE = SFX_ROBOT_WARCRY, PLURAL = SFX_ROBOT_WARCRY, NEUTER = SFX_ROBOT_WARCRY)
	death_message = "shudders violently whilst spitting out error text before collapsing, their visual sensor darkening..."
	special_death_message = "You have been shut down.<br><small>But it is not the end of you yet... if you still have your body, wait until somebody can resurrect you...</small>"
	joinable_roundstart = TRUE

	inherent_actions = list(/datum/action/repair_self)

/datum/species/robot/on_species_gain(mob/living/carbon/human/H, datum/species/old_species)
	. = ..()
	H.speech_span = SPAN_ROBOT
	H.voice_filter = "afftfilt=real='hypot(re,im)*sin(0)':imag='hypot(re,im)*cos(0)':win_size=512:overlap=1,rubberband=pitch=0.8"
	H.health_threshold_crit = -100

/datum/species/robot/post_species_loss(mob/living/carbon/human/H)
	. = ..()
	H.speech_span = initial(H.speech_span)
	H.voice_filter = initial(H.voice_filter)
	H.health_threshold_crit = -50

/datum/species/robot/handle_unique_behavior(mob/living/carbon/human/H)
	if(H.health <= 0 && H.health > -50)
		H.clear_fullscreen("robotlow")
		H.overlay_fullscreen("robothalf", /atom/movable/screen/fullscreen/machine/robothalf)
	else if(H.health <= -50)
		H.clear_fullscreen("robothalf")
		H.overlay_fullscreen("robotlow", /atom/movable/screen/fullscreen/machine/robotlow)
	else
		H.clear_fullscreen("robothalf")
		H.clear_fullscreen("robotlow")
	if(H.health > -25) //Staggerslowed if below crit threshold
		return
	H.Stagger(2 SECONDS)
	H.adjust_slowdown(1)

///Lets a robot repair itself over time at the cost of being stunned and blind
/datum/action/repair_self
	name = "Activate autorepair"
	action_icon_state = "suit_configure"
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_KB_ROBOT_AUTOREPAIR,
	)

/datum/action/repair_self/can_use_action(silent, override_flags, selecting)
	. = ..()
	if(!.)
		return
	return !owner.incapacitated()

/datum/action/repair_self/action_activate()
	. = ..()
	if(!. || !ishuman(owner))
		return
	var/mob/living/carbon/human/howner = owner
	if(!howner.getBruteLoss() && !howner.getFireLoss())
		return
	howner.apply_status_effect(STATUS_EFFECT_REPAIR_MODE, 10 SECONDS)
	howner.balloon_alert_to_viewers("repairing...")

/datum/species/robot/alpharii
	name = "Hammerhead Combat Robot"
	icobase = 'icons/mob/human_races/r_robot_alpharii.dmi'
	joinable_roundstart = FALSE

/datum/species/robot/charlit
	name = "Chilvaris Combat Robot"
	icobase = 'icons/mob/human_races/r_robot_charlit.dmi'
	joinable_roundstart = FALSE

/datum/species/robot/deltad
	name = "Ratcher Combat Robot"
	icobase = 'icons/mob/human_races/r_robot_deltad.dmi'
	joinable_roundstart = FALSE

/datum/species/robot/bravada
	name = "Sterling Combat Robot"
	icobase = 'icons/mob/human_races/r_robot_bravada.dmi'
	joinable_roundstart = FALSE
