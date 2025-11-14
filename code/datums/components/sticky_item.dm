/datum/component/sticky_item
	///Current atom this item is attached to
	var/atom/stuck_to
	///Current image overlay applied to stuck_to
	var/image/saved_overlay
	///Custom icon file to be used for the overlay when item is stuck on
	var/icon/icon_file
	///Custom icon state to be used for the overlay when item is stuck on
	var/icon_state

/datum/component/sticky_item/Initialize(_icon_file, _icon_state)
	. = ..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	var/obj/item/item_parent = parent

	if(_icon_file)
		icon_file = _icon_file
	else
		icon_file = item_parent.icon

	if(_icon_state)
		icon_state = _icon_state
	else
		icon_state = item_parent.icon_state

	RegisterSignal(item_parent, COMSIG_MOVABLE_IMPACT, PROC_REF(on_impact))
	RegisterSignal(item_parent, COMSIG_ITEM_STICKY_STICK_TO, PROC_REF(stick_to))
	RegisterSignal(item_parent, COMSIG_ITEM_STICKY_CLEAN_REFS, PROC_REF(clean_refs))

/datum/component/sticky_item/Destroy(force=FALSE, silent=FALSE)
	clean_refs()
	return ..()

/// Deals with actually making the parent stick to the target
/datum/component/sticky_item/proc/stick_to(datum/source, atom/target)
	SIGNAL_HANDLER
	if(!isitem(source)) //somehow...
		CRASH("Sticky item component was somehow not on an item upon attach. Component attached to: [parent]")
	var/obj/item/item_source = source
	if(!item_source.can_stick_to(target))
		return
	var/image/stuck_overlay = image(icon_file, target, icon_state)
	stuck_overlay.pixel_x = rand(-5, 5)
	stuck_overlay.pixel_y = rand(-7, 7)
	target.add_overlay(stuck_overlay)
	item_source.forceMove(target)
	saved_overlay = stuck_overlay
	stuck_to = target
	target.visible_message(span_warning("[item_source] sticks to [target]!"))
	RegisterSignal(stuck_to, COMSIG_QDELETING, PROC_REF(clean_refs))

/// Called on throw impact via signal
/datum/component/sticky_item/proc/on_impact(datum/source, atom/movable/hit_atom, speed)
	SIGNAL_HANDLER
	stick_to(source, hit_atom)

/// Handles cleaning up the overlay and nulling out the stuck_to atom
/datum/component/sticky_item/proc/clean_refs()
	SIGNAL_HANDLER
	if(stuck_to)
		stuck_to.cut_overlay(saved_overlay)
		UnregisterSignal(stuck_to, COMSIG_QDELETING)
		stuck_to = null
	QDEL_NULL(saved_overlay)

/// Same as normal, except this one has special behaviour on move, like deploying smoke
/datum/component/sticky_item/move_behaviour/stick_to(datum/source, atom/target)
	. = ..()
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))

/datum/component/sticky_item/move_behaviour/Destroy(force, silent)
	if(stuck_to)
		UnregisterSignal(stuck_to, COMSIG_MOVABLE_MOVED)
	return ..()

/// Behaviour on stuck_to move
/datum/component/sticky_item/move_behaviour/proc/on_move(datum/source, old_loc, movement_dir, forced, old_locs)
	SIGNAL_HANDLER
	if(!isitem(parent)) //somehow...
		CRASH("Sticky item component was somehow not on an item upon move. Component attached to: [source]")
	var/obj/item/item_parent = parent
	item_parent.on_move_sticky()
