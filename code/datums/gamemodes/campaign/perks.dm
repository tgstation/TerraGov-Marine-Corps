GLOBAL_LIST_INIT_TYPED(campaign_perk_list, /datum/perk, init_glob_perk_list()) //this may or may not be even needed

/proc/init_glob_perk_list()
	. = list()
	for(var/perk_type in subtypesof(/datum/perk))
		var/datum/perk/perk = new perk_type
		.[perk_type] = perk

//List of all loadout_item datums by job, excluding ones that must be unlocked
GLOBAL_LIST_INIT(campaign_perks_by_role, init_campaign_perks_by_role())

/proc/init_campaign_perks_by_role()
	. = list()
	for(var/job in GLOB.campaign_jobs)
		.[job] = list()
		for(var/i in GLOB.campaign_perk_list)
			var/datum/perk/perk = GLOB.campaign_perk_list[i]
			if(!(job in perk.jobs_supported))
				continue
			.[job] += perk

/*
Will need a way to org perks (and other stuff) by faction and/or specific role.
Needed both for a purchase list and effected list (if one perk impacts multiple roles, unless we keep everything entirely separate)
**/
/datum/perk
	///Name of the perk
	var/name = "base perk name"
	///Brief description of the perk
	var/desc = "desc here"
	///Addition desc for special reqs such as other perks
	var/req_desc
	///UI icon for this perk
	var/ui_icon
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

///Any one off bonuses for unlocking this perk
/datum/perk/proc/unlock_bonus(mob/living/carbon/owner, datum/individual_stats/owner_stats)
	return

///Applies perk benefits
/datum/perk/proc/apply_perk(mob/living/carbon/owner)
	return

///Removes perk benefits
/datum/perk/proc/remove_perk(mob/living/carbon/owner)
	return

/datum/perk/hp_boost
	name = "Improved constitution"
	desc = "+15 max health."
	ui_icon = "health_1"
	all_jobs = TRUE
	unlock_cost = 800
	///How much this perk increases your maxhp by
	var/health_mod = 15

/datum/perk/hp_boost/apply_perk(mob/living/carbon/owner)
	owner.maxHealth += health_mod

/datum/perk/hp_boost/remove_perk(mob/living/carbon/owner)
	owner.maxHealth -= health_mod

/datum/perk/hp_boost/two
	name = "Extreme constitution"
	desc = "An additional +15 max health."
	req_desc = "Requires Improved constitution."
	ui_icon = "health_2"
	prereq_perks = list(/datum/perk/hp_boost)
	unlock_cost = 1000

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
	ui_icon = "soft_footed"
	traits = list(TRAIT_LIGHT_STEP)
	all_jobs = TRUE
	unlock_cost = 400

/datum/perk/trait/axe_master
	name = "Axe master"
	desc = "You are able to wield a breaching axe with considerable skill. Grants access to a special sweep attack when wielded, and allows some roles to select an axe as a back stored weapon."
	req_desc = "Requires Melee specialisation."
	ui_icon = "soft_footed"
	traits = list(TRAIT_AXE_EXPERT)
	jobs_supported = list(SOM_SQUAD_MARINE, SOM_SQUAD_VETERAN, SOM_SQUAD_LEADER, SOM_FIELD_COMMANDER)
	unlock_cost = 450
	prereq_perks = list(/datum/perk/skill_mod/melee/two)

/datum/perk/trait/axe_master/unlock_bonus(mob/living/carbon/owner, datum/individual_stats/owner_stats)
	if(!istype(owner_stats))
		return
	owner_stats.unlock_loadout_item(/datum/loadout_item/back/boarding_axe, SOM_SQUAD_MARINE, owner, 0)
	owner_stats.unlock_loadout_item(/datum/loadout_item/back/boarding_axe, SOM_SQUAD_VETERAN, owner, 0)
	owner_stats.unlock_loadout_item(/datum/loadout_item/back/boarding_axe, SOM_FIELD_COMMANDER, owner, 0)

/datum/perk/trait/sword_master
	name = "Sword master"
	desc = "You are able to wield a sword with considerable skill. Grants access to a special lunge attack when wielding any sword, and allows some roles to select a machete as a back stored weapon."
	req_desc = "Requires Melee specialisation."
	ui_icon = "soft_footed"
	traits = list(TRAIT_SWORD_EXPERT)
	jobs_supported = list(SQUAD_MARINE, SQUAD_LEADER, FIELD_COMMANDER)
	unlock_cost = 450
	prereq_perks = list(/datum/perk/skill_mod/melee/two)

/datum/perk/trait/sword_master/unlock_bonus(mob/living/carbon/owner, datum/individual_stats/owner_stats)
	if(!istype(owner_stats))
		return
	owner_stats.unlock_loadout_item(/datum/loadout_item/back/machete, SQUAD_MARINE, owner, 0)
	owner_stats.unlock_loadout_item(/datum/loadout_item/back/machete, SQUAD_LEADER, owner, 0)

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
	desc = "Improved unarmed damage and stun chance."
	ui_icon = "cqc_1"
	cqc = 1
	all_jobs = TRUE
	unlock_cost = 250

/datum/perk/skill_mod/cqc/two
	name = "Hand to hand specialisation"
	desc = "Greatly improved unarmed damage and stun chance."
	req_desc = "Requires Hand to hand expertise."
	ui_icon = "cqc_2"
	unlock_cost = 350
	prereq_perks = list(/datum/perk/skill_mod/cqc)

