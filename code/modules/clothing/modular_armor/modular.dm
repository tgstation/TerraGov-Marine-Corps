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
		/obj/item/armor_module/storage/medical/basic,
		/obj/item/armor_module/storage/injector,
		/obj/item/armor_module/storage/grenade,
		/obj/item/armor_module/storage/integrated,
		/obj/item/armor_module/armor/badge,
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
	update_icon() //Update for greyscale.

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

/obj/item/clothing/suit/modular/on_pocket_insertion()
	. = ..()
	update_icon()

/obj/item/clothing/suit/modular/on_pocket_removal()
	. = ..()
	update_icon()

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
	soft_armor = list(MELEE = 45, BULLET = 65, LASER = 65, ENERGY = 55, BOMB = 50, BIO = 50, FIRE = 50, ACID = 55)
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
		/obj/item/armor_module/module/eshield,

		/obj/item/armor_module/storage/general,
		/obj/item/armor_module/storage/ammo_mag,
		/obj/item/armor_module/storage/engineering,
		/obj/item/armor_module/storage/medical,
		/obj/item/armor_module/storage/injector,
		/obj/item/armor_module/storage/grenade,
		/obj/item/armor_module/storage/integrated,
		/obj/item/armor_module/armor/badge,
	)

	flags_item_map_variant = ITEM_JUNGLE_VARIANT|ITEM_ICE_VARIANT|ITEM_DESERT_VARIANT
	icon_state_variants = list(
		"black",
		"jungle",
		"desert",
		"snow",
	)

	current_variant = "black"

	allowed_uniform_type = /obj/item/clothing/under

/obj/item/clothing/suit/modular/xenonauten/engineer
	starting_attachments = list(/obj/item/armor_module/module/better_shoulder_lamp, /obj/item/armor_module/storage/engineering)

/obj/item/clothing/suit/modular/xenonauten/mimir
	starting_attachments = list(/obj/item/armor_module/module/mimir_environment_protection/mark1)

/obj/item/clothing/suit/modular/xenonauten/shield
	starting_attachments = list(/obj/item/armor_module/module/eshield)

/obj/item/clothing/suit/modular/xenonauten/rownin
	name = "\improper Rownin Skeleton"
	desc = "A light armor, if you can even called it that, for dedicated marines that want to travel light and have agility in exchange of protection. Alt-Click to remove attached items. Use it to toggle the built-in flashlight."
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)
	icon_state = "rownin_skeleton"
	item_state = "rownin_skeleton"
	slowdown = 0

	icon_state_variants = list()

	current_variant = ""

/obj/item/clothing/suit/modular/xenonauten/pilot
	name = "\improper TerraGov standard flak jacket"
	desc = "A flak jacket used by dropship pilots to protect themselves while flying in the cockpit. Excels in protecting the wearer against high-velocity solid projectiles."
	icon_state = "pilot"
	item_state = "pilot"
	item_icons = list(slot_wear_suit_str = 'icons/mob/modular/modular_armor.dmi')
	flags_item = NONE
	soft_armor = list(MELEE = 40, BULLET = 50, LASER = 50, ENERGY = 25, BOMB = 30, BIO = 5, FIRE = 25, ACID = 30)
	slowdown = 0.25

	attachments_allowed = list()

	allowed = list(
		/obj/item/weapon/gun,
		/obj/item/tank/emergency_oxygen,
		/obj/item/flashlight,
		/obj/item/ammo_magazine,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/tool/lighter,
		/obj/item/weapon/baton,
		/obj/item/restraints/handcuffs,
		/obj/item/explosive/grenade,
		/obj/item/binoculars,
		/obj/item/weapon/combat_knife,
		/obj/item/attachable/bayonetknife,
		/obj/item/storage/belt/sparepouch,
		/obj/item/storage/holster/blade,
		/obj/item/storage/belt/gun,
		/obj/item/weapon/energy/sword,
	)

