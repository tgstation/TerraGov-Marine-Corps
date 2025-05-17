/datum/action/ability/activable/item_toggle
	name = ""
	/**
	 *the item that has this action in its list of actions. Is not necessarily the target
	 * e.g. gun attachment action: target = attachment, holder = gun.
	 */
	var/obj/item/holder_item
	/// Defines wheter we overlay the image of the obj we are linked to
	var/use_obj_appeareance = TRUE

/datum/action/ability/activable/item_toggle/New(Target, obj/item/holder)
	. = ..()
	if(!holder)
		holder = target
	holder_item = holder
	if(!name)
		name = "Use [target]"
	button.name = name

/datum/action/ability/activable/item_toggle/Destroy()
	holder_item = null
	return ..()

/datum/action/ability/activable/item_toggle/use_ability(atom/target)
	holder_item.ui_action_click(owner, src, target)
	succeed_activate()
	add_cooldown()

/datum/action/ability/activable/item_toggle/update_button_icon()
	if(visual_references[VREF_MUTABLE_LINKED_OBJ])
		button.cut_overlay(visual_references[VREF_MUTABLE_LINKED_OBJ])
	if(use_obj_appeareance)
		var/obj/item/I = target
		// -0.5 so its below maptext and above the selected frames
		var/item_image = mutable_appearance(I.icon, I.icon_state, ACTION_LAYER_IMAGE_ONTOP)
		visual_references[VREF_MUTABLE_LINKED_OBJ] = item_image
		button.add_overlay(item_image)
	else
		visual_references[VREF_MUTABLE_LINKED_OBJ] = null
	return ..()

/datum/action/ability/activable/item_toggle/remove_action(mob/M)
	deselect()
	return ..()
