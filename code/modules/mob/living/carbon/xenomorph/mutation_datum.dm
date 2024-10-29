GLOBAL_DATUM_INIT(mutation_selector, /datum/mutation_datum, new)

/datum/mutation_datum
	interaction_flags = INTERACT_UI_INTERACT

/datum/mutation_datum/ui_state(mob/user)
	return GLOB.hive_ui_state // Similar purpose.

/datum/mutation_datum/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MutationSelector", "Mutation Selector")
		ui.open()

/datum/mutation_datum/ui_data(mob/living/carbon/xenomorph/xeno_user)
	var/list/data = list()

	data["shell_chambers"] = length(xeno_user.hive?.shell_chambers)
	data["spur_chambers"] = length(xeno_user.hive?.shell_chambers)
	data["veil_chambers"] = length(xeno_user.hive?.shell_chambers)
	data["biomass"] = xeno_user.biomass
	switch(xeno_user.xeno_caste.tier)
		if(XENO_TIER_ONE)
			data["cost"] = XENO_UPGRADE_BIOMASS_COST_T1
		if(XENO_TIER_TWO)
			data["cost"] = XENO_UPGRADE_BIOMASS_COST_T2
		if(XENO_TIER_THREE)
			data["cost"] = XENO_UPGRADE_BIOMASS_COST_T3
		else
			data["cost"] = XENO_UPGRADE_BIOMASS_COST_T4

	var/list/upgrades = list(
		list(
			"category" = "Survival",
			"upgrades" = list(
				list(
					"name" = "Carapace",
					"desc" = "Increase our armor."
				),
				list(
					"name" = "Regeneration",
					"desc" = "Increase our health regeneration."
				),
				list(
					"name" = "Vampirism",
					"desc" = "Leech from our attacks."
				)
			)
		),
		list(
			"category" = "Attack",
			"upgrades" = list(
				list(
					"name" = "Celerity",
					"desc" = "Increase our movement speed."
				),
				list(
					"name" = "Adrenaline",
					"desc" = "Increase our plasma regeneration."
				),
				list(
					"name" = "Crush",
					"desc" = "Increase our damage to objects."
				)
			)
		),
		list(
			"category" = "Utility",
			"upgrades" = list(
				list(
					"name" = "Toxin",
					"desc" = "Inject toxins into our target."
				),
				list(
					"name" = "Pheromones",
					"desc" = "Ability to emit pheromones."
				),
				list(
					"name" = "Trail",
					"desc" = "Leave a trail behind."
				)
			)
		)
	)
	data["upgrades"] = upgrades

	return data

/datum/mutation_datum/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("purchase")
			var/type = params["type"]
			if(type == "Carapace")
				remove_apply_upgrades(usr, GLOB.xeno_survival_upgrades, STATUS_EFFECT_UPGRADE_CARAPACE)
			if(type == "Regeneration")
				remove_apply_upgrades(usr, GLOB.xeno_survival_upgrades, STATUS_EFFECT_UPGRADE_REGENERATION)
			if(type == "Vampirism")
				remove_apply_upgrades(usr, GLOB.xeno_survival_upgrades, STATUS_EFFECT_UPGRADE_VAMPIRISM)
			if(type == "Celerity")
				remove_apply_upgrades(usr, GLOB.xeno_survival_upgrades, STATUS_EFFECT_UPGRADE_CELERITY)
			if(type == "Adrenaline")
				remove_apply_upgrades(usr, GLOB.xeno_survival_upgrades, STATUS_EFFECT_UPGRADE_ADRENALINE)
			if(type == "Crush")
				remove_apply_upgrades(usr, GLOB.xeno_survival_upgrades, STATUS_EFFECT_UPGRADE_CRUSH)
			if(type == "Toxin")
				remove_apply_upgrades(usr, GLOB.xeno_survival_upgrades, STATUS_EFFECT_UPGRADE_TOXIN)
			if(type == "Pheromones")
				remove_apply_upgrades(usr, GLOB.xeno_survival_upgrades, STATUS_EFFECT_UPGRADE_PHERO)
			if(type == "Trail")
				remove_apply_upgrades(usr, GLOB.xeno_survival_upgrades, STATUS_EFFECT_UPGRADE_TRAIL)

	SStgui.close_user_uis(usr, src)

/datum/mutation_datum/proc/remove_apply_upgrades(mob/ui_usr, list/upgrades_to_remove, datum/status_effect/upgrade_to_apply)
	if(!isxeno(ui_usr))
		return
	var/mob/living/carbon/xenomorph/xeno_user = ui_usr

	var/upgrade_price
	switch(xeno_user.xeno_caste.tier)
		if(XENO_TIER_ONE)
			upgrade_price = XENO_UPGRADE_BIOMASS_COST_T1
		if(XENO_TIER_TWO)
			upgrade_price = XENO_UPGRADE_BIOMASS_COST_T2
		if(XENO_TIER_THREE)
			upgrade_price = XENO_UPGRADE_BIOMASS_COST_T3
		else
			upgrade_price = XENO_UPGRADE_BIOMASS_COST_T4

	if(xeno_user.biomass < upgrade_price)
		to_chat(usr, span_warning("You don't have enough biomass!"))
		return

	var/upgrade = locate(upgrade_to_apply) in xeno_user.status_effects
	if(upgrade)
		to_chat(usr, span_xenonotice("Existing mutation chosen. No biomass spent."))
		return

	xeno_user.biomass -= upgrade_price
	to_chat(xeno_user, span_xenonotice("Mutation gained."))
	for(var/datum/status_effect/removed_status_effect AS in upgrades_to_remove)
		xeno_user.remove_status_effect(removed_status_effect)
	xeno_user.do_jitter_animation(500)
	xeno_user.apply_status_effect(upgrade_to_apply)

