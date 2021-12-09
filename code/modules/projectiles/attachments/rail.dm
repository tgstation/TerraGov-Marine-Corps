
///////////// Rail attachments ////////////////////////

/obj/item/attachable/reddot
	name = "red-dot sight"
	desc = "A red-dot sight for short to medium range. Does not have a zoom feature, but does increase weapon accuracy and fire rate while aiming by a good amount. \nNo drawbacks."
	icon_state = "reddot"
	slot = ATTACHMENT_SLOT_RAIL
	accuracy_mod = 0.15
	accuracy_unwielded_mod = 0.1
	aim_mode_delay_mod = -0.5

/obj/item/attachable/m16sight
	name = "M16 iron sights"
	desc = "The iconic carry-handle iron sights for the m16. Usually removed once the user finds something worthwhile to attach to the rail."
	icon_state = "m16sight"
	slot = ATTACHMENT_SLOT_RAIL
	accuracy_mod = 0.1
	accuracy_unwielded_mod = 0.05
	movement_acc_penalty_mod = -0.1


/obj/item/attachable/flashlight
	name = "rail flashlight"
	desc = "A simple flashlight used for mounting on a firearm. \nHas no drawbacks, but isn't particuraly useful outside of providing a light source."
	icon_state = "flashlight"
	light_mod = 6
	light_system = MOVABLE_LIGHT
	slot = ATTACHMENT_SLOT_RAIL
	materials = list(/datum/material/metal = 100, /datum/material/glass = 20)
	flags_attach_features = ATTACH_REMOVABLE|ATTACH_ACTIVATION
	attachment_action_type = /datum/action/item_action/toggle
	activation_sound = 'sound/items/flashlight.ogg'

/obj/item/attachable/flashlight/activate(mob/living/user)
	turn_light(user, !light_on)

/obj/item/attachable/flashlight/turn_light(mob/user, toggle_on)
	. = ..()

	if(. != CHECKS_PASSED)
		return

	if(ismob(master_gun.loc) && !user)
		user = master_gun.loc
	if(!toggle_on && light_on)
		icon_state = "flashlight"
		master_gun.set_light_range(0)
		master_gun.set_light_power(0)
		master_gun.set_light_on(FALSE)
		light_on = FALSE
		REMOVE_TRAIT(master_gun, TRAIT_GUN_FLASHLIGHT_ON, GUN_TRAIT)
	else if(toggle_on & !light_on)
		icon_state = "flashlight-on"
		master_gun.set_light_range(light_mod)
		master_gun.set_light_power(3)
		master_gun.set_light_on(TRUE)
		light_on = TRUE
		ADD_TRAIT(master_gun, TRAIT_GUN_FLASHLIGHT_ON, GUN_TRAIT)
	else
		return

	for(var/X in master_gun.actions)
		var/datum/action/A = X
		A.update_button_icon()

	update_icon()

/obj/item/attachable/flashlight/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I,/obj/item/tool/screwdriver))
		to_chat(user, span_notice("You modify the rail flashlight back into a normal flashlight."))
		if(loc == user)
			user.temporarilyRemoveItemFromInventory(src)
		var/obj/item/flashlight/F = new(user)
		user.put_in_hands(F) //This proc tries right, left, then drops it all-in-one.
		qdel(src) //Delete da old flashlight



/obj/item/attachable/quickfire
	name = "quickfire adapter"
	desc = "An enhanced and upgraded autoloading mechanism to fire rounds more quickly. \nHowever, it also reduces accuracy and the number of bullets fired on burst."
	slot = ATTACHMENT_SLOT_RAIL
	icon_state = "autoloader"
	accuracy_mod = -0.15
	scatter_mod = 5
	delay_mod = -0.125 SECONDS
	burst_mod = -1
	accuracy_unwielded_mod = -0.22
	scatter_unwielded_mod = 15


/obj/item/attachable/magnetic_harness
	name = "magnetic harness"
	desc = "A magnetically attached harness kit that attaches to the rail mount of a weapon. When dropped, the weapon will sling to a TGMC armor."
	icon_state = "magnetic"
	slot = ATTACHMENT_SLOT_RAIL
	pixel_shift_x = 13


