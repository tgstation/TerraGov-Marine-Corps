// ***************************************
// *********** Universal abilities
// ***************************************
// Resting
/datum/action/ability/xeno_action/xeno_resting
	name = "Rest"
	action_icon_state = "resting"
	desc = "Rest on weeds to regenerate health and plasma."
	use_state_flags = ABILITY_USE_LYING|ABILITY_USE_CRESTED|ABILITY_USE_SOLIDOBJECT|ABILITY_USE_STAGGERED
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_REST,
	)

/datum/action/ability/xeno_action/xeno_resting/action_activate()
	var/mob/living/carbon/xenomorph/X = owner
	if(!istype(X))
		return
	X.toggle_resting()
	return succeed_activate()

// ***************************************
// *********** Drone-y abilities
// ***************************************
/datum/action/ability/activable/xeno/plant_weeds
	name = "Plant Weeds"
	action_icon_state = "plant_weeds"
	action_icon = 'icons/Xeno/actions/construction.dmi'
	ability_cost = 75
	desc = "Plant a weed node on your tile."
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_DROP_WEEDS,
		KEYBINDING_ALTERNATE = COMSIG_XENOABILITY_CHOOSE_WEEDS,
	)
	use_state_flags = ABILITY_USE_LYING
	/// The multiplier of ability cost. This is seperate of the weed type's ability cost multiplier.
	var/cost_multiplier = 1
	/// How far can weeds be placed? 0: On use, plants on your tile. 1+: On use, select the ability and right-click to plant at target tile.
	var/max_range = 0
	/// List of weeds that can be selected.
	var/list/obj/alien/weeds/node/selectable_weed_typepaths = list(
		/obj/alien/weeds/node,
		/obj/alien/weeds/node/sticky,
		/obj/alien/weeds/node/resting
	)
	/// The selected type of weeds that will be planted.
	var/obj/alien/weeds/node/weed_type = /obj/alien/weeds/node
	/// Whether automatic weeding is active.
	var/auto_weeding = FALSE
	/// The turf that was last weeded. Used for auto weeding.
	var/turf/last_weeded_turf

/datum/action/ability/activable/xeno/plant_weeds/New(Target)
	. = ..()
	if(SSmonitor.gamestate == SHUTTERS_CLOSED)
		RegisterSignals(SSdcs, list(COMSIG_GLOB_GAMESTATE_GROUNDSIDE), PROC_REF(update_ability_cost))
		update_ability_cost()

/// Updates the ability cost.
/datum/action/ability/activable/xeno/plant_weeds/proc/update_ability_cost(datum/source)
	SIGNAL_HANDLER
	ability_cost = initial(ability_cost) * cost_multiplier * weed_type.ability_cost_mult * (SSmonitor.gamestate == SHUTTERS_CLOSED ? 0.5 : 1)
	update_button_icon()

/datum/action/ability/activable/xeno/plant_weeds/action_activate()
	if(max_range)
		return ..()
	if(can_use_action())
		plant_weeds(owner)

/datum/action/ability/activable/xeno/plant_weeds/use_ability(atom/A)
	plant_weeds(max_range ? A : get_turf(owner))

/// Plant a weeds node on the selected atom.
/datum/action/ability/activable/xeno/plant_weeds/proc/plant_weeds(atom/A)
	var/turf/T = get_turf(A)

	if(!T.check_alien_construction(owner, FALSE, weed_type))
		return fail_activate()

	if(locate(/obj/structure/xeno/trap) in T)
		to_chat(owner, span_warning("There is a resin trap in the way!"))
		return fail_activate()

	if(!T.is_weedable())
		to_chat(owner, span_warning("Bad place for a garden!"))
		return fail_activate()

	if(locate(weed_type) in T)
		to_chat(owner, span_warning("There's a pod here already!"))
		return fail_activate()

	owner.visible_message(span_xenonotice("\The [owner] regurgitates a pulsating node and plants it on the ground!"), \
		span_xenonotice("We regurgitate a pulsating node and plant it on the ground!"), null, 5)
	new weed_type(T)
	last_weeded_turf = T
	playsound(T, SFX_ALIEN_RESIN_BUILD, 25)
	GLOB.round_statistics.weeds_planted++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "weeds_planted")
	if(owner.client)
		var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[owner.ckey]
		personal_statistics.weeds_planted++
	add_cooldown()
	succeed_activate()

/datum/action/ability/activable/xeno/plant_weeds/alternate_action_activate()
	INVOKE_ASYNC(src, PROC_REF(choose_weed))
	return COMSIG_KB_ACTIVATED

/// Choose which weed will be planted by the xeno owner or toggle automatic weeding.
/datum/action/ability/activable/xeno/plant_weeds/proc/choose_weed()
	var/list/available_weeds = list()
	for(var/obj/alien/weeds/node/weed_type_possible AS in selectable_weed_typepaths)
		var/weed_image = GLOB.weed_images_list[initial(weed_type_possible.name)]
		if(!weed_image)
			continue
		available_weeds[initial(weed_type_possible.name)] = weed_image
	available_weeds[AUTOMATIC_WEEDING] = GLOB.weed_images_list[AUTOMATIC_WEEDING] // For automatic weeding.

	var/weed_choice = show_radial_menu(xeno_owner, xeno_owner, available_weeds, radius = 48)
	if(!weed_choice)
		return

	if(weed_choice == AUTOMATIC_WEEDING)
		toggle_auto_weeding()
	else
		for(var/obj/alien/weeds/node/weed_type_possible AS in GLOB.weed_type_list)
			if(initial(weed_type_possible.name) == weed_choice)
				weed_type = weed_type_possible
				update_ability_cost()
				break
		to_chat(owner, span_xenonotice("We will now spawn <b>[weed_choice]\s</b> when using the plant weeds ability."))
	update_button_icon()

///Toggles automatic weeding
/datum/action/ability/activable/xeno/plant_weeds/proc/toggle_auto_weeding()
	SIGNAL_HANDLER
	if(auto_weeding)
		UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)
		UnregisterSignal(owner, COMSIG_MOB_DEATH)
		auto_weeding = FALSE
		to_chat(owner, span_xenonotice("We will no longer automatically plant weeds."))
		return
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(weed_on_move))
	RegisterSignal(owner, COMSIG_MOB_DEATH, PROC_REF(toggle_auto_weeding))
	auto_weeding = TRUE
	to_chat(owner, span_xenonotice("We will now automatically plant weeds."))

///Used for performing automatic weeding
/datum/action/ability/activable/xeno/plant_weeds/proc/weed_on_move(datum/source)
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	if(xeno_owner.loc_weeds_type)
		return
	if(get_dist(owner, last_weeded_turf) < AUTO_WEEDING_MIN_DIST)
		return
	if(!can_use_ability(xeno_owner.loc, TRUE, ABILITY_IGNORE_SELECTED_ABILITY))
		return
	plant_weeds(owner)

/datum/action/ability/activable/xeno/plant_weeds/update_button_icon()
	name = "Plant Weeds ([ability_cost])"
	action_icon_state = initial(weed_type.name)
	if(auto_weeding)
		if(!visual_references[VREF_IMAGE_ONTOP])
			// below maptext , above selected frames
			visual_references[VREF_IMAGE_ONTOP] = image('icons/Xeno/actions/construction.dmi', icon_state = "repeating", layer = ACTION_LAYER_IMAGE_ONTOP)
			button.add_overlay(visual_references[VREF_IMAGE_ONTOP])
	else if(visual_references[VREF_IMAGE_ONTOP])
		button.cut_overlay(visual_references[VREF_IMAGE_ONTOP])
		visual_references[VREF_IMAGE_ONTOP] = null
	return ..()

//AI stuff
/datum/action/ability/activable/xeno/plant_weeds/ai_should_start_consider()
	return TRUE

/datum/action/ability/activable/xeno/plant_weeds/ai_should_use(target)
	if(!can_use_action(override_flags = ABILITY_IGNORE_SELECTED_ABILITY))
		return FALSE
	var/mob/living/carbon/xenomorph/owner_xeno = owner
	if(owner_xeno.loc_weeds_type)
		return FALSE
	return TRUE

/datum/action/ability/activable/xeno/plant_weeds/ranged
	max_range = 4

/datum/action/ability/activable/xeno/plant_weeds/ranged/can_use_ability(atom/A, silent = FALSE, override_flags)
	var/area/area = get_area(A)
	if(area.area_flags & MARINE_BASE)
		if(!silent)
			to_chat(owner, span_xenowarning("You cannot weed here!"))
		return FALSE
	if(!line_of_sight(owner, get_turf(A)))
		to_chat(owner, span_warning("You cannot plant weeds without line of sight!"))
		return FALSE
	return ..()

/datum/action/ability/activable/xeno/plant_weeds/ranged/can_use_action(silent, override_flags, selecting)
	if (owner?.status_flags & INCORPOREAL)
		return FALSE
	return ..()

// Secrete Resin
/datum/action/ability/activable/xeno/secrete_resin
	name = "Secrete Resin"
	action_icon_state = RESIN_WALL
	action_icon = 'icons/Xeno/actions/construction.dmi'
	desc = "Builds whatever resin you selected"
	target_flags = ABILITY_TURF_TARGET
	ability_cost = 75
	action_type = ACTION_TOGGLE
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_SECRETE_RESIN,
	)
	///Minimum time to build a resin structure
	var/base_wait = 1 SECONDS
	///Multiplicator factor to add to the building time, depends on the health of the structure built
	var/scaling_wait = 1 SECONDS
	///List of buildable structures. Order corresponds with resin_images_list.
	var/list/buildable_structures = list(
		/turf/closed/wall/resin/regenerating,
		/turf/closed/wall/resin/regenerating/special/bulletproof,
		/turf/closed/wall/resin/regenerating/special/fireproof,
		/turf/closed/wall/resin/regenerating/special/hardy,
		/obj/alien/resin/sticky,
		/obj/structure/mineral_door/resin,
		)
	/// Used for the dragging functionality of pre-shuttter building
	var/dragging = FALSE
	/// The percentage of maximum health to heal the owner whenever a structure is built.
	var/heal_percentage = 0

