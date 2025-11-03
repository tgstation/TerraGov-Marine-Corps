// Defines for boiler globs. Their icon states, specifically. Also used to reference their typepaths and for the radials.
#define BOILER_GLOB_NEUROTOXIN "neurotoxin_glob"
#define BOILER_GLOB_NEUROTOXIN_LANCE "neurotoxin_glob_lance"
#define BOILER_GLOB_NEUROTOXIN_FAST "neurotoxin_glob_fast"
#define BOILER_GLOB_CORROSIVE "corrosive_glob"
#define BOILER_GLOB_CORROSIVE_LANCE "corrosive_glob_lance"
#define BOILER_GLOB_CORROSIVE_FAST "corrosive_glob_fast"
#define BOILER_GLOB_OZELOMELYN "ozelomelyn_glob"
#define BOILER_GLOB_HEMODILE "hemodile_glob"
#define BOILER_GLOB_SANGUINAL "sanguinal_glob"

/// List of globs, keyed by icon state. Used for radial selection.
GLOBAL_LIST_INIT(boiler_glob_list, list(
	BOILER_GLOB_NEUROTOXIN = /datum/ammo/xeno/boiler_gas,
	BOILER_GLOB_NEUROTOXIN_LANCE = /datum/ammo/xeno/boiler_gas/lance,
	BOILER_GLOB_NEUROTOXIN_FAST = /datum/ammo/xeno/boiler_gas/fast,
	BOILER_GLOB_CORROSIVE = /datum/ammo/xeno/boiler_gas/corrosive,
	BOILER_GLOB_CORROSIVE_LANCE = /datum/ammo/xeno/boiler_gas/corrosive/lance,
	BOILER_GLOB_CORROSIVE_FAST = /datum/ammo/xeno/boiler_gas/corrosive/fast,
	BOILER_GLOB_OZELOMELYN = /datum/ammo/xeno/boiler_gas/ozelomelyn,
	BOILER_GLOB_HEMODILE = /datum/ammo/xeno/boiler_gas/hemodile,
	BOILER_GLOB_SANGUINAL = /datum/ammo/xeno/boiler_gas/sanguinal
))

/// List of glob action button images, Used for radial selection.
GLOBAL_LIST_INIT(boiler_glob_image_list, list(
	BOILER_GLOB_NEUROTOXIN = image('icons/Xeno/actions/boiler.dmi', icon_state = BOILER_GLOB_NEUROTOXIN),
	BOILER_GLOB_NEUROTOXIN_LANCE = image('icons/Xeno/actions/boiler.dmi', icon_state = BOILER_GLOB_NEUROTOXIN_LANCE),
	BOILER_GLOB_NEUROTOXIN_FAST = image('icons/Xeno/actions/boiler.dmi', icon_state = BOILER_GLOB_NEUROTOXIN_FAST),
	BOILER_GLOB_CORROSIVE = image('icons/Xeno/actions/boiler.dmi', icon_state = BOILER_GLOB_CORROSIVE),
	BOILER_GLOB_CORROSIVE_LANCE = image('icons/Xeno/actions/boiler.dmi', icon_state = BOILER_GLOB_CORROSIVE_LANCE),
	BOILER_GLOB_CORROSIVE_FAST = image('icons/Xeno/actions/boiler.dmi', icon_state = BOILER_GLOB_CORROSIVE_FAST),
	BOILER_GLOB_OZELOMELYN = image('icons/Xeno/actions/boiler.dmi', icon_state = BOILER_GLOB_OZELOMELYN),
	BOILER_GLOB_HEMODILE = image('icons/Xeno/actions/boiler.dmi', icon_state = BOILER_GLOB_HEMODILE),
	BOILER_GLOB_SANGUINAL = image('icons/Xeno/actions/boiler.dmi', icon_state = BOILER_GLOB_SANGUINAL),
))

// ***************************************
// *********** Long range sight
// ***************************************

/datum/action/ability/xeno_action/toggle_long_range
	name = "Toggle Long Range Sight"
	action_icon_state = "toggle_long_range"
	action_icon = 'icons/Xeno/actions/boiler.dmi'
	desc = "Extend your sight off into the distance. Must remain stationary to use."
	ability_cost = 20
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_LONG_RANGE_SIGHT,
	)
	use_state_flags = ABILITY_USE_LYING
	/// The amount of decisecond it takes to finish using the ability.
	var/do_after_length = 1 SECONDS
	/// The offset in a direction for zoom_in.
	var/tile_offset = 7
	/// The size of the zoom for zoom_in.
	var/view_size = 4

