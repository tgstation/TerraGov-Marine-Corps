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

///Overhead animation to indicate a perk has been unlocked
/datum/perk/proc/unlock_animation(mob/living/carbon/owner)
	var/obj/effect/overlay/perk/perk_animation = new
	owner.vis_contents += perk_animation
	flick(ui_icon, perk_animation)
	addtimer(CALLBACK(src, PROC_REF(remove_unlock_animation), owner, perk_animation), 1.8 SECONDS, TIMER_CLIENT_TIME)

///callback for removing the eye from viscontents
/datum/perk/proc/remove_unlock_animation(mob/living/carbon/owner, obj/effect/overlay/perk/perk_animation)
	owner.vis_contents -= perk_animation
	qdel(perk_animation)

/datum/perk/shield_overclock
	name = "Shield overlock"
	desc = "Overclocking a shield module beyond manufacturing specifications results in a more powerful shield at that cost of burning out sensitive components after weeks of use instead of months. \
	May void the warranty. Also unlocks shield modules for roles that do not already have access to it."
	ui_icon = "overclock"
	all_jobs = TRUE
	unlock_cost = 800

/datum/perk/shield_overclock/unlock_bonus(mob/living/carbon/owner, datum/individual_stats/owner_stats)
	if(owner_stats.faction == FACTION_TERRAGOV)
		owner_stats.replace_loadout_option(/datum/loadout_item/suit_slot/light_shield/overclocked, /datum/loadout_item/suit_slot/light_shield, jobs_supported)
		owner_stats.replace_loadout_option(/datum/loadout_item/suit_slot/medium_shield/overclocked, /datum/loadout_item/suit_slot/medium_shield, jobs_supported)
		owner_stats.replace_loadout_option(/datum/loadout_item/suit_slot/heavy_shield/overclocked, /datum/loadout_item/suit_slot/heavy_shield, jobs_supported)
		owner_stats.replace_loadout_option(/datum/loadout_item/suit_slot/medium_shield/overclocked/engineer, /datum/loadout_item/suit_slot/medium_engineer, jobs_supported)
		owner_stats.unlock_loadout_item(/datum/loadout_item/suit_slot/light_shield/overclocked/medic, SQUAD_CORPSMAN, owner)
		owner_stats.unlock_loadout_item(/datum/loadout_item/suit_slot/medium_shield/overclocked/medic, SQUAD_CORPSMAN, owner)
		owner_stats.unlock_loadout_item(/datum/loadout_item/suit_slot/light_shield/overclocked/engineer, SQUAD_ENGINEER, owner)

	else if(owner_stats.faction == FACTION_SOM)
		owner_stats.replace_loadout_option(/datum/loadout_item/suit_slot/som_light_shield/overclocked, /datum/loadout_item/suit_slot/som_light_shield, jobs_supported)
		owner_stats.replace_loadout_option(/datum/loadout_item/suit_slot/som_light_shield/overclocked/veteran, /datum/loadout_item/suit_slot/som_light_shield/veteran, jobs_supported)
		owner_stats.replace_loadout_option(/datum/loadout_item/suit_slot/som_medium_shield/overclocked, /datum/loadout_item/suit_slot/som_medium_shield, jobs_supported)
		owner_stats.replace_loadout_option(/datum/loadout_item/suit_slot/som_heavy_shield/overclocked, /datum/loadout_item/suit_slot/som_heavy_shield, jobs_supported)
		owner_stats.replace_loadout_option(/datum/loadout_item/suit_slot/som_heavy_shield/breacher/overclocked, /datum/loadout_item/suit_slot/som_heavy_shield/breacher, jobs_supported)
		owner_stats.replace_loadout_option(/datum/loadout_item/suit_slot/som_light_shield/overclocked/medic, /datum/loadout_item/suit_slot/som_medic/light, jobs_supported)
		owner_stats.replace_loadout_option(/datum/loadout_item/suit_slot/som_medium_shield/overclocked/medic, /datum/loadout_item/suit_slot/som_medic, jobs_supported)
		owner_stats.replace_loadout_option(/datum/loadout_item/suit_slot/som_light_shield/overclocked/engineer, /datum/loadout_item/suit_slot/som_engineer/light, jobs_supported)
		owner_stats.replace_loadout_option(/datum/loadout_item/suit_slot/som_medium_shield/overclocked/engineer, /datum/loadout_item/suit_slot/som_engineer, jobs_supported)

