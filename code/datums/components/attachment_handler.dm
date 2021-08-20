/datum/component/attachment_handler
	///Assoc list that stores the refs of the attachments to the parent. 'slot = reference'
	var/list/slots = list()
	///Typepath list that stores type data of allowed attachments. The attachment needs the attachment element to be able to attach regardless of what is stored here.
	var/list/attachables_allowed = list()
	///Proc the parent calls on attach.
	var/datum/callback/on_attach
	///Proc the parent calls on detach.
	var/datum/callback/on_detach
	///List of offsets for the parent that adjusts the attachment overlay. slot1_x = 1, slot1_y = 1, slot2_x = 3, slot2_y = 7, etc. Can be null, in that case the offsets for all the attachments default to 0.
	var/list/attachment_offsets = list()
	///List of the attachment overlay images. This is so that we can easily swap overlays in and out.
	var/list/attachable_overlays = list()
	///List of the icon states for the attachable_overlays. This exists so the parent or the attachment can change the overlay icon state.
	var/list/overlay_icon_states = list()


/datum/component/attachment_handler/Initialize(slots, list/attachables_allowed, list/attachment_offsets, list/starting_attachmments, datum/callback/on_attach, datum/callback/on_detach, list/overlays = list())
	. = ..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.slots = slots
	src.attachables_allowed = attachables_allowed
	src.on_attach = on_attach
	src.on_detach = on_detach
	src.attachment_offsets = attachment_offsets
	attachable_overlays = overlays //This is incase the parent wishes to have a stored reference to this list.
	attachable_overlays += slots 
	overlay_icon_states += slots 

	if(length(starting_attachmments)) //Attaches starting attachments
		for(var/starting_attachment_type in starting_attachmments)
			finish_handle_attachment(new starting_attachment_type())

	update_parent_overlay()

	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY , .proc/start_handle_attachment) //For attaching.
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, .proc/update_parent_overlay) //Updating the attachment overlays.

	RegisterSignal(parent, COMSIG_CLICK_ALT, .proc/start_detach) //For Detaching
	RegisterSignal(parent, COMSIG_ITEM_ACTIVATE_ATTACHMENT, .proc/activate_attachment) //Activating specific attachments.
	RegisterSignal(parent, COMSIG_ITEM_ATTACH_WITHOUT_USER, .proc/attach_without_user) //For attaching something without a user.
	RegisterSignal(parent, COMSIG_ITEM_UPDATE_ATTACHMENT_ICON, .proc/overlay_icon_update) //Updates a specific attachments overlay icon state.
	RegisterSignal(parent, COMSIG_PARENT_QDELETING, .proc/clean_references) //Dels attachments.

///Starts processing the attack, and whether or not the attachable can attack.
/datum/component/attachment_handler/proc/start_handle_attachment(datum/source, obj/attacking, mob/attacker)
	SIGNAL_HANDLER
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
	if(!input_attachment_data) //This is for when finish_handle_attachment is called directly. If it is called by start_handle_attachment the attachment_data just gets passed.
		attachment_data = get_attachment_data(attachment)

	if(slots[attachment_data["slot"]]) //Checks for an attachment in the current slot.
		var/obj/item/current_attachment = slots[attachment_data["slot"]]
		finish_detach(current_attachment, get_attachment_data(current_attachment), attacker) //Removes the current attachment.

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

	var/do_after_icon_type = BUSY_ICON_GENERIC
	var/attach_delay = attachment_data["attach_delay"]

	var/skill_used = attachment_data["attach_skill"]
	var/skill_upper_threshold = attachment_data["attach_skill_upper_threshold"]

	if(skill_used) //This is so we can make many attachments with different skills used to attach.
		if(user.skills.getRating(skill_used))
			user.visible_message(span_notice("[user] begins attaching [attachment] to [parent]."),
			span_notice("You begin attaching [attachment] to [parent]."), null, 4)
			if(skill_upper_threshold && user.skills.getRating(skill_used) >= skill_upper_threshold) //See if the attacher is super skilled/panzerelite born to defeat never retreat etc
				attach_delay *= 0.5
		else //If the user has no training, attaching takes twice as long and they fumble about.
			attach_delay *= 2
			user.visible_message(span_notice("[user] begins fumbling about, trying to attach [attachment] to [parent]."),
			span_notice("You begin fumbling about, trying to attach [attachment] to [parent]."), null, 4)
			do_after_icon_type = BUSY_ICON_UNSKILLED

	if(!do_after(user, attach_delay, TRUE, parent, do_after_icon_type))
		return FALSE
	user.visible_message(span_notice("[user] attaches [attachment] to [parent]."),
	span_notice("You attach [attachment] to [parent]."), null, 4)
	playsound(user, attachment_data["attach_sound"], 15, 1, 4)
	return TRUE

