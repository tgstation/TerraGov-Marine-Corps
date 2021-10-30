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
	desc = "Designed to mount a variety of modular armor components and support systems. It comes installed with light-plating and a shoulder lamp. Mount armor pieces to it by clicking on the frame with the components. Use Alt-Click to remove any attached items."
	icon = 'icons/mob/modular/modular_armor.dmi'
	icon_state = "underarmor"
	item_state = "underarmor"
	item_state_worn = TRUE
	item_icons = list(slot_wear_suit_str = 'icons/mob/modular/modular_armor.dmi')
	flags_atom = CONDUCT
	flags_armor_protection = CHEST|GROIN|ARMS|LEGS|FEET|HANDS
	flags_item = SYNTH_RESTRICTED|IMPEDE_JETPACK
	/// What is allowed to be equipped in suit storage
	allowed = list(
		/obj/item/weapon/gun,
		/obj/item/storage/belt/sparepouch,
		/obj/item/storage/large_holster/blade,
		/obj/item/weapon/claymore,
		/obj/item/storage/belt/gun,
		/obj/item/storage/belt/knifepouch,
		/obj/item/weapon/twohanded,
	)
	flags_equip_slot = ITEM_SLOT_OCLOTHING
	w_class = WEIGHT_CLASS_BULKY
	time_to_equip = 2 SECONDS
	time_to_unequip = 1 SECONDS

	soft_armor = list("melee" = 5, "bullet" = 20, "laser" = 20, "energy" = 20, "bomb" = 15, "bio" = 15, "rad" = 15, "fire" = 15, "acid" = 15)
	siemens_coefficient = 0.9
	permeability_coefficient = 1
	gas_transfer_coefficient = 1

	actions_types = list(/datum/action/item_action/toggle)
	///Assoc list of available slots.
	var/list/attachments_by_slot = list(
		ATTACHMENT_SLOT_CHESTPLATE,
		ATTACHMENT_SLOT_SHOULDER,
		ATTACHMENT_SLOT_KNEE,
		ATTACHMENT_SLOT_MODULE,
		ATTACHMENT_SLOT_STORAGE,
	)
	///Typepath list of allowed attachment types.
	var/list/attachments_allowed = list(
		/obj/item/armor_module/armor/chest/marine,
		/obj/item/armor_module/armor/legs/marine,
		/obj/item/armor_module/armor/arms/marine,

		/obj/item/armor_module/armor/chest/marine/skirmisher,
		/obj/item/armor_module/armor/legs/marine/skirmisher,
		/obj/item/armor_module/armor/arms/marine/skirmisher,

		/obj/item/armor_module/armor/chest/marine/skirmisher/scout,
		/obj/item/armor_module/armor/legs/marine/scout,
		/obj/item/armor_module/armor/arms/marine/scout,

		/obj/item/armor_module/armor/chest/marine/assault,
		/obj/item/armor_module/armor/legs/marine/assault,
		/obj/item/armor_module/armor/arms/marine/assault,

		/obj/item/armor_module/armor/chest/marine/eva,
		/obj/item/armor_module/armor/legs/marine/eva,
		/obj/item/armor_module/armor/arms/marine/eva,

		/obj/item/armor_module/armor/chest/marine/assault/eod,
		/obj/item/armor_module/armor/legs/marine/eod,
		/obj/item/armor_module/armor/arms/marine/eod,

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

		/obj/item/armor_module/storage/general,
		/obj/item/armor_module/storage/ammo_mag,
		/obj/item/armor_module/storage/engineering,
		/obj/item/armor_module/storage/medical,
		/obj/item/armor_module/storage/integrated,

	)
	///Pixel offsets for specific attachment slots. Is not used currently.
	var/list/attachment_offsets = list()
	///List of attachment types that is attached to the object on initialize.
	var/list/starting_attachments = list()
	///List of the attachment overlays.
	var/list/attachment_overlays = list()
	///List of icon_state suffixes for armor varients.
	var/list/icon_state_variants = list()
	///Current varient selected.
	var/current_variant
	/// Misc stats
	light_range = 5

