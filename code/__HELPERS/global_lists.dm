#define ALLTIPS (SSstrings.get_list_from_file("tips/marine") + SSstrings.get_list_from_file("tips/xeno") + SSstrings.get_list_from_file("tips/meme") + SSstrings.get_list_from_file("tips/meta"))

#define SYNTH_TYPES list("Synthetic","Early Synthetic")


// Posters
GLOBAL_LIST_INIT(poster_designs, subtypesof(/datum/poster))


// Pill icons
GLOBAL_LIST_EMPTY(randomized_pill_icons)

//////////////////////////
/////Initial Building/////
//////////////////////////

/proc/make_datum_references_lists()
	// Hair - Initialise all /datum/sprite_accessory/hair into an list indexed by hair-style name
	for(var/path in subtypesof(/datum/sprite_accessory/hair))
		var/datum/sprite_accessory/hair/H = new path()
		GLOB.hair_styles_list[H.name] = H
	// Facial Hair - Initialise all /datum/sprite_accessory/facial_hair into an list indexed by facialhair-style name
	for(var/path in subtypesof(/datum/sprite_accessory/facial_hair))
		var/datum/sprite_accessory/facial_hair/H = new path()
		GLOB.facial_hair_styles_list[H.name] = H

	// Species specific
	for(var/path in subtypesof(/datum/sprite_accessory/moth_wings))
		var/datum/sprite_accessory/moth_wings/wings = new path()
		GLOB.moth_wings_list[wings.name] = wings

	// Ethnicity - Initialise all /datum/ethnicity into a list indexed by ethnicity name
	for(var/path in subtypesof(/datum/ethnicity))
		var/datum/ethnicity/E = new path()
		GLOB.ethnicities_list[E.name] = E

	// Body Type - Initialise all /datum/body_type into a list indexed by body_type name
	for(var/path in subtypesof(/datum/body_type))
		var/datum/body_type/B = new path()
		GLOB.body_types_list[B.name] = B

	// Surgery Steps - Initialize all /datum/surgery_step into a list
	for(var/T in subtypesof(/datum/surgery_step))
		var/datum/surgery_step/S = new T
		GLOB.surgery_steps += S

	sort_surgeries()

	var/rkey = 0

	// Species
	for(var/T in subtypesof(/datum/species))
		rkey++
		var/datum/species/S = new T
		S.race_key = rkey //Used in mob icon caching.
		GLOB.all_species[S.name] = S

	// Our ammo stuff is initialized here.
	var/blacklist = list(/datum/ammo/energy, /datum/ammo/bullet/shotgun, /datum/ammo/xeno)
	for(var/t in subtypesof(/datum/ammo) - blacklist)
		var/datum/ammo/A = new t
		GLOB.ammo_list[A.type] = A

	for(var/X in subtypesof(/datum/xeno_caste))
		var/datum/xeno_caste/C = new X
		if(!(C.caste_type_path in GLOB.xeno_caste_datums))
			GLOB.xeno_caste_datums[C.caste_type_path] = list()
		GLOB.xeno_caste_datums[C.caste_type_path][C.upgrade] = C

	for(var/H in subtypesof(/datum/hive_status))
		var/datum/hive_status/HS = new H
		GLOB.hive_datums[HS.hivenumber] = HS


	for(var/L in subtypesof(/datum/language))
		var/datum/language/language = L
		if(!initial(language.key))
			continue

		GLOB.all_languages += language

		var/datum/language/instance = new language

		GLOB.language_datum_instances[language] = instance

	//Emotes
	for(var/path in subtypesof(/datum/emote))
		var/datum/emote/E = new path()
		E.emote_list[E.key] = E

	// Keybindings
	for(var/KB in subtypesof(/datum/keybinding))
		var/datum/keybinding/keybinding = KB
		if(!initial(keybinding.keybind_signal))
			continue
		var/datum/keybinding/instance = new keybinding
		GLOB.keybindings_by_name[instance.name] = instance

		// Classic
		if(LAZYLEN(instance.classic_keys))
			for(var/bound_key in instance.classic_keys)
				LAZYADD(GLOB.classic_keybinding_list_by_key[bound_key], list(instance.name))

		// Hotkey
		if(LAZYLEN(instance.hotkey_keys))
			for(var/bound_key in instance.hotkey_keys)
				LAZYADD(GLOB.hotkey_keybinding_list_by_key[bound_key], list(instance.name))

	for(var/i in 1 to 21)
		GLOB.randomized_pill_icons += "pill[i]"
	shuffle(GLOB.randomized_pill_icons)

	shuffle(GLOB.fruit_icon_states)
	shuffle(GLOB.reagent_effects)


	for(var/path in subtypesof(/datum/material))
		var/datum/material/M = new path
		GLOB.materials[path] = M


	for(var/R in typesof(/datum/autolathe/recipe)-/datum/autolathe/recipe)
		var/datum/autolathe/recipe/recipe = new R
		GLOB.autolathe_recipes += recipe
		GLOB.autolathe_categories |= recipe.category

		var/obj/item/I = new recipe.path
		if(I.materials && !recipe.resources) //This can be overidden in the datums.
			recipe.resources = list()
			for(var/material in I.materials)
				if(istype(I,/obj/item/stack/sheet))
					recipe.resources[material] = I.materials[material] //Doesn't take more if it's just a sheet or something. Get what you put in.
				else
					recipe.resources[material] = round(I.materials[material]*1.25) // More expensive to produce than they are to recycle.
			qdel(I)

	for(var/path in subtypesof(/datum/reagent))
		var/datum/reagent/D = new path()
		GLOB.chemical_reagents_list[path] = D

	for(var/path in subtypesof(/datum/chemical_reaction))

		var/datum/chemical_reaction/D = new path()
		var/list/reaction_ids = list()

		if(D.required_reagents && D.required_reagents.len)
			for(var/reaction in D.required_reagents)
				reaction_ids += reaction

		// Create filters based on each reagent id in the required reagents list
		for(var/id in reaction_ids)
			if(!GLOB.chemical_reactions_list[id])
				GLOB.chemical_reactions_list[id] = list()
			GLOB.chemical_reactions_list[id] += D
			break // Don't bother adding ourselves to other reagent ids, it is redundant

	for(var/path in typesof(/datum/namepool))
		var/datum/namepool/NP = new path
		GLOB.namepool[path] = NP

	return TRUE


//creates every subtype of prototype (excluding prototype) and adds it to list L.
//if no list/L is provided, one is created.
/proc/init_subtypes(prototype, list/L)
	if(!istype(L))
		L = list()
	for(var/path in subtypesof(prototype))
		L += new path()
	return L
