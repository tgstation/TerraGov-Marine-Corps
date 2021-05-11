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
	tie = 

/**
 * Allow to representate a tie (typically a webbing)
 * This is only able to represent /obj/item/clothing/tie/storage
 */
/datum/item_representation/tie
	///The storage of the tie
	var/datum/item_representation/storage/hold

/datum/item_representation/tie