//perks that give a trait
/datum/perk/trait
	///List of traits provided by this perk
	var/list/traits

/datum/perk/trait/apply_perk(mob/living/carbon/owner)
	owner.add_traits(traits, type)

/datum/perk/trait/remove_perk(mob/living/carbon/owner)
	owner.remove_traits(traits, type)

/datum/perk/trait/hp_boost
	name = "Improved constitution"
	desc = "Through disciplined training and hypno indoctrination, your body is able to tolerate higher levels of trauma. +25 max health, +25 pain resistance. \
	Also unlocks heavier armor for most roles."
	ui_icon = "health_1"
	all_jobs = TRUE
	unlock_cost = 800
	traits = list(TRAIT_LIGHT_PAIN_RESIST)
	///How much this perk increases your maxhp by
	var/health_mod = 25

/datum/perk/trait/hp_boost/apply_perk(mob/living/carbon/owner)
	. = ..()
	owner.maxHealth += health_mod

/datum/perk/trait/hp_boost/remove_perk(mob/living/carbon/owner)
	. = ..()
	owner.maxHealth -= health_mod

/datum/perk/trait/hp_boost/unlock_bonus(mob/living/carbon/owner, datum/individual_stats/owner_stats)
	if(owner_stats.faction == FACTION_TERRAGOV)
		owner_stats.replace_loadout_option(/datum/loadout_item/suit_slot/heavy_tyr/universal, /datum/loadout_item/suit_slot/heavy_tyr, SQUAD_MARINE)
		owner_stats.unlock_loadout_item(/datum/loadout_item/suit_slot/heavy_tyr/universal, list(SQUAD_LEADER, FIELD_COMMANDER), owner)
		owner_stats.unlock_loadout_item(/datum/loadout_item/helmet/tyr/universal, list(SQUAD_LEADER, FIELD_COMMANDER), owner)
		owner_stats.unlock_loadout_item(/datum/loadout_item/suit_slot/heavy_tyr/medic, list(SQUAD_CORPSMAN), owner)
		owner_stats.unlock_loadout_item(/datum/loadout_item/helmet/tyr/corpsman, list(SQUAD_CORPSMAN), owner)
		owner_stats.unlock_loadout_item(/datum/loadout_item/suit_slot/heavy_tyr/engineer, list(SQUAD_ENGINEER), owner)
		owner_stats.unlock_loadout_item(/datum/loadout_item/helmet/tyr/engineer, list(SQUAD_ENGINEER), owner)
	else if(owner_stats.faction == FACTION_SOM)
		owner_stats.replace_loadout_option(/datum/loadout_item/suit_slot/som_heavy_tyr/universal, /datum/loadout_item/suit_slot/som_heavy_tyr, SOM_SQUAD_MARINE)
		owner_stats.replace_loadout_option(/datum/loadout_item/suit_slot/som_heavy_tyr/universal, /datum/loadout_item/suit_slot/som_heavy_tyr/veteran, SOM_SQUAD_VETERAN)
		owner_stats.unlock_loadout_item(/datum/loadout_item/suit_slot/som_heavy_tyr/universal, list(SOM_SQUAD_LEADER, SOM_FIELD_COMMANDER), owner)
		owner_stats.unlock_loadout_item(/datum/loadout_item/helmet/som_tyr/universal, list(SOM_SQUAD_LEADER, SOM_FIELD_COMMANDER), owner)
		owner_stats.unlock_loadout_item(/datum/loadout_item/suit_slot/som_heavy_tyr/medic, list(SOM_SQUAD_CORPSMAN), owner)
		owner_stats.unlock_loadout_item(/datum/loadout_item/helmet/som_tyr/medic, list(SOM_SQUAD_CORPSMAN), owner)
		owner_stats.unlock_loadout_item(/datum/loadout_item/suit_slot/som_heavy_tyr/engineer, list(SOM_SQUAD_ENGINEER), owner)
		owner_stats.unlock_loadout_item(/datum/loadout_item/helmet/som_tyr/engineer, list(SOM_SQUAD_ENGINEER), owner)

