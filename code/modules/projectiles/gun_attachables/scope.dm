/obj/item/attachable/scope
	name = "rail scope"
	icon_state = "sniper"
	icon = 'icons/obj/items/guns/attachments/scope.dmi'
	desc = "A rail mounted zoom sight scope. Allows zoom by activating the attachment."
	slot = ATTACHMENT_SLOT_RAIL
	aim_speed_mod = 0.5 //Extra slowdown when aiming
	wield_delay_mod = 0.4 SECONDS
	scoped_accuracy_mod = SCOPE_RAIL //accuracy mod of 0.4 when scoped
	attach_features_flags = ATTACH_REMOVABLE|ATTACH_ACTIVATION
	attachment_action_type = /datum/action/item_action/toggle
	scope_zoom_mod = TRUE // codex
	accuracy_unwielded_mod = -0.05
	zoom_tile_offset = 11
	zoom_viewsize = 10
	zoom_allow_movement = TRUE
	///how much slowdown the scope gives when zoomed. You want this to be slowdown you want minus aim_speed_mod
	var/zoom_slowdown = 1
	/// scope zoom delay, delay before you can aim.
	var/scope_delay = 0
	///boolean as to whether a scope can apply nightvision
	var/has_nightvision = FALSE
	///boolean as to whether the attachment is currently giving nightvision
	var/active_nightvision = FALSE
	///True if the scope is supposed to reactiveate when a deployed gun is turned.
	var/deployed_scope_rezoom = FALSE

/obj/item/attachable/scope/activate(mob/living/carbon/user, turn_off)
	if(turn_off)
		if(SEND_SIGNAL(user, COMSIG_ITEM_ZOOM) &  COMSIG_ITEM_ALREADY_ZOOMED)
			zoom(user)
		return TRUE

	if(!(master_gun.item_flags & WIELDED) && !CHECK_BITFIELD(master_gun.item_flags, IS_DEPLOYED))
		if(user)
			to_chat(user, span_warning("You must hold [master_gun] with two hands to use [src]."))
		return FALSE
	if(CHECK_BITFIELD(master_gun.item_flags, IS_DEPLOYED) && user.dir != master_gun.loc.dir)
		user.setDir(master_gun.loc.dir)
	if(!do_after(user, scope_delay, NONE, src, BUSY_ICON_BAR))
		return FALSE
	zoom(user)
	update_icon()
	return TRUE

/obj/item/attachable/scope/zoom_item_turnoff(datum/source, mob/living/carbon/user)
	if(ismob(source))
		INVOKE_ASYNC(src, PROC_REF(activate), source, TRUE)
	else
		INVOKE_ASYNC(src, PROC_REF(activate), user, TRUE)

/obj/item/attachable/scope/onzoom(mob/living/user)
	if(!zoom_allow_movement)
		RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(zoom_item_turnoff))
	else
		user.add_movespeed_modifier(MOVESPEED_ID_SCOPE_SLOWDOWN, TRUE, 0, NONE, TRUE, zoom_slowdown)
	RegisterSignals(user, list(COMSIG_LIVING_SWAPPED_HANDS, COMSIG_KTLD_ACTIVATED), PROC_REF(zoom_item_turnoff))

	if(!CHECK_BITFIELD(master_gun.item_flags, IS_DEPLOYED))
		RegisterSignal(user, COMSIG_MOB_FACE_DIR, PROC_REF(change_zoom_offset))
	RegisterSignals(master_gun, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_UNWIELD, COMSIG_ITEM_DROPPED), PROC_REF(zoom_item_turnoff))
	master_gun.accuracy_mult += scoped_accuracy_mod
	if(has_nightvision)
		active_nightvision = TRUE
		user.reset_perspective(src)

/obj/item/attachable/scope/onunzoom(mob/living/user)
	if(zoom_allow_movement)
		user.remove_movespeed_modifier(MOVESPEED_ID_SCOPE_SLOWDOWN)
	UnregisterSignal(user, list(COMSIG_MOVABLE_MOVED, COMSIG_LIVING_SWAPPED_HANDS, COMSIG_MOB_FACE_DIR, COMSIG_KTLD_ACTIVATED))
	UnregisterSignal(master_gun, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_UNWIELD, COMSIG_ITEM_DROPPED))
	master_gun.accuracy_mult -= scoped_accuracy_mod
	if(has_nightvision)
		active_nightvision = FALSE
		user.reset_perspective(user)

/obj/item/attachable/scope/update_remote_sight(mob/living/user)
	. = ..()
	user.lighting_cutoff = LIGHTING_CUTOFF_MEDIUM
	user.sync_lighting_plane_cutoff()
	return TRUE

/obj/item/attachable/scope/zoom(mob/living/user, tileoffset, viewsize)
	. = ..()
	//Makes the gun zoom align with the attachment, used for projectile procs
	if(zoom)
		master_gun.zoom = TRUE
	else
		master_gun.zoom = FALSE

/obj/item/attachable/scope/marine
	name = "T-47 rail scope"
	desc = "A marine standard mounted zoom sight scope. Allows zoom by activating the attachment."
	icon_state = "marine"

/obj/item/attachable/scope/nightvision
	name = "T-46 Night vision scope"
	icon_state = "nv"
	desc = "A rail-mounted night vision scope developed by Roh-Easy industries for the TGMC. Allows zoom by activating the attachment."
	has_nightvision = TRUE