/// Helper for handling the start of mouse-down and to begin the drag-building
/datum/action/ability/activable/xeno/secrete_resin/proc/start_resin_drag(mob/user, atom/object, turf/location, control, params)
	SIGNAL_HANDLER

	var/list/modifiers = params2list(params)
	if(toggled && !(modifiers[BUTTON] == LEFT_CLICK))
		dragging = TRUE
		INVOKE_ASYNC(src, PROC_REF(qb_build_resin), get_turf(object))

/// Helper for ending drag-building , activated on mose-up
/datum/action/ability/activable/xeno/secrete_resin/proc/stop_resin_drag()
	SIGNAL_HANDLER
	dragging = FALSE

/// Handles removing the dragging functionality from the action all-togheter on round-start (shutter open)
/datum/action/ability/activable/xeno/secrete_resin/proc/end_resin_drag()
	SIGNAL_HANDLER
	dragging = FALSE
	UnregisterSignal(owner, list(COMSIG_MOB_MOUSEDRAG, COMSIG_MOB_MOUSEUP, COMSIG_MOB_MOUSEDOWN))
	UnregisterSignal(SSdcs, list(COMSIG_GLOB_OPEN_SHUTTERS_EARLY, COMSIG_GLOB_OPEN_TIMED_SHUTTERS_LATE,COMSIG_GLOB_TADPOLE_LANDED_OUT_LZ,COMSIG_GLOB_TADPOLE_RAPPEL_DEPLOYED_OUT_LZ,COMSIG_GLOB_DROPPOD_LANDED))

/// Extra handling for adding the action for draggin functionality (for instant building)
/datum/action/ability/activable/xeno/secrete_resin/give_action(mob/living/L)
	. = ..()
	if(!CHECK_BITFIELD(SSticker.mode?.round_type_flags, MODE_ALLOW_XENO_QUICKBUILD) || !SSresinshaping.active)
		return

	var/mutable_appearance/build_maptext = mutable_appearance(icon = null,icon_state = null, layer = ACTION_LAYER_MAPTEXT)
	build_maptext.pixel_x = 12
	build_maptext.pixel_y = -5
	build_maptext.maptext = MAPTEXT(SSresinshaping.quickbuild_points_by_hive[owner.get_xeno_hivenumber()])
	visual_references[VREF_MUTABLE_BUILDING_COUNTER] = build_maptext

	RegisterSignal(owner, COMSIG_MOB_MOUSEDOWN, PROC_REF(start_resin_drag))
	RegisterSignal(owner, COMSIG_MOB_MOUSEDRAG, PROC_REF(preshutter_resin_drag))
	RegisterSignal(owner, COMSIG_MOB_MOUSEUP, PROC_REF(stop_resin_drag))
	RegisterSignals(SSdcs, list(COMSIG_GLOB_OPEN_SHUTTERS_EARLY, COMSIG_GLOB_OPEN_TIMED_SHUTTERS_LATE,COMSIG_GLOB_TADPOLE_LANDED_OUT_LZ,COMSIG_GLOB_TADPOLE_RAPPEL_DEPLOYED_OUT_LZ,COMSIG_GLOB_DROPPOD_LANDED), PROC_REF(end_resin_drag))

/// Extra handling to remove the stuff needed for dragging
/datum/action/ability/activable/xeno/secrete_resin/remove_action(mob/living/carbon/xenomorph/X)
	if(!CHECK_BITFIELD(SSticker.mode?.round_type_flags, MODE_ALLOW_XENO_QUICKBUILD))
		return ..()
	UnregisterSignal(owner, list(COMSIG_MOB_MOUSEDRAG, COMSIG_MOB_MOUSEUP, COMSIG_MOB_MOUSEDOWN))
	UnregisterSignal(SSdcs, list(COMSIG_GLOB_OPEN_SHUTTERS_EARLY, COMSIG_GLOB_OPEN_TIMED_SHUTTERS_LATE,COMSIG_GLOB_TADPOLE_LANDED_OUT_LZ,COMSIG_GLOB_TADPOLE_RAPPEL_DEPLOYED_OUT_LZ,COMSIG_GLOB_DROPPOD_LANDED))
	update_button_icon() //reason for the double return ..() here is owner gets unassigned in one of the parent procs, so we can't call parent before unregistering signals here
	return ..()

/datum/action/ability/activable/xeno/secrete_resin/update_button_icon()
	var/mob/living/carbon/xenomorph/X = owner
	var/atom/A = X.selected_resin
	action_icon_state = initial(A.name)
	if(SSmonitor.gamestate == SHUTTERS_CLOSED && CHECK_BITFIELD(SSticker.mode?.round_type_flags, MODE_ALLOW_XENO_QUICKBUILD) && SSresinshaping.active)
		button.cut_overlay(visual_references[VREF_MUTABLE_BUILDING_COUNTER])
		var/mutable_appearance/number = visual_references[VREF_MUTABLE_BUILDING_COUNTER]
		number.maptext = MAPTEXT("[SSresinshaping.quickbuild_points_by_hive[owner.get_xeno_hivenumber()]]")
		visual_references[VREF_MUTABLE_BUILDING_COUNTER] = number
		button.add_overlay(visual_references[VREF_MUTABLE_BUILDING_COUNTER])
	else if(visual_references[VREF_MUTABLE_BUILDING_COUNTER])
		button.cut_overlay(visual_references[VREF_MUTABLE_BUILDING_COUNTER])
		visual_references[VREF_MUTABLE_BUILDING_COUNTER] = null
	return ..()

/datum/action/ability/activable/xeno/secrete_resin/action_activate()
	//Left click on the secrete resin button opens up radial menu (new type of changing structures).
	var/mob/living/carbon/xenomorph/X = owner
	if(X.selected_ability != src)
		return ..()
	. = ..()
	var/resin_choice = show_radial_menu(owner, owner, GLOB.resin_images_list, radius = 35)
	if(!resin_choice)
		return
	var/i = GLOB.resin_images_list.Find(resin_choice)
	X.selected_resin = buildable_structures[i]
	var/atom/A = X.selected_resin
	X.balloon_alert(X, lowertext(A::name))
	update_button_icon()

/datum/action/ability/activable/xeno/secrete_resin/alternate_action_activate()
	//Right click on secrete resin button cycles through to the next construction type (old method of changing structures).
	var/mob/living/carbon/xenomorph/X = owner
	if(X.selected_ability != src)
		return ..()
	var/i = buildable_structures.Find(X.selected_resin)
	if(length(buildable_structures) == i)
		X.selected_resin = buildable_structures[1]
	else
		X.selected_resin = buildable_structures[i+1]
	var/atom/A = X.selected_resin
	X.balloon_alert(X, lowertext(A::name))
	update_button_icon()

/datum/action/ability/activable/xeno/secrete_resin/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/xowner = owner
	if(SSmonitor.gamestate == SHUTTERS_CLOSED && CHECK_BITFIELD(SSticker.mode?.round_type_flags, MODE_ALLOW_XENO_QUICKBUILD) && SSresinshaping.active)
		qb_build_resin(A)
	else if(get_dist(owner, A) > xowner.xeno_caste.resin_max_range) //Maximum range is defined in the castedatum with resin_max_range, defaults to 0
		build_resin(get_turf(owner))
	else
		build_resin(get_turf(A))
	if(heal_percentage)
		var/health_healed = xeno_owner.maxHealth * heal_percentage
		HEAL_XENO_DAMAGE(xeno_owner, health_healed, FALSE)
/datum/action/ability/activable/xeno/secrete_resin/proc/get_wait()
	. = base_wait
	if(!scaling_wait)
		return
	var/mob/living/carbon/xenomorph/X = owner

	var/build_resin_modifier = 1
	switch(X.selected_resin)
		if(/obj/alien/resin/sticky)
			build_resin_modifier = 0.5

	return (base_wait + scaling_wait - max(0, (scaling_wait * X.health / X.maxHealth))) * build_resin_modifier

/datum/action/ability/activable/xeno/secrete_resin/proc/preshutter_resin_drag(datum/source, atom/src_object, atom/over_object, turf/src_location, turf/over_location, src_control, over_control, params)
	SIGNAL_HANDLER
	if(dragging)
		INVOKE_ASYNC(src, PROC_REF(qb_build_resin), get_turf(over_object))

/datum/action/ability/activable/xeno/secrete_resin/proc/qb_build_resin(turf/T, silent = FALSE)
	return build_resin(T, WEED_COSTS_QB_POINTS, FALSE,  silent= silent)

