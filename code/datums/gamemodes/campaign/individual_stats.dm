#define TAB_LOADOUT "Loadout"
#define TAB_PERKS "Perks"

/datum/individual_stats
	interaction_flags = INTERACT_UI_INTERACT
	var/owner_ckey
	///currently occupied mob - if any
	var/mob/living/carbon/current_mob
	///Credits. You buy stuff with it
	var/currency = 450
	///List of job types based on faction
	var/list/valid_jobs = list()
	///Single list of unlocked perks for easy reference
	var/list/unlocked_perks = list()
	///Unlocked perks organised by jobs effected
	var/list/list/datum/perk/perks_by_job = list()
	///Unlocked items
	var/list/list/datum/loadout_item/unlocked_items = list()
	///List of loadouts by role
	var/list/datum/outfit_holder/loadouts = list()
	///The faction associated with these stats
	var/faction
	///Currently selected UI category tab
	var/selected_tab = TAB_LOADOUT
	///Currently selected UI job tab
	var/selected_job

/datum/individual_stats/New(mob/living/carbon/new_mob, new_faction, new_currency)
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_MISSION_ENDED, PROC_REF(post_mission_credits))
	owner_ckey = new_mob.ckey
	current_mob = new_mob
	faction = new_faction
	currency += new_currency
	for(var/datum/job/job_type AS in SSticker.mode.valid_job_types)
		if(job_type::faction != faction)
			continue
		valid_jobs += job_type::title
		loadouts[job_type::title] = new /datum/outfit_holder(job_type::title)
		perks_by_job[job_type::title] = list()
		unlocked_items[job_type::title] = list()

/datum/individual_stats/Destroy(force, ...)
	current_mob = null
	unlocked_perks = null
	perks_by_job = null
	unlocked_items = null
	return ..()

///Pay each player additional credits based on individual performance during the mission
/datum/individual_stats/proc/post_mission_credits(datum/source)
	SIGNAL_HANDLER
	var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[owner_ckey]
	give_funds(personal_statistics.get_mission_reward())

///Applies cash
/datum/individual_stats/proc/give_funds(amount)
	currency += amount
	if(!current_mob)
		return
	to_chat(current_mob, span_warning("You have received a cash bonus of [amount]."))

///uses some funtokens, returns the amount missing, if insufficient funds
/datum/individual_stats/proc/use_funds(amount)
	if(amount > currency)
		return amount - currency
	currency -= amount

///Adds a perk if able
/datum/individual_stats/proc/purchase_perk(datum/perk/new_perk, mob/living/user)
	. = TRUE
	if(!istype(new_perk))
		return FALSE
	if(new_perk in unlocked_perks)
		to_chat(user, span_warning("Perk already purchased."))
		return FALSE
	if(length(new_perk.prereq_perks))
		var/perk_found
		for(var/prereq in new_perk.prereq_perks)
			perk_found = FALSE
			for(var/datum/perk/perk AS in unlocked_perks)
				if(perk.type != prereq)
					continue
				perk_found = TRUE
			if(!perk_found)
				to_chat(user, span_warning("One or more prerequisites missing for this perk."))
				return FALSE
	if(use_funds(new_perk.unlock_cost))
		to_chat(user, span_warning("Insufficient funds for this perk."))
		return FALSE

	new_perk.unlock_bonus(user, src)
	unlocked_perks += new_perk
	for(var/supported_job in new_perk.jobs_supported)
		if(!perks_by_job[supported_job])
			continue
		perks_by_job[supported_job] += new_perk

	if(!istype(user)) //we immediately apply the perk where possible
		return
	if(!(user.job.title in new_perk.jobs_supported))
		return
	new_perk.unlock_animation(user)
	new_perk.apply_perk(user)
	user.playsound_local(user, 'sound/effects/perk_unlock.ogg', 60)

