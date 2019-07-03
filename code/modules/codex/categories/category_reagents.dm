/datum/codex_category/reagents/Initialize()

	for(var/thing in GLOB.chemical_reagents_list)
		var/datum/reagent/reagent = GLOB.chemical_reagents_list[thing]
		if(reagent.hidden_from_codex)
			continue
		var/chem_name = lowertext(reagent.name)
		var/datum/codex_entry/entry = new( \
		_display_name = "[chem_name] (chemical)", \
		_associated_strings = list("[chem_name] pill"), \
		_lore_text = "[reagent.description] It apparently tastes of [reagent.taste_description].")

		var/list/production_strings = list()
		for(var/react in GLOB.chemical_reactions_list[reagent.id])

			var/datum/chemical_reaction/reaction = react

			if(reaction.hidden_from_codex)
				continue

			var/list/reactant_values = list()
			for(var/reactant_id in reaction.required_reagents)
				var/datum/reagent/reactant = GLOB.chemical_reagents_list[reactant_id]
				reactant_values += "[reaction.required_reagents[reactant_id]]u [lowertext(reactant.name)]"

			if(!reactant_values.len)
				continue

			var/list/catalysts = list()
			for(var/catalyst_id in reaction.required_catalysts)
				var/datum/reagent/catalyst = GLOB.chemical_reagents_list[catalyst_id]
				catalysts += "[reaction.required_catalysts[catalyst_id]]u [lowertext(catalyst.name)]"

			var/list/results = list()
			for(var/result_id in reaction.results)
				var/datum/reagent/result = GLOB.chemical_reagents_list[result_id]
				results += "[reaction.results[result_id]]u [lowertext(result.name)]"

			production_strings += "- [jointext(reactant_values, " + ")]"

			if(catalysts.len)
				production_strings += "(catalysts: [jointext(catalysts, ", ")])"

			production_strings += ": [jointext(results, ", ")]"

		if(production_strings.len)
			if(!entry.mechanics_text)
				entry.mechanics_text = "It can be produced as follows:<br>"
			else
				entry.mechanics_text += "<br><br>It can be produced as follows:<br>"
			entry.mechanics_text += jointext(production_strings, "<br>")

		SScodex.entries_by_string[entry.display_name] = entry