/obj/item/clothing/suit/modular/Initialize()
	. = ..()
	AddComponent(/datum/component/attachment_handler, attachments_by_slot, attachments_allowed, attachment_offsets, starting_attachments, null, null, null, attachment_overlays)
	update_icon()


/obj/item/clothing/suit/modular/equipped(mob/user, slot)
	. = ..()
	if(slot != SLOT_WEAR_SUIT)
		return
	for(var/key in attachments_by_slot)
		if(!attachments_by_slot[key])
			continue
		var/obj/item/armor_module/module = attachments_by_slot[key]
		if(!CHECK_BITFIELD(module.flags_attach_features, ATTACH_ACTIVATION))
			continue
		LAZYADD(module.actions_types, /datum/action/item_action/toggle)
		var/datum/action/item_action/toggle/new_action = new(module)
		new_action.give_action(user)

/obj/item/clothing/suit/modular/unequipped(mob/unequipper, slot)
	. = ..()
	if(slot != SLOT_WEAR_SUIT)
		return
	for(var/key in attachments_by_slot)
		if(!attachments_by_slot[key])
			continue
		var/obj/item/armor_module/module = attachments_by_slot[key]
		if(!CHECK_BITFIELD(module.flags_attach_features, ATTACH_ACTIVATION))
			continue
		LAZYREMOVE(module.actions_types, /datum/action/item_action/toggle)
		var/datum/action/item_action/toggle/old_action = locate(/datum/action/item_action/toggle) in module.actions
		old_action.remove_action(unequipper)

/obj/item/clothing/suit/modular/update_icon()
	. = ..()
	if(current_variant)
		icon_state = initial(icon_state) + "_[current_variant]"
		item_state = initial(item_state) + "_[current_variant]"
	update_clothing_icon()

/obj/item/clothing/suit/modular/on_pocket_insertion()
	. = ..()
	update_icon()

/obj/item/clothing/suit/modular/on_pocket_removal()
	. = ..()
	update_icon()

/obj/item/clothing/suit/modular/apply_custom(image/standing)
	for(var/key in attachment_overlays)
		var/image/overlay = attachment_overlays[key]
		if(!overlay)
			continue
		standing.overlays += overlay
	if(!attachments_by_slot[ATTACHMENT_SLOT_STORAGE] || !istype(attachments_by_slot[ATTACHMENT_SLOT_STORAGE], /obj/item/armor_module/storage))
		return standing
	var/obj/item/armor_module/storage/storage_module = attachments_by_slot[ATTACHMENT_SLOT_STORAGE]
	if(!storage_module.show_storage)
		return standing
	for(var/obj/item/stored AS in storage_module.storage.contents)
		standing.overlays += image(storage_module.show_storage_icon, icon_state = initial(stored.icon_state))
	return standing

/obj/item/clothing/suit/modular/mob_can_equip(mob/user, slot, warning)
	if(slot == SLOT_WEAR_SUIT && ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/clothing/under/marine/undersuit = H.w_uniform
		if(!istype(undersuit))
			to_chat(user, span_warning("You must be wearing a marine jumpsuit to equip this."))
			return FALSE
	return ..()


/obj/item/clothing/suit/modular/attack_self(mob/user)
	. = ..()
	if(.)
		return
	if(!isturf(user.loc))
		to_chat(user, span_warning("You cannot turn the light on while in [user.loc]."))
		return
	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_ARMOR_LIGHT) || !ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.wear_suit != src)
		return
	turn_light(user, !light_on)
	return TRUE

/obj/item/clothing/suit/modular/MouseDrop(over_object, src_location, over_location)
	if(!attachments_by_slot[ATTACHMENT_SLOT_STORAGE])
		return ..()
	if(!istype(attachments_by_slot[ATTACHMENT_SLOT_STORAGE], /obj/item/armor_module/storage))
		return ..()
	var/obj/item/armor_module/storage/armor_storage = attachments_by_slot[ATTACHMENT_SLOT_STORAGE]
	if(armor_storage.storage.handle_mousedrop(usr, over_object))
		return ..()


