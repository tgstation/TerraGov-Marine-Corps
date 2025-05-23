
/obj/item/armor_module
	name = "armor module"
	desc = "A dis-figured armor module, in its prime this would've been a key item in your modular armor... now its just trash."
	icon = 'icons/mob/modular/modular_armor.dmi'
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0) // This is here to overwrite code over at objs.dm line 41. Marines don't get funny 200+ bio buff anymore.

	slowdown = 0
	appearance_flags = KEEP_APART|TILE_BOUND

	///Reference to parent modular armor suit.
	var/obj/item/clothing/parent

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
	var/attach_features_flags = ATTACH_REMOVABLE|ATTACH_APPLY_ON_MOB
	///Time it takes to attach.
	var/attach_delay = 1.5 SECONDS
	///Time it takes to detach.
	var/detach_delay = 1.5 SECONDS
	///Used for when the mob attach overlay icon is different than icon.
	var/mob_overlay_icon
	///Pixel shift for the mob overlay on the X axis.
	var/mob_pixel_shift_x = 0
	///Pixel shift for the mob overlay on the Y axis.
	var/mob_pixel_shift_y = 0

	///Light modifier for attachment to an armor piece
	var/light_mod = 0

	///Replacement for initial icon that allows for the code to work with multiple variants
	var/base_icon

	///Assoc list that uses the parents type as a key. type = "new_icon_state". This will change the icon state depending on what type the parent is. If the list is empty, or the parent type is not within, it will have no effect.
	var/list/variants_by_parent_type = list()

	///Layer for the attachment to be applied to.
	var/attachment_layer
	///Slot that is required for the action to appear to the equipper. If null the action will appear whenever the item is equiped to a slot.
	var/prefered_slot = SLOT_WEAR_SUIT

	///List of slots this attachment has.
	var/list/attachments_by_slot = list()
	///Starting attachments that are spawned with this.
	var/list/starting_attachments = list()

	///Allowed attachment types
	var/list/attachments_allowed = list()

	///The signal for this module if it can toggled
	var/toggle_signal

/obj/item/armor_module/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/attachment, slot, attach_icon, on_attach, on_detach, null, can_attach, pixel_shift_x, pixel_shift_y, attach_features_flags, attach_delay, detach_delay, mob_overlay_icon = mob_overlay_icon, mob_pixel_shift_x = mob_pixel_shift_x, mob_pixel_shift_y = mob_pixel_shift_y, attachment_layer = attachment_layer, attach_sound = 'sound/machines/click.ogg')
	AddComponent(/datum/component/attachment_handler, attachments_by_slot, attachments_allowed, starting_attachments = starting_attachments)
	update_icon()

/// Called before a module is attached.
/obj/item/armor_module/proc/can_attach(obj/item/attaching_to, mob/user)
	return TRUE

/// Called when the module is added to the armor.
/obj/item/armor_module/proc/on_attach(obj/item/attaching_to, mob/user)
	SEND_SIGNAL(attaching_to, COMSIG_ARMOR_MODULE_ATTACHING, user, src)
	parent = attaching_to
	parent.set_light_range(parent.light_range + light_mod)
	parent.hard_armor = parent.hard_armor.attachArmor(hard_armor)
	parent.soft_armor = parent.soft_armor.attachArmor(soft_armor)
	parent.slowdown += slowdown
	if(CHECK_BITFIELD(attach_features_flags, ATTACH_ACTIVATION))
		RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(handle_actions))
		RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(handle_unequip_actions))
	base_icon = icon_state
	if(length(variants_by_parent_type))
		for(var/selection in variants_by_parent_type)
			if(istype(parent, selection))
				icon_state = variants_by_parent_type[selection]
				base_icon = variants_by_parent_type[selection]

	update_icon()

/// Called when the module is removed from the armor.
/obj/item/armor_module/proc/on_detach(obj/item/detaching_from, mob/user)
	SEND_SIGNAL(detaching_from, COMSIG_ARMOR_MODULE_DETACHED, user, src)
	parent.set_light_range(parent.light_range - light_mod)
	parent.hard_armor = parent.hard_armor.detachArmor(hard_armor)
	parent.soft_armor = parent.soft_armor.detachArmor(soft_armor)
	parent.slowdown -= slowdown
	UnregisterSignal(parent, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))
	parent = null
	icon_state = initial(icon_state)
	update_icon()

