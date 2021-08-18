/datum/component/attachment_handler
	///Assoc list that stores the refs of the attachments to the parent. 'slot = reference'
	var/list/slots = list()
	///Typepath list that stores type data of allowed attachments. The attachment needs the attachment element to be able to attach regardless of what is stored here.
	var/list/attachables_allowed = list()
	///Proc the parent calls on attach.
	var/datum/callback/on_attach
	///Proc the parent calls on detach.
	var/datum/callback/on_detach
	///List of offsets for the parent that adjusts the attachment overlay. slot1_x = 1, slot1_y = 1, slot2_x = 3, slot2_y = 7, etc.
	var/list/attachment_offsets = list()
	///List of the attachment overlay images. This is so that we can easily swap overlays in and out.
	var/list/attachable_overlays = list()
	///List of the icon states for the attachable_overlays. This exists so the parent or the attachment can change the overlay icon state.
	var/list/overlay_icon_states = list()


/datum/component/attachment_handler/Initialize(_slots, list/_attachables_allowed, list/_attachment_offsets, list/starting_attachmments, datum/callback/_on_attach, datum/callback/_on_detach, list/overlays = list())
	. = ..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	slots = _slots
	attachables_allowed = _attachables_allowed
	on_attach = _on_attach
	on_detach = _on_detach
	attachment_offsets = _attachment_offsets
	attachable_overlays = overlays //This is incase the parent wishes to have a stored reference to this list.
	attachable_overlays += slots 
	overlay_icon_states += slots 

	if(starting_attachmments?.len) //Attaches starting attachments
		for(var/starting_attachment_type in starting_attachmments)
			finish_handle_attachment(new starting_attachment_type())

	update_parent_overlay()

	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY , .proc/start_handle_attachment)
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, .proc/update_parent_overlay)

	RegisterSignal(parent, COMSIG_CLICK_ALT, .proc/start_detach)
	RegisterSignal(parent, COMSIG_ITEM_ACTIVATE_ATTACHMENT, .proc/activate_attachment)
	RegisterSignal(parent, COMSIG_ITEM_ATTACH_WITHOUT_USER, .proc/attach_without_user)
	RegisterSignal(parent, COMSIG_ITEM_UPDATE_ATTACHMENT_ICON, .proc/overlay_icon_update)
	RegisterSignal(parent, COMSIG_PARENT_QDELETING, .proc/clean_references)

///Starts processing the attack, and whether or not the attachable can attack.
/datum/component/attachment_handler/proc/start_handle_attachment(datum/source, obj/attacking, mob/attacker)
	if(!is_attachment(attacking))
		return

	var/list/attachment_data = get_attachment_data(attacking)

	if(!do_attach(attacking, attacker, attachment_data))
		return

	finish_handle_attachment(attacking, attachment_data, attacker)
	var/mob/living/carbon/human/human_attacker = attacker
	human_attacker.temporarilyRemoveItemFromInventory(attacking)

///Finishes setting up the attachment. This is where the attachment actually attaches. This can be called directly to bypass any checks to directly attach an object.
/datum/component/attachment_handler/proc/finish_handle_attachment(obj/item/attachment, list/input_attachment_data, mob/attacker)
	var/list/attachment_data = input_attachment_data
	if(!input_attachment_data)
		attachment_data = get_attachment_data(attachment)

	if(slots[attachment_data["slot"]])
		var/obj/item/current_attachment = slots[attachment_data["slot"]]
		finish_detach(current_attachment, get_attachment_data(current_attachment), attacker)

	attachment.forceMove(parent)
	slots[attachment_data["slot"]] = attachment

	on_attach?.Invoke(attachment, attacker)
	var/datum/callback/attachment_on_attach = attachment_data["on_attach"]
	attachment_on_attach?.Invoke(parent, attacker)

	update_overlay_icon_state(attachment, attachment_data["overlay_icon_state"])

	update_parent_overlay()

///This is the do_after and user checks for attaching.
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

	if(skill_used)
		if(user.skills.getRating(skill_used))
			user.visible_message(span_notice("[user] begins attaching [attachment] to [parent]."),
			span_notice("You begin attaching [attachment] to [parent]."), null, 4)
			if(skill_upper_threshold && user.skills.getRating(skill_used) >= skill_upper_threshold) //See if the attacher is super skilled/panzerelite born to defeat never retreat etc
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

