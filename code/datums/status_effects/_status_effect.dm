/**
 * # Status Effects
 *
 * Status effects are used to apply effects, either temporarily or permanently, to living mob types.
 *
 * _When making a new status effect, add a define of its datum to `__DEFINES/status_effects.dm` for ease of use._
 */
/datum/status_effect
	/// The ID of the effect. ID is used in adding and removing effects to check for duplicates, among other things.
	var/id = "effect"
	/// How long the status effect lasts in DECISECONDS. Use [STATUS_EFFECT_PERMANENT] for
	/// a status effect that is never removed except through specific means.
	var/duration = STATUS_EFFECT_PERMANENT
	/// When used with `alert_type`, shows the duration on the alert
	var/show_duration = FALSE
	/// Used to define if the status effect should be using `SSfastprocess`, `SSprocessing`, or `SSpriority_effects`.
	///
	/// `SSfastprocess` is suitable for most status effect types, with `SSprocessing` available for expensive effects
	/// or effects that don't care about fast timing. `SSpriority_effects` is suitable for status effects that must
	/// process fast while also being less likely to be skipped during server load due to the nature of the MC.
	var/processing_speed = STATUS_EFFECT_FAST_PROCESS
	/// This is how long between tick calls in deciseconds.
	/// This has to be a multiple of the wait of the subsystem this status effect is running on, which is based on `processing_speed`.
	/// Putting [STATUS_EFFECT_NO_TICK] here will stop tick calls, and if duration is [STATUS_EFFECT_PERMANENT], it stops processing entirely.
	/// Putting [STATUS_EFFECT_AUTO_TICK] here will make every subsystem tick call tick, making the tick interval depend entirely on `processing_speed`.
	var/tick_interval = 1 SECONDS
	/// The time until the next tick call, gets set to `tick_interval` after every tick call and decrements on every process call
	var/time_until_next_tick
	/// The mob that owns this status effect and is being affected by it
	VAR_FINAL/mob/living/owner
	/// How many of the effect can be on one mob, and what happens when you try to add another
	var/status_type = STATUS_EFFECT_UNIQUE
	/// Typepath of the screen alert thrown by the status effect when created
	var/alert_type = /atom/movable/screen/alert/status_effect
	/// A reference to the visible thrown alert when it's thrown, if [alert_type] is specified
	VAR_FINAL/atom/movable/screen/alert/status_effect/linked_alert
	/// Special behavior flags
	var/status_flags = NONE

/datum/status_effect/New(list/arguments)
	on_creation(arglist(arguments))

/// Called from `New` with any supplied status effect arguments.
/// Not guaranteed to exist by the end.
/// Returning `FALSE` from `on_apply` will stop `on_creation` and self-delete the effect.
/datum/status_effect/proc/on_creation(mob/living/new_owner, ...)
	if(new_owner)
		owner = new_owner
	if(QDELETED(owner) || !on_apply())
		qdel(src)
		return
	if(owner)
		LAZYADD(owner.status_effects, src)

	if(status_flags & STATUS_FLAG_CHECK_OWNER_DEATH)
		RegisterSignal(owner, COMSIG_MOB_DEATH, PROC_REF(on_owner_death))

	if(tick_interval != STATUS_EFFECT_NO_TICK)
		time_until_next_tick = tick_interval

	if(alert_type)
		var/atom/movable/screen/alert/status_effect/new_alert = owner.throw_alert(id, alert_type)
		new_alert.attached_effect = src //so the alert can reference us, if it needs to
		linked_alert = new_alert //so we can reference the alert, if we need to
		update_shown_duration()

	if(duration != STATUS_EFFECT_PERMANENT || tick_interval != STATUS_EFFECT_NO_TICK) // don't process if we don't care
		start_processing()

	return TRUE

/datum/status_effect/Destroy()
	stop_processing()
	linked_alert = null
	if(owner)
		owner.clear_alert(id)
		LAZYREMOVE(owner.status_effects, src)
		on_remove()
		owner = null
	return ..()

/// Status effect process. Handles adjusting its duration and time until it should actually tick.
/// Don't extend or override this proc, you should override [/datum/status_effect/proc/tick] instead.
/datum/status_effect/process(seconds_per_tick)
	SHOULD_NOT_OVERRIDE(TRUE)

	if(QDELETED(owner))
		qdel(src)
		return

	if(duration != STATUS_EFFECT_PERMANENT)
		duration = max(0, duration - (seconds_per_tick SECONDS)) // doing it first means it's more up to date for ticks to read

	if(tick_interval != STATUS_EFFECT_NO_TICK)
		time_until_next_tick = max(0, time_until_next_tick - (seconds_per_tick SECONDS)) // same here

	if(tick_interval == STATUS_EFFECT_AUTO_TICK)
		tick(seconds_per_tick)
	else if(tick_interval != STATUS_EFFECT_NO_TICK && time_until_next_tick <= 0)
		time_until_next_tick = tick_interval // same here as well
		tick(tick_interval / 10)

	if(QDELING(src))
		return // tick deleted us, no need to continue

	check_duration()

