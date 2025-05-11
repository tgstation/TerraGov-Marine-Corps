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

	// TODO: This needs to be updated as cost changes when a mutation is purchased.
	data["cost"] = get_mutation_cost(xeno_user)

	// TODO: Figure out how mutations will be found, listed, and displayed.
	data["survival_mutations"] = list()
	data["attack_mutations"] = list()
	data["utility_mutations"] = list()

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

/// Returns the cost of purchasing a mutation. Cost based on their caste tier and how many mutations they have so far.
/datum/mutation_datum/proc/get_mutation_cost(mob/living/carbon/xenomorph/xeno_target)
	// Cost is not expected to change as switching castes closes the UI.
	var/expected_cost = MUTATION_BIOMASS_THRESHOLD_T4
	switch(xeno_target.xeno_caste.tier)
		if(XENO_TIER_ONE)
			expected_cost = MUTATION_BIOMASS_THRESHOLD_T1
		if(XENO_TIER_TWO)
			expected_cost = MUTATION_BIOMASS_THRESHOLD_T2
		if(XENO_TIER_THREE)
			expected_cost = MUTATION_BIOMASS_THRESHOLD_T3

	// TODO: Get mutation count here and then `expected_cost` multiply by `(1 + #)`!
	return expected_cost

/// Tries to purchase a mutation. Denies if possible. Otherwise, removes conflicting mutations and gives the purchased mutation.
/datum/mutation_datum/proc/try_purchase_mutation(mob/living/carbon/xenomorph/xeno_purchaser, upgrade_name)
	if(!xeno_purchaser.hive || !upgrade_name)
		return
	if((xeno_purchaser.xeno_caste.caste_flags & CASTE_NO_MUTATION))
		return

	var/upgrade_price = get_mutation_cost(xeno_purchaser)
	var/current_biomass = !isnull(SSpoints.xeno_biomass_points_by_hive[xeno_purchaser.hivenumber]) ? SSpoints.xeno_biomass_points_by_hive[xeno_purchaser.hivenumber] : 0
	if(current_biomass < upgrade_price)
		to_chat(usr, span_warning("The hive does not have enough biomass!"))
		return

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

/datum/mutation_upgrade/shell
	category = MUTATION_STRUCTURE_SHELL
	required_structure = MUTATION_STRUCTURE_SHELL

/datum/mutation_upgrade/spur
	category = MUTATION_STRUCTURE_SPUR
	required_structure = MUTATION_STRUCTURE_SPUR

/datum/mutation_upgrade/veil
	category = MUTATION_STRUCTURE_VEIL
	required_structure = MUTATION_STRUCTURE_VEIL
