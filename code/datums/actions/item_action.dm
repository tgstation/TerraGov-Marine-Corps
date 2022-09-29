
/datum/action/item_action
	name = ""
	/**
	 *the item that has this action in its list of actions. Is not necessarily the target
	 * e.g. gun attachment action: target = attachment, holder = gun.
	 */
	var/obj/item/holder_item

/datum/action/item_action/New(Target, obj/item/holder)
	. = ..()
	if(!holder)
		holder = target
	holder_item = holder
	LAZYADD(holder_item.actions, src)
	if(!name)
		name = "Use [target]"
	button.name = name

/datum/action/item_action/Destroy()
	LAZYREMOVE(holder_item.actions, src)
	holder_item = null
	return ..()

/datum/action/item_action/action_activate()
	if(target)
		var/obj/item/I = target
		I.ui_action_click(owner, src, holder_item)

/datum/action/item_action/can_use_action()
	if(QDELETED(owner) || owner.incapacitated() || owner.lying_angle)
		return FALSE
	return TRUE

/datum/action/item_action/update_button_icon()
	button.cut_overlay(list(visual_references[VREF_IMAGE_LINKED_OBJ]))
	var/obj/item/I = target
	var/image/item_image = image(I.icon, button, I.icon_state, ABOVE_HUD_LAYER)
	item_image.plane = ABOVE_HUD_PLANE
	visual_references[VREF_IMAGE_LINKED_OBJ] = item_image
	button.add_overlay(list(item_image))
	..()

/datum/action/item_action/toggle/New(Target)
	. = ..()
	name = "Toggle [target]"
	button.name = name

/datum/action/item_action/toggle/suit_toggle/update_button_icon()
	. = ..()
	if(visual_references[VREF_IMAGE_SELECTED])
		button.cut_overlay(list(visual_references[VREF_IMAGE_SELECTED]))
	if(!holder_item.light_on)
		return
	visual_references[VREF_IMAGE_SELECTED] = image('icons/Marine/marine-weapons.dmi', src, "active")
	button.add_overlay(list(visual_references[VREF_IMAGE_SELECTED]))

/datum/action/item_action/toggle/motion_detector/action_activate()
	. = ..()
	update_button_icon()

/datum/action/item_action/firemode
	var/action_firemode
	var/obj/item/weapon/gun/holder_gun
	var/static/atom/movable/vis_obj/action/fmode_single/semiauto = new
	var/static/atom/movable/vis_obj/action/fmode_burst/burstfire = new
	var/static/atom/movable/vis_obj/action/fmode_single_auto/fullauto = new
	var/static/atom/movable/vis_obj/action/fmode_burst_auto/autoburst = new
	var/atom/movable/vis_obj/action/current_action_vis_obj


/datum/action/item_action/firemode/New()
	. = ..()
	holder_gun = holder_item
	button.overlays.Cut()
	update_button_icon()


/datum/action/item_action/firemode/update_button_icon()
	if(holder_gun.gun_firemode == action_firemode)
		return
	if(visual_references[VREF_IMAGE_SELECTED])
		button.cut_overlay(list(visual_references[VREF_IMAGE_SELECTED]))
	var/firemode_string = "fmode_"
	switch(holder_gun.gun_firemode)
		if(GUN_FIREMODE_SEMIAUTO)
			button.name = "Semi-Automatic Firemode"
			firemode_string += "single"
		if(GUN_FIREMODE_BURSTFIRE)
			button.name = "Burst Firemode"
			firemode_string += "burst"
		if(GUN_FIREMODE_AUTOMATIC)
			button.name = "Automatic Firemode"
			firemode_string += "single_auto"
		if(GUN_FIREMODE_AUTOBURST)
			button.name = "Automatic Burst Firemode"
			firemode_string += "burst_auto"
	visual_references[VREF_IMAGE_SELECTED] = image(action_icon, button, firemode_string, ABOVE_HUD_LAYER)
	button.add_overlay(visual_references[VREF_IMAGE_SELECTED])
	action_firemode = holder_gun.gun_firemode

/datum/action/item_action/aim_mode
	name = "Take Aim"

/datum/action/item_action/aim_mode/give_action(mob/M)
	. = ..()
	RegisterSignal(M, COMSIG_KB_AIMMODE, .proc/action_activate)

/datum/action/item_action/aim_mode/remove_action(mob/M)
	UnregisterSignal(M, COMSIG_KB_AIMMODE, .proc/action_activate)
	return ..()

/datum/action/item_action/aim_mode/update_button_icon()
	button.overlays.Cut()
	button.overlays += image('icons/mob/actions.dmi', null, "aim_mode", ABOVE_HUD_LAYER)

/datum/action/item_action/aim_mode/action_activate()
	var/obj/item/weapon/gun/I = target
	I.toggle_auto_aim_mode(owner)


/datum/action/item_action/toggle_hydro
	/// This references the TL84 flamer
	var/obj/item/weapon/gun/flamer/big_flamer/marinestandard/holder_flamer

/datum/action/item_action/toggle_hydro/New()
	. = ..()
	holder_flamer = holder_item
	RegisterSignal(holder_flamer, COMSIG_ITEM_HYDRO_CANNON_TOGGLED, .proc/update_toggle_button_icon)


/datum/action/item_action/toggle_hydro/update_button_icon()
	button.overlays.Cut()
	if (holder_flamer.hydro_active)
		button.overlays += image('icons/mob/actions.dmi', null, "TL_84_Water", ABOVE_HUD_LAYER)
		return
	button.overlays += image('icons/mob/actions.dmi', null, "TL_84_Flame", ABOVE_HUD_LAYER)

///Signal handler for when the hydro cannon is activated
/datum/action/item_action/toggle_hydro/proc/update_toggle_button_icon()
	SIGNAL_HANDLER
	update_button_icon()

/datum/action/item_action/toggle_hydro/Destroy()
	holder_flamer=null
	return ..()
