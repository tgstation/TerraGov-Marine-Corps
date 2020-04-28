/**
	Core armor module

	This is the core of the armor modules
	here we define the base attach / detach system of each module.
*/
/obj/item/armor_module
	name = "armor module"
	desc = "A dis-figured armor module, in its prime this would've been a key item in your modular armor... now its just trash."
	icon = 'icons/mob/modular/modular_armor.dmi'

	/// Is the module passive (always active) or a toggle
	var/module_type = ARMOR_MODULE_PASSIVE


/obj/item/armor_module/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()

	if(!proximity_flag)
		return
	if(QDELETED(user) || user.stat != CONSCIOUS)
		return
	if(!istype(target, /obj/item/clothing/suit/modular))
		return
	var/obj/item/clothing/suit/modular/parent = target
	if(!parent.can_attach(user, src))
		return

	do_attach(user, target)


/** Called when the module is added to the armor */
/obj/item/armor_module/proc/do_attach(mob/living/user, obj/item/clothing/suit/modular/parent)
	SEND_SIGNAL(parent, COMSIG_ARMOR_MODULE_ATTACH, user, src)
	user.dropItemToGround(src)
	forceMove(parent)


/** Called when the module is removed from the armor */
/obj/item/armor_module/proc/do_detach(mob/living/user, obj/item/clothing/suit/modular/parent)
	forceMove(get_turf(user))
	user.put_in_any_hand_if_possible(src, warning = FALSE)
	parent.update_overlays()
	SEND_SIGNAL(parent, COMSIG_ARMOR_MODULE_DETACH, user, src)


/obj/item/armor_module/attachable/do_attach(mob/living/user, obj/item/clothing/suit/modular/parent)
	. = ..()
	parent.installed_modules += src


/obj/item/armor_module/attachable/do_detach(mob/living/user, obj/item/clothing/suit/modular/parent)
	parent.installed_modules -= src
	return ..()
