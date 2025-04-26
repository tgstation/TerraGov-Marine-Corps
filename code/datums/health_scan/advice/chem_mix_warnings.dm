/// Fires when we have chemicals that should be completely isolated, like paracetamol or nanites.
/// This is high priority because giving medicine to a nanites user is just wasteful
/// and giving Tramadol to a Paracetamol user is very annoying.
/datum/scanner_advice/chem_mix_warning
	priority = ADVICE_PRIORITY_CHEM_MIX
	abstract_type = /datum/scanner_advice/chem_mix_warning

/datum/scanner_advice/chem_mix_warning/has_paracetamol/can_show(mob/living/carbon/human/patient, mob/user)
	return patient.reagents.has_reagent(/datum/reagent/medicine/paracetamol)

/datum/scanner_advice/chem_mix_warning/has_paracetamol/get_data(mob/living/carbon/human/patient, mob/user)
	. = list(
		ADVICE_TEXT = "Paracetamol detected—do NOT administer Tramadol.",
		ADVICE_TOOLTIP = "The patient has Paracetamol in their system. If Tramadol is administered, it will combine with Paracetamol to make a debilitating chemical.",
		ADVICE_ICON = FA_ICON_WINDOW_CLOSE,
		ADVICE_ICON_COLOR = "red"
	)

/datum/scanner_advice/chem_mix_warning/has_helpful_nanites/can_show(mob/living/carbon/human/patient, mob/user)
	return patient.reagents.has_reagent(/datum/reagent/medicalnanites)

/datum/scanner_advice/chem_mix_warning/has_helpful_nanites/get_data(mob/living/carbon/human/patient, mob/user)
	. = list(
		ADVICE_TEXT = "Nanites detected—only administer Peridaxon Plus, QuickClot and Dylovene.",
		ADVICE_TOOLTIP = "Nanites rapidly purge all medicines except Peridaxon Plus, Quick Clot/Quick Clot Plus and Dylovene.",
		ADVICE_ICON = FA_ICON_WINDOW_CLOSE,
		ADVICE_ICON_COLOR = COLOR_REAGENT_MEDICALNANITES
	)
