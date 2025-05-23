/// Fires when the patient has an embryo in them. Appears first for obvious reasons.
/datum/scanner_advice/implanted_embryo
	priority = ADVICE_PRIORITY_EMBRYO

/datum/scanner_advice/implanted_embryo/can_show(mob/living/carbon/human/patient, mob/user)
	return (patient.status_flags & XENO_HOST)

/datum/scanner_advice/implanted_embryo/get_data(mob/living/carbon/human/patient, mob/user)
	. = list(
		ADVICE_TEXT = "Alien embryo detected—immediate surgical intervention advised.", // friend detected :)
		ADVICE_TOOLTIP = "The patient has been implanted with an alien embryo! Left untreated, it will burst out of their chest. Surgical intervention is strongly advised.",
		ADVICE_ICON = FA_ICON_WORM,
		ADVICE_ICON_COLOR = "orange"
	)