/datum/perk/trait/hp_boost/two
	name = "Extreme constitution"
	desc = "Military grade biological augmentations are used to harden your body against grievous bodily harm. Provides an additional +25 max health and +10 pain resistance."
	req_desc = "Requires Improved constitution."
	ui_icon = "health_2"
	prereq_perks = list(/datum/perk/trait/hp_boost)
	traits = list(TRAIT_MEDIUM_PAIN_RESIST)
	unlock_cost = 1000

/datum/perk/trait/hp_boost/two/unlock_bonus(mob/living/carbon/owner, datum/individual_stats/owner_stats)
	return

/datum/perk/trait/quiet
	name = "Light footed"
	desc = "Quiet when running, silent when walking."
	ui_icon = "soft_footed"
	traits = list(TRAIT_LIGHT_STEP)
	all_jobs = TRUE
	unlock_cost = 300

/datum/perk/trait/axe_master
	name = "Axe master"
	desc = "You are able to wield a breaching axe with considerable skill. Grants access to a special sweep attack when wielded, and allows some roles to select an axe as a back stored weapon."
	req_desc = "Requires Melee specialisation."
	ui_icon = "axe"
	traits = list(TRAIT_AXE_EXPERT)
	jobs_supported = list(SOM_SQUAD_MARINE, SOM_SQUAD_VETERAN, SOM_SQUAD_LEADER, SOM_FIELD_COMMANDER)
	unlock_cost = 450
	prereq_perks = list(/datum/perk/skill_mod/melee/two)

/datum/perk/trait/axe_master/unlock_bonus(mob/living/carbon/owner, datum/individual_stats/owner_stats)
	if(!istype(owner_stats))
		return
	owner_stats.unlock_loadout_item(/datum/loadout_item/back/boarding_axe, jobs_supported, owner, 0)

/datum/perk/trait/sword_master
	name = "Sword master"
	desc = "You are able to wield a sword with considerable skill. Grants access to a special lunge attack when wielding any sword, and allows some roles to select a sword in different slots."
	req_desc = "Requires Melee specialisation."
	ui_icon = "sword"
	traits = list(TRAIT_SWORD_EXPERT)
	jobs_supported = list(SQUAD_MARINE, SQUAD_LEADER, FIELD_COMMANDER, SOM_SQUAD_MARINE, SOM_SQUAD_ENGINEER, SOM_SQUAD_VETERAN, SOM_SQUAD_LEADER, SOM_FIELD_COMMANDER)
	unlock_cost = 450
	prereq_perks = list(/datum/perk/skill_mod/melee/two)

/datum/perk/trait/sword_master/unlock_bonus(mob/living/carbon/owner, datum/individual_stats/owner_stats)
	if(!istype(owner_stats))
		return
	owner_stats.unlock_loadout_item(/datum/loadout_item/suit_store/machete_shield, jobs_supported, owner, 0)
	owner_stats.unlock_loadout_item(/datum/loadout_item/back/machete, jobs_supported, owner, 0)
	owner_stats.unlock_loadout_item(/datum/loadout_item/secondary/esword, jobs_supported, owner, 0)

//skill modifying perks
/datum/perk/skill_mod
	var/unarmed
	var/melee_weapons
	var/combat
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
	owner.set_skills(owner.skills.modifyRating(unarmed, melee_weapons, combat, pistols, shotguns, rifles, smgs, heavy_weapons, smartgun, \
	engineer, construction, leadership, medical, surgery, pilot, police, powerloader, large_vehicle, stamina))

