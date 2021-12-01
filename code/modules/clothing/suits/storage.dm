/obj/item/clothing/suit/storage
	var/obj/item/storage/internal/pockets = /obj/item/storage/internal/suit
	attachments_by_slot = list(
		ATTACHMENT_SLOT_MODULE,
		ATTACHMENT_SLOT_BADGE,
	)
	attachments_allowed = list(
		/obj/item/armor_module/module/better_shoulder_lamp,
		/obj/item/armor_module/module/valkyrie_autodoc,
		/obj/item/armor_module/module/fire_proof,
		/obj/item/armor_module/module/tyr_extra_armor,
		/obj/item/armor_module/module/tyr_extra_armor/mark1,
		/obj/item/armor_module/module/mimir_environment_protection,
		/obj/item/armor_module/module/mimir_environment_protection/mark1,
		/obj/item/armor_module/module/hlin_explosive_armor,
		/obj/item/armor_module/module/ballistic_armor,
		/obj/item/armor_module/module/chemsystem,
		/obj/item/armor_module/armor/badge,
	)


/obj/item/clothing/suit/storage/Initialize()
	. = ..()
	pockets = new pockets(src)


/obj/item/clothing/suit/storage/attack_hand(mob/living/user)
	if(pockets.handle_attack_hand(user))
		return ..()


/obj/item/clothing/suit/storage/MouseDrop(obj/over_object)
	if(pockets.handle_mousedrop(usr, over_object))
		return ..(over_object)


/obj/item/clothing/suit/storage/attackby(obj/item/I, mob/user, params)
	. = ..()
	return pockets.attackby(I, user, params)


/obj/item/clothing/suit/storage/emp_act(severity)
	pockets.emp_act(severity)
	return ..()


/obj/item/storage/internal/suit
	storage_slots = 2	//two slots
	max_w_class = 2		//fit only small items
	max_storage_space = 4
