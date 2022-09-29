
/datum/action/xeno_action
	var/plasma_cost = 0
	var/mechanics_text = "This ability not found in codex." //codex. If you are going to add an explanation for an ability. don't use stats, give a very brief explanation of how to use it.
	var/use_state_flags = NONE // bypass use limitations checked by can_use_action()
	var/last_use
	var/cooldown_timer
	var/ability_name
	var/keybind_flags
	var/cooldown_id
	var/target_flags = NONE
	/// flags to restrict a xeno ability to certain gamemode
	var/gamemode_flags = ABILITY_ALL_GAMEMODE

/datum/action/xeno_action/New(Target)
	. = ..()
	if(plasma_cost)
		name = "[name] ([plasma_cost])"
	var/image/cooldown_image = image('icons/effects/progressicons.dmi', null, "busy_clock")
	var/mutable_appearance/empowered_appearence = mutable_appearance('icons/mob/actions.dmi', "borders_center")
	empowered_appearence.layer = HUD_LAYER
	cooldown_image.pixel_y = 7
	cooldown_image.appearance_flags = RESET_COLOR|RESET_ALPHA
	visual_references[VREF_IMAGE_XENO_CLOCK] = cooldown_image
	visual_references[VREF_MUTABLE_EMPOWERED_FRAME] = empowered_appearence

/datum/action/xeno_action/give_action(mob/living/L)
	. = ..()
	var/mob/living/carbon/xenomorph/X = L
	X.xeno_abilities += src
	RegisterSignal(L, COMSIG_XENOMORPH_ABILITY_ON_UPGRADE, .proc/on_xeno_upgrade)

/datum/action/xeno_action/remove_action(mob/living/L)
	UnregisterSignal(L, COMSIG_XENOMORPH_ABILITY_ON_UPGRADE)
	if(cooldown_id)
		deltimer(cooldown_id)
	var/mob/living/carbon/xenomorph/X = L
	X.xeno_abilities -= src
	return ..()

/datum/action/xeno_action/proc/on_xeno_upgrade()
	return

///Adds an outline around the ability button
/datum/action/xeno_action/proc/add_empowered_frame()
	button.cut_overlay(visual_references[VREF_MUTABLE_EMPOWERED_FRAME])

/datum/action/xeno_action/proc/remove_empowered_frame()
	button.add_overlay(visual_references[VREF_MUTABLE_EMPOWERED_FRAME])

/datum/action/xeno_action/can_use_action(silent = FALSE, override_flags)
	var/mob/living/carbon/xenomorph/X = owner
	if(!X)
		return FALSE
	var/flags_to_check = use_state_flags|override_flags

	if(!(flags_to_check & XACT_IGNORE_COOLDOWN) && !action_cooldown_check())
		if(!silent)
			X.balloon_alert(X, "Wait [cooldown_remaining()] sec")
		return FALSE

	if(!(flags_to_check & XACT_USE_INCAP) && X.incapacitated())
		if(!silent)
			X.balloon_alert(X, "Cannot while incapacitated")
		return FALSE

	if(!(flags_to_check & XACT_USE_LYING) && X.lying_angle)
		if(!silent)
			X.balloon_alert(X, "Cannot while lying down")
		return FALSE

	if(!(flags_to_check & XACT_USE_BUCKLED) && X.buckled)
		if(!silent)
			X.balloon_alert(X, "Cannot while buckled")
		return FALSE

	if(!(flags_to_check & XACT_USE_STAGGERED) && X.stagger)
		if(!silent)
			X.balloon_alert(X, "Cannot while staggered")
		return FALSE

	if(!(flags_to_check & XACT_USE_FORTIFIED) && X.fortify)
		if(!silent)
			X.balloon_alert(X, "Cannot while fortified")
		return FALSE

	if(!(flags_to_check & XACT_USE_CRESTED) && X.crest_defense)
		if(!silent)
			X.balloon_alert(X, "Cannot while in crest defense")
		return FALSE

	if(!(flags_to_check & XACT_USE_NOTTURF) && !isturf(X.loc))
		if(!silent)
			X.balloon_alert(X, "Cannot do this here")
		return FALSE

	if(!(flags_to_check & XACT_USE_BUSY) && X.do_actions)
		if(!silent)
			X.balloon_alert(X, "Cannot, busy")
		return FALSE

	if(!(flags_to_check & XACT_USE_AGILITY) && X.agility)
		if(!silent)
			X.balloon_alert(X, "Cannot in agility mode")
		return FALSE

	if(!(flags_to_check & XACT_IGNORE_PLASMA) && X.plasma_stored < plasma_cost)
		if(!silent)
			X.balloon_alert(X, "Need [plasma_cost - X.plasma_stored] more plasma")
		return FALSE
	if(!(flags_to_check & XACT_USE_CLOSEDTURF) && isclosedturf(get_turf(X)))
		if(!silent)
			//Not converted to balloon alert as xeno.dm's balloon alert is simultaneously called and will overlap.
			to_chat(owner, span_warning("We can't do this while in a solid object!"))
		return FALSE

	return TRUE

/datum/action/xeno_action/fail_activate()
	update_button_icon()

