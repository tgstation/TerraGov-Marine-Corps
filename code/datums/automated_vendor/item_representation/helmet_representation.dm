/**
 * Allow to representate a modular helmet, and to color it
 * This is only able to representate items of type /obj/item/clothing/head/modular
 */
/datum/item_representation/modular_helmet
	///The color of the helmet
	var/greyscale_colors
	///The module installed
	var/datum/item_representation/modular_helmet_module/module

/datum/item_representation/modular_helmet/New(obj/item/item_to_copy)
	if(!item_to_copy)
		return
	if(!ismodularhelmet(item_to_copy))
		CRASH("/datum/item_representation/modular_helmet created from an item that is not an modular helmet")
	..()
	var/obj/item/clothing/head/modular/helmet_to_copy = item_to_copy
	module = new /datum/item_representation/modular_helmet_module(helmet_to_copy.installed_module)
	greyscale_colors = helmet_to_copy.greyscale_colors

/datum/item_representation/modular_helmet/instantiate_object()
	var/obj/item/clothing/head/modular/helmet = ..()
	module.install_on_helmet(helmet)
	helmet.set_greyscale_colors(greyscale_colors)
	return helmet

/**
 * Allow to representate an helmet module
 * This is only able to representate items of type /obj/item/helmet_module
 */
/datum/item_representation/modular_helmet_module

/datum/item_representation/modular_helmet_module/New(obj/item/item_to_copy)
	if(!item_to_copy)
		return
	if(!ishelmetmodule(item_to_copy))
		CRASH("/datum/item_representation/modular_helmet_module created from an item that is not an helmet module")
	..()

/datum/item_representation/modular_helmet_module/proc/install_on_helmet(obj/item/clothing/head/modular/helmet)
	var/obj/item/helmet_module/module = instantiate_object()
	module.do_attach(null, helmet)
