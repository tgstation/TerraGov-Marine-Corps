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
	data["spur_chambers"] = length(xeno_user.hive?.spur_chambers)
	data["veil_chambers"] = length(xeno_user.hive?.veil_chambers)
	data["biomass"] = !isnull(SSpoints.xeno_biomass_points_by_hive[xeno_user.hivenumber]) ? SSpoints.xeno_biomass_points_by_hive[xeno_user.hivenumber] : 0
	return data

/datum/mutation_datum/ui_static_data(mob/living/carbon/xenomorph/xeno_user)
	var/list/data = list()

	// Cost is not expected to change as switching castes closes the UI.
	switch(xeno_user.xeno_caste.tier)
		if(XENO_TIER_ONE)
			data["cost"] = XENO_UPGRADE_BIOMASS_COST_T1
		if(XENO_TIER_TWO)
			data["cost"] = XENO_UPGRADE_BIOMASS_COST_T2
		if(XENO_TIER_THREE)
			data["cost"] = XENO_UPGRADE_BIOMASS_COST_T3
		else
			data["cost"] = XENO_UPGRADE_BIOMASS_COST_T4

	data["survival_mutations"] = list()
	for(var/datum/mutation_upgrade/survival/subtype_survival_mutation AS in subtypesof(/datum/mutation_upgrade/survival))
		data["survival_mutations"] += list(list( // Double listing is how it needs to work.
			"name" = subtype_survival_mutation.name,
			"desc" = subtype_survival_mutation.desc,
			"owned" = locate(subtype_survival_mutation.status_effect) in xeno_user.status_effects
		))

	data["attack_mutations"] = list()
	for(var/datum/mutation_upgrade/attack/subtype_attack_mutation AS in subtypesof(/datum/mutation_upgrade/attack))
		data["attack_mutations"] += list(list(
			"name" = subtype_attack_mutation.name,
			"desc" = subtype_attack_mutation.desc,
			"owned" = locate(subtype_attack_mutation.status_effect) in xeno_user.status_effects
		))

	data["utility_mutations"] = list()
	for(var/datum/mutation_upgrade/utility/subtype_utility_mutation AS in subtypesof(/datum/mutation_upgrade/utility))
		data["utility_mutations"] += list(list(
			"name" = subtype_utility_mutation.name,
			"desc" = subtype_utility_mutation.desc,
			"owned" = locate(subtype_utility_mutation.status_effect) in xeno_user.status_effects
		))

	return data

/datum/mutation_datum/ui_act(action, params)
	. = ..()
	if(.)
		return
	if(!isxeno(usr))
		return

	switch(action)
		if("purchase")
			try_purchase_mutation(usr, params["upgrade_name"])

	SStgui.close_user_uis(usr, src)

/// Tries to purchase a mutation. Denies if possible. Otherwise, removes conflicting mutations and gives the purchased mutation.
/datum/mutation_datum/proc/try_purchase_mutation(mob/living/carbon/xenomorph/xeno_purchaser, upgrade_name)
	if(!xeno_purchaser.hive || !upgrade_name)
		return
	if((xeno_purchaser.xeno_caste.caste_flags & CASTE_NO_MUTATION))
		return

	var/upgrade_price
	switch(xeno_purchaser.xeno_caste.tier)
		if(XENO_TIER_ONE)
			upgrade_price = XENO_UPGRADE_BIOMASS_COST_T1
		if(XENO_TIER_TWO)
			upgrade_price = XENO_UPGRADE_BIOMASS_COST_T2
		if(XENO_TIER_THREE)
			upgrade_price = XENO_UPGRADE_BIOMASS_COST_T3
		else
			upgrade_price = XENO_UPGRADE_BIOMASS_COST_T4

	var/current_biomass = !isnull(SSpoints.xeno_biomass_points_by_hive[xeno_purchaser.hivenumber]) ? SSpoints.xeno_biomass_points_by_hive[xeno_purchaser.hivenumber] : 0
	if(current_biomass < upgrade_price)
		to_chat(usr, span_warning("The hive does not have enough biomass!"))
		return

	var/datum/mutation_upgrade/chosen_mutation_upgrade
	for(var/datum/mutation_upgrade/subtype_mutation AS in GLOB.mutation_upgrades_buyable)
		if(subtype_mutation.name == upgrade_name)
			chosen_mutation_upgrade = subtype_mutation
			break

	if(!chosen_mutation_upgrade)
		return

	switch(chosen_mutation_upgrade.required_structure)
		if(MUTATION_STRUCTURE_CHAMBER)
			if(!length(xeno_purchaser.hive.shell_chambers))
				to_chat(usr, span_xenonotice("This mutation requires a shell chamber to exist!"))
				return
		if(MUTATION_STRUCTURE_SPUR)
			if(!length(xeno_purchaser.hive.spur_chambers))
				to_chat(usr, span_xenonotice("This mutation requires a spur chamber to exist!"))
				return
		if(MUTATION_STRUCTURE_VEIL)
			if(!length(xeno_purchaser.hive.veil_chambers))
				to_chat(usr, span_xenonotice("This mutation requires a veil chamber to exist!"))
				return

	var/existing_upgrade = locate(chosen_mutation_upgrade.status_effect) in xeno_purchaser.status_effects
	if(existing_upgrade)
		to_chat(usr, span_xenonotice("Existing mutation chosen. No biomass spent."))
		return

	var/list/mutation_status_effects_to_remove = list()
	for(var/datum/mutation_upgrade/subtype_mutation AS in GLOB.mutation_upgrades_buyable)
		if(chosen_mutation_upgrade.category == subtype_mutation.category)
			mutation_status_effects_to_remove += subtype_mutation.status_effect

	SSpoints.xeno_biomass_points_by_hive[xeno_purchaser.hivenumber] -= upgrade_price
	to_chat(xeno_purchaser, span_xenonotice("Mutation gained."))
	for(var/datum/status_effect/removed_status_effect AS in mutation_status_effects_to_remove)
		xeno_purchaser.remove_status_effect(removed_status_effect)
	xeno_purchaser.do_jitter_animation(500)
	xeno_purchaser.apply_status_effect(chosen_mutation_upgrade.status_effect)
	xeno_message("[xeno_purchaser] has purchased [chosen_mutation_upgrade.name] Mutation.", "xenoannounce", 5, xeno_purchaser.hivenumber)