///Checks the current slots of the parent and if there are attachments that can be removed in those slots. Basically it makes sure theres room for the attachment. 
/datum/component/attachment_handler/proc/can_attach(obj/item/attachment, mob/living/carbon/human/user, list/attachment_data)
	if(!length(slots)) //If there is no slots, it cannot be attached to. Currently this has no use. But I had a thought about making attachments that can add/remove slots.
		return FALSE

	var/slot = attachment_data["slot"]

	if(!(slot in slots) || !(attachment.type in attachables_allowed)) //If theres no slot on parent, or if the attachment type isnt allowed, returns FALSE.
		to_chat(user, span_warning("You cannot attach [attachment] to [parent]!"))
		return FALSE

	var/obj/item/current_attachment_in_slot = slots["slot"]

	if(!current_attachment_in_slot) //If the slot is empty theres room.
		return TRUE

	var/list/current_attachment_data = get_attachment_data(current_attachment_in_slot)

	if(!CHECK_BITFIELD(current_attachment_data["flags_attach_features"], ATTACH_REMOVABLE)) //If the slots attachment is unremovable.
		to_chat(user, span_warning("You cannot remove [current_attachment_in_slot] from [parent] to make room for [attachment]!"))
		return FALSE

	return TRUE //Removal of a current attachment is done in finish_handle_attachment.

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
	for(var/key in slots) //Gets a list of the attachments that can be removed.
		var/obj/item/current_attachment = slots[key]
		if(!current_attachment)
			continue
		var/list/current_attachment_data = get_attachment_data(current_attachment)
		if(!CHECK_BITFIELD(current_attachment_data["flags_attach_features"], ATTACH_REMOVABLE))
			continue
		attachments_to_remove += current_attachment
	
	if(!length(attachments_to_remove))
		to_chat(human_user, span_warning("There are no attachments that can be removed from [parent]!"))
		return

	INVOKE_ASYNC(src, .proc/do_detach, human_user, attachments_to_remove)

///Does the detach, shows the user the removable attachments and handles the do_after.
/datum/component/attachment_handler/proc/do_detach(mob/living/carbon/human/user, list/attachments_to_remove)
	//If there is only one attachment to remove, then that will be the attachment_to_remove. If there is more than one it gives the user a list to select from.
	var/obj/item/attachment_to_remove = length(attachments_to_remove) == 1 ? attachments_to_remove[1] : tgui_input_list(user, "Choose an attachment", "Choose attachment", attachments_to_remove)
	if(!attachment_to_remove)
		return

	var/list/attachment_data = get_attachment_data(attachment_to_remove)

	var/do_after_icon_type = BUSY_ICON_GENERIC
	var/detach_delay = attachment_data["detach_delay"]

	var/skill_used = attachment_data["attach_skill"]
	var/skill_upper_threshold = attachment_data["attach_skill_upper_threshold"]

	if(skill_used) //Same as up in do_attach
		if(user.skills.getRating(skill_used))
			user.visible_message(span_notice("[user] begins detaching [attachment_to_remove] from [parent]."),
			span_notice("You begin detaching [attachment_to_remove] from [parent]."), null, 4)
			if(skill_upper_threshold && user.skills.getRating(skill_used) >= skill_upper_threshold)
				detach_delay *= 0.5
		else
			detach_delay *= 2
			user.visible_message(span_notice("[user] begins fumbling about, trying to detach [attachment_to_remove] from [parent]."),
			span_notice("You begin fumbling about, trying to detach [attachment_to_remove] from [parent]."), null, 4)
			do_after_icon_type = BUSY_ICON_UNSKILLED

	if(!do_after(user, detach_delay, TRUE, parent, do_after_icon_type))
		return FALSE

	user.visible_message(span_notice("[user] detaches [attachment_to_remove] to [parent]."),
	span_notice("You detach [attachment_to_remove] to [parent]."), null, 4)
	playsound(user, attachment_data["attach_sound"], 15, 1, 4)

	finish_detach(attachment_to_remove, attachment_data, user)