///Unlocks a loadout item for use
/datum/individual_stats/proc/unlock_loadout_item(item_type, job_type_or_types, mob/user, cost_override, job_req_override = FALSE)
	if(!islist(job_type_or_types))
		job_type_or_types = list(job_type_or_types)
	var/datum/loadout_item/item = GLOB.campaign_loadout_item_type_list[item_type]
	if(!istype(item))
		return FALSE
	var/insufficient_credits = use_funds(isnum(cost_override) ? cost_override : item.unlock_cost)
	if(insufficient_credits)
		to_chat(user, span_warning("Requires [insufficient_credits] more credits."))
		return FALSE
	for(var/job_type in job_type_or_types)
		if(!job_req_override && !(job_type in item.jobs_supported))
			continue
		loadouts[job_type]?.unlock_new_option(item)
	return TRUE

///Adds an item to the unlockable list for a job
/datum/individual_stats/proc/make_available_loadout_item(item_type, job_type_or_types, mob/user, job_req_override = FALSE)
	if(!islist(job_type_or_types))
		job_type_or_types = list(job_type_or_types)
	var/datum/loadout_item/item = GLOB.campaign_loadout_item_type_list[item_type]
	if(!istype(item))
		return FALSE
	for(var/job_type in job_type_or_types)
		if(!job_req_override && !(job_type in item.jobs_supported))
			continue
		loadouts[job_type]?.allow_new_option(item)
	return TRUE

///Adds and equips a loadout item, replacing another
/datum/individual_stats/proc/replace_loadout_option(new_item, removed_item, job_type_or_types, job_req_override = FALSE)
	if(!islist(job_type_or_types))
		job_type_or_types = list(job_type_or_types)
	var/datum/loadout_item/item = GLOB.campaign_loadout_item_type_list[new_item]
	if(!istype(item))
		return FALSE
	for(var/job_type in job_type_or_types)
		if(!job_req_override && !(job_type in item.jobs_supported))
			continue
		loadouts[job_type]?.unlock_new_option(item)
		if(loadouts[job_type]?.remove_option(GLOB.campaign_loadout_item_type_list[removed_item]))
			loadouts[job_type].attempt_equip_loadout_item(item)
	return TRUE

///Applies all perks to a mob
/datum/individual_stats/proc/apply_perks()
	if(!current_mob || QDELETED(current_mob))
		return
	for(var/datum/perk/perk AS in perks_by_job[current_mob.job.title])
		perk.apply_perk(current_mob)

//UI stuff
/datum/individual_stats/ui_assets(mob/user)
	return list(get_asset_datum(/datum/asset/spritesheet/campaign/perks), get_asset_datum(/datum/asset/spritesheet/campaign/loadout_items))

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

