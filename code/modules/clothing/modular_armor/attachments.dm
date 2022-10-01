
/obj/item/armor_module
	name = "armor module"
	desc = "A dis-figured armor module, in its prime this would've been a key item in your modular armor... now its just trash."
	icon = 'icons/mob/modular/modular_armor.dmi'
	soft_armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0) // This is here to overwrite code over at objs.dm line 41. Marines don't get funny 200+ bio buff anymore.

	slowdown = 0

	///Reference to parent modular armor suit.
	var/obj/item/clothing/parent

	///Slot the attachment is able to occupy.
	var/slot
	///Icon sheet of the attachment overlays
	var/attach_icon = null
	///Proc typepath that is called when this is attached to something.
	var/on_attach = .proc/on_attach
	///Proc typepath that is called when this is detached from something.
	var/on_detach = .proc/on_detach
	///Proc typepath that is called when this is item is being attached to something. Returns TRUE if it can attach.
	var/can_attach = .proc/can_attach
	///Pixel shift for the item overlay on the X axis.
	var/pixel_shift_x = 0
	///Pixel shift for the item overlay on the Y axis.
	var/pixel_shift_y = 0
	///Bitfield flags of various features.
	var/flags_attach_features = ATTACH_REMOVABLE|ATTACH_APPLY_ON_MOB
	///Time it takes to attach.
	var/attach_delay = 2 SECONDS
	///Time it takes to detach.
	var/detach_delay = 2 SECONDS
	///Used for when the mob attach overlay icon is different than icon.
	var/mob_overlay_icon
	///Pixel shift for the mob overlay on the X axis.
	var/mob_pixel_shift_x = 0
	///Pixel shift for the mob overlay on the Y axis.
	var/mob_pixel_shift_y = 0

	///Light modifier for attachment to an armor piece
	var/light_mod = 0

	///Replacement for initial icon that allows for the code to work with multiple variants
	var/base_icon

	///Assoc list that uses the parents type as a key. type = "new_icon_state". This will change the icon state depending on what type the parent is. If the list is empty, or the parent type is not within, it will have no effect.
	var/list/variants_by_parent_type = list()

	///Layer for the attachment to be applied to.
	var/attachment_layer
	///Slot that is required for the action to appear to the equipper. If null the action will appear whenever the item is equiped to a slot.
	var/prefered_slot = SLOT_WEAR_SUIT

/obj/item/armor_module/Initialize()
	. = ..()
	AddElement(/datum/element/attachment, slot, attach_icon, on_attach, on_detach, null, can_attach, pixel_shift_x, pixel_shift_y, flags_attach_features, attach_delay, detach_delay, mob_overlay_icon = mob_overlay_icon, mob_pixel_shift_x = mob_pixel_shift_x, mob_pixel_shift_y = mob_pixel_shift_y, attachment_layer = attachment_layer)

/// Called before a module is attached.
/obj/item/armor_module/proc/can_attach(obj/item/attaching_to, mob/user)
	return TRUE

/// Called when the module is added to the armor.
/obj/item/armor_module/proc/on_attach(obj/item/attaching_to, mob/user)
	SEND_SIGNAL(attaching_to, COMSIG_ARMOR_MODULE_ATTACHING, user, src)
	parent = attaching_to
	parent.set_light_range(parent.light_range + light_mod)
	parent.hard_armor = parent.hard_armor.attachArmor(hard_armor)
	parent.soft_armor = parent.soft_armor.attachArmor(soft_armor)
	parent.slowdown += slowdown
	if(CHECK_BITFIELD(flags_attach_features, ATTACH_ACTIVATION))
		RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/handle_actions)
	if(length(variants_by_parent_type))
		for(var/selection in variants_by_parent_type)
			if(istype(parent, selection))
				icon_state = variants_by_parent_type[selection]
				base_icon = variants_by_parent_type[selection]

	update_icon()

/// Called when the module is removed from the armor.
/obj/item/armor_module/proc/on_detach(obj/item/detaching_from, mob/user)
	SEND_SIGNAL(detaching_from, COMSIG_ARMOR_MODULE_DETACHED, user, src)
	parent.set_light_range(parent.light_range - light_mod)
	parent.hard_armor = parent.hard_armor.detachArmor(hard_armor)
	parent.soft_armor = parent.soft_armor.detachArmor(soft_armor)
	parent.slowdown -= slowdown
	UnregisterSignal(parent, COMSIG_ITEM_EQUIPPED)
	parent = null
	icon_state = initial(icon_state)
	update_icon()

