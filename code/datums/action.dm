
/datum/action
	var/name = "Generic Action"
	var/obj/target = null
	var/obj/screen/action_button/button = null
	var/mob/living/owner

	New(Target)
		target = Target
		button = new
		var/image/IMG = image(target.icon, button, target.icon_state)
		IMG.pixel_x = 0
		IMG.pixel_y = 0
		button.overlays += IMG
		button.source_action = src
		button.name = name

	Dispose()
		if(owner)
			remove_action(owner)
		cdel(button)
		button = null
		target = null

/datum/action/proc/update_button_icon()
	return

/datum/action/proc/action_activate()
	if(can_use_action())
		return TRUE

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

	New(Target)
		..()
		var/obj/item/I = target
		I.actions += src
		name = "Use [I]"
		button.name = name

	Dispose()
		var/obj/item/I = target
		I.actions -= src
		..()

	action_activate()
		. = ..()
		if(.)
			if(target)
				var/obj/item/I = target
				I.ui_action_click(owner)
				return TRUE

	can_use_action()
		. = ..()
		if(.)
			if(owner.stat || owner.is_mob_restrained() || owner.stunned || owner.lying)
				return FALSE

	update_button_icon()
		button.overlays.Cut()
		var/obj/item/I = target
		var/old = I.layer
		I.layer = FLOAT_LAYER
		button.overlays += I
		I.layer = old

/datum/action/item_action/toggle
	New(Target)
		..()
		name = "Toggle [target]"
		button.name = name




//This is the proc used to update all the action buttons.
/mob/proc/update_action_buttons(reload_screen)
	return

/mob/living/update_action_buttons(reload_screen)
	if(!hud_used || !client)
		return

	if(hud_used.hud_shown != HUD_STYLE_STANDARD)
		return

	var/button_number = 0

	for(var/datum/action/A in actions)
		button_number++
		var/obj/screen/action_button/B = A.button
		if(client && client.prefs.UI_style)
			B.icon = ui_style2icon(client.prefs.UI_style)
		B.screen_loc = B.get_button_screen_loc(button_number)
		if(reload_screen)
			client.screen += B

