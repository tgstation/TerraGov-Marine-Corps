/datum/reagent/medicine/clone
	name = "Clone" // 3 random characters
	var/for_blood_type = null
/datum/reagent/medicine/clone/New()
	name = "[initial(name)] [ascii2text(rand(65, 87))][ascii2text(rand(65, 87))][ascii2text(rand(65, 87))]" // 3 random characters

/datum/reagent/medicine/clone/blood_a
	for_blood_type = "A"

/datum/reagent/medicine/clone/blood_b
	for_blood_type = "B"

/datum/reagent/medicine/clone/blood_ab
	for_blood_type = "AB"

/datum/reagent/medicine/clone/blood_o
	for_blood_type = "O"

/datum/reagent/medicine/biomass
	name = "Biomass"

/datum/reagent/medicine/biomass/xeno
	name = "Converted Biomass"