/// Stops processing, removing it from relevant subsystems
/datum/status_effect/proc/stop_processing()
	switch(processing_speed)
		if(STATUS_EFFECT_FAST_PROCESS)
			STOP_PROCESSING(SSfastprocess, src)
		if(STATUS_EFFECT_NORMAL_PROCESS)
			STOP_PROCESSING(SSprocessing, src)
		if(STATUS_EFFECT_PRIORITY)
			STOP_PROCESSING(SSpriority_effects, src)

/// Stops ticking. Entirely stops processing if the effect is permanent.
/datum/status_effect/proc/stop_ticking()
	// If we have a set duration, we can't stop processing as duration is also handled in process
	if(duration != STATUS_EFFECT_PERMANENT)
		time_until_next_tick = STATUS_EFFECT_NO_TICK
		return

	// But if we are permanent, there is no reason to keep processing if we don't tick
	stop_processing()

/// (Re)starts processing, adding it to relevant subsystems
/datum/status_effect/proc/start_processing()
	switch(processing_speed)
		if(STATUS_EFFECT_FAST_PROCESS)
			START_PROCESSING(SSfastprocess, src)
		if(STATUS_EFFECT_NORMAL_PROCESS)
			START_PROCESSING(SSprocessing, src)
		if(STATUS_EFFECT_PRIORITY)
			START_PROCESSING(SSpriority_effects, src)

/// (Re)starts ticking, also (re)starting processing if the effect is permanent
/datum/status_effect/proc/start_ticking()
	// If we have a set duration, we assume we're processing already, so just reset the timer
	if(duration != STATUS_EFFECT_PERMANENT)
		time_until_next_tick = tick_interval
		return

	// But if we are permanent, we probably need to start processing
	start_processing()

/// Called whenever the effect is applied in [/datum/status_effect/proc/on_creation].
/// Returning `FALSE` will cause it to delete itself during creation instead.
/datum/status_effect/proc/on_apply()
	return TRUE

/**
 * Called from process() when `tick_interval` has hit zero. This can only be called if `tick_interval` is not [STATUS_EFFECT_NO_TICK].
 *
 * Ticks are separate from processing cycles. Status effects will frequently process without actually ticking,
 * due to the nature of `tick_interval`. Status effects can tick every time they process by setting `tick_interval`
 * to [STATUS_EFFECT_AUTO_TICK].
 *
 *
 * Arguments:
 * * `seconds_between_ticks`—This is a _CONSTANT_ value that uses the tick interval of the status effect divided by 10, or just the
 * seconds per tick of the subsystem firing it for [STATUS_EFFECT_AUTO_TICK] effects. _Don't treat it like lag compensation or anything similar._
 * It should never be changing in practice, it's best suited for scaling an effect's numbers with its interval or subsystem wait.
 */
/datum/status_effect/proc/tick(seconds_between_ticks)
	return

/// Called whenever the effect expires or is removed (qdeleted).
/// Note that at the point this is called, it is out of the
/// owner's status_effects list, but owner is not yet null
/datum/status_effect/proc/on_remove()
	return

/// Called before being fully removed (before `on_remove`).
/// Returning `FALSE` will cancel removal.
/datum/status_effect/proc/before_remove(...)
	return TRUE

/// Called when a status effect of `status_type` [STATUS_EFFECT_REFRESH]
/// has its duration refreshed in `apply_status_effect`
/datum/status_effect/proc/refresh(effect, ...)
	var/original_duration = initial(duration)
	if(original_duration == STATUS_EFFECT_PERMANENT)
		return
	duration = original_duration

/// Manually checks if the effect should've ended by now and deletes it if so
/datum/status_effect/proc/check_duration()
	if(duration != STATUS_EFFECT_PERMANENT && duration <= 0)
		qdel(src)
		return TRUE
	update_shown_duration()
	return FALSE

/// Updates the status effect alert's maptext (if possible)
/datum/status_effect/proc/update_shown_duration()
	PROTECTED_PROC(TRUE)
	if(!linked_alert || !show_duration)
		return FALSE

	linked_alert.maptext = get_duration_text()

/// Gets the text to show for the alert's maptext
/datum/status_effect/proc/get_duration_text()
	return MAPTEXT_TINY_UNICODE("<span style='text-align:center'>[round(duration / 10, 1)]s</span>")

/// Effects on owner death. Requires [STATUS_FLAG_CHECK_OWNER_DEATH].
/datum/status_effect/proc/on_owner_death(datum/source)
	SIGNAL_HANDLER
	if(status_flags & STATUS_FLAG_OWNER_DEATH_DEL)
		qdel(src)
		return
	stop_processing()
	RegisterSignal(owner, COMSIG_MOB_REVIVE, PROC_REF(on_owner_revive))

/// Any effects when the owner comes back to life if [STATUS_FLAG_CHECK_OWNER_DEATH] is used
/datum/status_effect/proc/on_owner_revive(datum/source)
	SIGNAL_HANDLER
	start_processing()

/atom/movable/screen/alert/status_effect
	name = "Curse of Mundanity"
	desc = "You don't feel any different..."
	var/datum/status_effect/attached_effect

/atom/movable/screen/alert/status_effect/Destroy()
	. = ..()
	attached_effect = null