/datum/perk/skill_mod/remove_perk(mob/living/carbon/owner)
	owner.set_skills(owner.skills.modifyRating(-unarmed, -melee_weapons, -combat, -pistols, -shotguns, -rifles, -smgs, -heavy_weapons, -smartgun, \
	-engineer, -construction, -leadership, -medical, -surgery, -pilot, -police, -powerloader, -large_vehicle, -stamina))

/datum/perk/skill_mod/unarmed
	name = "Hand to hand expertise"
	desc = "Advanced hand to hand combat training gives you an edge when you need to punch someone in the face. Improved unarmed damage and stun chance."
	ui_icon = "cqc_1"
	unarmed = 1
	all_jobs = TRUE
	unlock_cost = 250

/datum/perk/skill_mod/unarmed/two
	name = "Hand to hand specialisation"
	desc = "Muscle augments combined with specialised hand to hand combat training turn your body into a lethal weapon. Greatly improved unarmed damage and stun chance."
	req_desc = "Requires Hand to hand expertise."
	ui_icon = "cqc_2"
	unlock_cost = 350
	prereq_perks = list(/datum/perk/skill_mod/unarmed)

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

/datum/perk/skill_mod/combat
	name = "Advanced combat training"
	desc = "Improved handling for all firearms. A prerequisite for all gun skills perks, and increases the speed of tactical reloads."
	ui_icon = "firearms"
	combat = 1
	all_jobs = TRUE
	unlock_cost = 400

/datum/perk/skill_mod/pistols
	name = "Advanced pistol training"
	desc = "Improved damage, accuracy and scatter with pistol type firearms. Unlocks additional pistols for some roles."
	req_desc = "Requires Advanced combat training."
	ui_icon = "pistols"
	pistols = 1
	all_jobs = TRUE
	prereq_perks = list(/datum/perk/skill_mod/combat)
	unlock_cost = 400

/datum/perk/skill_mod/pistols/unlock_bonus(mob/living/carbon/owner, datum/individual_stats/owner_stats)
	if(!istype(owner_stats))
		return
	owner_stats.unlock_loadout_item(/datum/loadout_item/secondary/gun/som/extended_pistol, jobs_supported, owner, 0)
	owner_stats.unlock_loadout_item(/datum/loadout_item/secondary/gun/som/highpower, jobs_supported, owner, 0)
	owner_stats.unlock_loadout_item(/datum/loadout_item/secondary/gun/marine/highpower, jobs_supported, owner, 0)
	owner_stats.unlock_loadout_item(/datum/loadout_item/secondary/gun/marine/laser_pistol, jobs_supported, owner, 0)
	owner_stats.unlock_loadout_item(/datum/loadout_item/secondary/gun/marine/standard_revolver, jobs_supported, owner, 0)

/datum/perk/skill_mod/shotguns
	name = "Advanced shotgun training"
	desc = "Improved damage, accuracy and scatter with shotgun type firearms. Unlocks access to a shotgun secondary weapon in the backslot for some roles."
	req_desc = "Requires Advanced combat training."
	ui_icon = "shotguns"
	shotguns = 1
	all_jobs = TRUE
	prereq_perks = list(/datum/perk/skill_mod/combat)
	unlock_cost = 600

/datum/perk/skill_mod/shotguns/unlock_bonus(mob/living/carbon/owner, datum/individual_stats/owner_stats)
	if(!istype(owner_stats))
		return
	owner_stats.unlock_loadout_item(/datum/loadout_item/back/som_shotgun, jobs_supported, owner, 0)
	owner_stats.unlock_loadout_item(/datum/loadout_item/back/marine_shotgun, jobs_supported, owner, 0)

/datum/perk/skill_mod/rifles
	name = "Advanced rifle training"
	desc = "Improved damage, accuracy and scatter with rifle type firearms. Unlocks new weapons and ammo types for some roles."
	req_desc = "Requires Advanced combat training."
	ui_icon = "rifles"
	rifles = 1
	all_jobs = TRUE
	prereq_perks = list(/datum/perk/skill_mod/combat)
	unlock_cost = 1000

