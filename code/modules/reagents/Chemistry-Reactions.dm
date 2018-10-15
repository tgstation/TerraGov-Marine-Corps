///////////////////////////////////////////////////////////////////////////////////

/datum/chemical_reaction
	var/name = null
	var/id = null
	var/list/results = null
	var/list/required_reagents = new/list()
	var/list/required_catalysts = new/list()

	var/mob_react = TRUE //Determines if a chemical reaction can occur inside a mob

	// both vars below are currently unused
	var/atom/required_container = null // the container required for the reaction to happen
	var/required_other = 0 // an integer required for the reaction to happen

	var/required_temp = 0
	var/is_cold_recipe = 0 // Set to 1 if you want the recipe to only react when it's BELOW the required temp.
	var/mix_message = "The solution begins to bubble." //The message shown to nearby people upon mixing, if applicable
	var/mix_sound = 'sound/effects/bubbles.ogg' //The sound played upon mixing, if applicable

/datum/chemical_reaction/proc/on_reaction(var/datum/reagents/holder, var/created_volume)
	return
	//I recommend you set the result amount to the total volume of all components.