///Checks the current slots of the parent and if there are attachments that can be removed in those slots. Basically it makes sure theres room for the attachment. 
/datum/component/attachment_handler/proc/can_attach(obj/item/attachment, mob/living/carbon/human/user, list/attachment_data)
	if(!slots.len)
		return FALSE

	var/slot = attachment_data["slot"]

	if(!(slot in slots) || !(attachment.type in attachables_allowed))
		to_chat(user, span_warning("You cannot attach [attachment] to [parent]!"))
		return FALSE

	var/obj/item/current_attachment_in_slot = slots["slot"]

	if(!current_attachment_in_slot)
		return TRUE

	var/list/current_attachment_data = get_attachment_data(current_attachment_in_slot)

	if(!CHECK_BITFIELD(current_attachment_data["flags_attach_features"], ATTACH_REMOVABLE))
		to_chat(user, span_warning("You cannot remove [current_attachment_in_slot] from [parent] to make room for [attachment]!"))
		return FALSE

	return TRUE

///Starts with the detach, is called when the user Alt-Clicks the parent.
/datum/component/attachment_handler/proc/start_detach(datum/source, mob/user)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/human_user = user

	if(human_user.get_active_held_item() != parent && human_user.get_inactive_held_item() != parent)
		to_chat(human_user, span_warning("You must be holding [parent] to field strip it!"))
		return
	if((human_user.get_active_held_item() == parent && human_user.get_inactive_held_item()) || (human_user.get_inactive_held_item() == parent && human_user.get_active_held_item()))
		to_chat(human_user, span_warning("You need a free hand to field strip [parent]!"))
		return

	var/list/attachments_to_remove = list()
	for(var/key in slots)
		var/obj/item/current_attachment = slots[key]
		if(!current_attachment)
			continue
		var/list/current_attachment_data = get_attachment_data(current_attachment)
		if(!CHECK_BITFIELD(current_attachment_data["flags_attach_features"], ATTACH_REMOVABLE))
			continue
		attachments_to_remove += current_attachment
	
	if(!attachments_to_remove.len)
		to_chat(human_user, span_warning("There are no attachments that can be removed from [parent]!"))
		return

	INVOKE_ASYNC(src, .proc/do_detach, human_user, attachments_to_remove)

///Does the detach, shows the user the removable attachments and handles the do_after.
/datum/component/attachment_handler/proc/do_detach(mob/living/carbon/human/user, list/attachments_to_remove)
	var/obj/item/attachment_to_remove = attachments_to_remove.len == 1 ? attachments_to_remove[1] : tgui_input_list(user, "Choose an attachment", "Choose attachment", attachments_to_remove)
	if(!attachment_to_remove)
		return

	var/list/attachment_data = get_attachment_data(attachment_to_remove)

	var/idisplay = BUSY_ICON_GENERIC
	var/detach_delay = attachment_data["detach_delay"]

	var/skill_used = attachment_data["attach_skill"]
	var/skill_upper_threshold = attachment_data["attach_skill_upper_threshold"]

	if(skill_used)
		if(user.skills.getRating(skill_used))
			user.visible_message(span_notice("[user] begins detaching [attachment_to_remove] from [parent]."),
			span_notice("You begin detaching [attachment_to_remove] from [parent]."), null, 4)
			if(skill_upper_threshold && user.skills.getRating(skill_used) >= skill_upper_threshold)
				detach_delay *= 0.5
		else
			detach_delay *= 2
			user.visible_message(span_notice("[user] begins fumbling about, trying to detach [attachment_to_remove] from [parent]."),
			span_notice("You begin fumbling about, trying to detach [attachment_to_remove] from [parent]."), null, 4)
			idisplay = BUSY_ICON_UNSKILLED

	if(!do_after(user, detach_delay, TRUE, parent, idisplay))
		return FALSE
	
	user.visible_message(span_notice("[user] detaches [attachment_to_remove] to [parent]."),
	span_notice("You detach [attachment_to_remove] to [parent]."), null, 4)
	playsound(user, attachment_data["attach_sound"], 15, 1, 4)

	finish_detach(attachment_to_remove, attachment_data, user)

