#define ALLTIPS (SSstrings.get_list_from_file("tips/marine") + SSstrings.get_list_from_file("tips/xeno") + SSstrings.get_list_from_file("tips/meme") + SSstrings.get_list_from_file("tips/meta") + SSstrings.get_list_from_file("tips/HvH"))

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

	// Hair Gradients - Initialise all /datum/sprite_accessory/hair_gradient into an list indexed by gradient-style name
	for(var/path in subtypesof(/datum/sprite_accessory/hair_gradient))
		var/datum/sprite_accessory/hair_gradient/H = new path()
		GLOB.hair_gradients_list[H.name] = H

	// Facial Hair - Initialise all /datum/sprite_accessory/facial_hair into an list indexed by facialhair-style name
	for(var/path in subtypesof(/datum/sprite_accessory/facial_hair))
		var/datum/sprite_accessory/facial_hair/H = new path()
		GLOB.facial_hair_styles_list[H.name] = H

	// Species specific
	for(var/path in subtypesof(/datum/sprite_accessory/moth_wings)) //todo use init accesries
		var/datum/sprite_accessory/moth_wings/wings = new path()
		GLOB.moth_wings_list[wings.name] = wings

	// Ethnicity - Initialise all /datum/ethnicity into a list indexed by ethnicity name
	for(var/path in subtypesof(/datum/ethnicity))
		var/datum/ethnicity/E = new path()
		GLOB.ethnicities_list[E.name] = E

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
		if(S.joinable_roundstart)
			GLOB.roundstart_species[S.name] = S

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

	// Initializes static ui data used by all hive status UI
	var/list/per_tier_counter = list()
	for(var/caste_type_path AS in GLOB.xeno_caste_datums)
		var/datum/xeno_caste/caste = GLOB.xeno_caste_datums[caste_type_path][XENO_UPGRADE_BASETYPE]
		var/type_path = initial(caste.caste_type_path)

		GLOB.hive_ui_caste_index[type_path] = GLOB.hive_ui_static_data.len //Starts from 0.

		var/icon/xeno_minimap = icon('icons/UI_icons/map_blips.dmi', initial(caste.minimap_icon))
		var/tier = initial(caste.tier)
		if(tier == XENO_TIER_MINION)
			continue
		if(isnull(per_tier_counter[tier]))
			per_tier_counter[tier] = 0

		GLOB.hive_ui_static_data += list(list(
			"name" = initial(caste.caste_name),
			"is_queen" = type_path == /mob/living/carbon/xenomorph/queen,
			"minimap" = icon2base64(xeno_minimap),
			"sort_mod" = per_tier_counter[tier]++,
			"tier" = GLOB.tier_as_number[tier],
			"is_unique" = tier == XENO_TIER_FOUR, //TODO: Make this check a flag after caste flag refactoring is merged.
			"can_transfer_plasma" = CHECK_BITFIELD(initial(caste.can_flags), CASTE_CAN_BE_GIVEN_PLASMA),
			"evolution_max" = initial(caste.evolution_threshold)
		))

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

	init_keybindings()

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

	for(var/path in typesof(/datum/namepool))
		var/datum/namepool/NP = new path
		GLOB.namepool[path] = NP

	for(var/path in typesof(/datum/operation_namepool))
		var/datum/operation_namepool/NP = new path
		GLOB.operation_namepool[path] = NP

	return TRUE


//creates every subtype of prototype (excluding prototype) and adds it to list L.
//if no list/L is provided, one is created.
/proc/init_subtypes(prototype, list/L)
	if(!istype(L))
		L = list()
	for(var/path in subtypesof(prototype))
		L += new path()
	return L
