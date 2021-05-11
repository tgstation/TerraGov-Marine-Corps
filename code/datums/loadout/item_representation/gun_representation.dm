/**
 * Allow to representate a gun with its attachements
 * This is only able to represent guns and child of gun
 */
/datum/item_representation/gun
	/// Muzzle attachement representation
	var/datum/item_representation/gun_attachement/muzzle
	/// Rail attachement representation
	var/datum/item_representation/gun_attachement/rail
	/// Under attachement representation
	var/datum/item_representation/gun_attachement/under
	/// Stock attachement representation
	var/datum/item_representation/gun_attachement/stock

/datum/item_representation/gun/New(obj/item/item_to_copy)
	if(!item_to_copy)
		return
	if(!isgun(item_to_copy))
		CRASH("/datum/item_representation/gun created from an item that is not a gun")
	..()
	var/obj/item/weapon/gun/gun_to_copy = item_to_copy
	if(gun_to_copy.muzzle)
		muzzle = new /datum/item_representation/gun_attachement(gun_to_copy.muzzle)
	if(gun_to_copy.rail)
		rail = new /datum/item_representation/gun_attachement(gun_to_copy.rail)
	if(gun_to_copy.under)
		under = new /datum/item_representation/gun_attachement(gun_to_copy.under)
	if(gun_to_copy.stock)
		stock = new /datum/item_representation/gun_attachement(gun_to_copy.stock)

/datum/item_representation/gun/instantiate_object(datum/loadout_seller/seller)
	. = ..()
	if(!.)
		return
	var/obj/item/weapon/gun/gun = .
	muzzle?.install_on_gun(seller, gun)
	rail?.install_on_gun(seller, gun)
	under?.install_on_gun(seller, gun)
	stock?.install_on_gun(seller, gun)
	return gun

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
	attachment?.attach_to_gun(gun_to_attach)
