/datum/chemical_reaction
	/// ID of the reaction
	var/id
	/// Name of the reaction
	var/name
	///Results of the chemical reactions
	var/list/results = list()
	///Required chemicals that are USED in the reaction
	var/list/required_reagents = list()
	///Required chemicals that must be present in the container but are not USED.
	var/list/required_catalysts = list()

	///Determines if a chemical reaction can occur inside a mob
	var/mob_react = TRUE

	// Both of these variables are mostly unused
	/// the exact container path required for the reaction to happen
	var/atom/required_container
	/// an integer required for the reaction to happen
	var/required_other = 0

	///Required temperature for the reaction to begin
	var/required_temp = 0
	/// Set to TRUE if you want the recipe to only react when it's BELOW the required temp.
	var/is_cold_recipe = FALSE
	///The message shown to nearby people upon mixing, if applicable
	var/mix_message = "The solution begins to bubble."
	///The sound played upon mixing, if applicable
	var/mix_sound = 'sound/effects/bubbles.ogg'

	/// set to TRUE if you want something to be hidden from the ingame codex
	hidden_from_codex = TRUE


/**
 * Shit that happens on reaction
 *
 * Proc where the additional magic happens.
 * You dont want to handle mob spawning in this since there is a dedicated proc for that.client
 * Arguments:
 * * holder - the datum that holds this reagent, be it a beaker or anything else
 * * created_volume - volume created when this is mixed. look at 'var/list/results'.
 */
/datum/chemical_reaction/proc/on_reaction(datum/reagents/holder, created_volume)
	return
	//I recommend you set the result amount to the total volume of all components.
