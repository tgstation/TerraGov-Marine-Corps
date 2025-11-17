/datum/scanner_advice/limbs
	priority = ADVICE_PRIORITY_LIMBS
	abstract_type = /datum/scanner_advice/limbs

/datum/scanner_advice/limbs/harmful_implants/can_show(mob/living/carbon/human/patient, mob/user)
	for(var/datum/limb/limb AS in patient.limbs)
		if(length(limb.implants))
			for(var/obj/item/embedded AS in limb.implants)
				if(embedded.is_beneficial_implant())
					continue
				return TRUE

/datum/scanner_advice/limbs/harmful_implants/get_data(mob/living/carbon/human/patient, mob/user)
	. = list(
		ADVICE_TEXT = "Remove embedded objects with tweezers.",
		ADVICE_TOOLTIP = "Embedded objects cause Brute damage. Allow some time to heal in between removing large amounts of implants to avoid internal damage.",
		ADVICE_ICON = FA_ICON_THUMBTACK,
		ADVICE_ICON_COLOR = "red",
	)

/datum/scanner_advice/limbs/internal_bleeding/can_show(mob/living/carbon/human/patient, mob/user)
	for(var/datum/limb/limb AS in patient.limbs)
		for(var/datum/wound/wound in limb.wounds)
			if(!istype(wound, /datum/wound/internal_bleeding))
				continue
			return TRUE

/datum/scanner_advice/limbs/internal_bleeding/get_data(mob/living/carbon/human/patient, mob/user)
	. = list(
		ADVICE_TEXT = "Administer Quick Clot/Quick Clot Plus or cryo treatment.",
		ADVICE_TOOLTIP = "Internal bleeding detected. Quick Clot will suppress it for a few minutes, while Quick Clot Plus or cryo treatment will cure it.",
		ADVICE_ICON = FA_ICON_SYRINGE,
		ADVICE_ICON_COLOR = COLOR_REAGENT_QUICKCLOT,
	)

/datum/scanner_advice/limbs/infection/can_show(mob/living/carbon/human/patient, mob/user)
	if(patient.reagents.has_reagent(/datum/reagent/medicine/spaceacillin))
		return FALSE
	for(var/datum/limb/limb AS in patient.limbs)
		if(limb.germ_level > INFECTION_LEVEL_ONE)
			return TRUE

/datum/scanner_advice/limbs/infection/get_data(mob/living/carbon/human/patient, mob/user)
	. = list(
		ADVICE_TEXT = "Administer a single dose of Spaceacillin. Infections detected.",
		ADVICE_TOOLTIP = "If left untreated, they may worsen into Necrosis and require surgery.",
		ADVICE_ICON = FA_ICON_TABLETS,
		ADVICE_ICON_COLOR = COLOR_REAGENT_SPACEACILLIN,
	)
