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
	name = "Toggle Steam Rush"
	action_icon_state = "steam_rush"
	action_icon = 'icons/Xeno/actions/boiler.dmi'
	desc = "Gain a speed and damage boost while draining plasma. Slashes grant stacks which increase speed and damage. Creates smoke when at max stacks."
	ability_cost = 25
	cooldown_duration = 15 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_STEAM_RUSH,
	)
	/// Holds the particles instead of the mob.
	var/obj/effect/abstract/particle_holder/particle_holder
	///A reference to the VREF used to display the current stacks of steam rush.
	var/vref = VREF_MUTABLE_STEAMRUSH_STACKS
	/// Is the ability currently being used?
	var/active = FALSE
	/// The base increase of speed when ability is active.
	var/base_speed_buff = -0.3
	/// The per stack increase of speed when ability is active.
	var/stack_speed_buff = -0.03
	/// How often we consume plasma while active.
	var/steam_check_interval = 0.5 SECONDS
	/// Timer for checking steam rush upkeep.
	var/steam_rush_duration
	/// How much extra burn damage is dealt on slash, per stack.
	var/steam_damage = 1
	/// Current stacks of steam rush. Higher stacks increase the buffs. Slashing enemies increases stacks. Max 10.
	var/stacks = 0

/datum/action/ability/xeno_action/steam_rush/can_use_action(silent, override_flags, selecting)
	if(active)
		return TRUE
	return ..()

/datum/action/ability/xeno_action/steam_rush/give_action(mob/living/L)
	. = ..()
	var/mutable_appearance/counter_maptext = mutable_appearance(icon = null, icon_state = null, layer = ACTION_LAYER_MAPTEXT)
	counter_maptext.pixel_x = 16
	counter_maptext.pixel_y = 16
	counter_maptext.maptext = MAPTEXT("[stacks]")
	visual_references[vref] = counter_maptext

/datum/action/ability/xeno_action/steam_rush/remove_action(mob/living/carbon/xenomorph/X)
	. = ..()
	button.cut_overlay(visual_references[vref])
	visual_references[vref] = null

/datum/action/ability/xeno_action/steam_rush/action_activate()
	if(active)
		deactivate_steam_rush()
	else
		activate_steam_rush()

/// Toggles steam rush on.
/datum/action/ability/xeno_action/steam_rush/proc/activate_steam_rush()
	active = TRUE

	xeno_owner.emote("roar")
	xeno_owner.visible_message(span_danger("[xeno_owner]'s body starts to hiss with steam!"), \
	span_xenowarning("We feel steam spraying from our body!"))

	xeno_owner.add_movespeed_modifier(MOVESPEED_ID_BOILER_SIZZLER_STEAM_RUSH, TRUE, 0, NONE, TRUE, base_speed_buff)

	particle_holder = new(owner, /particles/sizzler_steam)
	particle_holder.pixel_y = -8
	particle_holder.pixel_x = 10

	RegisterSignal(xeno_owner, COMSIG_XENOMORPH_ATTACK_LIVING, PROC_REF(steam_slash))

	manage_steam_rush()

/// Handles plasma drain and upkeep of steam rush.
/datum/action/ability/xeno_action/steam_rush/proc/manage_steam_rush()
	if(xeno_owner.plasma_stored < ability_cost)
		return deactivate_steam_rush()
	xeno_owner.use_plasma(ability_cost)
	steam_rush_duration = addtimer(CALLBACK(src, PROC_REF(manage_steam_rush)), steam_check_interval, TIMER_UNIQUE|TIMER_STOPPABLE|TIMER_OVERRIDE)

