/**
 * Allow to representate a gun with its attachements
 * This is only able to represent guns and child of gun
 */
/datum/item_representation/gun
	///Flat list of the representations of the attachements on the gun
	var/list/datum/item_representation/gun_attachement/attachments = list()


/datum/item_representation/gun/New(obj/item/item_to_copy)
	if(!item_to_copy)
		return
	if(!isgun(item_to_copy))
		CRASH("/datum/item_representation/gun created from an item that is not a gun")
	..()
	var/obj/item/weapon/gun/gun_to_copy = item_to_copy
	for(var/key in gun_to_copy.attachments)
		attachments += new /datum/item_representation/gun_attachement(gun_to_copy.attachments[key])


/datum/item_representation/gun/instantiate_object(datum/loadout_seller/seller)
	. = ..()
	if(!.)
		return
	for(var/datum/item_representation/gun_attachement AS in attachments)
		gun_attachement.install_on_gun(seller, .)

/**
 * Allow to representate a gun attachement
 *  */
/datum/item_representation/gun_attachement

/datum/item_representation/gun_attachement/New(obj/item/item_to_copy)
	if(!item_to_copy)
		return
	if(!isgunattachment(item_to_copy))
		CRASH("/datum/item_representation/gun_attachement created from an item that is not a gun attachment")
	..()

///Attach the instantiated attachment to the gun
/datum/item_representation/proc/install_on_gun(seller, obj/item/weapon/gun/gun_to_attach)
	var/obj/item/attachable/attachment = instantiate_object(seller)
	if(!(attachment.flags_attach_features & ATTACH_REMOVABLE))//Unremovable attachment are not in vendors
		bypass_vendor_check = TRUE
	attachment?.attach_to_gun(gun_to_attach)
