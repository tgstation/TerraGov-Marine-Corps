/datum/element/attachment
    element_flags = ELEMENT_BESPOKE
    id_arg_index = 2
    var/attachment_data

/datum/element/attachment/Attach(datum/target, slot, overlay_icon, overlay_icon_state, datum/callback/on_attach, datum/callback/on_unattach, list/datum/callback/attachment_actions, pixel_shift_x, pixel_shift_y, flags_attach_features, attach_delay, detach_delay, attach_skill, attach_skill_upper_threshold, attach_sound, extra_vars)
    . = ..()
    if(!isitem(target))
        return ELEMENT_INCOMPATIBLE

    attachment_data = list(
        slot = slot,
        overlay_icon = overlay_icon,
        overlay_icon_state = overlay_icon_state,
        on_attach = on_attach,
        on_unattach = on_unattach,
        attachment_actions = attachment_actions,
        pixel_shift_x = pixel_shift_x,
        pixel_shift_y = pixel_shift_y,
        flags_attach_features = flags_attach_features,
        attach_delay = attach_delay,
        detach_delay = detach_delay,
        attach_skill = attach_skill,
        attach_skill_upper_threshold = attach_skill_upper_threshold,
        attach_sound = attach_sound,
        extra_vars = extra_vars,
    )

    RegisterSignal(target, COMSIG_ITEM_IS_ATTACHMENT, .proc/return_attachment)
    RegisterSignal(target, COMSIG_ITEM_GET_ATTACHMENT_DATA, .proc/return_attachment_data)

/datum/element/attachment/proc/return_attachment(datum/source)
    SIGNAL_HANDLER
    return IS_ATTACHMENT

/datum/element/attachment/proc/return_attachment_data(datum/source, list/list_to_fill)
    SIGNAL_HANDLER
    list_to_fill.Add(attachment_data)