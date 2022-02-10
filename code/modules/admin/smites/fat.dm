/// Fattens the target
/datum/smite/fat
	name = "Fatten up"

/datum/smite/fat/effect(client/user, mob/living/carbon/C)
	. = ..()

	if (!ishuman(C))
		to_chat(user, span_warning("Xenomorphs subsist only on a diet of marine salt. Aborting."), confidential = TRUE)
		return

	to_chat(C, span_warning("Your breathing becomes labored as you suddenly feel like you weigh 1000 lbs..."), confidential = TRUE)
	C.set_nutrition(NUTRITION_OVERFED * 2)
