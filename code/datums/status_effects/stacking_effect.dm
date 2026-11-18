/datum/status_effect/stacking
	id = STATUS_EFFECT_ID_ABSTRACT
	duration = -1 //removed under specific conditions
	alert_type = null
	/// If the status effect should be removed due to being under one stack
	var/consumed_on_fadeout = TRUE
	/// How many stacks are accumulated, also is # of stacks that target will have when first applied
	var/stacks = 0
	/// Deciseconds until ticks start occuring, which removes stacks (first stack will be removed at this time plus tick_interval)
	var/delay_before_decay
	tick_interval = 1 SECONDS
	/// How many stacks are lost per tick (decay trigger)
	var/stack_decay = 1
	/// Special effects trigger when stacks reach this amount
	var/stack_threshold
	/// Stacks cannot exceed this amount
	var/max_stacks
	/// If status should be removed once threshold is crossed
	var/consumed_on_threshold = TRUE
	/// Set to true once the threshold is crossed, false once it falls back below
	var/threshold_crossed = FALSE
	var/overlay_file
	var/underlay_file
	/// States in .dmi must be given a name followed by a number which corresponds to a number of stacks. put the state name without the number in these state vars
	var/overlay_state
	/// The number is concatonated onto the string based on the number of stacks to get the correct state name
	var/underlay_state
	/// A reference to the overlay appearance
	var/mutable_appearance/status_overlay
	/// A reference to the underlay appearance
	var/mutable_appearance/status_underlay

/datum/status_effect/stacking/get_duration_text()
	return MAPTEXT_TINY_UNICODE("<span style='text-align:center'>[round((stacks / max_stacks)*100)]%</span>")

/// Effects that occur when the stack count crosses `stack_threshold`
/datum/status_effect/stacking/proc/threshold_cross_effect()
	return

/// Effects that occur if the status effect is removed due to the `stack_threshold` being crossed
/datum/status_effect/stacking/proc/stacks_consumed_effect()
	return

/// Effects that occur if the status is removed due to being under 1 remaining stack
/datum/status_effect/stacking/proc/fadeout_effect()
	return

/// Runs every `tick`, causes stacks to decay over time
/datum/status_effect/stacking/proc/stack_decay_effect()
	return

/// Called when the `stack_threshold` is crossed (stacks go over the threshold)
/datum/status_effect/stacking/proc/on_threshold_cross()
	threshold_cross_effect()
	if(consumed_on_threshold)
		stacks_consumed_effect()
		qdel(src)

/// Called when the `stack_threshold` is uncrossed / dropped (stacks go under the threshold after being over it)
/datum/status_effect/stacking/proc/on_threshold_drop()
	return

/// Whether the owner can have the status effect.
/// Return `FALSE` if the owner is not in a valid state (self-deletes the effect), or `TRUE` otherwise
/datum/status_effect/stacking/proc/can_have_status()
	return owner.stat != DEAD

/// Whether the owner can currently gain stacks or not.
/// Return `FALSE` if the owner is not in a valid state, or TRUE otherwise
/datum/status_effect/stacking/proc/can_gain_stacks()
	return owner.stat != DEAD

/datum/status_effect/stacking/tick(seconds_between_ticks)
	if(!can_have_status())
		qdel(src)
	else
		add_stacks(-stack_decay)
		stack_decay_effect()

/// Add (or remove) `stacks_added` stacks to our current stack count
/datum/status_effect/stacking/proc/add_stacks(stacks_added)
	if(stacks_added > 0 && !can_gain_stacks())
		return FALSE
	if(status_overlay)
		owner.cut_overlay(status_overlay)
	stacks = min(stacks + stacks_added, max_stacks)
	if(stacks <= 0 && consumed_on_fadeout)
		fadeout_effect()
		qdel(src) // deletes status if stacks fall under one
		return

	if(stacks >= stack_threshold && !threshold_crossed) // threshold_crossed check prevents threshold effect from occurring if changing from above threshold to still above threshold
		threshold_crossed = TRUE
		on_threshold_cross()
		if(consumed_on_threshold)
			return
	else if(stacks < stack_threshold && threshold_crossed)
		threshold_crossed = FALSE // resets threshold effect if we fall below threshold so threshold effect can trigger again
		on_threshold_drop()

	if(stacks_added > 0)
		time_until_next_tick += delay_before_decay // refreshes time until decay

	if(status_overlay)
		status_overlay.icon_state = "[overlay_state][stacks]"
		owner.add_overlay(status_overlay)

/datum/status_effect/stacking/on_creation(mob/living/new_owner, stacks_to_apply)
	. = ..()
	if(.)
		add_stacks(stacks_to_apply)

/datum/status_effect/stacking/on_apply()
	if(!can_have_status())
		return FALSE
	status_overlay = mutable_appearance(overlay_file, "[overlay_state][stacks]")
	status_underlay = mutable_appearance(underlay_file, "[underlay_state][stacks]")
	var/icon_height = owner.get_cached_height()
	status_overlay.pixel_x = -owner.pixel_x
	status_overlay.pixel_y = FLOOR(icon_height * 0.25, 1)
	status_overlay.transform = matrix() * (icon_height/world.icon_size) //scale the status's overlay size based on the target's icon size
	status_underlay.pixel_x = -owner.pixel_x
	status_underlay.transform = matrix() * (icon_height/world.icon_size) * 3
	status_underlay.alpha = 40
	owner.add_overlay(status_overlay)
	owner.underlays += status_underlay
	return ..()

/datum/status_effect/stacking/Destroy()
	if(owner)
		owner.cut_overlay(status_overlay)
		owner.underlays -= status_underlay
	QDEL_NULL(status_overlay)
	return ..()
