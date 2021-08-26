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
	var/equip_delay = 0.5 SECONDS

	/// Misc stats
	light_range = 5


/obj/item/clothing/suit/modular/Destroy()
	QDEL_NULL(slot_chest)
	QDEL_NULL(slot_arms)
	QDEL_NULL(slot_legs)

	QDEL_LIST(installed_modules)
	installed_modules = null
	QDEL_NULL(installed_storage)
	QDEL_NULL(storage)
	return ..()

/obj/item/clothing/suit/modular/apply_custom(image/standing)
	if(slot_chest)
		standing.overlays += image(slot_chest.icon, ITEM_STATE_IF_SET(slot_chest))
	if(slot_arms)
		standing.overlays += image(slot_arms.icon, ITEM_STATE_IF_SET(slot_arms))
	if(slot_legs)
		standing.overlays += image(slot_legs.icon, ITEM_STATE_IF_SET(slot_legs))
	for(var/mod in installed_modules)
		var/obj/item/armor_module/module = mod
		standing.overlays += image(module.icon, ITEM_STATE_IF_SET(module))
	if(installed_storage)
		standing.overlays += image(installed_storage.icon, ITEM_STATE_IF_SET(installed_storage))


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


/obj/item/clothing/suit/modular/item_action_slot_check(mob/user, slot)
	if(!light_range) // No light no ability
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
			to_chat(user, span_warning("You need to remove the armor first."))
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

	if(user.do_actions)
		return FALSE

	if(!LAZYLEN(installed_modules))
		to_chat(user, span_notice("There is nothing to remove"))
		return TRUE

	if(ismob(loc) && (user.r_hand != src && user.l_hand != src))
		to_chat(user, span_warning("You need to remove the armor first."))
		return TRUE

	var/obj/item/armor_module/attachable/attachment
	if(LAZYLEN(installed_modules) == 1) // Single item (just take it)
		attachment = installed_modules[1]
	else if(LAZYLEN(installed_modules) > 1) // Multi item, ask which piece
		attachment = tgui_input_list(user, "Which module would you like to remove", "Remove module", installed_modules)
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

	if(user.do_actions)
		return FALSE

	if(ismob(loc) && (user.r_hand != src && user.l_hand != src))
		to_chat(user, span_warning("You need to remove the armor first."))
		return TRUE

	var/list/obj/item/armor_module/armor/armor_slots = list()
	if(slot_chest)
		armor_slots += slot_chest
	if(slot_arms)
		armor_slots += slot_arms
	if(slot_legs)
		armor_slots += slot_legs

	if(!length(armor_slots))
		to_chat(user, span_notice("There is nothing to remove"))
		return TRUE

	var/obj/item/armor_module/armor/armor_slot
	if(length(armor_slots) == 1) // Single item (just take it)
		armor_slot = armor_slots[1]
	else if(length(armor_slots) > 1) // Multi item, ask which piece
		armor_slot = tgui_input_list(user, "Which armor piece would you like to remove", "Remove armor piece", armor_slots)
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

	if(user.do_actions)
		return FALSE

	if(!installed_storage)
		to_chat(user, span_notice("There is nothing to remove"))
		return TRUE

	if(ismob(loc) && (user.r_hand != src && user.l_hand != src))
		to_chat(user, span_warning("You need to remove the armor first."))
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

/obj/item/clothing/suit/modular/pas11x
	name = "\improper PAS-11X pattern armored vest"
	desc = "A modified version of the PAS-11 that has been fit with Jaeger module attach points in order to give use to the surplus armor left while being able to compete with the X-02 Exoskeleton. Use it to toggle the built-in flashlight."
	soft_armor = list("melee" = 40, "bullet" = 60, "laser" = 60, "energy" = 45, "bomb" = 45, "bio" = 45, "rad" = 45, "fire" = 45, "acid" = 50)
	icon_state = "pas11_icon"
	item_state = "pas11"
	slowdown = 0.5
	flags_item_map_variant = (ITEM_JUNGLE_VARIANT|ITEM_ICE_VARIANT|ITEM_PRISON_VARIANT)

