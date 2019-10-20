
/datum/chemical_reaction/tricordrazine
	name = "Tricordrazine"
	results = list(/datum/reagent/medicine/tricordrazine = 2)
	required_reagents = list(/datum/reagent/medicine/inaprovaline = 1, /datum/reagent/medicine/dylovene = 1)
	mob_react = FALSE

/datum/chemical_reaction/alkysine
	name = "Alkysine"
	results = list(/datum/reagent/medicine/alkysine = 2)
	required_reagents = list(/datum/reagent/chlorine = 1, /datum/reagent/nitrogen = 1, /datum/reagent/medicine/dylovene = 1)

/datum/chemical_reaction/dexalin
	name = "Dexalin"
	results = list(/datum/reagent/medicine/dexalin = 1)
	required_reagents = list(/datum/reagent/oxygen = 2, /datum/reagent/toxin/phoron = 0.1)
	required_catalysts = list(/datum/reagent/toxin/phoron = 5)

/datum/chemical_reaction/dermaline
	name = "Dermaline"
	results = list(/datum/reagent/medicine/dermaline = 3)
	required_reagents = list(/datum/reagent/oxygen = 1, /datum/reagent/phosphorus = 1, /datum/reagent/medicine/kelotane = 1)

/datum/chemical_reaction/dexalinplus
	name = "Dexalin Plus"
	results = list(/datum/reagent/medicine/dexalinplus = 3)
	required_reagents = list(/datum/reagent/medicine/dexalin = 1, /datum/reagent/carbon = 1, /datum/reagent/iron = 1)

/datum/chemical_reaction/bicaridine
	name = "Bicaridine"
	results = list(/datum/reagent/medicine/bicaridine = 2)
	required_reagents = list(/datum/reagent/medicine/inaprovaline = 1, /datum/reagent/carbon = 1)

/datum/chemical_reaction/meralyne
	name = "Meralyne"
	results = list(/datum/reagent/medicine/meralyne = 2)
	required_reagents = list(/datum/reagent/medicine/inaprovaline = 1, /datum/reagent/medicine/bicaridine = 1, /datum/reagent/iron = 1)

/datum/chemical_reaction/hyperzine
	name = "Hyperzine"
	results = list(/datum/reagent/medicine/hyperzine = 3)
	required_reagents = list(/datum/reagent/consumable/sugar = 1, /datum/reagent/phosphorus = 1, /datum/reagent/sulfur = 1)

/datum/chemical_reaction/ryetalyn
	name = "Ryetalyn"
	results = list(/datum/reagent/medicine/ryetalyn = 2)
	required_reagents = list(/datum/reagent/medicine/arithrazine = 1, /datum/reagent/carbon = 1)

/datum/chemical_reaction/cryoxadone
	name = "Cryoxadone"
	results = list(/datum/reagent/medicine/cryoxadone = 3)
	required_reagents = list(/datum/reagent/medicine/dexalin = 1, /datum/reagent/water = 1, /datum/reagent/oxygen = 1)

/datum/chemical_reaction/clonexadone
	name = "Clonexadone"
	results = list(/datum/reagent/medicine/clonexadone = 2)
	required_reagents = list(/datum/reagent/medicine/cryoxadone = 1, /datum/reagent/sodium = 1, /datum/reagent/toxin/phoron = 0.1)
	required_catalysts = list(/datum/reagent/toxin/phoron = 5)

/datum/chemical_reaction/spaceacillin
	name = "Spaceacillin"
	results = list(/datum/reagent/medicine/spaceacillin = 2)
	required_reagents = list(/datum/reagent/cryptobiolin = 1, /datum/reagent/medicine/inaprovaline = 1)

/datum/chemical_reaction/imidazoline
	name = "imidazoline"
	results = list(/datum/reagent/medicine/imidazoline = 2)
	required_reagents = list(/datum/reagent/carbon = 1, /datum/reagent/hydrogen = 1, /datum/reagent/medicine/dylovene = 1)

/datum/chemical_reaction/ethylredoxrazine
	name = "Ethylredoxrazine"
	results = list(/datum/reagent/medicine/ethylredoxrazine = 3)
	required_reagents = list(/datum/reagent/oxygen = 1, /datum/reagent/medicine/dylovene = 1, /datum/reagent/carbon = 1)

/datum/chemical_reaction/ethanoloxidation
	name = "ethanoloxidation"	//Kind of a placeholder in case someone ever changes it so that chemicals
	results = list(/datum/reagent/water = 2) //H2O2 doesn't equal water, maybe change it in the future.
	required_reagents = list(/datum/reagent/medicine/ethylredoxrazine = 1, /datum/reagent/consumable/ethanol = 1)

/datum/chemical_reaction/sterilizine
	name = "Sterilizine"
	results = list(/datum/reagent/medicine/sterilizine = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol = 1, /datum/reagent/medicine/dylovene = 1, /datum/reagent/chlorine = 1)

