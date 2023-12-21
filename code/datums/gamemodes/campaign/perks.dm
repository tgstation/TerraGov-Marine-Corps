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
	///This applies to all campaign jobs
	var/all_jobs = FALSE
	///Any perks required before this one can be obtained
	var/list/datum/perk/prereq_perks

/datum/perk/New()
	. = ..()
	if(all_jobs)
		jobs_supported = GLOB.campaign_jobs

///Applies perk benefits
/datum/perk/proc/apply_perk(mob/living/carbon/owner)
	return

///Removes perk benefits
/datum/perk/proc/remove_perk(mob/living/carbon/owner)
	return

/datum/perk/hp_boost
	name = "Improved constitution"
	desc = "+10 max health."
	all_jobs = TRUE
	///How much this perk increases your maxhp by
	var/health_mod = 10

/datum/perk/hp_boost/apply_perk(mob/living/carbon/owner)
	owner.maxHealth += health_mod

/datum/perk/hp_boost/remove_perk(mob/living/carbon/owner)
	owner.maxHealth -= health_mod

/datum/perk/hp_boost/two
	name = "Extreme constitution"
	desc = "An additional +10 max health."

//perks that give a trait
/datum/perk/trait
	///List of traits provided by this perk
	var/list/traits

/datum/perk/trait/apply_perk(mob/living/carbon/owner)
	owner.add_traits(traits, type)

/datum/perk/trait/remove_perk(mob/living/carbon/owner)
	owner.remove_traits(traits, type)

/datum/perk/trait/quiet
	name = "Light footed"
	desc = "Quiet when running, silent when walking."
	traits = list(TRAIT_LIGHT_STEP)
	all_jobs = TRUE

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
	name = "Hand to hand expertise"
	cqc = 1
	all_jobs = TRUE

/datum/perk/skill_mod/cqc/two
	name = "Hand to hand specialisation"
	prereq_perks = list(/datum/perk/skill_mod/cqc)

/datum/perk/skill_mod/melee
	name = "Melee expertise"
	melee_weapons = 1
	all_jobs = TRUE

/datum/perk/skill_mod/melee/two
	name = "Melee specialisation"
	prereq_perks = list(/datum/perk/skill_mod/melee)

/datum/perk/skill_mod/pistols
	name = "Adanced pistol training"
	pistols = 1
	all_jobs = TRUE

/datum/perk/skill_mod/shotguns
	name = "Adanced shotgun training"
	shotguns = 1
	all_jobs = TRUE

/datum/perk/skill_mod/rifles
	name = "Adanced rifle training"
	rifles = 1
	all_jobs = TRUE

/datum/perk/skill_mod/smgs
	name = "Adanced SMG training"
	smgs = 1
	all_jobs = TRUE

/datum/perk/skill_mod/heavy_weapons
	name = "Heavy weapon specialisation"
	heavy_weapons = 1
	all_jobs = TRUE

/datum/perk/skill_mod/smartgun
	name = "Adanced smartgun training"
	smartgun = 1
	jobs_supported = list(SQUAD_SMARTGUNNER, CAPTAIN)

/datum/perk/skill_mod/construction
	name = "Adanced construction training"
	construction = 1
	all_jobs = TRUE

/datum/perk/skill_mod/leadership
	name = "Adanced leadership training"
	leadership = 1
	jobs_supported = list(SQUAD_LEADER, FIELD_COMMANDER, STAFF_OFFICER, CAPTAIN)

/datum/perk/skill_mod/medical
	name = "Adanced medical training"
	medical = 1
	all_jobs = TRUE

/datum/perk/skill_mod/stamina
	name = "Improved stamina"
	stamina = 1
	all_jobs = TRUE

/datum/perk/skill_mod/stamina/two
	name = "Extreme stamina"
	prereq_perks = list(/datum/perk/skill_mod/stamina)
