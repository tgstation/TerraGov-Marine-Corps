/datum/individual_stats
	interaction_flags = INTERACT_UI_INTERACT
	///ckey associated with this datum
	var/ckey
	///currently occupied mob - if any
	var/mob/living/carbon/current_mob //will we actually need this?
	///whatever cash/xp/placeholdershit. fun tokens
	var/currency = 0

	var/list/valid_jobs = list()
	///Single list of unlocked perks for easy reference
	var/list/unlocked_perks = list()
	///Unlocked perks organised by jobs effected
	var/list/list/datum/perk/perks_by_job = list()
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
		valid_jobs += job_type::title
		loadouts[job_type::title] = new /datum/outfit_holder(job_type::title)
		perks_by_job[job_type::title] = list()
		unlocked_items[job_type::title] = list()

/datum/individual_stats/Destroy(force, ...)
	ckey = null
	current_mob = null
	unlocked_perks = null
	perks_by_job = null
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
	if(new_perk in unlocked_perks)
		return
	if(length(new_perk.prereq_perks))
		for(var/prereq in new_perk.prereq_perks)
			if(prereq in unlocked_perks)
				continue
			return
	if(use_funds(new_perk.unlock_cost))
		return

	unlocked_perks += new_perk
	for(var/supported_job in new_perk.jobs_supported)
		if(!perks_by_job[supported_job])
			continue
		perks_by_job[supported_job] += new_perk

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
	for(var/datum/perk/perk AS in perks_by_job[current_mob.job.title])
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
	if(isobserver(user))
		return GLOB.always_state
	return GLOB.conscious_state

//datum/individual_stats/ui_data(mob/user)
	//. = ..()

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
	data["jobs"] = valid_jobs
	data["currency"] = currency

	//replace below
	data["icons"] = GLOB.campaign_icons
	data["mission_icons"] = GLOB.campaign_mission_icons

	//perk stuff
	var/list/perks_data = list()
	for(var/job in perks_by_job)
		for(var/datum/perk/perk AS in GLOB.campaign_perks_by_role[job])
			var/list/perk_data = list()
			perk_data["name"] = perk.name
			perk_data["job"] = job
			perk_data["type"] = perk.type
			perk_data["desc"] = perk.desc
			perk_data["cost"] = perk.unlock_cost
			perk_data["icon"] = perk.ui_icon
			perk_data["currently_active"] = !!(perk in perks_by_job[job])
			perks_data += list(perk_data)
	data["perks_data"] = perks_data

	//loadout stuff
	var/list/equipped_loadouts_data = list() //shit currently equipped to ALL job outfits
	var/list/available_loadouts_data = list() //all available shit. note this currently does not include non purchased stuff
	for(var/i in loadouts)
		var/datum/outfit_holder/outfit = loadouts[i]
		for(var/slot in outfit.equipped_things)
			var/datum/loadout_item/loadout_item = outfit.equipped_things[slot]
			if(!loadout_item) //will probably be able to remove this eventually. Probably now, that we have defaults
				continue
			var/list/equipped_item_ui_data = list() //slot + equipped item data
			var/list/current_loadout_item_data = list() //equipped item data
			current_loadout_item_data["name"] = loadout_item.name
			current_loadout_item_data["job"] = outfit.role
			current_loadout_item_data["slot"] = GLOB.inventory_slots_to_string["[loadout_item.item_slot]"]
			current_loadout_item_data["type"] = loadout_item.type
			current_loadout_item_data["desc"] = loadout_item.desc
			current_loadout_item_data["purchase_cost"] = loadout_item.purchase_cost
			current_loadout_item_data["unlock_cost"] = loadout_item.unlock_cost  //todo: do related
			current_loadout_item_data["valid_choice"] = loadout_item.item_checks(outfit) //is this item valid based on the current loadout. Don't think we need !! but check
			current_loadout_item_data["icon"] = loadout_item.item_typepath::icon_state //todo: Figure out if this works from a ui perspective, or if an 'ui_icon' is needed like assets
			equipped_item_ui_data["slot"] = slot
			equipped_item_ui_data["slot_text"] = GLOB.inventory_slots_to_string["[slot]"]
			equipped_item_ui_data["item_type"] = current_loadout_item_data
			equipped_loadouts_data += list(equipped_item_ui_data)

		for(var/slot in outfit.available_list)
			for(var/datum/loadout_item/loadout_item AS in outfit.available_list[slot])
				var/list/available_loadout_item_data = list()
				available_loadout_item_data["name"] = loadout_item.name
				available_loadout_item_data["job"] = outfit.role
				available_loadout_item_data["slot"] = GLOB.inventory_slots_to_string["[loadout_item.item_slot]"]
				available_loadout_item_data["type"] = loadout_item.type
				available_loadout_item_data["desc"] = loadout_item.desc
				available_loadout_item_data["purchase_cost"] = loadout_item.purchase_cost
				available_loadout_item_data["unlock_cost"] = loadout_item.unlock_cost
				available_loadout_item_data["valid_choice"] = loadout_item.item_checks(outfit)
				available_loadout_item_data["icon"] = loadout_item.item_typepath::icon_state
				available_loadouts_data += list(available_loadout_item_data)

	data["equipped_loadouts_data"] = equipped_loadouts_data
	data["available_loadouts_data"] = available_loadouts_data

	return data

/datum/individual_stats/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/datum/game_mode/hvh/campaign/current_mode = SSticker.mode
	if(!istype(current_mode))
		CRASH("campaign_mission loaded without campaign game mode")

	var/mob/living/user = usr

	switch(action)
		if("unlock_perk")
			var/unlocked_perk = text2path(params["selected_perk"])
			if(!unlocked_perk)
				return
			if(!GLOB.campaign_perk_list[unlocked_perk])
				return
			var/datum/perk/perk = GLOB.campaign_perk_list[unlocked_perk]
			purchase_perk(perk)
			update_static_data(user)
			return TRUE
		if("equip_item")
			var/equipped_item_type = text2path(params["selected_item"])
			if(!equipped_item_type)
				return
			var/equipped_item_job = params["selected_job"]
			if(!equipped_item_job)
				return
			for(var/datum/loadout_item/item AS in GLOB.campaign_loadout_items_by_role[equipped_item_job])
				if(!istype(item, equipped_item_type))
					continue
				loadouts[equipped_item_job].attempt_equip_loadout_item(item)
				update_static_data(user)
				return TRUE
		if("equip_outfit")
			var/job = params["outfit_job"]
			if(!job || !loadouts[job])
				return
			var/insufficient_credits = use_funds(loadouts[job].loadout_cost)
			if(insufficient_credits)
				to_chat(user, "<span class='warning'>Requires [insufficient_credits] more credits.")
				return
			loadouts[job].equip_loadout(user)
			update_static_data(user)

//loadout/perk UI for campaign gamemode
/datum/action/campaign_loadout
	name = "Loadout menu"
	action_icon_state = "individual_stats"

/datum/action/campaign_loadout/action_activate()
	var/datum/faction_stats/your_faction = GLOB.faction_stats_datums[owner.faction]
	if(!your_faction)
		return

	var/datum/individual_stats/stats = your_faction.individual_stat_list[owner.key]
	if(!stats)
		//return
		stats = your_faction.individual_stat_list[null] //PLACEHOLDER. KEY IS NOT SET WHEN THE STAT DATUM IS MADE, FIX PLS.
	stats.interact(owner)