/obj/item/clothing/suit/modular/item_action_slot_check(mob/user, slot)
	if(!light_range) // No light no ability
		return FALSE
	if(!ishuman(user))
		return FALSE
	if(slot != SLOT_WEAR_SUIT)
		return FALSE
	return TRUE //only give action button when armor is worn.

/obj/item/clothing/suit/modular/get_mechanics_info()
	. = ..()
	. += "<br><br />This is a piece of modular armor, It can equip different attachments.<br />"
	. += "<br>It currently has [attachments_by_slot[ATTACHMENT_SLOT_MODULE] ? "a" : "no" ] module installed.</br>"
	. += "<ul>"
	. += "<li>[attachments_by_slot[ATTACHMENT_SLOT_MODULE]]</li>"
	. += "</ul>"

	if(attachments_by_slot[ATTACHMENT_SLOT_CHESTPLATE])
		. += "<br> It has a [attachments_by_slot[ATTACHMENT_SLOT_CHESTPLATE]] installed."
	if(attachments_by_slot[ATTACHMENT_SLOT_SHOULDER])
		. += "<br> It has a [attachments_by_slot[ATTACHMENT_SLOT_SHOULDER]] installed."
	if(attachments_by_slot[ATTACHMENT_SLOT_KNEE])
		. += "<br> It has a [attachments_by_slot[ATTACHMENT_SLOT_KNEE]] installed."
	if(attachments_by_slot[ATTACHMENT_SLOT_STORAGE])
		. += "<br> It has a [attachments_by_slot[ATTACHMENT_SLOT_STORAGE]] installed."

/obj/item/clothing/suit/modular/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(!istype(I, /obj/item/facepaint) || !length(icon_state_variants))
		return
	var/obj/item/facepaint/paint = I
	if(paint.uses < 1)
		to_chat(user, span_warning("\the [paint] is out of color!"))
		return
	paint.uses--
	var/variant = tgui_input_list(user, "Choose a color.", "Color", icon_state_variants)

	if(!variant)
		return

	if(!do_after(user, 1 SECONDS, TRUE, src, BUSY_ICON_GENERIC))
		return

	current_variant = variant
	update_icon()

/obj/item/clothing/suit/modular/xenonauten
	name = "\improper Xenonauten-M pattern armored vest"
	desc = "A XN-M vest, also known as Xenonauten, a set vest with modular attachments made to work in many enviroments. This one seems to be a medium variant. Alt-Click to remove attached items. Use it to toggle the built-in flashlight."
	soft_armor = list("melee" = 40, "bullet" = 60, "laser" = 60, "energy" = 50, "bomb" = 45, "bio" = 45, "rad" = 45, "fire" = 45, "acid" = 50)
	icon_state = "medium"
	item_state = "medium"
	slowdown = 0.5

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

		/obj/item/armor_module/storage/general,
		/obj/item/armor_module/storage/ammo_mag,
		/obj/item/armor_module/storage/engineering,
		/obj/item/armor_module/storage/medical,
		/obj/item/armor_module/storage/integrated,
	)

	icon_state_variants = list(
		"drab",
		"black",
		"desert",
		"snow",
	)

	current_variant = "black"



/*/obj/item/clothing/suit/modular/xenonauten/update_icon()
	. = ..()
	if(item_state == icon_state)
		return
	item_state = icon_state*/

/obj/item/clothing/suit/modular/xenonauten/light
	name = "\improper Xenonauten-L pattern armored vest"
	desc = "A XN-L vest, also known as Xenonauten, a set vest with modular attachments made to work in many enviroments. This one seems to be a light variant. Alt-Click to remove attached items. Use it to toggle the built-in flashlight."
	soft_armor = list("melee" = 35, "bullet" = 55, "laser" = 55, "energy" = 50, "bomb" = 45, "bio" = 45, "rad" = 45, "fire" = 45, "acid" = 45)
	icon_state = "light"
	item_state = "light"
	slowdown = 0.3

