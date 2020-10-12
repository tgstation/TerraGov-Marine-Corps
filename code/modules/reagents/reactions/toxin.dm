////// Xeno Chem reactions
/datum/chemical_reaction/xeno_decaytoxin
    results = list(/datum/reagent/toxin/xeno_decaytoxin = 4)
    required_reagents = list(/datum/reagent/toxin/xeno_growthtoxin = 4, /datum/reagent/toxin/xeno_decaytoxin_catalyst = 0.1)
    required_catalysts = list(/datum/reagent/toxin/xeno_decaytoxin_catalyst = 1)
    mob_react = TRUE