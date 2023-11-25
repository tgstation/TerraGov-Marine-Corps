//A module you can use to add yet another color layer to your modular armor sets. icon name format is [prefix]_[bodypart]_highlight_[variant] , exclude _variant if you do not use it

/obj/item/armor_module/armor/highlight
	flags_attach_features = ATTACH_SAME_ICON|ATTACH_APPLY_ON_MOB
	secondary_color = TRUE
	flags_item_map_variant = NONE

/obj/item/armor_module/armor/highlight/update_greyscale()
	if(!parent)
		return
	. = ..()

/obj/item/armor_module/armor/highlight/on_attach(obj/item/attaching_to, mob/user)
	. = ..()
	greyscale_config = attaching_to.greyscale_config
	update_icon()
	update_greyscale()

/obj/item/armor_module/armor/highlight/chest_highlight
	name = "chest highlight"
	icon_state = "chest_highlight"
	slot = ATTACHMENT_SLOT_CHEST_HIGHLIGHT

/obj/item/armor_module/armor/highlight/chest_highlight/webbing
	colorable_allowed = ICON_STATE_VARIANTS_ALLOWED|PRESET_COLORS_ALLOWED
	current_variant = "normal"
	icon_state_variants = list(
		"normal",
		"webbing",
	)

/obj/item/armor_module/armor/highlight/leg_highlight
	name = "leg highlight"
	icon_state = "leg_highlight"
	slot = ATTACHMENT_SLOT_KNEE_HIGHLIGHT

/obj/item/armor_module/armor/highlight/arm_highlight
	name = "arm highlight"
	icon_state = "arm_highlight"
	slot = ATTACHMENT_SLOT_ARM_HIGHLIGHT

/obj/item/armor_module/armor/highlight/helm_highlight
	name = "helm highlight"
	icon_state = "helm_highlight"
	slot = ATTACHMENT_SLOT_HELM_HIGHLIGHT
