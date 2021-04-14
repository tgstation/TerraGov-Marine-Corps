/**
	Core helmet module

	Holds a single attachment module that typically comes with an action
*/
/obj/item/helmet_module
	name = "helmet module"
	desc = "A dis-figured helmet module, in its prime this would've been a key item in your modular armor set... now its just trash."
	icon = 'icons/mob/modular/modular_helmet_attachment.dmi'
	icon_state = "medium_helmet_icon"
	item_state = "medium_helmet"

	/// Is the module passive (always active) or a toggle
	var/module_type = ARMOR_MODULE_PASSIVE


/obj/item/helmet_module/afterattack(atom/target, mob/user, has_proximity, click_parameters)
	. = ..()

	if(!has_proximity)
		return
	if(QDELETED(user) || user.stat != CONSCIOUS)
		return
	if(!istype(target, /obj/item/clothing/head/modular))
		return
	var/obj/item/clothing/head/modular/parent = target
	if(!parent.can_attach(user, src))
		return

	do_attach(user, parent)

/// Called when the module is added to the armor
/obj/item/helmet_module/proc/do_attach(mob/living/user, obj/item/clothing/head/modular/parent)
	user.dropItemToGround(src)
	forceMove(parent)
	parent.installed_module = src
	parent.update_overlays()


/** Called when the module is removed from the armor */
/obj/item/helmet_module/proc/do_detach(mob/living/user, obj/item/clothing/head/modular/parent)
	forceMove(get_turf(parent))
	user.put_in_any_hand_if_possible(src, warning = FALSE)
	parent.installed_module = null
	parent.update_overlays()
	SEND_SIGNAL(parent, COMSIG_HELMET_MODULE_DETACHED, user, src)


/obj/item/helmet_module/proc/toggle_module(mob/living/user, obj/item/clothing/head/modular/parent)
	return
