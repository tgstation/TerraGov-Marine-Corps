
/datum/action/item_action
	name = ""
	/**
	 *the item that has this action in its list of actions. Is not necessarily the target
	 * e.g. gun attachment action: target = attachment, holder = gun.
	 */
	var/obj/item/holder_item
	/// Defines wheter we overlay the image of the obj we are linked to
	var/use_obj_appeareance = TRUE

/datum/action/item_action/New(Target, obj/item/holder, _action_icon, _action_icon_state)
	if(_action_icon)
		action_icon = _action_icon
	if(_action_icon_state)
		action_icon_state = _action_icon_state
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
	if(!target)
		return FALSE
	var/obj/item/I = target
	return I.ui_action_click(owner, src, holder_item)

/datum/action/item_action/can_use_action(silent, override_flags, selecting)
	if(QDELETED(owner) || owner.incapacitated() || owner.lying_angle)
		return FALSE
	return TRUE

/datum/action/item_action/update_button_icon()
	if(visual_references[VREF_MUTABLE_LINKED_OBJ])
		button.cut_overlay(visual_references[VREF_MUTABLE_LINKED_OBJ])
	if(use_obj_appeareance)
		var/obj/item/I = target
		// -0.5 so its below maptext and above the selected frames
		var/item_image = mutable_appearance(I.icon, I.icon_state, ACTION_LAYER_IMAGE_ONTOP)
		visual_references[VREF_MUTABLE_LINKED_OBJ] = item_image
		button.add_overlay(item_image)
	else
		visual_references[VREF_MUTABLE_LINKED_OBJ] = null
	return ..()

/datum/action/item_action/toggle
	action_type = ACTION_TOGGLE

/datum/action/item_action/toggle/New(Target)
	. = ..()
	name = "Toggle [target]"
	button.name = name

/datum/action/item_action/toggle/action_activate()
	. = ..()
	if(!.)
		return
	set_toggle(!toggled)

/datum/action/item_action/toggle/remove_action(mob/M)
	deselect()
	return ..()

/datum/action/item_action/toggle/suit_toggle
	keybinding_signals = list(KEYBINDING_NORMAL = COMSIG_KB_SUITLIGHT)

/datum/action/item_action/toggle/suit_toggle/light/ai_should_start_consider()
	if(SSticker?.mode?.round_type_flags & MODE_TWO_HUMAN_FACTIONS)
		return FALSE //HvH doesn't have full dark so its just a detriment
	return TRUE

/datum/action/item_action/toggle/suit_toggle/light/ai_should_use(atom/target)
	if(!holder_item)
		return FALSE
	if(holder_item.light_on)
		return FALSE
	return TRUE

/datum/action/item_action/firemode
	// just here so players see what key is it bound to
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_KB_FIREMODE,
	)
	use_obj_appeareance = FALSE
	var/action_firemode
	var/obj/item/weapon/gun/holder_gun


/datum/action/item_action/firemode/New()
	. = ..()
	holder_gun = holder_item

/datum/action/item_action/firemode/action_activate()
	. = ..()
	if(!.)
		return
	update_button_icon()


/datum/action/item_action/firemode/update_button_icon()
	if(holder_gun.gun_firemode == action_firemode)
		return
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
	action_icon_state = firemode_string
	action_firemode = holder_gun.gun_firemode
	return ..()

/datum/action/item_action/firemode/handle_button_status_visuals()
	button.color = rgb(255,255,255,255)

/datum/action/item_action/aim_mode
	name = "Take Aim"
	action_icon_state = "aim_mode"
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_KB_AIMMODE,
	)
	use_obj_appeareance = FALSE

/datum/action/item_action/aim_mode/action_activate()
	var/obj/item/weapon/gun/I = target
	I.toggle_auto_aim_mode(owner)
