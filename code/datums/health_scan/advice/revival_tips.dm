/// Fires when dead, provides braindeath ETA and a revival "checklist".
/datum/scanner_advice/revival_tips
	priority = ADVICE_PRIORITY_REVIVAL

/datum/scanner_advice/revival_tips/can_show(mob/living/carbon/human/patient, mob/user)
	if(patient.stat == DEAD)
		return TRUE

/datum/scanner_advice/revival_tips/get_data(mob/living/carbon/human/patient, mob/user)
	. = list()

	if(!issynth(patient)) // specifically checking for synths here because synths don't expire but robots do
		var/dead_color
		switch(patient.dead_ticks)
			if(0 to 0.4 * TIME_BEFORE_DNR)
				dead_color = "yellow"
			if(0.4 * TIME_BEFORE_DNR to 0.8 * TIME_BEFORE_DNR)
				dead_color = "orange"
			if(0.8 * TIME_BEFORE_DNR to INFINITY)
				dead_color = "red"
		. += list(list(
			ADVICE_TEXT = "Time remaining to revive: [DisplayTimeText((TIME_BEFORE_DNR-(patient.dead_ticks)) * (SSmobs.wait * 4))].",
			ADVICE_TOOLTIP = "The patient can't be revived after this long. Stasis bags pause this timer, and being revived resets it, even if the patient dies again.",
			ADVICE_ICON = FA_ICON_HEART_PULSE,
			ADVICE_ICON_COLOR = dead_color,
		))

	if(patient.wear_suit?.atom_flags & CONDUCT)
		. += list(list(
			ADVICE_TEXT = "Remove patient's suit or armor.",
			ADVICE_TOOLTIP = "Conductive suits and armor will prevent defibrillation until removed.",
			ADVICE_ICON = FA_ICON_VEST,
			ADVICE_ICON_COLOR = "blue",
		))

	var/state = patient.check_defib(DEFIBRILLATOR_HEALING_TIMES_SKILL(user.skills.getRating(SKILL_MEDICAL), DEFIBRILLATOR_BASE_HEALING_VALUE))
	if(state & DEFIB_POSSIBLE)
		. += list(list(
			ADVICE_TEXT = "Administer shock via defibrillator!",
			ADVICE_TOOLTIP = "The patient is ready to be revived! Resuscitate them as soon as possible!",
			ADVICE_ICON = FA_ICON_BOLT,
			ADVICE_ICON_COLOR = "yellow",
		))
