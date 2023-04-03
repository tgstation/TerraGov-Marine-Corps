//base suit for those that have some form of internal storage
/obj/item/clothing/suit/storage
	attachments_by_slot = list(
		ATTACHMENT_SLOT_STORAGE,
		ATTACHMENT_SLOT_BADGE,
	)
	attachments_allowed = list(
		/obj/item/armor_module/storage/general/irremovable,
		/obj/item/armor_module/greyscale/badge,
	)
	starting_attachments = list(/obj/item/armor_module/storage/general/irremovable)