/obj/item/clothing/suit/modular/xenonauten/heavy
	name = "\improper Xenonauten-H pattern armored vest"
	desc = "A XN-H vest, also known as Xenonauten, a set vest with modular attachments made to work in many enviroments. This one seems to be a heavy variant. Alt-Click to remove attached items. Use it to toggle the built-in flashlight."
	soft_armor = list("melee" = 45, "bullet" = 65, "laser" = 65, "energy" = 50, "bomb" = 45, "bio" = 45, "rad" = 45, "fire" = 45, "acid" = 55)
	icon_state = "heavy"
	item_state = "heavy"
	slowdown = 0.7

/** Core helmet module */
/obj/item/clothing/head/modular
	name = "Jaeger Pattern Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points."
	icon_state = "medium_helmet"
	item_state = list(
		slot_head_str = ""
	)
	flags_armor_protection = HEAD
	flags_armor_features = ARMOR_NO_DECAP
	flags_inventory = BLOCKSHARPOBJ
	flags_inv_hide = HIDEEARS
	allowed = null
	flags_equip_slot = ITEM_SLOT_HEAD
	w_class = WEIGHT_CLASS_NORMAL

	soft_armor = list("melee" = 15, "bullet" = 15, "laser" = 15, "energy" = 15, "bomb" = 15, "bio" = 15, "rad" = 15, "fire" = 15, "acid" = 15)

	greyscale_config = /datum/greyscale_config/modularhelmet_infantry
	greyscale_colors = "#5B6036"

	/// How long it takes to attach or detach to this item
	var/equip_delay = 3 SECONDS

	///optional assoc list of colors we can color this armor
	var/list/colorable_colors

	///Assoc list of available slots.
	var/list/attachments_by_slot = list(
		ATTACHMENT_SLOT_VISOR,
		ATTACHMENT_SLOT_STORAGE,
		ATTACHMENT_SLOT_HEAD_MODULE,
	)
	///Typepath list of allowed attachment types.
	var/list/attachments_allowed = list(
		/obj/item/armor_module/module/tyr_head,
		/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet,
		/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet/mark1,
		/obj/item/armor_module/module/welding,
		/obj/item/armor_module/module/binoculars,
		/obj/item/armor_module/module/antenna,
		/obj/item/armor_module/storage/helmet,
	)

	///Pixel offsets for specific attachment slots. Is not used currently.
	var/list/attachment_offsets = list()
	///List of attachment types that is attached to the object on initialize.
	var/list/starting_attachments = list()
	///List of the attachment overlays.
	var/list/attachment_overlays = list()

	///Pixel offset on the X axis for how the helmet sits on the mob without a visor.
	var/visorless_offset_x = 0
	///Pixel offset on the Y axis for how the helmet sits on the mob without a visor.
	var/visorless_offset_y = -1
	///List of icon_state suffixes for armor varients.
	var/list/icon_state_variants = list()
	///Current varient selected.
	var/current_variant

/obj/item/clothing/head/modular/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/attachment_handler, attachments_by_slot, attachments_allowed, attachment_offsets, starting_attachments, null, null, null, attachment_overlays)
	update_icon()

/obj/item/clothing/head/modular/update_icon()
	. = ..()
	if(current_variant)
		icon_state = initial(icon_state) + "_[current_variant]"
		item_state = initial(item_state) + "_[current_variant]"
	update_clothing_icon()

/obj/item/clothing/head/modular/on_pocket_insertion()
	. = ..()
	update_icon()

/obj/item/clothing/head/modular/on_pocket_removal()
	. = ..()
	update_icon()

/obj/item/clothing/head/modular/update_greyscale(list/colors, update)
	. = ..()
	if(!greyscale_config)
		return
	item_icons = list(slot_head_str = icon)

///Will force faction colors on this helmet
/obj/item/clothing/head/modular/proc/limit_colorable_colors(faction)
	switch(faction)
		if(FACTION_TERRAGOV)
			set_greyscale_colors("#2A4FB7")
			colorable_colors = list(
				"blue" = "#2A4FB7",
				"aqua" = "#2098A0",
				"purple" = "#871F8F",
			)
		if(FACTION_TERRAGOV_REBEL)
			set_greyscale_colors("#CC2C32")
			colorable_colors = list(
				"red" = "#CC2C32",
				"orange" = "#BC4D25",
				"yellow" = "#B7B21F",
			)

