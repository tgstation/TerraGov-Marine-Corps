/// Each subtype fires when we have a certain level of a damage type
/datum/scanner_advice/damage
	priority = ADVICE_PRIORITY_DAMAGE
	abstract_type = /datum/scanner_advice/damage

/datum/scanner_advice/damage/brute/can_show(mob/living/carbon/human/patient, mob/user)
	return (patient.getBruteLoss() > 5)

/datum/scanner_advice/damage/brute/get_data(mob/living/carbon/human/patient, mob/user)
	. = list()
	if(!(patient.species.species_flags & (IS_SYNTHETIC|ROBOTIC_LIMBS)))
		. += list(list(
			ADVICE_TEXT = "Use trauma kits or sutures to repair the bruised areas.",
			ADVICE_TOOLTIP = "Advanced trauma kits will heal brute damage, scaling with how proficient you are in the Medical field. Treated wounds slowly heal on their own.",
			ADVICE_ICON = FA_ICON_KIT_MEDICAL,
			ADVICE_ICON_COLOR = "#5EBB9E"
		))
		if(patient.getBruteLoss() > 30 && !patient.reagents.has_reagent(/datum/reagent/medicalnanites) && !patient.reagents.has_reagent(/datum/reagent/medicine/bicaridine, 3))
			. += list(list(
				ADVICE_TEXT = "Administer a single dose of Bicaridine to reduce physical trauma.",
				ADVICE_TOOLTIP = "Significant physical trauma detected. Bicaridine reduces brute damage.",
				ADVICE_ICON = FA_ICON_CAPSULES,
				ADVICE_ICON_COLOR = COLOR_REAGENT_BICARIDINE
			))
	else
		. += list(list(
			ADVICE_TEXT = "Use a blowtorch or nanopaste to repair the dented areas.",
			ADVICE_TOOLTIP = "Only a blowtorch or nanopaste can repair dented robotic limbs.",
			ADVICE_ICON = FA_ICON_TOOLS,
			ADVICE_ICON_COLOR = "red"
		))

/datum/scanner_advice/damage/burn/can_show(mob/living/carbon/human/patient, mob/user)
	return (patient.getFireLoss() > 5)

/datum/scanner_advice/damage/burn/get_data(mob/living/carbon/human/patient, mob/user)
	. = list()
	if(!(patient.species.species_flags & (IS_SYNTHETIC|ROBOTIC_LIMBS)))
		. += list(list(
			ADVICE_TEXT = "Use burn kits or sutures to repair the burned areas.",
			ADVICE_TOOLTIP = "Advanced burn kits will heal burn damage, scaling with how proficient you are in the Medical field. Treated wounds slowly heal on their own.",
			ADVICE_ICON = FA_ICON_KIT_MEDICAL,
			ADVICE_ICON_COLOR = "#D38956"
		))
		if(patient.getFireLoss() > 30 && !patient.reagents.has_reagent(/datum/reagent/medicalnanites) && !patient.reagents.has_reagent(/datum/reagent/medicine/kelotane, 3))
			. += list(list(
				ADVICE_TEXT = "Administer a single dose of Kelotane to reduce burns.",
				ADVICE_TOOLTIP = "Significant tissue burns detected. Kelotane reduces burn damage.",
				ADVICE_ICON = FA_ICON_CAPSULES,
				ADVICE_ICON_COLOR = COLOR_REAGENT_KELOTANE
			))
	else
		. += list(list(
			ADVICE_TEXT = "Use cable coils or nanopaste to repair the scorched areas.",
			ADVICE_TOOLTIP = "Only cable coils or nanopaste can repair scorched robotic limbs.",
			ADVICE_ICON = FA_ICON_PLUG,
			ADVICE_ICON_COLOR = "orange"
		))

/datum/scanner_advice/damage/tox/can_show(mob/living/carbon/human/patient, mob/user)
	var/has_dylovene = patient.reagents.has_reagent(/datum/reagent/medicine/dylovene, 3)
	for(var/datum/reagent/reagent AS in patient.reagents.reagent_list)
		if(!reagent.scannable)
			continue
		if(istype(reagent, /datum/reagent/toxin) && !has_dylovene)
			return TRUE
	if(patient.getToxLoss() > 15 && !has_dylovene)
		return TRUE

