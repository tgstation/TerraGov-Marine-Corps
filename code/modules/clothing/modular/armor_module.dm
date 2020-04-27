/**
	Armor module
*/
/obj/item/armor_module
	name = "armor module"
	desc = "A dis-figured armor module, in its prime this would've been a key item in your modular armor... now its just trash."
	icon = 'icons/mob/modular/modular_armor.dmi'

	var/module_type = ARMOR_MODULE_PASSIVE

	/// How long it takes to attach or detach this item
	var/equip_delay = 3 SECONDS


/obj/item/armor_module/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()

	if(!proximity_flag)
		return
	if(!user || user.stat != CONSCIOUS)
		return

	if(!can_attach(user, target))
		return

	on_attach(user, target)


/** Check if the module can be attached to, messages the user if not silent */
/obj/item/armor_module/proc/can_attach(mob/living/user, obj/item/clothing/suit/modular/parent, silent = FALSE)
	. = TRUE
	if(!istype(parent))
		return FALSE

	if(ismob(parent.loc))
		if(!silent)
			to_chat(user, "<span class='warning'>You need to remove the armor first.</span>")
		return FALSE

	// if(is_type_in_list(src, armor.allowed_modules_path))
	// 	if(!silent)
	// 		to_chat(user, "<span class='notice'>This doesn't attach here.</span>")
	// 	return FALSE

	if(!do_after(user, equip_delay, TRUE, user, BUSY_ICON_GENERIC))
		return FALSE


/** Check if the module can be attached to, messages the user if not silent */
/obj/item/armor_module/proc/can_detach(mob/living/user, obj/item/clothing/suit/modular/parent, silent = FALSE)
	. = TRUE
	if(!istype(parent))
		return FALSE

	if(!do_after(user, equip_delay, TRUE, user, BUSY_ICON_GENERIC))
		return FALSE


/** Called when the module is added to the armor */
/obj/item/armor_module/proc/on_attach(mob/living/user, obj/item/clothing/suit/modular/parent)
	SEND_SIGNAL(parent, COMSIG_ARMOR_MODULE_ATTACH, user, src)
	user.dropItemToGround(src)
	forceMove(parent)


/** Called when the module is removed from the armor */
/obj/item/armor_module/proc/on_detach(mob/living/user, obj/item/clothing/suit/modular/parent)
	forceMove(get_turf(parent))
	user.put_in_any_hand_if_possible(src, warning = FALSE)
	parent.update_overlays()
	SEND_SIGNAL(parent, COMSIG_ARMOR_MODULE_DEATTACH, user, src)



/obj/item/armor_module/attachable/can_attach(mob/living/user, obj/item/clothing/suit/modular/parent, silent)
	. = ..()

	if(!.)
		return

	if(length(parent.installed_modules) > parent.max_modules)
		if(!silent)
			to_chat(user,"<span class='warning'>There are too many pieces installed already.</span>")
		return FALSE


/obj/item/armor_module/attachable/on_attach(mob/living/user, obj/item/clothing/suit/modular/parent)
	. = ..()
	parent.installed_modules += src


/obj/item/armor_module/attachable/on_detach(mob/living/user, obj/item/clothing/suit/modular/parent)
	parent.installed_modules -= src
	return ..()