/obj/item/attachable/scope
	name = "rail scope"
	icon_state = "sniperscope"
	desc = "A rail mounted zoom sight scope. Allows zoom by activating the attachment. Use F12 if your HUD doesn't come back."
	slot = ATTACHMENT_SLOT_RAIL
	aim_speed_mod = 0.5 //Extra slowdown when aiming
	wield_delay_mod = 0.4 SECONDS
	accuracy_mod = 0.1
	scoped_accuracy_mod = SCOPE_RAIL
	flags_attach_features = ATTACH_REMOVABLE|ATTACH_ACTIVATION
	attachment_action_type = /datum/action/item_action/toggle
	scope_zoom_mod = TRUE // codex
	accuracy_unwielded_mod = -0.05
	zoom_tile_offset = 11
	zoom_viewsize = 10
	zoom_allow_movement = TRUE
	///how much slowdown the scope gives when zoomed. You want this to be slowdown you want minus aim_speed_mod
	var/zoom_slowdown = 1
	///boolean as to whether a scope can apply nightvision
	var/has_nightvision = FALSE
	///boolean as to whether the attachment is currently giving nightvision
	var/active_nightvision = FALSE


/obj/item/attachable/scope/marine
	name = "T-47 rail scope"
	desc = "A marine standard mounted zoom sight scope. Allows zoom by activating the attachment. Use F12 if your HUD doesn't come back."
	icon_state = "marinescope"

/obj/item/attachable/scope/nightvision
	name = "T-46 Night vision scope"
	icon_state = "nvscope"
	desc = "A rail-mounted night vision scope developed by Roh-Easy industries for the TGMC. Allows zoom by activating the attachment. Use F12 if your HUD doesn't come back."
	has_nightvision = TRUE

/obj/item/attachable/scope/mosin
	name = "Mosin nagant rail scope"
	icon_state = "mosinscope"
	desc = "A Mosin specific mounted zoom sight scope. Allows zoom by activating the attachment. Use F12 if your HUD doesn't come back."

/obj/item/attachable/scope/unremovable
	flags_attach_features = ATTACH_ACTIVATION


/obj/item/attachable/scope/unremovable/flaregun
	name = "long range ironsights"
	desc = "An unremovable set of long range ironsights for a flaregun."
	aim_speed_mod = 0
	wield_delay_mod = 0
	zoom_tile_offset = 5
	zoom_viewsize = 0
	scoped_accuracy_mod = SCOPE_RAIL_MINI
	zoom_slowdown = 0.50

/obj/item/attachable/scope/unremovable/tl127
	name = "T-45 rail scope"
	icon_state = "sniperscope_invisible"
	aim_speed_mod = 0
	wield_delay_mod = 0
	desc = "A rail mounted zoom sight scope specialized for the T-127 sniper rifle. Allows zoom by activating the attachment. Use F12 if your HUD doesn't come back."
	flags_attach_features = ATTACH_ACTIVATION

/obj/item/attachable/scope/unremovable/heavymachinegun
	name = "MG-08/495 long range ironsights"
	desc = "An unremovable set of long range ironsights for an MG-08/495 machinegun."
	icon_state = "sniperscope_invisible"
	flags_attach_features = ATTACH_ACTIVATION
	zoom_viewsize = 0
	zoom_tile_offset = 3


/obj/item/attachable/scope/unremovable/tl102
	name = "TL-102 smart sight"
	desc = "An unremovable smart sight built for use with the tl102, it does nearly all the aiming work for the gun's integrated IFF systems."
	icon_state = "sniperscope_invisible"
	zoom_viewsize = 0
	zoom_tile_offset = 3

/obj/item/attachable/scope/unremovable/tl102/nest
	zoom_tile_offset = 6

/obj/item/attachable/scope/activate(mob/living/carbon/user, turn_off)
	if(turn_off)
		zoom(user)
		return TRUE

	if(!(master_gun.flags_item & WIELDED) && !CHECK_BITFIELD(master_gun.flags_item, IS_DEPLOYED))
		if(user)
			to_chat(user, span_warning("You must hold [master_gun] with two hands to use [src]."))
		return FALSE
	if(CHECK_BITFIELD(master_gun.flags_item, IS_DEPLOYED) && user.dir != master_gun.loc.dir)
		user.setDir(master_gun.loc.dir)
	zoom(user)
	update_icon()
	return TRUE

/obj/item/attachable/scope/zoom_item_turnoff(datum/source, mob/living/carbon/user)
	if(ismob(source))
		activate(source, TRUE)
	else
		activate(user, TRUE)