/datum/perk/skill_mod/rifles/unlock_bonus(mob/living/carbon/owner, datum/individual_stats/owner_stats)
	if(!istype(owner_stats))
		return
	if(owner_stats.faction == FACTION_TERRAGOV)
		owner_stats.replace_loadout_option(/datum/loadout_item/suit_store/main_gun/marine/standard_rifle/enhanced, /datum/loadout_item/suit_store/main_gun/marine/standard_rifle, SQUAD_MARINE)
		owner_stats.replace_loadout_option(/datum/loadout_item/suit_store/main_gun/marine/standard_carbine/enhanced, /datum/loadout_item/suit_store/main_gun/marine/standard_carbine, SQUAD_MARINE)
		owner_stats.replace_loadout_option(/datum/loadout_item/suit_store/main_gun/marine/scout_carbine/enhanced, /datum/loadout_item/suit_store/main_gun/marine/scout_carbine, SQUAD_MARINE)
		owner_stats.replace_loadout_option(/datum/loadout_item/suit_store/main_gun/marine/suppressed_carbine/enhanced, /datum/loadout_item/suit_store/main_gun/marine/suppressed_carbine, SQUAD_MARINE)
		owner_stats.replace_loadout_option(/datum/loadout_item/suit_store/main_gun/corpsman/carbine/enhanced, /datum/loadout_item/suit_store/main_gun/corpsman/carbine, SQUAD_CORPSMAN)
		owner_stats.replace_loadout_option(/datum/loadout_item/suit_store/main_gun/corpsman/assault_rifle/enhanced, /datum/loadout_item/suit_store/main_gun/corpsman/assault_rifle, SQUAD_CORPSMAN)
		owner_stats.replace_loadout_option(/datum/loadout_item/suit_store/main_gun/engineer/carbine/enhanced, /datum/loadout_item/suit_store/main_gun/engineer/carbine, SQUAD_ENGINEER)
		owner_stats.replace_loadout_option(/datum/loadout_item/suit_store/main_gun/engineer/assault_rifle/enhanced, /datum/loadout_item/suit_store/main_gun/engineer/assault_rifle, SQUAD_ENGINEER)
		owner_stats.replace_loadout_option(/datum/loadout_item/suit_store/main_gun/squad_leader/carbine/enhanced, /datum/loadout_item/suit_store/main_gun/squad_leader/carbine, SQUAD_LEADER)
		owner_stats.replace_loadout_option(/datum/loadout_item/suit_store/main_gun/squad_leader/standard_rifle/enhanced, /datum/loadout_item/suit_store/main_gun/squad_leader/standard_rifle, SQUAD_LEADER)
		owner_stats.replace_loadout_option(/datum/loadout_item/suit_store/main_gun/field_commander/carbine/enhanced, /datum/loadout_item/suit_store/main_gun/field_commander/carbine, FIELD_COMMANDER)
		owner_stats.replace_loadout_option(/datum/loadout_item/suit_store/main_gun/field_commander/standard_rifle/enhanced, /datum/loadout_item/suit_store/main_gun/field_commander/standard_rifle, FIELD_COMMANDER)

		owner_stats.unlock_loadout_item(/datum/loadout_item/suit_store/main_gun/marine/plasma_rifle, SQUAD_MARINE, owner, 0)
		owner_stats.unlock_loadout_item(/datum/loadout_item/suit_store/main_gun/corpsman/plasma_rifle, SQUAD_CORPSMAN, owner, 0)
		owner_stats.unlock_loadout_item(/datum/loadout_item/suit_store/main_gun/engineer/plasma_rifle, SQUAD_ENGINEER, owner, 0)
		owner_stats.unlock_loadout_item(/datum/loadout_item/suit_store/main_gun/squad_leader/plasma_rifle, SQUAD_LEADER, owner, 0)
		owner_stats.unlock_loadout_item(/datum/loadout_item/suit_store/main_gun/field_commander/plasma_rifle, FIELD_COMMANDER, owner, 0)

	else if(owner_stats.faction == FACTION_SOM)
		owner_stats.replace_loadout_option(/datum/loadout_item/suit_store/main_gun/som_marine/standard_rifle/enhanced, /datum/loadout_item/suit_store/main_gun/som_marine/standard_rifle, SOM_SQUAD_MARINE)
		owner_stats.replace_loadout_option(/datum/loadout_item/suit_store/main_gun/som_marine/suppressed_rifle/enhanced, /datum/loadout_item/suit_store/main_gun/som_marine/suppressed_rifle, SOM_SQUAD_MARINE)
		owner_stats.replace_loadout_option(/datum/loadout_item/suit_store/main_gun/som_medic/standard_rifle/enhanced, /datum/loadout_item/suit_store/main_gun/som_medic/standard_rifle, SOM_SQUAD_CORPSMAN)
		owner_stats.replace_loadout_option(/datum/loadout_item/suit_store/main_gun/som_engineer/standard_rifle/enhanced, /datum/loadout_item/suit_store/main_gun/som_engineer/standard_rifle, SOM_SQUAD_ENGINEER)

		owner_stats.unlock_loadout_item(/datum/loadout_item/suit_store/main_gun/som_marine/volkite_charger, SOM_SQUAD_MARINE, owner, 0)
		owner_stats.unlock_loadout_item(/datum/loadout_item/suit_store/main_gun/som_medic/volkite_charger, SOM_SQUAD_CORPSMAN, owner, 0)
		owner_stats.unlock_loadout_item(/datum/loadout_item/suit_store/main_gun/som_engineer/volkite_charger, SOM_SQUAD_ENGINEER, owner, 0)

