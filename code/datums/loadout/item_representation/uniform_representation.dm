/**
 * Allow to representate an uniform and its tie (webbings and such)
 * This is only able to represent /obj/item/clothing/under
 */
/datum/item_representation/uniform_representation
	var/datum/item_representation/tie/tie 

/datum/item_representation/uniform_representation/New(obj/item/item_to_copy)
	if(!item_to_copy)
		return
	if(!isuniform(item_to_copy))
		CRASH("/datum/item_representation/uniform_representation created from an item that is not an uniform")
	..()
	var/obj/item/clothing/under/uniform_to_copy = item_to_copy
	if(uniform_to_copy.hastie)
		tie = new /datum/item_representation/tie(uniform_to_copy.hastie)

/datum/item_representation/uniform_representation/instantiate_object(datum/loadout_seller/seller, master = null, mob/living/user)
	. = ..()
	if(!.)
		return
	tie?.install_on_uniform(seller, ., user)

/datum/item_representation/uniform_representation/get_tgui_data()
	var/list/tgui_data = list()
	var/icon/icon_to_convert = icon(initial(item_type.icon), initial(item_type.icon_state), SOUTH)
	tgui_data["icons"] = list()
	tgui_data["icons"] += list(list(
		"icon" = icon2base64(icon_to_convert),
		"translateX" = NO_OFFSET,
		"translateY" = NO_OFFSET,
		"scale" = 1,
		))
	if(tie)
		icon_to_convert = icon(initial(tie.item_type.icon), initial(tie.item_type.icon_state), SOUTH)
		tgui_data["icons"] += list(list(
			"icon" = icon2base64(icon_to_convert),
			"translateX" = NO_OFFSET,
			"translateY" = NO_OFFSET,
			"scale" = 1,
			))
	tgui_data["name"] = initial(item_type.name)
	return tgui_data
	

/**
 * Allow to representate a tie (typically a webbing)
 * This is only able to represent /obj/item/clothing/tie/storage
 */
/datum/item_representation/tie
	///The storage of the tie
	var/datum/item_representation/storage/hold

/datum/item_representation/tie/New(obj/item/item_to_copy)
	if(!item_to_copy)
		return
	if(!iswebbing(item_to_copy))
		CRASH("/datum/item_representation/tie created from an item that is not a tie storage")
	..()
	var/obj/item/clothing/tie/storage/tie = item_to_copy
	hold = new /datum/item_representation/storage(tie.hold)
	
/datum/item_representation/tie/instantiate_object(datum/loadout_seller/seller, master = null, mob/living/user)
	. = ..()
	if(!.)
		return
	var/obj/item/clothing/tie/storage/tie = .
	tie.hold = hold.instantiate_object(seller, tie, user)

///Attach the tie to a uniform
/datum/item_representation/tie/proc/install_on_uniform(datum/loadout_seller/seller, obj/item/clothing/under/uniform, mob/living/user)
	var/obj/item/clothing/tie/storage/tie = instantiate_object(seller, null, user)
	tie?.on_attached(uniform)
	uniform.hastie = tie
