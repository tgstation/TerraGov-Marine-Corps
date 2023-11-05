/datum/chemical_reaction/ryetalyn
	name = "Ryetalyn"
	results = list(/datum/reagent/medicine/ryetalyn = 2)
	required_reagents = list(/datum/reagent/medicine/arithrazine = 1, /datum/reagent/carbon = 1)

/datum/chemical_reaction/synaptizine
	name = "Synaptizine"
	results = list(/datum/reagent/medicine/synaptizine = 3)
	required_reagents = list(/datum/reagent/consumable/sugar = 1, /datum/reagent/lithium = 1, /datum/reagent/water = 1)

/datum/chemical_reaction/hyronalin
	name = "Hyronalin"
	results = list(/datum/reagent/medicine/hyronalin = 2)
	required_reagents = list(/datum/reagent/radium = 1, /datum/reagent/medicine/dylovene = 1)

/datum/chemical_reaction/neuraline
	name = "Neuraline"
	results = list(/datum/reagent/medicine/neuraline = 4, /datum/reagent/toxin/huskpowder = 1)
	required_reagents = list(/datum/reagent/medicine/synaptizine = 1, /datum/reagent/medicine/arithrazine = 1, /datum/reagent/medicine/tricordrazine = 2)

/datum/chemical_reaction/somolent
	name = "Somolent"
	results = list(/datum/reagent/medicine/research/somolent = 4)
	required_reagents = list(/datum/reagent/toxin/sleeptoxin = 1, /datum/reagent/medicine/tricordrazine = 1, /datum/reagent/consumable/drink/doctor_delight = 1, /datum/reagent/medicine/paracetamol = 1)

/datum/chemical_reaction/stimulum
	name = "Stimulum"
	results = list(/datum/reagent/medicine/research/stimulon = 1)
	required_reagents = list(/datum/reagent/medicine/synaptizine = 10, /datum/reagent/medicine/arithrazine = 20, /datum/reagent/consumable/nutriment = 20)