/obj/item/clothing/suit/modular/xenonauten/light
	name = "\improper Xenonauten-L pattern armored vest"
	desc = "A XN-L vest, also known as Xenonauten, a set vest with modular attachments made to work in many enviroments. This one seems to be a light variant. Alt-Click to remove attached items. Use it to toggle the built-in flashlight."
	soft_armor = list(MELEE = 40, BULLET = 60, LASER = 60, ENERGY = 50, BOMB = 50, BIO = 50, FIRE = 50, ACID = 50)
	icon_state = "light"
	item_state = "light"
	slowdown = 0.3

/obj/item/clothing/suit/modular/xenonauten/light/shield
	starting_attachments = list(/obj/item/armor_module/module/eshield)

/obj/item/clothing/suit/modular/xenonauten/heavy
	name = "\improper Xenonauten-H pattern armored vest"
	desc = "A XN-H vest, also known as Xenonauten, a set vest with modular attachments made to work in many enviroments. This one seems to be a heavy variant. Alt-Click to remove attached items. Use it to toggle the built-in flashlight."
	soft_armor = list(MELEE = 50, BULLET = 70, LASER = 70, ENERGY = 60, BOMB = 50, BIO = 50, FIRE = 50, ACID = 60)
	icon_state = "heavy"
	item_state = "heavy"
	slowdown = 0.7

/obj/item/clothing/suit/modular/xenonauten/heavy/leader
	starting_attachments = list(/obj/item/armor_module/module/valkyrie_autodoc, /obj/item/armor_module/storage/general)

/obj/item/clothing/suit/modular/xenonauten/heavy/tyr_one
	starting_attachments = list(/obj/item/armor_module/module/tyr_extra_armor/mark1)

/obj/item/clothing/suit/modular/xenonauten/heavy/tyr_two
	starting_attachments = list(/obj/item/armor_module/module/tyr_extra_armor)

/obj/item/clothing/suit/modular/xenonauten/heavy/surt
	starting_attachments = list(/obj/item/armor_module/module/fire_proof, /obj/item/armor_module/storage/general)

/obj/item/clothing/suit/modular/xenonauten/heavy/shield
	starting_attachments = list(/obj/item/armor_module/module/eshield)

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

	soft_armor = list(MELEE = 15, BULLET = 15, LASER = 15, ENERGY = 15, BOMB = 15, BIO = 15, FIRE = 15, ACID = 15)

	greyscale_config = /datum/greyscale_config/modularhelmet
	greyscale_colors = ARMOR_PALETTE_DESERT

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
		/obj/item/armor_module/module/antenna,
		/obj/item/armor_module/storage/helmet,
		/obj/item/armor_module/armor/badge,
	)

	///optional assoc list of colors we can color this armor
	var/list/colorable_colors = ARMOR_PALETTES_LIST
	///Some defines to determin if the armor piece is allowed to be recolored.
	var/colorable_allowed = COLOR_WHEEL_NOT_ALLOWED
	///Pixel offset on the X axis for how the helmet sits on the mob without a visor.
	var/visorless_offset_x = 0
	///Pixel offset on the Y axis for how the helmet sits on the mob without a visor.
	var/visorless_offset_y = -1
	///List of icon_state suffixes for armor varients.
	var/list/icon_state_variants = list()
	///Current varient selected.
	var/current_variant

/obj/item/clothing/head/modular/Initialize()
	. = ..()
	update_icon() //Update for greyscale.

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

	if(colorable_allowed == NOT_COLORABLE || (!length(colorable_colors) && colorable_colors == COLOR_WHEEL_NOT_ALLOWED) && greyscale_config)
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

	var/selection

	switch(colorable_allowed)
		if(COLOR_WHEEL_ONLY)
			selection = "Color Wheel"
		if(COLOR_WHEEL_ALLOWED)
			selection = list("Color Wheel", "Preset Colors")
			selection = tgui_input_list(user, "Choose a color setting", "Choose setting", selection)
		if(COLOR_WHEEL_NOT_ALLOWED)
			selection = "Preset Colors"

	if(!selection)
		return

	var/new_color
	switch(selection)
		if("Preset Colors")
			var/color_selection
			color_selection = tgui_input_list(user, "Pick a color", "Pick color", colorable_colors)
			if(!color_selection)
				return
			if(islist(colorable_colors[color_selection]))
				var/old_list = colorable_colors[color_selection]
				color_selection = tgui_input_list(user, "Pick a color", "Pick color", old_list)
				if(!color_selection)
					return
				new_color = old_list[color_selection]
			else
				new_color = colorable_colors[color_selection]
		if("Color Wheel")
			new_color = input(user, "Pick a color", "Pick color") as null|color

	if(!new_color || !do_after(user, 1 SECONDS, TRUE, src, BUSY_ICON_GENERIC))
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