/datum/action/ability/activable/xeno/secrete_resin/proc/build_resin(turf/T, weed_flags = WEED_REQUIRES_LOS | WEED_TAKES_TIME | WEED_USES_PLASMA | WEED_NOTIFY, sound = SFX_ALIEN_RESIN_BUILD, silent = FALSE)
	var/mob/living/carbon/xenomorph/X = owner
	if(!can_build_here(T, silent))
		return fail_activate()
	if(CHECK_BITFIELD(weed_flags, WEED_REQUIRES_LOS) && !line_of_sight(owner, T, ignore_target_opacity = istype(T, /turf/closed/wall/resin)))
		if(CHECK_BITFIELD(weed_flags, WEED_COSTS_QB_POINTS))
			to_chat(owner, span_warning("You cannot build here without line of sight!"))
		else
			to_chat(owner, span_warning("You cannot secrete resin without line of sight!"))
		return fail_activate()
	if(CHECK_BITFIELD(weed_flags, WEED_TAKES_TIME) && !do_after(X, get_wait(), NONE, T, BUSY_ICON_BUILD))
		return fail_activate()
	// conditions may change, so we need to check again
	if(!can_build_here(T, silent))
		return fail_activate()
	var/atom/AM = X.selected_resin
	var/atom/new_resin
	var/costs_points = TRUE
	if(istype(T, /turf/closed/wall/resin))
		costs_points = FALSE
	if(costs_points && CHECK_BITFIELD(weed_flags, WEED_COSTS_QB_POINTS) && SSresinshaping.quickbuild_points_by_hive[owner.get_xeno_hivenumber()] <= 0)
		to_chat(owner, span_xenouserdanger("The hive has ran out of quickbuilding points! Wait until more sisters awaken or the marines land!"))
		return fail_activate()
	if(ispath(X.selected_resin, /turf)) // We should change turfs, not spawn them in directly
		var/list/baseturfs = islist(T.baseturfs) ? T.baseturfs : list(T.baseturfs)
		if(!istype(T, /turf/closed/wall/resin))
			baseturfs |= T.type
		new_resin = T
		T.ChangeTurf(X.selected_resin, baseturfs, CHANGETURF_KEEP_WEEDS)
	else
		new_resin = new X.selected_resin(T)
	if(CHECK_BITFIELD(weed_flags, WEED_NOTIFY))
		X.visible_message(span_xenowarning("\The [X] regurgitates a thick substance and shapes it into \a [initial(AM.name)]!"), \
		span_xenonotice("We regurgitate some resin and shape it into \a [initial(AM.name)]."), null, 5)
	if(sound)
		playsound(get_turf(owner), sound, 25)
	switch(X.selected_resin)
		if(/obj/alien/resin/sticky)
			ability_cost = initial(ability_cost) / 3
	if(new_resin)
		if(CHECK_BITFIELD(weed_flags, WEED_USES_PLASMA))
			add_cooldown(SSmonitor.gamestate == SHUTTERS_CLOSED ? get_cooldown()/2 : get_cooldown())
			succeed_activate(SSmonitor.gamestate == SHUTTERS_CLOSED ? ability_cost/2 : ability_cost)
		if(costs_points &&CHECK_BITFIELD(weed_flags, WEED_COSTS_QB_POINTS))
			SSresinshaping.quickbuild_points_by_hive[owner.get_xeno_hivenumber()]--
	ability_cost = initial(ability_cost) //Reset the plasma cost
	owner.record_structures_built()
	return TRUE

/datum/action/ability/activable/xeno/secrete_resin/proc/can_build_here(turf/T, silent = FALSE)
	var/mob/living/carbon/xenomorph/X = owner
	var/is_valid = is_valid_for_resin_structure(T, X.selected_resin == /obj/structure/mineral_door/resin, X.selected_resin)
	if(is_valid != NO_ERROR && silent)
		return FALSE
	switch(is_valid)
		if(NO_ERROR)
			return TRUE
		if(ERROR_CANT_WEED)
			owner.balloon_alert(owner, "this spot can't hold weeds!")
			return FALSE
		if(ERROR_NO_WEED)
			owner.balloon_alert(owner, "this spot doesn't have weeds!")
			return FALSE
		if(ERROR_NO_SUPPORT)
			owner.balloon_alert(owner, "no adjacent structure for support!")
			return FALSE
		if(ERROR_NOT_ALLOWED)
			owner.balloon_alert(owner, "the queen mother prohibits building here!")
			return FALSE
		if(ERROR_BLOCKER)
			owner.balloon_alert(owner, "a xeno is blocking this spot!")
			return FALSE
		if(ERROR_FOG)
			owner.balloon_alert(owner, "the fog won't let the resin grow!")
			return FALSE
		// it fails a lot here when dragging , so its to prevent spam
		if(ERROR_CONSTRUCT)
			return FALSE
	return FALSE

/datum/action/ability/xeno_action/pheromones
	name = "Emit Pheromones"
	action_icon_state = "emit_pheromones"
	ability_cost = 30
	desc = "Opens your pheromone options."
	use_state_flags = ABILITY_USE_STAGGERED|ABILITY_USE_NOTTURF|ABILITY_USE_BUSY|ABILITY_USE_LYING|ABILITY_USE_BUCKLED
	/// The amount to increase the aura's strength by. This is not used in determining the range.
	var/bonus_flat_strength = 0
	/// The amount to increase the aura's range by.
	var/bonus_flat_range = 0

/datum/action/ability/xeno_action/pheromones/proc/apply_pheros(phero_choice)
	var/mob/living/carbon/xenomorph/X = owner

	if(X.current_aura && X.current_aura.aura_types[1] == phero_choice)
		X.balloon_alert(X, "no longer emitting")
		QDEL_NULL(X.current_aura)
		if(X.hive?.living_xeno_ruler == X)
			X.hive?.update_leader_pheromones()
		X.hud_set_pheromone()
		return fail_activate()
	QDEL_NULL(X.current_aura)
	X.current_aura = SSaura.add_emitter(X, phero_choice, 6 + (X.xeno_caste.aura_strength * 2) + bonus_flat_range, X.xeno_caste.aura_strength + bonus_flat_strength, -1, X.faction, X.hivenumber)
	X.balloon_alert(X, "[lowertext(phero_choice)]")
	playsound(X.loc, SFX_ALIEN_DROOL, 25)

	if(X.hive?.living_xeno_ruler == X)
		X.hive?.update_leader_pheromones()
	X.hud_set_pheromone() //Visual feedback that the xeno has immediately started emitting pheromones
	succeed_activate()

/datum/action/ability/xeno_action/pheromones/action_activate()
	var/phero_choice = show_radial_menu(owner, owner, GLOB.pheromone_images_list, radius = 35)
	if(!phero_choice)
		return fail_activate()
	switch(phero_choice)
		if(AURA_XENO_RECOVERY)
			var/datum/action/ability/xeno_action/pheromones/emit_recovery/recovery_pheromones = xeno_owner.actions_by_path[/datum/action/ability/xeno_action/pheromones/emit_recovery]
			if(recovery_pheromones)
				recovery_pheromones.apply_pheros(AURA_XENO_RECOVERY)
		if(AURA_XENO_WARDING)
			var/datum/action/ability/xeno_action/pheromones/emit_warding/warding_pheromones = xeno_owner.actions_by_path[/datum/action/ability/xeno_action/pheromones/emit_warding]
			if(warding_pheromones)
				warding_pheromones.apply_pheros(AURA_XENO_WARDING)
		if(AURA_XENO_FRENZY)
			var/datum/action/ability/xeno_action/pheromones/emit_frenzy/frenzy_pheromones = xeno_owner.actions_by_path[/datum/action/ability/xeno_action/pheromones/emit_frenzy]
			if(frenzy_pheromones)
				frenzy_pheromones.apply_pheros(AURA_XENO_FRENZY)

/datum/action/ability/xeno_action/pheromones/emit_recovery
	name = "Toggle Recovery Pheromones"
	desc = "Increases healing for yourself and nearby teammates."
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_EMIT_RECOVERY,
	)
	hidden = TRUE

/datum/action/ability/xeno_action/pheromones/emit_recovery/action_activate()
	apply_pheros(AURA_XENO_RECOVERY)

/datum/action/ability/xeno_action/pheromones/emit_warding
	name = "Toggle Warding Pheromones"
	desc = "Increases armor for yourself and nearby teammates."
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_EMIT_WARDING,
	)
	hidden = TRUE

/datum/action/ability/xeno_action/pheromones/emit_warding/action_activate()
	apply_pheros(AURA_XENO_WARDING)

/datum/action/ability/xeno_action/pheromones/emit_frenzy
	name = "Toggle Frenzy Pheromones"
	desc = "Increases damage for yourself and nearby teammates."
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_EMIT_FRENZY,
	)
	hidden = TRUE

/datum/action/ability/xeno_action/pheromones/emit_frenzy/action_activate()
	apply_pheros(AURA_XENO_FRENZY)

/datum/action/ability/activable/xeno/transfer_plasma
	name = "Transfer Plasma"
	action_icon_state = "transfer_plasma"
	action_icon = 'icons/Xeno/actions/drone.dmi'
	desc = "Give some of your plasma to a teammate."
	var/plasma_transfer_amount = PLASMA_TRANSFER_AMOUNT
	var/transfer_delay = 2 SECONDS
	var/max_range = 2
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_TRANSFER_PLASMA,
	)
	target_flags = ABILITY_MOB_TARGET

/datum/action/ability/activable/xeno/transfer_plasma/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE

	if(!isxeno(A) || A == owner || !owner.issamexenohive(A))
		return FALSE

	var/mob/living/carbon/xenomorph/target = A

	if(!(target.xeno_caste.can_flags & CASTE_CAN_BE_GIVEN_PLASMA))
		if(!silent)
			to_chat(owner, span_warning("We can't give that caste plasma."))
			return FALSE

	if(get_dist(owner, target) > max_range)
		if(!silent)
			to_chat(owner, span_warning("We need to be closer to [target]."))
		return FALSE

	if(target.plasma_stored >= target.xeno_caste.plasma_max) //We can't select targets that won't benefit
		to_chat(owner, span_xenowarning("[target] already has full plasma."))
		return FALSE

