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
	if(helmet_to_copy.installed_module)
		module = new /datum/item_representation/modular_helmet_module(helmet_to_copy.installed_module)
	greyscale_colors = helmet_to_copy.greyscale_colors

/datum/item_representation/modular_helmet/instantiate_object(datum/loadout_seller/seller, master = null, mob/living/user)
	. = ..()
	if(!.)
		return
	var/obj/item/clothing/head/modular/helmet = .
	module?.install_on_helmet(seller, helmet, user)
	if(seller.faction == FACTION_NEUTRAL)
		helmet.set_greyscale_colors(greyscale_colors)
		return
	helmet.limit_colorable_colors(seller.faction)

/datum/item_representation/modular_helmet/get_tgui_data()
	var/list/tgui_data = list()
	var/icon/icon_to_convert = icon(SSgreyscale.GetColoredIconByType(initial(item_type.greyscale_config), greyscale_colors), dir = SOUTH)
	tgui_data["icons"] = list()
	tgui_data["icons"] += list(list(
		"icon" = icon2base64(icon_to_convert),
		"translateX" = NO_OFFSET,
		"translateY" = "40%",
		"scale" = 1.4,
		))
	if(module)
		icon_to_convert = icon(initial(module.item_type.icon), initial(module.item_type.icon_state), SOUTH)
		tgui_data["icons"] += list(list(
			"icon" = icon2base64(icon_to_convert),
			"translateX" = "35%",
			"translateY" = "30%",
			"scale" = 0.7,
			))
	tgui_data["name"] = initial(item_type.name)
	return tgui_data

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

///Attach the instantiated item on an helmet
/datum/item_representation/modular_helmet_module/proc/install_on_helmet(datum/loadout_seller/seller, obj/item/clothing/head/modular/helmet, mob/living/user)
	var/obj/item/helmet_module/module = instantiate_object(seller, null, user)
	module?.do_attach(null, helmet)
