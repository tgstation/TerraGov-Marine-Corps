/**
	Armor module
*/
/obj/item/armor_module
	// icon = 'icons/obj/clothing/modular.dmi'
	icon = 'icons/obj/clothing/suits.dmi'
	name = "armor module"
	desc = "A dis-figured armor module, in its prime this would've been a key item in your modular armor... now its just trash."

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
		to_world("wrong armor type?")
		return FALSE

	if(!do_after(user, equip_delay, TRUE, user, BUSY_ICON_GENERIC))
		return FALSE


/** Called when the module is added to the armor */
/obj/item/armor_module/proc/on_attach(mob/living/user, obj/item/clothing/suit/modular/parent)
	SEND_SIGNAL(parent, COMSIG_ARMOR_MODULE_ATTACH, user, src)
	user.dropItemToGround(src)
	forceMove(parent)
	parent.armor = parent.armor.attachArmor(src.armor)


/** Called when the module is removed from the armor */
/obj/item/armor_module/proc/on_deattach(mob/living/user, obj/item/clothing/suit/modular/parent)
	parent.armor = parent.armor.detachArmor(src.armor)
	forceMove(get_turf(parent))
	user.put_in_any_hand_if_possible(src, warning = FALSE)
	parent.update_overlays()
	SEND_SIGNAL(parent, COMSIG_ARMOR_MODULE_DEATTACH, user, src)