/obj/item/clothing/head/modular/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return

	if(!istype(I, /obj/item/facepaint))
		return

	var/obj/item/facepaint/paint = I
	if(paint.uses < 1)
		to_chat(user, span_warning("\the [paint] is out of color!"))
		return

	if(!greyscale_config && length(icon_state_variants))
		paint.uses--
		var/variant = tgui_input_list(user, "Choose a color.", "Color", icon_state_variants)

		if(!variant)
			return

		if(!do_after(user, 1 SECONDS, TRUE, src, BUSY_ICON_GENERIC))
			return

		current_variant = variant
		update_icon()
		return

	var/new_color
	if(colorable_colors)
		new_color = colorable_colors[tgui_input_list(user, "Pick a color", "Pick color", colorable_colors)]
	else
		new_color = input(user, "Pick a color", "Pick color") as null|color

	if(!new_color)
		return

	if(!do_after(user, 1 SECONDS, TRUE, src, BUSY_ICON_GENERIC))
		return

	set_greyscale_colors(new_color)
	paint.uses--
	update_icon()

/obj/item/clothing/head/modular/MouseDrop(over_object, src_location, over_location)
	if(!attachments_by_slot[ATTACHMENT_SLOT_STORAGE])
		return ..()
	if(!istype(attachments_by_slot[ATTACHMENT_SLOT_STORAGE], /obj/item/armor_module/storage))
		return ..()
	var/obj/item/armor_module/storage/armor_storage = attachments_by_slot[ATTACHMENT_SLOT_STORAGE]
	if(armor_storage.storage.handle_mousedrop(usr, over_object))
		return ..()

/obj/item/clothing/head/modular/equipped(mob/user, slot)
	. = ..()
	if(slot != SLOT_HEAD)
		return
	for(var/key in attachments_by_slot)
		if(!attachments_by_slot[key])
			continue
		var/obj/item/armor_module/module = attachments_by_slot[key]
		if(!CHECK_BITFIELD(module.flags_attach_features, ATTACH_ACTIVATION))
			continue
		LAZYADD(module.actions_types, /datum/action/item_action/toggle)
		var/datum/action/item_action/toggle/new_action = new(module)
		new_action.give_action(user)
	update_clothing_icon()


/obj/item/clothing/head/modular/unequipped(mob/unequipper, slot)
	. = ..()
	for(var/key in attachments_by_slot)
		if(!attachments_by_slot[key])
			continue
		var/obj/item/armor_module/module = attachments_by_slot[key]
		if(!CHECK_BITFIELD(module.flags_attach_features, ATTACH_ACTIVATION))
			continue
		LAZYREMOVE(module.actions_types, /datum/action/item_action/toggle)
		var/datum/action/item_action/toggle/old_action = locate(/datum/action/item_action/toggle) in module.actions
		if(!old_action)
			continue
		old_action.remove_action(unequipper)
		module.actions = null

	update_clothing_icon()

/obj/item/clothing/head/modular/apply_custom(image/standing)
	for(var/key in attachment_overlays)
		var/image/overlay = attachment_overlays[key]
		if(!overlay)
			continue
		standing.overlays += overlay
	if(attachments_by_slot[ATTACHMENT_SLOT_STORAGE] && istype(attachments_by_slot[ATTACHMENT_SLOT_STORAGE], /obj/item/armor_module/storage))
		var/obj/item/armor_module/storage/storage_module = attachments_by_slot[ATTACHMENT_SLOT_STORAGE]
		if(storage_module.show_storage)
			for(var/obj/item/stored AS in storage_module.storage.contents)
				standing.overlays += image(storage_module.show_storage_icon, icon_state = initial(stored.icon_state))
	if(attachments_by_slot[ATTACHMENT_SLOT_VISOR])
		return standing
	standing.pixel_x = visorless_offset_x
	standing.pixel_y = visorless_offset_y
	return standing


/obj/item/clothing/head/modular/get_mechanics_info()
	. = ..()
	. += "<br><br />This is a piece of modular armor, It can equip different attachments.<br />"
	. += "<br>It currently has [attachments_by_slot[ATTACHMENT_SLOT_HEAD_MODULE] ? attachments_by_slot[ATTACHMENT_SLOT_HEAD_MODULE] : "nothing"] installed."

