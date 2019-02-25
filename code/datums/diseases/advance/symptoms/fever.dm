/*
//////////////////////////////////////

Fever

	No change to hidden.
	Increases resistance.
	Increases stage speed.
	Little transmittable.
	Low level.

Bonus
	Heats up your body.

//////////////////////////////////////
*/

/datum/symptom/fever

	name = "Fever"
	stealth = 0
	resistance = 3
	stage_speed = 3
	transmittable = 2
	level = 2

/datum/symptom/fever/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/carbon/M = A.affected_mob
		to_chat(M, "<span class='notice'>[pick("You feel hot.", "You feel like you're burning.")]</span>")
		M.adjust_bodytemperature((10 * A.stage * TEMPERATURE_DAMAGE_COEFFICIENT), 0, BODYTEMP_HEAT_DAMAGE_LIMIT_ONE - 1)
	return
