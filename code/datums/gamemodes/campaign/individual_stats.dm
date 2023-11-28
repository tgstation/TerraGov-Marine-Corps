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
