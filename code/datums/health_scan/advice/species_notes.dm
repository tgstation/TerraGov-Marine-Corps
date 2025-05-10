/// Fires with some species to explain species characteristics.
/// I want to kill these in the future for a less intrusive system,
/// but for now I'm importing them into the new advice system.
/datum/scanner_advice/species
	priority = ADVICE_PRIORITY_SPECIES
	abstract_type = /datum/scanner_advice/species

/datum/scanner_advice/species/combat_robot/can_show(mob/living/carbon/human/patient, mob/user)
	return isrobot(patient)

/datum/scanner_advice/species/combat_robot/get_data(mob/living/carbon/human/patient, mob/user)
	. = list()
	. += list(list(
		ADVICE_TEXT = "Combat Robot: Patient can be immediately defibrillated.",
		ADVICE_TOOLTIP = "Combat Robots can be defibrillated regardless of health. It is highly advised to defibrillate them the moment their armor is removed instead of attempting repair.",
		ADVICE_ICON = FA_ICON_ROBOT,
		ADVICE_ICON_COLOR = "label"
	))
	. += list(list(
		ADVICE_TEXT = "Combat Robot: Patient does not enter critical condition.",
		ADVICE_TOOLTIP = "Combat Robots do not enter critical condition. They will continue operating until death at [patient.get_death_threshold() / patient.maxHealth * 100]% health.",
		ADVICE_ICON = FA_ICON_ROBOT,
		ADVICE_ICON_COLOR = "label"
	))

/datum/scanner_advice/species/synthetic/can_show(mob/living/carbon/human/patient, mob/user)
	return issynth(patient)

/datum/scanner_advice/species/synthetic/get_data(mob/living/carbon/human/patient, mob/user)
	. = list()
	. += list(list(
		ADVICE_TEXT = "Synthetic: Patient does not heal on defibrillation.",
		ADVICE_TOOLTIP = "Synthetics do not heal when being shocked with a defibrillator, meaning they are only revivable over [patient.get_death_threshold() / patient.maxHealth * 100]% health.",
		ADVICE_ICON = FA_ICON_ROBOT,
		ADVICE_ICON_COLOR = "label"
	))
	. += list(list(
		ADVICE_TEXT = "Synthetic: Patient overheats while lower than [SYNTHETIC_CRIT_THRESHOLD / patient.maxHealth * 100]% health.",
		ADVICE_TOOLTIP = "Synthetics overheat rapidly while their health is lower than [SYNTHETIC_CRIT_THRESHOLD / patient.maxHealth * 100]%. When defibrillating, the patient should be repaired above this threshold to avoid unnecessary burning.",
		ADVICE_ICON = FA_ICON_ROBOT,
		ADVICE_ICON_COLOR = "label"
	))
	. += list(list(
		ADVICE_TEXT = "Synthetic: Patient does not suffer from brain-death.",
		ADVICE_TOOLTIP = "Synthetics don't expire after 5 minutes of death.",
		ADVICE_ICON = FA_ICON_ROBOT,
		ADVICE_ICON_COLOR = "label"
	))