/datum/perk/skill_mod/smgs
	name = "Advanced SMG training"
	desc = "Improved damage, accuracy and scatter with SMG type firearms. Unlocks new weapons and ammo types for some roles."
	req_desc = "Requires Advanced combat training."
	ui_icon = "smgs"
	smgs = 1
	all_jobs = TRUE
	prereq_perks = list(/datum/perk/skill_mod/combat)
	unlock_cost = 500

/datum/perk/skill_mod/smgs/unlock_bonus(mob/living/carbon/owner, datum/individual_stats/owner_stats)
	if(!istype(owner_stats))
		return
	if(owner_stats.faction == FACTION_TERRAGOV)
		owner_stats.replace_loadout_option(/datum/loadout_item/suit_store/main_gun/marine/standard_smg/enhanced, /datum/loadout_item/suit_store/main_gun/marine/standard_smg, SQUAD_MARINE)
		owner_stats.replace_loadout_option(/datum/loadout_item/suit_store/main_gun/marine/smg_and_shield/enhanced, /datum/loadout_item/suit_store/main_gun/marine/smg_and_shield, SQUAD_MARINE)
		owner_stats.replace_loadout_option(/datum/loadout_item/suit_store/main_gun/corpsman/standard_smg/enhanced, /datum/loadout_item/suit_store/main_gun/corpsman/standard_smg, SQUAD_CORPSMAN)
		owner_stats.replace_loadout_option(/datum/loadout_item/suit_store/main_gun/engineer/standard_smg/enhanced, /datum/loadout_item/suit_store/main_gun/engineer/standard_smg, SQUAD_ENGINEER)
		owner_stats.replace_loadout_option(/datum/loadout_item/suit_store/main_gun/squad_leader/standard_smg/enhanced, /datum/loadout_item/suit_store/main_gun/squad_leader/standard_smg, SQUAD_LEADER)

		owner_stats.unlock_loadout_item(/datum/loadout_item/suit_store/main_gun/marine/plasma_smg, SQUAD_MARINE, owner, 0)
		owner_stats.unlock_loadout_item(/datum/loadout_item/suit_store/main_gun/corpsman/plasma_smg, SQUAD_CORPSMAN, owner, 0)
		owner_stats.unlock_loadout_item(/datum/loadout_item/suit_store/main_gun/engineer/plasma_smg, SQUAD_ENGINEER, owner, 0)
		owner_stats.unlock_loadout_item(/datum/loadout_item/suit_store/main_gun/squad_leader/plasma_smg, SQUAD_LEADER, owner, 0)
		owner_stats.unlock_loadout_item(/datum/loadout_item/suit_store/main_gun/field_commander/plasma_smg, FIELD_COMMANDER, owner, 0)
	else if(owner_stats.faction == FACTION_SOM)
		owner_stats.replace_loadout_option(/datum/loadout_item/suit_store/main_gun/som_marine/smg/enhanced, /datum/loadout_item/suit_store/main_gun/som_marine/smg, SOM_SQUAD_MARINE)
		owner_stats.replace_loadout_option(/datum/loadout_item/suit_store/main_gun/som_marine/smg_and_shield/enhanced, /datum/loadout_item/suit_store/main_gun/som_marine/smg_and_shield, SOM_SQUAD_MARINE)
		owner_stats.replace_loadout_option(/datum/loadout_item/suit_store/main_gun/som_medic/smg/enhanced, /datum/loadout_item/suit_store/main_gun/som_medic/smg, SOM_SQUAD_CORPSMAN)
		owner_stats.replace_loadout_option(/datum/loadout_item/suit_store/main_gun/som_engineer/smg/enhanced, /datum/loadout_item/suit_store/main_gun/som_engineer/smg, SOM_SQUAD_ENGINEER)

