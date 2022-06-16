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
		/obj/item/storage/holster/blade,
		/obj/item/weapon/claymore,
		/obj/item/storage/belt/gun,
		/obj/item/storage/belt/knifepouch,
		/obj/item/weapon/twohanded,
		/obj/item/tool/pickaxe/plasmacutter,
	)
	flags_equip_slot = ITEM_SLOT_OCLOTHING
	w_class = WEIGHT_CLASS_BULKY
	time_to_equip = 2 SECONDS
	time_to_unequip = 1 SECONDS

	soft_armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
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

/obj/item/clothing/suit/modular/on_pocket_insertion()
	. = ..()
	update_icon()

/obj/item/clothing/suit/modular/on_pocket_removal()
	. = ..()
	update_icon()

/obj/item/clothing/suit/modular/apply_custom(image/standing)
	. = ..()
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
	soft_armor = list("melee" = 45, "bullet" = 65, "laser" = 65, "energy" = 55, "bomb" = 50, "bio" = 50, "rad" = 50, "fire" = 50, "acid" = 55)
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
		/obj/item/armor_module/storage/integrated,
		/obj/item/armor_module/armor/badge,
	)

	icon_state_variants = list(
		"drab",
		"black",
		"desert",
		"snow",
	)

	current_variant = "black"

	allowed_uniform_type = /obj/item/clothing/under

<<<<<<< HEAD
/obj/item/clothing/suit/modular/xenonauten/engineer
	starting_attachments = list(/obj/item/armor_module/module/better_shoulder_lamp, /obj/item/armor_module/storage/engineering)

/obj/item/clothing/suit/modular/xenonauten/mimir
	starting_attachments = list(/obj/item/armor_module/module/mimir_environment_protection/mark1)

// Thank Jeff for providing sprites to color flak jacket
=======
>>>>>>> 70b9fa39f125f3de9126155db4d510dc73cb0171
/obj/item/clothing/suit/modular/xenonauten/pilot
	name = "\improper TerraGov standard flak jacket"
	desc = "A flak jacket used by dropship pilots to protect themselves while flying in the cockpit. Excels in protecting the wearer against high-velocity solid projectiles."
	icon_state = "pilot"
	item_state = "pilot"
	item_icons = list(slot_wear_suit_str = 'icons/mob/modular/modular_armor.dmi')
	flags_item = NONE
	soft_armor = list("melee" = 40, "bullet" = 50, "laser" = 50, "energy" = 25, "bomb" = 30, "bio" = 5, "rad" = 5, "fire" = 25, "acid" = 30)
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
	)

/obj/item/clothing/suit/modular/xenonauten/light
	name = "\improper Xenonauten-L pattern armored vest"
	desc = "A XN-L vest, also known as Xenonauten, a set vest with modular attachments made to work in many enviroments. This one seems to be a light variant. Alt-Click to remove attached items. Use it to toggle the built-in flashlight."
	soft_armor = list("melee" = 40, "bullet" = 60, "laser" = 60, "energy" = 50, "bomb" = 50, "bio" = 50, "rad" = 50, "fire" = 50, "acid" = 50)
	icon_state = "light"
	item_state = "light"
	slowdown = 0.3

/obj/item/clothing/suit/modular/xenonauten/light/shield
	starting_attachments = list(/obj/item/armor_module/module/eshield)

/obj/item/clothing/suit/modular/xenonauten/heavy
	name = "\improper Xenonauten-H pattern armored vest"
	desc = "A XN-H vest, also known as Xenonauten, a set vest with modular attachments made to work in many enviroments. This one seems to be a heavy variant. Alt-Click to remove attached items. Use it to toggle the built-in flashlight."
	soft_armor = list("melee" = 50, "bullet" = 70, "laser" = 70, "energy" = 60, "bomb" = 50, "bio" = 50, "rad" = 50, "fire" = 50, "acid" = 60)
	icon_state = "heavy"
	item_state = "heavy"
	slowdown = 0.7

