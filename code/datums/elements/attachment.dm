/datum/element/attachment
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2
	///Assoc list of the data required for attaching. It does not change and should not be edited anywhere but here.
	var/list/attachment_data

//on_attach, on_detach, on_activate and can_attach are all proc paths that get turned into callbacks when they are called.
/datum/element/attachment/Attach(datum/target, slot, overlay_icon, on_attach, on_detach, on_activate, can_attach, pixel_shift_x, pixel_shift_y, flags_attach_features, attach_delay, detach_delay, attach_skill, attach_skill_upper_threshold, attach_sound, extra_vars)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE
	var/obj/item/target_item = target
	if(!attachment_data) //attachment_data only needs to be set once.
		attachment_data = list(
			SLOT = slot, //Slot the attachment fits into, is a string.
			OVERLAY_ICON = overlay_icon ? overlay_icon : target_item.icon, //Icon sheet of the overlay.
			ON_ATTACH = on_attach, //Callback for what the attachment does on attach. Can be null.
			ON_DETACH = on_detach, //Callback for what the attachment does on detach. Can be null. 
			ON_ACTIVATE = on_activate, //Activation proc for attachment. Can be null.
			CAN_ATTACH = can_attach, //Callback that is called on attach to determine by the attachment whether or not it can attach to the item.
			PIXEL_SHIFT_X = pixel_shift_x, //Pixel shift on X Axis for the attachments overlay.
			PIXEL_SHIFT_Y = pixel_shift_y, //Pixel shift on Y Axis for the attachments overlay.
			FLAGS_ATTACH_FEATURES = flags_attach_features, //Flags for how the attachment functions.
			ATTACH_DELAY = attach_delay, //Delay for attaching.
			DETACH_DELAY = detach_delay, //Delay for detaching.
			ATTACH_SKILL = attach_skill, //Skill used in attaching and detaching. Can be null. If user does not meet the skill requirement the attach delay and detach delay is doubled.
			ATTACH_SKILL_UPPER_THRESHOLD = attach_skill_upper_threshold, //Skill threshold for a bonus on attaching and detaching. If use meets the upper threshold the attach delay and detach delay will be halved.
			ATTACH_SOUND = attach_sound, //Sound played on attach and detach.
			EXTRA_VARS = extra_vars, //List of extra vars for other uses.
		)

	RegisterSignal(target, COMSIG_ITEM_IS_ATTACHING, .proc/on_attaching)

///Fills list_to_fill with attachment_data
/datum/element/attachment/proc/on_attaching(datum/source, mob/attacher, list/list_to_fill)
	SIGNAL_HANDLER
	list_to_fill.Add(attachment_data)