///Actually detaches the attachment. This can be called directly to bypass checks.
/datum/component/attachment_handler/proc/finish_detach(obj/item/attachment, list/attachment_data, mob/living/carbon/human/user)
	user?.put_in_hands(attachment)
	slots[attachment_data["slot"]] = null //Sets the slot the attachment is being removed from to null.

	update_parent_overlay()

	on_detach?.Invoke(attachment, user)
	var/datum/callback/attachment_on_detach = attachment_data["on_detach"]
	attachment_on_detach?.Invoke(parent, user)

///This calls the activate proc for the an attachment in slot. This serves to be a slot based way of activating attachments. Whereas if you have the reference of the attachment you want to activate you should just call its activation proc.
/datum/component/attachment_handler/proc/activate_attachment(slot, mob/user)
	SIGNAL_HANDLER
	var/obj/item/attachment_to_activate = slots[slot] //Gets the attachment in the slot to activate.
	if(!attachment_to_activate)
		return NONE
	var/list/attachment_data = get_attachment_data(attachment_to_activate)
	var/datum/callback/on_activate = attachment_data["on_activate"]
	if(!on_activate)
		return NONE //Cant activate if theres no activate callback.
	on_activate.Invoke(parent, user)
	return ATTACHMENT_ACTIVATED

///This is for other objects to be able to attach things without the need for a user.
/datum/component/attachment_handler/proc/attach_without_user(datum/source, obj/item/attachment, list/input_attachment_data)
	SIGNAL_HANDLER
	return finish_handle_attachment(attachment, input_attachment_data)

///This updates the overlays of the parent and apllies the right ones.
/datum/component/attachment_handler/proc/update_parent_overlay(datum/source)
	SIGNAL_HANDLER
	var/obj/item/parent_item = parent
	for(var/slot in slots) //Cycles through all the slots.
		var/obj/item/attachment = slots[slot]


		var/image/overlay = attachable_overlays[slot]
		parent_item.overlays -= overlay //First removes the existing overlay that occupies the slots overlay.

		if(!attachment) //No attachment, no overlay.
			attachable_overlays[slot] = null
			continue

		var/list/attachment_data = get_attachment_data(attachment)

		overlay = image(attachment_data["overlay_icon"], parent_item, overlay_icon_states[slot])

		var/slot_x = 0 //This and slot_y are for the event that the parent did not have an overlay_offsets. In that case the offsets default to 0
		var/slot_y = 0
		for(var/attachment_slot in attachment_offsets)
			if("[slot]_x" == attachment_slot)
				slot_x = attachment_offsets["[slot]_x"]
				continue
			if("[slot]_y" == attachment_slot)
				slot_y = attachment_offsets["[slot]_y"]
				continue

		var/pixel_shift_x = attachment_data["pixel_shift_x"] ? attachment_data["pixel_shift_x"] : 0 //This also is incase the attachments pixel_shift_x and y are null. If so it defaults to 0.
		var/pixel_shift_y = attachment_data["pixel_shift_y"] ? attachment_data["pixel_shift_y"] : 0

		overlay.pixel_x = slot_x - pixel_shift_x
		overlay.pixel_y = slot_y - pixel_shift_y    

		attachable_overlays[slot] = overlay
		parent_item.overlays += overlay

///Deletes the attachments when the parent deletes.
/datum/component/attachment_handler/proc/clean_references()
	SIGNAL_HANDLER
	QDEL_LIST_ASSOC_VAL(slots)

///This calls update_overlay_icon_state
/datum/component/attachment_handler/proc/overlay_icon_update(datum/source, obj/item/attachment, new_icon_state)
	SIGNAL_HANDLER
	update_overlay_icon_state(attachment, new_icon_state)

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
/datum/component/attachment_handler/proc/get_attachment_data(obj/item/attachment)
	var/list/attachment_data = list()
	SEND_SIGNAL(attachment, COMSIG_ITEM_GET_ATTACHMENT_DATA, attachment_data)
	return attachment_data
