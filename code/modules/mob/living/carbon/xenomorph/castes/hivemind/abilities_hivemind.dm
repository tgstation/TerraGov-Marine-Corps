/datum/action/ability/xeno_action/return_to_core
	name = "Return to Core"
	action_icon_state = "lay_hivemind"
	desc = "Teleport back to your core."
	use_state_flags = ABILITY_USE_CLOSEDTURF

/datum/action/ability/xeno_action/return_to_core/action_activate()
	SEND_SIGNAL(owner, COMSIG_XENOMORPH_CORE_RETURN)
	return ..()

/datum/action/ability/activable/xeno/secrete_resin/hivemind/can_use_action(silent = FALSE, override_flags, selecting = FALSE)
	if (owner.status_flags & INCORPOREAL)
		return FALSE
	return ..()

/datum/action/ability/xeno_action/change_form
	name = "Change form"
	action_icon_state = "manifest"
	desc = "Change from your incorporeal form to your physical on and vice-versa."
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOMORPH_HIVEMIND_CHANGE_FORM,
	)
	use_state_flags = ABILITY_USE_CLOSEDTURF

/datum/action/ability/xeno_action/change_form/action_activate()
	var/mob/living/carbon/xenomorph/xenomorph_owner = owner
	xenomorph_owner.change_form()

/datum/action/ability/activable/xeno/command_minions
	name = "Command minions"
	action_icon_state = "minion_agressive"
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

/datum/action/ability/activable/xeno/psychic_cure/queen_give_heal/hivemind/can_use_action(silent = FALSE, override_flags, selecting = FALSE)
	if (owner.status_flags & INCORPOREAL)
		return FALSE
	return ..()

/datum/action/ability/activable/xeno/transfer_plasma/hivemind
	plasma_transfer_amount = PLASMA_TRANSFER_AMOUNT * 2

/datum/action/ability/activable/xeno/transfer_plasma/hivemind/can_use_action(silent = FALSE, override_flags, selecting = FALSE)
	if (owner.status_flags & INCORPOREAL)
		return FALSE
	return ..()

/datum/action/ability/xeno_action/pheromones/hivemind/can_use_action(silent = FALSE, override_flags)
	if (owner.status_flags & INCORPOREAL)
		return FALSE
	return ..()

/datum/action/ability/xeno_action/watch_xeno/hivemind/can_use_action(silent = FALSE, override_flags)
	if(TIMER_COOLDOWN_CHECK(owner, COOLDOWN_HIVEMIND_MANIFESTATION))
		return FALSE
	return ..()

/datum/action/ability/xeno_action/watch_xeno/hivemind/on_list_xeno_selection(datum/source, mob/living/carbon/xenomorph/selected_xeno)
	if(!can_use_action())
		return
	var/mob/living/carbon/xenomorph/hivemind/hivemind = source
	hivemind.jump(selected_xeno)

/datum/action/ability/xeno_action/teleport
	name = "Teleport"
	action_icon_state = "resync"
	desc = "Pick a location on the map and instantly manifest there if possible."
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMISG_XENOMORPH_HIVEMIND_TELEPORT,
	)
	use_state_flags = ABILITY_USE_CLOSEDTURF
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

	if(!polled_coords)
		owner.client?.screen -= shown_map
		shown_map.UnregisterSignal(owner, COMSIG_MOB_CLICKON)
		showing_map = FALSE
		return

	owner.client?.screen -= shown_map
	showing_map = FALSE
	var/turf/turf_to_teleport_to = locate(polled_coords[1], polled_coords[2], owner.z)

	if(!turf_to_teleport_to)
		return

	var/mob/living/carbon/xenomorph/hivemind/hivemind_owner = owner
	if(!hivemind_owner.check_weeds(turf_to_teleport_to, TRUE))
		owner.balloon_alert(owner, "No weeds in selected location")
		return
	if(!(hivemind_owner.status_flags & INCORPOREAL))
		hivemind_owner.start_teleport(turf_to_teleport_to)
		return
	hivemind_owner.abstract_move(turf_to_teleport_to)
