/datum/perk
	///Name of the perk
	var/name = "base perk name"
	///Brief description of the perk
	var/desc = "desc here"

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
	cqc = 1

/datum/perk/skill_mod/cqc_two
	cqc = 2

/datum/perk/skill_mod/melee
	melee_weapons = 1

/datum/perk/skill_mod/melee_two
	melee_weapons = 2

/datum/perk/skill_mod/pistols
	pistols = 1

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