/obj/item/attachable/scope/optical
	name = "T-49 Optical imaging scope"
	icon_state = "imager"
	desc = "A rail-mounted scope designed for the AR-55 and GL-54. Features low light optical imaging capabilities and assists with precision aiming. Allows zoom by activating the attachment."
	has_nightvision = TRUE
	aim_speed_mod = 0.3
	wield_delay_mod = 0.2 SECONDS
	zoom_tile_offset = 7
	zoom_viewsize = 2
	add_aim_mode = TRUE

/obj/item/attachable/scope/mosin
	name = "Mosin nagant rail scope"
	icon_state = "mosin"
	desc = "A Mosin specific mounted zoom sight scope. Allows zoom by activating the attachment."

/obj/item/attachable/scope/standard_magnum
	name = "R-76 rail scope"
	desc = "A custom rail mounted zoom sight scope designed specifically for the R-76 Magnum. Allows zoom by activating the attachment."
	icon = 'icons/obj/items/guns/attachments/scope_64.dmi'
	icon_state = "t76scope"

/obj/item/attachable/scope/laser_sniper_scope
	name = "Terra Experimental laser sniper rifle rail scope"
	desc = "A marine standard mounted zoom sight scope made for the Terra Experimental laser sniper rifle otherwise known as TE-S abbreviated, allows zoom by activating the attachment."
	icon_state = "tes"

/obj/item/attachable/scope/unremovable
	attach_features_flags = ATTACH_ACTIVATION

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
	icon_state = "tl127"
	aim_speed_mod = 0
	wield_delay_mod = 0
	desc = "A rail mounted zoom sight scope specialized for the SR-127 sniper rifle. Allows zoom by activating the attachment."

/obj/item/attachable/scope/unremovable/heavymachinegun
	name = "HMG-08 long range ironsights"
	desc = "An unremovable set of long range ironsights for an HMG-08 machinegun."
	icon_state = "sniper_invisible"
	zoom_viewsize = 0
	zoom_tile_offset = 5

/obj/item/attachable/scope/unremovable/mmg
	name = "MG-27 rail scope"
	icon_state = "mini"
	desc = "A small rail mounted zoom sight scope. Allows zoom by activating the attachment."
	wield_delay_mod = 0.2 SECONDS
	aim_speed_mod = 0.2
	scoped_accuracy_mod = SCOPE_RAIL_MINI
	zoom_slowdown = 0.3
	zoom_tile_offset = 5
	zoom_viewsize = 0

/obj/item/attachable/scope/unremovable/standard_atgun
	name = "AT-36 long range scope"
	desc = "An unremovable set of long range scopes, very complex to properly range. Requires time to aim.."
	icon_state = "sniper_invisible"
	scope_delay = 2 SECONDS
	zoom_tile_offset = 7

/obj/item/attachable/scope/unremovable/hsg_102
	name = "HSG-102 smart sight"
	desc = "An unremovable smart sight built for use with the HSG-102, it does nearly all the aiming work for the gun's integrated IFF systems."
	icon_state = "sniper_invisible"
	zoom_viewsize = 0
	zoom_tile_offset = 5
	deployed_scope_rezoom = TRUE

//all mounted guns with a nest use this
/obj/item/attachable/scope/unremovable/hsg_102/nest
	scope_delay = 2 SECONDS
	zoom_tile_offset = 7
	zoom_viewsize = 2
	deployed_scope_rezoom = FALSE

/obj/item/attachable/scope/unremovable/plasma_sniper_scope
	name = "PL-02 sniper rifle rail scope"
	desc = "A marine standard mounted zoom sight scope made for the PL-02 plasma sniper rifle, allows zoom by activating the attachment. Use F12 if your HUD doesn't come back."
	icon_state = "plasma_scope" // missing icon?

/obj/item/attachable/scope/mini
	name = "mini rail scope"
	icon_state = "mini"
	desc = "A small rail mounted zoom sight scope. Allows zoom by activating the attachment."
	slot = ATTACHMENT_SLOT_RAIL
	wield_delay_mod = 0.2 SECONDS
	accuracy_unwielded_mod = -0.05
	aim_speed_mod = 0.2
	scoped_accuracy_mod = SCOPE_RAIL_MINI
	scope_zoom_mod = TRUE
	has_nightvision = FALSE
	zoom_allow_movement = TRUE
	zoom_slowdown = 0.3
	zoom_tile_offset = 5
	zoom_viewsize = 0
	variants_by_parent_type = list(/obj/item/weapon/gun/rifle/som = "")

/obj/item/attachable/scope/mini/tx11
	name = "AR-11 mini rail scope"
	icon_state = "tx11"

/obj/item/attachable/scope/antimaterial
	name = "antimaterial rail scope"
	desc = "A rail mounted zoom sight scope specialized for the antimaterial Sniper Rifle . Allows zoom by activating the attachment. Can activate its targeting laser while zoomed to take aim for increased damage and penetration."
	icon_state = "antimat"
	scoped_accuracy_mod = SCOPE_RAIL_SNIPER
	has_nightvision = TRUE
	zoom_allow_movement = FALSE
	attach_features_flags = ATTACH_ACTIVATION|ATTACH_REMOVABLE
	pixel_shift_x = 0
	pixel_shift_y = 17

/obj/item/attachable/scope/slavic
	icon_state = "slavic"

/obj/item/attachable/scope/pmc
	icon_state = "pmc"
	attach_features_flags = ATTACH_ACTIVATION

/obj/item/attachable/scope/mini/dmr
	name = "DMR-37 mini rail scope"
	icon_state = "t37"