/datum/individual_stats/ui_data(mob/user)
	var/datum/game_mode/hvh/campaign/current_mode = SSticker.mode
	if(!istype(current_mode))
		CRASH("campaign_mission loaded without campaign game mode")

	var/list/data = list()
	var/mob/living/living_user = user
	data["current_job"] = istype(living_user) ? living_user.job.title : null
	data["currency"] = currency

	if(selected_tab != TAB_LOADOUT)
		return data
	//This cannot be static data due to the limitations on how frequently static data can be updated, and clicking on loadout options requires a data update.
	var/list/equipped_loadouts_data = list() //items currently equipped to ALL job outfits
	var/list/available_loadouts_data = list() //all available AND purchasable loadout options
	var/list/outfit_cost_data = list() //Current cost of all outfits

	var/datum/outfit_holder/outfit = loadouts[selected_job]

	var/list/outfit_cost_list = list()
	outfit_cost_list["job"] = selected_job
	outfit_cost_list["outfit_cost"] = outfit.loadout_cost
	outfit_cost_data += list(outfit_cost_list)

	for(var/slot in outfit.equipped_things)
		var/datum/loadout_item/loadout_item = outfit.equipped_things[slot]
		if(!loadout_item)
			continue
		var/list/equipped_item_ui_data = list() //slot + equipped item data
		var/list/current_loadout_item_data = list() //equipped item data
		current_loadout_item_data["name"] = loadout_item.name
		current_loadout_item_data["job"] = outfit.role
		current_loadout_item_data["slot"] = GLOB.inventory_slots_to_string["[loadout_item.item_slot]"]
		current_loadout_item_data["type"] = loadout_item.type
		current_loadout_item_data["desc"] = loadout_item.desc
		current_loadout_item_data["purchase_cost"] = loadout_item.purchase_cost
		current_loadout_item_data["unlock_cost"] = loadout_item.unlock_cost
		current_loadout_item_data["valid_choice"] = loadout_item.item_checks(outfit)
		current_loadout_item_data["icon"] = loadout_item.ui_icon
		current_loadout_item_data["quantity"] = loadout_item.quantity
		current_loadout_item_data["requirements"] = loadout_item.req_desc
		current_loadout_item_data["unlocked"] = TRUE

		equipped_item_ui_data["item_type"] = current_loadout_item_data
		equipped_item_ui_data["slot"] = slot
		equipped_item_ui_data["slot_text"] = GLOB.inventory_slots_to_string["[slot]"]

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
			available_loadout_item_data["icon"] = loadout_item.ui_icon
			available_loadout_item_data["quantity"] = loadout_item.quantity
			available_loadout_item_data["requirements"] = loadout_item.req_desc
			available_loadout_item_data["unlocked"] = TRUE
			available_loadouts_data += list(available_loadout_item_data)

	for(var/slot in outfit.purchasable_list)
		for(var/datum/loadout_item/loadout_item AS in outfit.purchasable_list[slot])
			var/list/purchasable_loadout_item_data = list()
			purchasable_loadout_item_data["name"] = loadout_item.name
			purchasable_loadout_item_data["job"] = outfit.role
			purchasable_loadout_item_data["slot"] = GLOB.inventory_slots_to_string["[loadout_item.item_slot]"]
			purchasable_loadout_item_data["type"] = loadout_item.type
			purchasable_loadout_item_data["desc"] = loadout_item.desc
			purchasable_loadout_item_data["purchase_cost"] = loadout_item.purchase_cost
			purchasable_loadout_item_data["unlock_cost"] = loadout_item.unlock_cost
			purchasable_loadout_item_data["valid_choice"] = loadout_item.item_checks(outfit)
			purchasable_loadout_item_data["icon"] = loadout_item.ui_icon
			purchasable_loadout_item_data["quantity"] = loadout_item.quantity
			purchasable_loadout_item_data["requirements"] = loadout_item.req_desc
			purchasable_loadout_item_data["unlocked"] = FALSE
			available_loadouts_data += list(purchasable_loadout_item_data)

	data["equipped_loadouts_data"] = equipped_loadouts_data
	data["available_loadouts_data"] = available_loadouts_data
	data["outfit_cost_data"] = outfit_cost_data

	return data

