//This file exists only to keep old typepaths so the loadout system can transition them.
//we need to do that since the jatum deserialization uses text2path but byond doenst return a path
//if that path doenst exist.



/obj/item/clothing/suit/modular/pas11x
/obj/item/clothing/head/modular/marine/m10x/tech
/obj/item/clothing/head/modular/marine/m10x/corpsman
/obj/item/clothing/head/modular/marine/m10x/standard

/obj/item/clothing/head/helmet/marine/robot
/obj/item/clothing/head/helmet/marine/robot/light
/obj/item/clothing/head/helmet/marine/robot/heavy

/obj/item/clothing/suit/storage/marine/robot
/obj/item/clothing/suit/storage/marine/robot/light
/obj/item/clothing/suit/storage/marine/robot/heavy

//Changing item_representation typepaths also breaks loadouts horribly.

/datum/item_representation/suit_with_storage
	///The storage of the suit
	var/datum/item_representation/storage/pockets

/datum/item_representation/modular_armor
	///List of attachments on the armor.
	var/list/datum/item_representation/armor_module/attachments = list()
	///Icon_state suffix for the saved icon_state varient.
	var/current_variant

/datum/item_representation/modular_helmet
	///The attachments installed.
	var/list/datum/item_representation/armor_module/attachments = list()
	///The color of the helmet
	var/greyscale_colors
	///Icon_state suffix for the saved icon_state varient.
	var/current_variant