/datum/action/ability/xeno_action/toggle_long_range/remove_action(mob/living/carbon/xenomorph/removed_from_xenomorph)
	if(xeno_owner.xeno_flags & XENO_ZOOMED)
		xeno_owner.zoom_out()
	return ..()

/datum/action/ability/xeno_action/toggle_long_range/bull
	tile_offset = 11
	view_size = 12

/datum/action/ability/xeno_action/toggle_long_range/action_activate()
	if(xeno_owner.xeno_flags & XENO_ZOOMED)
		xeno_owner.zoom_out()
		xeno_owner.visible_message(span_notice("[xeno_owner] stops looking off into the distance."), \
		span_notice("We stop looking off into the distance."), null, 5)
	else
		xeno_owner.visible_message(span_notice("[xeno_owner] starts looking off into the distance."), \
			span_notice("We start focusing your sight to look off into the distance."), null, 5)
		if(!do_after(xeno_owner, do_after_length, IGNORE_HELD_ITEM, null, BUSY_ICON_GENERIC) || (xeno_owner.xeno_flags & XENO_ZOOMED))
			return
		xeno_owner.zoom_in(tile_offset, view_size)
		..()

// ***************************************
// *********** Gas type toggle
// ***************************************

/datum/action/ability/xeno_action/toggle_bomb
	name = "Toggle Bombard Type"
	action_icon_state = "corrosive_glob"
	action_icon = 'icons/Xeno/actions/boiler.dmi'
	desc = "Switches Boiler Bombard type between available glob types."
	use_state_flags = ABILITY_USE_BUSY|ABILITY_USE_LYING
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_TOGGLE_BOMB,
		KEYBINDING_ALTERNATE = COMSIG_XENOABILITY_TOGGLE_BOMB_RADIAL,
	)
	/// A list of ammo that can be selected.
	var/list/datum/ammo/xeno/boiler_gas/selectable_glob_typepaths = list(
		/datum/ammo/xeno/boiler_gas,
		/datum/ammo/xeno/boiler_gas/corrosive
	)
	/// Should the default two glob typepaths be replaced with a faster verison?
	var/fast_gas = FALSE
	/// Should unique glob typepaths be added?
	var/unique_gas = FALSE

/datum/action/ability/xeno_action/toggle_bomb/give_action(mob/living/carbon/xenomorph/given_to_xenomorph)
	..()
	reset_selectable_glob_typepath_list()

/datum/action/ability/xeno_action/toggle_bomb/remove_action(mob/living/carbon/xenomorph/removed_from_xenomorph)
	selectable_glob_typepaths = initial(selectable_glob_typepaths)
	return ..()

/datum/action/ability/xeno_action/toggle_bomb/on_xeno_upgrade()
	. = ..()
	reset_selectable_glob_typepath_list()

/datum/action/ability/xeno_action/toggle_bomb/can_use_action(silent, override_flags, selecting)
	. = ..()
	if(!.)
		return FALSE
	if(!length(selectable_glob_typepaths))
		if(!silent)
			to_chat(xeno_owner, span_warning("We don't have any globs to choose!"))
		return FALSE

/datum/action/ability/xeno_action/toggle_bomb/action_activate()
	var/found_pos = selectable_glob_typepaths.Find(xeno_owner.ammo?.type)
	if(!found_pos)
		xeno_owner.ammo = GLOB.ammo_list[selectable_glob_typepaths[1]]
	else
		xeno_owner.ammo = GLOB.ammo_list[selectable_glob_typepaths[(found_pos % length(selectable_glob_typepaths)) + 1]]

	var/datum/ammo/xeno/boiler_gas/boiler_glob = xeno_owner.ammo
	to_chat(xeno_owner, span_notice(boiler_glob.select_text))
	update_button_icon()

/datum/action/ability/xeno_action/toggle_bomb/alternate_action_activate()
	. = COMSIG_KB_ACTIVATED
	if(!can_use_action())
		return
	if(length(selectable_glob_typepaths) > 2) // The choice to skip to a specific glob.
		INVOKE_ASYNC(src, PROC_REF(select_glob_radial))
		return
	action_activate()

/datum/action/ability/xeno_action/toggle_bomb/update_button_icon()
	var/datum/ammo/xeno/boiler_gas/boiler_glob = xeno_owner.ammo	//Should be safe as this always selects a ammo.
	action_icon_state = boiler_glob.icon_key
	return ..()

