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
		/obj/item/instrument,
		/obj/item/storage/belt/sparepouch,
		/obj/item/storage/holster/blade,
		/obj/item/weapon/claymore,
		/obj/item/storage/belt/gun,
		/obj/item/storage/belt/knifepouch,
		/obj/item/weapon/twohanded,
		/obj/item/tool/pickaxe/plasmacutter,
		/obj/item/tool/shovel/etool,
		/obj/item/weapon/energy/sword,
	)
	flags_equip_slot = ITEM_SLOT_OCLOTHING
	w_class = WEIGHT_CLASS_BULKY
	time_to_equip = 2 SECONDS
	time_to_unequip = 1 SECONDS

	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)
	siemens_coefficient = 0.9
	permeability_coefficient = 1
	gas_transfer_coefficient = 1

	actions_types = list(/datum/action/item_action/toggle/suit_toggle)

	attachments_by_slot = list(
		ATTACHMENT_SLOT_CHESTPLATE,
		ATTACHMENT_SLOT_SHOULDER,
		ATTACHMENT_SLOT_KNEE,
		ATTACHMENT_SLOT_MODULE,
		ATTACHMENT_SLOT_STORAGE,
		ATTACHMENT_SLOT_BADGE,
		ATTACHMENT_SLOT_BELT,
	)
	attachments_allowed = list(
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

		/obj/item/armor_module/armor/chest/marine/helljumper,
		/obj/item/armor_module/armor/legs/marine/helljumper,
		/obj/item/armor_module/armor/arms/marine/helljumper,

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
		/obj/item/armor_module/module/eshield,

		/obj/item/armor_module/storage/general,
		/obj/item/armor_module/storage/ammo_mag,
		/obj/item/armor_module/storage/engineering,
		/obj/item/armor_module/storage/medical,
		/obj/item/armor_module/storage/general/som,
		/obj/item/armor_module/storage/engineering/som,
		/obj/item/armor_module/storage/medical/som,
		/obj/item/armor_module/storage/injector,
		/obj/item/armor_module/storage/grenade,
		/obj/item/armor_module/storage/integrated,
		/obj/item/armor_module/greyscale/badge,
	)
	light_range = 5

	///List of icon_state suffixes for armor varients.
	var/list/icon_state_variants = list()
	///Current varient selected.
	var/current_variant
	///Uniform type that is allowed to be worn with this.
	var/allowed_uniform_type = /obj/item/clothing/under/marine

/obj/item/clothing/suit/modular/Initialize()
	. = ..()
	update_icon()

/obj/item/clothing/suit/modular/update_icon()
	. = ..()
	if(current_variant)
		icon_state = initial(icon_state) + "_[current_variant]"
		item_state = initial(item_state) + "_[current_variant]"
	update_clothing_icon()

/obj/item/clothing/suit/modular/update_item_sprites()
	switch(SSmapping.configs[GROUND_MAP].armor_style)
		if(MAP_ARMOR_STYLE_JUNGLE)
			if(flags_item_map_variant & ITEM_JUNGLE_VARIANT)
				current_variant = "jungle"
		if(MAP_ARMOR_STYLE_ICE)
			if(flags_item_map_variant & ITEM_ICE_VARIANT)
				current_variant = "snow"
		if(MAP_ARMOR_STYLE_PRISON)
			if(flags_item_map_variant & ITEM_PRISON_VARIANT)
				current_variant = "prison"
		if(MAP_ARMOR_STYLE_DESERT)
			if(flags_item_map_variant & ITEM_DESERT_VARIANT)
				current_variant = "desert"

/obj/item/clothing/suit/modular/apply_custom(mutable_appearance/standing)
	. = ..()
	if(!attachments_by_slot[ATTACHMENT_SLOT_STORAGE] || !istype(attachments_by_slot[ATTACHMENT_SLOT_STORAGE], /obj/item/armor_module/storage))
		return standing
	var/obj/item/armor_module/storage/storage_module = attachments_by_slot[ATTACHMENT_SLOT_STORAGE]
	if(!storage_module.show_storage)
		return standing
	for(var/obj/item/stored AS in storage_module.storage.contents)
		standing.overlays += mutable_appearance(storage_module.show_storage_icon, icon_state = initial(stored.icon_state))
	return standing

