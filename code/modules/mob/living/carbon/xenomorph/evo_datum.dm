//! TODO: this needs a refactor/UI rewor at some point, we've probably bolted too much onto this over time

/// Empty datum parent for use as evolution panel entrance.
/datum/evolution_panel
	// Empty

/// Controls the evolution UI
/datum/evolution_panel/ui_interact(mob/user, datum/tgui/ui)
	// Xeno only screen
	if(!isxeno(user))
		return

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "HiveEvolveScreen")
		ui.open()

/// Checks for xeno access and prevents unconscious / dead xenos from interacting.
/datum/evolution_panel/ui_state(mob/user)
	return GLOB.xeno_state

/// Static data provided once when the ui is opened
/datum/evolution_panel/ui_static_data(mob/living/carbon/xenomorph/xeno)
	. = list()
	.["name"] = xeno.xeno_caste.display_name
	.["abilities"] = list()
	for(var/ability in xeno.xeno_caste.actions)
		var/datum/action/ability/xeno_action/xeno_ability = ability
		if(SSticker.mode && !(SSticker.mode.xeno_abilities_flags & initial(xeno_ability.gamemode_flags)))
			continue
		.["abilities"]["[ability]"] = list(
			"name" = initial(xeno_ability.name),
			"desc" = initial(xeno_ability.desc),
			"cost" = initial(xeno_ability.ability_cost),
			"cooldown" = (initial(xeno_ability.cooldown_duration) / 10)
		)
	.["evolves_to"] = list()
	for(var/evolves_into in xeno.get_evolution_options())
		var/datum/xeno_caste/caste = GLOB.xeno_caste_datums[evolves_into][XENO_UPGRADE_BASETYPE]
		var/list/caste_data = list(
			"type_path" = caste.type,
			"name" = caste.display_name,
			"abilities" = list(),
			"instant_evolve" = (caste.caste_flags & CASTE_INSTANT_EVOLUTION || (HAS_TRAIT(xeno, TRAIT_STRAIN_SWAP) || HAS_TRAIT(xeno, TRAIT_CASTE_SWAP) || HAS_TRAIT(xeno, TRAIT_REGRESSING))),
		)
		for(var/ability in caste.actions)
			var/datum/action/ability/xeno_action/xeno_ability = ability
			if(SSticker.mode && !(SSticker.mode.xeno_abilities_flags & initial(xeno_ability.gamemode_flags)))
				continue
			caste_data["abilities"]["[ability]"] = list(
				"name" = initial(xeno_ability.name),
				"desc" = initial(xeno_ability.desc),
				"cost" = initial(xeno_ability.ability_cost),
				"cooldown" = (initial(xeno_ability.cooldown_duration) / 10)
			)
		.["evolves_to"]["[caste.caste_type_path]"] = caste_data

/// Some data to update the UI with the current evolution status
/datum/evolution_panel/ui_data(mob/living/carbon/xenomorph/xeno)
	var/list/data = list()

	if(iscrashgamemode(SSticker.mode))
		var/datum/game_mode/infestation/crash/crash_mode = SSticker.mode
		data["bypass_evolution_checks"] = !crash_mode.shuttle_landed
	else
		data["bypass_evolution_checks"] = (SSticker.mode?.round_type_flags & MODE_ALLOW_XENO_QUICKBUILD) && SSresinshaping.active

	data["can_evolve"] = \
		!xeno.is_ventcrawling && \
		!xeno.incapacitated(TRUE) && \
		xeno.health >= xeno.maxHealth && \
		xeno.plasma_stored >= (xeno.xeno_caste.plasma_max * xeno.xeno_caste.plasma_regen_limit)

	data["evolution"] = list(
		"current" = xeno.evolution_stored,
		"max" = xeno.xeno_caste.evolution_threshold
	)

	return data

/// Handles actuually evolving
/datum/evolution_panel/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	var/mob/living/carbon/xenomorph/xeno = usr
	switch(action)
		if("evolve")
			var/newpath = text2path(params["path"])
			if(!newpath)
				return
			var/datum/xeno_caste/caste = GLOB.xeno_caste_datums[newpath][XENO_UPGRADE_BASETYPE]
			if(!caste)
				return
			xeno.do_evolve(caste.type, (HAS_TRAIT(xeno, TRAIT_CASTE_SWAP) || HAS_TRAIT(xeno, TRAIT_REGRESSING)|| HAS_TRAIT(xeno, TRAIT_STRAIN_SWAP))) // All the checks for can or can't are handled inside do_evolve
			return TRUE

/datum/evolution_panel/ui_close(mob/user)
	. = ..()
	REMOVE_TRAIT(user, TRAIT_CASTE_SWAP, TRAIT_CASTE_SWAP)
	REMOVE_TRAIT(user, TRAIT_REGRESSING, TRAIT_REGRESSING)
	REMOVE_TRAIT(user, TRAIT_STRAIN_SWAP, TRAIT_STRAIN_SWAP)
