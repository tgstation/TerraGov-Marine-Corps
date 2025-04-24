/// Fires when in critical condition, tells the user to administer Inaprovaline.
/datum/scanner_advice/crit_condition
	priority = ADVICE_PRIORITY_CRIT

/datum/scanner_advice/crit_condition/can_show(mob/living/carbon/human/patient, mob/user)
	if(patient.stat != DEAD && patient.health < patient.get_crit_threshold() && !(patient.species.species_flags & ROBOTIC_LIMBS))
		return TRUE

/datum/scanner_advice/crit_condition/get_data(mob/living/carbon/human/patient, mob/user)
	. = list(
		ADVICE_TEXT = "Administer a single dose of Inaprovaline.",
		ADVICE_TOOLTIP = "When used in critical condition, Inaprovaline prevents suffocation and heals the patient. This can only happen once every 5 minutes and only when the Inaprovaline enters the body.",
		ADVICE_ICON = FA_ICON_SYRINGE,
		ADVICE_ICON_COLOR = COLOR_REAGENT_INAPROVALINE
	)
