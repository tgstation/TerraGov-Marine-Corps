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
