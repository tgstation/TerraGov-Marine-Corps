//base suit for those that have some form of internal storage
/obj/item/clothing/suit/storage
	w_class = WEIGHT_CLASS_BULKY
	attachments_by_slot = list(
		ATTACHMENT_SLOT_STORAGE,
		ATTACHMENT_SLOT_BADGE,
	)
	attachments_allowed = list(
		/obj/item/armor_module/storage/pocket,
		/obj/item/armor_module/armor/badge,
	)
	starting_attachments = list(/obj/item/armor_module/storage/pocket)