/obj/item/clothing/suit/modular/xenonauten/heavy/leader
	starting_attachments = list(/obj/item/armor_module/module/valkyrie_autodoc, /obj/item/armor_module/storage/general)

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
	var/list/colorable_colors = list(
		"Default" = list(
			"Drab" = ARMOR_PALETTE_DRAB,
			"Brown" = ARMOR_PALETTE_BROWN,
			"Snow" = ARMOR_PALETTE_SNOW,
			"Desert" = ARMOR_PALETTE_DESERT,
			"Black" = ARMOR_PALETTE_BLACK,
			"Grey" = ARMOR_PALETTE_GREY,
			"Gun Metal" = ARMOR_PALETTE_GUN_METAL,
			"Night Slate" = ARMOR_PALETTE_NIGHT_SLATE,
			"Fall" = ARMOR_PALETTE_FALL,
		),
		"Red" = list(
			"Dark Red" = ARMOR_PALETTE_RED,
			"Bronze Red" = ARMOR_PALETTE_BRONZE_RED,
			"Red" = ARMOR_PALETTE_LIGHT_RED,
			"Blood Red" = ARMOR_PALETTE_BLOOD_RED,
		),
		"Green" = list(
			"Green" = ARMOR_PALETTE_GREEN,
			"Emerald" = ARMOR_PALETTE_EMERALD,
			"Lime" = ARMOR_PALETTE_LIME,
			"Mint" = ARMOR_PALETTE_MINT,
			"Jade" = ARMOR_PALETTE_JADE,
			"Leaf" = ARMOR_PALETTE_LEAF,
			"Forest" = ARMOR_PALETTE_FOREST,
			"Smoked Green" = ARMOR_PALETTE_SMOKED_GREEN,
		),
		"Purple" = list(
			"Purple" = ARMOR_PALETTE_PURPLE,
			"Lavander" = ARMOR_PALETTE_LAVANDER,
			"Lilac" = ARMOR_PALETTE_LILAC,
			"Iris Purple" = ARMOR_PALETTE_IRIS_PURPLE,
			"Orchid" = ARMOR_PALETTE_ORCHID,
			"Grape" = ARMOR_PALETTE_GRAPE,
		),
		"Blue" = list(
			"Dark Blue" = ARMOR_PALETTE_BLUE,
			"Blue" = ARMOR_PALETTE_LIGHT_BLUE,
			"Cottonwood" = ARMOR_PALETTE_COTTONWOOD,
			"Aqua" = ARMOR_PALETTE_AQUA,
			"Cerulean" = ARMOR_PALETTE_CERULEAN,
			"Sea Blue" = ARMOR_PALETTE_SEA_BLUE,
			"Cloud" = ARMOR_PALETTE_CLOUD,
		),
		"Yellow" = list(
			"Gold" = ARMOR_PALETTE_YELLOW,
			"Yellow" = ARMOR_PALETTE_LIGHT_YELLOW,
			"Angelic Gold" = ARMOR_PALETTE_ANGELIC,
			"Honey" = ARMOR_PALETTE_HONEY,
		),
		"Orange" = list(
			"Orange" = ARMOR_PALETTE_ORANGE,
			"Beige" = ARMOR_PALETTE_BEIGE,
			"Earth" = ARMOR_PALETTE_EARTH,
		),
		"Pink" = list(
			"Salmon" = ARMOR_PALETTE_SALMON_PINK,
			"Magenta" = ARMOR_PALETTE_MAGENTA_PINK,
			"Sakura" = ARMOR_PALETTE_SAKURA,
		),
	)
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

/obj/item/clothing/head/modular/apply_custom(image/standing)
	. = ..()
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
	greyscale_config = /datum/greyscale_config/modularhelmet
	attachments_allowed = list(
		/obj/item/armor_module/module/tyr_head,
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
		"green",
		"black",
		"brown",
		"white",
	)

	current_variant = "black"

/obj/item/clothing/head/modular/marine/m10x/welding
	starting_attachments = list(/obj/item/armor_module/storage/helmet, /obj/item/armor_module/module/welding)

/obj/item/clothing/head/modular/marine/m10x/mimir
	starting_attachments = list(/obj/item/armor_module/storage/helmet, /obj/item/armor_module/module/mimir_environment_protection/mimir_helmet/mark1)

/obj/item/clothing/head/modular/marine/m10x/heavy
	name = "\improper M10XE pattern marine helmet"
	desc = "A standard M10XE Pattern Helmet. This is a modified version of the M10X helmet, offering an enclosed visor apparatus."
	icon_state = "heavyhelmet_icon"
	item_state = "heavyhelmet"

/obj/item/clothing/head/modular/marine/m10x/leader
	name = "\improper M11X pattern leader helmet"
	desc = "A slightly fancier helmet for marine leaders. This one has cushioning to project your fragile brain."
	soft_armor = list("melee" = 75, "bullet" = 65, "laser" = 55, "energy" = 55, "bomb" = 50, "bio" = 50, "rad" = 50, "fire" = 50, "acid" = 50)

//SOM modular armour

/obj/item/clothing/suit/modular/som
	name = "\improper SOM light battle armor"
	desc = "The M-21 battle armor is typically used by SOM light infantry, or other specialists that require more mobility at the cost of some protection. Provides good protection without minor impairment to the users mobility. Alt-Click to remove attached items. Use it to toggle the built-in flashlight."
	soft_armor = list("melee" = 45, "bullet" = 70, "laser" = 60, "energy" = 60, "bomb" = 55, "bio" = 50, "rad" = 50, "fire" = 50, "acid" = 45)
	icon_state = "som_medium"
	item_state = "som_medium"
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
		/obj/item/armor_module/storage/medical/basic,
		/obj/item/armor_module/storage/injector,
		/obj/item/armor_module/storage/integrated,
		/obj/item/armor_module/armor/badge,
	)

	icon_state_variants = list(
		"black",
	)
	current_variant = "black"

	allowed_uniform_type = /obj/item/clothing/under