/// On hit proc for steam rush slashes. Slashing increases stacks, stacks provide damage and speed buffs.
/datum/action/ability/xeno_action/steam_rush/proc/steam_slash(datum/source, mob/living/target, damage, list/damage_mod, list/armor_mod)
	SIGNAL_HANDLER
	var/mob/living/carbon/carbon_target = target

	carbon_target.apply_damage(steam_damage * stacks, damagetype = BURN, blocked = ACID)
	xenomorph_spray(get_turf(carbon_target), 5 SECONDS, steam_damage * stacks)
	playsound(carbon_target, 'sound/voice/alien/hiss2.ogg', 25)
	to_chat(carbon_target, span_danger("You are burned by the hot steam!")) //I'm just going to operate under the assumption that xvx combat will never be a meaningful thing.

	switch(stacks)
		if(0 to 8)
			stacks++
			update_button_icon()
		if(9)
			stacks++
			update_button_icon()
			QDEL_NULL(particle_holder)
			particle_holder = new(owner, /particles/sizzler_steam/intense)
			particle_holder.pixel_y = -8
			particle_holder.pixel_x = 10
			xeno_owner.visible_message(span_danger("[xeno_owner]'s body is spewing steam intensely!"), \
			span_xenowarning("Our steam reaches max intensity!"))
		if(10)
			var/datum/effect_system/smoke_spread/smoke = new /datum/effect_system/smoke_spread/xeno/acid/light()
			playsound(carbon_target, 'sound/effects/smoke.ogg', 10, 1, 2)
			smoke.set_up(0, carbon_target)
			smoke.start()

	xeno_owner.add_movespeed_modifier(MOVESPEED_ID_BOILER_SIZZLER_STEAM_RUSH, TRUE, 0, NONE, TRUE, (base_speed_buff + (stack_speed_buff * stacks)))

/// Toggles steam rush off, removing buffs and putting the ability on cooldown.
/datum/action/ability/xeno_action/steam_rush/proc/deactivate_steam_rush()
	xeno_owner.remove_movespeed_modifier(MOVESPEED_ID_BOILER_SIZZLER_STEAM_RUSH)
	xeno_owner.playsound_local(xeno_owner, 'sound/voice/alien/hiss2.ogg', 50)
	deltimer(steam_rush_duration)
	steam_rush_duration = null
	active = FALSE
	stacks = 0
	update_button_icon()
	QDEL_NULL(particle_holder)
	UnregisterSignal(xeno_owner, COMSIG_XENOMORPH_ATTACK_LIVING)
	add_cooldown()

/datum/action/ability/xeno_action/steam_rush/on_cooldown_finish()
	owner.balloon_alert(owner, "steam rush ready")
	owner.playsound_local(owner, 'sound/effects/alien/new_larva.ogg', 25, 0, 1)
	return ..()

/datum/action/ability/xeno_action/steam_rush/update_button_icon()
	button.cut_overlay(visual_references[vref])
	if(stacks)
		var/mutable_appearance/number = visual_references[vref]
		number.maptext = MAPTEXT("[stacks]")
		visual_references[vref] = number
		button.add_overlay(visual_references[vref])
	return ..()

/datum/action/ability/xeno_action/steam_rush/ai_should_start_consider()
	return TRUE

/datum/action/ability/xeno_action/steam_rush/ai_should_use(atom/target)
	if(active)
		if(!iscarbon(target))
			return TRUE
		return FALSE
	if(!iscarbon(target))
		return FALSE
	if(!line_of_sight(owner, target, 7))
		return FALSE
	if(!can_use_action(override_flags = ABILITY_IGNORE_SELECTED_ABILITY))
		return FALSE
	if(target.get_xeno_hivenumber() == owner.get_xeno_hivenumber())
		return FALSE
	return TRUE

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

/particles/sizzler_steam/intense
	count = 300
	spawning = 18
	drift = generator(GEN_SPHERE, 0, 2, NORMAL_RAND)

// ***************************************
// *********** Smokescreen Spit
// ***************************************

/datum/action/ability/activable/xeno/smokescreen_spit
	name = "Smokescreen Spit"
	action_icon_state = "corrosive_glob"
	action_icon = 'icons/Xeno/actions/boiler.dmi'
	desc = "Spit a steam smokescreen to cover your advance or retreat. Direct hits stagger and slow."
	ability_cost = 350
	cooldown_duration = 75 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_SMOKESCREEN_SPIT,
	)
	/// The amount of time for the do_after.
	var/cast_time = 3 SECONDS
	/// The ammo type the ability fires.
	var/datum/ammo/xeno/ammo_type = /datum/ammo/xeno/acid/smokescreen
	/// Timer for increasing light range while channeling.
	var/channel_light_timer
	/// Current light range while channeling.
	var/light_range = 0

