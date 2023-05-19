/obj/item/armor_module/greyscale/kama
	name = "6E chameleon kama"
	desc = "A chromatic kama to improve on the design of the 7E badge, this kama is capable of two colors, for all your fashion needs. Hanged from the belt, it serves to flourish the lower extremities.  \n Interact with facepaint to color. Attaches onto a uniform."
	icon_state = "kama"
	slot = ATTACHMENT_SLOT_KAMA
	attachment_layer = KAMA_LAYER
	prefered_slot = SLOT_W_UNIFORM
	greyscale_config = /datum/greyscale_config/kama
	greyscale_colors = COLOR_VERY_LIGHT_GRAY
	flags_attach_features = ATTACH_REMOVABLE|ATTACH_SAME_ICON|ATTACH_APPLY_ON_MOB
	attach_delay = 0 SECONDS
	detach_delay = 0 SECONDS
	secondary_color = TRUE
	attachments_by_slot = list(ATTACHMENT_SLOT_KAMA_HIGHLIGHT)
	starting_attachments = list(/obj/item/armor_module/greyscale/kama_highlight)

/obj/item/armor_module/greyscale/kama/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/attachment_handler, \
	attachments_by_slot, \
	list(/obj/item/armor_module/greyscale/kama_highlight), \
	starting_attachments = starting_attachments)

/obj/item/armor_module/greyscale/kama_highlight
	name = "Kama Highlight"
	desc = "A kama to improve on the design of the 7E badge, this cape is capable of six colors, for all your fashion needs. This variation of the cape functions more as a scarf. \n Interact with facepaint to color. Attaches onto a uniform."
	icon_state = "kama_highlight"
	slot = ATTACHMENT_SLOT_KAMA_HIGHLIGHT
	flags_attach_features = ATTACH_SAME_ICON|ATTACH_APPLY_ON_MOB
	greyscale_config = /datum/greyscale_config/kama
	greyscale_colors = COLOR_MAROON
	secondary_color = TRUE
