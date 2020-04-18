
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
		I.ui_action_click(owner, src, holder_item)

/datum/action/item_action/can_use_action()
	if(QDELETED(owner) || owner.incapacitated() || owner.lying_angle)
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
	button.vis_contents -= current_action_vis_obj
	switch(holder_gun.gun_firemode)
		if(GUN_FIREMODE_SEMIAUTO)
			button.name = "Semi-Automatic Firemode"
			current_action_vis_obj = semiauto
		if(GUN_FIREMODE_BURSTFIRE)
			button.name = "Burst Firemode"
			current_action_vis_obj = burstfire
		if(GUN_FIREMODE_AUTOMATIC)
			button.name = "Automatic Firemode"
			current_action_vis_obj = fullauto
		if(GUN_FIREMODE_AUTOBURST)
			button.name = "Automatic Burst Firemode"
			current_action_vis_obj = autoburst
	button.vis_contents += current_action_vis_obj
	action_firemode = holder_gun.gun_firemode