///When vended, limits the paintable colors based on the vending machine's faction
/obj/item/clothing/head/modular/on_vend(mob/user, faction, fill_container = FALSE, auto_equip = FALSE)
	. = ..()
	if(faction)
		limit_colorable_colors(faction)

/obj/item/clothing/head/modular/m10x
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
	soft_armor = list(MELEE = 50, BULLET = 70, LASER = 70, ENERGY = 60, BOMB = 50, BIO = 50, FIRE = 50, ACID = 60)
	attachments_allowed = list(
		/obj/item/armor_module/module/tyr_head,
		/obj/item/armor_module/module/hod_head,
		/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet,
		/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet/mark1,
		/obj/item/armor_module/module/welding,
		/obj/item/armor_module/module/welding/superior,
		/obj/item/armor_module/module/binoculars,
		/obj/item/armor_module/module/antenna,
		/obj/item/armor_module/storage/helmet,
		/obj/item/armor_module/armor/badge,
	)
	starting_attachments = list(/obj/item/armor_module/storage/helmet)
	visorless_offset_x = 0
	visorless_offset_y = 0
	flags_item_map_variant = ITEM_JUNGLE_VARIANT|ITEM_ICE_VARIANT|ITEM_DESERT_VARIANT

	icon_state_variants = list(
		"black",
		"jungle",
		"desert",
		"snow",
	)

	current_variant = "black"

/obj/item/clothing/head/modular/m10x/welding
	starting_attachments = list(/obj/item/armor_module/storage/helmet, /obj/item/armor_module/module/welding)

/obj/item/clothing/head/modular/m10x/mimir
	starting_attachments = list(/obj/item/armor_module/storage/helmet, /obj/item/armor_module/module/mimir_environment_protection/mimir_helmet/mark1)

/obj/item/clothing/head/modular/m10x/tyr
	starting_attachments = list(/obj/item/armor_module/storage/helmet, /obj/item/armor_module/module/tyr_head)

/obj/item/clothing/head/modular/m10x/heavy
	name = "\improper M10XE pattern marine helmet"
	desc = "A standard M10XE Pattern Helmet. This is a modified version of the M10X helmet, offering an enclosed visor apparatus."
	icon_state = "heavyhelmet_icon"
	item_state = "heavyhelmet"

/obj/item/clothing/head/modular/m10x/leader
	name = "\improper M11X pattern leader helmet"
	desc = "A slightly fancier helmet for marine leaders. This one has cushioning to project your fragile brain."
	soft_armor = list(MELEE = 75, BULLET = 75, LASER = 75, ENERGY = 65, BOMB = 55, BIO = 50, FIRE = 50, ACID = 60)

/obj/item/clothing/head/modular/marine
	name = "Jaeger Pattern Infantry Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points. Has Infantry markings."
	icon_state = "infantry_helmet"
	soft_armor = list(MELEE = 50, BULLET = 70, LASER = 70, ENERGY = 60, BOMB = 50, BIO = 50, FIRE = 50, ACID = 60)
	accuracy_mod = 0
	greyscale_config = /datum/greyscale_config/modularhelmet
	attachments_allowed = list(
		/obj/item/armor_module/module/tyr_head,
		/obj/item/armor_module/module/hod_head,
		/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet,
		/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet/mark1,
		/obj/item/armor_module/module/welding,
		/obj/item/armor_module/module/welding/superior,
		/obj/item/armor_module/module/binoculars,
		/obj/item/armor_module/module/antenna,
		/obj/item/armor_module/storage/helmet,
		/obj/item/armor_module/armor/visor/marine,
		/obj/item/armor_module/armor/badge,
	)

	starting_attachments = list(/obj/item/armor_module/armor/visor/marine, /obj/item/armor_module/storage/helmet)
	flags_item_map_variant = ITEM_JUNGLE_VARIANT|ITEM_ICE_VARIANT|ITEM_PRISON_VARIANT

