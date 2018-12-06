var/list/clients = list()								//list of all clients
var/list/admins = list()								//list of all clients whom are admins
var/list/directory = list()							//list of all ckeys with associated client
var/list/unansweredAhelps = list()			//This feels inefficient, but I can't think of a better way. Stores the message indexed by CID
var/list/unansweredMhelps = list()
var/list/CLFaxes = list()								//List of all CL faxes sent this round
var/list/fax_contents = list() 					//List of fax contents to maintain it even if source paper is deleted
var/list/TGMCFaxes = list()							//List of all TGMC faxes sent this round
var/list/active_tracking_beacons = list()			//List of all active squad tracking beacons

//Names of maps that can be compiled on
var/list/DEFAULT_NEXT_MAP_CANDIDATES = list("LV-624", "Ice Colony", "Big-Red", "Prison Station")
var/list/NEXT_MAP_CANDIDATES = DEFAULT_NEXT_MAP_CANDIDATES.Copy()

//List of player votes. Name of the map from NEXT_MAP_CANDIADATES indexed by ckey
var/list/player_votes = list()

//Since it didn't really belong in any other category, I'm putting this here
//This is for procs to replace all the goddamn 'in world's that are chilling around the code

var/global/list/player_list = list()				//List of all mobs **with clients attached**. Excludes /mob/new_player
var/global/list/mob_list = list()					//List of all mobs, including clientless
var/global/list/living_mob_list = list()			//List of all alive mobs, including clientless. Excludes /mob/new_player
var/global/list/living_xeno_list = list()			//List of all alive mob/living/carbon/Xenomorph mobs
var/global/list/dead_mob_list = list()				//List of all dead mobs, including clientless. Excludes /mob/new_player

var/global/list/cable_list = list()					//Index for all cables, so that powernets don't have to look through the entire world all the time
var/global/list/chemical_reactions_list				//List of all /datum/chemical_reaction datums. Used during chemical reactions
var/global/list/chemical_reagents_list				//List of all /datum/reagent datums indexed by reagent id. Used by chemistry stuff
var/global/list/landmarks_list = list()				//List of all landmarks created
var/global/list/surgery_steps = list()				//List of all surgery steps  |BS12
var/global/list/side_effects = list()				//List of all medical sideeffects types by thier names |BS12
var/global/list/mechas_list = list()				//List of all mechs. Used by hostile mobs target tracking.
var/global/list/ammo_list = list()					//List of all ammo types. Used by guns to tell the projectile how to act.
var/global/list/joblist = list()					//List of all jobstypes, minus borg and AI

var/global/list/structure_list = list()				//List of all /obj/structure as they are created, to fetch generic structures with a lot less lag
var/global/list/active_areas = list()
var/global/list/all_areas = list()
var/global/list/machines = list()
var/global/list/processing_machines = list()
var/global/list/turfs = list()
var/global/list/object_list = list()
var/global/list/item_list = list()
var/global/list/effect_list = list()
var/global/list/attachment_vendors = list() //Used by our gamemode code
var/global/list/marine_vendors = list() //Used by our gamemode code
var/global/list/cargo_ammo_vendors = list() //Used by our gamemode code
var/global/list/cargo_guns_vendors = list() //Used by our gamemode code
var/global/list/processing_objects = list()
var/global/list/active_diseases = list()
var/global/list/events = list()
var/global/list/processing_second = list()

//used by binoculars for dropship bombardment
var/global/list/active_laser_targets = list()

//used by the main overwatch console
var/global/list/active_orbital_beacons = list()
var/global/list/active_supply_beacons = list()

//Used by Queen overwatch
//var/global/list/xeno_leader_list = list() - moved to hive_datum

//Languages/species/whitelist.
var/global/list/all_species[0]
var/global/list/all_languages[0]
var/global/list/language_keys[0]					//table of say codes for all languages
var/global/list/synth_types = list("Synthetic","Early Synthetic")

var/global/list/xeno_caste_datums = list()

// Posters
var/global/list/datum/poster/poster_designs = subtypesof(/datum/poster)
//Preferences stuff
	// Ethnicities
var/global/list/ethnicities_list = list()			// Stores /datum/ethnicity indexed by name
	// Body Types
var/global/list/body_types_list = list()			// Stores /datum/body_type indexed by name
	//Hairstyles
var/global/list/hair_styles_list = list()			//stores /datum/sprite_accessory/hair indexed by name
var/global/list/hair_styles_male_list = list()
var/global/list/hair_styles_female_list = list()
var/global/list/facial_hair_styles_list = list()	//stores /datum/sprite_accessory/facial_hair indexed by name
var/global/list/facial_hair_styles_male_list = list()
var/global/list/facial_hair_styles_female_list = list()
var/global/list/skin_styles_female_list = list()		//unused
	//Underwear
