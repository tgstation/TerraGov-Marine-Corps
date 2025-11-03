/datum/scanner_advice/damage/ear_alky/can_show(mob/living/carbon/human/patient, mob/user)
	if((patient.get_ear_damage() > 0 || patient.get_ear_deaf() > 0) && !patient.reagents.has_reagent(/datum/reagent/medicine/alkysine))
		return TRUE

/datum/scanner_advice/damage/ear_alky/get_data(mob/living/carbon/human/patient, mob/user)
	var/ear_damage = patient.get_ear_damage()
	var/ear_deaf = patient.get_ear_deaf()
	var/ismild = ear_damage < 100


	. = list(
		ADVICE_TEXT = "Administer a single dose of Alkysine.",
		ADVICE_TOOLTIP = "[ismild ? "Mild" : "Severe"] ear damage detected. Alkysine heals ear damage. If left untreated, patient may be unable to hear things. The damage is [ismild ? "" : "not "]mild enough to heal naturally over time without treatment.[ismild  && ear_deaf ? " Temporary deafness will wear off in [ceil(ear_deaf*2)] seconds without treatment." : ""][ismild && ear_damage ? "Ear damage will wear off in [ceil(ear_damage*40)] seconds without treatment.": ""]",
		ADVICE_ICON = FA_ICON_CAPSULES,
		ADVICE_ICON_COLOR = COLOR_REAGENT_ALKYSINE,
	)

/datum/scanner_advice/damage/earmuffs/can_show(mob/living/carbon/human/patient, mob/user)
	if((patient.get_ear_damage() > 0 || patient.get_ear_deaf() > 0) && !istype(patient.wear_ear, /obj/item/clothing/ears/earmuffs))
		return TRUE

/datum/scanner_advice/damage/earmuffs/get_data(mob/living/carbon/human/patient, mob/user)
	var/ear_damage = patient.get_ear_damage()
	var/ear_deaf = patient.get_ear_deaf()
	var/ismild = ear_damage < 100

	. = list(
		ADVICE_TEXT = "Place earmuffs over the patient's ears.",
		ADVICE_TOOLTIP = "[ismild ? "Mild" : "Severe"] ear damage detected. Earmuffs heal ear damage by protecting the ear from sounds. Even quiet sounds can prevent healing of severe ear damage and delay healing of mild ear damage. If left untreated, patient may be unable to hear things. The damage is [ismild ? "" : "not "]mild enough to heal naturally over time without treatment.[ismild  && ear_deaf ? " Temporary deafness will wear off in [ceil(ear_deaf*2)] seconds without treatment." : ""][ismild && ear_damage ? "Ear damage will wear off in [ceil(ear_damage*40)] seconds without treatment.": ""]",
		ADVICE_ICON = FA_ICON_HEADPHONES,
		ADVICE_ICON_COLOR = COLOR_REAGENT_ALKYSINE,
	)
