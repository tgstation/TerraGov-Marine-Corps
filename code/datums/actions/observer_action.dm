
/datum/action/observer_action
	var/icon_icon = 'icons/mob/actions.dmi' //This is the file for the ACTION icon
	var/icon_icon_state = "default" //And this is the state for the action icon
	var/button_icon_state = "template" //The state for the button background


/datum/action/observer_action/update_button_icon()
	if(!button)
		return

	button.name = name
	button.desc = desc

	if(icon_icon && icon_icon_state)
		button.cut_overlays(TRUE)
		button.add_overlay(mutable_appearance(icon_icon, icon_icon_state))

	if(button_icon_state)
		button.icon_state = button_icon_state

	return TRUE

/datum/action/observer_action/crew_manifest
	name = "Show Crew manifest"
	icon_icon = 'icons/obj/items/books.dmi'
	icon_icon_state = "book"

/datum/action/observer_action/crew_manifest/action_activate()
	. = ..()
	var/mob/dead/observer/O = owner
	if(!istype(O))
		return // Shouldn't have this action
	O.view_manifest()


/datum/action/observer_action/show_hivestatus
	name = "Show Hive status"
	icon_icon_state = "watch_xeno"

/datum/action/observer_action/show_hivestatus/action_activate()
	. = ..()
	check_hive_status()