///Adds or removes actions based on whether the parent is in the correct slot.
/obj/item/armor_module/proc/handle_actions(datum/source, mob/user, slot)
	SIGNAL_HANDLER
	if(prefered_slot && (slot != prefered_slot))
		LAZYREMOVE(actions_types, /datum/action/item_action/toggle)
		var/datum/action/item_action/toggle/old_action = locate(/datum/action/item_action/toggle) in actions
		old_action?.remove_action(user)
		actions = null
		return
	LAZYADD(actions_types, /datum/action/item_action/toggle)
	var/datum/action/item_action/toggle/new_action = new(src)
	new_action.give_action(user)

/obj/item/armor_module/ui_action_click(mob/user, datum/action/item_action/toggle/action)
	action.set_toggle(activate(user))
	action.update_button_icon()

///Called on ui_action_click. Used for activating the module.
/obj/item/armor_module/proc/activate(mob/living/user)
	return

/**
 *  These are the basic type for armor armor_modules. What seperates these from /armor_module is that these are designed to be recolored.
 *  These include Leg plates, Chest plates, Shoulder Plates and Visors. This could be expanded to anything that functions like armor and has greyscale functionality.
 */

/obj/item/armor_module/armor
	name = "modular armor - armor module"
	icon = 'icons/mob/modular/modular_armor.dmi'

	/// The additional armor provided by equipping this piece.
	soft_armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)

	/// Addititve Slowdown of this armor piece
	slowdown = 0

	greyscale_config = /datum/greyscale_config/modularchest
	greyscale_colors = ARMOR_PALETTE_DESERT

	flags_attach_features = ATTACH_REMOVABLE|ATTACH_SAME_ICON|ATTACH_APPLY_ON_MOB

	flags_item_map_variant = ITEM_JUNGLE_VARIANT|ITEM_ICE_VARIANT|ITEM_PRISON_VARIANT
	///If TRUE, this armor piece can be recolored when its parent is right clicked by facepaint.
	var/secondary_color = FALSE

	///optional assoc list of colors we can color this armor
	var/list/colorable_colors = ARMOR_PALETTES_LIST
	///Some defines to determin if the armor piece is allowed to be recolored.
	var/colorable_allowed = COLOR_WHEEL_NOT_ALLOWED

/obj/item/armor_module/armor/Initialize()
	. = ..()
	update_icon()

/obj/item/armor_module/armor/on_attach(obj/item/attaching_to, mob/user)
	. = ..()
	if(!secondary_color)
		return
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY_ALTERNATE, .proc/handle_color)
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/extra_examine)

/obj/item/armor_module/armor/on_detach(obj/item/detaching_from, mob/user)
	UnregisterSignal(parent, list(COMSIG_PARENT_ATTACKBY_ALTERNATE, COMSIG_PARENT_EXAMINE))
	return ..()

/obj/item/armor_module/armor/update_item_sprites()
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

///Will force faction colors on this armor module
/obj/item/armor_module/armor/proc/limit_colorable_colors(faction)
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

/obj/item/armor_module/armor/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return

	if(colorable_allowed == NOT_COLORABLE || (!length(colorable_colors) && colorable_colors == COLOR_WHEEL_NOT_ALLOWED))
		return

	if(!istype(I, /obj/item/facepaint))
		return

	var/obj/item/facepaint/paint = I
	if(paint.uses < 1)
		to_chat(user, span_warning("\the [paint] is out of color!"))
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

	if(!new_color || !do_after(user, 1 SECONDS, TRUE, parent ? parent : src, BUSY_ICON_GENERIC))
		return

	set_greyscale_colors(new_color)
	paint.uses--
	update_icon()
	parent?.update_icon()

///Colors the armor when the parent is right clicked with facepaint.
/obj/item/armor_module/armor/proc/handle_color(datum/source, obj/I, mob/user)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, /atom/proc/attackby, I, user)
	return COMPONENT_NO_AFTERATTACK

///Relays the extra controls to the user when the parent is examined.
/obj/item/armor_module/armor/proc/extra_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += "Right click the [parent] with paint to color the [src]"