/datum/individual_stats/ui_static_data(mob/user)
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

	var/list/perks_data = list()
	for(var/job in perks_by_job)
		for(var/datum/perk/perk AS in GLOB.campaign_perks_by_role[job])
			var/list/perk_data = list()
			perk_data["name"] = perk.name
			perk_data["job"] = job
			perk_data["type"] = perk.type
			perk_data["desc"] = perk.desc
			perk_data["requirements"] = perk.req_desc
			perk_data["cost"] = perk.unlock_cost
			perk_data["icon"] = perk.ui_icon
			perk_data["currently_active"] = !!(perk in perks_by_job[job])
			perks_data += list(perk_data)
		data["perks_data"] = perks_data

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
		if("set_selected_tab")
			var/new_tab = params["new_selected_tab"]
			if(new_tab != TAB_LOADOUT && new_tab != TAB_PERKS)
				return
			selected_tab = new_tab
			user.playsound_local(user, 'sound/effects/menu_click.ogg', 50)
			return TRUE
		if("set_selected_job")
			var/new_job = params["new_selected_job"]
			if(!new_job)
				return
			selected_job = new_job
			user.playsound_local(user, 'sound/effects/menu_click.ogg', 50)
			return TRUE
		if("play_ding")
			user.playsound_local(user, 'sound/effects/menu_click.ogg', 50) //just for the consistant experience
			return TRUE
		if("unlock_perk")
			var/unlocked_perk = text2path(params["selected_perk"])
			if(!unlocked_perk)
				return
			if(!GLOB.campaign_perk_list[unlocked_perk])
				return
			var/datum/perk/perk = GLOB.campaign_perk_list[unlocked_perk]
			if(!purchase_perk(perk, user))
				return
			ui.send_full_update()
			user.playsound_local(user, 'sound/effects/menu_click.ogg', 50)
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
				loadouts[equipped_item_job].equip_loadout_item(item)
				user.playsound_local(user, 'sound/effects/menu_click.ogg', 50)
				return TRUE
		if("unlock_item")
			var/equipped_item_type = text2path(params["unlocked_item"])
			if(!equipped_item_type)
				return
			var/equipped_item_job = params["selected_job"]
			if(!equipped_item_job)
				return
			if(!unlock_loadout_item(equipped_item_type, equipped_item_job, user))
				return
			user.playsound_local(user, 'sound/effects/menu_click.ogg', 50)
			return TRUE
		if("equip_outfit")
			var/job = params["outfit_job"]
			if(!job || !loadouts[job])
				return
			if(!istype(user) || user.stat)
				to_chat(user, span_warning("Must be alive to do this!"))
				return
			var/datum/campaign_mission/current_mission = get_current_mission()
			if(!current_mission || current_mission.mission_state == MISSION_STATE_FINISHED)
				to_chat(user, span_warning("Wait for the next mission to be selected!"))
				return
			var/obj/item/card/id/user_id = user.get_idcard()
			if(!(user_id.id_flags & CAN_BUY_LOADOUT))
				to_chat(user, span_warning("You have already selected a loadout for this mission."))
				return
			if(user.job.title != job)
				to_chat(user, span_warning("Invalid job. This outfit is for [job]."))
				return
			if(!is_mainship_level(user.z))
				to_chat(user, span_warning("You can't equip a new loadout in the field!"))
				return
			if(!loadouts[job].check_full_loadout())
				to_chat(user, span_warning("Invalid loadout."))
				return
			var/insufficient_credits = use_funds(loadouts[job].loadout_cost)
			if(insufficient_credits)
				to_chat(user, span_warning("Requires [insufficient_credits] more credits."))
				return
			loadouts[job].equip_loadout(user)
			user.playsound_local(user, 'sound/effects/menu_click.ogg', 50)
			user_id.id_flags &= ~CAN_BUY_LOADOUT
			return TRUE

//loadout/perk UI for campaign gamemode
/datum/action/campaign_loadout
	name = "Loadout menu"
	action_icon_state = "individual_stats"

/datum/action/campaign_loadout/give_action(mob/M)
	. = ..()
	var/datum/faction_stats/your_faction = GLOB.faction_stats_datums[owner.faction]
	if(!your_faction)
		return

	var/datum/individual_stats/stats = your_faction.get_player_stats(owner)
	if(!stats)
		return
	stats.current_mob = M

/datum/action/campaign_loadout/action_activate()
	var/datum/faction_stats/your_faction = GLOB.faction_stats_datums[owner.faction]
	if(!your_faction)
		return
	var/datum/individual_stats/stats = your_faction.get_player_stats(owner)
	if(!stats)
		return
	stats.current_mob = owner //taking over ssd's creates a mismatch
	//we have to update selected tab/job so we load the correct data for the UI
	var/mob/living/living_owner = owner

	if(!isliving(owner) || !(living_owner?.job?.title in stats.valid_jobs))
		stats.selected_job = stats.valid_jobs[1]
	else
		stats.selected_job = living_owner.job.title
	stats.selected_tab = TAB_LOADOUT
	stats.interact(owner)

#undef TAB_LOADOUT
#undef TAB_PERKS
