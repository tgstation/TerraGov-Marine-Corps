GLOBAL_LIST_INIT(campaign_perk_list, list(
	//perks here
))

/datum/individual_stats
	interaction_flags = INTERACT_UI_INTERACT
	///ckey associated with this datum
	var/ckey
	///currently occupied mob - if any
	var/mob/living/carbon/current_mob //will we actually need this?
	///whatever cash/xp/placeholdershit. fun tokens
	var/currency = 0
	///Player perks
	var/list/datum/perk/perks = list()
	///The faction associated with these stats
	var/faction //will we actually need this? Maybe more relevant to have available perks,but may need for ui, depending on how this is viewed

/datum/individual_stats/New(new_faction, new_currency)
	. = ..()
	faction = new_faction
	currency = new_currency

/datum/individual_stats/Destroy(force, ...)
	ckey = null
	current_mob = null
	QDEL_NULL(perks)
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

/datum/individual_stats/proc/apply_bonuses(mob/living/carbon/user)
	for(var/datum/perk/perk AS in perks)
		perk.apply_perk()