/// Opens a radial menu to select a glob in and sets current ammo to the selected result.
/datum/action/ability/xeno_action/toggle_bomb/proc/select_glob_radial()
	var/list/available_globs = list()
	for(var/datum/ammo/xeno/boiler_gas/glob_type AS in selectable_glob_typepaths)
		var/glob_image = GLOB.boiler_glob_image_list[initial(glob_type.icon_key)]
		if(!glob_image)
			continue
		available_globs[initial(glob_type.icon_key)] = glob_image

	var/glob_choice = show_radial_menu(owner, owner, available_globs, radius = 48)
	if(!glob_choice)
		return

	var/referenced_path = GLOB.boiler_glob_list[glob_choice]
	xeno_owner.ammo = GLOB.ammo_list[referenced_path]
	var/datum/ammo/xeno/boiler_gas/boiler_glob = xeno_owner.ammo
	to_chat(xeno_owner, span_notice(boiler_glob.select_text))
	update_button_icon()

/// Empties the glob typepath list and adds glob typepaths based on various factors.
/datum/action/ability/xeno_action/toggle_bomb/proc/reset_selectable_glob_typepath_list()
	selectable_glob_typepaths.Cut()
	if(!fast_gas)
		selectable_glob_typepaths += /datum/ammo/xeno/boiler_gas
		selectable_glob_typepaths += /datum/ammo/xeno/boiler_gas/corrosive
	else
		selectable_glob_typepaths += /datum/ammo/xeno/boiler_gas/fast
		selectable_glob_typepaths += /datum/ammo/xeno/boiler_gas/corrosive/fast
	if(unique_gas)
		selectable_glob_typepaths += /datum/ammo/xeno/boiler_gas/ozelomelyn
		selectable_glob_typepaths += /datum/ammo/xeno/boiler_gas/hemodile
		selectable_glob_typepaths += /datum/ammo/xeno/boiler_gas/sanguinal
	if(xeno_owner.upgrade == XENO_UPGRADE_PRIMO)
		selectable_glob_typepaths += /datum/ammo/xeno/boiler_gas/lance
		selectable_glob_typepaths += /datum/ammo/xeno/boiler_gas/corrosive/lance
	var/found_pos = selectable_glob_typepaths.Find(xeno_owner.ammo?.type)
	if(!found_pos)
		xeno_owner.ammo = GLOB.ammo_list[selectable_glob_typepaths[1]]
	else
		xeno_owner.ammo = GLOB.ammo_list[selectable_glob_typepaths[(found_pos % length(selectable_glob_typepaths)) + 1]]
	update_button_icon()

// ***************************************
// *********** Gas cloud bomb maker
// ***************************************

/datum/action/ability/xeno_action/create_boiler_bomb
	name = "Create Bomb"
	action_icon_state = "create_bomb"
	action_icon = 'icons/Xeno/actions/boiler.dmi'
	desc = "Creates a Boiler Bombard of the type currently selected."
	ability_cost = 200
	use_state_flags = ABILITY_USE_BUSY|ABILITY_USE_LYING
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_CREATE_BOMB,
	)

/datum/action/ability/xeno_action/create_boiler_bomb/give_action(mob/living/L)
	. = ..()
	var/mutable_appearance/neuroglob_maptext = mutable_appearance(icon = null, icon_state = null, layer = ACTION_LAYER_MAPTEXT)
	visual_references[VREF_MUTABLE_NEUROGLOB_COUNTER] = neuroglob_maptext
	neuroglob_maptext.pixel_x = 25
	neuroglob_maptext.pixel_y = -4
	neuroglob_maptext.maptext = MAPTEXT("<font color=yellow>[xeno_owner.neurotoxin_ammo]")

	var/mutable_appearance/corrosiveglob_maptext = mutable_appearance(icon = null, icon_state = null, layer = ACTION_LAYER_MAPTEXT)
	visual_references[VREF_MUTABLE_CORROSIVEGLOB_COUNTER] = corrosiveglob_maptext
	corrosiveglob_maptext.pixel_x = 25
	corrosiveglob_maptext.pixel_y = 8
	corrosiveglob_maptext.maptext = MAPTEXT("<font color=green>[xeno_owner.corrosive_ammo]")

/datum/action/ability/xeno_action/create_boiler_bomb/can_use_action(silent, override_flags, selecting)
	. = ..()
	if(!.)
		return FALSE
	if(xeno_owner.xeno_flags & XENO_ZOOMED)
		if(!silent)
			xeno_owner.balloon_alert(xeno_owner, "can't while zoomed in!")
		return FALSE
	if(!xeno_owner.ammo)
		if(!silent)
			xeno_owner.balloon_alert(xeno_owner, "globule not selected!")
		return FALSE
	var/current_ammo = xeno_owner.corrosive_ammo + xeno_owner.neurotoxin_ammo
	if(current_ammo >= xeno_owner.xeno_caste.max_ammo)
		if(!silent)
			xeno_owner.balloon_alert(xeno_owner, "globule storage full!")
		return FALSE

