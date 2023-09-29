#define ALLTIPS (SSstrings.get_list_from_file("tips/marine") + SSstrings.get_list_from_file("tips/xeno") + SSstrings.get_list_from_file("tips/meme") + SSstrings.get_list_from_file("tips/meta") + SSstrings.get_list_from_file("tips/HvH"))

#define SYNTH_TYPES list("Synthetic","Early Synthetic")

#define ROBOT_TYPES list("Basic","Hammerhead","Chilvaris","Ratcher","Sterling")


// Posters
GLOBAL_LIST_INIT(poster_designs, subtypesof(/datum/poster))


//////////////////////////
/////Initial Building/////
//////////////////////////

/proc/init_sprite_accessories()
	init_sprite_accessory_subtypes(/datum/sprite_accessory/hair, GLOB.hair_styles_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/hair_gradient, GLOB.hair_gradients_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/facial_hair, GLOB.facial_hair_styles_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/moth_wings, GLOB.moth_wings_list)

/proc/init_species()
	var/rkey = 0

	// Species
	for(var/T in subtypesof(/datum/species))
		rkey++
		var/datum/species/S = new T
		S.race_key = rkey //Used in mob icon caching.
		GLOB.all_species[S.name] = S
		if(S.joinable_roundstart)
			GLOB.roundstart_species[S.name] = S


/proc/init_language_datums()
	for(var/L in subtypesof(/datum/language))
		var/datum/language/language = L
		if(!initial(language.key))
			continue

		GLOB.all_languages += language

		var/datum/language/instance = new language

		GLOB.language_datum_instances[language] = instance

/proc/init_emote_list()
	//Emotes
	for(var/path in subtypesof(/datum/emote))
		var/datum/emote/E = new path()
		E.emote_list[E.key] = E

/proc/init_chemistry()
	for(var/path in subtypesof(/datum/reagent))
		var/datum/reagent/D = new path()
		GLOB.chemical_reagents_list[path] = D

	for(var/path in subtypesof(/datum/chemical_reaction))
		var/datum/chemical_reaction/D = new path()
		var/list/reaction_ids = list()

		if(length(D.required_reagents))
			for(var/result in D.results)

			for(var/reaction in D.required_reagents)
				reaction_ids += reaction

		// Create filters based on each reagent id in the required reagents list
		for(var/id in reaction_ids)
			if(!GLOB.chemical_reactions_list[id])
				GLOB.chemical_reactions_list[id] = list()
			GLOB.chemical_reactions_list[id] += D
			break // Don't bother adding ourselves to other reagent ids, it is redundant

/proc/init_namepool()
	for(var/path in typesof(/datum/namepool))
		var/datum/namepool/NP = new path
		GLOB.namepool[path] = NP

	for(var/path in typesof(/datum/operation_namepool))
		var/datum/operation_namepool/NP = new path
		GLOB.operation_namepool[path] = NP


/// These should be replaced with proper _INIT macros
/proc/make_datum_reference_lists()
	populate_seed_list()
	init_sprite_accessories()
	init_species()
	init_language_datums()
	init_emote_list()
	init_chemistry()
	init_namepool()
	init_keybindings()


//creates every subtype of prototype (excluding prototype) and adds it to list L.
//if no list/L is provided, one is created.
/proc/init_subtypes(prototype, list/L)
	if(!istype(L))
		L = list()
	for(var/path in subtypesof(prototype))
		L += new path()
	return L
