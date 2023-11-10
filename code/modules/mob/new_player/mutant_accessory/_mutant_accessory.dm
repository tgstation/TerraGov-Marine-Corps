GLOBAL_LIST_EMPTY(generic_accessories)
GLOBAL_LIST_INIT_TYPED(mutant_accessories, /list, InitMutantAccessories())

/proc/InitMutantAccessories()
	var/list/compiled = list()
	// Here we build the global list for all accessories
	for(var/path in subtypesof(/datum/mutant_accessory))
		var/datum/mutant_accessory/P = path
		if(initial(P.key) && initial(P.name))
			P = new path()
			if(!compiled[P.key])
				compiled[P.key] = list()
			compiled[P.key][P.name] = P
			//TODO: Replace "generic" definitions with something better
			if(P.generic && !GLOB.generic_accessories[P.key])
				GLOB.generic_accessories[P.key] = P.generic
	return compiled

/datum/mutant_accessory
	/// Name of the accessory
	var/name
	/// Which key is used for this accessory
	var/key
	/// Whats the generic name of its type (Wings, Horns etc.)
	var/generic
	/// Icon file of this accessory
	var/icon
	/// Icon state of this accessory
	var/icon_state
	/// If true, then it wont be an available choice from prefs
	var/locked
	/// If has an organ type, this mutant bodypart will grant the organ too
	var/organ_type
	/// Whether an accessory actually exists, if it doesnt then it will only be recorded in DNA. (Important for "None" selections or non-standard choices such as leg type)
	var/factual = TRUE
	/// Which color source does it take from. USE_ONE_COLOR or USE_MATRIXED_COLORS allow customization choices
	var/color_src = USE_ONE_COLOR
	/// Which species can take it. If null then all can (The species needs a key in their default mutant bodyparts for this too)
	var/list/allowed_species
	/// Which layers get rendered for this accessory
	var/list/relevent_layers = list(BODY_BEHIND_LAYER, BODY_ADJ_LAYER, BODY_FRONT_LAYER)

	/// Which gender is allowed to take it. if null then all can
	var/gender
	/// Whether it gets a special sprite for genders
	var/gender_specific

	/// It's x dimension
	var/dimension_x = 32
	/// It's y dimension
	var/dimension_y = 32
	/// Whether to center the sprite. Important for non standard dimensions
	var/center

	/// Whether the accessory can have a special icon_state to render, i.e. wagging tails
	var/special_render_case

	/// Whether it has any extras to render, and their appropriate color sources. You cant use the customizable keys for this
	var/extra
	var/extra_color_src
	var/extra2
	var/extra2_color_src

	///Which color we default to on acquisition of the accessory (such as switching species, default color for character customization etc)
	///You can also put down a a HEX color, to be used instead as the default
	var/default_color

	var/special_colorize

	var/always_color_customizable

/datum/mutant_accessory/New()
	if(!default_color)
		switch(color_src)
			if(USE_ONE_COLOR)
				default_color = DEFAULT_PRIMARY
			if(USE_MATRIXED_COLORS)
				default_color = DEFAULT_MATRIXED
			else
				default_color = "FFFFFF"
	if(name == "None")
		factual = FALSE
	if(color_src == USE_MATRIXED_COLORS && default_color != DEFAULT_MATRIXED)
		default_color = DEFAULT_MATRIXED

/datum/mutant_accessory/proc/is_hidden(mob/living/carbon/human/H)
	return

/datum/mutant_accessory/proc/get_special_render_state(mob/living/carbon/human/H)
	return

/datum/mutant_accessory/proc/get_special_render_colour(mob/living/carbon/human/H, passed_state)
	return null

/datum/mutant_accessory/proc/get_default_color(list/features, datum/species/pref_species) //Needs features for the color information
	var/list/colors
	switch(default_color)
		if(DEFAULT_PRIMARY)
			colors = list(features["mcolor"])
		if(DEFAULT_SECONDARY)
			colors = list(features["mcolor2"])
		if(DEFAULT_TERTIARY)
			colors = list(features["mcolor3"])
		if(DEFAULT_MATRIXED)
			colors = list(features["mcolor"], features["mcolor2"], features["mcolor3"])
		if(DEFAULT_SKIN_OR_PRIMARY)
			if(pref_species && pref_species.species_flags & HAS_SKIN_TONE)
				colors = list(features["skin_color"])
			else
				colors = list(features["mcolor"])
		else
			colors = list(default_color)

	return colors

/proc/GetDefaultMutantpart(datum/species/current_species, key, list/features)
	if(!current_species.default_mutant_bodyparts[key])
		return
	var/datum/mutant_accessory/MA
	var/name_to_find = current_species.default_mutant_bodyparts[key]
	if(name_to_find == ACC_RANDOM)
		var/list/pool = GetMutantpartList(current_species, key, FALSE)
		var/name = pick(pool)
		MA = GLOB.mutant_accessories[key][name]
	else
		MA = GLOB.mutant_accessories[key][name_to_find]
	var/list/returned = list()
	returned[MUTANT_INDEX_NAME] = MA.name
	returned[MUTANT_INDEX_COLOR_LIST] = MA.get_default_color(features, current_species)
	return returned

/proc/GetMutantpartList(datum/species/current_species, key, mismatched = FALSE)
	var/list/returning = GLOB.mutant_accessories[key].Copy()
	if(!mismatched)
		for(var/name in returning)
			var/datum/mutant_accessory/MA = GLOB.mutant_accessories[key][name]
			if(!MA.allowed_species)
				continue
			if(!MA.allowed_species[current_species.name])
				returning -= name
	return returning