/obj/item/clothing/head/modular/marine/update_item_sprites()
	var/new_color
	switch(SSmapping.configs[GROUND_MAP].armor_style)
		if(MAP_ARMOR_STYLE_JUNGLE)
			if(flags_item_map_variant & ITEM_JUNGLE_VARIANT)
				new_color = ARMOR_PALETTE_DRAB
		if(MAP_ARMOR_STYLE_ICE)
			if(flags_item_map_variant & ITEM_ICE_VARIANT)
				new_color = ARMOR_PALETTE_SNOW
		if(MAP_ARMOR_STYLE_PRISON)
			if(flags_item_map_variant & ITEM_PRISON_VARIANT)
				new_color = ARMOR_PALETTE_BLACK
	set_greyscale_colors(new_color)
	update_icon()

/obj/item/clothing/head/modular/marine/skirmisher
	name = "Jaeger Pattern Skirmisher Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points. Has Skirmisher markings."
	icon_state = "skirmisher_helmet"
	greyscale_config = /datum/greyscale_config/modularhelmet/skirmisher
	attachments_allowed = list(
		/obj/item/armor_module/module/tyr_head,
		/obj/item/armor_module/module/hod_head,
		/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet,
		/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet/mark1,
		/obj/item/armor_module/module/welding,
		/obj/item/armor_module/module/welding/superior,
		/obj/item/armor_module/module/binoculars,
		/obj/item/armor_module/module/antenna,
		/obj/item/armor_module/storage/helmet,
		/obj/item/armor_module/armor/visor/marine/skirmisher,
		/obj/item/armor_module/armor/badge,
	)

	starting_attachments = list(/obj/item/armor_module/armor/visor/marine/skirmisher, /obj/item/armor_module/storage/helmet)

/obj/item/clothing/head/modular/marine/assault
	name = "Jaeger Pattern Assault Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points. Has Assault markings."
	icon_state = "assault_helmet"
	greyscale_config = /datum/greyscale_config/modularhelmet/assault
	attachments_allowed = list(
		/obj/item/armor_module/module/tyr_head,
		/obj/item/armor_module/module/hod_head,
		/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet,
		/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet/mark1,
		/obj/item/armor_module/module/welding,
		/obj/item/armor_module/module/welding/superior,
		/obj/item/armor_module/module/binoculars,
		/obj/item/armor_module/module/antenna,
		/obj/item/armor_module/storage/helmet,
		/obj/item/armor_module/armor/visor/marine/assault,
		/obj/item/armor_module/armor/badge,
	)

	starting_attachments = list(/obj/item/armor_module/armor/visor/marine/assault, /obj/item/armor_module/storage/helmet)

/obj/item/clothing/head/modular/marine/eva
	name = "Jaeger Pattern EVA Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points. Has EVA markings."
	icon_state = "eva_helmet"
	greyscale_config = /datum/greyscale_config/modularhelmet/eva
	attachments_allowed = list(
		/obj/item/armor_module/module/tyr_head,
		/obj/item/armor_module/module/hod_head,
		/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet,
		/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet/mark1,
		/obj/item/armor_module/module/welding,
		/obj/item/armor_module/module/welding/superior,
		/obj/item/armor_module/module/binoculars,
		/obj/item/armor_module/module/antenna,
		/obj/item/armor_module/storage/helmet,
		/obj/item/armor_module/armor/visor/marine/eva,
		/obj/item/armor_module/armor/visor/marine/eva/skull,
		/obj/item/armor_module/armor/badge,
	)

	starting_attachments = list(/obj/item/armor_module/armor/visor/marine/eva, /obj/item/armor_module/storage/helmet)