/datum/action/ability/xeno_action/create_boiler_bomb/action_activate()
	var/unique_glob = TRUE
	switch(xeno_owner.ammo.type)
		if(/datum/ammo/xeno/boiler_gas/corrosive, /datum/ammo/xeno/boiler_gas/corrosive/lance, /datum/ammo/xeno/boiler_gas/corrosive/fast)
			unique_glob = FALSE
			xeno_owner.corrosive_ammo++
			xeno_owner.balloon_alert(xeno_owner, "corrosive globule prepared")
		if(/datum/ammo/xeno/boiler_gas, /datum/ammo/xeno/boiler_gas/lance, /datum/ammo/xeno/boiler_gas/fast)
			unique_glob = FALSE
			xeno_owner.neurotoxin_ammo++
			xeno_owner.balloon_alert(xeno_owner, "neurotoxin globule prepared")
	if(unique_glob)
		if(xeno_owner.corrosive_ammo > xeno_owner.neurotoxin_ammo)
			xeno_owner.neurotoxin_ammo++
			xeno_owner.balloon_alert(xeno_owner, "neurotoxin globule prepared")
		else
			xeno_owner.corrosive_ammo++
			xeno_owner.balloon_alert(xeno_owner, "corrosive globule prepared")
	xeno_owner.update_ammo_glow()
	update_button_icon()
	succeed_activate()

/datum/action/ability/xeno_action/create_boiler_bomb/update_button_icon()
	desc = "[initial(desc)] Reduces bombard cooldown by [BOILER_BOMBARD_COOLDOWN_REDUCTION / 10] seconds for each stored. Begins to emit light when surpassing [xeno_owner.glob_luminosity_threshold] globs stored."

	button.cut_overlay(visual_references[VREF_MUTABLE_CORROSIVEGLOB_COUNTER])
	var/mutable_appearance/corrosiveglobnumber = visual_references[VREF_MUTABLE_CORROSIVEGLOB_COUNTER]
	corrosiveglobnumber.maptext = MAPTEXT("<font color=green>[xeno_owner.corrosive_ammo]")
	button.add_overlay(visual_references[VREF_MUTABLE_CORROSIVEGLOB_COUNTER])

	button.cut_overlay(visual_references[VREF_MUTABLE_NEUROGLOB_COUNTER])
	var/mutable_appearance/neuroglobnumber = visual_references[VREF_MUTABLE_NEUROGLOB_COUNTER]
	neuroglobnumber.maptext = MAPTEXT("<font color=yellow>[xeno_owner.neurotoxin_ammo]")
	button.add_overlay(visual_references[VREF_MUTABLE_NEUROGLOB_COUNTER])
	return ..()

// ***************************************
// *********** Gas cloud bombs
// ***************************************
/datum/action/ability/activable/xeno/bombard
	name = "Bombard"
	action_icon_state = "bombard"
	action_icon = 'icons/Xeno/actions/boiler.dmi'
	desc = "Dig yourself into place in order to launch a glob of gas."
	cooldown_duration = 32 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_BOMBARD,
	)
	target_flags = ABILITY_TURF_TARGET
	/// To prepare the ability, the amount of deciseconds the owner must remain still.
	var/prepare_length = 3 SECONDS
	/// After preparation, the amount of deciseconds the owner must wait until the glob of gas is launched upon target selection.
	var/fire_length = 2 SECONDS
	/// How much should the cooldown be multiplied by if a fast glob variant was used?
	var/fast_cooldown_multiplier = 1
	/// If a non-corrosive / non-neurotoxin glob is launched, how much stored corrosive / neurotoxin globs is required/consumed?
	var/special_glob_required = 0
	/// Additional max range applied to all globs of gas.
	var/bonus_max_range = 0

/datum/action/ability/activable/xeno/bombard/get_cooldown()
	var/cooldown = cooldown_duration - ((xeno_owner.neurotoxin_ammo + xeno_owner.corrosive_ammo) * BOILER_BOMBARD_COOLDOWN_REDUCTION)
	if(istype(xeno_owner.ammo, /datum/ammo/xeno/boiler_gas/fast) || istype(xeno_owner.ammo, /datum/ammo/xeno/boiler_gas/corrosive/fast))
		cooldown *= fast_cooldown_multiplier
	return cooldown

/datum/action/ability/activable/xeno/bombard/on_cooldown_finish()
	to_chat(owner, span_notice("We feel our toxin glands swell. We are able to bombard an area again."))
	if(xeno_owner.selected_ability == src)
		xeno_owner.set_bombard_pointer()
	return ..()

