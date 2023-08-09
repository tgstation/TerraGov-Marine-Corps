
//List of Hivemind resin structure images
GLOBAL_LIST_INIT(hivemind_resin_images_list, list(
		RESIN_WALL = image('icons/mob/actions.dmi', icon_state = RESIN_WALL),
		STICKY_RESIN = image('icons/mob/actions.dmi', icon_state = STICKY_RESIN),
		RESIN_DOOR = image('icons/mob/actions.dmi', icon_state = RESIN_DOOR),
		ALIEN_NEST = image('icons/mob/actions.dmi', icon_state = ALIEN_NEST),
		GROWTH_WALL = image('icons/mob/actions.dmi', icon_state = GROWTH_WALL),
		GROWTH_DOOR = image('icons/mob/actions.dmi', icon_state = GROWTH_DOOR)
		))


/datum/action/xeno_action/return_to_core
	name = "Return to Core"
	action_icon_state = "lay_hivemind"
	desc = "Teleport back to your core."
	use_state_flags = XACT_USE_CLOSEDTURF
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_RETURN_CORE,
	)

/datum/action/xeno_action/return_to_core/action_activate()
	SEND_SIGNAL(owner, COMSIG_XENOMORPH_CORE_RETURN)

/datum/action/xeno_action/psy_gain/hivemind
	name = "Psy Gain"
	action_icon_state = "psy_gain"
	desc = "Gives your hive 100 psy points, if marines are on the ground."
	cooldown_timer = 200 SECONDS

/datum/action/xeno_action/psy_gain/hivemind/action_activate()
	if(length_char(GLOB.humans_by_zlevel["2"]) > 0.2 * length_char(GLOB.alive_human_list))\
	    SSpoints.add_psy_points("[XENO_HIVE_NORMAL]", 100)
	succeed_activate()
	add_cooldown()

/datum/action/xeno_action/activable/secrete_resin/hivemind
	buildable_structures = list(
		/turf/closed/wall/resin/regenerating,
		/obj/alien/resin/sticky,
		/obj/structure/mineral_door/resin,
		/obj/structure/bed/nest,
		/obj/alien/resin/resin_growth,
		/obj/alien/resin/resin_growth/door,
		)

/datum/action/xeno_action/activable/secrete_resin/hivemind/action_activate()
	var/mob/living/carbon/xenomorph/X = owner
	if(X.selected_ability != src)
		return ..()
	var/resin_choice = show_radial_menu(owner, owner, GLOB.hivemind_resin_images_list, radius = 48)
	if(!resin_choice)
		return
	var/i = GLOB.hivemind_resin_images_list.Find(resin_choice)
	X.selected_resin = buildable_structures[i]
	var/atom/A = X.selected_resin
	X.balloon_alert(X, initial(A.name))
	update_button_icon()

/datum/action/xeno_action/activable/secrete_resin/hivemind/can_use_action(silent = FALSE, override_flags, selecting = FALSE)
	if (owner.status_flags & INCORPOREAL)
		return FALSE
	return ..()

/datum/action/xeno_action/change_form
	name = "Change form"
	action_icon_state = "manifest"
	desc = "Change from your incorporeal form to your physical on and vice-versa."
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOMORPH_HIVEMIND_CHANGE_FORM,
	)
	use_state_flags = XACT_USE_CLOSEDTURF
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_CHANGE_FORM,
	)

/datum/action/xeno_action/change_form/action_activate()
	var/mob/living/carbon/xenomorph/xenomorph_owner = owner
	xenomorph_owner.change_form()

/datum/action/xeno_action/activable/command_minions
	name = "Command minions"
	action_icon_state = "rally_minions"
	desc = "Command all minions, ordering them to converge on this location."
	ability_name = "command minions"
	plasma_cost = 100
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_RALLY_MINION,
	)
	keybind_flags = XACT_KEYBIND_USE_ABILITY
	cooldown_timer = 60 SECONDS
	use_state_flags = XACT_USE_LYING|XACT_USE_BUCKLED

/datum/action/xeno_action/activable/command_minions/use_ability(atom/target)
	var/turf_targeted = get_turf(target)
	if(!turf_targeted)
		return
	new /obj/effect/ai_node/goal(turf_targeted, owner)
	succeed_activate()
	add_cooldown()

/datum/action/xeno_action/activable/psychic_cure/hivemind/can_use_action(silent = FALSE, override_flags, selecting = FALSE)
	if (owner.status_flags & INCORPOREAL)
		return FALSE
	return ..()

/datum/action/xeno_action/activable/transfer_plasma/hivemind
	plasma_transfer_amount = PLASMA_TRANSFER_AMOUNT * 2

/datum/action/xeno_action/activable/transfer_plasma/hivemind/can_use_action(silent = FALSE, override_flags, selecting = FALSE)
	if (owner.status_flags & INCORPOREAL)
		return FALSE
	return ..()

/datum/action/xeno_action/pheromones/hivemind/can_use_action(silent = FALSE, override_flags)
	if (owner.status_flags & INCORPOREAL)
		return FALSE
	return ..()

/datum/action/xeno_action/watch_xeno/hivemind/can_use_action(silent = FALSE, override_flags)
	if(TIMER_COOLDOWN_CHECK(owner, COOLDOWN_HIVEMIND_MANIFESTATION))
		return FALSE
	return ..()

/datum/action/xeno_action/watch_xeno/hivemind/on_list_xeno_selection(datum/source, mob/living/carbon/xenomorph/selected_xeno)
	if(!can_use_action())
		return
	var/mob/living/carbon/xenomorph/hivemind/hivemind = source
	hivemind.jump(selected_xeno)

/datum/action/xeno_action/sow/hivemind
	cooldown_timer = 70 SECONDS

/datum/action/xeno_action/sow/hivemind/can_use_action(silent = FALSE, override_flags, selecting = FALSE)
	if (owner.status_flags & INCORPOREAL)
		return FALSE
	return ..()

/datum/action/xeno_action/blessing_menu/hivemind/can_use_action(silent = FALSE, override_flags, selecting = FALSE)
	if (owner.status_flags & INCORPOREAL)
		return FALSE
	return ..()

/datum/action/xeno_action/place_acidwell/hivemind/can_use_action(silent = FALSE, override_flags, selecting = FALSE)
	if (owner.status_flags & INCORPOREAL)
		return FALSE
	return ..()

/datum/action/xeno_action/place_jelly_pod/hivemind/can_use_action(silent = FALSE, override_flags, selecting = FALSE)
	if (owner.status_flags & INCORPOREAL)
		return FALSE
	return ..()

