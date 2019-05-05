
/datum/action
	var/name = "Generic Action"
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

/datum/action/proc/remove_action(mob/living/L)
	if(L.client)
		L.client.screen -= button
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
	var/old = I.layer
	I.layer = FLOAT_LAYER
	button.overlays += I
	I.layer = old


/datum/action/item_action/toggle/New(Target)
	..()
	name = "Toggle [target]"
	button.name = name





/datum/action/xeno_action
	var/action_icon_state
	var/plasma_cost = 0
	var/mechanics_text = "This ability not found in codex." //codex. If you are going to add an explanation for an ability. don't use stats, give a very brief explanation of how to use it.

/datum/action/xeno_action/New(Target)
	..()
	button.overlays += image('icons/mob/actions.dmi', button, action_icon_state)

/datum/action/xeno_action/can_use_action()
	var/mob/living/carbon/Xenomorph/X = owner
	if(X && !X.incapacitated() && !X.lying && !X.buckled && X.plasma_stored >= plasma_cost && !X.stagger)
		return TRUE


//checks if the linked ability is on some cooldown.
//The action can still be activated by clicking the button
/datum/action/xeno_action/proc/action_cooldown_check()
	return TRUE

/datum/action/xeno_action/update_button_icon()
	if(!can_use_action())
		button.color = rgb(128,0,0,128)
	else if(!action_cooldown_check())
		button.color = rgb(240,180,0,200)
	else
		button.color = rgb(255,255,255,255)



/datum/action/xeno_action/activable
	var/ability_name

/datum/action/xeno_action/activable/action_activate()
	var/mob/living/carbon/Xenomorph/X = owner
	if(plasma_cost)
		if(!X.check_plasma(plasma_cost))
			return
	if(X.selected_ability == src)
		to_chat(X, "You will no longer use [ability_name] with [X.middle_mouse_toggle ? "middle-click" :"shift-click"].")
		button.icon_state = "template"
		X.selected_ability.on_deactivation()
		X.selected_ability = null
	else
		to_chat(X, "You will now use [ability_name] with [X.middle_mouse_toggle ? "middle-click" :"shift-click"].")
		if(X.selected_ability)
			X.selected_ability.button.icon_state = "template"
			X.selected_ability.on_deactivation()
			X.selected_ability = null
		button.icon_state = "template_on"
		X.selected_ability = src
		X.selected_ability.on_activation()
	if(plasma_cost)
		X.use_plasma(plasma_cost) //after on_activation so the button's appearance is updated correctly.


/datum/action/xeno_action/activable/remove_action(mob/living/carbon/Xenomorph/X)
	..()
	if(X.selected_ability == src)
		X.selected_ability = null

//the thing to do when the selected action ability is selected and triggered by middle_click
/datum/action/xeno_action/activable/proc/use_ability(atom/A)
	return

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
	return

/mob/living/update_action_buttons(reload_screen)
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