/datum/action/ability/activable/xeno/bombard/on_selection()
	var/current_ammo = xeno_owner.corrosive_ammo + xeno_owner.neurotoxin_ammo
	if(current_ammo <= 0)
		to_chat(xeno_owner, span_notice("We have nothing prepared to fire."))
		return FALSE

	xeno_owner.visible_message(span_notice("\The [xeno_owner] begins digging their claws into the ground."), \
	span_notice("We begin digging ourselves into place."), null, 5)
	if(!do_after(xeno_owner, prepare_length, FALSE, null, BUSY_ICON_HOSTILE))
		on_deselection()
		xeno_owner.selected_ability = null
		xeno_owner.update_action_button_icons()
		xeno_owner.reset_bombard_pointer()
		return FALSE

	xeno_owner.visible_message(span_notice("\The [xeno_owner] digs itself into the ground!"), \
		span_notice("We dig ourselves into place! If we move, we must wait again to fire."), null, 5)
	xeno_owner.set_bombard_pointer()
	RegisterSignal(owner, COMSIG_MOB_ATTACK_RANGED, TYPE_PROC_REF(/datum/action/ability/activable/xeno/bombard, on_ranged_attack))

/datum/action/ability/activable/xeno/bombard/on_deselection()
	if(xeno_owner?.selected_ability == src)
		xeno_owner.reset_bombard_pointer()
		to_chat(xeno_owner, span_notice("We relax our stance."))
	UnregisterSignal(owner, COMSIG_MOB_ATTACK_RANGED)

/datum/action/ability/activable/xeno/bombard/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(!xeno_owner.ammo)
		if(!silent)
			xeno_owner.balloon_alert(xeno_owner, "globule not selected!")
		return FALSE
	var/unique_glob = TRUE
	switch(xeno_owner.ammo.type)
		if(/datum/ammo/xeno/boiler_gas/corrosive, /datum/ammo/xeno/boiler_gas/corrosive/lance, /datum/ammo/xeno/boiler_gas/corrosive/fast)
			unique_glob = FALSE
			if(xeno_owner.corrosive_ammo <= 0)
				if(!silent)
					xeno_owner.balloon_alert(xeno_owner, "no corrosive globules!")
				return FALSE
		if(/datum/ammo/xeno/boiler_gas, /datum/ammo/xeno/boiler_gas/lance, /datum/ammo/xeno/boiler_gas/fast)
			unique_glob = FALSE
			if(xeno_owner.neurotoxin_ammo <= 0)
				if(!silent)
					xeno_owner.balloon_alert(xeno_owner, "no neurotoxin globules!")
				return FALSE
	var/total_globs = xeno_owner.corrosive_ammo + xeno_owner.neurotoxin_ammo
	if(unique_glob && special_glob_required > total_globs)
		if(!silent)
			xeno_owner.balloon_alert(xeno_owner, "not enough globules!")
		return FALSE

	var/turf/T = get_turf(A)
	var/turf/S = get_turf(owner)
	if(!isturf(T) || !(T.z in SSmapping.get_connected_levels(S.z)))
		if(!silent)
			xeno_owner.balloon_alert(xeno_owner, "invalid target!")
		return FALSE

/datum/action/ability/activable/xeno/bombard/use_ability(atom/A)
	var/turf/target = get_turf(A)

	if(!istype(target))
		return

	to_chat(xeno_owner, span_xenonotice("We begin building up pressure."))

	if(!do_after(xeno_owner, fire_length, IGNORE_HELD_ITEM, target, BUSY_ICON_DANGER))
		to_chat(xeno_owner, span_warning("We decide not to launch."))
		return fail_activate()

	if(!can_use_ability(target, FALSE, ABILITY_IGNORE_PLASMA))
		return fail_activate()

	xeno_owner.visible_message(span_xenowarning("\The [xeno_owner] launches a huge glob of gas hurling into the distance!"), \
	span_xenowarning("We launch a huge glob of gas hurling into the distance!"), null, 5)

	var/atom/movable/projectile/P = new /atom/movable/projectile(xeno_owner.loc)
	P.generate_bullet(xeno_owner.ammo)
	P.proj_max_range += bonus_max_range
	P.fire_at(target, xeno_owner, xeno_owner, xeno_owner.ammo.max_range + bonus_max_range, xeno_owner.ammo.shell_speed)
	playsound(xeno_owner, 'sound/effects/blobattack.ogg', 25, 1)

	var/unique_glob = TRUE
	switch(xeno_owner.ammo.type)
		if(/datum/ammo/xeno/boiler_gas/corrosive, /datum/ammo/xeno/boiler_gas/corrosive/lance, /datum/ammo/xeno/boiler_gas/corrosive/fast)
			unique_glob = FALSE
			GLOB.round_statistics.boiler_acid_smokes++
			SSblackbox.record_feedback("tally", "round_statistics", 1, "boiler_acid_smokes")
			xeno_owner.corrosive_ammo--
		if(/datum/ammo/xeno/boiler_gas, /datum/ammo/xeno/boiler_gas/lance, /datum/ammo/xeno/boiler_gas/fast)
			unique_glob = FALSE
			GLOB.round_statistics.boiler_neuro_smokes++
			SSblackbox.record_feedback("tally", "round_statistics", 1, "boiler_neuro_smokes")
			xeno_owner.neurotoxin_ammo--
	if(unique_glob)
		var/remaining_globs_to_remove = special_glob_required
		while(remaining_globs_to_remove > 0)
			remaining_globs_to_remove--
			if(xeno_owner.neurotoxin_ammo > xeno_owner.corrosive_ammo)
				xeno_owner.neurotoxin_ammo--
				continue
			xeno_owner.corrosive_ammo--
	owner.record_war_crime()

	xeno_owner.update_ammo_glow()
	update_button_icon()
	add_cooldown()

