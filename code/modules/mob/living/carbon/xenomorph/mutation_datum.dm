/datum/mutation_datum
	interaction_flags = INTERACT_UI_INTERACT
	/// A list of disk colors that have been fully printed.
	var/list/completed_disk_colors = list()

/datum/mutation_datum/New()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_DISK_GENERATED, PROC_REF(on_disk_printed))

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
	.["shell_chambers"] = length(xenomorph_user.hive.shell_chambers)
	.["spur_chambers"] = length(xenomorph_user.hive.spur_chambers)
	.["veil_chambers"] = length(xenomorph_user.hive.veil_chambers)
	.["disks_completed"] = HAS_TRAIT(xenomorph_user, TRAIT_VALHALLA_XENO) ? 3 : length(completed_disk_colors)

/datum/mutation_datum/ui_static_data(mob/user)
	. = ..()

	var/mob/living/carbon/xenomorph/xenomorph_user = user
	.["shell_mutations"] = list()
	.["spur_mutations"] = list()
	.["veil_mutations"] = list()
	.["already_has_shell"] = has_any_mutation_in_category(xenomorph_user, MUTATION_SHELL)
	.["already_has_spur"] = has_any_mutation_in_category(xenomorph_user, MUTATION_SPUR)
	.["already_has_veil"] = has_any_mutation_in_category(xenomorph_user, MUTATION_VEIL)
	for(var/datum/mutation_upgrade/mutation AS in xenomorph_user.xeno_caste.mutations)
		var/list_name = "veil_mutations"
		if(is_shell_mutation(mutation))
			list_name = "shell_mutations"
		else if(is_spur_mutation(mutation))
			list_name = "spur_mutations"
		.[list_name] += list(list(
			"name" = mutation.name,
			"type" = mutation.type,
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
			try_purchase_mutation(usr, text2path(params["upgrade_type"]))

	SStgui.close_user_uis(usr, src)

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
	if(!length(xenomorph_target.owned_mutations))
		return FALSE
	for(var/datum/mutation_upgrade/owned_mutation AS in xenomorph_target.owned_mutations)
		switch(mutation_category)
			if(MUTATION_SHELL)
				if(is_shell_mutation(owned_mutation))
					return TRUE
			if(MUTATION_SPUR)
				if(is_spur_mutation(owned_mutation))
					return TRUE
			if(MUTATION_VEIL)
				if(is_veil_mutation(owned_mutation))
					return TRUE
	return FALSE

/// Tries to purchase a mutation based on its typepath. Returns TRUE if the mutation was successfully purchased.
/datum/mutation_datum/proc/try_purchase_mutation(mob/living/carbon/xenomorph/xenomorph_purchaser, datum/mutation_upgrade/mutation_typepath)
	if(!xenomorph_purchaser.hive || !mutation_typepath)
		return FALSE
	if(!(SSticker.mode?.round_type_flags & MODE_MUTATIONS_OBTAINABLE) && !HAS_TRAIT(xenomorph_purchaser, TRAIT_VALHALLA_XENO))
		return FALSE
	if(!(xenomorph_purchaser.xeno_caste.caste_flags & CASTE_MUTATIONS_ALLOWED))
		return FALSE
	if(!(mutation_typepath in xenomorph_purchaser.xeno_caste.mutations))
		to_chat(xenomorph_purchaser, span_warning("That is not a valid mutation."))
		return FALSE
	if(xenomorph_purchaser.fortify)
		to_chat(xenomorph_purchaser, span_warning("You cannot buy mutations while fortified!"))
		return FALSE
	if(!HAS_TRAIT(xenomorph_purchaser, TRAIT_VALHALLA_XENO) && length(xenomorph_purchaser.owned_mutations) >= length(completed_disk_colors)) // Checking if buying another would put us over the completed disk count.
		to_chat(xenomorph_purchaser, span_warning("The hive hasn't developed enough to get another mutation..."))
		return FALSE
	if(has_mutation(xenomorph_purchaser, mutation_typepath))
		to_chat(xenomorph_purchaser, span_warning("You already own this mutation!"))
		return FALSE
	if(has_any_mutation_in_category(xenomorph_purchaser, mutation_typepath.category))
		to_chat(xenomorph_purchaser, span_warning("You already have a mutation in this category!"))
		return FALSE
	if(!xenomorph_purchaser.hive.has_any_mutation_structures_in_category(mutation_typepath.required_structure))
		to_chat(xenomorph_purchaser, span_warning("This mutation requires a [mutation_typepath.required_structure] chamber to exist!"))
		return FALSE
	for(var/datum/mutation_upgrade/owned_mutation AS in xenomorph_purchaser.owned_mutations)
		if(!(mutation_typepath in owned_mutation.conflicting_mutation_types))
			continue
		to_chat(xenomorph_purchaser, span_warning("That mutation is not compatible with the mutation: [owned_mutation.name]"))
		return FALSE
	to_chat(xenomorph_purchaser, span_xenonotice("Mutation gained."))
	xenomorph_purchaser.do_jitter_animation(500)
	new mutation_typepath(xenomorph_purchaser) // Everything else in handled during the mutation's New().
	return TRUE

/// Called when a disk is printed.
/datum/mutation_datum/proc/on_disk_printed(datum/source, obj/machinery/computer/nuke_disk_generator/printing_computer)
	SIGNAL_HANDLER
	var/disk_color = printing_computer.disk_color
	if(!disk_color || (disk_color in completed_disk_colors))
		return
	completed_disk_colors += disk_color
