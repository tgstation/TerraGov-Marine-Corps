/datum/component/attachment_handler
    var/list/slots = list()
    var/list/attachables_allowed = list()
    var/list/attachables_not_allowed = list()
    var/datum/callback/on_attach
    var/datum/callback/on_unattach
    var/list/attachments = list()
    var/list/attachment_offsets = list()
    var/list/attachable_overlays = list()
    var/list/extra_vars = list()

/datum/component/attachment_handler/Initialize(_slots, list/_attachables_allowed, list/_attachables_not_allowed, datum/callback/_on_attach, datum/callback/_on_unattach, list/_attachment_offsets)
    . = ..()
    if(!isitem(parent))
        return COMPONENT_INCOMPATIBLE
    
    slots = _slots
    attachables_allowed = _attachables_allowed
    attachables_not_allowed = _attachables_not_allowed
    on_attach = _on_attach
    on_unattach = _on_unattach
    attachment_offsets = _attachment_offsets

    RegisterSignal(parent, COMSIG_PARENT_ATTACKBY , .proc/start_handle_attachment)
    RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, .proc/update_parent_overlay)

/datum/component/attachment_handler/proc/start_handle_attachment(datum/source, obj/attacking, mob/attacker)
    if(!is_attachment(attacking) || !ishuman(attacker))
        return
    finish_handle_attachment(attacking, get_attachment_data(attacking))
    var/mob/living/carbon/human/human_attacker = attacker
    human_attacker.temporarilyRemoveItemFromInventory(attacking)

/datum/component/attachment_handler/proc/finish_handle_attachment(obj/item/attachment, list/attachment_data)
    attachment.forceMove(parent)
    attachments.Add(attachment_data)
    var/obj/item/parent_item = parent
    parent_item.update_overlays()


/datum/component/attachment_handler/proc/update_parent_overlay(datum/source)
    SIGNAL_HANDLER
    var/obj/item/parent_item = source
    for(var/list/attachment_list in attachments)
        var/slot = attachment_list["slot"]
        var/obj/item/attachment = attachment_list["attachment"]
        var/image/overlay = attachable_overlays[slot]
        parent_item.overlays -= overlay
        if(!attachment) //Only updates if the attachment exists for that slot.
            attachable_overlays[slot] = null
            return
        var/item_icon = attachment_list["overlay_icon_state"] ? attachment_list["overlay_icon_state"] : attachment.icon_state
        overlay = image(attachment_list["overlay_icon"] ? attachment_list["overylay_icon"] : attachment.icon, src, item_icon)
        overlay.pixel_x = attachment_offsets["[slot]_x"] - attachment_list["pixel_shift_x"]
        overlay.pixel_y = attachment_offsets["[slot]_y"] - attachment_list["pixel_shift_y"]    
        attachable_overlays[slot] = overlay
        attachment.overlays += overlay

/datum/component/attachment_handler/proc/is_attachment(/obj/item/attachment)
    return SEND_SIGNAL(attachment, COMSIG_ITEM_IS_ATTACHMENT) & IS_ATTACHMENT

/datum/component/attachment_handler/proc/get_attachment_data(/obj/item/attachment)
    return SEND_SIGNAL(attachment, COMSIG_ITEM_GET_ATTACHMENT_DATA)