/datum/action/ability/activable/xeno/bombard/clean_action()
	xeno_owner.reset_bombard_pointer()
	return ..()

/// Signal proc for clicking at a distance
/datum/action/ability/activable/xeno/bombard/proc/on_ranged_attack(mob/living/carbon/xenomorph/xeno_owner, atom/A, params)
	SIGNAL_HANDLER
	if(can_use_ability(A, TRUE))
		INVOKE_ASYNC(src, PROC_REF(use_ability), A)

/mob/living/carbon/xenomorph/boiler/Moved(atom/OldLoc,Dir)
	. = ..()
	if(selected_ability?.type == /datum/action/ability/activable/xeno/bombard)
		var/datum/action/ability/activable/bomb = actions_by_path[/datum/action/ability/activable/xeno/bombard]
		bomb.on_deselection()
		selected_ability.button.icon_state = "template"
		selected_ability = null
		update_action_button_icons()

/// Set the boiler's mouse cursor to the green firing cursor.
/mob/living/carbon/xenomorph/proc/set_bombard_pointer() //todo:roll into ability
	if(client)
		client.mouse_pointer_icon = 'icons/mecha/mecha_mouse.dmi'

/// Resets the boiler's mouse cursor to the default cursor.
/mob/living/carbon/xenomorph/proc/reset_bombard_pointer() //todo:roll into ability
	if(client)
		client.mouse_pointer_icon = initial(client.mouse_pointer_icon)

// ***************************************
// *********** Acid spray
// ***************************************
/datum/action/ability/activable/xeno/spray_acid/line/boiler
	cooldown_duration = 9 SECONDS

/datum/action/ability/activable/xeno/acid_shroud
	name = "Acid Shroud"
	action_icon_state = "acid_shroud"
	action_icon = 'icons/Xeno/actions/boiler.dmi'
	desc = "Create a smokescreen of gas, setting your Bombard on a longer cooldown. Does not require or consume a reserved globule."
	ability_cost = 200
	cooldown_duration = 32 SECONDS // 32 is the default Bombard cooldown.
	use_state_flags = ABILITY_USE_BUSY|ABILITY_USE_LYING
	keybind_flags = ABILITY_KEYBIND_USE_ABILITY | ABILITY_IGNORE_SELECTED_ABILITY
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_ACID_SHROUD,
		KEYBINDING_ALTERNATE = COMSIG_XENOABILITY_ACID_SHROUD_SELECT,
	)

/datum/action/ability/activable/xeno/acid_shroud/use_ability(atom/A)
	var/datum/effect_system/smoke_spread/emitted_gas //The gas that will emit when the ability activates, can be either acid or neuro.

	if(istype(xeno_owner.ammo, /datum/ammo/xeno/boiler_gas/corrosive))
		emitted_gas = new /datum/effect_system/smoke_spread/xeno/acid/opaque(xeno_owner)
	else
		emitted_gas = new /datum/effect_system/smoke_spread/xeno/neuro(xeno_owner)

	emitted_gas.set_up(2, get_turf(xeno_owner))
	emitted_gas.start()
	succeed_activate()
	add_cooldown()
	var/datum/action/ability/activable/xeno/bombard/bombard_action = xeno_owner.actions_by_path[/datum/action/ability/activable/xeno/bombard]
	if(bombard_action)
		if(bombard_action.cooldown_timer) //You need to clear a cooldown to add another, so that is done here.
			deltimer(bombard_action.cooldown_timer)
			bombard_action.cooldown_timer = null
			bombard_action.countdown.stop()
		bombard_action.add_cooldown(bombard_action.get_cooldown() + 8.5 SECONDS) // The cooldown of Bombard that is added when this ability is used.