/obj/item/clothing/suit/modular/pas11x/can_attach(mob/living/user, obj/item/armor_module/module, silent)
	if(istype(module, /obj/item/armor_module/armor))//can't attach armor.
		return FALSE
	return ..()



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

	actions_types = list(/datum/action/item_action/toggle)

	greyscale_config = /datum/greyscale_config/modularhelmet_infantry
	greyscale_colors = "#5B6036#f7fb58"

	/// Reference to the installed module
	var/obj/item/helmet_module/installed_module

	/// How long it takes to attach or detach to this item
	var/equip_delay = 3 SECONDS

	///whether this helmet should be using its emissive overlay or not
	var/visor_emissive_on = TRUE
	///Initial hex color we use when applying the visor color
	var/visor_color_hex = "#f7fb58"
	///Initial hex color we use when applying the main helmet color
	var/main_color_hex = "#5B6036"
	///Greyscale config color we use for the visor
	var/visor_greyscale_config = /datum/greyscale_config/modular_helmet_visor_emissive
	///optional assoc list of colors we can color this armor
	var/list/colorable_colors

/obj/item/clothing/head/modular/Initialize(mapload)
	. = ..()
	if(!visor_emissive_on || !visor_greyscale_config)
		return
	AddElement(/datum/element/special_clothing_overlay/modular_helmet_visor, HEAD_LAYER, visor_greyscale_config, visor_color_hex)
	update_icon()

/obj/item/clothing/head/modular/Destroy()
	QDEL_NULL(installed_module)
	return ..()

/obj/item/clothing/head/modular/update_greyscale(list/colors, update)
	. = ..()
	if(!greyscale_config)
		return
	item_icons = list(slot_head_str = icon)
	if(length(colors) >= 2) //for only single color helmets with no visor
		visor_color_hex = colors[2]

///Will force faction colors on this helmet
/obj/item/clothing/head/modular/proc/limit_colorable_colors(faction)
	switch(faction)
		if(FACTION_TERRAGOV)
			var/split_colors = list("#2A4FB7")
			if(visor_color_hex)
				split_colors += visor_color_hex
			set_greyscale_colors(split_colors)
			colorable_colors = list(
				"blue" = "#2A4FB7",
				"aqua" = "#2098A0",
				"purple" = "#871F8F",
			)
		if(FACTION_TERRAGOV_REBEL)
			var/split_colors = list("#CC2C32")
			if(visor_color_hex)
				split_colors += visor_color_hex
			set_greyscale_colors(split_colors)
			colorable_colors = list(
				"red" = "#CC2C32",
				"orange" = "#BC4D25",
				"yellow" = "#B7B21F",
			)

/obj/item/clothing/head/modular/examine(mob/user, distance, infix, suffix)
	. = ..()
	if(visor_greyscale_config)
		to_chat(user, "Right click the helmet to toggle the visor internal lighting.")
		to_chat(user, "Right click the helmet with paint to color the visor internal lighting.")

/obj/item/clothing/head/modular/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return

	if(!istype(I, /obj/item/facepaint))
		return FALSE

	if(!greyscale_config)
		return FALSE

	var/obj/item/facepaint/paint = I
	if(paint.uses < 1)
		to_chat(user, span_warning("\the [paint] is out of color!"))
		return TRUE
	paint.uses--
	var/new_color
	if(colorable_colors)
		new_color = colorable_colors[tgui_input_list(user, "Pick a color", "Pick color", colorable_colors)]
	else
		new_color = input(user, "Pick a color", "Pick color") as null|color

	if(!new_color)
		return

	if(!do_after(user, 1 SECONDS, TRUE, src, BUSY_ICON_GENERIC))
		return TRUE

	main_color_hex = new_color
	var/list/split_colors = list(new_color)
	if(visor_color_hex)
		split_colors += visor_color_hex
	set_greyscale_colors(split_colors)
	return TRUE

