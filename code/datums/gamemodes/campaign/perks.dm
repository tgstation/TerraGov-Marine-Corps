GLOBAL_LIST_INIT_TYPED(campaign_perk_list, /datum/perk, init_glob_perk_list()) //this may or may not be even needed

/proc/init_glob_perk_list()
	. = list()
	for(var/perk_type in subtypesof(/datum/perk))
		var/datum/perk/perk = new perk_type
		.[perk_type] = perk

//List of all loadout_item datums by job, excluding ones that must be unlocked
GLOBAL_LIST_INIT(campaign_perks_by_role, init_campaign_perks_by_role())

/proc/init_campaign_perks_by_role()
	. = list(
	SQUAD_MARINE = list(),
	SQUAD_ENGINEER = list(),
	SQUAD_CORPSMAN = list(),
	SQUAD_SMARTGUNNER = list(),
	SQUAD_LEADER = list(),
	FIELD_COMMANDER = list(),
	STAFF_OFFICER = list(),
	CAPTAIN = list(),
	SOM_SQUAD_MARINE = list(),
	SOM_SQUAD_ENGINEER = list(),
	SOM_SQUAD_CORPSMAN = list(),
	SOM_SQUAD_VETERAN = list(),
	SOM_SQUAD_LEADER = list(),
	SOM_FIELD_COMMANDER = list(),
	SOM_STAFF_OFFICER = list(),
	SOM_COMMANDER = list(),
)
	for(var/role in .)
		for(var/i in GLOB.campaign_perk_list)
			var/datum/perk/perk = GLOB.campaign_perk_list[i]
			if(!(role in perk.jobs_supported))
				continue
			.[role] += perk

/*
Will need a way to org perks (and other stuff) by faction and/or specific role.
Needed both for a purchase list and effected list (if one perk impacts multiple roles, unless we keep everything entirely separate)
**/
/datum/perk
	///Name of the perk
	var/name = "base perk name"
	///Brief description of the perk
	var/desc = "desc here"
	///UI icon for this perk
	var/ui_icon = "militia" //PLACEHOLDER
	///Cost to purchase this perk
	var/unlock_cost = 0
	///Job types that this perk is available to. no list implies this works for any job
	var/list/jobs_supported

///Applies perk benefits
/datum/perk/proc/apply_perk(mob/living/carbon/owner)
	return

///Removes perk benefits
/datum/perk/proc/remove_perk(mob/living/carbon/owner)
	return


//perks that give a trait
/datum/perk/trait
	///List of traits provided by this perk
	var/list/traits

/datum/perk/trait/apply_perk(mob/living/carbon/owner)
	owner.add_traits(traits, type)

/datum/perk/trait/remove_perk(mob/living/carbon/owner)
	owner.remove_traits(traits, type)

/datum/perk/trait/quiet
	traits = list(TRAIT_LIGHT_STEP)


//skill modifying perks
/datum/perk/skill_mod
	var/cqc
	var/melee_weapons
	var/firearms
	var/pistols
	var/shotguns
	var/rifles
	var/smgs
	var/heavy_weapons
	var/smartgun
	var/engineer
	var/construction
	var/leadership
	var/medical
	var/surgery
	var/pilot
	var/police
	var/powerloader
	var/large_vehicle
	var/stamina

/datum/perk/skill_mod/New()
	. = ..()

/datum/perk/skill_mod/apply_perk(mob/living/carbon/owner)
	owner.set_skills(owner.skills.modifyRating(cqc, melee_weapons, firearms, pistols, shotguns, rifles, smgs, heavy_weapons, smartgun, \
	engineer, construction, leadership, medical, surgery, pilot, police, powerloader, large_vehicle, stamina))

/datum/perk/skill_mod/remove_perk(mob/living/carbon/owner)
	owner.set_skills(owner.skills.modifyRating(-cqc, -melee_weapons, -firearms, -pistols, -shotguns, -rifles, -smgs, -heavy_weapons, -smartgun, \
	-engineer, -construction, -leadership, -medical, -surgery, -pilot, -police, -powerloader, -large_vehicle, -stamina))

/datum/perk/skill_mod/cqc
	name = "CQC +1"
	cqc = 1
	jobs_supported = list(SQUAD_MARINE, SOM_SQUAD_MARINE, SQUAD_ENGINEER)

/datum/perk/skill_mod/cqc_two
	name = "CQC +2"
	cqc = 2

/datum/perk/skill_mod/melee
	name = "Melee +1"
	melee_weapons = 1
	jobs_supported = list(SQUAD_MARINE, SOM_SQUAD_MARINE, SQUAD_LEADER)

/datum/perk/skill_mod/melee_two
	melee_weapons = 2

/datum/perk/skill_mod/pistols
	name = "Pistols +1"
	pistols = 1
	jobs_supported = list(SQUAD_MARINE, SOM_SQUAD_MARINE, SQUAD_CORPSMAN)

/datum/perk/skill_mod/shotguns
	shotguns = 1

/datum/perk/skill_mod/rifles
	rifles = 1

/datum/perk/skill_mod/smgs
	smgs = 1

/datum/perk/skill_mod/heavy_weapons
	heavy_weapons = 1

/datum/perk/skill_mod/smartgun
	smartgun = 1

/datum/perk/skill_mod/construction
	construction = 1

/datum/perk/skill_mod/leadership
	leadership = 1

/datum/perk/skill_mod/medical
	medical = 1

/datum/perk/skill_mod/stamina
	stamina = 1

/datum/perk/skill_mod/stamina_two
	stamina = 2