/obj/item/clothing/head/modular/marine/eva/skull
	name = "Jaeger Pattern EVA 'Skull' Helmet"
	starting_attachments = list(/obj/item/armor_module/armor/visor/marine/eva/skull, /obj/item/armor_module/storage/helmet)

/obj/item/clothing/head/modular/marine/eod
	name = "Jaeger Pattern EOD Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points. Has EOD markings"
	icon_state = "eod_helmet"
	greyscale_config = /datum/greyscale_config/modularhelmet/eod
	attachments_allowed = list(
		/obj/item/armor_module/module/tyr_head,
		/obj/item/armor_module/module/hod_head,
		/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet,
		/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet/mark1,
		/obj/item/armor_module/module/welding,
		/obj/item/armor_module/module/welding/superior,
		/obj/item/armor_module/module/binoculars,
		/obj/item/armor_module/module/antenna,

		/obj/item/armor_module/storage/helmet,

		/obj/item/armor_module/armor/visor/marine/eod,

		/obj/item/armor_module/armor/badge,
	)

	starting_attachments = list(/obj/item/armor_module/armor/visor/marine/eod, /obj/item/armor_module/storage/helmet)

/obj/item/clothing/head/modular/marine/scout
	name = "Jaeger Pattern Scout Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points. Has Scout markings"
	icon_state = "scout_helmet"
	greyscale_config = /datum/greyscale_config/modularhelmet/scout
	attachments_allowed = list(
		/obj/item/armor_module/module/tyr_head,
		/obj/item/armor_module/module/hod_head,
		/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet,
		/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet/mark1,
		/obj/item/armor_module/module/welding,
		/obj/item/armor_module/module/welding/superior,
		/obj/item/armor_module/module/binoculars,
		/obj/item/armor_module/module/antenna,
		/obj/item/armor_module/storage/helmet,
		/obj/item/armor_module/armor/visor/marine/scout,
		/obj/item/armor_module/armor/badge,
	)

	starting_attachments = list(/obj/item/armor_module/armor/visor/marine/scout, /obj/item/armor_module/storage/helmet)

/obj/item/clothing/head/modular/marine/helljumper
	name = "Jaeger Pattern Helljumper Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points. Has Helljumper markings"
	icon_state = "helljumper_helmet"
	greyscale_config = /datum/greyscale_config/modularhelmet/helljumper
	attachments_allowed = list(
		/obj/item/armor_module/module/tyr_head,
		/obj/item/armor_module/module/hod_head,
		/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet,
		/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet/mark1,
		/obj/item/armor_module/module/welding,
		/obj/item/armor_module/module/welding/superior,
		/obj/item/armor_module/module/binoculars,
		/obj/item/armor_module/module/antenna,
		/obj/item/armor_module/storage/helmet,
		/obj/item/armor_module/armor/visor/marine/helljumper,
		/obj/item/armor_module/armor/badge,
	)
	starting_attachments = list(/obj/item/armor_module/armor/visor/marine/helljumper, /obj/item/armor_module/storage/helmet)

/obj/item/clothing/head/modular/marine/infantry
	name = "Jaeger Pattern Infantry-Open Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points. Has Infantry markings and no visor."
	icon_state = "infantryopen_helmet"
	greyscale_config = /datum/greyscale_config/modularhelmet/infantry_open
	attachments_allowed = list(
		/obj/item/armor_module/module/tyr_head,
		/obj/item/armor_module/module/hod_head,
		/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet,
		/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet/mark1,
		/obj/item/armor_module/module/welding,
		/obj/item/armor_module/module/welding/superior,
		/obj/item/armor_module/module/binoculars,
		/obj/item/armor_module/module/antenna,
		/obj/item/armor_module/storage/helmet,
		/obj/item/armor_module/armor/badge,
	)
	starting_attachments = list(/obj/item/armor_module/storage/helmet)

	visorless_offset_x = 0
	visorless_offset_y = 0

