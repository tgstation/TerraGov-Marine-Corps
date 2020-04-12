/datum/action/xeno_action
	var/plasma_cost = 0
	var/mechanics_text = "This ability not found in codex." //codex. If you are going to add an explanation for an ability. don't use stats, give a very brief explanation of how to use it.
	var/use_state_flags = NONE // bypass use limitations checked by can_use_action()
	var/last_use
	var/cooldown_timer
	var/ability_name
	var/keybind_flags
	var/image/cooldown_image
	var/keybind_signal
	var/cooldown_id

/datum/action/xeno_action/New(Target)
	. = ..()
	if(plasma_cost)
		name = "[name] ([plasma_cost])"
	button.overlays += image('icons/mob/actions.dmi', button, action_icon_state)
	cooldown_image = image('icons/effects/progressicons.dmi', null, "busy_clock")
	cooldown_image.pixel_y = 7
	cooldown_image.appearance_flags = RESET_COLOR|RESET_ALPHA

/datum/action/xeno_action/give_action(mob/living/L)
	. = ..()
	var/mob/living/carbon/xenomorph/X = L
	X.xeno_abilities += src
	if(keybind_signal)
		RegisterSignal(L, keybind_signal, .proc/keybind_activation)


/datum/action/xeno_action/remove_action(mob/living/L)
	if(keybind_signal)
		UnregisterSignal(L, keybind_signal)
	if(cooldown_id)
		deltimer(cooldown_id)
	var/mob/living/carbon/xenomorph/X = L
	X.xeno_abilities -= src
	return ..()


/datum/action/xeno_action/proc/keybind_activation()
	if(can_use_action())
		action_activate()
	return COMSIG_KB_ACTIVATED

/datum/action/xeno_action/can_use_action(silent = FALSE, override_flags)
	var/mob/living/carbon/xenomorph/X = owner
	if(!X)
		return FALSE
	var/flags_to_check = use_state_flags|override_flags

	if(!CHECK_BITFIELD(flags_to_check, XACT_IGNORE_COOLDOWN) && !action_cooldown_check())
		if(!silent)
			to_chat(owner, "<span class='warning'>We can't use [ability_name] yet, we must wait [cooldown_remaining()] seconds!</span>")
		return FALSE

	if(!CHECK_BITFIELD(flags_to_check, XACT_USE_INCAP) && X.incapacitated())
		if(!silent)
			to_chat(owner, "<span class='warning'>We can't do this while incapacitated!</span>")
		return FALSE

	if(!CHECK_BITFIELD(flags_to_check, XACT_USE_LYING) && X.lying_angle)
		if(!silent)
			to_chat(owner, "<span class='warning'>We can't do this while lying down!</span>")
		return FALSE

	if(!CHECK_BITFIELD(flags_to_check, XACT_USE_BUCKLED) && X.buckled)
		if(!silent)
			to_chat(owner, "<span class='warning'>We can't do this while buckled!</span>")
		return FALSE

	if(!CHECK_BITFIELD(flags_to_check, XACT_USE_STAGGERED) && X.stagger)
		if(!silent)
			to_chat(owner, "<span class='warning'>We can't do this while staggered!</span>")
		return FALSE

	if(!CHECK_BITFIELD(flags_to_check, XACT_USE_FORTIFIED) && X.fortify)
		if(!silent)
			to_chat(owner, "<span class='warning'>We can't do this while fortified!</span>")
		return FALSE

	if(!CHECK_BITFIELD(flags_to_check, XACT_USE_CRESTED) && X.crest_defense)
		if(!silent)
			to_chat(owner, "<span class='warning'>We can't do this while in crest defense!</span>")
		return FALSE

	if(!CHECK_BITFIELD(flags_to_check, XACT_USE_NOTTURF) && !isturf(X.loc))
		if(!silent)
			to_chat(owner, "<span class='warning'>We can't do this here!</span>")
		return FALSE

	if(!CHECK_BITFIELD(flags_to_check, XACT_USE_BUSY) && X.action_busy)
		if(!silent)
			to_chat(owner, "<span class='warning'>We're busy doing something right now!</span>")
		return FALSE

	if(!CHECK_BITFIELD(flags_to_check, XACT_USE_AGILITY) && X.agility)
		if(!silent)
			to_chat(owner, "<span class='warning'>We can't do this in agility mode!</span>")
		return FALSE

	if(!CHECK_BITFIELD(flags_to_check, XACT_IGNORE_PLASMA) && X.plasma_stored < plasma_cost)
		if(!silent)
			to_chat(owner, "<span class='warning'>We don't have enough plasma, we need [plasma_cost - X.plasma_stored] more.</span>")
		return FALSE

	return TRUE

/datum/action/xeno_action/fail_activate()
	update_button_icon()

/datum/action/xeno_action/proc/succeed_activate()
	var/mob/living/carbon/xenomorph/X = owner
	if(plasma_cost && !QDELETED(owner))
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


/datum/action/xeno_action/proc/add_cooldown()
	if(cooldown_id) // stop doubling up
		return
	last_use = world.time
	cooldown_id = addtimer(CALLBACK(src, .proc/on_cooldown_finish), get_cooldown(), TIMER_STOPPABLE)
	button.overlays += cooldown_image
	update_button_icon()


/datum/action/xeno_action/proc/cooldown_remaining()
	return timeleft(cooldown_id) * 0.1


//override this for cooldown completion.
/datum/action/xeno_action/proc/on_cooldown_finish()
	cooldown_id = null
	if(!button)
		CRASH("no button object on finishing xeno action cooldown")
	button.overlays -= cooldown_image
	update_button_icon()

/datum/action/xeno_action/update_button_icon()
	if(!can_use_action(TRUE, XACT_IGNORE_COOLDOWN))
		button.color = "#80000080" // rgb(128,0,0,128)
	else if(!action_cooldown_check())
		button.color = "#f0b400c8" // rgb(240,180,0,200)
	else
		button.color = "#ffffffff" // rgb(255,255,255,255)



/datum/action/xeno_action/activable

/datum/action/xeno_action/activable/New()
	. = ..()


/datum/action/xeno_action/activable/Destroy()
	var/mob/living/carbon/xenomorph/X = owner
	if(X.selected_ability == src)
		deselect()
	return ..()


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
		to_chat(X, "You will no longer use [ability_name] with [X.middle_mouse_toggle ? "middle-click" :"shift-click"].")
		deselect()
	else
		to_chat(X, "You will now use [ability_name] with [X.middle_mouse_toggle ? "middle-click" :"shift-click"].")
		if(X.selected_ability)
			X.selected_ability.deselect()
		select()
	return ..()


/datum/action/xeno_action/activable/remove_action(mob/living/carbon/xenomorph/X)
	if(X.selected_ability == src)
		X.selected_ability = null
	return ..()


//the thing to do when the selected action ability is selected and triggered by middle_click
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
