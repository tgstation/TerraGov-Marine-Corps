
/datum/action/item_action
	name = "Use item"
	var/obj/item/holder_item //the item that has this action in its list of actions. Is not necessarily the target
							//e.g. gun attachment action: target = attachment, holder = gun.

/datum/action/item_action/New(Target, obj/item/holder)
	. = ..()
	if(!holder)
		holder = target
	holder_item = holder
	holder_item.actions += src
	name = "Use [target]"
	button.name = name

/datum/action/item_action/Destroy()
	holder_item.actions -= src
	holder_item = null
	return ..()

/datum/action/item_action/action_activate()
	if(target)
		var/obj/item/I = target
		I.ui_action_click(owner, holder_item)

/datum/action/item_action/can_use_action()
	if(QDELETED(owner) || owner.incapacitated() || owner.lying)
		return FALSE
	return TRUE

/datum/action/item_action/update_button_icon()
	button.overlays.Cut()
	var/obj/item/I = target
	var/old_layer = I.layer
	var/old_plane = I.plane
	I.layer = ABOVE_HUD_LAYER
	I.plane = ABOVE_HUD_PLANE
	button.overlays += I
	I.layer = old_layer
	I.plane = old_plane


/datum/action/item_action/toggle/New(Target)
	. = ..()
	name = "Toggle [target]"
	button.name = name



