/**
	Modular armor

	Modular armor consists of a a suit and helmet.
	The suit is able to have a storage, module, and 3x armor attachments (chest, arms, and legs)
	Helmets only have a single module slot.

	Suits have a single action, which is to toggle the flashlight.
	Helmets have diffrnet actions based on what module you have installed.

*/
/obj/item/clothing/suit/modular
	name = "Jaeger XM-02 combat exoskeleton"
	desc = "Designed to mount a variety of modular armor components and support systems. It comes installed with light-plating and a shoulder lamp. Mount armor pieces to it by clicking on the frame with the components. Use a crowbar to remove armor pieces, use a screwdriver to remove armor attachments."
	icon = 'icons/mob/modular/modular_armor.dmi'
	icon_state = "underarmor_icon"
	item_state = "underarmor"
	flags_atom = CONDUCT
	flags_armor_protection = CHEST|GROIN|ARMS|LEGS|FEET|HANDS
	/// What is allowed to be equipped in suit storage
	allowed = list(
		/obj/item/weapon/gun,
		/obj/item/storage/belt/sparepouch,
		/obj/item/storage/large_holster/machete,
		/obj/item/weapon/claymore,
		/obj/item/storage/belt/gun
	)
	flags_equip_slot = ITEM_SLOT_OCLOTHING
	w_class = WEIGHT_CLASS_BULKY
	time_to_equip = 2 SECONDS
	time_to_unequip = 1 SECONDS

	soft_armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 10, "bomb" = 10, "bio" = 10, "rad" = 10, "fire" = 10, "acid" = 10)
	siemens_coefficient = 0.9
	permeability_coefficient = 1
	gas_transfer_coefficient = 1

	actions_types = list(/datum/action/item_action/toggle)

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

	/// How long it takes to attach or detach to this item
	var/equip_delay = 3 SECONDS

	/// Misc stats
	light_strength = 5


/obj/item/clothing/suit/modular/Destroy()
	QDEL_NULL(slot_chest)
	QDEL_NULL(slot_arms)
	QDEL_NULL(slot_legs)

	QDEL_LIST(installed_modules)
	installed_modules = null
	QDEL_NULL(installed_storage)
	QDEL_NULL(storage)
	return ..()

