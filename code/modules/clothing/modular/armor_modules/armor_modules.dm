/**
	Armor module
*/
/obj/item/armor_module
	icon = 'icons/obj/clothing/modular.dmi'
	name = "armor module"
	desc = "A dis-figured armor module, in its prime this would've been a key item in your modular armor... now its just trash."

/** Check if the module can be attached to, messages the user if not silent */
/obj/item/armor_module/proc/can_attach(mob/living/user, obj/item/clothing/suit/modular/armor, silent = FALSE)
	. = TRUE
	if(is_type_in_list(src, armor.allowed_modules))
		if(!silent)
			to_chat(user, "<span class='notice'>This doesn't attach here.</span>")
		return FALSE

	SEND_SIGNAL(src, COMSIG_ARMOR_PREATTACH, user, armor)

/** Called when the module is added to the armor */
/obj/item/armor_module/proc/on_attach(mob/living/user, obj/item/clothing/suit/modular/armor)
	SEND_SIGNAL(src, COMSIG_ARMOR_ATTACH, user, armor)

/** Called when the module is removed from the armor */
/obj/item/armor_module/proc/on_deattach(mob/living/user, obj/item/clothing/suit/modular/armor)
	SEND_SIGNAL(src, COMSIG_ARMOR_DEATTACH, user, armor)