/datum/action/ability/activable/xeno/transfer_plasma/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/X = owner
	var/mob/living/carbon/xenomorph/target = A

	to_chat(X, span_notice("We start focusing our plasma towards [target]."))
	new /obj/effect/temp_visual/transfer_plasma(get_turf(X)) //Cool SFX that confirms our source and our target
	new /obj/effect/temp_visual/transfer_plasma(get_turf(target)) //Cool SFX that confirms our source and our target
	playsound(X, SFX_ALIEN_DROOL, 25)

	X.face_atom(target) //Face our target so we don't look silly

	if(!do_after(X, transfer_delay, NONE, null, BUSY_ICON_FRIENDLY))
		return fail_activate()

	if(!can_use_ability(A))
		return fail_activate()

	target.beam(X,"drain_life", time = 1 SECONDS, maxdistance = 10) //visual SFX
	target.add_filter("transfer_plasma_outline", 3, outline_filter(1, COLOR_STRONG_MAGENTA))
	addtimer(CALLBACK(target, TYPE_PROC_REF(/datum, remove_filter), "transfer_plasma_outline"), 1 SECONDS) //Failsafe blur removal

	var/amount = plasma_transfer_amount
	if(X.plasma_stored < plasma_transfer_amount)
		amount = X.plasma_stored //Just use all of it

	else //Otherwise transfer as much as the target can use
		amount = clamp(target.xeno_caste.plasma_max - target.plasma_stored, 0, plasma_transfer_amount)

	X.use_plasma(amount)
	target.gain_plasma(amount)
	to_chat(target, span_xenodanger("[X] has transfered [amount] units of plasma to us. We now have [target.plasma_stored]/[target.xeno_caste.plasma_max]."))
	to_chat(X, span_xenodanger("We have transferred [amount] units of plasma to [target]. We now have [X.plasma_stored]/[X.xeno_caste.plasma_max]."))
	playsound(X, SFX_ALIEN_DROOL, 25)


// ***************************************
// *********** Corrosive Acid
// ***************************************

/datum/action/ability/activable/xeno/corrosive_acid
	name = "Corrosive Acid"
	action_icon_state = "corrosive_acid"
	desc = "Cover an object with acid to slowly melt it. Takes a few seconds."
	ability_cost = 100
	var/obj/effect/xenomorph/acid/acid_type = /obj/effect/xenomorph/acid
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_CORROSIVE_ACID,
	)
	use_state_flags = ABILITY_USE_BUCKLED
	/// How much to reduce acid delay? Lower is faster. Multiplicative.
	var/acid_speed_multiplier = 1

/datum/action/ability/activable/xeno/corrosive_acid/can_use_ability(atom/A, silent = FALSE, override_flags)
	var/obj/effect/xenomorph/acid/current_acid_type = acid_type
	if(SSmonitor.gamestate == SHUTTERS_CLOSED && CHECK_BITFIELD(SSticker.mode?.round_type_flags, MODE_ALLOW_XENO_QUICKBUILD) && SSresinshaping.active)
		current_acid_type = /obj/effect/xenomorph/acid/strong //if it is before shutters open, everyone gets strong acid
	// Check if it's an acid object we're upgrading
	if (istype(A, /obj/effect/xenomorph/acid))
		var/obj/effect/xenomorph/acid/existing_acid = A
		A = existing_acid.acid_t // Swap the target to the target of the acid
	. = ..()
	if(!.)
		return FALSE
	if(!owner.Adjacent(A))
		if(!silent)
			owner.balloon_alert(owner, "too far away!")
		return FALSE
	if(ismob(A))
		if(!silent)
			owner.balloon_alert(owner, "can't melt that!")
		return FALSE
	switch(A.should_apply_acid(current_acid_type::acid_strength))
		if(ATOM_CANNOT_ACID)
			if(!silent)
				owner.balloon_alert(owner, "can't dissolve that!")
			return FALSE
		if(ATOM_STRONGER_ACID)
			if(!silent)
				owner.balloon_alert(owner, "current acid is equal or higher in power!")
			return FALSE

/datum/action/ability/activable/xeno/corrosive_acid/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/X = owner
	var/obj/effect/xenomorph/acid/current_acid_type = acid_type
	// Check if it's an acid object we're upgrading
	if(istype(A, /obj/effect/xenomorph/acid))
		var/obj/effect/xenomorph/acid/existing_acid = A
		A = existing_acid.acid_t // Swap the target to the target of the acid


	var/aciddelay = max(0, A.get_acid_delay() * acid_speed_multiplier);
	if(SSmonitor.gamestate == SHUTTERS_CLOSED && CHECK_BITFIELD(SSticker.mode?.round_type_flags, MODE_ALLOW_XENO_QUICKBUILD) && SSresinshaping.active)
		current_acid_type = /obj/effect/xenomorph/acid/strong //if it is before shutters open, everyone gets strong acid
		aciddelay = 0

	if(!A.dissolvability(current_acid_type::acid_strength))
		return fail_activate()

	X.face_atom(A)
	to_chat(X, span_xenowarning("We begin generating enough acid to melt through the [A]"))

	if(!do_after(X, aciddelay, NONE, A, BUSY_ICON_HOSTILE))
		return fail_activate()

	if(!can_use_ability(A, TRUE))
		return fail_activate()

	new current_acid_type(get_turf(A), A, A.dissolvability(current_acid_type::acid_strength))
	succeed_activate(ability_cost * A.dissolvability(current_acid_type::acid_strength) > 0 ? ability_cost / A.dissolvability(current_acid_type::acid_strength) : ability_cost)

	if(!isturf(A))
		log_combat(X, A, "spat on", addition="with corrosive acid")
	X.visible_message(span_xenowarning("\The [X] vomits globs of vile stuff all over \the [A]. It begins to sizzle and melt under the bubbling mess of acid!"), \
	span_xenowarning("We vomit globs of vile stuff all over \the [A]. It begins to sizzle and melt under the bubbling mess of acid!"), null, 5)
	playsound(X.loc, "sound/bullets/acid_impact1.ogg", 25)
	if(owner.client)
		var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[owner.ckey]
		personal_statistics.acid_applied++
	GLOB.round_statistics.all_acid_applied++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "all_acid_applied")

// ***************************************
// *********** Super strong acid
// ***************************************

/datum/action/ability/activable/xeno/corrosive_acid/strong
	name = "Corrosive Acid"
	ability_cost = 200
	acid_type = /obj/effect/xenomorph/acid/strong


/datum/action/ability/activable/xeno/spray_acid
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_SPRAY_ACID,
	)
	use_state_flags = ABILITY_USE_BUCKLED
	action_icon_state = "spray_acid"
	action_icon = 'icons/Xeno/actions/boiler.dmi'

/datum/action/ability/activable/xeno/spray_acid/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(!A)
		return FALSE

	var/turf/T = get_turf(owner)
	var/turf/T2 = get_turf(A)
	if(T == T2)
		if(!silent)
			to_chat(owner, span_warning("That's far too close!"))
		return FALSE


/datum/action/ability/activable/xeno/spray_acid/on_cooldown_finish()
	playsound(owner.loc, 'sound/voice/alien/drool1.ogg', 50, 1)
	to_chat(owner, span_xenodanger("We feel our acid glands refill. We can spray acid again."))
	return ..()

/datum/action/ability/activable/xeno/xeno_spit
	name = "Xeno Spit"
	action_icon_state = "shift_spit_neurotoxin"
	action_icon = 'icons/Xeno/actions/spits.dmi'
	desc = "Spit neurotoxin or acid at your target up to 7 tiles away."
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_XENO_SPIT,
	)
	use_state_flags = ABILITY_USE_LYING|ABILITY_USE_BUCKLED|ABILITY_DO_AFTER_ATTACK|ABILITY_USE_STAGGERED
	target_flags = ABILITY_MOB_TARGET
	///Current target that the xeno is targeting. This is for aiming.
	var/current_target

/datum/action/ability/activable/xeno/xeno_spit/give_action(mob/living/L)
	. = ..()
	owner.AddComponent(/datum/component/automatedfire/autofire, get_cooldown(), _fire_mode = GUN_FIREMODE_AUTOMATIC,  _callback_reset_fire = CALLBACK(src, PROC_REF(reset_fire)), _callback_fire = CALLBACK(src, PROC_REF(fire)))

/datum/action/ability/activable/xeno/xeno_spit/remove_action(mob/living/L)
	qdel(owner.GetComponent(/datum/component/automatedfire/autofire))
	return ..()

/datum/action/ability/activable/xeno/xeno_spit/update_button_icon()
	var/mob/living/carbon/xenomorph/X = owner
	action_icon_state = "shift_spit_[initial(X.ammo.icon_state)]"
	return ..()

/datum/action/ability/activable/xeno/xeno_spit/action_activate()
	var/mob/living/carbon/xenomorph/X = owner
	if(X.selected_ability != src)
		RegisterSignal(X, COMSIG_MOB_MOUSEDRAG, PROC_REF(change_target))
		RegisterSignal(X, COMSIG_MOB_MOUSEUP, PROC_REF(stop_fire))
		RegisterSignal(X, COMSIG_MOB_MOUSEDOWN, PROC_REF(start_fire))
		return ..()
	for(var/i in 1 to length(X.xeno_caste.spit_types))
		if(X.ammo == GLOB.ammo_list[X.xeno_caste.spit_types[i]])
			if(i == length(X.xeno_caste.spit_types))
				X.ammo = GLOB.ammo_list[X.xeno_caste.spit_types[1]]
				break
			X.ammo = GLOB.ammo_list[X.xeno_caste.spit_types[i+1]]
			break
	to_chat(X, span_notice("We will now spit [X.ammo.name] ([X.ammo.spit_cost] plasma)."))
	X.update_spits(TRUE)
	update_button_icon()

