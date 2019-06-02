GLOBAL_LIST_EMPTY(metatips)
GLOBAL_LIST_EMPTY(marinetips)
GLOBAL_LIST_EMPTY(xenotips)
GLOBAL_LIST_EMPTY(joketips)
#define ALLTIPS (GLOB.marinetips + GLOB.xenotips + GLOB.joketips + GLOB.metatips)

#define SYNTH_TYPES list("Synthetic","Early Synthetic")

var/global/list/surgery_steps = list()				//List of all surgery steps  |BS12
var/global/list/joblist = list()					//List of all jobstypes, minus borg and AI

var/global/list/active_areas = list()
GLOBAL_LIST_EMPTY(all_areas)
var/global/list/processing_machines = list()
var/global/list/active_diseases = list()
var/global/list/events = list()

//used by binoculars for dropship bombardment
var/global/list/active_laser_targets = list()

//used by the main overwatch console
var/global/list/active_orbital_beacons = list()

// Posters
var/global/list/datum/poster/poster_designs = subtypesof(/datum/poster)

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
		surgery_steps += S
	sort_surgeries()

	// List of job. I can't believe this was calculated multiple times per tick!
	for(var/T in subtypesof(/datum/job))
		var/datum/job/J = new T
		joblist[J.title] = J

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
		if(!initial(keybinding.key))
			continue
		var/datum/keybinding/instance = new keybinding
		GLOB.keybindings_by_name[initial(instance.name)] = instance
		if (!(initial(instance.key) in GLOB.keybinding_list_by_key))
			GLOB.keybinding_list_by_key[initial(instance.key)] = list()
		GLOB.keybinding_list_by_key[initial(instance.key)] += instance.name
	// Sort all the keybindings by their weight
	for(var/key in GLOB.keybinding_list_by_key)
		GLOB.keybinding_list_by_key[key] = sortList(GLOB.keybinding_list_by_key[key])

	return TRUE


//creates every subtype of prototype (excluding prototype) and adds it to list L.
//if no list/L is provided, one is created.
/proc/init_subtypes(prototype, list/L)
	if(!istype(L))
		L = list()
	for(var/path in subtypesof(prototype))
		L += new path()
	return L