/obj/item/clothing/suit/modular/mob_can_equip(mob/user, slot, warning)
	if(slot == SLOT_WEAR_SUIT && ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/clothing/under/undersuit = H.w_uniform
		if(!istype(undersuit, allowed_uniform_type))
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
	if(.)
		return

	if(!istype(I, /obj/item/facepaint) || !length(icon_state_variants))
		return

	var/obj/item/facepaint/paint = I
	if(paint.uses < 1)
		to_chat(user, span_warning("\the [paint] is out of color!"))
		return

	var/variant = tgui_input_list(user, "Choose a color.", "Color", icon_state_variants)

	if(!variant)
		return

	if(!do_after(user, 1 SECONDS, TRUE, src, BUSY_ICON_GENERIC))
		return

	current_variant = variant
	paint.uses--
	update_icon()

/obj/item/clothing/suit/modular/rownin
	name = "\improper Rownin Skeleton"
	desc = "A light armor, if you can even called it that, for dedicated marines that want to travel light and have agility in exchange of protection. Alt-Click to remove attached items. Use it to toggle the built-in flashlight."
	icon_state = "rownin_skeleton"
	item_state = "rownin_skeleton"
	allowed_uniform_type = /obj/item/clothing/under
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
		/obj/item/armor_module/module/eshield,

		/obj/item/armor_module/storage/general,
		/obj/item/armor_module/storage/ammo_mag,
		/obj/item/armor_module/storage/engineering,
		/obj/item/armor_module/storage/medical,
		/obj/item/armor_module/storage/general/som,
		/obj/item/armor_module/storage/engineering/som,
		/obj/item/armor_module/storage/medical/som,
		/obj/item/armor_module/storage/injector,
		/obj/item/armor_module/storage/grenade,
		/obj/item/armor_module/storage/integrated,
		/obj/item/armor_module/greyscale/badge,
	)

/** Core helmet module */
/obj/item/clothing/head/modular
	name = "Jaeger Pattern Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points."
	icon = 'icons/mob/modular/xenonauten_helmets.dmi'
	icon_state = "infantry_helmet"
	item_icons = list(
		slot_head_str = 'icons/mob/modular/xenonauten_helmets.dmi',
		slot_l_hand_str = 'icons/mob/items_lefthand_1.dmi',
		slot_r_hand_str = 'icons/mob/items_righthand_1.dmi',
	)
	flags_armor_protection = HEAD
	flags_armor_features = ARMOR_NO_DECAP
	flags_inventory = BLOCKSHARPOBJ
	flags_inv_hide = HIDEEARS|HIDE_EXCESS_HAIR
	allowed = null
	flags_equip_slot = ITEM_SLOT_HEAD
	w_class = WEIGHT_CLASS_NORMAL

	soft_armor = list(MELEE = 15, BULLET = 15, LASER = 15, ENERGY = 15, BOMB = 15, BIO = 15, FIRE = 15, ACID = 15)

	attachments_by_slot = list(
		ATTACHMENT_SLOT_VISOR,
		ATTACHMENT_SLOT_STORAGE,
		ATTACHMENT_SLOT_HEAD_MODULE,
		ATTACHMENT_SLOT_BADGE,
	)
	attachments_allowed = list(
		/obj/item/armor_module/module/tyr_head,
		/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet,
		/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet/mark1,
		/obj/item/armor_module/module/welding,
		/obj/item/armor_module/module/welding/superior,
		/obj/item/armor_module/module/binoculars,
		/obj/item/armor_module/module/binoculars/artemis_mark_two,
		/obj/item/armor_module/module/artemis,
		/obj/item/armor_module/module/antenna,
		/obj/item/armor_module/storage/helmet,
		/obj/item/armor_module/greyscale/badge,
	)

	///Pixel offset on the X axis for how the helmet sits on the mob without a visor.
	var/visorless_offset_x = 0
	///Pixel offset on the Y axis for how the helmet sits on the mob without a visor.
	var/visorless_offset_y = 0
	///List of icon_state suffixes for armor varients.
	var/list/icon_state_variants = list()
	///Current varient selected.
	var/current_variant

/obj/item/clothing/head/modular/Initialize()
	. = ..()
	update_icon()

/obj/item/clothing/head/modular/update_icon()
	. = ..()
	if(current_variant)
		icon_state = initial(icon_state) + "_[current_variant]"
		item_state = initial(item_state) + "_[current_variant]"
	update_clothing_icon()

/obj/item/clothing/head/modular/update_item_sprites()
	switch(SSmapping.configs[GROUND_MAP].armor_style)
		if(MAP_ARMOR_STYLE_JUNGLE)
			if(flags_item_map_variant & ITEM_JUNGLE_VARIANT)
				current_variant = "jungle"
		if(MAP_ARMOR_STYLE_ICE)
			if(flags_item_map_variant & ITEM_ICE_VARIANT)
				current_variant = "snow"
		if(MAP_ARMOR_STYLE_PRISON)
			if(flags_item_map_variant & ITEM_PRISON_VARIANT)
				current_variant = "prison"
		if(MAP_ARMOR_STYLE_DESERT)
			if(flags_item_map_variant & ITEM_DESERT_VARIANT)
				current_variant = "desert"