/datum/action/ability/activable/xeno/xeno_spit/deselect()
	UnregisterSignal(owner, list(COMSIG_MOB_MOUSEUP, COMSIG_MOB_MOUSEDRAG, COMSIG_MOB_MOUSEDOWN))
	return ..()

/datum/action/ability/activable/xeno/xeno_spit/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/xenomorph/X = owner
	if(!X.check_state())
		return FALSE
	if(X.ammo?.spit_cost > X.plasma_stored)
		if(!silent)
			to_chat(X, span_warning("We need [X.ammo?.spit_cost - X.plasma_stored] more plasma!"))
		return FALSE

/datum/action/ability/activable/xeno/xeno_spit/get_cooldown()
	var/mob/living/carbon/xenomorph/X = owner
	return (X.xeno_caste.spit_delay + X.ammo?.added_spit_delay)

/datum/action/ability/activable/xeno/xeno_spit/on_cooldown_finish()
	var/mob/living/carbon/xenomorph/X = owner
	to_chat(X, span_notice("We feel our neurotoxin glands swell with ichor. We can spit again."))
	return ..()

/datum/action/ability/activable/xeno/xeno_spit/use_ability(atom/A)
	if(owner.client) //If its not an ai it will register to listen for clicks instead of use this proc. We want to call start_fire from here only if the owner is an ai.
		return
	start_fire(object = A, can_use_ability_flags = ABILITY_IGNORE_SELECTED_ABILITY)

///Starts the xeno firing.
/datum/action/ability/activable/xeno/xeno_spit/proc/start_fire(datum/source, atom/object, turf/location, control, params, can_use_ability_flags)
	SIGNAL_HANDLER
	var/list/modifiers = params2list(params)
	if(((modifiers["right"] || modifiers["middle"]) && (modifiers["shift"] || modifiers["ctrl"] || modifiers["left"])) || \
	((modifiers["left"] && modifiers["shift"]) && (modifiers["ctrl"] || modifiers["middle"] || modifiers["right"])) || \
	(modifiers["left"] && !modifiers["shift"]))
		return
	var/mob/living/carbon/xenomorph/xeno = owner
	if(!can_use_ability(object, TRUE, can_use_ability_flags))
		return fail_activate()
	set_target(get_turf_on_clickcatcher(object, xeno, params))
	if(!current_target)
		return

	SEND_SIGNAL(owner, COMSIG_XENO_FIRE)
	xeno?.client?.mouse_pointer_icon = 'icons/UI_Icons/gun_crosshairs/rifle.dmi'

///Fires the spit projectile.
/datum/action/ability/activable/xeno/xeno_spit/proc/fire()
	var/mob/living/carbon/xenomorph/X = owner
	var/turf/current_turf = get_turf(owner)
	var/sound_to_play = pick(1, 2) == 1 ? 'sound/voice/alien/spitacid.ogg' : 'sound/voice/alien/spitacid2.ogg'
	playsound(X.loc, sound_to_play, 25, 1)

	var/atom/movable/projectile/newspit = new /atom/movable/projectile(current_turf)
	ability_cost = X.ammo.spit_cost
	newspit.generate_bullet(X.ammo, X.ammo.damage * SPIT_UPGRADE_BONUS(X))
	newspit.def_zone = X.get_limbzone_target()
	newspit.fire_at(current_target, X, X, X.ammo.max_range, X.ammo.shell_speed)

	if(can_use_ability(current_target) && X.client) //X.client to make sure autospit doesn't continue for non player mobs.
		succeed_activate()
		return AUTOFIRE_CONTINUE
	fail_activate()
	return NONE

///Resets the autofire component.
/datum/action/ability/activable/xeno/xeno_spit/proc/reset_fire()
	set_target(null)
	owner?.client?.mouse_pointer_icon = initial(owner.client.mouse_pointer_icon)

///Changes the current target.
/datum/action/ability/activable/xeno/xeno_spit/proc/change_target(datum/source, atom/src_object, atom/over_object, turf/src_location, turf/over_location, src_control, over_control, params)
	SIGNAL_HANDLER
	var/mob/living/carbon/xenomorph/xeno = owner
	set_target(get_turf_on_clickcatcher(over_object, xeno, params))
	xeno.face_atom(current_target)

///Sets the current target and registers for qdel to prevent hardels
/datum/action/ability/activable/xeno/xeno_spit/proc/set_target(atom/object)
	if(object == current_target || object == owner)
		return
	if(current_target)
		UnregisterSignal(current_target, COMSIG_QDELETING)
	current_target = object
	if(current_target)
		RegisterSignal(current_target, COMSIG_QDELETING, PROC_REF(clean_target))

///Cleans the current target in case of Hardel
/datum/action/ability/activable/xeno/xeno_spit/proc/clean_target()
	SIGNAL_HANDLER
	current_target = get_turf(current_target)

///Stops the Autofire component and resets the current cursor.
/datum/action/ability/activable/xeno/xeno_spit/proc/stop_fire()
	SIGNAL_HANDLER
	owner?.client?.mouse_pointer_icon = initial(owner.client.mouse_pointer_icon)
	SEND_SIGNAL(owner, COMSIG_XENO_STOP_FIRE)

/datum/action/ability/activable/xeno/xeno_spit/ai_should_start_consider()
	return TRUE

/datum/action/ability/activable/xeno/xeno_spit/ai_should_use(atom/target)
	if(!iscarbon(target))
		return FALSE
	if(get_dist(target, owner) > 6)
		return FALSE
	if(!can_use_ability(target, override_flags = ABILITY_IGNORE_SELECTED_ABILITY))
		return FALSE
	if(!line_of_sight(owner, target))
		return FALSE
	if(target.get_xeno_hivenumber() == owner.get_xeno_hivenumber())
		return FALSE
	return TRUE


/datum/action/ability/xeno_action/xenohide
	name = "Hide"
	action_icon_state = "xenohide"
	desc = "Causes your sprite to hide behind certain objects and under tables. Not the same as stealth. Does not use plasma."
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_HIDE,
	)

/datum/action/ability/xeno_action/xenohide/remove_action(mob/living/L)
	UnregisterSignal(L, COMSIG_XENOMORPH_POUNCE)
	return ..()

/datum/action/ability/xeno_action/xenohide/can_use_action(silent, override_flags, selecting)
	if(HAS_TRAIT(owner, TRAIT_TANK_DESANT))
		if(!silent)
			owner.balloon_alert(owner, "cannot while on vehicle")
		return FALSE
	return ..()

/datum/action/ability/xeno_action/xenohide/action_activate()
	var/mob/living/carbon/xenomorph/X = owner
	if(X.layer != BELOW_TABLE_LAYER)
		RegisterSignal(owner, COMSIG_XENOMORPH_POUNCE, PROC_REF(action_activate))
		X.layer = BELOW_TABLE_LAYER
		to_chat(X, span_notice("We are now hiding."))
		button.add_overlay(mutable_appearance('icons/Xeno/actions/general.dmi', "selected_purple_frame", ACTION_LAYER_ACTION_ICON_STATE, null, FLOAT_PLANE))
	else
		UnregisterSignal(owner, COMSIG_XENOMORPH_POUNCE)
		X.layer = MOB_LAYER
		to_chat(X, span_notice("We have stopped hiding."))
		button.cut_overlay(mutable_appearance('icons/Xeno/actions/general.dmi', "selected_purple_frame", ACTION_LAYER_ACTION_ICON_STATE, null, FLOAT_PLANE))


//Neurotox Sting
/datum/action/ability/activable/xeno/neurotox_sting
	name = "Neurotoxin Sting"
	action_icon_state = "neuro_sting"
	action_icon = 'icons/Xeno/actions/sentinel.dmi'
	desc = "A channeled melee attack that injects the target with neurotoxin over a few seconds, temporarily stunning them."
	cooldown_duration = 12 SECONDS
	ability_cost = 150
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_NEUROTOX_STING,
	)
	target_flags = ABILITY_MOB_TARGET
	use_state_flags = ABILITY_USE_BUCKLED
	/// Whatever our victim is injected with.
	var/sting_chemical = /datum/reagent/toxin/xeno_neurotoxin
	/// The amount of reagents injected for each recurring injection.
	var/sting_amount = XENO_NEURO_AMOUNT_RECURRING
	/// The type of gas that is emitted, if any. This only occurs on the first injection.
	var/datum/effect_system/smoke_spread/sting_gas
	/// The range of the gas emitted, if any.
	var/sting_gas_range = 0

/datum/action/ability/activable/xeno/neurotox_sting/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE

	if(!A?.can_sting())
		if(!silent)
			to_chat(owner, span_warning("Our sting won't affect this target!"))
		return FALSE
	if(!owner.Adjacent(A))
		var/mob/living/carbon/xenomorph/X = owner
		if(!silent && world.time > (X.recent_notice + X.notice_delay)) //anti-notice spam
			to_chat(X, span_warning("We can't reach this target!"))
			X.recent_notice = world.time //anti-notice spam
		return FALSE
	var/mob/living/carbon/C = A
	if (isnestedhost(C))
		if(!silent)
			to_chat(owner, span_warning("Ashamed, we reconsider bullying the poor, nested host with our stinger."))
		return FALSE

