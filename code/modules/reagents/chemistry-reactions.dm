///////////////////////////////////////////////////////////////////////////////////

/datum/chemical_reaction
	var/name
	var/id
	var/list/results
	hidden_from_codex //codex
	var/list/required_reagents = list()
	var/list/required_catalysts = list()

	var/mob_react = TRUE //Determines if a chemical reaction can occur inside a mob

	// both vars below are currently unused
	var/atom/required_container // the container required for the reaction to happen
	var/required_other = FALSE // an integer required for the reaction to happen

	var/required_temp = 0
	var/is_cold_recipe = FALSE // Set to 1 if you want the recipe to only react when it's BELOW the required temp.
	var/mix_message = "The solution begins to bubble." //The message shown to nearby people upon mixing, if applicable
	var/mix_sound = 'sound/effects/bubbles.ogg' //The sound played upon mixing, if applicable

/datum/chemical_reaction/proc/on_reaction(datum/reagents/holder, created_volume)
	return
	//I recommend you set the result amount to the total volume of all components.