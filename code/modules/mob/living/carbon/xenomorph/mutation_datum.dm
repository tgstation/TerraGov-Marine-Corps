/datum/mutation_datum
	interaction_flags = INTERACT_UI_INTERACT

/datum/mutation_datum/ui_state(mob/user)
	return GLOB.hive_ui_state

/datum/mutation_datum/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MutationSelector", "Mutation Selector")
		ui.open()

/datum/mutation_datum/ui_data(mob/user)
	. = ..()

	var/mob/living/carbon/xenomorph/xenomorph_user = user
	.["biomass"] = !isnull(SSpoints.xeno_biomass_points_by_hive[xenomorph_user.hivenumber]) ? SSpoints.xeno_biomass_points_by_hive[xenomorph_user.hivenumber] : 0

	.["shell_chambers"] = length(xenomorph_user.hive.shell_chambers)
	.["spur_chambers"] = length(xenomorph_user.hive.spur_chambers)
	.["veil_chambers"] = length(xenomorph_user.hive.veil_chambers)

/datum/mutation_datum/ui_static_data(mob/user)
	. = ..()

	var/mob/living/carbon/xenomorph/xenomorph_user = user
	.["already_has_shell_mutation"] = has_any_mutation_in_category(xenomorph_user, MUTATION_SHELL)
	.["already_has_spur_mutation"] = has_any_mutation_in_category(xenomorph_user, MUTATION_SPUR)
	.["already_has_veil_mutation"] = has_any_mutation_in_category(xenomorph_user, MUTATION_VEIL)

	.["cost"] = get_mutation_cost(xenomorph_user)
	.["cost_text"] = (get_mutation_cost(xenomorph_user) > MUTATION_BIOMASS_MAXIMUM || (.["already_has_shell_mutation"] && .["already_has_spur_mutation"] && .["already_has_veil_mutation"])) ? "∞" : .["cost"]
	.["shell_mutations"] = list()
	.["spur_mutations"] = list()
	.["veil_mutations"] = list()

	for(var/datum/mutation_upgrade/mutation AS in xenomorph_user.xeno_caste.buyable_mutations)
		var/list_name = "veil_mutations"
		if(is_shell_mutation(mutation))
			list_name = "shell_mutations"
		else if(is_spur_mutation(mutation))
			list_name = "spur_mutations"
		.[list_name] += list(list(
			"name" = mutation.name,
			"desc" = mutation.desc,
			"owned" = has_mutation(xenomorph_user, mutation)
		))

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
/datum/mutation_datum/proc/get_mutation_cost(mob/living/carbon/xenomorph/xenomorph_target)
	var/expected_cost = MUTATION_BIOMASS_THRESHOLD_T4
	switch(xenomorph_target.xeno_caste.tier)
		if(XENO_TIER_ONE)
			expected_cost = MUTATION_BIOMASS_THRESHOLD_T1
		if(XENO_TIER_TWO)
			expected_cost = MUTATION_BIOMASS_THRESHOLD_T2
		if(XENO_TIER_THREE)
			expected_cost = MUTATION_BIOMASS_THRESHOLD_T3
	expected_cost += (expected_cost * length(xenomorph_target.owned_mutations))
	return expected_cost

/// Returns TRUE if the xenomorph has a mutation based on a typepath.
/datum/mutation_datum/proc/has_mutation(mob/living/carbon/xenomorph/xenomorph_target, datum/mutation_upgrade/mutation_typepath)
	if(!length(xenomorph_target.owned_mutations))
		return FALSE
	for(var/datum/mutation_upgrade/owned_mutation AS in xenomorph_target.owned_mutations)
		if(!istype(owned_mutation, mutation_typepath))
			continue
		return TRUE
	return FALSE

/// Returns TRUE if the xenomorph has a mutation in a certain category.
/datum/mutation_datum/proc/has_any_mutation_in_category(mob/living/carbon/xenomorph/xenomorph_target, mutation_category)
	switch(mutation_category)
		if(MUTATION_SHELL)
			for(var/datum/mutation_upgrade/owned_mutation AS in xenomorph_target.owned_mutations)
				if(is_shell_mutation(owned_mutation))
					return TRUE
		if(MUTATION_SPUR)
			for(var/datum/mutation_upgrade/owned_mutation AS in xenomorph_target.owned_mutations)
				if(is_spur_mutation(owned_mutation))
					return TRUE
		if(MUTATION_VEIL)
			for(var/datum/mutation_upgrade/owned_mutation AS in xenomorph_target.owned_mutations)
				if(is_veil_mutation(owned_mutation))
					return TRUE
	return FALSE

/// Returns TRUE if the mutation was successfully purchased.
/datum/mutation_datum/proc/try_purchase_mutation(mob/living/carbon/xenomorph/xenomorph_purchaser, upgrade_name)
	if(!xenomorph_purchaser.hive || !upgrade_name)
		return FALSE
	if((xenomorph_purchaser.xeno_caste.caste_flags & CASTE_NO_MUTATION))
		return FALSE
	if(xenomorph_purchaser.fortify)
		to_chat(usr, span_warning("You cannot buy mutations while fortified!"))
		return FALSE

	var/upgrade_price = get_mutation_cost(xenomorph_purchaser)
	var/current_biomass = !isnull(SSpoints.xeno_biomass_points_by_hive[xenomorph_purchaser.hivenumber]) ? SSpoints.xeno_biomass_points_by_hive[xenomorph_purchaser.hivenumber] : 0
	if(current_biomass < upgrade_price)
		to_chat(usr, span_warning("The hive does not have enough biomass!"))
		return FALSE

	var/datum/mutation_upgrade/found_mutation
	for(var/datum/mutation_upgrade/buyable_mutation AS in xenomorph_purchaser.xeno_caste.buyable_mutations)
		if(buyable_mutation.name == upgrade_name)
			found_mutation = buyable_mutation
			break

	if(!found_mutation)
		return FALSE
	if(has_mutation(xenomorph_purchaser, found_mutation))
		to_chat(usr, span_warning("You already own this mutation!"))
		return FALSE
	if(has_any_mutation_in_category(xenomorph_purchaser, found_mutation.category))
		to_chat(usr, span_warning("You already have a mutation in this category!"))
		return FALSE
	for(var/datum/mutation_upgrade/owned_mutation AS in xenomorph_purchaser.owned_mutations)
		if(!is_type_in_list(owned_mutation, found_mutation.conflicting_mutation_types))
			continue
		to_chat(usr, span_warning("That mutation is not compatible with the mutation: [owned_mutation.name]"))
		return FALSE

	switch(found_mutation.required_structure)
		if(MUTATION_SHELL)
			if(!length(xenomorph_purchaser.hive.shell_chambers))
				to_chat(usr, span_xenonotice("This mutation requires a shell chamber to exist!"))
				return FALSE
		if(MUTATION_SPUR)
			if(!length(xenomorph_purchaser.hive.spur_chambers))
				to_chat(usr, span_xenonotice("This mutation requires a spur chamber to exist!"))
				return FALSE
		if(MUTATION_VEIL)
			if(!length(xenomorph_purchaser.hive.veil_chambers))
				to_chat(usr, span_xenonotice("This mutation requires a veil chamber to exist!"))
				return FALSE

	to_chat(xenomorph_purchaser, span_xenonotice("Mutation gained."))
	xenomorph_purchaser.do_jitter_animation(500)
	new found_mutation(xenomorph_purchaser) // Everything else in handled during the mutation's New().
	return TRUE
