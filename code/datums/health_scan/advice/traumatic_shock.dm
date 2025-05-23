/// Fires when shock stage is severe enough to hurt combat ability.
/datum/scanner_advice/traumatic_shock
	priority = ADVICE_PRIORITY_SHOCK

/datum/scanner_advice/traumatic_shock/can_show(mob/living/carbon/human/patient, mob/user)
	if(patient.reagents.has_reagent(/datum/reagent/medicalnanites) || patient.reagents.has_reagent(/datum/reagent/medicine/paracetamol))
		return FALSE
	if(patient.traumatic_shock > 40 && !patient.reagents.has_reagent(/datum/reagent/medicine/tramadol))
		return TRUE

/datum/scanner_advice/traumatic_shock/get_data(mob/living/carbon/human/patient, mob/user)
	. = list(
		ADVICE_TEXT = "Administer a single dose of Tramadol to reduce pain.",
		ADVICE_TOOLTIP = "The patient is experiencing performance impeding pain and may suffer symptoms from sluggishness to collapsing. Tramadol is the most common painkiller and reduces pain.",
		ADVICE_ICON = FA_ICON_TABLETS,
		ADVICE_ICON_COLOR = COLOR_REAGENT_TRAMADOL
	)
