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


/datum/item_representation/gun/instantiate_object(datum/loadout_seller/seller, master = null, mob/living/user)
	. = ..()
	if(!.)
		return
	for(var/datum/item_representation/gun_attachement/gun_attachement AS in attachments)
		gun_attachement.install_on_gun(seller, ., user)

/**
 * Allow to representate a gun attachement
 */
/datum/item_representation/gun_attachement

/datum/item_representation/gun_attachement/New(obj/item/item_to_copy)
	if(!item_to_copy)
		return
	if(!isgunattachment(item_to_copy))
		CRASH("/datum/item_representation/gun_attachement created from an item that is not a gun attachment")
	..()

///Attach the instantiated attachment to the gun
/datum/item_representation/gun_attachement/proc/install_on_gun(seller, obj/item/weapon/gun/gun_to_attach, mob/living/user)
	var/obj/item/attachable/attachment_type = item_type
	if(!(initial(attachment_type.flags_attach_features) & ATTACH_REMOVABLE))//Unremovable attachment are not in vendors
		bypass_vendor_check = TRUE
	var/obj/item/attachable/attachment = instantiate_object(seller, null, user)
	attachment?.attach_to_gun(gun_to_attach)

/**
 * Able to representate a handfull
 */
/datum/item_representation/handful_representation
	/// Icon state of the handful
	var/icon_state = ""
	/// The ammo of the handful
	var/datum/ammo/bullet/ammo
	/// The caliber of the handful
	var/caliber = ""
	/// The maxium of rounds this handful can contains
	var/max_rounds = 0
	/// The type of gun this handful can feed
	var/gun_type

/datum/item_representation/handful_representation/New(obj/item/item_to_copy)
	if(!item_to_copy)
		return
	if(!ishandful(item_to_copy))
		CRASH("/datum/item_representation/handful_representation created from an item that is not a handful")
	..()
	var/obj/item/ammo_magazine/handful/handful_to_copy = item_to_copy
	icon_state = handful_to_copy.icon_state
	ammo = handful_to_copy.default_ammo
	caliber = handful_to_copy.caliber
	max_rounds = handful_to_copy.max_rounds
	gun_type = handful_to_copy.gun_type

/datum/item_representation/handful_representation/instantiate_object(datum/loadout_seller/seller, master = null, mob/living/user)
	if(!is_handful_buyable(ammo))
		return
	var/obj/item/ammo_magazine/handful/handful = new item_type(master)
	handful.generate_handful(ammo, caliber, max_rounds, gun_type, max_rounds)
	return handful
