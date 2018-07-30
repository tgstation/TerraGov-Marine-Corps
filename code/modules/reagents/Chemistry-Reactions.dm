///////////////////////////////////////////////////////////////////////////////////

/datum/chemical_reaction
	var/name = null
	var/id = null
	var/result = null
	var/list/required_reagents = new/list()
	var/list/required_catalysts = new/list()

	var/mob_react = TRUE //Determines if a chemical reaction can occur inside a mob

	// both vars below are currently unused
	var/atom/required_container = null // the container required for the reaction to happen
	var/required_other = 0 // an integer required for the reaction to happen

	var/result_amount = 0 //I recommend you set the result amount to the total volume of all components.
	var/secondary = 0 // set to nonzero if secondary reaction
	var/list/secondary_results = list()		//additional reagents produced by the reaction
	var/requires_heating = 0

/datum/chemical_reaction/proc/on_reaction(var/datum/reagents/holder, var/created_volume)
	return