/obj/item/clothing/suit/modular/mob_can_equip(mob/user, slot, warning)
	if(slot == SLOT_WEAR_SUIT && ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/clothing/under/marine/undersuit = H.w_uniform
		if(!istype(undersuit))
			to_chat(user, "<span class='warning'>You must be wearing a marine jumpsuit to equip this.</span>")
			return FALSE
	return ..()

/obj/item/clothing/suit/modular/attack_self(mob/user)
	. = ..()
	if(.)
		return
	if(!isturf(user.loc))
		to_chat(user, "<span class='warning'>You cannot turn the light on while in [user.loc].</span>")
		return
	if(COOLDOWN_CHECK(src, COOLDOWN_ARMOR_LIGHT) || !ishuman(user))
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
	if(storage.handle_mousedrop(usr, over_object))
		return ..()


/obj/item/clothing/suit/modular/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return

	if(QDELETED(user) || user.stat != CONSCIOUS)
		return TRUE

	if(istype(I, /obj/item/armor_module))
		var/obj/item/armor_module/module = I
		if(!module.can_attach(user, src))
			return FALSE
		if(!can_attach(user, module))
			return FALSE
		module.do_attach(user, src)
		update_overlays()
		return

	if(!storage)
		return
	return storage.attackby(I, user, params)


/obj/item/clothing/suit/modular/emp_act(severity)
	storage?.emp_act(severity)
	return ..()

/obj/item/clothing/suit/modular/proc/can_attach(mob/living/user, obj/item/armor_module/module, silent = FALSE)
	. = TRUE
	if(!istype(module))
		return FALSE

	if(ismob(loc) && (user.r_hand != src && user.l_hand != src))
		if(!silent)
			to_chat(user, "<span class='warning'>You need to remove the armor first.</span>")
		return FALSE

	if(!do_after(user, equip_delay, TRUE, user, BUSY_ICON_GENERIC))
		return FALSE

/obj/item/clothing/suit/modular/proc/can_detach(mob/living/user, obj/item/armor_module/module, silent = FALSE)
	. = TRUE

	if(!do_after(user, equip_delay, TRUE, user, BUSY_ICON_GENERIC))
		return FALSE


/obj/item/clothing/suit/modular/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	if(.)
		return

	if(user.action_busy)
		return FALSE

	if(!LAZYLEN(installed_modules))
		to_chat(user, "<span class='notice'>There is nothing to remove</span>")
		return TRUE

	if(ismob(loc) && (user.r_hand != src && user.l_hand != src))
		to_chat(user, "<span class='warning'>You need to remove the armor first.</span>")
		return TRUE

	var/obj/item/armor_module/attachable/attachment
	if(LAZYLEN(installed_modules) == 1) // Single item (just take it)
		attachment = installed_modules[1]
	else if(LAZYLEN(installed_modules) > 1) // Multi item, ask which piece
		attachment = input(user, "Which module would you like to remove", "Remove module") as null|anything in installed_modules
	if(!attachment)
		return TRUE

	if(!can_detach(user, attachment))
		return TRUE

	attachment.do_detach(user, src)
	update_overlays()
	return TRUE


/obj/item/clothing/suit/modular/crowbar_act(mob/living/user, obj/item/I)
	. = ..()
	if(.)
		return

	if(user.action_busy)
		return FALSE

	if(ismob(loc) && (user.r_hand != src && user.l_hand != src))
		to_chat(user, "<span class='warning'>You need to remove the armor first.</span>")
		return TRUE

	var/list/obj/item/armor_module/armor/armor_slots = list()
	if(slot_chest)
		armor_slots += slot_chest
	if(slot_arms)
		armor_slots += slot_arms
	if(slot_legs)
		armor_slots += slot_legs

	if(!length(armor_slots))
		to_chat(user, "<span class='notice'>There is nothing to remove</span>")
		return TRUE

	var/obj/item/armor_module/armor/armor_slot
	if(length(armor_slots) == 1) // Single item (just take it)
		armor_slot = armor_slots[1]
	else if(length(armor_slots) > 1) // Multi item, ask which piece
		armor_slot = input(user, "Which armor piece would you like to remove", "Remove armor piece") as null|anything in armor_slots
	if(!armor_slot)
		return TRUE

	if(!can_detach(user, armor_slot))
		return TRUE
	armor_slot.do_detach(user, src)
	update_overlays()
	return TRUE


/obj/item/clothing/suit/modular/wirecutter_act(mob/living/user, obj/item/I)
	. = ..()
	if(.)
		return

	if(user.action_busy)
		return FALSE

	if(!installed_storage)
		to_chat(user, "<span class='notice'>There is nothing to remove</span>")
		return TRUE

	if(ismob(loc) && (user.r_hand != src && user.l_hand != src))
		to_chat(user, "<span class='warning'>You need to remove the armor first.</span>")
		return TRUE

	if(!can_detach(user, installed_storage))
		return TRUE
	installed_storage.do_detach(user, src)
	update_overlays()
	return TRUE

/obj/item/clothing/suit/modular/update_overlays()
	. = ..()

	if(overlays)
		cut_overlays()

	if(slot_chest)
		add_overlay(image(slot_chest.icon, slot_chest.icon_state))
	if(slot_arms)
		add_overlay(image(slot_arms.icon, slot_arms.icon_state))
	if(slot_legs)
		add_overlay(image(slot_legs.icon, slot_legs.icon_state))

	// we intentionally do not add modules here
	// as the icons are not made to be added in world, only on mobs.

	if(installed_storage)
		add_overlay(image(installed_storage.icon, installed_storage.icon_state))

	update_clothing_icon()


/obj/item/clothing/suit/modular/get_mechanics_info()
	. = ..()
	. += "<br><br />This is a piece of modular armor, It can equip different attachments.<br />"
	. += "<br>It currently has [LAZYLEN(installed_modules)] / [max_modules] modules installed."
	. += "<ul>"
	if(LAZYLEN(installed_modules))
		for(var/obj/item/armor_module/mod in installed_modules)
			. += "<li>[mod]</li>"
	. += "</ul>"

	if(slot_chest)
		. += "<br> It has a [slot_chest] installed."
	if(slot_arms)
		. += "<br> It has a [slot_arms] installed."
	if(slot_legs)
		. += "<br> It has a [slot_legs] installed."
	if(installed_storage)
		. += "<br> It has a [installed_storage] installed."


/** Core helmet module */
/obj/item/clothing/head/modular
	name = "Jaeger Pattern Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points."
	icon = 'icons/mob/modular/modular_armor.dmi'
	icon_state = "medium_helmet"
	flags_armor_protection = HEAD
	flags_armor_features = ARMOR_NO_DECAP
	flags_inventory = BLOCKSHARPOBJ
	flags_inv_hide = HIDEEARS
	allowed = list()
	flags_equip_slot = ITEM_SLOT_HEAD
	w_class = WEIGHT_CLASS_NORMAL

	soft_armor = list("melee" = 15, "bullet" = 15, "laser" = 15, "energy" = 15, "bomb" = 15, "bio" = 15, "rad" = 15, "fire" = 15, "acid" = 15)

	actions_types = list(/datum/action/item_action/toggle)

	/// Reference to the installed module
	var/obj/item/helmet_module/installed_module

	/// How long it takes to attach or detach to this item
	var/equip_delay = 3 SECONDS


/obj/item/clothing/head/modular/Initialize()
	. = ..()
	// Removes the _icon from the end of the icon_state
	icon_state = "[initial(icon_state)]_icon"
	item_state = initial(icon_state)


/obj/item/clothing/head/modular/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return

	if(!istype(I, /obj/item/facepaint))
		return FALSE

	var/obj/item/facepaint/paint = I
	if(paint.uses < 1)
		to_chat(user, "<span class='warning'>\the [paint] is out of color!</span>")
		return TRUE
	paint.uses--

	var/new_color = input(user, "Pick a color", "Pick color", "") in list(
		"black", "snow", "desert", "gray", "brown", "red", "blue", "yellow", "green", "aqua", "purple", "orange"
	)

	if(!do_after(user, 1 SECONDS, TRUE, src, BUSY_ICON_GENERIC))
		return TRUE

	icon_state = "[initial(icon_state)]_[new_color]_icon"
	item_state = "[initial(icon_state)]_[new_color]"

	return TRUE


/obj/item/clothing/head/modular/Destroy()
	QDEL_NULL(installed_module)
	return ..()


/obj/item/clothing/head/modular/item_action_slot_check(mob/user, slot)
	if(!ishuman(user))
		return FALSE
	if(slot != SLOT_HEAD)
		return FALSE
	if(installed_module?.module_type != ARMOR_MODULE_TOGGLE)
		return FALSE
	return TRUE //only give action button when armor is worn.


/obj/item/clothing/head/modular/attack_self(mob/user)
	. = ..()
	if(.)
		return
	if(!isturf(user.loc))
		to_chat(user, "<span class='warning'>You cannot turn the module on while in [user.loc].</span>")
		return
	if(COOLDOWN_CHECK(user, COOLDOWN_ARMOR_ACTION) || !ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.head != src)
		return
	installed_module?.toggle_module(user, src)
	return TRUE



/obj/item/clothing/head/modular/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	if(.)
		return

	if(user.action_busy)
		return FALSE

	if(!installed_module)
		to_chat(user, "<span class='notice'>There is nothing to remove</span>")
		return TRUE

	var/obj/item/armor_module/attachable/attachment = installed_module
	if(!can_detach(user, attachment))
		return TRUE

	attachment.do_detach(user, src)
	update_overlays()
	return TRUE


/obj/item/clothing/head/modular/update_overlays()
	. = ..()
	update_clothing_icon()


/obj/item/clothing/head/modular/get_mechanics_info()
	. = ..()
	. = ..()
	. += "<br><br />This is a piece of modular armor, It can equip different attachments.<br />"
	. += "<br>It currently has [installed_module ? installed_module : "nothing"] installed."

/obj/item/clothing/head/modular/proc/can_attach(mob/living/user, obj/item/helmet_module/module, silent = FALSE)
	. = TRUE
	if(!istype(module))
		return FALSE

	if(ismob(loc) && (user.r_hand != src && user.l_hand != src))
		if(!silent)
			to_chat(user, "<span class='warning'>You need to remove the armor first.</span>")
		return FALSE

	if(installed_module)
		if(!silent)
			to_chat(user,"<span class='warning'>There is already an installed module.</span>")
		return FALSE

	if(!do_after(user, equip_delay, TRUE, user, BUSY_ICON_GENERIC))
		return FALSE

/obj/item/clothing/head/modular/proc/can_detach(mob/living/user, obj/item/helmet_module/module, silent = FALSE)
	. = TRUE

	if(!do_after(user, equip_delay, TRUE, user, BUSY_ICON_GENERIC))
		return FALSE

/obj/item/clothing/head/modular/light
	name = "Jaeger Pattern light Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points."
	icon_state = "light_helmet"
	soft_armor = list("melee" = 50, "bullet" = 50, "laser" = 50, "energy" = 50, "bomb" = 50, "bio" = 50, "rad" = 50, "fire" = 50, "acid" = 50)
	accuracy_mod = 10

/obj/item/clothing/head/modular/medium
	name = "Jaeger Pattern medium Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points."
	icon_state = "medium_helmet"
	soft_armor = list("melee" = 60, "bullet" = 60, "laser" = 60, "energy" = 60, "bomb" = 60, "bio" = 60, "rad" = 60, "fire" = 60, "acid" = 60)
	accuracy_mod = 0

/obj/item/clothing/head/modular/heavy
	name = "Jaeger Pattern heavy Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points."
	icon_state = "heavy_helmet"
	soft_armor = list("melee" = 75, "bullet" = 75, "laser" = 75, "energy" = 75, "bomb" = 75, "bio" = 75, "rad" = 75, "fire" = 75, "acid" = 75)
	accuracy_mod = -10