///Plasma cost override allows for actions/abilities to override the normal plasma costs
/datum/action/xeno_action/proc/succeed_activate(plasma_cost_override)
	if(QDELETED(owner))
		return
	var/mob/living/carbon/xenomorph/X = owner
	if(plasma_cost_override)
		X.use_plasma(plasma_cost_override)
		return
	if(plasma_cost)
		X.use_plasma(plasma_cost)

//checks if the linked ability is on some cooldown.
//The action can still be activated by clicking the button
/datum/action/xeno_action/proc/action_cooldown_check()
	return !cooldown_id


/datum/action/xeno_action/proc/clear_cooldown()
	if(!cooldown_id)
		return
	deltimer(cooldown_id)
	on_cooldown_finish()


/datum/action/xeno_action/proc/get_cooldown()
	return cooldown_timer


/datum/action/xeno_action/proc/add_cooldown(cooldown_override = 0)
	SIGNAL_HANDLER
	var/cooldown_length = get_cooldown()
	if(cooldown_override)
		cooldown_length = cooldown_override
	if(cooldown_id || !cooldown_length) // stop doubling up or waiting on zero
		return
	last_use = world.time
	cooldown_id = addtimer(CALLBACK(src, .proc/on_cooldown_finish), cooldown_length, TIMER_STOPPABLE)
	button.add_overlay(visual_references[VREF_IMAGE_XENO_CLOCK])


/datum/action/xeno_action/proc/cooldown_remaining()
	return timeleft(cooldown_id) * 0.1


//override this for cooldown completion.
/datum/action/xeno_action/proc/on_cooldown_finish()
	cooldown_id = null
	if(!button)
		CRASH("no button object on finishing xeno action cooldown")
	button.cut_overlay(visual_references[VREF_IMAGE_XENO_CLOCK])

/datum/action/xeno_action/handle_button_status_visuals()
	if(!can_use_action(TRUE, XACT_IGNORE_COOLDOWN))
		button.color = "#80000080" // rgb(128,0,0,128)
	else if(!action_cooldown_check())
		button.color = "#f0b400c8" // rgb(240,180,0,200)
	else
		button.color = "#ffffffff" // rgb(255,255,255,255)

/datum/action/xeno_action/activable/Destroy()
	var/mob/living/carbon/xenomorph/X = owner
	if(X.selected_ability == src)
		deselect()
	return ..()

/datum/action/xeno_action/activable/alternate_action_activate()
	INVOKE_ASYNC(src, .proc/action_activate)

/datum/action/xeno_action/activable/action_activate()
	var/mob/living/carbon/xenomorph/X = owner
	if(X.selected_ability == src)
		return
	if(X.selected_ability)
		X.selected_ability.deselect()
	select()

/datum/action/xeno_action/activable/keybind_activation()
	. = COMSIG_KB_ACTIVATED
	if(CHECK_BITFIELD(keybind_flags, XACT_KEYBIND_USE_ABILITY))
		if(can_use_ability(null, FALSE, XACT_IGNORE_SELECTED_ABILITY))
			use_ability()
		return

	if(can_use_action(FALSE, NONE, TRUE)) // just for selecting
		action_activate()

/datum/action/xeno_action/activable/proc/deselect()
	var/mob/living/carbon/xenomorph/X = owner
	remove_selected_frame()
	X.selected_ability = null
	on_deactivation()

/datum/action/xeno_action/activable/proc/select()
	var/mob/living/carbon/xenomorph/X = owner
	add_selected_frame()
	X.selected_ability = src
	on_activation()

/datum/action/xeno_action/activable/action_activate()
	var/mob/living/carbon/xenomorph/X = owner
	if(X.selected_ability == src)
		deselect()
	else
		if(X.selected_ability)
			X.selected_ability.deselect()
		select()
	return ..()


/datum/action/xeno_action/activable/remove_action(mob/living/carbon/xenomorph/X)
	if(X.selected_ability == src)
		X.selected_ability = null
	return ..()


///the thing to do when the selected action ability is selected and triggered by middle_click
/datum/action/xeno_action/activable/proc/use_ability(atom/A)
	return

/datum/action/xeno_action/activable/can_use_action(silent = FALSE, override_flags, selecting = FALSE)
	if(selecting)
		return ..(silent, XACT_IGNORE_COOLDOWN|XACT_IGNORE_PLASMA|XACT_USE_STAGGERED)
	return ..()

//override this
/datum/action/xeno_action/activable/proc/can_use_ability(atom/A, silent = FALSE, override_flags)
	if(QDELETED(owner))
		return FALSE

	var/flags_to_check = use_state_flags|override_flags

	var/mob/living/carbon/xenomorph/X = owner
	if(!CHECK_BITFIELD(flags_to_check, XACT_IGNORE_SELECTED_ABILITY) && X.selected_ability != src)
		return FALSE
	. = can_use_action(silent, override_flags)
	if(!CHECK_BITFIELD(flags_to_check, XACT_TARGET_SELF) && A == owner)
		return FALSE

/datum/action/xeno_action/activable/proc/can_activate()
	return TRUE

/datum/action/xeno_action/activable/proc/on_activation()
	return

/datum/action/xeno_action/activable/proc/on_deactivation()
	return
