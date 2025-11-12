/datum/action/ability/xeno_action/return_to_core
	name = "Return to Core"
	action_icon_state = "lay_hivemind"
	action_icon = 'icons/Xeno/actions/hivemind.dmi'
	desc = "Teleport back to your core."
	use_state_flags = ABILITY_USE_SOLIDOBJECT

/datum/action/ability/xeno_action/return_to_core/action_activate()
	SEND_SIGNAL(owner, COMSIG_XENOMORPH_CORE_RETURN)
	return ..()

/datum/action/ability/activable/xeno/secrete_resin/hivemind/can_use_action(silent, override_flags, selecting)
	if (owner.status_flags & INCORPOREAL)
		return FALSE
	return ..()

/datum/action/ability/xeno_action/change_form
	name = "Change form"
	action_icon_state = "manifest"
	action_icon = 'icons/Xeno/actions/hivemind.dmi'
	desc = "Change from your incorporeal form to your physical on and vice-versa."
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOMORPH_HIVEMIND_CHANGE_FORM,
	)
	use_state_flags = ABILITY_USE_SOLIDOBJECT

/datum/action/ability/xeno_action/change_form/action_activate()
	xeno_owner.change_form()

/datum/action/ability/activable/xeno/command_minions
	name = "Command minions"
	action_icon_state = "minion_agressive"
	action_icon = 'icons/Xeno/actions/leader.dmi'
	desc = "Command all minions, ordering them to converge on this location. Rightclick to change minion behaviour."
	ability_cost = 100
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_RALLY_MINION,
		KEYBINDING_ALTERNATE = COMSIG_XENOABILITY_MINION_BEHAVIOUR,
	)
	keybind_flags = ABILITY_KEYBIND_USE_ABILITY
	cooldown_duration = 60 SECONDS
	use_state_flags = ABILITY_USE_LYING|ABILITY_USE_BUCKLED
	///If minions should be agressive
	var/minions_agressive = TRUE

/datum/action/ability/activable/xeno/command_minions/update_button_icon()
	action_icon_state = minions_agressive ? "minion_agressive" : "minion_passive"
	return ..()

/datum/action/ability/activable/xeno/command_minions/use_ability(atom/target)
	var/turf_targeted = get_turf(target)
	if(!turf_targeted)
		return
	new /obj/effect/ai_node/goal(turf_targeted, owner)
	succeed_activate()
	add_cooldown()

/datum/action/ability/activable/xeno/command_minions/alternate_action_activate()
	minions_agressive = !minions_agressive
	SEND_SIGNAL(owner, COMSIG_ESCORTING_ATOM_BEHAVIOUR_CHANGED, minions_agressive)
	update_button_icon()

/datum/action/ability/activable/xeno/psychic_cure/queen_give_heal/hivemind
	hivemind_heal = TRUE

/datum/action/ability/activable/xeno/psychic_cure/queen_give_heal/hivemind/can_use_action(silent, override_flags, selecting)
	if (owner.status_flags & INCORPOREAL)
		return FALSE
	return ..()

/datum/action/ability/activable/xeno/transfer_plasma/hivemind
	plasma_transfer_amount = PLASMA_TRANSFER_AMOUNT * 2

/datum/action/ability/activable/xeno/transfer_plasma/hivemind/can_use_action(silent, override_flags, selecting)
	if (owner.status_flags & INCORPOREAL)
		return FALSE
	return ..()

/datum/action/ability/xeno_action/pheromones/hivemind/can_use_action(silent, override_flags, selecting)
	if (owner.status_flags & INCORPOREAL)
		return FALSE
	return ..()

/datum/action/ability/xeno_action/watch_xeno/hivemind/can_use_action(silent, override_flags, selecting)
	if(TIMER_COOLDOWN_RUNNING(owner, COOLDOWN_HIVEMIND_MANIFESTATION))
		return FALSE
	return ..()

/datum/action/ability/xeno_action/watch_xeno/hivemind/on_list_xeno_selection(datum/source, mob/living/carbon/xenomorph/selected_xeno)
	if(!can_use_action())
		return
	var/mob/living/carbon/xenomorph/hivemind/hivemind = source
	hivemind.jump(selected_xeno)

/datum/action/ability/xeno_action/teleport
	name = "Teleport"
	action_icon_state = "resync" // TODO: i think i missed an icon
	desc = "Pick a location on the map and instantly manifest there if possible."
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOMORPH_HIVEMIND_TELEPORT,
	)
	use_state_flags = ABILITY_USE_SOLIDOBJECT
	///Is the map being shown to the player right now?
	var/showing_map = FALSE

