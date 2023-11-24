//A module you can use to add yet another color layer to your modular armor sets. icon name format is [prefix][bodypart]_highlight

/obj/item/armor_module/armor/highlight
	flags_attach_features = ATTACH_SAME_ICON|ATTACH_APPLY_ON_MOB
	secondary_color = TRUE
	flags_item_map_variant = NONE

/obj/item/armor_module/armor/highlight/on_attach(obj/item/attaching_to, mob/user)
	icon = attaching_to.icon
	greyscale_config = attaching_to.greyscale_config
	RegisterSignal(attaching_to, COMSIG_ITEM_VARIANT_CHANGE, PROC_REF(on_variant_change)())
	. = ..()

/obj/item/armor_module/armor/highlight/proc/on_variant_change(mob/user, variant)
	SIGNAL_HANDLER
	if(variant in icon_state_variants)
		current_variant = variant
		update_icon()
		update_greyscale()

/obj/item/armor_module/armor/highlight/chest_highlight
	name = "chest highlight"
	icon_state = "chest_highlight"
	slot = ATTACHMENT_SLOT_CHEST_HIGHLIGHT

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
