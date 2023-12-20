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
	var/list/datum/outfit_holder/loadouts = list()
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
		loadouts[job_type::title] = new /datum/outfit_holder(job_type::title)
		perks[job_type::title] = list()
		unlocked_items[job_type::title] = list()

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
		CRASH("loadout_item loaded with no supported jobs")

	for(var/supported_job in new_item.jobs_supported)
		if(!unlocked_items[supported_job])
			continue
		unlocked_items[supported_job] += new_item
		loadouts[supported_job].add_new_option(new_item)

///Applies all perks to a mob
/datum/individual_stats/proc/apply_perks()
	if(!current_mob || QDELETED(current_mob))
		return
	for(var/datum/perk/perk AS in perks[current_mob.job.title])
		perk.apply_perk(current_mob)

///Attempts to add an available item to a loadout
/datum/individual_stats/proc/attempt_equip_loadout_item(datum/loadout_item/new_item, role)
	loadouts[role].attempt_equip_loadout_item(new_item)


//UI stuff//

/datum/individual_stats/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(ui)
		return
	ui = new(user, src, "IndividualStats")
	ui.open()

/datum/individual_stats/ui_state(mob/user)
	return GLOB.conscious_state //will need to kill this later probably

/datum/individual_stats/ui_data(mob/user)
	. = ..()
	var/datum/game_mode/hvh/campaign/current_mode = SSticker.mode
	if(!istype(current_mode))
		CRASH("campaign_mission loaded without campaign game mode")

	var/list/data = list()

	var/list/perks_data = list()
	for(var/job in perks)
		for(var/datum/perk/perk AS in GLOB.campaign_perks_by_role[job])
			var/list/perk_data = list()
			perk_data["name"] = perk.name
			perk_data["job"] = job
			perk_data["type"] = perk.type
			perk_data["desc"] = perk.desc
			perk_data["cost"] = perk.unlock_cost
			perk_data["icon"] = perk.ui_icon
			perk_data["currently_active"] = !!(perk in perks[job])
			perks_data += list(perk_data)
	data["perks_data"] = perks_data

	data["currency"] = currency

	return data

/datum/individual_stats/ui_static_data(mob/user)
	. = ..()
	var/datum/game_mode/hvh/campaign/current_mode = SSticker.mode
	if(!istype(current_mode))
		CRASH("campaign_mission loaded without campaign game mode")

	var/list/data = list()

	var/ui_theme
	switch(faction)
		if(FACTION_SOM)
			ui_theme = "som"
		else
			ui_theme = "ntos"
	data["ui_theme"] = ui_theme

	data["faction"] = faction

	//replace below
	data["icons"] = GLOB.campaign_icons
	data["mission_icons"] = GLOB.campaign_mission_icons

	return data

/datum/individual_stats/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/datum/game_mode/hvh/campaign/current_mode = SSticker.mode
	if(!istype(current_mode))
		CRASH("campaign_mission loaded without campaign game mode")

	var/mob/living/user = usr

	switch(action) //insert shit here
		if("unlock_perk")
			var/unlocked_perk = text2path(params["selected_perk"])
			if(!unlocked_perk)
				return
			if(!GLOB.campaign_perk_list[unlocked_perk])
				return
			var/datum/perk/perk = GLOB.campaign_perk_list[unlocked_perk]
			purchase_perk(perk)
			return TRUE

///Opens up the players campaign status UI
/mob/living/proc/open_individual_stats_ui()
	set name = "Individual Stats"
	set desc = "Check the your individual stats and loadout."
	set category = "IC"

	var/datum/faction_stats/your_faction = GLOB.faction_stats_datums[faction]
	if(!your_faction)
		return

	var/datum/individual_stats/stats = your_faction.individual_stat_list[key]
	if(!stats)
		//return
		stats = your_faction.individual_stat_list[null] //PLACEHOLDER. KEY IS NOT SET WHEN THE STAT DATUM IS MADE, FIX PLS.
	stats.interact(src)