/datum/perk/skill_mod/heavy_weapons
	name = "Heavy weapon specialisation"
	desc = "Improved damage, accuracy and scatter with heavy weapon type firearms. Unlocks new weapons and ammo types for some roles."
	req_desc = "Requires Advanced combat training."
	ui_icon = "heavy"
	heavy_weapons = 1
	all_jobs = TRUE
	prereq_perks = list(/datum/perk/skill_mod/combat)
	unlock_cost = 800

/datum/perk/skill_mod/heavy_weapons/unlock_bonus(mob/living/carbon/owner, datum/individual_stats/owner_stats)
	if(!istype(owner_stats))
		return
	if(owner_stats.faction == FACTION_TERRAGOV)
		owner_stats.unlock_loadout_item(/datum/loadout_item/back/tgmc_heam_rocket_bag, SQUAD_MARINE, owner, 0)
		owner_stats.unlock_loadout_item(/datum/loadout_item/suit_store/main_gun/marine/plasma_cannon, SQUAD_MARINE, owner, 0)
		owner_stats.unlock_loadout_item(/datum/loadout_item/back/minigun_powerpack, SQUAD_MARINE, owner, 0)
		owner_stats.unlock_loadout_item(/datum/loadout_item/suit_store/main_gun/marine/minigun, SQUAD_MARINE, owner, 0)
	else if(owner_stats.faction == FACTION_SOM)
		owner_stats.unlock_loadout_item(/datum/loadout_item/back/som_heat_rocket_bag, SOM_SQUAD_VETERAN, owner, 0)

/datum/perk/skill_mod/smartgun
	name = "Advanced smartgun training"
	desc = "Improved damage, accuracy and scatter with smartguns type firearms."
	req_desc = "Requires Advanced combat training."
	ui_icon = "smartguns"
	smartgun = 1
	jobs_supported = list(SQUAD_SMARTGUNNER, CAPTAIN)
	prereq_perks = list(/datum/perk/skill_mod/combat)
	unlock_cost = 800

/datum/perk/skill_mod/construction
	name = "Advanced construction training"
	desc = "Faster construction times when building. Some items may no longer have a penalty delay when constructing, and engineers exclusively build tougher barricades."
	ui_icon = "construction"
	construction = 2
	all_jobs = TRUE
	unlock_cost = 350

