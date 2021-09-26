
/obj/item/armor_module
	name = "armor module"
	desc = "A dis-figured armor module, in its prime this would've been a key item in your modular armor... now its just trash."
	icon = 'icons/mob/modular/modular_armor.dmi'

	slowdown = 0

	///Reference to parent modular armor suit.
	var/obj/item/clothing/suit/modular/parent

	///Slot the attachment is able to occupy.
	var/slot
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
	var/flags_attach_features = ATTACH_REMOVABLE
	///Time it takes to attach.
	var/attach_delay = 2 SECONDS
	///Time it takes to detach.
	var/detach_delay = 2 SECONDS

	///Light modifier for attachment to an armor piece
	var/light_mod = 0
	
	///Assoc list that uses the parents type as a key. type = "new_icon_state". This will change the icon state depending on what type the parent is. If the list is empty, or the parent type is not within, it will have no effect.
	var/list/variants_by_parent_type = list()

/obj/item/armor_module/Initialize()
	. = ..()
	AddElement(/datum/element/attachment, slot, icon, on_attach, on_detach, null, can_attach, pixel_shift_x, pixel_shift_y, flags_attach_features, attach_delay, detach_delay)

/// Called before a module is attached.
/obj/item/armor_module/proc/can_attach(obj/item/attaching_to, mob/user)
	if(!istype(attaching_to, /obj/item/clothing/suit/modular) && !istype(attaching_to, /obj/item/clothing/head/modular))
		return FALSE
	return TRUE

/// Called when the module is added to the armor.
/obj/item/armor_module/proc/on_attach(obj/item/attaching_to, mob/user)
	SEND_SIGNAL(attaching_to, COMSIG_ARMOR_MODULE_ATTACHING, user, src)
	parent = attaching_to
	parent.set_light_range(parent.light_range + light_mod)
	parent.hard_armor = parent.hard_armor.attachArmor(hard_armor)
	parent.soft_armor = parent.soft_armor.attachArmor(soft_armor)
	parent.slowdown += slowdown
	if(!length(variants_by_parent_type) || !(parent.type in variants_by_parent_type))
		return
	icon_state = variants_by_parent_type[parent.type]
	update_icon()

/// Called when the module is removed from the armor.
/obj/item/armor_module/proc/on_detach(obj/item/detaching_from, mob/user)
	SEND_SIGNAL(detaching_from, COMSIG_ARMOR_MODULE_DETACHED, user, src)
	parent.set_light_range(parent.light_range - light_mod)
	parent.hard_armor = parent.hard_armor.detachArmor(hard_armor)
	parent.soft_armor = parent.soft_armor.detachArmor(soft_armor)
	parent.slowdown -= slowdown
	parent = null
	icon_state = initial(icon_state)
	update_icon()

/obj/item/armor_module/ui_action_click(mob/user, datum/action/item_action/action)
	activate(user)

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

	greyscale_config = /datum/greyscale_config/modularchest_infantry
	greyscale_colors = "#444732"

	flags_attach_features = ATTACH_REMOVABLE|ATTACH_SAME_ICON

	///optional assoc list of colors we can color this armor
	var/list/colorable_colors

/obj/item/armor_module/armor/Initialize()
	. = ..()
	item_state = initial(icon_state) + "_a"
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

	if(!istype(I, /obj/item/facepaint))
		return

	var/obj/item/facepaint/paint = I
	if(paint.uses < 1)
		to_chat(user, span_warning("\the [paint] is out of color!"))
		return

	var/new_color
	if(colorable_colors)
		new_color = colorable_colors[tgui_input_list(user, "Pick a color", "Pick color", colorable_colors)]
	else
		new_color = input(user, "Pick a color", "Pick color") as null|color

	if(!new_color)
		return

	if(!do_after(user, 1 SECONDS, TRUE, parent ? parent : src, BUSY_ICON_GENERIC))
		return

	set_greyscale_colors(new_color)
	paint.uses--
	update_icon()
	parent?.update_icon()