/obj/item/clothing/head/modular/marine
	name = "Jaeger Pattern Infantry Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points. Has Infantry markings."
	icon_state = "infantry_helmet"
	soft_armor = list("melee" = 50, "bullet" = 50, "laser" = 50, "energy" = 50, "bomb" = 50, "bio" = 50, "rad" = 50, "fire" = 50, "acid" = 50)
	accuracy_mod = 0
	greyscale_config = /datum/greyscale_config/modularhelmet_infantry
	attachments_allowed = list(
		/obj/item/armor_module/module/tyr_head,
		/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet,
		/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet/mark1,
		/obj/item/armor_module/module/welding,
		/obj/item/armor_module/module/binoculars,
		/obj/item/armor_module/module/antenna,

		/obj/item/armor_module/storage/helmet,

		/obj/item/armor_module/armor/visor/marine,
	)

	starting_attachments = list(/obj/item/armor_module/armor/visor/marine, /obj/item/armor_module/storage/helmet)

/obj/item/clothing/head/modular/marine/skirmisher
	name = "Jaeger Pattern Skirmisher Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points. Has Skirmisher markings."
	icon_state = "skirmisher_helmet"
	greyscale_config = /datum/greyscale_config/modularhelmet_skirmisher
	attachments_allowed = list(
		/obj/item/armor_module/module/tyr_head,
		/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet,
		/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet/mark1,
		/obj/item/armor_module/module/welding,
		/obj/item/armor_module/module/binoculars,
		/obj/item/armor_module/module/antenna,

		/obj/item/armor_module/storage/helmet,

		/obj/item/armor_module/armor/visor/marine/skirmisher,
	)

	starting_attachments = list(/obj/item/armor_module/armor/visor/marine/skirmisher, /obj/item/armor_module/storage/helmet)

/obj/item/clothing/head/modular/marine/assault
	name = "Jaeger Pattern Assault Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points. Has Assault markings."
	icon_state = "assault_helmet"
	greyscale_config = /datum/greyscale_config/modularhelmet_assault
	attachments_allowed = list(
		/obj/item/armor_module/module/tyr_head,
		/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet,
		/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet/mark1,
		/obj/item/armor_module/module/welding,
		/obj/item/armor_module/module/binoculars,
		/obj/item/armor_module/module/antenna,

		/obj/item/armor_module/storage/helmet,

		/obj/item/armor_module/armor/visor/marine/assault,
	)

	starting_attachments = list(/obj/item/armor_module/armor/visor/marine/assault, /obj/item/armor_module/storage/helmet)

/obj/item/clothing/head/modular/marine/eva
	name = "Jaeger Pattern EVA Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points. Has EVA markings."
	icon_state = "eva_helmet"
	greyscale_config = /datum/greyscale_config/modularhelmet_eva
	attachments_allowed = list(
		/obj/item/armor_module/module/tyr_head,
		/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet,
		/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet/mark1,
		/obj/item/armor_module/module/welding,
		/obj/item/armor_module/module/binoculars,
		/obj/item/armor_module/module/antenna,

		/obj/item/armor_module/storage/helmet,

		/obj/item/armor_module/armor/visor/marine/eva,
		/obj/item/armor_module/armor/visor/marine/eva/skull,
	)

	starting_attachments = list(/obj/item/armor_module/armor/visor/marine/eva, /obj/item/armor_module/storage/helmet)

/obj/item/clothing/head/modular/marine/eva/skull
	name = "Jaeger Pattern EVA 'Skull' Helmet"
	starting_attachments = list(/obj/item/armor_module/armor/visor/marine/eva/skull, /obj/item/armor_module/storage/helmet)

