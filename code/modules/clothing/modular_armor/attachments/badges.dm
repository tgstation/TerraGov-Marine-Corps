/obj/item/armor_module/armor/badge
	name = "E7 Chameleon Badge"
	desc = "The E7 Chameloen Badge uses brand new and revolutionary technology to make your gear look even cooler. It is capable of changing into a variety of different shapes (Alt-Click), changing colors (Attack with Green Facepaint), and attaching to nearly all clothing, helmets, berets, and or armor!"
	greyscale_config = /datum/greyscale_config/badge/lchest
	greyscale_colors = "#afafad"
	slot = ATTACHMENT_SLOT_BADGE
	flags_attach_features = ATTACH_REMOVABLE|ATTACH_SAME_ICON|ATTACH_APPLY_ON_MOB|ATTACH_NO_HANDS
	///List of selectable greyscale configs for wearing the badge at different levels and on different objects.
	var/list/style_list = list(
		"Shield (Left Chest)" = /datum/greyscale_config/badge/lchest,
		"Shield (Right Chest)" = /datum/greyscale_config/badge/rchest,
		"Shield (Left Arm)" = /datum/greyscale_config/badge/larm,
		"Shield (Right Arm)" = /datum/greyscale_config/badge/rarm,
		"Shield (Beret Forward)" = /datum/greyscale_config/badge/beretf,
		"Shield (Beret Side)" = /datum/greyscale_config/badge/berets,
		"Shield (Left Helm)" = /datum/greyscale_config/badge/lhelm,
		"Shield (Right Helm)" = /datum/greyscale_config/badge/rhelm,

		"Triangle (Left Chest)" = /datum/greyscale_config/badge/lchest/triangle,
		"Triangle (Right Chest)" = /datum/greyscale_config/badge/rchest/triangle,
		"Triangle (Left Arm)" = /datum/greyscale_config/badge/larm/triangle,
		"Triangle (Right Arm)" = /datum/greyscale_config/badge/rarm/triangle,
		"Triangle (Beret Forward)" = /datum/greyscale_config/badge/beretf/triangle,
		"Triangle (Beret Side)" = /datum/greyscale_config/badge/berets/triangle,
		"Triangle (Left Helm)" = /datum/greyscale_config/badge/lhelm/triangle,
		"Triangle (Right Helm)" = /datum/greyscale_config/badge/rhelm/triangle,

		"Circle (Left Chest)" = /datum/greyscale_config/badge/lchest/circle,
		"Circle (Right Chest)" = /datum/greyscale_config/badge/rchest/circle,
		"Circle (Left Arm)" = /datum/greyscale_config/badge/larm/circle,
		"Circle (Right Arm)" = /datum/greyscale_config/badge/rarm/circle,
		"Circle (Beret Forward)" = /datum/greyscale_config/badge/beretf/circle,
		"Circle (Beret Side)" = /datum/greyscale_config/badge/berets/circle,
		"Circle (Left Helm)" = /datum/greyscale_config/badge/lhelm/circle,
		"Circle (Right Helm)" = /datum/greyscale_config/badge/rhelm/circle,

		"Square (Left Chest)" = /datum/greyscale_config/badge/lchest/square,
		"Square (Right Chest)" = /datum/greyscale_config/badge/rchest/square,
		"Square (Left Arm)" = /datum/greyscale_config/badge/larm/square,
		"Square (Right Arm)" = /datum/greyscale_config/badge/rarm/square,
		"Square (Beret Forward)" = /datum/greyscale_config/badge/beretf/square,
		"Square (Beret Side)" = /datum/greyscale_config/badge/berets/square,
		"Square (Left Helm)" = /datum/greyscale_config/badge/lhelm/square,
		"Square (Right Helm)" = /datum/greyscale_config/badge/rhelm/square,

		"V (Left Chest)" = /datum/greyscale_config/badge/lchest/V,
		"V (Right Chest)" = /datum/greyscale_config/badge/rchest/V,
		"V (Left Arm)" = /datum/greyscale_config/badge/larm/V,
		"V (Right Arm)" = /datum/greyscale_config/badge/rarm/V,
		"V (Beret Forward)" = /datum/greyscale_config/badge/beretf/V,
		"V (Beret Side)" = /datum/greyscale_config/badge/berets/V,
		"V (Left Helm)" = /datum/greyscale_config/badge/lhelm/V,
		"V (Right Helm)" = /datum/greyscale_config/badge/rhelm/V,

		"Lambda (Left Chest)" = /datum/greyscale_config/badge/lchest/lambda,
		"Lambda (Right Chest)" = /datum/greyscale_config/badge/rchest/lambda,
		"Lambda (Left Arm)" = /datum/greyscale_config/badge/larm/lambda,
		"Lambda (Right Arm)" = /datum/greyscale_config/badge/rarm/lambda,
		"Lambda (Beret Forward)" = /datum/greyscale_config/badge/beretf/lambda,
		"Lambda (Beret Side)" = /datum/greyscale_config/badge/berets/lambda,
		"Lambda (Left Helm)" = /datum/greyscale_config/badge/lhelm/lambda,
		"Lambda (Right Helm)" = /datum/greyscale_config/badge/rhelm/lambda,

		"Circle Two (Left Chest)" = /datum/greyscale_config/badge/lchest/circle2,
		"Circle Two (Right Chest)" = /datum/greyscale_config/badge/rchest/circle2,
		"Circle Two (Left Arm)" = /datum/greyscale_config/badge/larm/circle2,
		"Circle Two (Right Arm)" = /datum/greyscale_config/badge/rarm/circle2,
		"Circle Two (Beret Forward)" = /datum/greyscale_config/badge/beretf/circle2,
		"Circle Two (Beret Side)" = /datum/greyscale_config/badge/berets/circle2,
		"Circle Two (Left Helm)" = /datum/greyscale_config/badge/lhelm/circle2,
		"Circle Two (Right Helm)" = /datum/greyscale_config/badge/rhelm/circle2,
	)

