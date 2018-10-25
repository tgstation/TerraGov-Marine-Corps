
/datum/chemical_reaction/tricordrazine
	name = "Tricordrazine"
	id = "tricordrazine"
	results = list("tricordrazine" = 2)
	required_reagents = list("inaprovaline" = 1, "anti_toxin" = 1)
	mob_react = FALSE

/datum/chemical_reaction/alkysine
	name = "Alkysine"
	id = "alkysine"
	results = list("alkysine" = 2)
	required_reagents = list("chlorine" = 1, "nitrogen" = 1, "anti_toxin" = 1)

/datum/chemical_reaction/dexalin
	name = "Dexalin"
	id = "dexalin"
	results = list("dexalin" = 1)
	required_reagents = list("oxygen" = 2, "phoron" = 0.1)
	required_catalysts = list("phoron" = 5)

/datum/chemical_reaction/dermaline
	name = "Dermaline"
	id = "dermaline"
	results = list("dermaline" = 3)
	required_reagents = list("oxygen" = 1, "phosphorus" = 1, "kelotane" = 1)

/datum/chemical_reaction/dexalinplus
	name = "Dexalin Plus"
	id = "dexalinplus"
	results = list("dexalinplus" = 3)
	required_reagents = list("dexalin" = 1, "carbon" = 1, "iron" = 1)

/datum/chemical_reaction/bicaridine
	name = "Bicaridine"
	id = "bicaridine"
	results = list("bicaridine" = 2)
	required_reagents = list("inaprovaline" = 1, "carbon" = 1)

/datum/chemical_reaction/hyperzine
	name = "Hyperzine"
	id = "hyperzine"
	results = list("hyperzine" = 3)
	required_reagents = list("sugar" = 1, "phosphorus" = 1, "sulfur" = 1)

/datum/chemical_reaction/ryetalyn
	name = "Ryetalyn"
	id = "ryetalyn"
	results = list("ryetalyn" = 2)
	required_reagents = list("arithrazine" = 1, "carbon" = 1)

/datum/chemical_reaction/cryoxadone
	name = "Cryoxadone"
	id = "cryoxadone"
	results = list("cryoxadone" = 3)
	required_reagents = list("dexalin" = 1, "water" = 1, "oxygen" = 1)

/datum/chemical_reaction/clonexadone
	name = "Clonexadone"
	id = "clonexadone"
	results = list("clonexadone" = 2)
	required_reagents = list("cryoxadone" = 1, "sodium" = 1, "phoron" = 0.1)
	required_catalysts = list("phoron" = 5)

/datum/chemical_reaction/spaceacillin
	name = "Spaceacillin"
	id = "spaceacillin"
	results = list("spaceacillin" = 2)
	required_reagents = list("cryptobiolin" = 1, "inaprovaline" = 1)

/datum/chemical_reaction/imidazoline
	name = "imidazoline"
	id = "imidazoline"
	results = list("imidazoline" = 2)
	required_reagents = list("carbon" = 1, "hydrogen" = 1, "anti_toxin" = 1)

/datum/chemical_reaction/ethylredoxrazine
	name = "Ethylredoxrazine"
	id = "ethylredoxrazine"
	results = list("ethylredoxrazine" = 3)
	required_reagents = list("oxygen" = 1, "anti_toxin" = 1, "carbon" = 1)

/datum/chemical_reaction/ethanoloxidation
	name = "ethanoloxidation"	//Kind of a placeholder in case someone ever changes it so that chemicals
	id = "ethanoloxidation"		//	react in the body. Also it would be silly if it didn't exist.
	results = list("water" = 2) //H2O2 doesn't equal water, maybe change it in the future.
	required_reagents = list("ethylredoxrazine" = 1, "ethanol" = 1)

/datum/chemical_reaction/sterilizine
	name = "Sterilizine"
	id = "sterilizine"
	results = list("sterilizine" = 3)
	required_reagents = list("ethanol" = 1, "anti_toxin" = 1, "chlorine" = 1)

