/obj/item/armor_module/armor/badge
	name = "7E Chameleon Badge"
	desc = "The 7E Chameloen Badge uses brand new and revolutionary technology to make your gear look even cooler. It is capable of changing into a variety of different shapes (Alt-Click), changing colors (Attack with Green Facepaint), and attaching to nearly all clothing, helmets, berets, and or armor!"
	greyscale_config = /datum/greyscale_config/badge/shield
	icon_state = "in_hand"
	slot = ATTACHMENT_SLOT_BADGE
	flags_attach_features = ATTACH_REMOVABLE|ATTACH_APPLY_ON_MOB|ATTACH_NO_HANDS|ATTACH_SAME_ICON
	colorable_allowed = COLOR_WHEEL_ALLOWED
	greyscale_colors = COLOR_RED
	secondary_color = TRUE
	flags_item_map_variant = NONE

	///List of selectable styles for where the badge is worn.
	var/list/style_list = list(
		"Beret Front",
		"Beret Side",
		"Left Shoulder",
		"Right Shoulder",
		"Left Chest",
		"Right Chest",
		"Left Helmet",
		"Right Helmet",
	)
	///Current selected badge style. This is the icon_state for the greyscale config used for the mob sprite.
	var/current_style = "Left Chest"
	///List of selectable shapes.
	var/list/shape_list = list(
		"Shield" = /datum/greyscale_config/badge/shield,
		"Triangle" = /datum/greyscale_config/badge/triangle,
		"Circle" = /datum/greyscale_config/badge/circle,
		"Square" = /datum/greyscale_config/badge/square,
		"V" = /datum/greyscale_config/badge/V,
		"Lambda" = /datum/greyscale_config/badge/lambda,
		"Alternate Circle" = /datum/greyscale_config/badge/circle2,
	)

/obj/item/armor_module/armor/badge/Initialize(mapload)
	. = ..()
	update_icon()

/obj/item/armor_module/armor/badge/examine(mob/user)
	. = ..()
	. += span_notice("Its current style is set to [current_style]")

/obj/item/armor_module/armor/badge/can_attach(obj/item/attaching_to, mob/user)
	. = ..()
	var/allowed = TRUE
	if((current_style == "Beret Front" || current_style == "Beret Side") && !(istype(attaching_to, /obj/item/clothing/head/tgmcberet) || istype(attaching_to, /obj/item/clothing/head/beret)))
		allowed = FALSE
	if((current_style == "Left Shoulder" || current_style == "Right Shoulder" || current_style == "Left Chest" || current_style == "Right Chest") && !(istype(attaching_to, /obj/item/clothing/suit) || istype(attaching_to, /obj/item/clothing/under)))
		allowed = FALSE
	if((current_style == "Left Helmet" || current_style == "Right Helmet") && !(istype(attaching_to, /obj/item/clothing/head)))
		allowed = FALSE
	if(!allowed)
		to_chat(user, span_warning("The currently selected style, ([current_style]), is not compatable with [attaching_to]."))
	return allowed

/obj/item/armor_module/armor/badge/on_attach(obj/item/attaching_to, mob/user)
	icon_state = current_style
	return ..()

/obj/item/armor_module/armor/badge/on_detach(obj/item/detaching_from, mob/user)
	icon_state = "in_hand"
	return ..()

/obj/item/armor_module/armor/badge/AltClick(mob/user)
	. = ..()
	if(!ishuman(user))
		return
	var/mob/living/living_user = user
	if(!living_user.Adjacent(src) || (living_user.get_active_held_item() != src && living_user.get_inactive_held_item() != src))
		return
	var/new_style = tgui_input_list(living_user, "Pick a style", "Pick style", style_list)
	var/new_shape = tgui_input_list(living_user, "Pick a shape", "Pick shape", shape_list)
	if(!new_style && !new_shape)
		return
	if(!do_after(living_user, 1 SECONDS, NONE, src, BUSY_ICON_GENERIC))
		return
	if(new_style)
		current_style = new_style
	if(new_shape)
		set_greyscale_config(shape_list[new_shape])
	update_icon()



/obj/item/armor_module/armor/stylehat_badge
	name = "Beret Badge"
	icon_state = "beret_badge"
	greyscale_config = /datum/greyscale_config/style_hat/badge
	slot = ATTACHMENT_SLOT_CAPE_HIGHLIGHT
	flags_attach_features = ATTACH_APPLY_ON_MOB|ATTACH_DIFFERENT_MOB_ICON_STATE
	secondary_color = TRUE
	greyscale_colors = COLOR_RED
	flags_item_map_variant = NONE
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/armor_module/armor/stylehat_badge/classic
	name = "Classic Beret Badge"
	icon_state = "classic_beret_badge"

/obj/item/armor_module/armor/stylehat_badge/ushanka
	name = "Ushanka Badge"
	icon_state = "ushanka_badge"

/obj/item/armor_module/armor/visor_glyph
	name = "Visor Glyph"
	icon_state = "skull"
	greyscale_config = /datum/greyscale_config/visors/glyphs
	slot = ATTACHMENT_SLOT_CAPE_HIGHLIGHT
	flags_attach_features = ATTACH_APPLY_ON_MOB|ATTACH_SAME_ICON
	secondary_color = TRUE
	greyscale_colors = COLOR_WHITE
	flags_item_map_variant = NONE
	colorable_allowed = COLOR_WHEEL_ALLOWED

/obj/item/armor_module/armor/visor_glyph/old
	icon_state = "skull_old"
