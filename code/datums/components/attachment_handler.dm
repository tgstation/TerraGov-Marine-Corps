/datum/component/attachment_handler
    var/list/slots = list()
	var/list/attachments = list()
    var/list/attachables_allowed = list()
    var/datum/callback/on_attach
    var/datum/callback/on_unattach
    var/list/attachment_offsets = list()
    var/list/attachable_overlays = list()
    var/list/extra_vars = list()


/datum/component/attachment_handler/Initialize(_slots, list/_attachables_allowed, datum/callback/_on_attach, datum/callback/_on_unattach, list/_attachment_offsets, list/_attachable_overlays)
    . = ..()
    if(!isitem(parent))
        return COMPONENT_INCOMPATIBLE
    
    slots = _slots
    attachables_allowed = _attachables_allowed
    on_attach = _on_attach
    on_unattach = _on_unattach
    attachment_offsets = _attachment_offsets
    attachable_overlays = _attachable_overlays

    RegisterSignal(parent, COMSIG_PARENT_ATTACKBY , .proc/start_handle_attachment)
    RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, .proc/update_parent_overlay)

/datum/component/attachment_handler/proc/start_handle_attachment(datum/source, obj/attacking, mob/attacker)
	if(!is_attachment(attacking))
		return

	var/list/attachment_data = list(attachment = attacking)
	get_attachment_data(attacking, attachment_data)



	if(!do_attach(attacking, attacker, attachment_data))
		return

	finish_handle_attachment(attacking,attachment_data)
	var/mob/living/carbon/human/human_attacker = attacker
	human_attacker.temporarilyRemoveItemFromInventory(attacking)

/datum/component/attachment_handler/proc/finish_handle_attachment(obj/item/attachment, list/attachment_data)
	attachment.forceMove(parent)
	attachments.Add(list(attachment_data))

	var/obj/item/parent_item = parent
	parent_item.update_overlays()

/datum/component/attachment_handler/proc/do_attach(obj/item/attachment, mob/attacher, list/attachment_data)
	if(!ishuman(attacher))
		return FALSE

	var/mob/living/carbon/human/user = attacher

	if(!can_attach(attachment, user, attachment_data))
		return FALSE

	var/obj/item/in_hand = user.get_inactive_held_item()
	if(in_hand != parent)
		to_chat(user, span_warning("You have to hold [parent] to do that!"))
		return FALSE

	var/idisplay = BUSY_ICON_GENERIC
	var/attach_delay = attachment_data["attach_delay"]

	var/skill_used = attachment_data["attach_skill"]
	var/skill_upper_threshold = attachment_data["attach_skill_upper_threshold"]

	if(user.skills.getRating(skill_used))
		user.visible_message(span_notice("[user] begins attaching [attachment] to [parent]."),
		span_notice("You begin attaching [attachment] to [parent]."), null, 4)
		if(user.skills.getRating(skill_used) >= skill_upper_threshold) //See if the attacher is super skilled/panzerelite born to defeat never retreat etc
			attach_delay *= 0.5
	else //If the user has no training, attaching takes twice as long and they fumble about.
		attach_delay *= 2
		user.visible_message(span_notice("[user] begins fumbling about, trying to attach [attachment] to [parent]."),
		span_notice("You begin fumbling about, trying to attach [attachment] to [parent]."), null, 4)
		idisplay = BUSY_ICON_UNSKILLED

	if(!do_after(user, attach_delay, TRUE, parent, idisplay))
		return FALSE
	
	user.visible_message(span_notice("[user] attaches [attachment] to [parent]."),
	span_notice("You attach [attachment] to [parent]."), null, 4)
	playsound(user, attachment_data["attach_sound"], 15, 1, 4)
	return TRUE


/datum/component/attachment_handler/proc/can_attach(obj/item/attachment, mob/living/carbon/human/user, list/attachment_data)
	if(!slots.len)
		return FALSE

	var/slot = attachment_data["slot"]
	var/list/current_attachment_data = slots[slot]

	if(!current_attachment_data || !(attachment.type in attachables_allowed))
		to_chat(user, span_warning("You cannot attach [attachment] to [parent]!"))
		return FALSE

	if(!current_attachment_data)
		return TRUE
	var/obj/item/current_attachment_in_slot = current_attachment_data["attachment"]
	if(!CHECK_BITFIELD(current_attachment_data["flags_attach_features"], ATTACH_REMOVABLE))
		to_chat(user, span_warning("You cannot remove [current_attachment_in_slot] from [parent] to make room for [attachment]!"))
		return FALSE

	return TRUE

/datum/component/attachment_handler/proc/update_parent_overlay(datum/source)
	SIGNAL_HANDLER
	var/obj/item/parent_item = source
	for(var/list/attachment_list in attachments)
		if(!attachment_list.len)
			continue
		var/slot = attachment_list["slot"]
		var/image/overlay = attachable_overlays[slot]
		parent_item.overlays -= overlay


		overlay = image(attachment_list["overlay_icon"], parent_item, attachment_list["overlay_icon_state"])

		overlay.pixel_x = attachment_offsets["[slot]_x"] - attachment_list["pixel_shift_x"]
		overlay.pixel_y = attachment_offsets["[slot]_y"] - attachment_list["pixel_shift_y"]    

		attachable_overlays[slot] = overlay
		parent_item.overlays += overlay


/datum/component/attachment_handler/proc/is_attachment(obj/item/attachment)
    return SEND_SIGNAL(attachment, COMSIG_ITEM_IS_ATTACHMENT) & IS_ATTACHMENT

/datum/component/attachment_handler/proc/get_attachment_data(obj/item/attachment, list/list_to_fill)
    return SEND_SIGNAL(attachment, COMSIG_ITEM_GET_ATTACHMENT_DATA, list_to_fill)