/datum/action/ability/activable/xeno/neurotox_sting/on_cooldown_finish()
	playsound(owner.loc, 'sound/voice/alien/drool1.ogg', 50, 1)
	to_chat(owner, span_xenodanger("We feel our toxic glands refill. We can use our [initial(name)] again."))
	return ..()

/datum/action/ability/activable/xeno/neurotox_sting/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/X = owner

	succeed_activate()

	add_cooldown()
	X.recurring_injection(A, sting_chemical, XENO_NEURO_CHANNEL_TIME, sting_amount, gas_type = sting_gas, gas_range = sting_gas_range)

	track_stats()

///Adds ability tally to the end-round statistics.
/datum/action/ability/activable/xeno/neurotox_sting/proc/track_stats()
	GLOB.round_statistics.sentinel_neurotoxin_stings++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "sentinel_neurotoxin_stings")

//Ozelomelyn Sting
/datum/action/ability/activable/xeno/neurotox_sting/ozelomelyn
	name = "Ozelomelyn Sting"
	action_icon_state = "drone_sting"
	action_icon = 'icons/Xeno/actions/shrike.dmi'
	desc = "A channeled melee attack that injects the target with Ozelomelyn over a few seconds, purging chemicals and dealing minor toxin damage to a moderate cap while inside them."
	cooldown_duration = 25 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_OZELOMELYN_STING,
	)
	ability_cost = 100
	sting_chemical = /datum/reagent/toxin/xeno_ozelomelyn

///Adds ability tally to the end-round statistics.
/datum/action/ability/activable/xeno/neurotox_sting/ozelomelyn/track_stats()
	GLOB.round_statistics.ozelomelyn_stings++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "ozelomelyn_stings")

// ***************************************
// *********** Psychic Whisper
// ***************************************
/datum/action/ability/xeno_action/psychic_whisper
	name = "Psychic Whisper"
	action_icon_state = "psychic_whisper"
	action_icon = 'icons/Xeno/actions/shrike.dmi'
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_PSYCHIC_WHISPER,
	)
	use_state_flags = ABILITY_USE_LYING
	target_flags = ABILITY_MOB_TARGET


/datum/action/ability/xeno_action/psychic_whisper/action_activate()
	var/mob/living/carbon/xenomorph/X = owner
	var/list/target_list = list()
	for(var/mob/living/possible_target in view(WORLD_VIEW, X))
		if(possible_target == X || !possible_target.client || isxeno(possible_target))
			continue
		target_list += possible_target

	if(!length(target_list))
		to_chat(X, span_warning("There's nobody nearby to whisper to."))
		return

	var/mob/living/L = tgui_input_list(X, "Target", "Send a Psychic Whisper to whom?", target_list)
	if(!L)
		return

	if(!X.check_state())
		return

	var/msg = stripped_input("Message:", "Psychic Whisper")
	if(!msg)
		return

	log_directed_talk(X, L, msg, LOG_SAY, "psychic whisper")
	to_chat(L, span_alien("You hear a strange, alien voice in your head. <i>\"[msg]\"</i>"))
	to_chat(X, span_xenonotice("We said: \"[msg]\" to [L]"))
	message_admins("[X] has sent [L] this psychic message: \"[msg]\" at [ADMIN_VERBOSEJMP(X)].")

// ***************************************
// *********** Lay Egg
// ***************************************
/datum/action/ability/xeno_action/lay_egg
	name = "Lay Egg"
	action_icon_state = "lay_egg"
	action_icon = 'icons/Xeno/actions/construction.dmi'
	desc = "Create an egg that will grow a larval hugger after a short delay. Empty eggs can have huggers inserted into them."
	ability_cost = 200
	cooldown_duration = 12 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_LAY_EGG,
	)
	/// Should the egg contain the owner's selected_hugger_type instead?
	var/use_selected_hugger = FALSE
	/// The amount to multiply the created hugger's hand attach time by.
	var/hand_attach_time_multiplier = 1

/datum/action/ability/xeno_action/lay_egg/action_activate(mob/living/carbon/xenomorph/user)
	var/mob/living/carbon/xenomorph/xeno = owner
	var/turf/current_turf = get_turf(owner)

	if(!current_turf.check_alien_construction(owner, planned_building = /obj/alien/egg/hugger))
		return fail_activate()

	if(!xeno.loc_weeds_type)
		to_chat(user, span_xenowarning("Our eggs wouldn't grow well enough here. Lay them on resin."))
		return fail_activate()

	owner.visible_message(span_xenonotice("[owner] starts planting an egg."), \
		span_xenonotice("We start planting an egg."), null, 5)

	if(!do_after(owner, 2.5 SECONDS, NONE, current_turf, BUSY_ICON_BUILD, extra_checks = CALLBACK(current_turf, TYPE_PROC_REF(/turf, check_alien_construction), owner)))
		return fail_activate()

	if(!xeno.loc_weeds_type)
		return fail_activate()

	new /obj/alien/egg/hugger(current_turf, xeno.hivenumber, use_selected_hugger ? xeno_owner.selected_hugger_type : null, hand_attach_time_multiplier)

	playsound(current_turf, 'sound/effects/splat.ogg', 15, 1)

	succeed_activate()
	add_cooldown()
	owner.record_traps_created()

/////////////////////////////////////////////////////////////////////////////////////////////

////////////////////
/// Rally Hive
///////////////////
/datum/action/ability/xeno_action/rally_hive
	name = "Rally Hive"
	action_icon_state = "rally_hive"
	action_icon = 'icons/Xeno/actions/leader.dmi'
	desc = "Rallies the hive to a congregate at a target location, along with an arrow pointer. Gives the Hive your current health status. 60 second cooldown."
	ability_cost = 0
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_RALLY_HIVE,
	)
	keybind_flags = ABILITY_KEYBIND_USE_ABILITY
	cooldown_duration = 60 SECONDS
	use_state_flags = ABILITY_USE_LYING|ABILITY_USE_BUCKLED

/datum/action/ability/xeno_action/rally_hive/action_activate()
	var/mob/living/carbon/xenomorph/X = owner

	xeno_message("Our leader [X] is rallying the hive to [AREACOORD_NO_Z(X.loc)]!", "xenoannounce", 6, X.hivenumber, FALSE, X, 'sound/voice/alien/distantroar_3.ogg',TRUE,null,/atom/movable/screen/arrow/leader_tracker_arrow)
	notify_ghosts("\ [X] is rallying the hive to [AREACOORD_NO_Z(X.loc)]!", source = X, action = NOTIFY_JUMP)

	succeed_activate()
	add_cooldown()

	GLOB.round_statistics.xeno_rally_hive++ //statistics
	SSblackbox.record_feedback("tally", "round_statistics", 1, "xeno_rally_hive")

/datum/action/ability/xeno_action/rally_minion
	name = "Rally Minions"
	action_icon_state = "minion_agressive"
	action_icon = 'icons/Xeno/actions/leader.dmi'
	desc = "Rallies the minions around you, asking them to follow you if they don't have a leader already. Rightclick to change minion behaviour."
	ability_cost = 0
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_RALLY_MINION,
		KEYBINDING_ALTERNATE = COMSIG_XENOABILITY_MINION_BEHAVIOUR,
	)
	keybind_flags = ABILITY_KEYBIND_USE_ABILITY
	cooldown_duration = 10 SECONDS
	use_state_flags = ABILITY_USE_LYING|ABILITY_USE_BUCKLED
	///If minions should be agressive
	var/minions_agressive = TRUE

/datum/action/ability/xeno_action/rally_minion/update_button_icon()
	action_icon_state = minions_agressive ? "minion_agressive" : "minion_passive"
	return ..()

/datum/action/ability/xeno_action/rally_minion/action_activate()
	succeed_activate()
	add_cooldown()
	owner.emote("roar")
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_AI_MINION_RALLY, owner)
	SEND_SIGNAL(owner, COMSIG_ESCORTING_ATOM_BEHAVIOUR_CHANGED, minions_agressive) //New escorting ais should have the same behaviour as old one

/datum/action/ability/xeno_action/rally_minion/alternate_action_activate()
	minions_agressive = !minions_agressive
	SEND_SIGNAL(owner, COMSIG_ESCORTING_ATOM_BEHAVIOUR_CHANGED, minions_agressive)
	update_button_icon()

/////////////////////////////////////////////////////////////////////////////////////////////

/mob/living/carbon/xenomorph/proc/add_abilities()
	for(var/action_path in xeno_caste.actions)
		var/datum/action/ability/xeno_action/action = new action_path(src)
		if(!SSticker.mode || SSticker.mode.xeno_abilities_flags & action.gamemode_flags)
			action.give_action(src)


/mob/living/carbon/xenomorph/proc/remove_abilities()
	for(var/action_datum in mob_abilities)
		qdel(action_datum)

/datum/action/ability/xeno_action/rally_hive/hivemind //Halve the cooldown for Hiveminds as their relative omnipresence means they can actually make use of this lower cooldown.
	cooldown_duration = 30 SECONDS

//*********
// Psy Drain
//*********
/datum/action/ability/activable/xeno/psydrain
	name = "Psy drain"
	action_icon_state = "headbite"
	desc = "Drain the victim of its life force to gain larva and psych points"
	ability_cost = 50
	use_state_flags = ABILITY_USE_STAGGERED|ABILITY_USE_FORTIFIED|ABILITY_USE_CRESTED //can't use while staggered, defender fortified or crest down
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_HEADBITE,
	)
	gamemode_flags = ABILITY_NUCLEARWAR
	///How much larva points it gives (10 points for one larva in NW)
	var/larva_point_reward = 1

