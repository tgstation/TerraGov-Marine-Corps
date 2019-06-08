
/datum/action
	var/name = "Generic Action"
	var/desc
	var/obj/target = null
	var/obj/screen/action_button/button = null
	var/mob/living/owner

/datum/action/New(Target)
	target = Target
	button = new
	if(target)
		var/image/IMG
		if(ispath(target))
			IMG = image(initial(target.icon), button, initial(target.icon_state))
		else
			IMG = image(target.icon, button, target.icon_state)
		IMG.pixel_x = 0
		IMG.pixel_y = 0
		button.overlays += IMG
	button.source_action = src
	button.name = name
	if(desc)
		button.desc = desc

/datum/action/Destroy()
	if(owner)
		remove_action(owner)
	qdel(button)
	button = null
	target = null

/datum/action/proc/should_show()
	return TRUE

/datum/action/proc/update_button_icon()
	return

/datum/action/proc/action_activate()
	return

/datum/action/proc/fail_activate()
	return

/datum/action/proc/can_use_action()
	if(owner) return TRUE

/datum/action/proc/give_action(mob/living/L)
	if(owner)
		if(owner == L)
			return
		remove_action(owner)
	owner = L
	L.actions += src
	if(L.client)
		L.client.screen += button
	L.update_action_buttons()
	L.actions_by_path[type] = src

/datum/action/proc/remove_action(mob/living/L)
	if(L.client)
		L.client.screen -= button
	L.actions_by_path[type] = null
	L.actions -= src
	L.update_action_buttons()
	owner = null



/datum/action/item_action
	name = "Use item"
	var/obj/item/holder_item //the item that has this action in its list of actions. Is not necessarily the target
							//e.g. gun attachment action: target = attachment, holder = gun.

/datum/action/item_action/New(Target, obj/item/holder)
	..()
	if(!holder)
		holder = target
	holder_item = holder
	holder_item.actions += src
	name = "Use [target]"
	button.name = name

/datum/action/item_action/Destroy()
	holder_item.actions -= src
	holder_item = null
	..()

/datum/action/item_action/action_activate()
	if(target)
		var/obj/item/I = target
		I.ui_action_click(owner, holder_item)

/datum/action/item_action/can_use_action()
	if(owner && !owner.incapacitated() && !owner.lying)
		return TRUE

/datum/action/item_action/update_button_icon()
	button.overlays.Cut()
	var/obj/item/I = target
	I.layer = ABOVE_HUD_LAYER
	I.plane = ABOVE_HUD_PLANE
	button.overlays += I
	I.layer = initial(I.layer)
	I.plane = initial(I.plane)


/datum/action/item_action/toggle/New(Target)
	..()
	name = "Toggle [target]"
	button.name = name


//Preset for general and toggled actions
/datum/action/innate
	var/active = FALSE
	var/icon_icon = 'icons/mob/actions.dmi' //This is the file for the ACTION icon
	var/icon_icon_state = "default" //And this is the state for the action icon
	var/button_icon_state = "template" //The state for the button background


/datum/action/innate/action_activate()
	if(!can_use_action())
		return FALSE
	if(!active)
		Activate()
	else
		Deactivate()
	return TRUE


/datum/action/innate/update_button_icon()
	if(!button)
		return

	button.name = name
	button.desc = desc

	if(icon_icon && icon_icon_state)
		button.cut_overlays(TRUE)
		button.add_overlay(mutable_appearance(icon_icon, icon_icon_state))

	if(button_icon_state)
		button.icon_state = button_icon_state

	if(can_use_action())
		button.color = rgb(255, 255, 255, 255)
	else
		button.color = rgb(128, 0, 0, 128)
	
	return TRUE


/datum/action/innate/give_action()
	. = ..()
	update_button_icon()


/datum/action/innate/proc/Activate()
	return


/datum/action/innate/proc/Deactivate()
	return



