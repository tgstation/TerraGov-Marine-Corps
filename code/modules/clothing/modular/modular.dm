/**
	Modular armor
*/
/obj/item/clothing/suit/modular
	name = "Modular under armor"
	desc = "Some modular armor that can have attachments"
	icon = 'icons/mob/modular/modular.dmi'
	icon_state = "under-armor"
	item_state = "under-armor"
	flags_armor_protection = CHEST|GROIN|ARMS|LEGS
	allowed = list() /// What is allowed to be equipped in suit storage
	armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 10, "bomb" = 10, "bio" = 10, "rad" = 10, "fire" = 10, "acid" = 10)
	flags_equip_slot = ITEM_SLOT_OCLOTHING
	w_class = WEIGHT_CLASS_NORMAL

	/// The human that is wearing the armor
	var/mob/living/carbon/human/owner

	// Attachment slots for armor pieces
	var/obj/item/armor_module/armor/slot_chest
	var/obj/item/armor_module/armor/slot_arms
	var/obj/item/armor_module/armor/slot_legs

	/// Installed modules
	var/list/obj/item/armor_module/module/installed_modules
	var/obj/item/armor_module/module/storage/installed_storage

 	///List of allowed types [/obj/item/armor_module] that can be installed into this modular armor.
	var/allowed_modules_path = list(
		/obj/item/armor_module,
	)
	///List of allowed types [/obj/item/armor_module] that can be installed into this modular armor.
	var/allowed_armor_path = list(
		/obj/item/armor_module,
	)
	///List of allowed types [/obj/item/armor_module] that can be installed into this modular armor.
	var/allowed_storage_path = list(
		/obj/item/armor_module,
	)


/obj/item/clothing/suit/modular/Initialize()
	. = ..()


/obj/item/clothing/suit/modular/Destroy()
	QDEL_NULL(slot_chest)
	QDEL_NULL(slot_arms)
	QDEL_NULL(slot_legs)
	return ..()


/obj/item/clothing/suit/modular/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	var/list/obj/item/armor_module/armor/armor_slots = list(slot_chest, slot_arms, slot_legs)
	listclearnulls(armor_slots)

	if(!length(armor_slots))
		to_chat(user, "<span class='notice'>There is nothing to remove</span>")
		return

	var/obj/item/armor_module/armor/armor_slot
	if(length(armor_slots) == 1) // Single item (just take it)
		armor_slot = armor_slots[1]
	else if(length(armor_slots) > 1) // Multi item, ask which piece
		armor_slot = input(user, "Which armor piece would you like to remove", "Remove armor piece") as null|anything in armor_slots
	if(!armor_slot)
		to_world("no armor slot")
		return

	if(!armor_slot.can_detach(user, src))
		to_world("can't detatch")
		return
	armor_slot.on_deattach(user, src)


/obj/item/clothing/suit/modular/update_overlays()
	. = ..()

	if(overlays)
		cut_overlays()

	if(slot_chest)
		add_overlay(mutable_appearance(slot_chest.icon, slot_chest.icon_state))
	if(slot_arms)
		add_overlay(mutable_appearance(slot_arms.icon, slot_arms.icon_state))
	if(slot_legs)
		add_overlay(mutable_appearance(slot_legs.icon, slot_legs.icon_state))

	update_clothing_icon()