/obj/item/armor_module/armor/badge/Initialize()
	. = ..()
	style_list = string_list(style_list)
	item_state = initial(icon_state)
	update_icon()

/obj/item/armor_module/armor/badge/limit_colorable_colors(faction)
	return

/obj/item/armor_module/armor/can_attach(obj/item/attaching_to, mob/user)
	. = ..()
	var/allowed = TRUE
	if((istype(attaching_to, /obj/item/clothing/under) || istype(attaching_to, /obj/item/clothing/suit)) && (!ispath(greyscale_config, /datum/greyscale_config/badge/lchest) && !ispath(greyscale_config, /datum/greyscale_config/badge/rchest) && !ispath(greyscale_config, /datum/greyscale_config/badge/larm) && !ispath(greyscale_config, /datum/greyscale_config/badge/rarm)))
		allowed = FALSE
	if((istype(attaching_to, /obj/item/clothing/head/beret) || istype(attaching_to, /obj/item/clothing/head/tgmcberet)) && (!ispath(greyscale_config, /datum/greyscale_config/badge/beretf) && !ispath(greyscale_config, /datum/greyscale_config/badge/berets)))
		allowed = FALSE
	if((istype(attaching_to, /obj/item/clothing/head) && !istype(attaching_to, /obj/item/clothing/head/beret && !istype(attaching_to, /obj/item/clothing/head/tgmcberet))) && (!ispath(greyscale_config, /datum/greyscale_config/badge/lhelm) && !ispath(greyscale_config, /datum/greyscale_config/badge/rhelm)))
		allowed = FALSE
	if(!allowed)
		to_chat(user, span_notice("The currently selected style is not compatable with [attaching_to]."))
		return allowed
	return allowed


/obj/item/armor_module/armor/badge/AltClick(mob/user)
	. = ..()
	if(!ishuman(user))
		return
	var/mob/living/living_user = user
	if(!living_user.Adjacent(src) || (living_user.get_active_held_item() != src && living_user.get_inactive_held_item() != src))
		return
	var/new_style = tgui_input_list(living_user, "Pick a style", "Pick style", style_list)
	if(!new_style)
		return
	if(!do_after(living_user, 1 SECONDS, TRUE, src, BUSY_ICON_GENERIC))
		return
	set_greyscale_config(style_list[new_style])
	update_icon()