var/global/list/underwear_m = list("Briefs") //Curse whoever made male/female underwear diffrent colours
var/global/list/underwear_f = list("Briefs", "Panties")
	//undershirt
var/global/list/undershirt_t = list("None","Undershirt(Sleeveless)", "Undershirt(Sleeved)", "Rolled Undershirt(Sleeveless)", "Rolled Undershirt(Sleeved)")
	//Backpacks
var/global/list/backbaglist = list("Nothing", "Backpack", "Satchel")
	// Species specific
var/global/list/moth_wings_list = list()
// var/global/list/exclude_jobs = list(/datum/job/ai,/datum/job/cyborg)

//////////////////////////
/////Initial Building/////
//////////////////////////

/proc/makeDatumRefLists()
	// Hair - Initialise all /datum/sprite_accessory/hair into an list indexed by hair-style name
	for(var/path in subtypesof(/datum/sprite_accessory/hair))
		var/datum/sprite_accessory/hair/H = new path()
		hair_styles_list[H.name] = H
		switch(H.gender)
			if(MALE)
				hair_styles_male_list += H.name
			if(FEMALE)
				hair_styles_female_list += H.name
			else
				hair_styles_male_list += H.name
				hair_styles_female_list += H.name
 	// Facial Hair - Initialise all /datum/sprite_accessory/facial_hair into an list indexed by facialhair-style name
	for(var/path in subtypesof(/datum/sprite_accessory/facial_hair))
		var/datum/sprite_accessory/facial_hair/H = new path()
		facial_hair_styles_list[H.name] = H
		switch(H.gender)
			if(MALE)
				facial_hair_styles_male_list += H.name
			if(FEMALE)
				facial_hair_styles_female_list += H.name
			else
				facial_hair_styles_male_list += H.name
				facial_hair_styles_female_list += H.name

	// Species specific
	for(var/path in subtypesof(/datum/sprite_accessory/moth_wings))
		var/datum/sprite_accessory/moth_wings/wings = new path()
		moth_wings_list[wings.name] = wings

	// Ethnicity - Initialise all /datum/ethnicity into a list indexed by ethnicity name
	for(var/path in subtypesof(/datum/ethnicity))
		var/datum/ethnicity/E = new path()
		ethnicities_list[E.name] = E

	// Body Type - Initialise all /datum/body_type into a list indexed by body_type name
	for(var/path in subtypesof(/datum/body_type))
		var/datum/body_type/B = new path()
		body_types_list[B.name] = B

	// Surgery Steps - Initialize all /datum/surgery_step into a list
	for(var/T in subtypesof(/datum/surgery_step))
		var/datum/surgery_step/S = new T
		surgery_steps += S
	sort_surgeries()

	// List of job. I can't believe this was calculated multiple times per tick!
	for(var/T in subtypesof(/datum/job))
		var/datum/job/J = new T
		joblist[J.title] = J

	// Languages
	for(var/T in subtypesof(/datum/language))
		var/datum/language/L = new T
		all_languages[L.name] = L

	for(var/language_name in all_languages)
		var/datum/language/L = all_languages[language_name]
		language_keys[":[lowertext(L.key)]"] = L
		language_keys[".[lowertext(L.key)]"] = L
		language_keys["#[lowertext(L.key)]"] = L
	var/rkey = 0

	// Species
	for(var/T in subtypesof(/datum/species))
		rkey++
		var/datum/species/S = new T
		S.race_key = rkey //Used in mob icon caching.
		all_species[S.name] = S

	// Our ammo stuff is initialized here.
	var/blacklist = list(/datum/ammo/energy, /datum/ammo/energy/yautja, /datum/ammo/energy/yautja/rifle, /datum/ammo/bullet/shotgun, /datum/ammo/xeno)
	for(var/t in subtypesof(/datum/ammo) - blacklist)
		var/datum/ammo/A = new t
		ammo_list[A.type] = A

	for(var/X in subtypesof(/datum/xeno_caste))
		var/datum/xeno_caste/C = new X
		if(!(C.caste_type_path in xeno_caste_datums))
			xeno_caste_datums[C.caste_type_path] = list(1,2,3,4)
		var/upgrade_level = CLAMP(C.upgrade + 1, 1, 4)
		xeno_caste_datums[C.caste_type_path][upgrade_level] = C

	return 1

/* // Uncomment to debug chemical reaction list.
/client/verb/debug_chemical_list()

	for (var/reaction in chemical_reactions_list)
		. += "chemical_reactions_list\[\"[reaction]\"\] = \"[chemical_reactions_list[reaction]]\"\n"
		if(islist(chemical_reactions_list[reaction]))
			var/list/L = chemical_reactions_list[reaction]
			for(var/t in L)
				. += "    has: [t]\n"
	to_chat(world, .)
*/