/obj/item/clothing/suit/modular/som/light
	name = "\improper SOM scout armor"
	desc = "The M-11 scout armor is a lightweight suit that that allows for minimal encumberance while still providing reasonable protection. Often seen on scouts or other specialist units that aren't normally getting shot at. Alt-Click to remove attached items. Use it to toggle the built-in flashlight."
	soft_armor = list("melee" = 40, "bullet" = 65, "laser" = 55, "energy" = 55, "bomb" = 50, "bio" = 50, "rad" = 50, "fire" = 50, "acid" = 45)
	icon_state = "som_light"
	item_state = "som_light"
	slowdown = 0.3

/obj/item/clothing/suit/modular/som/heavy
	name = "\improper SOM heavy battle armor"
	desc = "A standard suit of M-31 heavy duty combat armor worn by SOM shock troops. Provides excellent protection however it does reduce mobility somewhat. Alt-Click to remove attached items. Use it to toggle the built-in flashlight."
	soft_armor = list("melee" = 50, "bullet" = 75, "laser" = 65, "energy" = 65, "bomb" = 60, "bio" = 50, "rad" = 65, "fire" = 70, "acid" = 50)
	icon_state = "som_heavy"
	item_state = "som_heavy"
	slowdown = 0.7

	siemens_coefficient = 0.4
	permeability_coefficient = 0.5
	gas_transfer_coefficient = 0.5

/obj/item/clothing/suit/modular/som/heavy/leader
	name = "\improper SOM Gorgon pattern assault armor"
	desc = "A bulky suit of heavy combat armor, the M-35 'Gorgon' armour provides the user with superior protection without severely impacting mobility. Typically seen on SOM leaders or their most elite combat units due to the significant construction and maintenance requirements. You'll need serious firepower to punch through this. Alt-Click to remove attached items. Use it to toggle the built-in flashlight."
	soft_armor = list("melee" = 60, "bullet" = 80, "laser" = 70, "energy" = 70, "bomb" = 70, "bio" = 55, "rad" = 70, "fire" = 80, "acid" = 50)
	icon_state = "som_leader"
	item_state = "som_leader"

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
	soft_armor = list("melee" = 45, "bullet" = 70, "laser" = 60, "energy" = 60, "bomb" = 55, "bio" = 50, "rad" = 50, "fire" = 50, "acid" = 45)
	accuracy_mod = 0
	greyscale_config = null
	greyscale_colors = null

	flags_armor_protection = HEAD|FACE|EYES
	attachments_allowed = list(
		/obj/item/armor_module/module/tyr_head,
		/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet,
		/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet/mark1,
		/obj/item/armor_module/module/welding,
		/obj/item/armor_module/module/welding/superior,
		/obj/item/armor_module/module/binoculars,
		/obj/item/armor_module/module/antenna,
		/obj/item/armor_module/storage/helmet,
		/obj/item/armor_module/storage/helmet/som_leader,
		/obj/item/armor_module/storage/helmet/som_vet,
		/obj/item/armor_module/storage/helmet/som,
		/obj/item/armor_module/armor/visor/marine,
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

/obj/item/clothing/head/modular/som/medic
	starting_attachments = list(/obj/item/armor_module/storage/helmet/som_vet)

/obj/item/clothing/head/modular/som/standard
	starting_attachments = list(/obj/item/armor_module/storage/helmet/som)

/obj/item/clothing/head/modular/som/veteran
	name = "\improper SOM veteran helmet"
	desc = "The standard combat helmet worn by SOM combat specialists. State of the art materials provides more protection for more valuable brains."
	icon = 'icons/mob/modular/m10.dmi'
	item_icons = list(
		slot_head_str = 'icons/mob/modular/m10.dmi',
		slot_l_hand_str = 'icons/mob/items_lefthand_1.dmi',
		slot_r_hand_str = 'icons/mob/items_righthand_1.dmi',)
	icon_state = "som_helmet"
	item_state = "som_helmet"
	soft_armor = list("melee" = 50, "bullet" = 75, "laser" = 65, "energy" = 65, "bomb" = 60, "bio" = 50, "rad" = 65, "fire" = 70, "acid" = 50)

/obj/item/clothing/head/modular/som/veteran/leader
	starting_attachments = list(/obj/item/armor_module/storage/helmet/som_leader)

/obj/item/clothing/head/modular/som/veteran/vet
	starting_attachments = list(/obj/item/armor_module/storage/helmet/som_vet)