///called when the item is dropped: relevant when item is forcedropped from a non-hand slot so we can remove the actions.
/obj/item/armor_module/proc/handle_unequip_actions(datum/source, mob/user)
	SIGNAL_HANDLER
	handle_actions(source, user, null)

///Adds or removes actions based on whether the parent is in the correct slot.
/obj/item/armor_module/proc/handle_actions(datum/source, mob/user, slot)
	SIGNAL_HANDLER
	if(prefered_slot && (slot != prefered_slot) || !CHECK_BITFIELD(attach_features_flags, ATTACH_ACTIVATION))
		LAZYREMOVE(actions_types, /datum/action/item_action/toggle)
		var/datum/action/item_action/toggle/old_action = locate(/datum/action/item_action/toggle) in actions
		old_action?.remove_action(user)
		actions = null
		return
	LAZYADD(actions_types, /datum/action/item_action/toggle)
	var/datum/action/item_action/toggle/new_action = new(src)
	if(toggle_signal)
		new_action.keybinding_signals = list(KEYBINDING_NORMAL = toggle_signal)
	new_action.give_action(user)

/obj/item/armor_module/ui_action_click(mob/user, datum/action/item_action/toggle/action)
	action.set_toggle(activate(user))

///Called on ui_action_click. Used for activating the module.
/obj/item/armor_module/proc/activate(mob/living/user)
	return

/**
 *  These are the basic type for armor armor_modules. What seperates these from /armor_module is that these are designed to be recolored.
 *  These include Leg plates, Chest plates, Shoulder Plates and Visors. This could be expanded to anything that functions like armor and has greyscale functionality.
 */

/obj/item/armor_module/armor
	name = "modular armor - armor module"
	icon = 'icons/mob/modular/modular_armor.dmi'

	/// The additional armor provided by equipping this piece.
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)

	/// Addititve Slowdown of this armor piece
	slowdown = 0

	greyscale_config = null
	greyscale_colors = ARMOR_PALETTE_DRAB

	attach_features_flags = ATTACH_REMOVABLE|ATTACH_SAME_ICON|ATTACH_APPLY_ON_MOB

	item_map_variant_flags = ITEM_JUNGLE_VARIANT|ITEM_ICE_VARIANT|ITEM_PRISON_VARIANT
	///If TRUE, this armor piece can be recolored when its parent is right clicked by facepaint.
	var/secondary_color = FALSE

	colorable_colors = LEGACY_ARMOR_PALETTES_LIST
	colorable_allowed = PRESET_COLORS_ALLOWED

/obj/item/armor_module/armor/on_attach(obj/item/attaching_to, mob/user)
	. = ..()
	if(!secondary_color)
		return
	RegisterSignal(parent, COMSIG_ITEM_SECONDARY_COLOR, PROC_REF(handle_color))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(extra_examine))

/obj/item/armor_module/armor/on_detach(obj/item/detaching_from, mob/user)
	UnregisterSignal(parent, list(COMSIG_ATOM_EXAMINE, COMSIG_ITEM_SECONDARY_COLOR))
	return ..()

/obj/item/armor_module/armor/color_item(obj/item/facepaint/paint, mob/user)
	. = ..()
	parent?.update_icon()

///Sends a list of available colored attachments to be colored when the parent is right clicked with paint.
/obj/item/armor_module/armor/proc/handle_color(datum/source, mob/user, list/obj/item/secondaries)
	SIGNAL_HANDLER
	secondaries += src
	for(var/key in attachments_by_slot)
		if(!attachments_by_slot[key] || !istype(attachments_by_slot[key], /obj/item/armor_module/armor))
			continue
		var/obj/item/armor_module/armor/armor_piece = attachments_by_slot[key]
		if(!armor_piece.secondary_color)
			continue
		armor_piece.handle_color(source, user, secondaries)

///Relays the extra controls to the user when the parent is examined.
/obj/item/armor_module/armor/proc/extra_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += "Right click the [parent] with paint to color [src]"
