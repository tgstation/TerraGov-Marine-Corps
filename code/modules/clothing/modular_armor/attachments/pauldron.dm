/obj/item/armor_module/greyscale/pauldron
	name = "7E Chameleon Pauldron"
	desc = "The 7E Chameloen Pauldron uses brand new and revolutionary technology to make your shoulders look COOLER. It is capable of changing into a variety of different shapes (Alt-Click) and changing colors (Attack with Green Facepaint) to give you that extra edge in style!"
	greyscale_config = /datum/greyscale_config/pauldron/right
	icon_state = "in_hand"
	slot = ATTACHMENT_SLOT_PAULDRON
	flags_attach_features = ATTACH_REMOVABLE|ATTACH_APPLY_ON_MOB|ATTACH_NO_HANDS|ATTACH_SAME_ICON

	///Current selected pauldron shape. This is the icon_state for the greyscale config used for the mob sprite.
	var/current_shape = "Standard Right Pauldron"
	///List of selectable shapes.
	var/list/shape_list = list(
		"Low Profile Right Pauldron" = /datum/greyscale_config/pauldron/right/low,
		"Extended Right Pauldron" = /datum/greyscale_config/pauldron/right/extended,
		"Epaulette Right Pauldron" = /datum/greyscale_config/pauldron/right/epaulette,
		"Athletic Right Pauldron" = /datum/greyscale_config/pauldron/right/athletic,
		"Federation Right Pauldron" = /datum/greyscale_config/pauldron/right/federation,
		"Zeon Right Pauldron" = /datum/greyscale_config/pauldron/right/zeon,
		"Standard Left Pauldron" = /datum/greyscale_config/pauldron/left,
		"Low Profile Left Pauldron" = /datum/greyscale_config/pauldron/left/low,
		"Extended Left Pauldron" = /datum/greyscale_config/pauldron/left/extended,
		"Epaulette Left Pauldron" = /datum/greyscale_config/pauldron/left/epaulette,
		"Athletic Left Pauldron" = /datum/greyscale_config/pauldron/left/athletic,
		"Federation Left Pauldron" = /datum/greyscale_config/pauldron/left/federation,
		"Zeon Left Pauldron" = /datum/greyscale_config/pauldron/left/zeon,
	)

/obj/item/armor_module/greyscale/pauldron/Initialize(mapload)
	. = ..()
	update_icon()

/obj/item/armor_module/greyscale/pauldron/examine(mob/user)
	. = ..()
	. += span_notice("Its current shape is set to [current_shape]")

/obj/item/armor_module/greyscale/pauldron/can_attach(obj/item/attaching_to, mob/user)
	. = ..()
	var/allowed = TRUE
	if((current_shape == "Left Shoulder" || current_shape == "Right Shoulder") && !(istype(attaching_to, /obj/item/clothing/under)))
		allowed = FALSE
	if(!allowed)
		to_chat(user, span_warning("The currently selected shape, ([current_shape]), is not compatable with [attaching_to]."))
	return allowed

/obj/item/armor_module/greyscale/pauldron/on_attach(obj/item/attaching_to, mob/user)
	icon_state = current_shape
	return ..()

/obj/item/armor_module/greyscale/pauldron/on_detach(obj/item/detaching_from, mob/user)
	icon_state = "in_hand"
	return ..()

/obj/item/armor_module/greyscale/pauldron/AltClick(mob/user)
	. = ..()
	if(!ishuman(user))
		return
	var/mob/living/living_user = user
	if(!living_user.Adjacent(src) || (living_user.get_active_held_item() != src && living_user.get_inactive_held_item() != src))
		return
	var/new_shape = tgui_input_list(living_user, "Pick a shape", "Pick shape", shape_list)
	if(!new_shape && !new_shape)
		return
	if(!do_after(living_user, 1 SECONDS, TRUE, src, BUSY_ICON_GENERIC))
		return
	if(new_shape)
		current_shape = new_shape
	if(new_shape)
		set_greyscale_config(shape_list[new_shape])
	update_icon()