/obj/item/clothing/head/modular/marine/eod
	name = "Jaeger Pattern EOD Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points. Has EOD markings"
	icon_state = "eod_helmet"
	greyscale_config = /datum/greyscale_config/modularhelmet_eod
	attachments_allowed = list(
		/obj/item/armor_module/module/tyr_head,
		/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet,
		/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet/mark1,
		/obj/item/armor_module/module/welding,
		/obj/item/armor_module/module/binoculars,
		/obj/item/armor_module/module/antenna,

		/obj/item/armor_module/storage/helmet,

		/obj/item/armor_module/armor/visor/marine/eod,
	)

	starting_attachments = list(/obj/item/armor_module/armor/visor/marine/eod, /obj/item/armor_module/storage/helmet)

/obj/item/clothing/head/modular/marine/scout
	name = "Jaeger Pattern Scout Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points. Has Scout markings"
	icon_state = "scout_helmet"
	greyscale_config = /datum/greyscale_config/modularhelmet_scout
	attachments_allowed = list(
		/obj/item/armor_module/module/tyr_head,
		/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet,
		/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet/mark1,
		/obj/item/armor_module/module/welding,
		/obj/item/armor_module/module/binoculars,
		/obj/item/armor_module/module/antenna,

		/obj/item/armor_module/storage/helmet,

		/obj/item/armor_module/armor/visor/marine/scout,
	)

	starting_attachments = list(/obj/item/armor_module/armor/visor/marine/scout, /obj/item/armor_module/storage/helmet)

/obj/item/clothing/head/modular/marine/infantry
	name = "Jaeger Pattern Infantry-Open Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points. Has Infantry markings and no visor."
	icon_state = "infantryopen_helmet"
	greyscale_colors = "#5B6036"
	greyscale_config = /datum/greyscale_config/modularhelmet_infantry_open
	attachments_allowed = list(
		/obj/item/armor_module/module/tyr_head,
		/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet,
		/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet/mark1,
		/obj/item/armor_module/module/welding,
		/obj/item/armor_module/module/binoculars,
		/obj/item/armor_module/module/antenna,

		/obj/item/armor_module/storage/helmet,
	)
	starting_attachments = list(/obj/item/armor_module/storage/helmet)

	visorless_offset_x = 0
	visorless_offset_y = 0

/obj/item/clothing/head/modular/marine/m10x
	name = "\improper M10X pattern marine helmet"
	desc = "A standard M10 Pattern Helmet with attach points. It reads on the label, 'The difference between an open-casket and closed-casket funeral. Wear on head for best results.'."
	icon = 'icons/mob/modular/m10.dmi'
	icon_state = "helmet_icon"
	icon_override = null
	item_state = "helmet"
	item_state_worn = TRUE
	item_state_slots = null
	item_icons = list(
		slot_head_str = 'icons/mob/modular/m10.dmi',
		slot_l_hand_str = 'icons/mob/items_lefthand_1.dmi',
		slot_r_hand_str = 'icons/mob/items_righthand_1.dmi',
	)
	greyscale_colors = null
	greyscale_config = null
	attachments_allowed = list(
		/obj/item/armor_module/module/tyr_head,
		/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet,
		/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet/mark1,
		/obj/item/armor_module/module/welding,
		/obj/item/armor_module/module/binoculars,
		/obj/item/armor_module/module/antenna,
		/obj/item/armor_module/storage/helmet,
	)
	starting_attachments = list(/obj/item/armor_module/storage/helmet)
	visorless_offset_x = 0
	visorless_offset_y = 0

	icon_state_variants = list(
		"green",
		"black",
		"brown",
		"white",
	)

	current_variant = "black"

/obj/item/clothing/head/modular/marine/m10x/heavy
	name = "\improper M10XE pattern marine helmet"
	desc = "A standard M10XE Pattern Helmet. This is a modified version of the M10X helmet, offering an enclosed visor apparatus."
	icon_state = "heavyhelmet_icon"
	item_state = "heavyhelmet"

/obj/item/clothing/head/modular/marine/m10x/leader
	name = "\improper M11X pattern leader helmet"
	desc = "A slightly fancier helmet for marine leaders. This one has cushioning to project your fragile brain."
	soft_armor = list("melee" = 75, "bullet" = 65, "laser" = 50, "energy" = 50, "bomb" = 50, "bio" = 50, "rad" = 50, "fire" = 50, "acid" = 50)
