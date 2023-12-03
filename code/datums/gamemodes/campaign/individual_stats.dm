GLOBAL_LIST_INIT(campaign_perk_list, list(
	//perks here
))

GLOBAL_LIST_INIT(campaign_unlock_list, list(
	//unlocks here
))

/datum/individual_stats
	interaction_flags = INTERACT_UI_INTERACT
	///ckey associated with this datum
	var/ckey
	///currently occupied mob - if any
	var/mob/living/carbon/human/current_mob //will we actually need this?
	///whatever cash/xp/placeholdershit. fun tokens
	var/currency = 0
	///Player skill set
	var/datum/skills/skill_bonus //how will we figure this considering multiple roles? more vars?
	///Player perks
	var/list/perks = list()

	var/list/unlocks = list() //will we need this?
	///The faction associated with these stats
	var/faction //will we actually need this?

/datum/individual_stats/New(new_faction, new_currency)
	. = ..()
	faction = new_faction
	currency = new_currency

/datum/individual_stats/Destroy(force, ...)
	ckey = null
	current_mob = null
	skill_bonus = null
	QDEL_NULL(perks)
	QDEL_NULL(unlocks)
	return ..()

///uses some funtokens, returns the amount missing, if insufficient funds
/datum/individual_stats/proc/give_funds(amount)
	currency += amount
	if(!current_mob)
		return
	to_chat(current_mob, "<span class='warning'>You have received a cash bonus of [amount].")

///uses some funtokens, returns the amount missing, if insufficient funds
/datum/individual_stats/proc/use_funds(amount)
	if(amount > currency)
		return amount - currency
	currency -= amount

/datum/individual_stats/proc/apply_bonuses(mob/living/carbon/human/user)
	//apply skill bonuses
	user.skills.modifyRating(skill_bonus.cqc, skill_bonus.melee_weapons,\
	skill_bonus.firearms, skill_bonus.pistols, skill_bonus.shotguns, skill_bonus.rifles, skill_bonus.smgs, skill_bonus.heavy_weapons, skill_bonus.smartgun,\
	skill_bonus.engineer, skill_bonus.construction, skill_bonus.leadership, skill_bonus.medical, skill_bonus.surgery, skill_bonus.pilot, skill_bonus.police, skill_bonus.powerloader, skill_bonus.large_vehicle)



/datum/perk
	var/name = "base perk name"
	var/desc = "desc here"
	///ckey associated with this datum
	var/ckey
	///currently occupied mob - if any
	var/mob/living/carbon/human/current_mob //will we actually need this?

/datum/perk/New(mob/living/carbon/human/new_owner)
	. = ..()
	current_mob = new_owner
	ckey = new_owner.key

/datum/perk/Destroy(force, ...)
	ckey = null
	current_mob = null
	remove_perk()
	return ..()

/datum/perk/proc/apply_perk()
	//apply bonus here

/datum/perk/proc/remove_perk()
	//remove bonus here

/datum/perk/trait
	var/list/traits

/datum/perk/trait/apply_perk()
	current_mob.add_traits(traits, type)

/datum/perk/trait/remove_perk()
	current_mob.remove_traits(traits, type)

/datum/perk/trait/quiet
	traits = list(TRAIT_LIGHT_STEP)

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

/datum/perk/skill_mod/apply_perk()
	current_mob.set_skills(current_mob.skills.modifyRating(cqc, melee_weapons, firearms, pistols, shotguns, rifles, smgs, heavy_weapons, smartgun, \
	engineer, construction, leadership, medical, surgery, pilot, police, powerloader, large_vehicle, stamina))

/datum/perk/skill_mod/remove_perk()
	current_mob.set_skills(current_mob.skills.modifyRating(-cqc, -melee_weapons, -firearms, -pistols, -shotguns, -rifles, -smgs, -heavy_weapons, -smartgun, \
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