/datum/chemical_reaction/inaprovaline
	name = "Inaprovaline"
	id = "inaprovaline"
	results = list("inaprovaline" = 3)
	required_reagents = list("oxygen" = 1, "carbon" = 1, "sugar" = 1)

/datum/chemical_reaction/anti_toxin
	name = "Dylovene"
	id = "anti_toxin"
	results = list("anti_toxin" = 3)
	required_reagents = list("silicon" = 1, "potassium" = 1, "nitrogen" = 1)


/datum/chemical_reaction/tramadol
	name = "Tramadol"
	id = "tramadol"
	results = list("tramadol" = 3)
	required_reagents = list("inaprovaline" = 1, "ethanol" = 1, "oxygen" = 1)

/datum/chemical_reaction/paracetamol
	name = "Paracetamol"
	id = "paracetamol"
	results = list("paracetamol" = 3)
	required_reagents = list("tramadol" = 1, "sugar" = 1, "water" = 1)

/datum/chemical_reaction/oxycodone
	name = "Oxycodone"
	id = "oxycodone"
	results = list("oxycodone" = 1)
	required_reagents = list("ethanol" = 1, "tramadol" = 1)
	required_catalysts = list("phoron" = 1)

/datum/chemical_reaction/synaptizine
	name = "Synaptizine"
	id = "synaptizine"
	results = list("synaptizine" = 3)
	required_reagents = list("sugar" = 1, "lithium" = 1, "water" = 1)

/datum/chemical_reaction/leporazine
	name = "Leporazine"
	id = "leporazine"
	results = list("leporazine" = 2)
	required_reagents = list("silicon" = 1, "copper" = 1)
	required_catalysts = list("phoron" = 5)

/datum/chemical_reaction/hyronalin
	name = "Hyronalin"
	id = "hyronalin"
	results = list("hyronalin" = 2)
	required_reagents = list("radium" = 1, "anti_toxin" = 1)

/datum/chemical_reaction/arithrazine
	name = "Arithrazine"
	id = "arithrazine"
	results = list("arithrazine" = 2)
	required_reagents = list("hyronalin" = 1, "hydrogen" = 1)

/datum/chemical_reaction/kelotane
	name = "Kelotane"
	id = "kelotane"
	results = list("kelotane" = 2)
	required_reagents = list("silicon" = 1, "carbon" = 1)

/datum/chemical_reaction/peridaxon
	name = "Peridaxon"
	id = "peridaxon"
	results = list("peridaxon" = 2)
	required_reagents = list("bicaridine" = 2, "clonexadone" = 2)
	required_catalysts = list("phoron" = 5)

/datum/chemical_reaction/quickclot
	name = "Quickclot"
	id = "quickclot"
	results = list("quickclot" = 1)
	required_reagents = list("kelotane" = 2, "clonexadone" = 2)
	required_catalysts = list("phoron" = 5)


/datum/chemical_reaction/methylphenidate //TODO REMOVE OR MAKE IT NOT JUST A RP CHEM
	name = "Methylphenidate"
	id = "methylphenidate"
	results = list("methylphenidate" = 3)
	required_reagents = list("mindbreaker" = 1, "hydrogen" = 1)

/datum/chemical_reaction/citalopram //SAME AS ABOVE, RP CHEM
	name = "Citalopram"
	id = "citalopram"
	results = list("citalopram" = 3)
	required_reagents = list("mindbreaker" = 1, "carbon" = 1)

/datum/chemical_reaction/paroxetine//SAME, RP CHEM
	name = "Paroxetine"
	id = "paroxetine"
	results = list("paroxetine" = 3)
	required_reagents = list("mindbreaker" = 1, "oxygen" = 1, "inaprovaline" = 1)

/datum/chemical_reaction/hypervene //New purge chem.
	name = "Hypervene"
	id = "hypervene"
	results = list("hypervene" = 3)
	required_reagents = list("arithrazine" = 1, "dylovene" = 1, "ethylredoxrazine" = 1)