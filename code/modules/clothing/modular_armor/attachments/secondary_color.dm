//A module you can use to add yet another color layer to your modular armor sets. icon name format is [prefix]_[bodypart]_secondary_color_[variant] , exclude _variant if you do not use it

/obj/item/armor_module/armor/secondary_color
	flags_attach_features = ATTACH_SAME_ICON|ATTACH_APPLY_ON_MOB
	secondary_color = TRUE
	flags_item_map_variant = NONE

/obj/item/armor_module/armor/secondary_color/update_greyscale()
	if(!parent)
		return
	. = ..()

/obj/item/armor_module/armor/secondary_color/on_attach(obj/item/attaching_to, mob/user)
	. = ..()
	greyscale_config = attaching_to.greyscale_config
	name = "[attaching_to.name] secondary color"

	update_icon()
	update_greyscale()
	RegisterSignal(attaching_to, COMSIG_ITEM_VARIANT_CHANGE, PROC_REF(on_variant_change))

/obj/item/armor_module/armor/secondary_color/proc/on_variant_change(mob/user, variant)
	SIGNAL_HANDLER
	if(variant in icon_state_variants)
		current_variant = variant
		update_icon()
		update_greyscale()

/obj/item/armor_module/armor/secondary_color/chest
	name = "chest secondary_color"
	icon_state = "chest_secondary_color"
	slot = ATTACHMENT_SLOT_CHEST_SECONDARY_COLOR

/obj/item/armor_module/armor/secondary_color/chest/webbing
	colorable_allowed = ICON_STATE_VARIANTS_ALLOWED|PRESET_COLORS_ALLOWED
	current_variant = "normal"
	icon_state_variants = list(
		"normal",
		"webbing",
	)

/obj/item/armor_module/armor/secondary_color/leg
	name = "leg secondary_color"
	icon_state = "leg_secondary_color"
	slot = ATTACHMENT_SLOT_KNEE_SECONDARY_COLOR

/obj/item/armor_module/armor/secondary_color/arm
	name = "arm secondary_color"
	icon_state = "arm_secondary_color"
	slot = ATTACHMENT_SLOT_ARM_SECONDARY_COLOR

/obj/item/armor_module/armor/secondary_color/helm
	name = "helm secondary_color"
	icon_state = "helm_secondary_color"
	slot = ATTACHMENT_SLOT_HELM_SECONDARY_COLOR
