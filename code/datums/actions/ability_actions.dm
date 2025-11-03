
/datum/action/ability
	///If you are going to add an explanation for an ability. don't use stats, give a very brief explanation of how to use it.
	desc = "This ability can not be found in codex."
	action_icon = 'icons/Xeno/actions/general.dmi'
	///The cost of using this ability. Typically a plasma cost for xenos
	var/ability_cost = 0
	///bypass use limitations checked by can_use_action()
	var/use_state_flags = NONE
	///Standard cooldown for this ability
	var/cooldown_duration
	///special behavior flags for how this ability is used
	var/keybind_flags
	///the actual cooldown timer
	var/cooldown_timer
	///any special flags for what this ability targets
	var/target_flags = NONE
	/// flags to restrict an ability to certain gamemode
	var/gamemode_flags = ABILITY_ALL_GAMEMODE
	///Cooldown map text holder
	var/obj/effect/countdown/action_cooldown/countdown

/datum/action/ability/New(Target)
	. = ..()
	if(ability_cost)
		name = "[name] ([ability_cost])"
	countdown = new(button, src)

/datum/action/ability/Destroy()
	if(cooldown_timer)
		deltimer(cooldown_timer)
	QDEL_NULL(countdown)
	return ..()

/datum/action/ability/give_action(mob/living/L)
	. = ..()
	var/mob/living/carbon/carbon_owner = L
	carbon_owner.mob_abilities += src

/datum/action/ability/remove_action(mob/living/L)
	var/mob/living/carbon/carbon_owner = L
	if(!istype(carbon_owner))
		stack_trace("/datum/action/ability/remove_action called with [L], expecting /mob/living/carbon.")
	carbon_owner.mob_abilities -= src
	return ..()

/datum/action/ability/handle_button_status_visuals()
	if(!can_use_action(TRUE, ABILITY_IGNORE_COOLDOWN))
		button.color = "#80000080" // rgb(128,0,0,128)
	else if(!action_cooldown_finished())
		button.color = "#f0b400c8" // rgb(240,180,0,200)
	else
		button.color = "#ffffffff" // rgb(255,255,255,255)

/datum/action/ability/can_use_action(silent, override_flags, selecting)
	var/mob/living/carbon/carbon_owner = owner
	if(!carbon_owner)
		return FALSE
	var/to_check_flags = use_state_flags|override_flags

	if(!(to_check_flags & ABILITY_IGNORE_COOLDOWN) && !action_cooldown_finished())
		if(!silent)
			carbon_owner.balloon_alert(carbon_owner, "wait [cooldown_remaining()] seconds!")
		return FALSE

	if(!(to_check_flags & ABILITY_USE_INCAP) && carbon_owner.incapacitated())
		if(!silent)
			carbon_owner.balloon_alert(carbon_owner, "incapacitated!")
		return FALSE

	if(!(to_check_flags & ABILITY_USE_LYING) && carbon_owner.lying_angle)
		if(!silent)
			carbon_owner.balloon_alert(carbon_owner, "lying down!")
		return FALSE

	if(!(to_check_flags & ABILITY_USE_BUCKLED) && carbon_owner.buckled)
		if(!silent)
			carbon_owner.balloon_alert(carbon_owner, "buckled!")
		return FALSE

	if(!(to_check_flags & ABILITY_USE_STAGGERED) && carbon_owner.IsStaggered())
		if(!silent)
			carbon_owner.balloon_alert(carbon_owner, "staggered!")
		return FALSE


	if(!(to_check_flags & ABILITY_USE_NOTTURF) && !isturf(carbon_owner.loc))
		if(!silent)
			carbon_owner.balloon_alert(carbon_owner, "not right here!")
		return FALSE

	if(!(to_check_flags & ABILITY_USE_BUSY) && carbon_owner.do_actions)
		if(!silent)
			carbon_owner.balloon_alert(carbon_owner, "busy!")
		return FALSE

	if(!(to_check_flags & ABILITY_USE_BURROWED) && HAS_TRAIT(carbon_owner, TRAIT_BURROWED))
		if(!silent)
			carbon_owner.balloon_alert(carbon_owner, "burrowed!")
		return FALSE

	if(!(to_check_flags & ABILITY_USE_SOLIDOBJECT))
		var/turf/current_turf = get_turf(carbon_owner)
		if(!current_turf) //we are in nullspace when first spawning in
			return FALSE
		if(isclosedturf(current_turf))
			if(!silent)
				//Not converted to balloon alert as xeno.dm's balloon alert is simultaneously called and will overlap.
				to_chat(owner, span_warning("We can't do this while in a solid object!"))
			return FALSE
		for(var/obj/turf_object in current_turf.contents)
			if(!turf_object.density || !turf_object.opacity)
				continue
			if(!silent)
				//Same as above.
				to_chat(owner, span_warning("We can't do this while in a solid object!"))
			return FALSE

	return TRUE

/datum/action/ability/fail_activate()
	update_button_icon()
	return FALSE

///ability cost override allows for actions/abilities to override the normal ability costs
/datum/action/ability/proc/succeed_activate(ability_cost_override)
	if(QDELETED(owner))
		return
	ability_cost_override = ability_cost_override? ability_cost_override : ability_cost
	if(SEND_SIGNAL(owner, COMSIG_ABILITY_SUCCEED_ACTIVATE, src, ability_cost_override) & SUCCEED_ACTIVATE_CANCEL)
		return
	if(ability_cost_override > 0)
		var/mob/living/carbon/carbon_owner = owner
		carbon_owner.deduct_ability_cost(ability_cost_override)

