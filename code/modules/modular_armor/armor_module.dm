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

/** Called before a module is attached */
/obj/item/armor_module/proc/can_attach(mob/living/user, obj/item/clothing/suit/modular/parent, silent = FALSE)
	. = TRUE
	if(!istype(user) || !istype(parent))
		return FALSE

/** Called before a module is removed */
/obj/item/armor_module/proc/can_detach(mob/living/user, obj/item/clothing/suit/modular/parent, silent = FALSE)
	. = TRUE
	if(!istype(parent) || !istype(user))
		return FALSE

/** Called when the module is added to the armor */
/obj/item/armor_module/proc/do_attach(mob/living/user, obj/item/clothing/suit/modular/parent)
	SEND_SIGNAL(parent, COMSIG_ARMOR_MODULE_ATTACHING, user, src)
	user.dropItemToGround(src)
	forceMove(parent)


/** Called when the module is removed from the armor */
/obj/item/armor_module/proc/do_detach(mob/living/user, obj/item/clothing/suit/modular/parent)
	forceMove(get_turf(user))
	user.put_in_any_hand_if_possible(src, warning = FALSE)
	SEND_SIGNAL(parent, COMSIG_ARMOR_MODULE_DETACHED, user, src)