/obj/item/attachable/scope/onzoom(mob/living/user)
	if(zoom_allow_movement)
		user.add_movespeed_modifier(MOVESPEED_ID_SCOPE_SLOWDOWN, TRUE, 0, NONE, TRUE, zoom_slowdown)
		RegisterSignal(user, COMSIG_CARBON_SWAPPED_HANDS, .proc/zoom_item_turnoff)
	else
		RegisterSignal(user, list(COMSIG_MOVABLE_MOVED, COMSIG_CARBON_SWAPPED_HANDS), .proc/zoom_item_turnoff)
	if(!(master_gun.flags_gun_features & IS_DEPLOYED))
		RegisterSignal(user, COMSIG_MOB_FACE_DIR, .proc/change_zoom_offset)
	RegisterSignal(master_gun, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_UNWIELD, COMSIG_ITEM_DROPPED), .proc/zoom_item_turnoff)
	master_gun.accuracy_mult += scoped_accuracy_mod
	if(has_nightvision)
		update_remote_sight(user)
		user.reset_perspective(src)
		active_nightvision = TRUE

/obj/item/attachable/scope/onunzoom(mob/living/user)
	if(zoom_allow_movement)
		user.remove_movespeed_modifier(MOVESPEED_ID_SCOPE_SLOWDOWN)
		UnregisterSignal(user, list(COMSIG_CARBON_SWAPPED_HANDS, COMSIG_MOB_FACE_DIR))
	else
		UnregisterSignal(user, list(COMSIG_MOVABLE_MOVED, COMSIG_CARBON_SWAPPED_HANDS, COMSIG_MOB_FACE_DIR))
	UnregisterSignal(master_gun, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_UNWIELD, COMSIG_ITEM_DROPPED))
	master_gun.accuracy_mult -= scoped_accuracy_mod
	if(has_nightvision)
		user.update_sight()
		user.reset_perspective(user)
		active_nightvision = FALSE

/obj/item/attachable/scope/update_remote_sight(mob/living/user)
	. = ..()
	user.see_in_dark = 32
	user.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	user.sync_lighting_plane_alpha()
	return TRUE

/obj/item/attachable/scope/unremovable/laser_sniper_scope
	name = "Terra Experimental laser sniper rifle rail scope"
	desc = "A marine standard mounted zoom sight scope made for the Terra Experimental laser sniper rifle otherwise known as TE-S abbreviated, allows zoom by activating the attachment. Use F12 if your HUD doesn't come back."
	icon_state = "tes"

/obj/item/attachable/scope/mini
	name = "mini rail scope"
	icon_state = "miniscope"
	desc = "A small rail mounted zoom sight scope. Allows zoom by activating the attachment. Use F12 if your HUD doesn't come back."
	slot = ATTACHMENT_SLOT_RAIL
	wield_delay_mod = 0.2 SECONDS
	accuracy_mod = 0.05
	accuracy_unwielded_mod = -0.05
	aim_speed_mod = 0.2
	scoped_accuracy_mod = SCOPE_RAIL_MINI
	scope_zoom_mod = TRUE
	has_nightvision = FALSE
	zoom_allow_movement = TRUE
	zoom_slowdown = 0.3
	zoom_tile_offset = 5
	zoom_viewsize = 0

/obj/item/attachable/scope/mini/tx11
	name = "TX-11 mini rail scope"
	icon_state = "tx11scope"

/obj/item/attachable/scope/antimaterial
	name = "antimaterial rail scope"
	desc = "A rail mounted zoom sight scope specialized for the antimaterial Sniper Rifle . Allows zoom by activating the attachment. Can activate its targeting laser while zoomed to take aim for increased damage and penetration. Use F12 if your HUD doesn't come back."
	icon_state = "antimat"
	scoped_accuracy_mod = SCOPE_RAIL_SNIPER
	has_nightvision = TRUE
	flags_attach_features = ATTACH_ACTIVATION|ATTACH_REMOVABLE
	pixel_shift_x = 0
	pixel_shift_y = 17


/obj/item/attachable/scope/slavic
	icon_state = "slavicscope"

/obj/item/attachable/scope/pmc
	icon_state = "pmcscope"
	flags_attach_features = ATTACH_ACTIVATION

/obj/item/attachable/scope/mini/dmr
	name = "T-37 mini rail scope"
	icon_state = "t37"
