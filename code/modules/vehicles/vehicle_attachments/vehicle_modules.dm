/obj/item/vehicle_module
	name = "vehicle module"
	desc = "A proto-vehicle module. Call the coders if you see this."
	icon = 'icons/mob/modular/modular_armor.dmi'
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0) // This is here to overwrite code over at objs.dm line 41. Marines don't get funny 200+ bio buff anymore.
	appearance_flags = KEEP_APART|TILE_BOUND

	///Reference to parent object.
	var/obj/parent

	///Slot the attachment is able to occupy.
	var/slot
	///Icon sheet of the attachment overlays
	var/attach_icon = null
	///Proc typepath that is called when this is attached to something.
	var/on_attach = PROC_REF(on_attach)
	///Proc typepath that is called when this is detached from something.
	var/on_detach = PROC_REF(on_detach)
	///Proc typepath that is called when this is item is being attached to something. Returns TRUE if it can attach.
	var/can_attach = PROC_REF(can_attach)
	///Pixel shift for the item overlay on the X axis.
	var/pixel_shift_x = 0
	///Pixel shift for the item overlay on the Y axis.
	var/pixel_shift_y = 0
	///Bitfield flags of various features.
	var/attach_features_flags = NONE
	///Time it takes to attach.
	var/attach_delay = 1.5 SECONDS
	///Time it takes to detach.
	var/detach_delay = 1.5 SECONDS

	///List of slots this attachment has.
	var/list/attachments_by_slot = list()
	///Starting attachments that are spawned with this.
	var/list/starting_attachments = list()
	///Allowed attachment types
	var/list/attachments_allowed = list()

	///The signal for this module if it can toggled
	var/toggle_signal
	///dmi for the action button
	var/action_icon
	///icon_state for the action button
	var/action_icon_state
	///Whether the obj appearance for this attachment should be used for the action buttno
	var/should_use_obj_appeareance = TRUE

/obj/item/vehicle_module/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/attachment, slot, attach_icon, on_attach, on_detach, null, can_attach, pixel_shift_x, pixel_shift_y, attach_features_flags, attach_delay, detach_delay, attach_sound = 'sound/weapons/guns/interact/launcher_reload.ogg')
	AddComponent(/datum/component/attachment_handler, attachments_by_slot, attachments_allowed, starting_attachments = starting_attachments)
	update_icon()

/// Called before a module is attached.
/obj/item/vehicle_module/proc/can_attach(obj/item/attaching_to, mob/user)
	return TRUE

/// Called when the module is added to the armor.
/obj/item/vehicle_module/proc/on_attach(obj/item/attaching_to, mob/user)
	SEND_SIGNAL(attaching_to, COMSIG_ARMOR_MODULE_ATTACHING, user, src)
	parent = attaching_to
	parent.hard_armor = parent.hard_armor.attachArmor(hard_armor)
	parent.soft_armor = parent.soft_armor.attachArmor(soft_armor)
	//below applicable on buckle?
	if(CHECK_BITFIELD(attach_features_flags, ATTACH_ACTIVATION))
		RegisterSignal(parent, COMSIG_MOVABLE_BUCKLE, PROC_REF(on_buckle))
		RegisterSignal(parent, COMSIG_MOVABLE_UNBUCKLE, PROC_REF(on_unbuckle))

/// Called when the module is removed from the armor.
/obj/item/vehicle_module/proc/on_detach(obj/item/detaching_from, mob/user)
	SEND_SIGNAL(detaching_from, COMSIG_ARMOR_MODULE_DETACHED, user, src)
	parent.hard_armor = parent.hard_armor.detachArmor(hard_armor)
	parent.soft_armor = parent.soft_armor.detachArmor(soft_armor)
	UnregisterSignal(parent, list(COMSIG_MOVABLE_BUCKLE, COMSIG_MOVABLE_UNBUCKLE))
	parent = null

///Adds actions if the mob has the correct flag
/obj/item/vehicle_module/proc/on_buckle(datum/source, mob/living/buckling_mob, force = FALSE, check_loc = TRUE, lying_buckle = FALSE, hands_needed = 0, target_hands_needed = 0, silent)
	SIGNAL_HANDLER
	var/obj/vehicle/parent_vehicle = source
	if(!parent_vehicle.is_equipment_controller(buckling_mob))
		return

	LAZYADD(actions_types, /datum/action/item_action/toggle)
	var/datum/action/item_action/toggle/new_action = new(src, src, action_icon, action_icon_state)
	new_action.use_obj_appeareance = FALSE
	new_action.update_button_icon()
	if(toggle_signal)
		new_action.keybinding_signals = list(KEYBINDING_NORMAL = toggle_signal)
	new_action.give_action(buckling_mob)

///Removes actions if the mob had them
/obj/item/vehicle_module/proc/on_unbuckle(datum/source, mob/living/unbuckled_mob, force = FALSE)
	SIGNAL_HANDLER
	var/obj/vehicle/parent_vehicle = source
	if(!parent_vehicle.is_equipment_controller(unbuckled_mob))
		return
	LAZYREMOVE(actions_types, /datum/action/item_action/toggle)
	var/datum/action/item_action/toggle/old_action = locate(/datum/action/item_action/toggle) in actions
	old_action?.remove_action(unbuckled_mob)
	actions = null

/obj/item/vehicle_module/ui_action_click(mob/user, datum/action/item_action/toggle/action)
	action.set_toggle(activate(user))

///Called on ui_action_click. Used for activating the module.
/obj/item/vehicle_module/proc/activate(mob/living/user)
	return
