/datum/component/attachment
    var/list/attachment_data

/datum/component/attachment/Initialize(slot, overlay_icon, overlay_icon_state, datum/callback/on_attach, datum/callback/on_unattach, list/datum/callback/attachment_actions, pixel_shift_x, pixel_shift_y)
    . = ..()
    if(!isitem(parent))
        return COMPONENT_INCOMPATIBLE

    attachment_data = list(
        attachment = parent,
        slot = slot,
        overlay_icon = overlay_icon,
        overlay_icon_state = overlay_icon_state,
        on_attach = on_attach,
        on_unattach = on_unattach,
        attachment_actions = attachment_actions,
        pixel_shift_x = pixel_shift_x,
        pixel_shift_y = pixel_shift_y,
    )

    RegisterSignal(parent, COMSIG_ITEM_IS_ATTACHMENT, .proc/return_attachment)
    RegisterSignal(parent, COMSIG_ITEM_GET_ATTACHMENT_DATA, .proc/return_attachment_data)

#define IS_ATTACHMENT (1<<0)
/datum/component/attachment/proc/return_attachment(datum/source)
    SIGNAL_HANDLER
    return IS_ATTACHMENT

/datum/component/attachment/proc/return_attachment_data(datum/source)
    SIGNAL_HANDLER
    return attachment_data