/datum/action/ability/activable/xeno/psydrain/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..() //do after checking the below stuff
	if(!.)
		return
	if(!iscarbon(A))
		return FALSE
	var/mob/living/carbon/xenomorph/X = owner
	var/mob/living/carbon/victim = A //target of ability
	if(X.do_actions) //can't use if busy
		return FALSE
	if(!X.Adjacent(victim)) //checks if owner next to target
		return FALSE
	if(X.on_fire)
		if(!silent)
			to_chat(X, span_warning("We're too busy being on fire to do this!"))
		return FALSE
	if(victim.stat != DEAD)
		if(!silent)
			to_chat(X, span_warning("This creature is struggling too much for us to drain its life force."))
		return FALSE
	if(HAS_TRAIT(victim, TRAIT_PSY_DRAINED))
		if(!silent)
			to_chat(X, span_warning("There is no longer any life force in this creature!"))
		return FALSE
	if(!ishuman(victim))
		if(!silent)
			to_chat(X, span_warning("We can't drain something that is not human."))
		return FALSE
	if(issynth(victim)) //checks if target is a synth
		if(!silent)
			to_chat(X, span_warning("This artificial construct has no life force to drain"))
		return FALSE
	if(X.status_flags & INCORPOREAL)
		if(!silent)
			to_chat(X, span_warning("You can't do this while flying!"))
		return FALSE

	X.face_atom(victim) //Face towards the target so we don't look silly
	X.visible_message(span_xenowarning("\The [X] begins opening its mouth and extending a second jaw towards \the [victim]."), \
	span_danger("We slowly drain \the [victim]'s life force!"), null, 20)
	var/channel = SSsounds.random_available_channel()
	playsound(X, 'sound/magic/nightfall.ogg', 40, channel = channel)
	if(!do_after(X, 5 SECONDS, IGNORE_HELD_ITEM, victim, BUSY_ICON_DANGER, extra_checks = CALLBACK(X, TYPE_PROC_REF(/mob, break_do_after_checks), list("health" = X.health))))
		X.visible_message(span_xenowarning("\The [X] retracts its inner jaw."), \
		span_danger("We retract our inner jaw."), null, 20)
		X.stop_sound_channel(channel)
		return FALSE
	X.stop_sound_channel(channel)
	succeed_activate() //dew it

/datum/action/ability/activable/xeno/psydrain/use_ability(mob/M)
	var/mob/living/carbon/xenomorph/X = owner
	var/mob/living/carbon/victim = M

	if(HAS_TRAIT(victim, TRAIT_PSY_DRAINED))
		to_chat(X, span_warning("Someone drained the life force of our victim before we could do it!"))
		return fail_activate()

	playsound(X, 'sound/magic/end_of_psy_drain.ogg', 40)

	X.visible_message(span_xenodanger("\The [victim]'s life force is drained by \the [X]!"), \
	span_xenodanger("We suddenly feel \the [victim]'s life force streaming into us!"))

	victim.do_jitter_animation(2)
	victim.adjustCloneLoss(20)

	ADD_TRAIT(victim, TRAIT_PSY_DRAINED, TRAIT_PSY_DRAINED)
	if(HAS_TRAIT(victim, TRAIT_UNDEFIBBABLE))
		victim.med_hud_set_status()
	var/psy_points_reward = PSY_DRAIN_REWARD_MIN + ((HIGH_PLAYER_POP - SSmonitor.maximum_connected_players_count) / HIGH_PLAYER_POP * (PSY_DRAIN_REWARD_MAX - PSY_DRAIN_REWARD_MIN))
	psy_points_reward = clamp(psy_points_reward, PSY_DRAIN_REWARD_MIN, PSY_DRAIN_REWARD_MAX)
	if(HAS_TRAIT(victim, TRAIT_HIVE_TARGET))
		SEND_GLOBAL_SIGNAL(COMSIG_GLOB_HIVE_TARGET_DRAINED, X)
		psy_points_reward = psy_points_reward * 3
	SSpoints.add_strategic_psy_points(X.hivenumber, psy_points_reward)
	SSpoints.add_tactical_psy_points(X.hivenumber, psy_points_reward*0.25)
	if(X.hivenumber != XENO_HIVE_NORMAL)
		return
	var/datum/job/xeno_job = SSjob.GetJobType(/datum/job/xenomorph)
	xeno_job.add_job_points(larva_point_reward)
	X.hive.update_tier_limits()
	GLOB.round_statistics.larva_from_psydrain += larva_point_reward / xeno_job.job_points_needed

	if(owner.client)
		var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[owner.ckey]
		personal_statistics.drained++
	log_combat(victim, owner, "was drained.")
	log_game("[key_name(victim)] was drained at [AREACOORD(victim.loc)].")

/////////////////////////////////
// Cocoon
/////////////////////////////////
/datum/action/ability/activable/xeno/cocoon
	name = "Cocoon"
	action_icon_state = "regurgitate"
	desc = "Devour your victim to cocoon it in your belly. This cocoon will automatically be ejected later, and while the marine inside it still has life force it will give psychic points."
	use_state_flags = ABILITY_USE_STAGGERED|ABILITY_USE_FORTIFIED|ABILITY_USE_CRESTED //can't use while staggered, defender fortified or crest down
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_REGURGITATE,
	)
	ability_cost = 100
	gamemode_flags = ABILITY_NUCLEARWAR
	///In how much time the cocoon will be ejected
	var/cocoon_production_time = 3 SECONDS

/datum/action/ability/activable/xeno/cocoon/can_use_ability(atom/A, silent, override_flags)
	. = ..()
	if(!.)
		return
	if(!ishuman(A) || issynth(A))
		to_chat(owner, span_warning("That wouldn't taste very good."))
		return FALSE
	var/mob/living/carbon/human/victim = A
	if(owner.do_actions) //can't use if busy
		return FALSE
	if(!owner.Adjacent(victim)) //checks if owner next to target
		return FALSE
	if(victim.stat != DEAD)
		if(!silent)
			to_chat(owner, span_warning("This creature is struggling too much for us to devour it."))
		return FALSE
	if(HAS_TRAIT(victim, TRAIT_PSY_DRAINED))
		if(!silent)
			to_chat(owner, span_warning("There is no longer any life force in this creature!"))
		return FALSE
	if(victim.buckled)
		if(!silent)
			to_chat(owner, span_warning("[victim] is buckled to something."))
		return FALSE
	var/mob/living/carbon/xenomorph/X = owner
	if(X.on_fire)
		if(!silent)
			to_chat(X, span_warning("We're too busy being on fire to do this!"))
		return FALSE
	if(X.eaten_mob) //Only one thing in the stomach at a time, please
		if(!silent)
			to_chat(X, span_warning("We already have something in our stomach, there's no way that will fit."))
		return FALSE
	for(var/obj/effect/forcefield/fog in range(1, X))
		if(!silent)
			to_chat(X, span_warning("We are too close to the fog."))
		return FALSE
	X.face_atom(victim)
	X.visible_message(span_danger("[X] starts to devour [victim]!"), \
	span_danger("We start to devour [victim]!"), null, 5)

	succeed_activate()

/datum/action/ability/activable/xeno/cocoon/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/X = owner
	var/mob/living/carbon/human/victim = A
	var/channel = SSsounds.random_available_channel()
	playsound(X, 'sound/vore/struggle.ogg', 40, channel = channel)
	if(!do_after(X, 7 SECONDS, IGNORE_HELD_ITEM, victim, BUSY_ICON_DANGER, extra_checks = CALLBACK(owner, TYPE_PROC_REF(/mob, break_do_after_checks), list("health" = X.health))))
		to_chat(owner, span_warning("We stop devouring \the [victim]. They probably tasted gross anyways."))
		X.stop_sound_channel(channel)
		return fail_activate()
	if(HAS_TRAIT(victim, TRAIT_PSY_DRAINED))
		to_chat(owner, span_warning("Someone drained the life force of our victim before we could devour it!"))
		return fail_activate()
	owner.visible_message(span_warning("[X] devours [victim]!"), \
	span_warning("We devour [victim]!"), null, 5)
	to_chat(owner, span_warning("We will eject the cocoon in [cocoon_production_time / 10] seconds! Do not move until it is done."))
	X.eaten_mob = victim
	var/turf/starting_turf = get_turf(victim)
	victim.forceMove(X)
	X.do_jitter_animation()
	succeed_activate()
	channel = SSsounds.random_available_channel()
	playsound(X, 'sound/vore/escape.ogg', 40, channel = channel)
	if(!do_after(X, cocoon_production_time, IGNORE_HELD_ITEM, null, BUSY_ICON_DANGER))
		to_chat(owner, span_warning("We moved too soon and we will have to devour our victim again!"))
		X.eject_victim(FALSE, starting_turf)
		X.stop_sound_channel(channel)
		return fail_activate()
	victim.dead_ticks = 0
	ADD_TRAIT(victim, TRAIT_STASIS, TRAIT_STASIS)
	X.eject_victim(TRUE, starting_turf)
	if(owner.client)
		var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[owner.ckey]
		personal_statistics.cocooned++