/datum/mutation_upgrade
	/// The name that is displayed in the TGUI.
	var/name
	/// The description that is displayed in the TGUI.
	var/desc
	/// The category slot that this upgrade takes. Upgrades that conflict with this category slot will be removed/replaced.
	var/category
	/// The structure that needs to exist for a successful purchase.
	var/required_structure
	/// The status effect given upon successful purchase.
	var/datum/status_effect/status_effect

/datum/mutation_upgrade/survival
	category = MUTATION_CATEGORY_SURVIVAL
	required_structure = MUTATION_STRUCTURE_CHAMBER

/datum/mutation_upgrade/survival/carapace
	name = "Carapace"
	desc = "Increases our hard armor by 1 per Shell Chamber."
	status_effect = STATUS_EFFECT_UPGRADE_CARAPACE

/datum/mutation_upgrade/survival/regeneration
	name = "Regeneration"
	desc = "When regenerating health on weeds, regenerate 0.8% max health and 0.167 sunder per Shell Chamber."
	status_effect = STATUS_EFFECT_UPGRADE_REGENERATION

/datum/mutation_upgrade/survival/vampirism
	name = "Vampirism"
	desc = "When slashing living humans, heal 10% for damage dealt per Shell Chamber."
	status_effect = STATUS_EFFECT_UPGRADE_VAMPIRISM

/datum/mutation_upgrade/attack
	category = MUTATION_CATEGORY_ATTACK
	required_structure = MUTATION_STRUCTURE_SPUR

/datum/mutation_upgrade/attack/celerity
	name = "Celerity"
	desc = "Move -0.1 units faster per Spur Chamber."
	category = MUTATION_CATEGORY_ATTACK
	required_structure = MUTATION_STRUCTURE_SPUR
	status_effect = STATUS_EFFECT_UPGRADE_CELERITY

/datum/mutation_upgrade/attack/adrenaline
	name = "Adrenaline"
	desc = "When regenerating plasma on weeds, regenerate 5% additional plasma and 1% maximum plasma per Spur Chamber. It is doubled if resting."
	status_effect = STATUS_EFFECT_UPGRADE_ADRENALINE

/datum/mutation_upgrade/attack/crush
	name = "Crush"
	desc = "When attacking structures, deal a second instance of damage that is a 1/3 of your melee damage with 15 AP per Spur Chamber."
	status_effect = STATUS_EFFECT_UPGRADE_CRUSH

/datum/mutation_upgrade/utility
	category = MUTATION_CATEGORY_UTILITY
	required_structure = MUTATION_STRUCTURE_VEIL

/datum/mutation_upgrade/utility/focus
	name = "Focus"
	desc = "Deal 1 additional melee damage for every Veil Chamber."
	status_effect = STATUS_EFFECT_UPGRADE_FOCUS

/datum/mutation_upgrade/utility/pheromones
	name = "Pheromones"
	desc = "Allows you to emit a chosen pheromone starting at a power of 1 and an additional 0.25 per Veil Chamber."
	status_effect = STATUS_EFFECT_UPGRADE_PHERO

/datum/mutation_upgrade/utility/camouflage
	name = "Camouflage"
	desc = "Grants various stealth effects based on the amount of Veil Chambers: slient step (1), immunity to tactical sensor detection (2), and stealth that is broken when taking damage & regained when healing (3)."
	status_effect = STATUS_EFFECT_UPGRADE_CAMOUFLAGE