/datum/action/ability/activable/xeno/smokescreen_spit/use_ability(atom/target)
	manage_channel_glow(TRUE)
	if(cast_time > 0 && !do_after(xeno_owner, cast_time, NONE, xeno_owner, BUSY_ICON_DANGER))
		manage_channel_glow(FALSE)
		add_cooldown(15 SECONDS) // Short cooldown on fail
		return fail_activate()

	var/atom/movable/projectile/newspit = new /atom/movable/projectile(get_turf(xeno_owner))
	newspit.generate_bullet(ammo_type)
	newspit.def_zone = xeno_owner.get_limbzone_target()

	newspit.fire_at(target, xeno_owner, xeno_owner, newspit.ammo.max_range)
	manage_channel_glow(FALSE)
	succeed_activate()
	add_cooldown()

/// Turns on/off the light glow while channeling the spit and increases the light range every half second.
/datum/action/ability/activable/xeno/smokescreen_spit/proc/manage_channel_glow(continue_light = FALSE)
	if(!continue_light)
		light_range = 0
		if(xeno_owner)
			xeno_owner.set_light_on(FALSE)
			xeno_owner.set_light_range_power_color(0, 0)
		deltimer(channel_light_timer)
		return
	if(light_range < 6)
		light_range += 1
	xeno_owner.set_light_on(TRUE)
	xeno_owner.set_light_range_power_color(light_range, 4, BOILER_LUMINOSITY_BASE_COLOR)
	channel_light_timer = addtimer(CALLBACK(src, PROC_REF(manage_channel_glow), TRUE), 0.5 SECONDS, TIMER_STOPPABLE)

/datum/action/ability/activable/xeno/smokescreen_spit/ai_should_start_consider()
	return TRUE

/datum/action/ability/activable/xeno/smokescreen_spit/ai_should_use(atom/target)
	if(!iscarbon(target))
		return FALSE
	if(get_dist(target, owner) < 5 || get_dist(target, owner) > 13)
		return FALSE
	if(!can_use_ability(target, override_flags = ABILITY_IGNORE_SELECTED_ABILITY))
		return FALSE
	if(!line_of_sight(owner, target))
		return FALSE
	if(target.get_xeno_hivenumber() == owner.get_xeno_hivenumber())
		return FALSE
	action_activate()
	LAZYINCREMENT(owner.do_actions, target)
	addtimer(CALLBACK(src, PROC_REF(decrease_do_action), target), cast_time)
	return TRUE

///Decrease the do_actions of the owner
/datum/action/ability/activable/xeno/smokescreen_spit/proc/decrease_do_action(atom/target)
	LAZYDECREMENT(owner.do_actions, target)

// ***************************************
// *********** Acid dash
// ***************************************
/datum/action/ability/activable/xeno/charge/acid_dash
	name = "Acid Dash"
	action_icon_state = "pounce"
	action_icon = 'icons/Xeno/actions/runner.dmi'
	desc = "Instantly dash, tackling the first marine in your path. If you manage to tackle someone, gain another cast of the ability."
	ability_cost = 100
	cooldown_duration = 20 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_ACID_DASH,
	)
	paralyze_duration = 0 // Although we don't do anything related to paralyze, it is nice to have this zeroed out.
	charge_range = BOILER_CHARGEDISTANCE
	///Can we use the ability again
	var/recast_available = FALSE
	///Is this the recast
	var/recast = FALSE
	/// If we should do acid_spray_act on those we pass over.
	var/do_acid_spray_act = TRUE
	///List of pass_flags given by this action
	var/charge_pass_flags = PASS_LOW_STRUCTURE|PASS_DEFENSIVE_STRUCTURE|PASS_FIRE
	/// How long we stun tackled targets
	var/stun_duration = 1 SECONDS
	/// The duration in deciseconds in which a trail of opaque gas will last.
	var/gas_trail_duration = 0