/////////////////////////////////
// blessing Menu
/////////////////////////////////
/datum/action/ability/xeno_action/blessing_menu
	name = "Mothers Blessings"
	action_icon_state = "hivestore"
	action_icon = 'icons/Xeno/actions/construction.dmi' // TODO: fix it
	desc = "Ask the Queen Mother for blessings for your hive in exchange for psychic energy."
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_BLESSINGSMENU,
	)
	use_state_flags = ABILITY_USE_LYING|ABILITY_USE_CRESTED
	hidden = TRUE

/datum/action/ability/xeno_action/blessing_menu/action_activate()
	var/mob/living/carbon/xenomorph/X = owner
	X.hive.purchases.interact(X)
	return succeed_activate()

/////////////////////////////////
// pattern building
/////////////////////////////////

//Pattern Defines, for the radial menu.
#define CROSS_3X3 /datum/buildingpattern/cross3x3
#define SQUARE_2X2 /datum/buildingpattern/square2x2
#define SQUARE_3X3 /datum/buildingpattern/square3x3
#define HOLLOW_CROSS /datum/buildingpattern/hollow_cross3x3

//List of all images used for Patterns, in the radial selection menu
GLOBAL_LIST_INIT(pattern_images_list, list(
	CROSS_3X3 = image('icons/Xeno/patterns.dmi', icon_state = "cross3x3"),
	SQUARE_2X2 = image('icons/Xeno/patterns.dmi', icon_state = "square2x2"),
	SQUARE_3X3 = image('icons/Xeno/patterns.dmi', icon_state = "square3x3"),
	HOLLOW_CROSS = image('icons/Xeno/patterns.dmi', icon_state = "hollowcross3x3"),
))

/datum/action/ability/activable/xeno/place_pattern
	name = "Place Pattern"
	desc = "Place a pattern of hive walls."
	action_icon_state = "square2x2"
	action_icon = 'icons/Xeno/patterns.dmi'
	target_flags = ABILITY_TURF_TARGET
	gamemode_flags = ABILITY_NUCLEARWAR
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_PLACE_PATTERN,
		KEYBINDING_ALTERNATE = COMSIG_XENOABILITY_SELECT_PATTERN,
	)
	use_state_flags = ABILITY_USE_LYING
	var/datum/buildingpattern/selected_pattern = new /datum/buildingpattern/square2x2
	/// Holograms are used to show the pattern before placing it
	var/list/atom/holograms = list()
	/// timerid before we cleanup the holograms
	var/cleanup_timer
	/// how long a hologram lasts without movement
	var/cleanup_time = 4 SECONDS

/datum/action/ability/activable/xeno/place_pattern/alternate_action_activate()
	INVOKE_ASYNC(src, PROC_REF(select_pattern))

/datum/action/ability/activable/xeno/place_pattern/give_action(mob/living/L)
	. = ..()
	//if its not prep, remove the ability instantly
	if(!(SSmonitor.gamestate == SHUTTERS_CLOSED && CHECK_BITFIELD(SSticker.mode?.round_type_flags, MODE_ALLOW_XENO_QUICKBUILD) && SSresinshaping.active))
		remove_action(owner)
	RegisterSignals(SSdcs, list(COMSIG_GLOB_OPEN_SHUTTERS_EARLY, COMSIG_GLOB_OPEN_TIMED_SHUTTERS_LATE,COMSIG_GLOB_TADPOLE_LANDED_OUT_LZ,COMSIG_GLOB_TADPOLE_RAPPEL_DEPLOYED_OUT_LZ,COMSIG_GLOB_DROPPOD_LANDED), PROC_REF(toggle_off))

///Seperate proc that calls remove_action, to block any signal shenanigans.
/datum/action/ability/activable/xeno/place_pattern/proc/toggle_off()
	SIGNAL_HANDLER
	remove_action(owner)

/datum/action/ability/activable/xeno/place_pattern/remove_action(mob/living/L)
	. = ..()
	UnregisterSignal(SSdcs, list(COMSIG_GLOB_OPEN_SHUTTERS_EARLY, COMSIG_GLOB_OPEN_TIMED_SHUTTERS_LATE,COMSIG_GLOB_TADPOLE_LANDED_OUT_LZ,COMSIG_GLOB_TADPOLE_RAPPEL_DEPLOYED_OUT_LZ,COMSIG_GLOB_DROPPOD_LANDED))

/datum/action/ability/activable/xeno/place_pattern/on_selection()
	RegisterSignal(owner, COMSIG_ATOM_MOUSE_ENTERED, PROC_REF(show_hologram_call))

/datum/action/ability/activable/xeno/place_pattern/on_deselection()
	UnregisterSignal(owner, COMSIG_ATOM_MOUSE_ENTERED)
	cleanup_holograms()

// don't slow down the other signals
/datum/action/ability/activable/xeno/place_pattern/proc/show_hologram_call(mob/user, atom/target)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(show_hologram), user, target)

/// move or create a hologram on mousemove, and also start the cleanup timer and check turf validity
/datum/action/ability/activable/xeno/place_pattern/proc/show_hologram(mob/user, atom/target)
	SIGNAL_HANDLER
	var/list/target_turfs = get_target_turfs(target)
	if(!length(target_turfs))
		// no turfs? means the mouse is offscreen so we can cleanup
		cleanup_holograms()
		return
	var/index = 1
	var/create_new = length(holograms) != length(target_turfs)
	if(create_new)
		cleanup_holograms()
	for(var/turf/target_turf AS in target_turfs)
		if(create_new)
			create_hologram(target_turf)
		else
			move_hologram(target_turf, holograms[index])
		check_turf_validity(target_turf, holograms[index])
		index++
	start_cleanup_timer()

/// check if the turf is valid or not for the selected build type, and apply a matrix color if not
/datum/action/ability/activable/xeno/place_pattern/proc/check_turf_validity(turf/target_turf, obj/effect/hologram)
	var/datum/action/ability/activable/xeno/secrete_resin/secrete_resin = locate() in xeno_owner.actions
	if(!secrete_resin)
		return
	hologram.remove_filter("invalid_turf_filter")
	if(!secrete_resin.can_build_here(target_turf, TRUE))
		hologram.add_filter("invalid_turf_filter", 1, color_matrix_filter(rgb(233, 23, 23)))

/// creates the hologram and quickly fades it in, step_size is increased to make movement smoother
/datum/action/ability/activable/xeno/place_pattern/proc/create_hologram(turf/target_turf)
	var/atom/selected = xeno_owner.selected_resin
	var/obj/effect/build_hologram/hologram = new(target_turf, selected, FALSE, xeno_owner)
	hologram.alpha = 0
	hologram.layer = selected.layer + 1
	hologram.step_size = 4 * ICON_SIZE_ALL
	animate(hologram, 1 SECONDS, alpha = initial(hologram.alpha))
	holograms += hologram

/datum/action/ability/activable/xeno/place_pattern/proc/move_hologram(turf/target_turf, obj/effect/hologram)
	hologram.abstract_move(target_turf)

/datum/action/ability/activable/xeno/place_pattern/proc/start_cleanup_timer()
	delete_timer()
	cleanup_timer = addtimer(CALLBACK(src, PROC_REF(cleanup_holograms)), cleanup_time, TIMER_STOPPABLE)

/datum/action/ability/activable/xeno/place_pattern/proc/delete_timer()
	deltimer(cleanup_timer)
	cleanup_timer = null

/datum/action/ability/activable/xeno/place_pattern/proc/cleanup_holograms()
	delete_timer()
	QDEL_LIST(holograms)

///Selects the pattern from a radial menu
/datum/action/ability/activable/xeno/place_pattern/proc/select_pattern()
	var/pattern_choice = show_radial_menu(owner, owner, GLOB.pattern_images_list, radius = 48)
	if(!pattern_choice)
		return
	selected_pattern = new pattern_choice
	var/datum/buildingpattern/pattern = pattern_choice
	var/image/pattern_icon = GLOB.pattern_images_list[pattern_choice]
	action_icon_state = pattern_icon.icon_state
	update_button_icon()
	xeno_owner.balloon_alert(xeno_owner, pattern.overheadmsg)
	cleanup_holograms()

/datum/action/ability/activable/xeno/place_pattern/use_ability(atom/A)
	var/datum/action/ability/activable/xeno/secrete_resin/secrete_resin = locate() in xeno_owner.actions
	if(!istype(secrete_resin))
		xeno_owner.balloon_alert(xeno_owner, "secrete resin ability missing!")
		return FALSE
	var/list/target_turfs = get_target_turfs(A)
	if(!length(target_turfs))
		xeno_owner.balloon_alert(xeno_owner, "no valid ground found")
		return FALSE
	// check if one is successful, if none, we output a visible error
	var/success = FALSE
	for(var/turf/target_turf as anything in target_turfs)
		// if last tile without the rest having any successes, we inform the user of a error
		var/loud = !success && target_turfs.Find(target_turf) == length(target_turfs)
		if(secrete_resin.qb_build_resin(target_turf, silent = !loud))
			success = TRUE

/// gets turfs based on the current active pattern with the pattern offsets around the target atom
/datum/action/ability/activable/xeno/place_pattern/proc/get_target_turfs(atom/A)
	var/turf/sourceturf = get_turf(A)
	if(!sourceturf)
		return list()
	var/starty = sourceturf.y + selected_pattern.offset_y
	var/iterx
	var/startz = sourceturf.z
	var/turf/targetturf

	var/list/turfs = list()
	for(var/layer in selected_pattern.pattern)
		iterx = sourceturf.x + selected_pattern.offset_x
		for(var/tile in splittext(layer, ""))
			if(tile == "X")
				targetturf = locate(iterx, starty, startz)
				turfs += targetturf
			iterx = iterx - 1
		starty = starty + 1
	return turfs