// ***************************************
// *********** Steam Rush
// ***************************************

/datum/action/ability/xeno_action/steam_rush
	name = "Steam Rush"
	action_icon_state = "steam_rush"
	action_icon = 'icons/Xeno/actions/boiler.dmi'
	desc = "Gain a short-lived speed boost. Slashes deal extra burn damage and extends the duration of the speed boost."
	ability_cost = 100
	cooldown_duration = 25 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_STEAM_RUSH,
	)
	/// Holds the particles instead of the mob.
	var/obj/effect/abstract/particle_holder/particle_holder
	/// Is the ability currently being used?
	var/active = FALSE
	/// The increase of speed when ability is active.
	var/speed_buff = -1
	/// How long the ability will last?
	var/duration = 1.5 SECONDS
	/// Timer for steam rush's duration.
	var/steam_rush_duration
	/// How much extra burn damage is dealt on slash?
	var/steam_damage = 10
	/// The duration in deciseconds in which a trail of opaque gas will last.
	var/gas_trail_duration = 0

/datum/action/ability/xeno_action/steam_rush/action_activate()
	var/mob/living/carbon/xenomorph/boiler/sizzler/X = xeno_owner

	if(active)
		to_chat(X, span_xenodanger("Our body is already spewing steam!"))
		return

	X.emote("roar")
	X.visible_message(span_danger("[X]'s body starts to hiss with steam!"), \
	span_xenowarning("We feel steam spraying from our body!"))

	active = TRUE

	steam_rush_duration = addtimer(CALLBACK(src, PROC_REF(steam_rush_deactivate)), duration, TIMER_UNIQUE|TIMER_STOPPABLE|TIMER_OVERRIDE)

	X.add_movespeed_modifier(MOVESPEED_ID_BOILER_SIZZLER_STEAM_RUSH, TRUE, 0, NONE, TRUE, speed_buff)

	particle_holder = new(owner, /particles/sizzler_steam)
	particle_holder.pixel_y = -8
	particle_holder.pixel_x = 10

	RegisterSignal(X, COMSIG_XENOMORPH_ATTACK_LIVING, PROC_REF(steam_slash))
	if(gas_trail_duration)
		RegisterSignal(xeno_owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_movement))

	succeed_activate()
	add_cooldown()

///Adds burn damage and resets timer during steam rush buff
/datum/action/ability/xeno_action/steam_rush/proc/steam_slash(datum/source, mob/living/target, damage, list/damage_mod, list/armor_mod)
	SIGNAL_HANDLER
	var/mob/living/rusher = owner
	var/datum/action/ability/xeno_action/steam_rush/steam_rush_ability = rusher.actions_by_path[/datum/action/ability/xeno_action/steam_rush]
	var/mob/living/carbon/carbon_target = target

	carbon_target.apply_damage(steam_damage, damagetype = BURN, blocked = ACID, attacker = owner)
	playsound(carbon_target, 'sound/voice/alien/hiss2.ogg', 25)
	to_chat(carbon_target, span_danger("You are burned by the hot steam!")) //I'm just going to operate under the assumption that xvx combat will never be a meaningful thing.

	if(steam_rush_ability.steam_rush_duration)
		deltimer(steam_rush_ability.steam_rush_duration)
		steam_rush_ability.steam_rush_duration = addtimer(CALLBACK(src, PROC_REF(steam_rush_deactivate)), duration + 1 SECONDS, TIMER_UNIQUE|TIMER_STOPPABLE|TIMER_OVERRIDE)

///Called when we want to end the steam rush ability
/datum/action/ability/xeno_action/steam_rush/proc/steam_rush_deactivate()
	if(QDELETED(owner))
		return
	var/mob/living/carbon/xenomorph/X = owner

	X.remove_movespeed_modifier(MOVESPEED_ID_BOILER_SIZZLER_STEAM_RUSH)

	X.playsound_local(X, 'sound/voice/alien/hiss2.ogg', 50)

	active = FALSE
	QDEL_NULL(particle_holder)
	UnregisterSignal(X, COMSIG_XENOMORPH_ATTACK_LIVING)
	if(gas_trail_duration)
		UnregisterSignal(xeno_owner, COMSIG_MOVABLE_MOVED)

