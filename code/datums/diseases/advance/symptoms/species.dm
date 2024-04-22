/datum/symptom/undead_adaptation
	name = "Necrotic Metabolism"
	desc = ""
	stealth = 2
	resistance = -2
	stage_speed = 1
	transmittable = 0
	level = 5
	severity = 0

/datum/symptom/undead_adaptation/OnAdd(datum/disease/advance/A)
	A.process_dead = TRUE
	A.infectable_biotypes |= MOB_UNDEAD

/datum/symptom/undead_adaptation/OnRemove(datum/disease/advance/A)
	A.process_dead = FALSE
	A.infectable_biotypes &= ~MOB_UNDEAD

/datum/symptom/inorganic_adaptation
	name = "Inorganic Biology"
	desc = ""
	stealth = -1
	resistance = 4
	stage_speed = -2
	transmittable = 3
	level = 5
	severity = 0

/datum/symptom/inorganic_adaptation/OnAdd(datum/disease/advance/A)
	A.infectable_biotypes |= MOB_MINERAL //Mineral covers plasmamen and golems.

/datum/symptom/inorganic_adaptation/OnRemove(datum/disease/advance/A)
	A.infectable_biotypes &= ~MOB_MINERAL