/datum/perk/skill_mod/construction/apply_perk(mob/living/carbon/owner)
	. = ..()
	if((owner.skills.getRating(SKILL_CONSTRUCTION)) < SKILL_CONSTRUCTION_MASTER)
		return
	ADD_TRAIT(owner, TRAIT_SUPERIOR_BUILDER, type)

/datum/perk/skill_mod/construction/remove_perk(mob/living/carbon/owner)
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_SUPERIOR_BUILDER, type)

/datum/perk/skill_mod/leadership
	name = "Advanced leadership training"
	desc = "Advanced leadership training and battlefield experience resulting in an improved ability to command and control the soldiers under your command. Improved effectiveness and range when issuing orders."
	ui_icon = "leadership"
	leadership = 1
	jobs_supported = list(SQUAD_LEADER, FIELD_COMMANDER, STAFF_OFFICER, CAPTAIN, SOM_SQUAD_LEADER, SOM_STAFF_OFFICER, SOM_FIELD_COMMANDER, SOM_COMMANDER)
	unlock_cost = 1100

/datum/perk/skill_mod/medical
	name = "Advanced medical training"
	desc = "Faster at applying medical items. Some items may no longer have a penalty delay. Unlocks access to improved first aid pouches if not already available."
	ui_icon = "medical"
	medical = 2
	all_jobs = TRUE
	unlock_cost = 300

/datum/perk/skill_mod/medical/unlock_bonus(mob/living/carbon/owner, datum/individual_stats/owner_stats)
	if(!istype(owner_stats))
		return
	if(owner_stats.faction == FACTION_TERRAGOV)
		for(var/job_type in owner_stats.loadouts)
			owner_stats.replace_loadout_option(/datum/loadout_item/r_pocket/standard_first_aid/standard_improved, /datum/loadout_item/r_pocket/standard_first_aid, job_type)
			owner_stats.replace_loadout_option(/datum/loadout_item/l_pocket/standard_first_aid/standard_improved, /datum/loadout_item/l_pocket/standard_first_aid, job_type)

	else if(owner_stats.faction == FACTION_SOM)
		for(var/job_type in owner_stats.loadouts)
			owner_stats.replace_loadout_option(/datum/loadout_item/r_pocket/som_standard_first_aid/standard_improved, /datum/loadout_item/r_pocket/som_standard_first_aid, job_type)
			owner_stats.replace_loadout_option(/datum/loadout_item/l_pocket/som_standard_first_aid/standard_improved, /datum/loadout_item/l_pocket/som_standard_first_aid, job_type)

/datum/perk/skill_mod/stamina
	name = "Improved stamina"
	desc = "Superior physical conditioning results in overall improved stamina. Improved max stamina, stamina regen rate, and reduces the delay before stamina begins to regenerate after stamina loss."
	ui_icon = "stamina_1"
	stamina = 1
	all_jobs = TRUE
	unlock_cost = 600
	///How much this perk increases your max_stam by
	var/stam_mod = 10

/datum/perk/skill_mod/stamina/apply_perk(mob/living/carbon/owner)
	. = ..()
	owner.max_stamina += stam_mod
	owner.max_stamina_buffer += stam_mod

/datum/perk/skill_mod/stamina/remove_perk(mob/living/carbon/owner)
	. = ..()
	owner.max_stamina -= stam_mod
	owner.max_stamina_buffer -= stam_mod

/datum/perk/skill_mod/stamina/two
	name = "Extreme stamina"
	desc = "Mechanically augmented physical conditioning results in significantly enhanced overall stamina. Further improved max stamina, stamina regen rate, and reduced delay before stamina begins to regenerate after stamina loss."
	req_desc = "Requires Improved stamina."
	ui_icon = "stamina_2"
	prereq_perks = list(/datum/perk/skill_mod/stamina)
	unlock_cost = 800

/obj/effect/overlay/perk
	layer = ABOVE_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	icon = 'icons/effects/perk_unlock.dmi'
	icon_state = ""
	pixel_x = 8
	pixel_y = 32