/datum/chemical_reaction/inaprovaline
	name = "Inaprovaline"
	results = list(/datum/reagent/medicine/inaprovaline = 3)
	required_reagents = list(/datum/reagent/oxygen = 1, /datum/reagent/carbon = 1, /datum/reagent/consumable/sugar = 1)

/datum/chemical_reaction/dylovene
	name = "Dylovene"
	results = list(/datum/reagent/medicine/dylovene = 3)
	required_reagents = list(/datum/reagent/silicon = 1, /datum/reagent/potassium = 1, /datum/reagent/nitrogen = 1)


/datum/chemical_reaction/tramadol
	name = "Tramadol"
	results = list(/datum/reagent/medicine/tramadol = 3)
	required_reagents = list(/datum/reagent/medicine/inaprovaline = 1, /datum/reagent/consumable/ethanol = 1, /datum/reagent/oxygen = 1)

/datum/chemical_reaction/paracetamol
	name = "Paracetamol"
	results = list(/datum/reagent/medicine/paracetamol = 3)
	required_reagents = list(/datum/reagent/medicine/tramadol = 1, /datum/reagent/consumable/sugar = 1, /datum/reagent/water = 1)

/datum/chemical_reaction/oxycodone
	name = "Oxycodone"
	results = list(/datum/reagent/medicine/oxycodone = 1)
	required_reagents = list(/datum/reagent/consumable/ethanol = 1, /datum/reagent/medicine/tramadol = 1)
	required_catalysts = list(/datum/reagent/toxin/phoron = 1)

/datum/chemical_reaction/synaptizine
	name = "Synaptizine"
	results = list(/datum/reagent/medicine/synaptizine = 3)
	required_reagents = list(/datum/reagent/consumable/sugar = 1, /datum/reagent/lithium = 1, /datum/reagent/water = 1)

/datum/chemical_reaction/leporazine
	name = "Leporazine"
	results = list(/datum/reagent/medicine/leporazine = 2)
	required_reagents = list(/datum/reagent/silicon = 1, /datum/reagent/copper = 1)
	required_catalysts = list(/datum/reagent/toxin/phoron = 5)

/datum/chemical_reaction/hyronalin
	name = "Hyronalin"
	results = list(/datum/reagent/medicine/hyronalin = 2)
	required_reagents = list(/datum/reagent/radium = 1, /datum/reagent/medicine/dylovene = 1)

/datum/chemical_reaction/arithrazine
	name = "Arithrazine"
	results = list(/datum/reagent/medicine/arithrazine = 2)
	required_reagents = list(/datum/reagent/medicine/hyronalin = 1, /datum/reagent/hydrogen = 1)

/datum/chemical_reaction/kelotane
	name = "Kelotane"
	results = list(/datum/reagent/medicine/kelotane = 2)
	required_reagents = list(/datum/reagent/silicon = 1, /datum/reagent/carbon = 1)

/datum/chemical_reaction/peridaxon
	name = "Peridaxon"
	results = list(/datum/reagent/medicine/peridaxon = 2)
	required_reagents = list(/datum/reagent/medicine/bicaridine = 2, /datum/reagent/medicine/clonexadone = 2)
	required_catalysts = list(/datum/reagent/toxin/phoron = 5)

/datum/chemical_reaction/quickclot
	name = "Quick-Clot"
	results = list(/datum/reagent/medicine/quickclot = 1)
	required_reagents = list(/datum/reagent/medicine/kelotane = 2, /datum/reagent/medicine/clonexadone = 2)
	required_catalysts = list(/datum/reagent/toxin/phoron = 5)


/datum/chemical_reaction/methylphenidate //TODO REMOVE OR MAKE IT NOT JUST A RP CHEM
	name = "Methylphenidate"
	results = list(/datum/reagent/medicine/antidepressant/methylphenidate = 3)
	required_reagents = list(/datum/reagent/toxin/mindbreaker = 1, /datum/reagent/hydrogen = 1)

/datum/chemical_reaction/citalopram //SAME AS ABOVE, RP CHEM
	name = "Citalopram"
	results = list(/datum/reagent/medicine/antidepressant/citalopram = 3)
	required_reagents = list(/datum/reagent/toxin/mindbreaker = 1, /datum/reagent/carbon = 1)

/datum/chemical_reaction/paroxetine//SAME, RP CHEM
	name = "Paroxetine"
	results = list(/datum/reagent/medicine/antidepressant/paroxetine = 3)
	required_reagents = list(/datum/reagent/toxin/mindbreaker = 1, /datum/reagent/oxygen = 1, /datum/reagent/medicine/inaprovaline = 1)

/datum/chemical_reaction/hypervene //New purge chem.
	name = "Hypervene"
	results = list(/datum/reagent/medicine/hypervene = 3)
	required_reagents = list(/datum/reagent/medicine/arithrazine = 1, /datum/reagent/medicine/dylovene = 1, /datum/reagent/medicine/ethylredoxrazine = 1)