/obj/item/clothing/head/modular/attackby_alternate(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return

	if(!visor_color_hex)
		return

	if(!istype(I, /obj/item/facepaint))
		return FALSE

	var/obj/item/facepaint/paint = I
	if(paint.uses < 1)
		to_chat(user, "<span class='warning'>\the [paint] is out of color!</span>")
		return TRUE
	paint.uses--

	var/new_color = input(user, "Pick a color", "Pick color") as null|color
	if(!new_color)
		return

	if(!do_after(user, 1 SECONDS, TRUE, src, BUSY_ICON_GENERIC))
		return TRUE

	visor_color_hex = new_color
	set_greyscale_colors(list(main_color_hex, new_color))

/obj/item/clothing/head/modular/attack_hand_alternate(mob/living/carbon/human/user)
	if(user.head == src)
		return //must NOT be worn to toggle
	if(!visor_greyscale_config)
		return
	visor_emissive_on = !visor_emissive_on
	if(visor_emissive_on)
		AddElement(/datum/element/special_clothing_overlay/modular_helmet_visor, HEAD_LAYER, visor_greyscale_config, visor_color_hex)
	else
		RemoveElement(/datum/element/special_clothing_overlay/modular_helmet_visor, HEAD_LAYER, visor_greyscale_config, visor_color_hex)
	update_icon()

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
		to_chat(user, span_warning("You cannot turn the module on while in [user.loc]."))
		return
	if(TIMER_COOLDOWN_CHECK(user, COOLDOWN_ARMOR_ACTION) || !ishuman(user))
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

	if(user.do_actions)
		return FALSE

	if(!installed_module)
		to_chat(user, span_notice("There is nothing to remove"))
		return TRUE

	var/obj/item/armor_module/attachable/attachment = installed_module
	if(!can_detach(user, attachment))
		return TRUE

	attachment.do_detach(user, src)
	update_overlays()
	return TRUE


/obj/item/clothing/head/modular/update_overlays()
	. = ..()
	if(installed_module)
		. += image(installed_module.icon, installed_module.item_state)
	if(visor_emissive_on)
		. += emissive_appearance('icons/mob/modular/infantry.dmi', "visor")

/obj/item/clothing/head/modular/apply_custom(image/standing)
	if(installed_module)
		standing.overlays += image(installed_module.icon, ITEM_STATE_IF_SET(installed_module))

/obj/item/clothing/head/modular/get_mechanics_info()
	. = ..()
	. += "<br><br />This is a piece of modular armor, It can equip different attachments.<br />"
	. += "<br>It currently has [installed_module ? installed_module : "nothing"] installed."

/obj/item/clothing/head/modular/proc/can_attach(mob/living/user, obj/item/helmet_module/module, silent = FALSE)
	. = TRUE
	if(!istype(module))
		return FALSE

	if(ismob(loc) && (user.r_hand != src && user.l_hand != src))
		if(!silent)
			to_chat(user, span_warning("You need to remove the armor first."))
		return FALSE

	if(installed_module)
		if(!silent)
			to_chat(user,span_warning("There is already an installed module."))
		return FALSE

	if(user.do_actions)
		return FALSE

	if(!do_after(user, equip_delay, TRUE, user, BUSY_ICON_GENERIC))
		return FALSE
	update_overlays()

/obj/item/clothing/head/modular/proc/can_detach(mob/living/user, obj/item/helmet_module/module, silent = FALSE)
	. = TRUE

	if(!do_after(user, equip_delay, TRUE, user, BUSY_ICON_GENERIC))
		return FALSE
	update_overlays()

/obj/item/clothing/head/modular/marine
	name = "Jaeger Pattern Infantry Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points. Has Infantry markings."
	icon_state = "infantry_helmet"
	soft_armor = list("melee" = 50, "bullet" = 50, "laser" = 50, "energy" = 50, "bomb" = 50, "bio" = 50, "rad" = 50, "fire" = 50, "acid" = 50)
	accuracy_mod = 0
	greyscale_config = /datum/greyscale_config/modularhelmet_infantry
	visor_greyscale_config = /datum/greyscale_config/modular_helmet_visor_emissive

/obj/item/clothing/head/modular/marine/skirmisher
	name = "Jaeger Pattern Skirmisher Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points. Has Skirmisher markings."
	icon_state = "skirmisher_helmet"
	greyscale_config = /datum/greyscale_config/modularhelmet_skirmisher
	visor_greyscale_config = /datum/greyscale_config/modular_helmet_visor_emissive/skirmisher

/obj/item/clothing/head/modular/marine/assault
	name = "Jaeger Pattern Assault Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points. Has Assault markings."
	icon_state = "assault_helmet"
	greyscale_config = /datum/greyscale_config/modularhelmet_assault
	visor_greyscale_config = /datum/greyscale_config/modular_helmet_visor_emissive/assault

/obj/item/clothing/head/modular/marine/eva
	name = "Jaeger Pattern EVA Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points. Has EVA markings."
	icon_state = "eva_helmet"
	greyscale_config = /datum/greyscale_config/modularhelmet_eva
	visor_greyscale_config = /datum/greyscale_config/modular_helmet_visor_emissive/eva

/obj/item/clothing/head/modular/marine/eva/skull
	name = "Jaeger Pattern EVA Skull Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points. Has EVA markings and a skull on the visor."
	icon_state = "eva_skull_helmet"
	greyscale_config = /datum/greyscale_config/modularhelmet_eva_skull
	visor_greyscale_config = /datum/greyscale_config/modular_helmet_visor_emissive_skull

/obj/item/clothing/head/modular/marine/eod
	name = "Jaeger Pattern EOD Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points. Has EOD markings"
	icon_state = "eod_helmet"
	greyscale_config = /datum/greyscale_config/modularhelmet_eod
	visor_greyscale_config = /datum/greyscale_config/modular_helmet_visor_emissive/eod

/obj/item/clothing/head/modular/marine/scout
	name = "Jaeger Pattern Scout Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points. Has Scout markings"
	icon_state = "scout_helmet"
	greyscale_config = /datum/greyscale_config/modularhelmet_scout
	visor_greyscale_config = /datum/greyscale_config/modular_helmet_visor_emissive/scout

/obj/item/clothing/head/modular/marine/infantry
	name = "Jaeger Pattern Infantry-Open Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points. Has Infantry markings and no visor."
	icon_state = "infantryopen_helmet"
	greyscale_colors = "#5B6036"
	greyscale_config = /datum/greyscale_config/modularhelmet_infantry_open
	visor_color_hex = null //no visor, no color
	visor_greyscale_config = null

/obj/item/clothing/head/modular/marine/m10x
	name = "\improper M10X pattern marine helmet"
	desc = "A standard M10 Pattern Helmet modified with attach points. It reads on the label, 'The difference between an open-casket and closed-casket funeral. Wear on head for best results.'."
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
	flags_item_map_variant = (ITEM_JUNGLE_VARIANT|ITEM_ICE_VARIANT|ITEM_PRISON_VARIANT)
	greyscale_colors = null
	greyscale_config = null
	visor_color_hex = null
	visor_greyscale_config = null

/obj/item/clothing/head/modular/marine/m10x/standard
	flags_item_map_variant = (ITEM_JUNGLE_VARIANT|ITEM_ICE_VARIANT|ITEM_PRISON_VARIANT|ITEM_ICE_PROTECTION)

/obj/item/clothing/head/modular/marine/m10x/tech
	name = "\improper M10X technician helmet"
	flags_item_map_variant = (ITEM_JUNGLE_VARIANT|ITEM_ICE_VARIANT|ITEM_PRISON_VARIANT|ITEM_ICE_PROTECTION)


/obj/item/clothing/head/modular/marine/m10x/corpsman
	name = "\improper M10X corpsman helmet"
	flags_item_map_variant = (ITEM_JUNGLE_VARIANT|ITEM_ICE_VARIANT|ITEM_PRISON_VARIANT|ITEM_ICE_PROTECTION)

/obj/item/clothing/head/modular/marine/m10x/heavy
	name = "\improper M10XE pattern marine helmet"
	desc = "A standard M10XE Pattern Helmet. This is a modified version of the M10X helmet, offering an enclosed visor apparatus."
	icon_state = "heavyhelmet_icon"
	item_state = "heavyhelmet"
	flags_item_map_variant = (ITEM_JUNGLE_VARIANT|ITEM_ICE_VARIANT|ITEM_PRISON_VARIANT|ITEM_ICE_PROTECTION)

/obj/item/clothing/head/modular/marine/m10x/leader
	name = "\improper M11X pattern leader helmet"
	desc = "A slightly fancier helmet for marine leaders. This one has cushioning to project your fragile brain."
	soft_armor = list("melee" = 75, "bullet" = 65, "laser" = 50, "energy" = 50, "bomb" = 50, "bio" = 50, "rad" = 50, "fire" = 50, "acid" = 50)
	flags_item_map_variant = (ITEM_JUNGLE_VARIANT|ITEM_ICE_VARIANT|ITEM_PRISON_VARIANT|ITEM_ICE_PROTECTION)