/datum/perk/skill_mod/melee
	name = "Melee expertise"
	desc = "Improved damage with melee weapons."
	ui_icon = "melee_1"
	melee_weapons = 1
	all_jobs = TRUE
	unlock_cost = 300

/datum/perk/skill_mod/melee/two
	name = "Melee specialisation"
	desc = "Greatly improved damage with melee weapons."
	req_desc = "Requires Melee expertise."
	ui_icon = "melee_2"
	prereq_perks = list(/datum/perk/skill_mod/melee)
	unlock_cost = 400

/datum/perk/skill_mod/firearms
	name = "Advanced firearm training"
	desc = "Improved handling for all firearms. A prerequisite for all gun skills perks."
	ui_icon = "firearms"
	firearms = 1
	all_jobs = TRUE
	unlock_cost = 600

/datum/perk/skill_mod/pistols
	name = "Advanced pistol training"
	desc = "Improved damage with pistol type firearms."
	req_desc = "Requires Advanced firearm training."
	ui_icon = "pistols"
	pistols = 1
	all_jobs = TRUE
	prereq_perks = list(/datum/perk/skill_mod/firearms)
	unlock_cost = 400

/datum/perk/skill_mod/shotguns
	name = "Advanced shotgun training"
	desc = "Improved damage with shotgun type firearms. Unlocks access to a shotgun secondary weapon in the backslot."
	req_desc = "Requires Advanced firearm training."
	ui_icon = "shotguns"
	shotguns = 1
	all_jobs = TRUE
	prereq_perks = list(/datum/perk/skill_mod/firearms)
	unlock_cost = 600

/datum/perk/skill_mod/shotguns/unlock_bonus(mob/living/carbon/owner, datum/individual_stats/owner_stats)
	if(!istype(owner_stats))
		return
	owner_stats.unlock_loadout_item(owner_stats.faction == FACTION_SOM ? /datum/loadout_item/back/som_shotgun : /datum/loadout_item/back/marine_shotgun, owner_stats.faction == FACTION_SOM ? SOM_SQUAD_MARINE : SQUAD_MARINE, owner, 0)

/datum/perk/skill_mod/rifles
	name = "Advanced rifle training"
	desc = "Improved damage with rifle type firearms."
	req_desc = "Requires Advanced firearm training."
	ui_icon = "rifles"
	rifles = 1
	all_jobs = TRUE
	prereq_perks = list(/datum/perk/skill_mod/firearms)
	unlock_cost = 1000

/datum/perk/skill_mod/smgs
	name = "Advanced SMG training"
	desc = "Improved damage with SMG type firearms."
	req_desc = "Requires Advanced firearm training."
	ui_icon = "smgs"
	smgs = 1
	all_jobs = TRUE
	prereq_perks = list(/datum/perk/skill_mod/firearms)
	unlock_cost = 500

/datum/perk/skill_mod/heavy_weapons
	name = "Heavy weapon specialisation"
	desc = "Improved damage with heavy weapon type firearms."
	req_desc = "Requires Advanced firearm training."
	ui_icon = "heavy"
	heavy_weapons = 1
	all_jobs = TRUE
	prereq_perks = list(/datum/perk/skill_mod/firearms)
	unlock_cost = 800

/datum/perk/skill_mod/smartgun
	name = "Advanced smartgun training"
	desc = "Improved damage with smartguns type firearms."
	req_desc = "Requires Advanced firearm training."
	ui_icon = "smartguns"
	smartgun = 1
	jobs_supported = list(SQUAD_SMARTGUNNER, CAPTAIN)
	prereq_perks = list(/datum/perk/skill_mod/firearms)
	unlock_cost = 800

/datum/perk/skill_mod/construction
	name = "Advanced construction training"
	desc = "Faster construction times when building. Some items may no longer have a penalty delay when constructing."
	ui_icon = "construction"
	construction = 1
	all_jobs = TRUE
	unlock_cost = 600

/datum/perk/skill_mod/leadership
	name = "Advanced leadership training"
	desc = "Improved bonuses when issuing orders."
	ui_icon = "leadership"
	leadership = 1
	jobs_supported = list(SQUAD_LEADER, FIELD_COMMANDER, STAFF_OFFICER, CAPTAIN, SOM_SQUAD_LEADER, SOM_STAFF_OFFICER, SOM_FIELD_COMMANDER, SOM_COMMANDER)
	unlock_cost = 1100

/datum/perk/skill_mod/medical
	name = "Advanced medical training"
	desc = "Faster at applying medical items. Some items may no longer have a penalty delay."
	ui_icon = "medical"
	medical = 1
	all_jobs = TRUE
	unlock_cost = 600

/datum/perk/skill_mod/stamina
	name = "Improved stamina"
	desc = "Improved stamina regen rate, and reduces the delay before stamina begins to regenerate."
	ui_icon = "stamina_1"
	stamina = 1
	all_jobs = TRUE
	unlock_cost = 600

/datum/perk/skill_mod/stamina/two
	name = "Extreme stamina"
	desc = "Greatly stamina regen rate, and further reduces the delay before stamina begins to regenerate."
	req_desc = "Requires Improved stamina."
	ui_icon = "stamina_2"
	prereq_perks = list(/datum/perk/skill_mod/stamina)
	unlock_cost = 800