/obj/item/clothing/head/modular/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return

	if(!istype(I, /obj/item/facepaint) || !length(icon_state_variants))
		return

	var/obj/item/facepaint/paint = I
	if(paint.uses < 1)
		to_chat(user, span_warning("\the [paint] is out of color!"))
		return

	var/variant = tgui_input_list(user, "Choose a color.", "Color", icon_state_variants)

	if(!variant)
		return

	if(!do_after(user, 1 SECONDS, TRUE, src, BUSY_ICON_GENERIC))
		return

	current_variant = variant
	paint.uses--
	update_icon()

/obj/item/clothing/head/modular/apply_custom(mutable_appearance/standing)
	. = ..()
	if(attachments_by_slot[ATTACHMENT_SLOT_STORAGE] && istype(attachments_by_slot[ATTACHMENT_SLOT_STORAGE], /obj/item/armor_module/storage))
		var/obj/item/armor_module/storage/storage_module = attachments_by_slot[ATTACHMENT_SLOT_STORAGE]
		if(storage_module.show_storage)
			for(var/obj/item/stored AS in storage_module.storage.contents)
				standing.overlays += mutable_appearance(storage_module.show_storage_icon, icon_state = initial(stored.icon_state))
	if(attachments_by_slot[ATTACHMENT_SLOT_VISOR])
		return standing
	standing.pixel_x = visorless_offset_x
	standing.pixel_y = visorless_offset_y
	return standing


/obj/item/clothing/head/modular/get_mechanics_info()
	. = ..()
	. += "<br><br />This is a piece of modular armor, It can equip different attachments.<br />"
	. += "<br>It currently has [attachments_by_slot[ATTACHMENT_SLOT_HEAD_MODULE] ? attachments_by_slot[ATTACHMENT_SLOT_HEAD_MODULE] : "nothing"] installed."

/** Colorable masks */
/obj/item/clothing/mask/gas/modular
	name = "style mask"
	desc = "A cool sylish mask that through some arcane magic blocks gas attacks. How? Who knows. How did you even get this?"
	icon = 'icons/obj/clothing/headwear/style_hats.dmi'
	breathy = FALSE
	item_icons = list(
		slot_wear_mask_str = 'icons/mob/modular/style_hats_mob.dmi',
	)
	icon_state = "gas_alt"
	item_state = "gas_alt"

	///List of icon_state suffixes for armor varients.
	var/list/icon_state_variants = list()
	///Current varient selected.
	var/current_variant

/obj/item/clothing/mask/gas/modular/Initialize()
	. = ..()
	update_icon()

/obj/item/clothing/mask/gas/modular/update_icon()
	. = ..()
	if(current_variant)
		icon_state = initial(icon_state) + "_[current_variant]"
		item_state = initial(item_state) + "_[current_variant]"
	update_clothing_icon()

/obj/item/clothing/mask/gas/modular/update_item_sprites()
	switch(SSmapping.configs[GROUND_MAP].armor_style)
		if(MAP_ARMOR_STYLE_JUNGLE)
			if(flags_item_map_variant & ITEM_JUNGLE_VARIANT)
				current_variant = "drab"
		if(MAP_ARMOR_STYLE_ICE)
			if(flags_item_map_variant & ITEM_ICE_VARIANT)
				current_variant = "snow"
		if(MAP_ARMOR_STYLE_PRISON)
			if(flags_item_map_variant & ITEM_PRISON_VARIANT)
				current_variant = "black"
		if(MAP_ARMOR_STYLE_DESERT)
			if(flags_item_map_variant & ITEM_DESERT_VARIANT)
				current_variant = "desert"

/obj/item/clothing/mask/gas/modular/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return

	if(!istype(I, /obj/item/facepaint) || !length(icon_state_variants))
		return

	var/obj/item/facepaint/paint = I
	if(paint.uses < 1)
		to_chat(user, span_warning("\the [paint] is out of color!"))
		return

	var/variant = tgui_input_list(user, "Choose a color.", "Color", icon_state_variants)

	if(!variant)
		return

	if(!do_after(user, 1 SECONDS, TRUE, src, BUSY_ICON_GENERIC))
		return

	current_variant = variant
	paint.uses--
	update_icon()