/datum/scanner_advice/damage/tox/get_data(mob/living/carbon/human/patient, mob/user)
	. = list(
		ADVICE_TEXT = "Administer a single dose of Dylovene.",
		ADVICE_TOOLTIP = "Toxic chemicals or significant blood toxins detected. Dylovene will reduce toxin damage, or their liver will filter it out on its own if it isn't damaged.",
		ADVICE_ICON = FA_ICON_CAPSULES,
		ADVICE_ICON_COLOR = COLOR_REAGENT_DYLOVENE
	)

/datum/scanner_advice/damage/oxy/can_show(mob/living/carbon/human/patient, mob/user)
	if(patient.getOxyLoss() > 25 && !patient.reagents.has_reagent(/datum/reagent/medicine/dexalinplus))
		return TRUE

/datum/scanner_advice/damage/oxy/get_data(mob/living/carbon/human/patient, mob/user)
	. = list(
		ADVICE_TEXT = "Administer a single dose of Dexalin Plus to re-oxygenate patient's blood.",
		ADVICE_TOOLTIP = "If you don't have Dexalin or Dexalin Plus, CPR or treating their other symptoms and waiting for their bloodstream to re-oxygenate will work.",
		ADVICE_ICON = FA_ICON_SYRINGE,
		ADVICE_ICON_COLOR = COLOR_REAGENT_DEXALIN
	)

/datum/scanner_advice/damage/clone/can_show(mob/living/carbon/human/patient, mob/user)
	return (patient.getCloneLoss() > 5)

/datum/scanner_advice/damage/clone/get_data(mob/living/carbon/human/patient, mob/user)
	var/organic_patient = !(patient.species.species_flags & (IS_SYNTHETIC|ROBOTIC_LIMBS))
	. = list(
		ADVICE_TEXT = organic_patient ? "Patient should sleep or seek cryo treatment - cellular damage." : "Patient should seek a robotic cradle - integrity damage.",
		ADVICE_TOOLTIP = "[organic_patient ? "Cellular damage" : "Integrity damage"] is sustained from psychic draining, special chemicals and special weapons. It can only be healed through the aforementioned methods.",
		ADVICE_ICON = organic_patient ? FA_ICON_DNA : FA_ICON_WRENCH,
		ADVICE_ICON_COLOR = "teal"
	)

/datum/scanner_advice/damage/brain/can_show(mob/living/carbon/human/patient, mob/user)
	var/datum/internal_organ/brain/brain = patient.get_organ_slot(ORGAN_SLOT_BRAIN)
	if(isnull(brain))
		return FALSE
	if(brain.organ_status != ORGAN_HEALTHY && !patient.reagents.has_reagent(/datum/reagent/medicine/alkysine))
		return TRUE

/datum/scanner_advice/damage/brain/get_data(mob/living/carbon/human/patient, mob/user)
	. = list(
		ADVICE_TEXT = "Administer a single dose of Alkysine.",
		ADVICE_TOOLTIP = "Significant brain damage detected. Alkysine heals brain damage. If left untreated, patient may be unable to function well.",
		ADVICE_ICON = FA_ICON_CAPSULES,
		ADVICE_ICON_COLOR = COLOR_REAGENT_ALKYSINE
	)

/datum/scanner_advice/damage/eyes/can_show(mob/living/carbon/human/patient, mob/user)
	var/datum/internal_organ/eyes/eyes = patient.get_organ_slot(ORGAN_SLOT_EYES)
	if(isnull(eyes))
		return FALSE
	if(eyes.organ_status != ORGAN_HEALTHY && !patient.reagents.has_reagent(/datum/reagent/medicine/imidazoline))
		return TRUE

/datum/scanner_advice/damage/eyes/get_data(mob/living/carbon/human/patient, mob/user)
	. = list(
		ADVICE_TEXT = "Administer a single dose of Imidazoline.",
		ADVICE_TOOLTIP = "Eye damage detected. Imidazoline heals eye damage. If left untreated, patient may be unable to see properly.",
		ADVICE_ICON = FA_ICON_CAPSULES,
		ADVICE_ICON_COLOR = COLOR_REAGENT_IMIDAZOLINE
	)