///Actually detaches the attachment. This can be called directly to bypass checks.
/datum/component/attachment_handler/proc/finish_detach(obj/item/attachment, list/attachment_data, mob/living/carbon/human/user)
	if(user)
		user.put_in_hands(attachment)
	slots[attachment_data["slot"]] = null

	update_parent_overlay()

	on_detach?.Invoke(attachment, user)
	var/datum/callback/attachment_on_detach = attachment_data["on_detach"]
	attachment_on_detach?.Invoke(parent, user)

	UnregisterSignal(parent, COMSIG_PARENT_QDELETING)

///This calls the activate proc for the an attachment in slot.
/datum/component/attachment_handler/proc/activate_attachment(slot, mob/user)
	SIGNAL_HANDLER
	var/obj/item/attachment_to_activate = slots[slot]
	if(!attachment_to_activate)
		return NONE
	var/list/attachment_data = get_attachment_data(attachment_to_activate)
	var/datum/callback/on_activate = attachment_data["on_activate"]
	on_activate?.Invoke(parent, user)
	return ATTACHMENT_ACTIVATED

///This is for other objects to be able to attach things without the need for a user.
/datum/component/attachment_handler/proc/attach_without_user(datum/source, obj/item/attachment, list/input_attachment_data)
	SIGNAL_HANDLER
	return finish_handle_attachment(attachment, input_attachment_data)

///This updates the overlays of the parent and apllies the right ones.
/datum/component/attachment_handler/proc/update_parent_overlay(datum/source)
	SIGNAL_HANDLER
	var/obj/item/parent_item = parent
	for(var/slot in slots)
		var/obj/item/attachment = slots[slot]


		var/image/overlay = attachable_overlays[slot]
		parent_item.overlays -= overlay

		if(!attachment)
			attachable_overlays[slot] = null
			continue

		var/list/attachment_data = get_attachment_data(attachment)

		overlay = image(attachment_data["overlay_icon"], parent_item, overlay_icon_states[slot])

		var/slot_x = 0
		var/slot_y = 0
		for(var/attachment_slot in attachment_offsets)
			if("[slot]_x" == attachment_slot)
				slot_x = attachment_offsets["[slot]_x"]
				continue
			if("[slot]_y" == attachment_slot)
				slot_y = attachment_offsets["[slot]_y"]
				continue

		overlay.pixel_x = slot_x - attachment_data["pixel_shift_x"]
		overlay.pixel_y = slot_y - attachment_data["pixel_shift_y"]    

		attachable_overlays[slot] = overlay
		parent_item.overlays += overlay

///Deletes the attachments when the parent deletes.
/datum/component/attachment_handler/proc/clean_references()
	SIGNAL_HANDLER
	for(var/key in slots)
		QDEL_NULL(slots[key])

///This calls update_overlay_icon_state
/datum/component/attachment_handler/proc/overlay_icon_update(datum/source, obj/item/attachment, new_icon_state)
	SIGNAL_HANDLER
	return update_overlay_icon_state(attachment, new_icon_state)

///This updates the overlay icon state of the inputted attachment
/datum/component/attachment_handler/proc/update_overlay_icon_state(obj/item/attachment, new_icon_state)
	for(var/key in slots)
		if(attachment != slots[key])
			continue
		var/list/attachment_data = get_attachment_data(attachment)
		overlay_icon_states[attachment_data["slot"]] = new_icon_state
		return update_parent_overlay()

///Sends a signal to the attachment, will return TRUE if the attachment recieves the signal and has the attachable element that will return the bitfield IS_ATTACHMENT.
/datum/component/attachment_handler/proc/is_attachment(obj/item/attachment)
	return SEND_SIGNAL(attachment, COMSIG_ITEM_IS_ATTACHMENT) & IS_ATTACHMENT

///Returns an assoc list from the _attachment's element with all the attachment data.
/datum/component/attachment_handler/proc/get_attachment_data(obj/item/_attachment)
	var/list/attachment_data = list()
	SEND_SIGNAL(_attachment, COMSIG_ITEM_GET_ATTACHMENT_DATA, attachment_data)
	return attachment_data