#define XACT_USE_INCAP			(1 << 0) // ignore incapacitated
#define XACT_USE_LYING			(1 << 1) // ignore lying down
#define XACT_USE_BUCKLED		(1 << 2) // ignore buckled
#define XACT_USE_STAGGERED		(1 << 3) // ignore staggered
#define XACT_USE_FORTIFIED		(1 << 4) // ignore fortified
#define XACT_USE_CRESTED		(1 << 5) // ignore being in crest defense
#define XACT_USE_NOTTURF		(1 << 6) // ignore not being on a turf (like in a vent)
#define XACT_USE_BUSY			(1 << 7) // ignore being in a do_after or similar
#define XACT_USE_AGILITY		(1 << 8) // ignore agility mode
#define XACT_TARGET_SELF		(1 << 9) // allow self-targetting
#define XACT_IGNORE_PLASMA		(1 << 10) // ignore plasma cost
#define XACT_IGNORE_COOLDOWN	(1 << 11) // ignore cooldown
#define XACT_IGNORE_DEAD_TARGET	(1 << 12) // bypass checks of a dead target
#define XACT_IGNORE_SELECTED_ABILITY	(1 << 13) // bypass the check of the selected ability

#define XACT_KEYBIND_USE_ABILITY (1 << 0) // immediately activate even if selectable

/datum/action/xeno_action
	var/action_icon_state
	var/plasma_cost = 0
	var/mechanics_text = "This ability not found in codex." //codex. If you are going to add an explanation for an ability. don't use stats, give a very brief explanation of how to use it.
	var/use_state_flags = NONE // bypass use limitations checked by can_use_action()
	var/on_cooldown
	var/last_use
	var/cooldown_timer
	var/ability_name
	var/keybind_flags
	var/image/cooldown_image
	var/keybind_signal

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
	if(keybind_signal)
		RegisterSignal(L, keybind_signal, .proc/keybind_activation)

/datum/action/xeno_action/remove_action(mob/living/L)
	. = ..()
	if(keybind_signal)
		UnregisterSignal(L, keybind_signal)

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
			to_chat(owner, "<span class='warning'>You can't use [ability_name] yet, wait [cooldown_remaining()] seconds!</span>")
		return FALSE

	if(!CHECK_BITFIELD(flags_to_check, XACT_USE_INCAP) && X.incapacitated())
		if(!silent)
			to_chat(owner, "<span class='warning'>You can't do this while incapacitated!</span>")
		return FALSE

	if(!CHECK_BITFIELD(flags_to_check, XACT_USE_LYING) && X.lying)
		if(!silent)
			to_chat(owner, "<span class='warning'>You can't do this while lying down!</span>")
		return FALSE

	if(!CHECK_BITFIELD(flags_to_check, XACT_USE_BUCKLED) && X.buckled)
		if(!silent)
			to_chat(owner, "<span class='warning'>You can't do this while buckled!</span>")
		return FALSE

	if(!CHECK_BITFIELD(flags_to_check, XACT_USE_STAGGERED) && X.stagger)
		if(!silent)
			to_chat(owner, "<span class='warning'>You can't do this while staggered!</span>")
		return FALSE

	if(!CHECK_BITFIELD(flags_to_check, XACT_USE_FORTIFIED) && X.fortify)
		if(!silent)
			to_chat(owner, "<span class='warning'>You can't do this while fortified!</span>")
		return FALSE

	if(!CHECK_BITFIELD(flags_to_check, XACT_USE_CRESTED) && X.crest_defense)
		if(!silent)
			to_chat(owner, "<span class='warning'>You can't do this while in crest defense!</span>")
		return FALSE

	if(!CHECK_BITFIELD(flags_to_check, XACT_USE_NOTTURF) && !isturf(X.loc))
		if(!silent)
			to_chat(owner, "<span class='warning'>You can't do this here!</span>")
		return FALSE

	if(!CHECK_BITFIELD(flags_to_check, XACT_USE_BUSY) && X.action_busy)
		if(!silent)
			to_chat(owner, "<span class='warning'>You're busy doing something right now!</span>")
		return FALSE

	if(!CHECK_BITFIELD(flags_to_check, XACT_USE_AGILITY) && X.agility)
		if(!silent)
			to_chat(owner, "<span class='warning'>You can't do that in agility mode!</span>")
		return FALSE

	if(!CHECK_BITFIELD(flags_to_check, XACT_IGNORE_PLASMA) && X.plasma_stored < plasma_cost)
		if(!silent)
			to_chat(owner, "<span class='warning'>You don't have enough plasma to do this!</span>")
		return FALSE

	return TRUE

/datum/action/xeno_action/fail_activate()
	update_button_icon()

/datum/action/xeno_action/proc/succeed_activate()
	var/mob/living/carbon/xenomorph/X = owner
	if(plasma_cost)
		X.use_plasma(plasma_cost)

