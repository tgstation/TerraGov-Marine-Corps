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
	.["cost"] = get_mutation_cost(xeno_user)
	.["cost_text"] = get_mutation_cost(xeno_user) < MUTATION_BIOMASS_MAXIMUM ? .["cost"] : "∞"
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
			"owned" = locate(mutation) in xeno_user.owned_mutations
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
	// Cost is not expected to change as switching castes closes the UI.
	var/expected_cost = MUTATION_BIOMASS_THRESHOLD_T4
	switch(xeno_target.xeno_caste.tier)
		if(XENO_TIER_ONE)
			expected_cost = MUTATION_BIOMASS_THRESHOLD_T1
		if(XENO_TIER_TWO)
			expected_cost = MUTATION_BIOMASS_THRESHOLD_T2
		if(XENO_TIER_THREE)
			expected_cost = MUTATION_BIOMASS_THRESHOLD_T3

	expected_cost += (expected_cost * xeno_target.owned_mutations)
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

	var/datum/mutation_upgrade/found_mutation
	for(var/datum/mutation_upgrade/buyable_mutation AS in xeno_purchaser.xeno_caste.buyable_mutations)
		if(buyable_mutation.name == upgrade_name)
			found_mutation = buyable_mutation
			break

	if(!found_mutation)
		return

	switch(found_mutation.required_structure)
		if(MUTATION_STRUCTURE_SHELL)
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

	to_chat(xeno_purchaser, span_xenonotice("Mutation gained."))
	xeno_purchaser.do_jitter_animation(500)

	var/datum/mutation_upgrade/new_mutation = new found_mutation(xeno_purchaser)
	xeno_purchaser.owned_mutations += new_mutation
	new_mutation.on_gain()

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
	/// The xenomorph owner of this mutation upgrade.
	var/mob/living/carbon/xenomorph/xenomorph_owner

/datum/mutation_upgrade/New(mob/living/carbon/xenomorph/new_xeno_owner)
	xenomorph_owner = new_xeno_owner

/datum/mutation_upgrade/proc/on_gain()
	SHOULD_CALL_PARENT(TRUE)

	xenomorph_owner.apply_status_effect(status_effect)
	switch(required_structure)
		if(MUTATION_STRUCTURE_SHELL)
			RegisterSignal(SSdcs, COMSIG_MUTATION_CHAMBER_SHELL, PROC_REF(on_building_update))
		if(MUTATION_STRUCTURE_SPUR)
			RegisterSignal(SSdcs, COMSIG_MUTATION_CHAMBER_SPUR, PROC_REF(on_building_update))
		if(MUTATION_STRUCTURE_VEIL)
			RegisterSignal(SSdcs, COMSIG_MUTATION_CHAMBER_VEIL, PROC_REF(on_building_update))
	on_building_update(0, get_total_buildings())

/datum/mutation_upgrade/proc/on_lose()
	SHOULD_CALL_PARENT(TRUE)

	xenomorph_owner.remove_status_effect(status_effect)
	switch(required_structure)
		if(MUTATION_STRUCTURE_SHELL)
			UnregisterSignal(SSdcs, COMSIG_MUTATION_CHAMBER_SHELL)
		if(MUTATION_STRUCTURE_SPUR)
			UnregisterSignal(SSdcs, COMSIG_MUTATION_CHAMBER_SPUR)
		if(MUTATION_STRUCTURE_VEIL)
			UnregisterSignal(SSdcs, COMSIG_MUTATION_CHAMBER_VEIL)
	on_building_update(get_total_buildings(), 0)

/datum/mutation_upgrade/proc/on_building_update(previous_amount, new_amount)
	return

/datum/mutation_upgrade/proc/get_total_buildings()
	if(!xenomorph_owner || !required_structure)
		return 0
	switch(required_structure)
		if(MUTATION_STRUCTURE_SHELL)
			return length(xenomorph_owner.hive.shell_chambers)
		if(MUTATION_STRUCTURE_SPUR)
			return length(xenomorph_owner.hive.spur_chambers)
		if(MUTATION_STRUCTURE_VEIL)
			return length(xenomorph_owner.hive.veil_chambers)

/**
 * Shell Mutations
 */
/datum/mutation_upgrade/shell
	category = MUTATION_CATEGORY_SHELL
	required_structure = MUTATION_STRUCTURE_SHELL
	status_effect = /datum/status_effect/mutation_shell_upgrade

// Defender
/datum/mutation_upgrade/shell/carapace_waxing
	name = "Carapace Waxing"
	desc = "Regenerate Skin additionally reduces various debuffs by 1/2/3 stacks or 2/4/6 seconds."

/datum/mutation_upgrade/shell/carapace_waxing/on_building_update(previous_amount, new_amount)
	..()
	var/datum/action/ability/xeno_action/regenerate_skin/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/regenerate_skin]
	if(!ability)
		return
	ability.debuff_amount_to_remove += (new_amount - previous_amount)

/**
 * Spur
 */
/datum/mutation_upgrade/spur
	category = MUTATION_CATEGORY_SPUR
	required_structure = MUTATION_STRUCTURE_SPUR
	status_effect = /datum/status_effect/mutation_spur_upgrade

/datum/mutation_upgrade/spur/on_gain()
	RegisterSignal(SSdcs, COMSIG_MUTATION_CHAMBER_SPUR, PROC_REF(on_building_update))
	..()

/datum/mutation_upgrade/spur/on_lose()
	UnregisterSignal(SSdcs, COMSIG_MUTATION_CHAMBER_SPUR)
	..()

// Defender
/datum/mutation_upgrade/spur/sharpening_claws
	name = "Sharpening Claws"
	desc = "For every 10% missing armor, you gain 2/3/4 armor piercing for your slash attacks."

/datum/mutation_upgrade/spur/sharpening_claws/on_gain()
	..()

/datum/mutation_upgrade/spur/sharpening_claws/on_lose()
	..()

/**
 * Veil
 */
/datum/mutation_upgrade/veil
	category = MUTATION_CATEGORY_VEIL
	required_structure = MUTATION_STRUCTURE_VEIL
	status_effect = /datum/status_effect/mutation_veil_upgrade

/datum/mutation_upgrade/veil/on_gain()
	RegisterSignal(SSdcs, COMSIG_MUTATION_CHAMBER_VEIL, PROC_REF(on_building_update))
	..()

/datum/mutation_upgrade/veil/on_lose()
	UnregisterSignal(SSdcs, COMSIG_MUTATION_CHAMBER_VEIL)
	..()

/datum/mutation_upgrade/veil/slow_and_steady
	name = "Slow and Steady"
	desc = "While Fortify is active, you can move at 10/20/30% of your movement speed."

/datum/mutation_upgrade/veil/slow_and_steady/on_gain()
	..()

/datum/mutation_upgrade/veil/slow_and_steady/on_lose()
	..()
