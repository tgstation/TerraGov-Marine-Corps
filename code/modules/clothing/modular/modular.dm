/**
	Modular armor
*/
/obj/item/clothing/suit/modular
	name = "Jaeger XM-02 combat exoskeleton"
	desc = "Designed to mount a variety of modular armor components and support systems. It comes installed with light-plating and a shoulder lamp. Mount armor pieces to it by clicking on the frame with the components"
	icon = 'icons/mob/modular/modular_armor.dmi'
	icon_state = "underarmor_icon"
	item_state = "underarmor"
	flags_armor_protection = CHEST|GROIN|ARMS|LEGS
	/// What is allowed to be equipped in suit storage
	allowed = list(
		/obj/item/weapon/gun/,
		/obj/item/tank/emergency_oxygen,
		/obj/item/storage/bible,
		/obj/item/storage/belt/sparepouch,
		/obj/item/storage/large_holster/machete,
		/obj/item/weapon/claymore,
		/obj/item/storage/belt/gun
	)
	flags_equip_slot = ITEM_SLOT_OCLOTHING
	w_class = WEIGHT_CLASS_BULKY

	armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 10, "bomb" = 10, "bio" = 10, "rad" = 10, "fire" = 10, "acid" = 10)
	siemens_coefficient = 0.9
	permeability_coefficient = 1
	gas_transfer_coefficient = 1

	actions_types = list(/datum/action/item_action/toggle)

	/// An assoc list of stat mods
	var/list/stat_mod

	/// The human that is wearing the armor
	var/mob/living/carbon/human/owner

	/// Attachment slots for chest armor
	var/obj/item/armor_module/armor/slot_chest
	/// Attachment slots for arm armor
	var/obj/item/armor_module/armor/slot_arms
	/// Attachment slots for leg armor
	var/obj/item/armor_module/armor/slot_legs

	/** Installed modules */
	/// How many modules you can have
	var/max_modules = 1
	 /// What modules are installed
	var/list/obj/item/armor_module/attachable/installed_modules
	/// What storage is installed
	var/obj/item/armor_module/storage/installed_storage
	/// Holder for the actual storage implementation
	var/obj/item/storage/internal/storage

	///List of allowed types [/obj/item/armor_module] that can be installed into this modular armor.
	var/allowed_armor_path = list(
		/obj/item/armor_module,
	)
 	///List of allowed types [/obj/item/armor_module] that can be installed into this modular armor.
	var/allowed_modules_path = list(
		/obj/item/armor_module,
	)
	///List of allowed types [/obj/item/armor_module] that can be installed into this modular armor.
	var/allowed_storage_path = list(
		/obj/item/armor_module,
	)

	/// Misc stats
	light_strength = 4


/obj/item/clothing/suit/modular/Initialize()
	. = ..()
	installed_modules = list()


/obj/item/clothing/suit/modular/Destroy()
	QDEL_NULL(slot_chest)
	QDEL_NULL(slot_arms)
	QDEL_NULL(slot_legs)

	QDEL_NULL(installed_modules)
	QDEL_NULL(installed_storage)
	QDEL_NULL(storage)
	return ..()


/obj/item/clothing/suit/modular/attack_self(mob/user)
	if(!isturf(user.loc))
		to_chat(user, "<span class='warning'>You cannot turn the light on while in [user.loc].</span>")
		return
	if(cooldowns[COOLDOWN_ARMOR_LIGHT] || !ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.wear_suit != src)
		return
	toggle_armor_light(user)
	return TRUE

/obj/item/clothing/suit/modular/item_action_slot_check(mob/user, slot)
	if(!light_strength) // No light no ability
		return FALSE
	if(!ishuman(user))
		return FALSE
	if(slot != SLOT_WEAR_SUIT)
		return FALSE
	return TRUE //only give action button when armor is worn.


/obj/item/clothing/suit/modular/attack_hand(mob/living/user)
	if(!storage)
		return ..()
	if(storage.handle_attack_hand(user))
		return ..()


/obj/item/clothing/suit/modular/MouseDrop(over_object, src_location, over_location)
	if(!storage)
		return ..()
	if(storage?.handle_mousedrop(usr, over_object))
		return ..()


/obj/item/clothing/suit/modular/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return
	if(!storage)
		return
	if(I.tool_behaviour)
		return

	return storage.attackby(I, user, params)


/obj/item/clothing/suit/modular/emp_act(severity)
	storage?.emp_act(severity)
	return ..()


/obj/item/clothing/suit/modular/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	if(!length(installed_modules))
		to_chat(user, "<span class='notice'>There is nothing to remove</span>")
		return

	var/obj/item/armor_module/attachable/attachment
	if(length(installed_modules) == 1) // Single item (just take it)
		attachment = installed_modules[1]
	else if(length(installed_modules) > 1) // Multi item, ask which piece
		attachment = input(user, "Which module would you like to remove", "Remove module") as null|anything in installed_modules
	if(!attachment)
		return

	if(!attachment.can_detach(user, src))
		return

	attachment.on_detach(user, src)
	update_overlays()


/obj/item/clothing/suit/modular/crowbar_act(mob/living/user, obj/item/I)
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
		return

	if(!armor_slot.can_detach(user, src))
		return
	armor_slot.on_detach(user, src)
	update_overlays()




/obj/item/clothing/suit/modular/wirecutter_act(mob/living/user, obj/item/I)
	. = ..()
	if(!installed_storage)
		to_chat(user, "<span class='notice'>There is nothing to remove</span>")
		return

	if(!installed_storage.can_detach(user, src))
		return
	installed_storage.on_detach(user, src)
	update_overlays()


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

	// we intentionally do not add modules here
	// as the icons are not made to be added in world, only on mobs.

	if(installed_storage)
		add_overlay(mutable_appearance(installed_storage.icon, installed_storage.icon_state))

	update_clothing_icon()
