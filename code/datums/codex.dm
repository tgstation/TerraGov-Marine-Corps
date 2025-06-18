///Uses the SIGN macro to return a string of "+" if x is 0 or greater
#define PRINT_SIGN_IF_POSITIVE(x) SIGN(x) >= 0 ? "+" : ""

/client/verb/codex()
	set name = "Open Codex"
	set category = "OOC"
	set desc ="Open and browse the Codex"

	//TO-DO: make this stuff actually work
	codex = new /datum/codex(src)
	codex.open_ui(mob)

/datum/codex
	///Whatever page the codex is currently on
	var/atom/entry
	///The client using the UI
	var/client/owner
	///The search results from the last search; is stored here by the SScodex then passed on to the UI
	var/list/search_results

/datum/codex/New(client)
	owner = client

//TO-DO: Figure out if this should be deleted and use ui_interact instead
/datum/codex/proc/open_ui(mob/viewer, atom/target)
	entry = target
	ui_interact(viewer)

/datum/codex/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Codex", "Codex", always_open = TRUE)
		ui.open()

/datum/codex/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	if(action == "search_codex")
		var/query = params["query"]
		var/list/results = SScodex.search_codex(query)
		search_results = results
		return TRUE

/datum/codex/ui_data(mob/user)
	var/list/data = SScodex.get_codex_data(entry)
	. = list()
	.["name"] = data["name"]
	.["description"] = data["description"]
	.["mechanics"] = data["mechanics"]
	.["lore"] = data["lore"]
	.["antag"] = data["antag"]
	.["attributes"] = data["attributes"]
	.["background"] = data["background"]
	.["is_gun"] = data["is_gun"]
	.["is_clothing"] = data["is_clothing"]
	.["searchResults"] = length(search_results) ? search_results : null

/datum/codex/ui_static_data(mob/user)
	return list()

/* --- TO-DO: MOVE THIS STUFF WHERE IT BELONGS FINISHED --- */

///Return a list of background information and lore for the Codex to display
/atom/proc/get_background_info()
	return list()

/obj/item/weapon/gun/get_background_info()
	var/list/data = list()
	var/list/entries = SScodex.retrieve_entries_for_string(general_codex_key)
	var/datum/codex_entry/general_entry = LAZYACCESS(entries, 1)
	if(general_entry?.mechanics_text)
		data += general_entry.mechanics_text
		data += general_entry.lore_text
	return data

///Return a list of this object's attributes for the Codex to display; health, weight, etc
/atom/proc/get_attributes()
	. = list()

/obj/item/weapon/gun/get_attributes()
	. = ..()
	. += list("Caliber" = "[caliber]\
			TT| Ammunition type used by this weapon.")
	if(damage_mult != 1)
		var/multiplier = PERCENT(damage_mult - 1)
		. += list("Damage Modifier" = "[PRINT_SIGN_IF_POSITIVE(multiplier)][multiplier]%\
			TT| Increase or decrease damage dealt by projectiles fired from this weapon")
	if(damage_falloff_mult)
		. += list("Damage Falloff Modifier" = "[(PERCENT(damage_falloff_mult - 1))]%\
			TT| Increase or decrease the rate at which projectiles fired from this weapon lose damage over distance \
			(Note: This is a MODIFIER on the projectile, NOT a fixed amount by which damage is reduced per tile)")
	. += list("Time Between Shots" = "[fire_delay ? fire_delay / 10 : "0"] seconds\
			TT| Wait for this long after firing a bullet before you can fire another one")
	if(burst_amount > 1)
		. += list("Shots Per Burst" = "[burst_amount]\
			TT| Number of projectiles fired per burst")
		. += list("Time Between Bursts" = "[(min((burst_delay * 2), (fire_delay * 3))) / 10] seconds\
			TT| Wait for this long after firing a burst before you can fire another one")
	if(max_shells)	//Use max_shells first because max_rounds is null if a magazine-based gun has no magazine inserted
		. += list("Ammo Capacity" = "[max_shells][CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_CYCLE_ONLY_BEFORE_FIRE) ? "" : " + 1"] rounds")
	else if(max_chamber_items)	//Usually used by guns with internal magazines like pump shotguns and revolvers
		. += list("Ammo Capacity" = "[max_rounds] rounds")
	if(max_shots)	//Used by energy weapons
		. += list("Charge Capacity" = "[max_shots] shots")
	. += list("Time To Wield" = "[wield_delay / 10] seconds")
	if(accuracy_mult)
		. += list("Accuracy Multiplier" = "[PRINT_SIGN_IF_POSITIVE(accuracy_mult)][PERCENT(accuracy_mult - 1)]%\
			TT| Modifier to the accuracy of projectiles fired from this weapon; Attachments will change this number")
	if(accuracy_mult_unwielded)
		. += list("Unwielded Accuracy Modifier" = "[PERCENT(accuracy_mult_unwielded - 1)]%\
			TT| Accuracy penalty when firing this weapon one-handed")
	. += list("Accuracy Penalty While Moving" = "[(movement_acc_penalty_mult * 0.15) * 100]%")
	. += list("Scatter" = "[scatter]")
	. += list("Unwielded Scatter" = "[scatter_unwielded]\
			TT| Note: This is a fixed number, not a modifier to normal scatter")
	if(burst_scatter_mult != 1)
		. += list("Burst Scatter Modifier" = "[PRINT_SIGN_IF_POSITIVE(burst_scatter_mult)][PERCENT(burst_scatter_mult - 1)]%\
			TT| Increase or decrease the scatter of projectiles when fired as part of a burst")
	. += list("Recoil" = "[recoil]")
	. += list("Unwielded Recoil" = "[recoil_unwielded]\
			TT| Note: This is a fixed number, not a modifier to normal recoil")