/// Creates a trail of acid smoke when moving.
/datum/action/ability/xeno_action/steam_rush/proc/on_movement(datum/source, atom/old_loc, movement_dir, forced, list/old_locs)
	if(xeno_owner.stat != CONSCIOUS)
		return
	var/datum/effect_system/smoke_spread/xeno/acid/opaque/smoke = new()
	smoke.set_up(0, get_turf(xeno_owner), gas_trail_duration / (2 SECONDS))
	smoke.start()

/datum/action/ability/xeno_action/steam_rush/on_cooldown_finish()
	owner.balloon_alert(owner, "steam rush ready")
	owner.playsound_local(owner, 'sound/effects/alien/new_larva.ogg', 25, 0, 1)
	return ..()

/particles/sizzler_steam
	icon = 'icons/effects/particles/smoke.dmi'
	icon_state = list("steam_1" = 1, "steam_2" = 1, "steam_3" = 2)
	width = 100
	height = 300
	count = 50
	spawning = 3
	lifespan = 1.5 SECONDS
	fade = 3 SECONDS
	velocity = list(0, 0.3, 0)
	position = list(5, 32, 0)
	drift = generator(GEN_SPHERE, 0, 1, NORMAL_RAND)
	friction = 0.1
	gravity = list(0, 0.95)
	grow = 0.1

// ***************************************
// *********** Smokescreen Spit
// ***************************************

/datum/action/ability/xeno_action/smokescreen_spit
	name = "Smokescreen Spit"
	action_icon_state = "corrosive_glob"
	action_icon = 'icons/Xeno/actions/boiler.dmi'
	desc = "Empower your next spit, causing it to create a wide smokescreen."
	ability_cost = 350
	cooldown_duration = 30 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_SMOKESCREEN_SPIT,
	)
	use_state_flags = ABILITY_USE_STAGGERED
/// Timer for the window you have to fire smokescreen spit.
	var/smokescreen_spit_window
	/// Duration of the window you have to fire smokescreen spit.
	var/window_duration = 1.5 SECONDS
	/// The ammo type to change the owner's ammo to when activated.
	var/datum/ammo/xeno/ammo_type = /datum/ammo/xeno/acid/airburst/heavy

/datum/action/ability/xeno_action/smokescreen_spit/action_activate()
	var/mob/living/carbon/xenomorph/boiler/sizzler/X = owner

	X.ammo = ammo_type
	X.update_spits(TRUE)
	X.balloon_alert(owner, "smokescreen prepared")

	smokescreen_spit_window = addtimer(CALLBACK(src, PROC_REF(smokescreen_spit_deactivate)), window_duration, TIMER_UNIQUE)

	succeed_activate()
	add_cooldown()

///Called when smokescreen ability ends to reset our ammo
/datum/action/ability/xeno_action/smokescreen_spit/proc/smokescreen_spit_deactivate()
	if(QDELETED(owner))
		return
	var/mob/living/carbon/xenomorph/boiler/sizzler/X = owner

	X.ammo = null // update_spits() will reselect their ammo.
	X.update_spits(TRUE)
	X.balloon_alert(owner, "spit back to normal")

// ***************************************
// *********** High-Pressure Spit
// ***************************************
/datum/action/ability/activable/xeno/high_pressure_spit
	name = "High-Pressure Spit"
	action_icon_state = "corrosive_lance_glob"
	action_icon = 'icons/Xeno/actions/boiler.dmi'
	desc = "Fire a high pressure glob of acid that knocks back, stuns, and shatters the target."
	ability_cost = 150
	cooldown_duration = 25 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_HIGH_PRESSURE_SPIT,
	)

/datum/action/ability/activable/xeno/high_pressure_spit/use_ability(atom/target)
	var/mob/living/carbon/xenomorph/X = owner

	new /obj/effect/temp_visual/wraith_warp(get_turf(owner))

	if(!do_after(X, 1 SECONDS, NONE, target, BUSY_ICON_DANGER))
		return fail_activate()

	playsound(X.loc, 'sound/voice/alien/hiss2.ogg', 50, 1)

	var/datum/ammo/xeno/acid/heavy/high_pressure_spit/high_pressure_spit = GLOB.ammo_list[/datum/ammo/xeno/acid/heavy/high_pressure_spit]

	var/atom/movable/projectile/newspit = new(get_turf(X))
	newspit.generate_bullet(high_pressure_spit)
	newspit.def_zone = X.get_limbzone_target()

	newspit.fire_at(target, X, X, newspit.ammo.max_range)

	succeed_activate()
	add_cooldown()

/datum/action/ability/activable/xeno/high_pressure_spit/on_cooldown_finish()
	owner.balloon_alert(owner, "high-pressure spit ready")
	owner.playsound_local(owner, 'sound/voice/alien/hiss2.ogg', 25, 0, 1)
	return ..()