/datum/action/ability/activable/xeno/charge/acid_dash/use_ability(atom/A)
	if(!A)
		return
	if(recast && cooldown_timer)
		if(TIMER_COOLDOWN_RUNNING(src, COOLDOWN_ACID_DASH_ACTIVATION))
			return
	RegisterSignal(xeno_owner, COMSIG_XENO_OBJ_THROW_HIT, PROC_REF(obj_hit))
	RegisterSignal(xeno_owner, COMSIG_MOVABLE_POST_THROW, PROC_REF(charge_complete))
	RegisterSignal(xeno_owner, COMSIG_XENOMORPH_LEAP_BUMP, PROC_REF(mob_hit))
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(acid_steps)) //We drop acid on every tile we pass through

	xeno_owner.visible_message(span_danger("[xeno_owner] slides towards \the [A]!"), \
	span_danger("We dash towards \the [A], spraying acid down our path!") )
	xeno_owner.emote("roar")
	xeno_owner.xeno_flags |= XENO_LEAPING //This has to come before throw_at, which checks impact. So we don't do end-charge specials when thrown
	if(recast)
		succeed_activate(5) //Greatly reduced cost on recast
	else
		succeed_activate()

	xeno_owner.add_pass_flags(charge_pass_flags, type)
	owner.throw_at(A, charge_range, 2, owner)

/datum/action/ability/activable/xeno/charge/acid_dash/mob_hit(datum/source, mob/living/living_target)
	. = TRUE
	if(living_target.stat || isxeno(living_target) || !(iscarbon(living_target))) //we leap past xenos
		return
	if(!recast)
		recast_available = TRUE
	var/mob/living/carbon/carbon_victim = living_target
	carbon_victim.ParalyzeNoChain(stun_duration)

	to_chat(carbon_victim, span_userdanger("The [owner] tackles us, sending us behind them!"))
	owner.visible_message(span_xenodanger("\The [owner] tackles [carbon_victim], swapping location with them!"), \
		span_xenodanger("We push [carbon_victim] in our acid trail!"), visible_message_flags = COMBAT_MESSAGE)

/datum/action/ability/activable/xeno/charge/acid_dash/charge_complete()
	. = ..()
	UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)
	if(recast_available)
		addtimer(CALLBACK(src, PROC_REF(charge_complete)), 2 SECONDS) //Delayed recursive call, this time you won't gain a recast so it will go on cooldown in 2 SECONDS.
		TIMER_COOLDOWN_START(src, COOLDOWN_ACID_DASH_ACTIVATION, 0.3 SECONDS) // Small delay before you can recast, to make it harder to misfire.
		recast = TRUE
		recast_available = FALSE
	else
		recast = FALSE
		add_cooldown()
	xeno_owner.remove_pass_flags(charge_pass_flags, type)
	recast_available = FALSE

///Drops an acid puddle on the current owner's tile, will do 0 damage if the owner has no acid_spray_damage. Creates opaque gas if gas_trail_duration is set by mutation.
/datum/action/ability/activable/xeno/charge/acid_dash/proc/acid_steps(atom/A, atom/OldLoc, Dir, Forced)
	SIGNAL_HANDLER
	xenomorph_spray(get_turf(xeno_owner), 5 SECONDS, xeno_owner.xeno_caste.acid_spray_damage, xeno_owner, FALSE, do_acid_spray_act)
	if(gas_trail_duration)
		if(xeno_owner.stat != CONSCIOUS)
			return
		var/datum/effect_system/smoke_spread/xeno/acid/opaque/smoke = new()
		smoke.set_up(0, get_turf(xeno_owner), gas_trail_duration / (2 SECONDS))
		smoke.start()

// ***************************************
// *********** High-Pressure Spit
// ***************************************
/datum/action/ability/activable/xeno/high_pressure_spit
	name = "High-Pressure Spit"
	action_icon_state = "corrosive_glob_lance"
	action_icon = 'icons/Xeno/actions/boiler.dmi'
	desc = "Fire a high pressure glob of acid that knocks back, stuns, and shatters the target."
	ability_cost = 75
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
