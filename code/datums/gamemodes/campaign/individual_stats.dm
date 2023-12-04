/datum/individual_stats
	interaction_flags = INTERACT_UI_INTERACT
	///ckey associated with this datum
	var/ckey
	///currently occupied mob - if any
	var/mob/living/carbon/current_mob //will we actually need this?
	///whatever cash/xp/placeholdershit. fun tokens
	var/currency = 0
	///Player perks
	var/list/list/datum/perk/perks = list()
	///Unlocked items
	var/list/list/datum/loadout_item/unlocked_items = list() //probs some initial list here based on class etc.
	///List of loadouts by role
	var/list/datum/outfit/quick/loadouts = list()
	///The faction associated with these stats
	var/faction

/datum/individual_stats/New(mob/living/carbon/new_mob, new_faction, new_currency)
	. = ..()
	ckey = new_mob.key
	current_mob = new_mob
	faction = new_faction
	currency = new_currency
	for(var/datum/job/job_type AS in SSticker.mode.valid_job_types)
		if(job_type::faction != faction)
			continue
		loadouts[job_type] = new
		perks[job_type] = list()
		unlocked_items[job_type] = list()

/datum/individual_stats/Destroy(force, ...)
	ckey = null
	current_mob = null
	perks = null
	unlocked_items = null
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

///Adds a perk if able
/datum/individual_stats/proc/purchase_perk(datum/perk/new_perk)
	if(!istype(new_perk))
		return
	//insert 'we already got this' check here, unless we have a 'purchasable list'
	if(use_funds(new_perk.unlock_cost))
		return

	if(!length(new_perk.jobs_supported))
		for(var/job in perks)
			perks[job] += new_perk
	else
		for(var/supported_job in new_perk.jobs_supported)
			if(!perks[supported_job])
				continue
			perks[supported_job] += new_perk

///Adds an item if able
/datum/individual_stats/proc/unlock_loadout_item(datum/loadout_item/new_item)
	if(!istype(new_item))
		return
	//insert 'we already got this' check here, unless we have a 'purchasable list'
	if(use_funds(new_item.unlock_cost))
		return

	if(!length(new_item.jobs_supported))
		for(var/job in unlocked_items)
			unlocked_items[job] += new_item
	else
		for(var/supported_job in new_item.jobs_supported)
			if(!unlocked_items[supported_job])
				continue
			unlocked_items[supported_job] += new_item

///Applies all perks to a mob
/datum/individual_stats/proc/apply_perks(mob/living/carbon/user)
	for(var/datum/perk/perk AS in perks[user.job])
		perk.apply_perk(user)

///Attempts to add an available item to a loadout
/datum/individual_stats/proc/attempt_add_loadout_item(datum/loadout_item/new_item, role)
	new_item.attempt_add_loadout_item(loadouts[role])