//checks if the linked ability is on some cooldown.
//The action can still be activated by clicking the button
/datum/action/xeno_action/proc/action_cooldown_check()
	return !on_cooldown

/datum/action/xeno_action/proc/clear_cooldown()
	for(var/timer in active_timers)
		qdel(timer)
		on_cooldown_finish()

/datum/action/xeno_action/proc/get_cooldown()
	return cooldown_timer

/datum/action/xeno_action/proc/add_cooldown()
	if(!length(active_timers)) // stop doubling up
		last_use = world.time
		on_cooldown = TRUE
		addtimer(CALLBACK(src, .proc/on_cooldown_finish), get_cooldown())
		button.overlays += cooldown_image
		update_button_icon()

/datum/action/xeno_action/proc/cooldown_remaining()
	for(var/i in active_timers)
		var/datum/timedevent/timer = i
		return (timer.timeToRun - world.time) * 0.1
	return 0

//override this for cooldown completion.
/datum/action/xeno_action/proc/on_cooldown_finish()
	on_cooldown = FALSE
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
	var/image/selected_frame

/datum/action/xeno_action/activable/New()
	. = ..()
	selected_frame = image('icons/mob/actions.dmi', null, "selected_frame")
	selected_frame.appearance_flags = RESET_COLOR

/datum/action/xeno_action/activable/keybind_activation()
	. = COMSIG_KB_ACTIVATED
	if(CHECK_BITFIELD(keybind_flags, XACT_KEYBIND_USE_ABILITY))
		if(can_use_ability(null, FALSE, XACT_IGNORE_SELECTED_ABILITY))
			use_ability()
		return

	if(can_use_action(FALSE, null, TRUE)) // just for selecting
		action_activate()

/datum/action/xeno_action/activable/proc/deselect()
	var/mob/living/carbon/xenomorph/X = owner
	button.overlays -= selected_frame
	X.selected_ability = null
	on_deactivation()

/datum/action/xeno_action/activable/proc/select()
	var/mob/living/carbon/xenomorph/X = owner
	button.overlays += selected_frame
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
	..()
	if(X.selected_ability == src)
		X.selected_ability = null

//the thing to do when the selected action ability is selected and triggered by middle_click
/datum/action/xeno_action/activable/proc/use_ability(atom/A)
	return

/datum/action/xeno_action/activable/can_use_action(silent = FALSE, override_flags, selecting = FALSE)
	if(selecting)
		return ..(silent, XACT_IGNORE_COOLDOWN|XACT_IGNORE_PLASMA|XACT_USE_STAGGERED)
	return ..()

//override this
/datum/action/xeno_action/activable/proc/can_use_ability(atom/A, silent = FALSE, override_flags)
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

/datum/action/skill
	var/skill_name
	var/skill_min

/datum/action/skill/should_show()
	return can_use_action()

/datum/action/skill/can_use_action()
	var/mob/living/carbon/human/human = owner
	return istype(human) && human.mind && human.mind.cm_skills && human.mind.cm_skills.vars[skill_name] >= skill_min

/datum/action/skill/fail_activate()
	if(owner)
		owner << "<span class='warning'>You are not competent enough to do that.</span>" // This message shouldn't show since incompetent people shouldn't have the button, but JIC.

//This is the proc used to update all the action buttons.
/mob/proc/update_action_buttons(reload_screen)
	if(!hud_used || !client)
		return

	if(hud_used.hud_version == HUD_STYLE_NOHUD)
		return

	var/button_number = 0

	if(hud_used.action_buttons_hidden)
		for(var/datum/action/A in actions)
			A.button.screen_loc = null
			if(reload_screen)
				client.screen += A.button
	else
		for(var/datum/action/A in actions)
			if(A.should_show())
				A.update_button_icon()
				button_number++
				var/obj/screen/action_button/B = A.button
				B.screen_loc = B.get_button_screen_loc(button_number)
				if(reload_screen)
					client.screen += B
			else
				A.button.screen_loc = null
				if(reload_screen)
					client.screen += A.button

		if(!button_number)
			hud_used.hide_actions_toggle.screen_loc = null
			if(reload_screen)
				client.screen += hud_used.hide_actions_toggle
			return

	hud_used.hide_actions_toggle.screen_loc = hud_used.hide_actions_toggle.get_button_screen_loc(button_number+1)

	if(reload_screen)
		client.screen += hud_used.hide_actions_toggle

