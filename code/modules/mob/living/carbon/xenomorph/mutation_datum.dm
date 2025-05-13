/datum/mutation_datum
	interaction_flags = INTERACT_UI_INTERACT

/datum/mutation_datum/ui_state(mob/user)
	return GLOB.hive_ui_state // Similar purpose.

/datum/mutation_datum/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MutationSelector", "Mutation Selector")
		ui.open()

/datum/mutation_datum/ui_data(mob/user)
	. = ..()

	var/mob/living/carbon/xenomorph/xeno_user = user
	.["biomass"] = !isnull(SSpoints.xeno_biomass_points_by_hive[xeno_user.hivenumber]) ? SSpoints.xeno_biomass_points_by_hive[xeno_user.hivenumber] : 0

	.["shell_chambers"] = length(xeno_user.hive.shell_chambers)
	.["spur_chambers"] = length(xeno_user.hive.spur_chambers)
	.["veil_chambers"] = length(xeno_user.hive.veil_chambers)

/datum/mutation_datum/ui_static_data(mob/user)
	. = ..()

	var/mob/living/carbon/xenomorph/xeno_user = user
	.["already_has_shell_mutation"] = has_any_mutation_in_category(xeno_user, MUTATION_SHELL)
	.["already_has_spur_mutation"] = has_any_mutation_in_category(xeno_user, MUTATION_SPUR)
	.["already_has_veil_mutation"] = has_any_mutation_in_category(xeno_user, MUTATION_VEIL)

	.["cost"] = get_mutation_cost(xeno_user)
	.["cost_text"] = (get_mutation_cost(xeno_user) > MUTATION_BIOMASS_MAXIMUM || (.["already_has_shell_mutation"] && .["already_has_spur_mutation"] && .["already_has_veil_mutation"])) ? "∞" : .["cost"]
	.["shell_mutations"] = list()
	.["spur_mutations"] = list()
	.["veil_mutations"] = list()

	for(var/datum/mutation_upgrade/mutation AS in xeno_user.xeno_caste.buyable_mutations)
		var/list_name = "veil_mutations"
		if(is_shell_mutation(mutation))
			list_name = "shell_mutations"
		else if(is_spur_mutation(mutation))
			list_name = "spur_mutations"
		.[list_name] += list(list(
			"name" = mutation.name,
			"desc" = mutation.desc,
			"owned" = has_mutation(xeno_user, mutation)
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
/datum/mutation_datum/proc/get_mutation_cost(mob/living/carbon/xenomorph/xeno_target)
	var/expected_cost = MUTATION_BIOMASS_THRESHOLD_T4
	switch(xeno_target.xeno_caste.tier)
		if(XENO_TIER_ONE)
			expected_cost = MUTATION_BIOMASS_THRESHOLD_T1
		if(XENO_TIER_TWO)
			expected_cost = MUTATION_BIOMASS_THRESHOLD_T2
		if(XENO_TIER_THREE)
			expected_cost = MUTATION_BIOMASS_THRESHOLD_T3
	expected_cost += (expected_cost * length(xeno_target.owned_mutations))
	return expected_cost

/// Checks if the xenomorph has a mutation
/datum/mutation_datum/proc/has_mutation(mob/living/carbon/xenomorph/xeno_target, datum/mutation_upgrade/mutation_typepath)
	if(!length(xeno_target.owned_mutations))
		return FALSE
	for(var/datum/mutation_upgrade/owned_mutation AS in xeno_target.owned_mutations)
		if(!istype(owned_mutation, mutation_typepath))
			continue
		return TRUE
	return FALSE

/datum/mutation_datum/proc/has_any_mutation_in_category(mob/living/carbon/xenomorph/xeno_target, mutation_category)
	switch(mutation_category)
		if(MUTATION_SHELL)
			for(var/datum/mutation_upgrade/owned_mutation AS in xeno_target.owned_mutations)
				if(is_shell_mutation(owned_mutation))
					return TRUE
		if(MUTATION_SPUR)
			for(var/datum/mutation_upgrade/owned_mutation AS in xeno_target.owned_mutations)
				if(is_spur_mutation(owned_mutation))
					return TRUE
		if(MUTATION_VEIL)
			for(var/datum/mutation_upgrade/owned_mutation AS in xeno_target.owned_mutations)
				if(is_veil_mutation(owned_mutation))
					return TRUE
	return FALSE

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

	var/datum/mutation_upgrade/found_mutation
	for(var/datum/mutation_upgrade/buyable_mutation AS in xeno_purchaser.xeno_caste.buyable_mutations)
		if(buyable_mutation.name == upgrade_name)
			found_mutation = buyable_mutation
			break

	if(!found_mutation)
		return

	if(has_mutation(xeno_purchaser, found_mutation))
		to_chat(usr, span_warning("You already own this mutation!"))
		return

	switch(found_mutation.required_structure)
		if(MUTATION_SHELL)
			if(!length(xeno_purchaser.hive.shell_chambers))
				to_chat(usr, span_xenonotice("This mutation requires a shell chamber to exist!"))
				return
		if(MUTATION_SPUR)
			if(!length(xeno_purchaser.hive.spur_chambers))
				to_chat(usr, span_xenonotice("This mutation requires a spur chamber to exist!"))
				return
		if(MUTATION_VEIL)
			if(!length(xeno_purchaser.hive.veil_chambers))
				to_chat(usr, span_xenonotice("This mutation requires a veil chamber to exist!"))
				return

	to_chat(xeno_purchaser, span_xenonotice("Mutation gained."))
	xeno_purchaser.do_jitter_animation(500)

	var/datum/mutation_upgrade/new_mutation = new found_mutation(xeno_purchaser)
	xeno_purchaser.owned_mutations += new_mutation