// ***************************************
// *********** Modular Style Line
// ***************************************
/obj/item/clothing/suit/modular/style
	name = "\improper Drip"
	desc = "They got that drip, doe."
	flags_item_map_variant = NONE
	allowed_uniform_type = /obj/item/clothing/under
	icon = 'icons/obj/clothing/cm_suits.dmi'
	attachments_allowed = list(
// Armor Modules
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
// Storage Modules
		/obj/item/armor_module/storage/general,
		/obj/item/armor_module/storage/ammo_mag,
		/obj/item/armor_module/storage/engineering,
		/obj/item/armor_module/storage/medical,
		/obj/item/armor_module/storage/medical/basic,
		/obj/item/armor_module/storage/injector,
		/obj/item/armor_module/storage/grenade,
		/obj/item/armor_module/storage/integrated,
		/obj/item/armor_module/armor/badge,
// Equalizer Modules
		/obj/item/armor_module/module/style/light_armor,
		/obj/item/armor_module/module/style/medium_armor,
		/obj/item/armor_module/module/style/heavy_armor,
	)

	var/codex_info = {"<BR>This item is part of the <b>Style Line.</b><BR>
	<BR>The <b>Style Line</b> is a line of equipment designed to provide as much style as possible without compromising the user's protection.
	This line of equipment accepts <b>Equalizer modules</b>, which allow the user to alter any given piece of equipment's protection according to their preferences.<BR>"}

/obj/item/clothing/suit/modular/style/get_mechanics_info()
	. = ..()
	. += jointext(codex_info, "<br>")

/obj/item/clothing/suit/modular/style/leather_jacket
	name = "\improper leather jacket"
	desc = "A fashionable jacket. Get them with style."
	icon = 'icons/obj/clothing/cm_suits.dmi'
	icon_state = "leather_jacket"
	item_state = "leather_jacket"
	item_icons = list(
		slot_wear_suit_str = 'icons/mob/suit_1.dmi',
		slot_l_hand_str = 'icons/mob/items_lefthand_1.dmi',
		slot_r_hand_str = 'icons/mob/items_righthand_1.dmi',
	)
	icon_state_variants = list(
		"normal",
		"webbing",
	)
	current_variant = "normal"

/obj/item/clothing/suit/modular/style/duster
	name = "\improper duster"
	desc = "A light, loose-fitting colorable long coat, for those that want to have more style."
	icon_state = "duster"
	item_state = "duster"
	item_icons = list(
		slot_wear_suit_str = 'icons/mob/suit_1.dmi',
	)
	icon_state_variants = list(
		"drab",
		"snow",
		"black",
		"desert",
		"red",
		"blue",
		"purple",
		"gold",
	)
	current_variant = "black"

//SOM modular armour

/obj/item/clothing/suit/modular/som
	name = "\improper SOM light battle armor"
	desc = "The M-21 battle armor is typically used by SOM light infantry, or other specialists that require more mobility at the cost of some protection. Provides good protection without minor impairment to the users mobility. Alt-Click to remove attached items. Use it to toggle the built-in flashlight."
	soft_armor = list(MELEE = 45, BULLET = 70, LASER = 60, ENERGY = 60, BOMB = 50, BIO = 50, FIRE = 50, ACID = 50)
	icon_state = "som_medium"
	item_state = "som_medium"
	slowdown = 0.5

	attachments_allowed = list(
		/obj/item/armor_module/module/better_shoulder_lamp,
		/obj/item/armor_module/module/valkyrie_autodoc,
		/obj/item/armor_module/module/fire_proof/som,
		/obj/item/armor_module/module/tyr_extra_armor/som,
		/obj/item/armor_module/module/mimir_environment_protection/som,
		/obj/item/armor_module/module/hlin_explosive_armor,
		/obj/item/armor_module/module/eshield/som,
		/obj/item/armor_module/storage/general,
		/obj/item/armor_module/storage/ammo_mag,
		/obj/item/armor_module/storage/engineering,
		/obj/item/armor_module/storage/medical,
		/obj/item/armor_module/storage/medical/basic,
		/obj/item/armor_module/storage/injector,
		/obj/item/armor_module/storage/grenade,
		/obj/item/armor_module/storage/integrated,
		/obj/item/armor_module/armor/badge,
	)

	icon_state_variants = list(
		"black",
	)
	current_variant = "black"

	allowed_uniform_type = /obj/item/clothing/under

/obj/item/clothing/suit/modular/som/engineer
	starting_attachments = list(/obj/item/armor_module/storage/engineering)

/obj/item/clothing/suit/modular/som/shield
	starting_attachments = list(/obj/item/armor_module/module/eshield/som)

/obj/item/clothing/suit/modular/som/light
	name = "\improper SOM scout armor"
	desc = "The M-11 scout armor is a lightweight suit that that allows for minimal encumberance while still providing reasonable protection. Often seen on scouts or other specialist units that aren't normally getting shot at. Alt-Click to remove attached items. Use it to toggle the built-in flashlight."
	soft_armor = list(MELEE = 40, BULLET = 65, LASER = 55, ENERGY = 55, BOMB = 45, BIO = 50, FIRE = 50, ACID = 45)
	icon_state = "som_light"
	item_state = "som_light"
	slowdown = 0.3

/obj/item/clothing/suit/modular/som/light/shield
	starting_attachments = list(/obj/item/armor_module/module/eshield/som)


/obj/item/clothing/suit/modular/som/heavy
	name = "\improper SOM heavy battle armor"
	desc = "A standard suit of M-31 heavy duty combat armor worn by SOM shock troops. Provides excellent protection however it does reduce mobility somewhat. Alt-Click to remove attached items. Use it to toggle the built-in flashlight."
	soft_armor = list(MELEE = 50, BULLET = 75, LASER = 65, ENERGY = 65, BOMB = 50, BIO = 50, FIRE = 60, ACID = 55)
	icon_state = "som_heavy"
	item_state = "som_heavy"
	slowdown = 0.7

/obj/item/clothing/suit/modular/som/heavy/pyro
	starting_attachments = list(
		/obj/item/armor_module/module/fire_proof/som,
		/obj/item/armor_module/storage/general,
	)

/obj/item/clothing/suit/modular/som/heavy/lorica
	starting_attachments = list(/obj/item/armor_module/module/tyr_extra_armor/som)

/obj/item/clothing/suit/modular/som/heavy/mithridatius
	starting_attachments = list(/obj/item/armor_module/module/mimir_environment_protection/som)

/obj/item/clothing/suit/modular/som/heavy/shield
	starting_attachments = list(/obj/item/armor_module/module/eshield/som)

/obj/item/clothing/suit/modular/som/heavy/leader
	name = "\improper SOM Gorgon pattern assault armor"
	desc = "A bulky suit of heavy combat armor, the M-35 'Gorgon' armor provides the user with superior protection without severely impacting mobility. Typically seen on SOM leaders or their most elite combat units due to the significant construction and maintenance requirements. You'll need serious firepower to punch through this. Alt-Click to remove attached items. Use it to toggle the built-in flashlight."
	soft_armor = list(MELEE = 60, BULLET = 80, LASER = 70, ENERGY = 70, BOMB = 60, BIO = 55, FIRE = 65, ACID = 55)
	icon_state = "som_leader"
	item_state = "som_leader"

	siemens_coefficient = 0.4
	permeability_coefficient = 0.5
	gas_transfer_coefficient = 0.5
	attachments_allowed = list(
		/obj/item/armor_module/module/better_shoulder_lamp,
		/obj/item/armor_module/module/valkyrie_autodoc,
		/obj/item/armor_module/module/fire_proof/som,
		/obj/item/armor_module/module/mimir_environment_protection/som,
		/obj/item/armor_module/module/hlin_explosive_armor,
		/obj/item/armor_module/module/eshield/som,
		/obj/item/armor_module/storage/general,
		/obj/item/armor_module/storage/ammo_mag,
		/obj/item/armor_module/storage/engineering,
		/obj/item/armor_module/storage/medical,
		/obj/item/armor_module/storage/medical/basic,
		/obj/item/armor_module/storage/injector,
		/obj/item/armor_module/storage/grenade,
		/obj/item/armor_module/storage/integrated,
		/obj/item/armor_module/armor/badge,
	)

/obj/item/clothing/suit/modular/som/heavy/leader/valk
	starting_attachments = list(
		/obj/item/armor_module/module/valkyrie_autodoc,
		/obj/item/armor_module/storage/medical/basic,
	)

//helmet

/obj/item/clothing/head/modular/som
	name = "\improper SOM infantry helmet"
	desc = "The standard combat helmet worn by SOM combat troops. Made using advanced polymers to provide very effective protection without compromising visibility."
	icon = 'icons/mob/modular/m10.dmi'
	item_icons = list(
		slot_head_str = 'icons/mob/modular/m10.dmi',
		slot_l_hand_str = 'icons/mob/items_lefthand_1.dmi',
		slot_r_hand_str = 'icons/mob/items_righthand_1.dmi',)
	icon_state = "som_helmet"
	item_state = "som_helmet"
	soft_armor = list(MELEE = 45, BULLET = 70, LASER = 60, ENERGY = 60, BOMB = 50, BIO = 50, FIRE = 50, ACID = 50)
	greyscale_config = null
	greyscale_colors = null
	flags_inv_hide = HIDEEARS|HIDEALLHAIR
	flags_armor_protection = HEAD|FACE|EYES
	attachments_allowed = list(
		/obj/item/armor_module/module/tyr_head/som,
		/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet/som,
		/obj/item/armor_module/module/welding,
		/obj/item/armor_module/module/welding/superior,
		/obj/item/armor_module/module/binoculars,
		/obj/item/armor_module/module/antenna,
		/obj/item/armor_module/storage/helmet,
		/obj/item/armor_module/armor/badge,
	)

	starting_attachments = list(/obj/item/armor_module/storage/helmet)

	visorless_offset_x = 0
	visorless_offset_y = 0
	icon_state_variants = list(
		"black",
	)
	current_variant = "black"
	colorable_colors = list()

/obj/item/clothing/head/modular/som/welder
	starting_attachments = list(/obj/item/armor_module/storage/helmet, /obj/item/armor_module/module/welding)

/obj/item/clothing/head/modular/som/mithridatius
	starting_attachments = list(/obj/item/armor_module/storage/helmet, /obj/item/armor_module/module/mimir_environment_protection/mimir_helmet/som)

/obj/item/clothing/head/modular/som/veteran
	name = "\improper SOM veteran helmet"
	desc = "The standard combat helmet worn by SOM combat specialists. State of the art materials provides more protection for more valuable brains."
	soft_armor = list(MELEE = 50, BULLET = 75, LASER = 65, ENERGY = 65, BOMB = 50, BIO = 50, FIRE = 60, ACID = 55)

/obj/item/clothing/head/modular/som/veteran/lorica
	starting_attachments = list(/obj/item/armor_module/storage/helmet, /obj/item/armor_module/module/tyr_head/som)

/obj/item/clothing/head/modular/som/leader
	name = "\improper SOM Gorgon pattern helmet"
	desc = "Made for use with Gorgon pattern assault armor, providing superior protection. Typically seen on SOM leaders or their most elite combat units."
	icon_state = "som_helmet_leader"
	item_state = "som_helmet_leader"
	soft_armor = list(MELEE = 60, BULLET = 80, LASER = 70, ENERGY = 70, BOMB = 60, BIO = 55, FIRE = 65, ACID = 55)
	attachments_allowed = list(
		/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet/som,
		/obj/item/armor_module/module/welding,
		/obj/item/armor_module/module/welding/superior,
		/obj/item/armor_module/module/binoculars,
		/obj/item/armor_module/module/antenna,
		/obj/item/armor_module/storage/helmet,
		/obj/item/armor_module/armor/badge,
	)