/datum/action/ability/xeno_action/teleport/action_activate()
	var/atom/movable/screen/minimap/shown_map = SSminimaps.fetch_minimap_object(owner.z, MINIMAP_FLAG_XENO)

	if(showing_map) // The map is open on their screen, close it
		owner.client?.screen -= shown_map
		shown_map.UnregisterSignal(owner, COMSIG_MOB_CLICKON)
		showing_map = FALSE
		return

	owner.client?.screen += shown_map
	showing_map = TRUE
	var/list/polled_coords = shown_map.get_coords_from_click(owner)
	owner.client?.screen -= shown_map
	showing_map = FALSE
	if(!polled_coords)
		shown_map.UnregisterSignal(owner, COMSIG_MOB_CLICKON)
		return
	var/turf/turf_to_teleport_to = locate(polled_coords[1], polled_coords[2], owner.z)
	if(!turf_to_teleport_to)
		return

	if(!xeno_owner.check_weeds(turf_to_teleport_to, TRUE))
		owner.balloon_alert(owner, "no weeds in selected location!")
		return
	if(!(xeno_owner.status_flags & INCORPOREAL) && isxenohivemind(xeno_owner))
		var/mob/living/carbon/xenomorph/hivemind/hivemind_owner = xeno_owner
		hivemind_owner.start_teleport(turf_to_teleport_to)
		return
	xeno_owner.abstract_move(turf_to_teleport_to)

/datum/action/ability/activable/xeno/shoot_xeno_artillery
	name = "Shoot Artillery"
	action_icon_state = "bombard"
	action_icon = 'icons/Xeno/actions/boiler.dmi'
	desc = "Select one of the Hive's artillery buildings and shoot it at a target. Right-click to select which artillery to use."
	use_state_flags = ABILITY_USE_SOLIDOBJECT
	/// The currently selected artillery to use/shoot.
	var/obj/structure/xeno/acid_maw/selected_artillery
	/// If we're waiting on player input. Used to prevent switching artillery mid-input.
	var/waiting_on_player_input = FALSE

/datum/action/ability/activable/xeno/shoot_xeno_artillery/can_use_action(silent, override_flags, selecting)
	. = ..()
	if(!.)
		return
	if(!GLOB.xeno_acid_jaws_by_hive[xeno_owner.hivenumber])
		if(!silent)
			xeno_owner.balloon_alert(xeno_owner, "no xeno artillery found!")
		return FALSE
	if(!selected_artillery || QDELING(selected_artillery))
		if(!silent)
			xeno_owner.balloon_alert(xeno_owner, "pick an artillery first!")
		return FALSE
	if(TIMER_COOLDOWN_RUNNING(selected_artillery, COOLDOWN_MAW_GLOB))
		if(!silent)
			var/timeleft = S_TIMER_COOLDOWN_TIMELEFT(selected_artillery, COOLDOWN_MAW_GLOB)
			xeno_owner.balloon_alert(xeno_owner, "cooldown: [timeleft/10] seconds")
		return FALSE

/datum/action/ability/activable/xeno/shoot_xeno_artillery/fail_activate()
	waiting_on_player_input = FALSE
	return ..()

/datum/action/ability/activable/xeno/shoot_xeno_artillery/action_activate()
	waiting_on_player_input = TRUE
	if(!selected_artillery.try_fire(xeno_owner, xeno_owner, FALSE, FALSE, FALSE) || !can_use_action(TRUE))
		return fail_activate()
	waiting_on_player_input = FALSE

/datum/action/ability/activable/xeno/shoot_xeno_artillery/alternate_action_activate()
	if(!GLOB.xeno_acid_jaws_by_hive[xeno_owner.hivenumber] || waiting_on_player_input)
		return
	if(length(GLOB.xeno_acid_jaws_by_hive[xeno_owner.hivenumber]) == 1)
		selected_artillery = GLOB.xeno_acid_jaws_by_hive[xeno_owner.hivenumber][1]
		xeno_owner.balloon_alert(xeno_owner, "artillery selected")
		update_button_icon()
		return
	INVOKE_ASYNC(src, PROC_REF(select_artillery_from_input_list))

/datum/action/ability/activable/xeno/shoot_xeno_artillery/proc/select_artillery_from_input_list()
	selected_artillery = tgui_input_list(xeno_owner, "Which artillery to use?", "Artillery List",  GLOB.xeno_acid_jaws_by_hive[xeno_owner.hivenumber])
	if(!selected_artillery)
		return
	xeno_owner.balloon_alert(xeno_owner, "artillery selected")
	update_button_icon()