///Return a list of mechanical details for the Codex to display; what ammo it accepts, etc
/atom/proc/get_mechanics()
	. = list()

/obj/get_mechanics()
	. += list("Melee Damage" = "[force]")

/obj/item/get_mechanics()
	. = ..()
	. += list("Size" = "[weight_class_to_text(w_class)]")

/obj/item/weapon/gun/get_mechanics()
	. = ..()
	var/skill
	switch(gun_skill_category)
		if(SKILL_RIFLES)
			skill = "rifle skill"
		if(SKILL_SMGS)
			skill = "SMG skill"
		if(SKILL_HEAVY_WEAPONS)
			skill = "heavy weapon skill"
		if(SKILL_SMARTGUN)
			skill = "smartgun skill"
		if(SKILL_SHOTGUNS)
			skill = "shotgun skill"
		if(SKILL_PISTOLS)
			skill = "pistol skill"

	if(skill)
		. += list("Skill" = "This weapons is affected by the [skill] level.")
	if(CHECK_BITFIELD(gun_features_flags, GUN_WIELDED_FIRING_ONLY))
		. += list("Wielded" = "This can only be fired with a two-handed grip.")
	if(/datum/action/item_action/aim_mode in actions_types)
		. += list("Aim Mode" = "This weapon can be aimed.")
		. += list("Time Between Aimed Shots" = "[(fire_delay + aim_fire_delay) / 10] seconds")
	if(scope_zoom)
		. += list("Scope" = "It has a magnifying optical scope. It can be toggled with Use Scope verb.")
	if(gun_firemode_list.len > 1)
		. += list("Firemodes" = "Can fire in [english_list(gun_firemode_list)]. Click the Toggle Burst Fire button to change it.")

	var/list/loading_ways = list()
	if(load_method & SINGLE_CASING)
		loading_ways += "loose [caliber] rounds"
	if(load_method & SPEEDLOADER)
		loading_ways += "speedloaders"
	if(load_method & MAGAZINE)
		loading_ways += "magazines"
	if(load_method & CELL)
		loading_ways += "cells"
	if(load_method & POWERPACK)
		loading_ways += "it's powerpack"
	. += list("Loading System" = "Can be loaded using [english_list(loading_ways)].")

	//Add a sublist of attachments categorized by what slot they fit in
	if(attachable_allowed)
		var/list/attachments = list()
		for(var/X in attachable_allowed)
			var/obj/item/attachable/attachment = X
			switch(attachment.slot)
				if(ATTACHMENT_SLOT_RAIL)
					attachments["Rail"] += list("[initial(attachment.name)]")
				if(ATTACHMENT_SLOT_UNDER)
					attachments["Underbarrel"] += list("[initial(attachment.name)]")
				if(ATTACHMENT_SLOT_MUZZLE)
					attachments["Muzzle"] += list("[initial(attachment.name)]")
				if(ATTACHMENT_SLOT_STOCK)
					attachments["Stock"] += list("[initial(attachment.name)]")
				if(ATTACHMENT_BARREL_MOD)
					attachments["Barrel"] += list("[initial(attachment.name)]")
		. += list("Compatible Attachments" = attachments)