///checks if the linked ability is on some cooldown. The action can still be activated by clicking the button
/datum/action/ability/proc/action_cooldown_finished()
	return !cooldown_timer

///Removes the cooldown
/datum/action/ability/proc/clear_cooldown()
	if(!cooldown_timer)
		return
	deltimer(cooldown_timer)
	on_cooldown_finish()

///Returns the cooldown timer
/datum/action/ability/proc/get_cooldown()
	return cooldown_duration

///Adds a cooldown to this ability
/datum/action/ability/proc/add_cooldown(cooldown_override = 0)
	SIGNAL_HANDLER
	var/cooldown_length = get_cooldown()
	if(cooldown_override)
		cooldown_length = cooldown_override
	if(cooldown_timer || !cooldown_length) // stop doubling up or waiting on zero
		return
	cooldown_timer = addtimer(CALLBACK(src, PROC_REF(on_cooldown_finish)), cooldown_length, TIMER_STOPPABLE)
	countdown.start()
	update_button_icon()

///Time remaining on cooldown
/datum/action/ability/proc/cooldown_remaining()
	return timeleft(cooldown_timer) * 0.1

///override this for cooldown completion
/datum/action/ability/proc/on_cooldown_finish()
	cooldown_timer = null
	countdown.stop()
	if(!button)
		return
	update_button_icon()

///Any changes when a xeno with this ability evolves
/datum/action/ability/proc/on_xeno_upgrade()
	SIGNAL_HANDLER
	return

/datum/action/ability/activable
	action_type = ACTION_SELECT

/datum/action/ability/activable/Destroy()
	var/mob/living/carbon/carbon_owner = owner
	if(carbon_owner?.selected_ability == src)
		deselect()
	return ..()

/datum/action/ability/activable/set_toggle(value)
	. = ..()
	if(!.)
		return
	if(!owner)
		return
	if(toggled)
		SEND_SIGNAL(owner, COMSIG_ACTION_EXCLUSIVE_TOGGLE, owner)
		RegisterSignal(owner, COMSIG_ACTION_EXCLUSIVE_TOGGLE, PROC_REF(deselect))
	else
		UnregisterSignal(owner, COMSIG_ACTION_EXCLUSIVE_TOGGLE)

/datum/action/ability/activable/alternate_action_activate()
	INVOKE_ASYNC(src, PROC_REF(action_activate))

/datum/action/ability/activable/action_activate()
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/carbon_owner = owner
	if(carbon_owner.selected_ability)
		if(carbon_owner.selected_ability == src)
			return
		carbon_owner.selected_ability.deselect()
	select()

/datum/action/ability/activable/keybind_activation()
	. = COMSIG_KB_ACTIVATED
	if(CHECK_BITFIELD(keybind_flags, ABILITY_KEYBIND_USE_ABILITY))
		if(can_use_ability(null, FALSE, ABILITY_IGNORE_SELECTED_ABILITY))
			use_ability()
		return

	if(can_use_action(FALSE, NONE, TRUE)) // just for selecting
		action_activate()

/datum/action/ability/activable/remove_action(mob/living/carbon/carbon_owner)
	deselect()
	if(carbon_owner.selected_ability == src)
		carbon_owner.selected_ability = null
	return ..()

/datum/action/ability/activable/can_use_action(silent, override_flags, selecting)
	if(selecting)
		return ..(silent, ABILITY_IGNORE_COOLDOWN|ABILITY_IGNORE_PLASMA|ABILITY_USE_STAGGERED)
	return ..()

///override this
/datum/action/ability/activable/proc/can_use_ability(atom/A, silent = FALSE, override_flags)
	if(QDELETED(owner))
		return FALSE

	var/to_check_flags = use_state_flags|override_flags

	var/mob/living/carbon/carbon_owner = owner
	if(!CHECK_BITFIELD(to_check_flags, ABILITY_IGNORE_SELECTED_ABILITY) && carbon_owner.selected_ability != src)
		return FALSE
	. = can_use_action(silent, override_flags)
	if(!CHECK_BITFIELD(to_check_flags, ABILITY_TARGET_SELF) && A == owner)
		return FALSE

///the thing to do when the selected action ability is selected and triggered by middle_click
/datum/action/ability/activable/proc/use_ability(atom/A)
	return

///Setting this ability as the active ability
/datum/action/ability/activable/select()
	. = ..()
	var/mob/living/carbon/carbon_owner = owner
	carbon_owner.selected_ability = src
	on_selection()

///Deselecting this ability for use
/datum/action/ability/activable/deselect()
	. = ..()
	if(owner)
		var/mob/living/carbon/carbon_owner = owner
		carbon_owner.selected_ability = null
	on_deselection()

///Any effects on selecting this ability
/datum/action/ability/activable/proc/on_selection()
	return

///Any effects on deselecting this ability
/datum/action/ability/activable/proc/on_deselection()
	return

//related mob procs

///deducts the cost of using an ability
/mob/living/carbon/proc/deduct_ability_cost(amount)
	return

/mob/living/carbon/xenomorph/deduct_ability_cost(amount)
	use_plasma(amount)

///adds an ability to the mob
/mob/living/carbon/proc/add_ability(datum/action/ability/new_ability)
	if(!new_ability)
		return
	new_ability = new new_ability(src)
	new_ability.give_action(src)

///Removes an ability from a mob
/mob/living/carbon/proc/remove_ability(datum/action/ability/old_ability)
	for(var/datum/action/ability/action_datum in mob_abilities)
		if(action_datum.type != old_ability)
			continue
		qdel(action_datum)
