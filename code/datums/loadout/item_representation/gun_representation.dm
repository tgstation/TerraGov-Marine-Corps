/**
 * Allow to representate a gun with its attachements
 * This is only able to represent guns and child of gun
 */
/datum/item_representation/gun
	///Flat list of the representations of the attachements on the gun
	var/list/datum/item_representation/attachments = list()


/datum/item_representation/gun/New(obj/item/item_to_copy)
	if(!item_to_copy)
		return
	if(!isgun(item_to_copy))
		CRASH("/datum/item_representation/gun created from an item that is not a gun")
	..()
	var/obj/item/weapon/gun/gun_to_copy = item_to_copy
	/*
	// bit of a jank solution but it works
	// this essentially checks if the gun is a subtype that exists only to have predefined attachments
	// as a base gun can have starting_attachment_types (think stocks)
	// comparing the name should be generally a safe solution to prevent cases like getting /obj/item/weapon/gun/rifle from /obj/item/weapon/gun/rifle/standard_carbine
	*/
	var/obj/item/weapon/gun/parent = new gun_to_copy.parent_type
	if(gun_to_copy.starting_attachment_types && gun_to_copy.name == parent.name)
		item_type = gun_to_copy.parent_type
	qdel(parent)
	for(var/key in gun_to_copy.attachments_by_slot)
		if(!gun_to_copy.attachments_by_slot[key])
			continue
		if(!isgun(gun_to_copy.attachments_by_slot[key]))
			attachments += new /datum/item_representation/gun_attachement(gun_to_copy.attachments_by_slot[key])
			continue
		attachments += new /datum/item_representation/gun(gun_to_copy.attachments_by_slot[key])


/datum/item_representation/gun/instantiate_object(datum/loadout_seller/seller, master = null, mob/living/user)
	. = ..()
	if(!.)
		return
	for(var/datum/item_representation/gun_attachement AS in attachments)
		if(istype(gun_attachement, /datum/item_representation/gun))
			var/datum/item_representation/gun/gun = gun_attachement
			gun.install_on_gun(seller, ., user)
			continue
		var/datum/item_representation/gun_attachement/attachment = gun_attachement
		attachment.install_on_gun(seller, ., user)

///Instantiates and instals the type onto gun_to_attach
/datum/item_representation/gun/proc/install_on_gun(seller, obj/item/weapon/gun/gun_to_attach, mob/living/user)
	var/gun_to_vend
	if(item_type in gun_to_attach.starting_attachment_types)
		bypass_vendor_check = TRUE
	gun_to_vend = instantiate_object(seller, null, user)
	if(!gun_to_vend)
		return
	SEND_SIGNAL(gun_to_attach, COMSIG_LOADOUT_VENDOR_VENDED_ATTACHMENT_GUN, gun_to_vend)

/**
 * Allow to representate a gun attachement
 */
/datum/item_representation/gun_attachement

/datum/item_representation/gun_attachement/New(obj/item/item_to_copy)
	if(!item_to_copy)
		return
	if(!isgunattachment(item_to_copy) && !isgun(item_to_copy))
		CRASH("/datum/item_representation/gun_attachement created from an item that is not a gun attachment")
	..()

///Attach the instantiated attachment to the gun
/datum/item_representation/gun_attachement/proc/install_on_gun(seller, obj/item/weapon/gun/gun_to_attach, mob/living/user)
	var/attachment_to_vend
	if(item_type in gun_to_attach.starting_attachment_types)
		bypass_vendor_check = TRUE
	attachment_to_vend = instantiate_object(seller, null, user)
	if(!attachment_to_vend)
		return
	SEND_SIGNAL(gun_to_attach, COMSIG_LOADOUT_VENDOR_VENDED_GUN_ATTACHMENT, attachment_to_vend)

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

/datum/item_representation/handful_representation/instantiate_object(datum/loadout_seller/seller, master = null, mob/living/user)
	if(!is_handful_buyable(ammo, seller, user))
		return
	var/obj/item/ammo_magazine/handful/handful = new item_type(master)
	handful.generate_handful(ammo, caliber, max_rounds, max_rounds)
	return handful
