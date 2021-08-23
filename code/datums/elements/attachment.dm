/datum/element/attachment
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2
	///Assoc list of the data required for attaching. It does not change and should not be edited anywhere but here.
	var/attachment_data

//on_attach, on_detach, on_activate and can_attach are all proc paths that get turned into callbacks when they are called.
/datum/element/attachment/Attach(datum/target, slot, overlay_icon, overlay_icon_state, on_attach, on_detach, on_activate, can_attach, pixel_shift_x, pixel_shift_y, flags_attach_features, attach_delay, detach_delay, attach_skill, attach_skill_upper_threshold, attach_sound, extra_vars)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE
	var/obj/item/target_item = target
	attachment_data = list(
		slot = slot, //Slot the attachment fits into, is a string.
		overlay_icon = overlay_icon ? overlay_icon : target_item.icon, //Icon sheet of the overlay
		overlay_icon_state = overlay_icon_state ? overlay_icon_state : target_item.icon_state, //Icon state of the overlay
		on_attach = on_attach, //Callback for what the attachment does on attach. Can be null.
		on_detach = on_detach, //Callback for what the attachment does on detach. Can be null. 
		on_activate = on_activate, //Activation proc for attachment. Can be null.
		can_attach = can_attach, //Callback that is called on attach to determine by the attachment whether or not it can attach to the item.
		pixel_shift_x = pixel_shift_x, //Pixel shift on X Axis for the attachments overlay.
		pixel_shift_y = pixel_shift_y, //Pixel shift on Y Axis for the attachments overlay.
		flags_attach_features = flags_attach_features, //Flags for how the attachment functions.
		attach_delay = attach_delay, //Delay for attaching.
		detach_delay = detach_delay, //Delay for detaching.
		attach_skill = attach_skill, //Skill used in attaching and detaching. Can be null. If user does not meet the skill requirement the attach delay and detach delay is doubled.
		attach_skill_upper_threshold = attach_skill_upper_threshold, //Skill threshold for a bonus on attaching and detaching. If use meets the upper threshold the attach delay and detach delay will be halved.
		attach_sound = attach_sound, //Sound played on attach and detach.
		extra_vars = extra_vars, //List of extra vars for other uses.
	)

	RegisterSignal(target, COMSIG_ITEM_IS_ATTACHING, .proc/on_attaching)

///Fills list_to_fill with attachment_data
/datum/element/attachment/proc/on_attaching(datum/source, mob/attacher, list/list_to_fill)
	SIGNAL_HANDLER
	list_to_fill.Add(attachment_data)
